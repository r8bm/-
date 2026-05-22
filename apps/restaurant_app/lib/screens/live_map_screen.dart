import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

class LiveMapScreen extends StatefulWidget{final ApiService api; const LiveMapScreen({super.key,required this.api}); @override State<LiveMapScreen> createState()=>_LiveMapScreenState();}
class _LiveMapScreenState extends State<LiveMapScreen>{List<DriverRow>drivers=[];Map<String,dynamic>?settings;bool loading=true;@override void initState(){super.initState();load();}Future<void>load()async{final d=await widget.api.liveMap();setState((){settings=d['settings'];drivers=(d['drivers'] as List).map((e)=>DriverRow.fromJson(Map<String,dynamic>.from(e))).toList();loading=false;});}
 @override Widget build(BuildContext context){final lat=(settings?['restaurant_lat'] as num?)?.toDouble()??31.04219;final lng=(settings?['restaurant_lng'] as num?)?.toDouble()??46.25726;final markers=<Marker>{Marker(markerId:const MarkerId('restaurant'),position:LatLng(lat,lng),infoWindow:const InfoWindow(title:'المطعم')),...drivers.where((d)=>d.lat!=null&&d.lng!=null).map((d)=>Marker(markerId:MarkerId('driver_${d.id}'),position:LatLng(d.lat!,d.lng!),infoWindow:InfoWindow(title:d.name,snippet:d.status)))};return Scaffold(appBar:AppBar(title:const Text('الخريطة المباشرة'),actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh))]),body:loading?const Center(child:CircularProgressIndicator()):Column(children:[Expanded(child:GoogleMap(initialCameraPosition:CameraPosition(target:LatLng(lat,lng),zoom:13),markers:markers)),Expanded(child:ListView(children:drivers.map((d)=>ListTile(title:Text(d.name),subtitle:Text('${d.status} | ${d.lat}, ${d.lng}'))).toList()))]));}
}
