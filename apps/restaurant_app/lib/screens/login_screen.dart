import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class RestaurantLoginScreen extends StatefulWidget { final ApiService api; const RestaurantLoginScreen({super.key, required this.api}); @override State<RestaurantLoginScreen> createState()=>_RestaurantLoginScreenState(); }
class _RestaurantLoginScreenState extends State<RestaurantLoginScreen>{
  final phone=TextEditingController(text:'07711111111'); final pass=TextEditingController(text:'123456'); final base=TextEditingController(text:ApiService.defaultBaseUrl); String? error; bool loading=false;
  Future<void> login() async { setState(()=>loading=true); try{ widget.api.baseUrl=base.text.trim(); final d=await widget.api.login(phone.text.trim(),pass.text.trim()); final role=d['user']['role']; if(role!='restaurant_admin' && role!='restaurant_staff') throw ApiException('هذا التطبيق خاص بالمطعم فقط'); if(!mounted)return; Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>DashboardScreen(api:widget.api))); }catch(e){ setState(()=>error=e.toString()); }finally{ if(mounted)setState(()=>loading=false); } }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('دخول المطعم')),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[TextField(controller:base,decoration:const InputDecoration(labelText:'رابط السيرفر')),TextField(controller:phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),TextField(controller:pass,obscureText:true,decoration:const InputDecoration(labelText:'كلمة المرور')),if(error!=null)Text(error!,style:const TextStyle(color:Colors.red)),FilledButton(onPressed:loading?null:login,child:Text(loading?'جاري الدخول':'دخول'))])));
}
