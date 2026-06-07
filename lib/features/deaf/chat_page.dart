import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeDeafScreen extends StatefulWidget {
  const HomeDeafScreen({super.key});

  @override
  State<HomeDeafScreen> createState() => _HomeDeafScreenState();
}

class _HomeDeafScreenState extends State<HomeDeafScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechReady = false;
  bool _listening = false;

  String _userName = 'المستخدم';
  String _recognizedText = 'اضغط على زر المايك لبدء تحويل الكلام إلى نص...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('name') ?? 'المستخدم';

    _speechReady = await _speech.initialize(
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'done' || s == 'notListening') {
          setState(() => _listening = false);
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _recognizedText = 'حدث خطأ في التعرف على الصوت: ${e.errorMsg}';
        });
      },
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (!_speechReady) {
      setState(() => _recognizedText = 'التعرف على الصوت غير جاهز على هذا الجهاز.');
      return;
    }

    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    setState(() {
      _listening = true;
      _recognizedText = 'استمع الآن... تحدث بالقرب من الهاتف.';
    });

    await _speech.listen(
      localeId: 'ar_SA',
      onResult: (res) {
        if (!mounted) return;
        setState(() => _recognizedText = res.recognizedWords.isEmpty
            ? 'لم يتم التقاط كلام واضح... حاول مرة أخرى.'
            : res.recognizedWords);
      },
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlue = Color(0xFF64B5F6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          'واجهة الصم - $_userName',
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              _infoCard(
                title: 'ترجمة الكلام إلى نص',
                subtitle: 'اجعل شخصًا يتحدث، وستظهر الكلمات هنا كنص لتسهيل التواصل.',
                icon: Icons.mic_none,
                color: primaryBlue,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _recognizedText,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 20, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _listening ? Colors.redAccent : primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _toggleListen,
                  icon: Icon(_listening ? Icons.stop : Icons.mic),
                  label: Text(
                    _listening ? 'إيقاف الاستماع' : 'ابدأ الاستماع',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.black54, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
