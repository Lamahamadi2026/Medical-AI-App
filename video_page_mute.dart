import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPageMute extends StatefulWidget {
  const VideoPageMute({super.key});

  @override
  State<VideoPageMute> createState() => _VideoPageMuteState();
}

class _VideoPageMuteState extends State<VideoPageMute> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isProcessingFrame = false; // لمنع تكدس الفريمات أثناء التحليل المستقبلي

  // شريط النصوص السفلي الذي سيعرض ترجمة لغة الإشارة المباشرة ريل تايم
  String _detectedText = "وجه الكاميرا نحو اليد لبدء ترجمة لغة الإشارة...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLiveVideo();
  }

  Future<void> _initLiveVideo() async {
    // 1. طلب إذن استخدام الكاميرا من نظام التشغيل
    await Permission.camera.request();

    if (await Permission.camera.isDenied) {
      setState(() => _detectedText = "عذرًا، يجب السماح بصلاحية الكاميرا لترجمة الإشارات.");
      return;
    }

    // 2. جلب الكاميرات المتاحة في جهاز الـ Redmi
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _detectedText = "لم يتم العثور على كاميرا في الجهاز.");
      return;
    }

    // 3. إعداد الكاميرا بدقة عالية لالتقاط تفاصيل حركة الأصابع واليدين بسلاسة ريل تايم
    _controller = CameraController(
      cameras.first, // استخدام الكاميرا الخلفية (يمكن تبديلها لـ cameras[1] إذا كانت الأمامية)
      ResolutionPreset.high,
      enableAudio: false, // الكاميرا صامتة تماماً لتناسب واجهة البكم وتوفير موارد المعالج
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });

      // 4. تشغيل تدفق الفريمات الفوري (Image Stream) بمجرد نجاح تهيئة الفيديو المباشر
      _startLiveSignStream();

    } catch (e) {
      print("Error Initializing Sign Language Video: $e");
      setState(() => _detectedText = "حدث خطأ أثناء تشغيل فيديو لغة الإشارة.");
    }
  }

  // دالة تهيئة واستقبال فريمات الفيديو الحي ريل تايم لخدمة لغة الإشارة
  void _startLiveSignStream() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((CameraImage availableFrame) {
      // إذا كان النموذج مشغولاً بتحليل فريم سابق، يتم تخطي الفريم الحالي لمنع تعليق الفيديو
      if (_isProcessingFrame) return;

      _isProcessingFrame = true;

      // ✋ [مكان ربط نموذج لغة الإشارة مستقبلاً]:
      // هنا تتدفق الصور (availableFrame) كـ فريمات فيديو مستمرة أجزاء من الثانية.
      // عند تجهيز الـ Model، نقوم بتمرير 'availableFrame' إليه لتحليل حركة اليد، ثم نقوم بـ setState للـ _detectedText.

      // مثال توضيحي للمناقشة أمام الدكاترة (سيتم استبداله بالترجمة الفعلية لاحقاً):
      /*
      String result = await MySignModel.predict(availableFrame);
      setState(() {
         _detectedText = result;
      });
      */

      // إعادة تعيين الحارس لاستقبال الفريم التالي بعد معالجة الفريم الحالي
      _isProcessingFrame = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // التعامل الذكي مع الكاميرا في حال خروج المستخدم مؤقتاً من التطبيق لمنع كراش الكاميرا
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initLiveVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // إيقاف تدفق الصور وإغلاق الكاميرا نهائياً عند الخروج لتحرير ذاكرة الهاتف (RAM)
    if (_controller != null && _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('مترجم لغة الإشارة الفوري', textDirection: TextDirection.rtl),
        centerTitle: true,
      ),
      body: _isCameraReady && _controller != null
          ? Stack(
        fit: StackFit.expand,
        children: [
          // المعاينة الحية للفيديو المستمر المباشر (Real-time Video Preview)
          CameraPreview(_controller!),

          // شريط الترجمة الذكي أسفل الشاشة لعرض النصوص المترجمة من حركة اليدين
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1565C0), width: 1.5),
              ),
              child: Text(
                _detectedText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}