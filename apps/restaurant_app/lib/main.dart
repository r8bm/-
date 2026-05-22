import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); final api=ApiService(); await api.load(); runApp(RestaurantApp(api:api)); }
class RestaurantApp extends StatelessWidget{final ApiService api; const RestaurantApp({super.key,required this.api}); @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Delivery Restaurant',theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:Colors.orange),useMaterial3:true),home:api.token==null?RestaurantLoginScreen(api:api):DashboardScreen(api:api));}
