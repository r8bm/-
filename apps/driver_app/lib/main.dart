import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/driver_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  await api.load();
  runApp(DriverApp(api: api));
}

class DriverApp extends StatelessWidget {
  final ApiService api;
  const DriverApp({super.key, required this.api});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Delivery Driver',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true, fontFamily: 'Roboto'),
    home: api.token == null ? LoginScreen(api: api) : DriverHomeScreen(api: api),
  );
}
