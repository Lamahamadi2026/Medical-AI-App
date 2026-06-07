import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMute extends StatefulWidget {
  const HomeMute({super.key});

  @override
  State<HomeMute> createState() => _HomeMuteState();
}

class _HomeMuteState extends State<HomeMute> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textCtrl = TextEditingController();

  String _userName = 'المستخدم';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('name') ?? 'المستخدم';

    // إعدادات النطق
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _tts.stop();
    await _tts.speak(t);
  }

  Future<void> _speakTyped() async => _speak(_textCtrl.text);

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlue = Color(0xFF64B5F6);

    final actions = <Map<String, dynamic>>[
      {'text': 'أحتاج مساعدة من فضلك', 'icon': Icons.help_outline},
      {'text': 'أشعر بألم', 'icon': Icons.healing},
      {'text': 'أريد الماء', 'icon': Icons.water_drop_outlined},
      {'text': 'أريد الذهاب إلى الحمام', 'icon': Icons.wc},
      {'text': 'اتصل بالطبيب', 'icon': Icons.local_hospital_outlined},
      {'text': 'من فضلك انتظر قليلًا', 'icon': Icons.hourglass_bottom},
      {'text': 'شكراً لك', 'icon': Icons.favorite_border},
      {'text': 'طوارئ! اتصل بالإسعاف', 'icon': Icons.emergency},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          title: Text('واجهة البكم - $_userName', textDirection: TextDirection.rtl),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.keyboard), text: 'نص ➜ صوت'),
              Tab(icon: Icon(Icons.touch_app), text: 'تواصل سريع'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [lightBlue, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              _textToSpeechTab(primaryBlue),
              _quickActionsTab(primaryBlue, actions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textToSpeechTab(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        textDirection: TextDirection.rtl,
        children: [
          _infoCard(
            title: 'تحويل النص إلى صوت',
            subtitle: 'اكتب ما تريد قوله وسيقوم التطبيق بنطقه بصوت مسموع.',
            icon: Icons.record_voice_over,
            color: primaryBlue,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _textCtrl,
            maxLines: 6,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب هنا...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.92),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _speakTyped,
                    icon: const Icon(Icons.volume_up),
                    label: const Text(
                      'نطق النص',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _textCtrl.clear();
                    _tts.stop();
                    setState(() {});
                  },
                  icon: Icon(Icons.delete_outline, color: primaryBlue),
                  label: Text('مسح', style: TextStyle(color: primaryBlue)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionsTab(Color primaryBlue, List<Map<String, dynamic>> actions) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        textDirection: TextDirection.rtl,
        children: [
          _infoCard(
            title: 'تواصل سريع',
            subtitle: 'اضغط على أي بطاقة ليتم نطق الجملة فورًا.',
            icon: Icons.touch_app,
            color: primaryBlue,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              itemCount: actions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.25,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final item = actions[i];
                final text = item['text'] as String;
                final isEmergency = text.contains('طوارئ');

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _speak(text),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isEmergency ? Colors.redAccent : primaryBlue.withOpacity(0.25),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: isEmergency ? Colors.redAccent : primaryBlue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isEmergency ? Colors.redAccent : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
