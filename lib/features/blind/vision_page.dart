import 'dart:convert';
import 'dart:io';
import 'dart:async'; // 👈 ضروري لعمل الـ Timeout

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';

class BlindPage extends StatefulWidget {
  const BlindPage({super.key});

  @override
  State<BlindPage> createState() => _BlindPageState();
}

class _BlindPageState extends State<BlindPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  final FlutterTts _flutterTts = FlutterTts();

  // 💡 تأكد من أن هذا الرابط هو الرابط النشط حالياً في ngrok
  final String apiUrl = "https://84dd-190-2-149-218.ngrok-free.app/api/analyze/";
  final String ocrUrl = "https://84dd-190-2-149-218.ngrok-free.app/api/read-text/";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();

    if (await Permission.camera.isDenied) {
      await _speak("عذرًا، لا يمكن فتح الكاميرا بدون إذن.");
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      await _speak("لم يتم العثور على كاميرا على هذا الجهاز.");
      return;
    }

    // تهيئة الكاميرا بدقة عالية (1080p) لتوازن السرعة والدقة
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });

      await _speak("تم تشغيل الكاميرا. انقر للتعرف على المحيط، أو اضغط مطولاً لقراءة النص.");
    } catch (e) {
      print("Camera Init Error: $e");
      await _speak("حدث خطأ أثناء تشغيل الكاميرا.");
    }
  }

  // --- دالة التعرف على الأشياء (نظام YOLO) ---
  Future<void> _captureAndDescribe() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    await _speak("جاري تحليل المحيط...");

    try {
      final picture = await _controller!.takePicture();
      final result = await _sendRequestToServer(File(picture.path), apiUrl);

      if (result != null && result["tts_text"] != null) {
        await _speak(result["tts_text"]);
      } else {
        await _speak("لم أتمكن من التعرف على الأشياء حالياً.");
      }
    } catch (e) {
      await _speak("عذراً، فشل الاتصال بالخادم.");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- دالة قراءة النصوص (نظام Layout + EasyOCR) ---
  Future<void> _captureAndReadText() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    await _speak("جاري استخراج النص من الصورة...");

    try {
      final picture = await _controller!.takePicture();
      final result = await _sendRequestToServer(File(picture.path), ocrUrl);
      print("========== OCR RESULT ==========");
      print(result);
      print("================================");
      if (result != null && result["tts_text"] != null) {
        // نطق النص الذي استخرجه الخادم بدقة
        await _speak(result["tts_text"]);
      } else {
        await _speak("لم أتمكن من العثور على نص واضح.");
      }
    } catch (e) {
      await _speak("حدث خطأ أثناء محاولة قراءة النص.");
    } finally {
      setState(() => _isProcessing = false);
    }


  }

  // 💡 دالة موحدة لإرسال الطلبات تدعم التوقيت والعربية
  Future<Map<String, dynamic>?> _sendRequestToServer(File imageFile, String url) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // وضع مهلة 30 ثانية لأن معالجة الذكاء الاصطناعي قد تستغرق وقتاً
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // تصحيح فك تشفير اللغة العربية (UTF-8)
        String responseBody = utf8.decode(response.bodyBytes);
        return jsonDecode(responseBody);
      }
      return null;
    } catch (e) {
      print("🔥 Server Error: $e");
      return null;
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("ar");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.8); // سرعة هادئة لتكون واضحة للكفيف
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraReady
          ? GestureDetector(
        onTap: _captureAndDescribe,
        onLongPress: _captureAndReadText,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}