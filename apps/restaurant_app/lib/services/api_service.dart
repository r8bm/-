import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception { final String message; ApiException(this.message); @override String toString()=>message; }
class ApiService {
  static const String defaultBaseUrl = 'http://10.0.2.2:8080';
  String baseUrl; String? token;
  ApiService({this.baseUrl = defaultBaseUrl});
  Future<void> load() async { final p=await SharedPreferences.getInstance(); token=p.getString('token'); baseUrl=p.getString('baseUrl')??defaultBaseUrl; }
  Map<String,String> get headers=>{'Content-Type':'application/json', if(token!=null)'Authorization':'Bearer $token'};
  Future<Map<String,dynamic>> _handle(http.Response r) async { final d=r.body.isEmpty?<String,dynamic>{}:jsonDecode(r.body) as Map<String,dynamic>; if(r.statusCode>=400) throw ApiException(d['error']?.toString()??'Server error'); return d; }
  Future<Map<String,dynamic>> login(String phone,String password) async { final r=await http.post(Uri.parse('$baseUrl/auth/login'),headers:headers,body:jsonEncode({'phone':phone,'password':password})); final d=await _handle(r); token=d['token']; final p=await SharedPreferences.getInstance(); await p.setString('token',token!); await p.setString('baseUrl',baseUrl); return d; }
  Future<void> logout() async { token=null; final p=await SharedPreferences.getInstance(); await p.remove('token'); }
  Future<Map<String,dynamic>> settings()=>_handle(http.get(Uri.parse('$baseUrl/restaurant/settings'),headers:headers));
  Future<Map<String,dynamic>> updateSettings(Map<String,dynamic> body)=>_handle(http.put(Uri.parse('$baseUrl/restaurant/settings'),headers:headers,body:jsonEncode(body)));
  Future<Map<String,dynamic>> drivers()=>_handle(http.get(Uri.parse('$baseUrl/restaurant/drivers'),headers:headers));
  Future<Map<String,dynamic>> createDriver(Map<String,dynamic> body)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/drivers'),headers:headers,body:jsonEncode(body)));
  Future<Map<String,dynamic>> orders()=>_handle(http.get(Uri.parse('$baseUrl/restaurant/orders'),headers:headers));
  Future<Map<String,dynamic>> createOrder(Map<String,dynamic> body)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/orders'),headers:headers,body:jsonEncode(body)));
  Future<Map<String,dynamic>> assignOrder(int orderId,int driverId)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/orders/$orderId/assign'),headers:headers,body:jsonEncode({'driver_id':driverId})));
  Future<Map<String,dynamic>> liveMap()=>_handle(http.get(Uri.parse('$baseUrl/restaurant/live-map'),headers:headers));
  Future<Map<String,dynamic>> penalties()=>_handle(http.get(Uri.parse('$baseUrl/restaurant/penalties'),headers:headers));
  Future<Map<String,dynamic>> approvePenalty(int id)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/penalties/$id/approve'),headers:headers));
  Future<Map<String,dynamic>> manualPenalty(Map<String,dynamic> body)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/penalties/manual'),headers:headers,body:jsonEncode(body)));
  Future<Map<String,dynamic>> driverReport(int driverId,String date)=>_handle(http.get(Uri.parse('$baseUrl/restaurant/drivers/$driverId/report?date=$date'),headers:headers));
  Future<Map<String,dynamic>> closeSettlement(int driverId,String date,int amount)=>_handle(http.post(Uri.parse('$baseUrl/restaurant/settlements/$driverId/close'),headers:headers,body:jsonEncode({'date':date,'amount_returned_by_driver':amount})));
}
