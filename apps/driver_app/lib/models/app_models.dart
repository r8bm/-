class UserSession {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? driver;
  UserSession({required this.token, required this.user, this.driver});
  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    token: json['token'], user: Map<String, dynamic>.from(json['user']),
    driver: json['driver'] == null ? null : Map<String, dynamic>.from(json['driver']),
  );
}

class DeliveryOrder {
  final int id;
  final String customerName;
  final String? customerPhone;
  final double customerLat;
  final double customerLng;
  final String? customerAddress;
  final int foodPrice;
  final int deliveryFee;
  final int totalPrice;
  final String paymentMethod;
  final String status;
  final String? allowedReturnBy;
  final int? allowedReturnMinutes;
  final int lateMinutes;
  DeliveryOrder({required this.id, required this.customerName, this.customerPhone, required this.customerLat, required this.customerLng, this.customerAddress, required this.foodPrice, required this.deliveryFee, required this.totalPrice, required this.paymentMethod, required this.status, this.allowedReturnBy, this.allowedReturnMinutes, required this.lateMinutes});
  factory DeliveryOrder.fromJson(Map<String, dynamic> j) => DeliveryOrder(
    id: j['id'], customerName: j['customer_name'], customerPhone: j['customer_phone'],
    customerLat: (j['customer_lat'] as num).toDouble(), customerLng: (j['customer_lng'] as num).toDouble(),
    customerAddress: j['customer_address'], foodPrice: j['food_price'], deliveryFee: j['delivery_fee'], totalPrice: j['total_price'],
    paymentMethod: j['payment_method'], status: j['status'], allowedReturnBy: j['allowed_return_by'], allowedReturnMinutes: j['allowed_return_minutes'], lateMinutes: j['late_minutes'] ?? 0,
  );
}
