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
    } catch (e) {
      print("!! Model missing or invalid (size 134 bytes). Proceeding with fallback logic. Error: $e\n");
    }
    
    print("!! Fetching All Messages !!\n");
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500, // limit to 500 most recent
      );

      print("Got all Messages\n");
      final processed = await Future.wait(
        messages.map((sms) async {
          final body = sms.body ?? '';
          final sender = sms.sender ?? 'Unknown';
          final date = sms.date ?? DateTime.now();
          // print("\tProccessing Messages:\n\t\t$body\n");

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

          // Trigger notification if spam and alerts enabled
          if (processedSms.isSpam) {
            final alertsEnabled = await SettingsManager.getBool(SettingsManager.keySpamAlerts);
            if (alertsEnabled) {
              NotificationService.showSpamAlert(sender: sender, body: body);
            }
          }

          return processedSms;
        }),
      );

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
    final text = body.toLowerCase();
    
    // if (tokenizer == null || session == null) {
    //   // Fallback dummy logic if model is not present yet
    //   bool isDummySpam = text.contains("offer") || text.contains("free") || text.contains("win");
    //   return SmsClassification(isSpam: isDummySpam, confidence: isDummySpam ? 0.85 : 0.95);
    // }


    final tokenizedText = tokenizer.encode(
      body,
      addSpecialTokens: true,
    );

    final tokens = tokenizedText.ids;
    print("\t\tTokenized Text: $tokens\n");
    print("\t\tRunning Model ... for above text\n");

    print('Inputs:  ${session.inputNames}');
    print('Outputs: ${session.outputNames}');

    final inputIds = Int64List.fromList(tokenizedText.ids);
    final attentionMask = Int64List.fromList(tokenizedText.attentionMask);
    final seqLen = tokenizedText.ids.length;

    final inputs = {
      'input_ids': await OrtValue.fromList(inputIds, [1, seqLen]),
      'attention_mask': await OrtValue.fromList(attentionMask, [1, seqLen]),
    };

    final outputs = await session.run(inputs);

    final finalScore = await outputs['logits']!.asList();
    // Softmax ------------------------
    // logits is [[ham_score, spam_score]] — flatten it
    final logits = (finalScore[0] as List).cast<double>();
    print('\t\tLogits: ${logits}');
    // logits = [3.458, -3.014]

    // Apply softmax
    final hamLogit = logits[0];
    final spamLogit = logits[1];

    final maxLogit = hamLogit > spamLogit
        ? hamLogit
        : spamLogit; // for numerical stability
    final expHam = exp(hamLogit - maxLogit);
    final expSpam = exp(spamLogit - maxLogit);
    final sumExp = expHam + expSpam;

    final hamProb = expHam / sumExp;
    final spamScore = expSpam / sumExp;

    // print('HAM:  ${(hamProb * 100).toStringAsFixed(1)}%');
    print('SPAM: ${(spamScore * 100).toStringAsFixed(1)}%');

    // final double spamScore = spamProb;
    // --------------------------------

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
