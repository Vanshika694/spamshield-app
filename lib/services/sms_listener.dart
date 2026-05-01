import 'dart:typed_data';
import 'dart:math';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_embedder/flutter_embedder.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'notification_service.dart';
import 'sms_service.dart';

class SmsListener {
  static final Telephony _telephony = Telephony.instance;

  static void start() {
    _telephony.listenIncomingSms(
      onNewMessage: _onForegroundSms,
      onBackgroundMessage: _smsBackgroundHandler,
    );
  }

  static Future<void> _onForegroundSms(SmsMessage message) async {
    print("New SMS!!");
    if (message.body == null || message.body!.isEmpty) return;
    final classification = await SmsService.classifyText(message.body!);
    print("Message: ${message.body} | Output:${classification.isSpam}");
    if (classification.isSpam) {
      await NotificationService.showSpamAlert(
        sender: message.address ?? 'Unknown',
        body: message.body!,
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _smsBackgroundHandler(SmsMessage message) async {
  if (message.body == null || message.body!.isEmpty) return;

  await NotificationService.init();
  await initFlutterEmbedder();

  final tokenizer = await HfTokenizer.fromAsset('assets/model/tokenizer.json');
  final ort = OnnxRuntime();
  final session = await ort.createSessionFromAsset('assets/model/model.onnx');

  final encoded = tokenizer.encode(message.body!, addSpecialTokens: true);
  final seqLen = encoded.ids.length;
  final inputs = {
    'input_ids': await OrtValue.fromList(Int64List.fromList(encoded.ids), [
      1,
      seqLen,
    ]),
    'attention_mask': await OrtValue.fromList(
      Int64List.fromList(encoded.attentionMask),
      [1, seqLen],
    ),
  };

  final outputs = await session.run(inputs);
  final raw = await outputs['logits']!.asList();
  final logits = ((raw as List)[0] as List).cast<double>();

  final maxLogit = logits[0] > logits[1] ? logits[0] : logits[1];
  final spamScore =
      exp(logits[1] - maxLogit) /
      (exp(logits[0] - maxLogit) + exp(logits[1] - maxLogit));

  if (spamScore >= 0.35) {
    await NotificationService.showSpamAlert(
      sender: message.address ?? 'Unknown',
      body: message.body!,
    );
  }
}
