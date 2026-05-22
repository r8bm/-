class DriverRow {
  final int id; final String name; final String phone; final String status; final double? lat; final double? lng;
  DriverRow({required this.id, required this.name, required this.phone, required this.status, this.lat, this.lng});
  factory DriverRow.fromJson(Map<String,dynamic> j)=>DriverRow(id:j['id'], name:j['name'], phone:j['phone'], status:j['status'], lat:(j['last_lat'] as num?)?.toDouble(), lng:(j['last_lng'] as num?)?.toDouble());
}
class OrderRow {
  final int id; final String customerName; final int foodPrice; final int deliveryFee; final int totalPrice; final String status; final String? driverName;
  OrderRow({required this.id, required this.customerName, required this.foodPrice, required this.deliveryFee, required this.totalPrice, required this.status, this.driverName});
  factory OrderRow.fromJson(Map<String,dynamic> j)=>OrderRow(id:j['id'], customerName:j['customer_name'], foodPrice:j['food_price'], deliveryFee:j['delivery_fee'], totalPrice:j['total_price'], status:j['status'], driverName:j['driver_name']);
}
