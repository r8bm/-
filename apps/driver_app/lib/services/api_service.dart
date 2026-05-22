import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String defaultBaseUrl = 'http://10.0.2.2:8080';
  String baseUrl;
  String? token;
  ApiService({this.baseUrl = defaultBaseUrl});

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    baseUrl = prefs.getString('baseUrl') ?? defaultBaseUrl;
  }

  Future<void> saveSession(UserSession session) async {
    token = session.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', session.token);
    await prefs.setString('baseUrl', baseUrl);
  }

  Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> _handle(http.Response res) async {
    final data = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw ApiException(data['error']?.toString() ?? 'Server error');
    return data;
  }

  Future<UserSession> login(String phone, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'), headers: headers, body: jsonEncode({'phone': phone, 'password': password}));
    final data = await _handle(res);
    final session = UserSession.fromJson(data);
    await saveSession(session);
    return session;
  }

  Future<Map<String, dynamic>> me() async => _handle(await http.get(Uri.parse('$baseUrl/me'), headers: headers));

  Future<void> consent({required bool tracking, required bool camera, required bool background}) async {
    await _handle(await http.post(Uri.parse('$baseUrl/driver/consent'), headers: headers, body: jsonEncode({
      'trackingAccepted': tracking,
      'cameraAccepted': camera,
      'backgroundTrackingAccepted': background,
      'policyVersion': '1.0',
      'acceptedText': 'I accept location tracking during working hours and deliveries, camera permission for delivery proof/QR, and background tracking when necessary for active delivery.'
    })));
  }

  Future<Map<String, dynamic>> tasks() async => _handle(await http.get(Uri.parse('$baseUrl/driver/tasks'), headers: headers));

  Future<void> sendLocation(double lat, double lng, {double? accuracy}) async {
    await _handle(await http.post(Uri.parse('$baseUrl/driver/location'), headers: headers, body: jsonEncode({'lat': lat, 'lng': lng, 'accuracy_meters': accuracy, 'provider': 'gps'})));
  }

  Future<Map<String, dynamic>> pickup(int orderId) => _handle(http.post(Uri.parse('$baseUrl/driver/orders/$orderId/pickup'), headers: headers));
  Future<Map<String, dynamic>> arrive(int orderId) => _handle(http.post(Uri.parse('$baseUrl/driver/orders/$orderId/arrive'), headers: headers));
  Future<Map<String, dynamic>> deliver(int orderId, {String? proofPath, String? note}) => _handle(http.post(Uri.parse('$baseUrl/driver/orders/$orderId/deliver'), headers: headers, body: jsonEncode({'proof_photo_path': proofPath, 'proof_note': note})));
  Future<Map<String, dynamic>> returnToRestaurant(int orderId, double lat, double lng) => _handle(http.post(Uri.parse('$baseUrl/driver/orders/$orderId/return'), headers: headers, body: jsonEncode({'lat': lat, 'lng': lng})));
  Future<Map<String, dynamic>> report(String date) => _handle(http.get(Uri.parse('$baseUrl/driver/report?date=$date'), headers: headers));
  Future<Map<String, dynamic>> penalties() => _handle(http.get(Uri.parse('$baseUrl/driver/penalties'), headers: headers));
}
