import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // محاكاة تسجيل الدخول

    final prefs = await SharedPreferences.getInstance();
    final condition = prefs.getString('condition') ?? 'deaf';

    if (!mounted) return;
    setState(() => _loading = false);

    // التوجيه حسب نوع الحالة
    switch (condition) {
      case 'deaf':
        Navigator.pushReplacementNamed(context, '/welcome');
        break;
      case 'mute':
        Navigator.pushReplacementNamed(context, '/welcome');
        break;
      case 'blind':
        Navigator.pushReplacementNamed(context, '/welcome');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/welcome');   }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlue = Color(0xFFE3F2FD);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_information_rounded,
                        size: 90, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أدخل بياناتك للوصول إلى حسابك الطبي',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 28),

                    // نموذج تسجيل الدخول
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userCtrl,
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني أو رقم الهاتف',
                              prefixIcon: const Icon(Icons.person_outline,
                                  color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'يرجى إدخال البريد الإلكتروني أو الهاتف'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: primaryBlue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primaryBlue,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'كلمة المرور قصيرة جدًا'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // زر تسجيل الدخول
                          GestureDetector(
                            onTap: _loading ? null : _submit,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: _loading
                                      ? [Colors.grey, Colors.grey]
                                      : [primaryBlue, Colors.lightBlueAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _loading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                    : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'ليس لديك حساب؟ إنشاء حساب جديد',
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
