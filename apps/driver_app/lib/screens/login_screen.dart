import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'consent_screen.dart';
import 'driver_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiService api;
  const LoginScreen({super.key, required this.api});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController(text: '07722222222');
  final password = TextEditingController(text: '123456');
  final baseUrl = TextEditingController(text: ApiService.defaultBaseUrl);
  bool loading = false;
  String? error;
  Future<void> login() async {
    setState(() { loading = true; error = null; widget.api.baseUrl = baseUrl.text.trim(); });
    try {
      final session = await widget.api.login(phone.text.trim(), password.text.trim());
      if (session.user['role'] != 'driver') throw ApiException('هذا التطبيق خاص بالمندوب فقط');
      final me = await widget.api.me();
      if (me['latestConsent'] == null) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ConsentScreen(api: widget.api)));
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DriverHomeScreen(api: widget.api)));
      }
    } catch (e) { setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تسجيل دخول المندوب')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: baseUrl, decoration: const InputDecoration(labelText: 'رابط السيرفر')),
      TextField(controller: phone, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
      const SizedBox(height: 16),
      if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
      FilledButton(onPressed: loading ? null : login, child: Text(loading ? 'جاري الدخول...' : 'دخول')),
    ])),
  );
}
