import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _selectedCondition;
  bool _loading = false;

  /// حفظ بيانات المريض في SharedPreferences
  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameCtrl.text.trim());
    await prefs.setString('email', _emailCtrl.text.trim());
    await prefs.setString('condition', _selectedCondition!);

    // محاكاة تأخير قصير لإظهار مؤشر التحميل
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم إنشاء الحساب بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    // الانتقال إلى صفحة تسجيل الدخول
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color accentBlue = Color(0xFF42A5F5);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // شعار طبي دائري
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_hospital_rounded,
                      size: 50, color: primaryBlue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'إنشاء حساب جديد',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل بياناتك لإنشاء حسابك الطبي الشخصي',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),

                // البطاقة البيضاء لحقول التسجيل
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _nameCtrl,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم' : null,
                        ),
                        const SizedBox(height: 14),

                        _buildTextField(
                          controller: _emailCtrl,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'الرجاء إدخال البريد الإلكتروني'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        _buildTextField(
                          controller: _passCtrl,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          obscure: true,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'كلمة المرور قصيرة جدًا'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            labelText: 'اختر حالتك الصحية',
                            prefixIcon: const Icon(
                                Icons.accessibility_new_rounded,
                                color: primaryBlue),
                          ),
                          value: _selectedCondition,
                          items: const [
                            DropdownMenuItem(
                                value: 'deaf', child: Text('مريض الصم')),
                            DropdownMenuItem(
                                value: 'mute', child: Text('مريض البكم')),
                            DropdownMenuItem(
                                value: 'blind', child: Text('مريض المكفوفين')),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedCondition = v),
                          validator: (v) =>
                          v == null ? 'الرجاء اختيار الحالة الصحية' : null,
                        ),
                        const SizedBox(height: 30),

                        // زر التسجيل
                        GestureDetector(
                          onTap: _loading ? null : _register,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: _loading
                                    ? [Colors.grey, Colors.grey]
                                    : [primaryBlue, accentBlue],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.4),
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
                                'إنشاء الحساب',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'لديك حساب بالفعل؟ تسجيل الدخول',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔧 مكون مساعد لبناء حقل نصي بشكل موحد
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    const Color primaryBlue = Color(0xFF1565C0);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.blue[50],
      ),
      validator: validator,
    );
  }
}
