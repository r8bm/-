import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'driver_home_screen.dart';

class ConsentScreen extends StatefulWidget {
  final ApiService api;
  const ConsentScreen({super.key, required this.api});
  @override State<ConsentScreen> createState() => _ConsentScreenState();
}
class _ConsentScreenState extends State<ConsentScreen> {
  bool tracking = true, camera = true, background = true, loading = false;
  final loc = LocationService();
  Future<void> accept() async {
    setState(() => loading = true);
    await loc.requestAllNeededPermissions();
    await widget.api.consent(tracking: tracking, camera: camera, background: background);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DriverHomeScreen(api: widget.api)));
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الموافقة القانونية')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('يستخدم التطبيق موقعك أثناء ساعات العمل والطلبات لحساب مسار التوصيل ووقت الرجوع للمطعم. تستخدم الكاميرا فقط لإثبات التسليم أو QR. عند وجود طلب نشط قد يعمل التتبع في الخلفية حسب سياسة المطعم.'),
      CheckboxListTile(value: tracking, onChanged: (v)=>setState(()=>tracking=v??false), title: const Text('أوافق على تتبع الموقع أثناء العمل والطلبات')),
      CheckboxListTile(value: camera, onChanged: (v)=>setState(()=>camera=v??false), title: const Text('أوافق على استخدام الكاميرا لإثبات التسليم')),
      CheckboxListTile(value: background, onChanged: (v)=>setState(()=>background=v??false), title: const Text('أوافق على التتبع بالخلفية عند وجود طلب نشط')),
      FilledButton(onPressed: loading || !tracking ? null : accept, child: const Text('موافق ومتابعة'))
    ]),
  );
}
