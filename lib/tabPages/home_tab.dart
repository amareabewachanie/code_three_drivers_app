import 'dart:async';

import 'package:drivers_app/pushNotifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_map.dart';
import '../global/global.dart';
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  Completer<GoogleMapController> _controllerGoogleMap=Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator=Geolocator();
  LocationPermission? _locationPermission;





  checkIfLocationPermissionIsAllowed() async{
    _locationPermission=await Geolocator.requestPermission();
    if(_locationPermission==LocationPermission.denied){
      _locationPermission=await Geolocator.requestPermission();
    }
  }
  locateDriverCurrentPosition()async{
    Position cPosition= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition=cPosition;
    LatLng latLngPosition=LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress=await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!,context);

    AssistantMethods.readDriverRatings(context);
  }
  readCurrentDriverInformation()async
  {
      currentFirebaseUser=fAuth.currentUser;
      FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
          .once().then((snap){
            if(snap.snapshot.value !=null){
             onlineDriverData.id= (snap.snapshot.value as Map)["id"];
             onlineDriverData.name= (snap.snapshot.value as Map)["name"];
             onlineDriverData.phone=(snap.snapshot.value as Map)["phone"];
             onlineDriverData.email=(snap.snapshot.value as Map)["email"];
             onlineDriverData.car_number=(snap.snapshot.value as Map)["car_details"]["car_number"];
             onlineDriverData.car_model=(snap.snapshot.value as Map)["car_details"]["car_model"];
             onlineDriverData.car_color=(snap.snapshot.value as Map)["car_details"]["car_color"];
             driverVehicleType=(snap.snapshot.value as Map)["car_details"]["type"];
            }

      });
      PushNotificationSystem pushNotificationSystem=PushNotificationSystem();
      pushNotificationSystem.initializeCloudMessaging(context);
      pushNotificationSystem.generateAndGetToken();

      AssistantMethods.readDriverEarnings(context);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionIsAllowed();
    readCurrentDriverInformation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:  [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController=controller;
              // for black theme google map
              blackThemedGoogleMap(newGoogleMapController);
              locateDriverCurrentPosition();
            },
          ),
          // UI for Offline/Online
            statusText !="Now Online"?Container(
            height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Colors.black87,

          ):
            Container(),
          // Button for Online/Offline
          Positioned(
            top: statusText !="Now Online"?
            MediaQuery.of(context).size.height*0.46
                :25.0,
              left: 0,
              right: 0,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: ()
                      {
                         if(isDriverActive !=true) // offline
                         {
                           driverIsOnlineNow();
                           updateDriverLocationAtRealTime();
                           setState(() {
                             statusText="Now Online";
                             isDriverActive=true;
                             buttonColor=Colors.green;
                           });
                           // Display toast
                           Fluttertoast.showToast(msg: "You are online now!");
                         }else{
                              driverIsOfflineNow();
                              setState(() {
                                statusText="Now Offline";
                                isDriverActive=false;
                                buttonColor=Colors.grey;
                              });
                              // Display toast
                              Fluttertoast.showToast(msg: "You are offline now!");
                         }
                  },
                     style: ElevatedButton.styleFrom(
                       primary: buttonColor,
                       padding: const EdgeInsets.symmetric(horizontal: 18),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(26)
                       )
                     ) ,
                      child:statusText !="Now Online"?
                   Text(
                     statusText,
                     style:const TextStyle(
                       fontSize: 16.0,
                       fontWeight: FontWeight.bold,
                       color: Colors.white
                     ),
                   )
                      :const Icon(Icons.phonelink_ring,
                    size: 26,

                  ))
                ],
              )
          )
        ],
      ),
    );
  }
  driverIsOnlineNow() async{
    Position pos=await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    driverCurrentPosition=pos;
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude);
    DatabaseReference ref=FirebaseDatabase.instance.ref()
        .child("drivers").child(currentFirebaseUser!.uid)
        .child("newRideStatus");
   ref.set("idle"); // searching for ride request
   ref.onValue.listen((event) {

   });
  }
  updateDriverLocationAtRealTime(){
      streamSubscriptionPosition=Geolocator.getPositionStream()
      .listen((Position position) {
          driverCurrentPosition=position;
          if(isDriverActive==true){
          Geofire.setLocation(
              currentFirebaseUser!.uid,
              driverCurrentPosition!.latitude,
              driverCurrentPosition!.longitude);
          }
          LatLng latLng=LatLng(
            driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude
          );
          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      });
  }
  driverIsOfflineNow()async{
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref=FirebaseDatabase.instance.ref()
        .child("drivers").child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref=null;
    Future.delayed(const Duration(milliseconds: 2000),(){
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}
