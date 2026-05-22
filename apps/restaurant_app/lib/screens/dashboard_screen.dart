import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'drivers_screen.dart';
import 'settings_screen.dart';
import 'penalties_screen.dart';
import 'reports_screen.dart';
import 'live_map_screen.dart';

class DashboardScreen extends StatelessWidget { final ApiService api; const DashboardScreen({super.key,required this.api});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('لوحة المطعم'),actions:[IconButton(onPressed:()async{await api.logout(); if(context.mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>RestaurantLoginScreen(api:api)));},icon:const Icon(Icons.logout))]),body:GridView.count(crossAxisCount:2,padding:const EdgeInsets.all(16),crossAxisSpacing:12,mainAxisSpacing:12,children:[
    _tile(context,'الطلبات',Icons.receipt_long,OrdersScreen(api:api)),_tile(context,'المندوبون',Icons.delivery_dining,DriversScreen(api:api)),_tile(context,'الخريطة المباشرة',Icons.map,LiveMapScreen(api:api)),_tile(context,'العقوبات',Icons.gavel,PenaltiesScreen(api:api)),_tile(context,'التقارير والمحاسبة',Icons.calculate,ReportsScreen(api:api)),_tile(context,'الإعدادات',Icons.settings,SettingsScreen(api:api)),
  ]));
  Widget _tile(BuildContext c,String title,IconData icon,Widget page)=>Card(child:InkWell(onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>page)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:44),const SizedBox(height:8),Text(title,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold),textAlign:TextAlign.center)])));
}
