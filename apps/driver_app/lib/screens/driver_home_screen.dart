import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'login_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final ApiService api;
  const DriverHomeScreen({super.key, required this.api});
  @override State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}
class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final loc = LocationService();
  List<DeliveryOrder> orders = [];
  Map<String, dynamic>? report;
  List penalties = [];
  bool loading = true;
  String? error;
  @override void initState() { super.initState(); refresh(); loc.startForegroundTracking(widget.api); }
  @override void dispose() { loc.stopTracking(); super.dispose(); }
  Future<void> refresh() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.tasks();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      final rep = await widget.api.report(today);
      final pens = await widget.api.penalties();
      setState(() {
        orders = (data['orders'] as List).map((e)=>DeliveryOrder.fromJson(Map<String,dynamic>.from(e))).toList();
        report = rep['report']; penalties = pens['penalties'];
      });
    } catch (e) { setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> action(Future Function() fn) async { try { await fn(); await refresh(); } catch(e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } }
  Widget orderCard(DeliveryOrder o) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('طلب #${o.id} - ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    Text('العنوان: ${o.customerAddress ?? '${o.customerLat}, ${o.customerLng}'}'),
    Text('سعر الطلب: ${o.foodPrice} | التوصيل: ${o.deliveryFee} | المجموع: ${o.totalPrice}'),
    Text('الدفع: ${o.paymentMethod} | الحالة: ${o.status}'),
    if (o.allowedReturnBy != null) Text('يجب الرجوع قبل: ${o.allowedReturnBy} | السماح: ${o.allowedReturnMinutes} دقيقة'),
    const SizedBox(height: 8), Wrap(spacing: 8, children: [
      if (o.status == 'assigned') FilledButton(onPressed: ()=>action(()=>widget.api.pickup(o.id)), child: const Text('استلمت الطلب')),
      if (o.status == 'picked_up') FilledButton(onPressed: ()=>action(()=>widget.api.arrive(o.id)), child: const Text('وصلت للزبون')),
      if (o.status == 'picked_up' || o.status == 'arrived_customer') FilledButton(onPressed: ()=>action(() async {
        final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 60);
        await widget.api.deliver(o.id, proofPath: img?.path, note: 'Delivered by driver');
      }), child: const Text('تم التسليم')),
      if (o.status == 'returning') FilledButton(onPressed: ()=>action(() async {
        final p = await loc.currentPosition();
        await widget.api.sendLocation(p.latitude, p.longitude, accuracy: p.accuracy);
        await widget.api.returnToRestaurant(o.id, p.latitude, p.longitude);
      }), child: const Text('رجعت للمطعم')),
    ])
  ])));
  Widget reportCard() {
    final t = report?['totals'] as Map<String, dynamic>?;
    if (t == null) return const SizedBox.shrink();
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('كشف حساب اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text('عدد الطلبات: ${t['order_count']}'),
      Text('إجمالي أسعار الطلبات: ${t['total_food_price']}'),
      Text('إجمالي أجور التوصيل: ${t['total_delivery_fee']}'),
      Text('المبلغ المستلم كاش ويجب تسليمه كاملًا للمطعم: ${t['expected_return_to_restaurant']}'),
      Text('عمولتي قبل العقوبات: ${t['gross_driver_commission']}'),
      Text('عدد العقوبات: ${t['penalty_count']} | وقت العقوبات: ${t['total_penalty_minutes']} دقيقة'),
      Text('الخصم بسبب العقوبات: ${t['total_penalty_reduction']}'),
      Text('العمولة النهائية المستحقة: ${t['final_driver_commission']}', style: const TextStyle(fontWeight: FontWeight.bold)),
    ])));
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تطبيق المندوب'), actions: [IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)), IconButton(onPressed: () async { await widget.api.logout(); if(!mounted)return; Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>LoginScreen(api: widget.api))); }, icon: const Icon(Icons.logout))]),
    body: loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: refresh, child: ListView(padding: const EdgeInsets.all(12), children: [
      if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
      reportCard(),
      const SizedBox(height: 8),
      const Text('طلباتي الحالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (orders.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('لا توجد طلبات نشطة'))),
      ...orders.map(orderCard),
      const Text('آخر العقوبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ...penalties.take(5).map((p)=>Card(child: ListTile(title: Text(p['reason'] ?? ''), subtitle: Text('خصم ${p['penalty_percent']}% من ${p['starts_at']} إلى ${p['ends_at']} - الحالة ${p['status']}')))),
    ])),
  );
}
