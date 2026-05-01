import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_embedder/flutter_embedder.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'settings_manager.dart';
import 'dart:math';

/// Result of a spam classification
class SmsClassification {
  final bool isSpam;
  final double confidence;
  SmsClassification({required this.isSpam, required this.confidence});
}

/// A processed SMS message with classification result
class ProcessedSms {
  final String sender;
  final String body;
  final DateTime date;
  final bool isSpam;
  final double confidence;

  ProcessedSms({
    required this.sender,
    required this.body,
    required this.date,
    required this.isSpam,
    required this.confidence,
  });
}

class SmsService {
  static const _kDebug = false;
  static final SmsQuery _query = SmsQuery();

  // ─── Permission: triggers real Android system popup ────────────
  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async => await Permission.sms.isGranted;

  static Future<void> openSettings() async => await openAppSettings();

  static HfTokenizer? _tokenizer;
  static OrtSession? _session;
  static List<ProcessedSms>? _cachedMessages;
  static Future<List<ProcessedSms>>? _loadingFuture;
  static final _progressController = StreamController<(int, int)>.broadcast();
  static Stream<(int, int)> get onProgress => _progressController.stream;

  static final _newSmsController = StreamController<ProcessedSms>.broadcast();
  static Stream<ProcessedSms> get onNewSms => _newSmsController.stream;

  static Future<void> initModel() async {
    if (_tokenizer != null && _session != null) return;
    try {
      _tokenizer = await HfTokenizer.fromAsset("assets/model/tokenizer.json");
      final ort = OnnxRuntime();
      _session = await ort.createSessionFromAsset("assets/model/model.onnx");
      print("!! Model Initialized\n");
      print('Model Inputs:  ${_session!.inputNames}');
      print('Model Outputs: ${_session!.outputNames}');
    } catch (e) {
      print("!! Model init failed: $e\n");
    }
  }

  static Future<SmsClassification> classifyText(String text) async {
    print("Classification Started !!");
    if (_tokenizer == null || _session == null) {
      final t = text.toLowerCase();
      final isDummySpam =
          t.contains("offer") || t.contains("free") || t.contains("win");
      return SmsClassification(
        isSpam: isDummySpam,
        confidence: isDummySpam ? 0.85 : 0.95,
      );
    }
    final tokenized = _tokenizer!.encode(text, addSpecialTokens: true);
    final inputIds = Int64List.fromList(tokenized.ids);
    final attentionMask = Int64List.fromList(tokenized.attentionMask);
    final seqLen = tokenized.ids.length;
    final inputs = {
      'input_ids': await OrtValue.fromList(inputIds, [1, seqLen]),
      'attention_mask': await OrtValue.fromList(attentionMask, [1, seqLen]),
    };
    final outputs = await _session!.run(inputs);
    final raw = await outputs['logits']!.asList();
    final logits = ((raw as List)[0] as List).cast<double>();
    final spamScore = _softmaxSpam(logits[0], logits[1]);
    final confidence = spamScore.clamp(0.0, 1.0);
    return SmsClassification(
      isSpam: confidence >= 0.35,
      confidence: confidence >= 0.35 ? confidence : (1.0 - confidence),
    );
  }

  static void addNewSms(String sender, String body, SmsClassification classification) {
    final sms = ProcessedSms(
      sender: sender,
      body: body,
      date: DateTime.now(),
      isSpam: classification.isSpam,
      confidence: classification.confidence,
    );
    if (_cachedMessages != null) {
      _cachedMessages = [sms, ..._cachedMessages!];
    }
    _newSmsController.add(sms);
  }

  static void correctClassification(String sender, String body, bool isSpam) {
    if (_cachedMessages == null) return;
    for (int i = 0; i < _cachedMessages!.length; i++) {
      final m = _cachedMessages![i];
      if (m.sender == sender && m.body == body) {
        final corrected = ProcessedSms(
          sender: m.sender,
          body: m.body,
          date: m.date,
          isSpam: isSpam,
          confidence: isSpam ? 1.0 : 0.0,
        );
        _cachedMessages![i] = corrected;
        _newSmsController.add(corrected);
        break;
      }
    }
  }

  /// Clear app-only history (does not touch phone SMS)
  static void clearCache() {
    _cachedMessages = null;
    _loadingFuture = null;
  }

  // ─── READ ALL SMS from device inbox ───────────────────────────
  static Future<List<ProcessedSms>> getAllSms({
    bool forceRefresh = false,
  }) async {
    if (_cachedMessages != null && !forceRefresh) return _cachedMessages!;
    if (_loadingFuture != null && !forceRefresh) return _loadingFuture!;

    _loadingFuture = _doGetAllSms();
    try {
      final result = await _loadingFuture!;
      _cachedMessages = result;
      return result;
    } finally {
      _loadingFuture = null;
    }
  }

  static Future<List<ProcessedSms>> _doGetAllSms() async {
    await initModel();

    print("!! Fetching All Messages !!\n");
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500,
      );

      if (messages.isEmpty) return [];

      final total = messages.length;
      _progressController.add((0, total));

      print("Classifying in small batches...\n");
      const batchSize = 4;
      final processed = <ProcessedSms>[];
      for (int i = 0; i < messages.length; i += batchSize) {
        final end = min(i + batchSize, messages.length);
        final batch = messages.sublist(i, end);
        final texts = batch.map((s) => s.body ?? '').toList();
        if (_kDebug)
          print(
            "Batch ${i ~/ batchSize + 1}/${(messages.length / batchSize).ceil()}: ${texts.length} messages",
          );

        final classifications = await _classifyBatch(
          texts,
          _tokenizer!,
          _session!,
        );

        for (int j = 0; j < batch.length; j++) {
          final sms = batch[j];
          final classification = classifications[j];
          processed.add(ProcessedSms(
            sender: sms.sender ?? 'Unknown',
            body: sms.body ?? '',
            date: sms.date ?? DateTime.now(),
            isSpam: classification.isSpam,
            confidence: classification.confidence,
          ));
        }

        _progressController.add((processed.length, total));
        await Future.delayed(const Duration(milliseconds: 15));
      }

      _progressController.add((total, total));
      return processed;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      return [];
    }
  }

  // ─── Softmax helper ─────────────────────────────────────────────
  static double _softmaxSpam(double hamLogit, double spamLogit) {
    final maxLogit = hamLogit > spamLogit ? hamLogit : spamLogit;
    final expHam = exp(hamLogit - maxLogit);
    final expSpam = exp(spamLogit - maxLogit);
    return expSpam / (expHam + expSpam);
  }

  // ─── Batch classifier ──────────────────────────────────────────
  static Future<List<SmsClassification>> _classifyBatch(
    List<String> texts,
    HfTokenizer tokenizer,
    OrtSession session,
  ) async {
    final encodings = await tokenizer.encodeBatchAsync(
      texts,
      addSpecialTokens: true,
    );

    int maxLen = 0;
    for (final e in encodings) {
      if (e.ids.length > maxLen) maxLen = e.ids.length;
    }

    final allIds = <int>[];
    final allMasks = <int>[];
    for (final e in encodings) {
      final pad = maxLen - e.ids.length;
      allIds.addAll(e.ids);
      allIds.addAll(List.filled(pad, 50283)); // pad_token_id
      allMasks.addAll(e.attentionMask);
      allMasks.addAll(List.filled(pad, 0));
    }

    final batchSize = texts.length;
    final inputs = {
      'input_ids': await OrtValue.fromList(Int64List.fromList(allIds), [
        batchSize,
        maxLen,
      ]),
      'attention_mask': await OrtValue.fromList(Int64List.fromList(allMasks), [
        batchSize,
        maxLen,
      ]),
    };

    final outputs = await session.run(inputs);
    final raw = await outputs['logits']!.asList();
    final pairs = (raw as List).cast<List<dynamic>>();

    final results = <SmsClassification>[];
    for (final pair in pairs) {
      final logits = (pair as List).cast<double>();
      if (_kDebug) print('\t\tLogits: ${logits}');
      final spamScore = _softmaxSpam(logits[0], logits[1]);
      if (_kDebug) print('SPAM: ${(spamScore * 100).toStringAsFixed(1)}%');
      final confidence = spamScore.clamp(0.0, 1.0);
      results.add(
        SmsClassification(
          isSpam: confidence >= 0.35,
          confidence: confidence >= 0.35 ? confidence : (1.0 - confidence),
        ),
      );
    }
    return results;
  }

  // ─── Aggregate stats ───────────────────────────────────────────
  static Map<String, int> getStats(List<ProcessedSms> messages) {
    final spam = messages.where((m) => m.isSpam).length;
    return {
      'total': messages.length,
      'spam': spam,
      'ham': messages.length - spam,
    };
  }
}
