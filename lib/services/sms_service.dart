import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_embedder/flutter_embedder.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'notification_service.dart';
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

  static List<ProcessedSms>? _cachedMessages;

  /// Clear app-only history (does not touch phone SMS)
  static void clearCache() {
    _cachedMessages = null;
  }

  // ─── READ ALL SMS from device inbox ───────────────────────────
  static Future<List<ProcessedSms>> getAllSms({bool forceRefresh = false}) async {
    if (_cachedMessages != null && !forceRefresh) return _cachedMessages!;

    print("!! Initializing Tokenizer & Model Session...\n");
    final tokenizerPath = "assets/model/tokenizer.json";
    final modelPath = "assets/model/model.onnx";

    HfTokenizer? tokenizer;
    OrtSession? session;
    
    try {
      tokenizer = await HfTokenizer.fromAsset(tokenizerPath);
      final ort = OnnxRuntime();
      session = await ort.createSessionFromAsset(modelPath);
      print("!! Tokenizer Initialized\n");
    } catch (e) {
      print("Tokenizer Missing $e\n");
    }

    try {
      final ort = OnnxRuntime();
      session = await ort.createSessionFromAsset(modelPath);
      print("Model Session Initialized\n");
      print('Model Inputs:  ${session.inputNames}');
      print('Model Outputs: ${session.outputNames}');
    } catch (e) {
      print("!! Model missing or invalid (size 134 bytes). Proceeding with fallback logic. Error: $e\n");
    }
    
    print("!! Fetching All Messages !!\n");
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500, // limit to 500 most recent
      );

      print("Got all Messages, classifying sequentially...\n");
      final processed = <ProcessedSms>[];
      for (int i = 0; i < messages.length; i++) {
        final sms = messages[i];
        final body = sms.body ?? '';
        final sender = sms.sender ?? 'Unknown';
        final date = sms.date ?? DateTime.now();

        if (_kDebug) print("[${i + 1}/${messages.length}] ${sender}: $body");

        final classification = await _classify(
          body,
          sender,
          tokenizer!,
          session!,
        );

        final processedSms = ProcessedSms(
          sender: sender,
          body: body,
          date: date,
          isSpam: classification.isSpam,
          confidence: classification.confidence,
        );

        processed.add(processedSms);

        // Trigger notification if spam and alerts enabled
        if (processedSms.isSpam) {
          final alertsEnabled = await SettingsManager.getBool(SettingsManager.keySpamAlerts);
          if (alertsEnabled) {
            NotificationService.showSpamAlert(sender: sender, body: body);
          }
        }
      }

      _cachedMessages = processed;
      return processed;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      return [];
    }
  }

  // ─── Heuristic Spam Classifier ─────────────────────────────────
  static Future<SmsClassification> _classify(
    String body,
    String sender,
    HfTokenizer tokenizer,
    OrtSession session,
  ) async {
    final tokenizedText = tokenizer.encode(
      body,
      addSpecialTokens: true,
    );

    if (_kDebug) print("\t\tTokenized Text: ${tokenizedText.ids}\n");

    final inputIds = Int64List.fromList(tokenizedText.ids);
    final attentionMask = Int64List.fromList(tokenizedText.attentionMask);
    final seqLen = tokenizedText.ids.length;

    final inputs = {
      'input_ids': await OrtValue.fromList(inputIds, [1, seqLen]),
      'attention_mask': await OrtValue.fromList(attentionMask, [1, seqLen]),
    };

    final outputs = await session.run(inputs);

    final finalScore = await outputs['logits']!.asList();
    final logits = (finalScore[0] as List).cast<double>();
    if (_kDebug) print('\t\tLogits: ${logits}');

    // Apply softmax
    final hamLogit = logits[0];
    final spamLogit = logits[1];

    final maxLogit = hamLogit > spamLogit
        ? hamLogit
        : spamLogit;
    final expHam = exp(hamLogit - maxLogit);
    final expSpam = exp(spamLogit - maxLogit);
    final sumExp = expHam + expSpam;

    final spamScore = expSpam / sumExp;
    if (_kDebug) print('SPAM: ${(spamScore * 100).toStringAsFixed(1)}%');

    final confidence = spamScore.clamp(0.0, 1.0);
    return SmsClassification(
      isSpam: confidence >= 0.35,
      confidence: confidence >= 0.35 ? confidence : (1.0 - confidence),
    );
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
