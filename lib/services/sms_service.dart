import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

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

  static Future<bool> hasPermission() async =>
      await Permission.sms.isGranted;

  static Future<void> openSettings() async => await openAppSettings();

  // ─── READ ALL SMS from device inbox ───────────────────────────
  static Future<List<ProcessedSms>> getAllSms() async {
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500, // limit to 500 most recent
      );

      return messages.map((sms) {
        final body   = sms.body   ?? '';
        final sender = sms.sender ?? 'Unknown';
        final date   = sms.date   ?? DateTime.now();

        final classification = _classify(body, sender);
        return ProcessedSms(
          sender: sender,
          body: body,
          date: date,
          isSpam: classification.isSpam,
          confidence: classification.confidence,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Heuristic Spam Classifier ─────────────────────────────────
  // TODO: Replace this with your ML model REST API call when ready:
  //   final res = await http.post('https://your-api.com/predict', body: {'text': body});
  //   final score = jsonDecode(res.body)['spam_probability'];
  static SmsClassification _classify(String body, String sender) {
    final text = body.toLowerCase();

    double spamScore = 0.0;

    // Strong spam keywords (+0.25 each)
    for (final kw in [
      'won', 'winner', 'prize', 'congratulations', 'claim',
      'free iphone', 'free gift', 'click here', 'urgent',
      'limited time', 'act now', 'lottery', 'selected',
      'cash prize', 'reward', 'bitcoin', 'crypto offer',
      'loan approved', 'instant loan', 'no documents',
      'you have been selected', 'you won',
    ]) {
      if (text.contains(kw)) spamScore += 0.25;
    }

    // Medium spam keywords (+0.12 each)
    for (final kw in [
      'offer', 'discount', 'deal', 'sale', 'apply now',
      'call now', 'reply stop', 'unsubscribe', 'earn money',
      'investment', 'earn from home', 'work from home',
    ]) {
      if (text.contains(kw)) spamScore += 0.12;
    }

    // Pattern signals
    if (RegExp(r'[A-Z]{4,}').hasMatch(body)) spamScore += 0.10; // lots of CAPS
    if (RegExp(r'!{2,}').hasMatch(body))        spamScore += 0.08; // multiple !!!
    if (RegExp(r'https?://\S+').hasMatch(text)) spamScore += 0.10; // URL present
    if (RegExp(r'\d{10}').hasMatch(body))        spamScore += 0.06; // raw phone number

    // Legitimate signals (reduce score)
    for (final kw in [
      'otp', 'one time password', 'verification code', 'your code is',
      'transaction', 'credited', 'debited', 'balance', 'a/c',
      'appointment', 'delivery', 'order', 'booking confirmed',
      'your order', 'dispatch', 'invoice',
    ]) {
      if (text.contains(kw)) spamScore -= 0.22;
    }

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
