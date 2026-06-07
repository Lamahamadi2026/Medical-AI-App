import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPageValue = _controller.page!;
      });
    });
  }

  final _pages = <_OnboardPageData>[
    _OnboardPageData(
      title: 'لمحة عن الفريق الطبي',
      subtitle: 'فريق متعدد التخصصات يضم أطباء وتمريضًا وأخصائيي تخاطب وعلاج سمعي وبصري للعمل معًا على رعاية شاملة.',
      image: "assets/images/team.png",
    ),
    _OnboardPageData(
      title: 'وظائف التطبيق لمرضى الصم',
      subtitle: 'تحويل الكلام المحيط إلى نص على الشاشة، تنبيهات اهتزازية، ودعم الترجمة الفورية للنصوص الهامة.',
      image: "assets/images/deaf.png",
    ),
    _OnboardPageData(
      title: 'وظائف التطبيق لمرضى البكم',
      subtitle: 'تحويل النص إلى كلام، عبارات سريعة للتواصل الفوري، ولوحة تواصل بصري تسهّل التعبير.',
      image: "assets/images/mute.png",
    ),
    _OnboardPageData(
      title: 'وظائف التطبيق للمكفوفين',
      subtitle: 'كاميرا ناطقة تصف المشهد من حولك، قراءة النصوص المطبوعة، وتوجيه صوتي للمساعدة في التنقل.',
      image: "assets/images/blind.png",
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // تحديد خلفية الـ Scaffold باللون الأسود
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              itemBuilder: (context, i) {
                double scale = (1 - ((_currentPageValue - i).abs() * 0.3)).clamp(0.0, 1.0);
                double opacity = (1 - ((_currentPageValue - i).abs() * 0.5)).clamp(0.0, 1.0);

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _OnboardPage(data: _pages[i]),
                  ),
                );
              },
            ),
          ),

          /// زر تخطي
          Positioned(
            top: 50,
            right: 25,
            child: InkWell(
              onTap: _finishOnboarding,
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue, // جعل اللون أبيض شفاف ليناسب الخلفية السوداء
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// مؤشر الصفحات
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                    spacing: 8,
                    dotColor: Colors.white24, // جعل النقاط غير النشطة خافتة
                    activeDotColor: Colors.white, // النقطة النشطة بيضاء بالكامل
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardPageData {
  final String title;
  final String subtitle;
  final String image;

  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardPageData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // ضمان أن تكون خلفية الصفحة نفسها سوداء
      child: Stack(
        children: [
          /// الصورة كخلفية
          Positioned.fill(
            child: Image.asset(
              data.image,
              fit: BoxFit.cover,
            ),
          ),

          /// التدرج اللوني لضمان وضوح النص فوق الصورة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9), // تدرج يبدأ شفافاً وينتهي بأسود داكن
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          /// النصوص
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      color: Colors.white38, // لون أبيض خافت قليلاً للنص الفرعي
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}