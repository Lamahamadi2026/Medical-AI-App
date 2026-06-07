import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String userName = '';
  String condition = '';
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'المستخدم';
    final cond = prefs.getString('condition') ?? 'deaf';

    setState(() {
      userName = name;
      condition = cond;
    });

    // إظهار العناصر تدريجيًا بعد تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _visible = true);

    // تأخير قبل الانتقال إلى الصفحة المناسبة
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    switch (cond) {
      case 'deaf':
        Navigator.pushReplacementNamed(context, '/home_deaf');
        break;
      case 'mute':
        Navigator.pushReplacementNamed(context, '/home_mute');
        break;
      case 'blind':
        Navigator.pushReplacementNamed(context, '/home_blind');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/home_deaf');
    }
  }

  String _getConditionText() {
    switch (condition) {
      case 'deaf':
        return 'مريض الصم 👂';
      case 'mute':
        return 'مريض البكم 🗣️';
      case 'blind':
        return 'مريض المكفوفين 👁️';
      default:
        return 'مريض';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlue = Color(0xFF64B5F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _visible ? 1.0 : 0.0,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  const Icon(Icons.local_hospital_rounded,
                      color: Colors.white, size: 90),
                  const SizedBox(height: 20),
                  Text(
                    'مرحبًا يا $userName 👋',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تم تحديد حالتك كـ ${_getConditionText()}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'جاري التحويل إلى الواجهة الخاصة بك...',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
