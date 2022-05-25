import 'dart:async';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widget/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_map.dart';
import '../widget/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;
  NewTripScreen({this.userRideRequestInformation});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  Completer<GoogleMapController> _controllerGoogleMap=Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
 String? buttonTitle="Arrived";
 Color? buttonColor=Colors.redAccent;
 Set<Marker> setOfMarkers=Set<Marker>();
 Set<Circle> setOfCircles=Set<Circle>();
 Set<Polyline> setOfPolyLines=Set<Polyline>();
 List<LatLng> polyLinePositionCoOrdinates=[];
 PolylinePoints polylinePoints=PolylinePoints();
 double mapPadding=0;
 BitmapDescriptor? iconAnimatedMarker;
 var geoLocator=Geolocator();
 Position? onlineDriverCurrentPosition;
 String riderRequestStatus="accepted";
 String durationFromInitialToDestination="";
 bool isRequestDirectionDetails=false;
 // 1). When the driver accepts a request
  // Origin Address= Driver current location, Destination Address= User pickup location
  // 2). When the Driver starts the tripe
  // Origin Address = The user pickup location , Destination Address= User destination location

  Future<void> drawPolyLineFromSourceToDestination(LatLng originLatLng,LatLng destnLatLng) async{
      showDialog(context:context, builder: (BuildContext context)=>ProgressDialog(
      message: "Fetching Direction Details",
    ));
    var directionDetailsInfo= await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destnLatLng);

    Navigator.pop(context);
    PolylinePoints  pPoints=PolylinePoints();
    List<PointLatLng> decodedPPointsResultList=pPoints.decodePolyline(directionDetailsInfo!.e_points!);
    polyLinePositionCoOrdinates.clear();
    if(decodedPPointsResultList.isNotEmpty){
      decodedPPointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoOrdinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    setOfPolyLines.clear();
    setState(() {
      Polyline polyline= Polyline(
        color: Colors.purpleAccent,
        polylineId:const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoOrdinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      setOfPolyLines.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if(originLatLng.latitude>destnLatLng.latitude && originLatLng.longitude>destnLatLng.longitude){
      boundsLatLng=LatLngBounds(southwest: destnLatLng,northeast: originLatLng);
    }else if(originLatLng.longitude>destnLatLng.longitude){
      boundsLatLng=LatLngBounds(
          southwest: LatLng(originLatLng.latitude,destnLatLng.longitude),
          northeast: LatLng(destnLatLng.latitude,originLatLng.longitude));
    }
    else if(originLatLng.latitude>destnLatLng.latitude){
      boundsLatLng=LatLngBounds(
          southwest: LatLng(destnLatLng.latitude,originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude,destnLatLng.longitude));
    }else{
      boundsLatLng=LatLngBounds(
          southwest: originLatLng,
          northeast: destnLatLng);
    }
    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng,65));
    Marker originMarker=Marker(markerId: const MarkerId("originID"),
        position:destnLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
    );
    Marker destinationMarker=Marker(markerId: const MarkerId("destinationID"),
        position:destnLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
    );
    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
    Circle originCircle= Circle(circleId:const CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng
    );
    Circle destinationCircle= Circle(circleId:const CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destnLatLng
    );
    setState(() {
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }
  createAnimatedIconMarker(){
    if(iconAnimatedMarker ==null){
      ImageConfiguration imageConfiguration=createLocalImageConfiguration
        (context,
          size: const Size(2.0, 2.0)
      );
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
        iconAnimatedMarker=value;
      });
    }
  }
  getDriverLocationUpdatesAtRealTime(){
    LatLng oldLatLng= const LatLng(0, 0);
    streamSubscriptionDriverLivePosition=Geolocator.getPositionStream()
        .listen((Position position) {
      driverCurrentPosition=position;
      onlineDriverCurrentPosition=position;

      LatLng latLngLiveDriverPosition=LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude
      );
      Marker animatedMarker=Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(
          title: "This is your current position"
        )
      );
      setState(() {
        CameraPosition cameraPosition=CameraPosition(target: latLngLiveDriverPosition,zoom: 16);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setOfMarkers.removeWhere((element) => element.mapsId.value=="AnimatedMarker");
        setOfMarkers.add(animatedMarker);
      });
      oldLatLng=latLngLiveDriverPosition;
    updateDurationTimeAtRealTime();
    // Updating driver location at real time with database
    Map driverLatLngDataMap={
        "latitude":onlineDriverCurrentPosition!.latitude.toString(),
        "longitude":onlineDriverCurrentPosition!.longitude.toString()
    };
    FirebaseDatabase.instance.ref().child("All Ride Requests")
      .child(widget.userRideRequestInformation!.rideRequestId!)
        .child("driverLocation").set(driverLatLngDataMap);
    });
  }
  updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails ==false){
      isRequestDirectionDetails=true;
      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng=LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
      var destinationLatLng;
      if(riderRequestStatus=="accepted"){
        destinationLatLng=widget.userRideRequestInformation!.originLatLng;
      }else{
        destinationLatLng=widget.userRideRequestInformation!.destinationLatLng;
      }
      var directionInformation=await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
      if(directionInformation !=null){
        setState(() {
          durationFromInitialToDestination= directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails=false;
    }
  }
  @override
  Widget build(BuildContext context) {
    createAnimatedIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom:  mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: setOfPolyLines,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController=controller;
              setState(() {
                mapPadding=350;
              });
              // for black theme google map
              blackThemedGoogleMap(newTripGoogleMapController);
              var driverCurrentLatLng=LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
              var userPickUpLatLng=widget.userRideRequestInformation!.originLatLng;
              drawPolyLineFromSourceToDestination(driverCurrentLatLng, userPickUpLatLng!);
              getDriverLocationUpdatesAtRealTime();
            },
          ),
          // Ride UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(color: Colors.white30,blurRadius: 18,
                      spreadRadius: .5,offset: Offset(0.6,0.6)),

                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 20.0),
                child: Column(
                  children: [
                          // Duration
                      Text(durationFromInitialToDestination,
                      style: const TextStyle(
                          fontSize: 16,fontWeight: FontWeight.bold,
                      color: Colors.lightGreenAccent),
                    ),

                    const SizedBox(height: 18,),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8,),
                    // UserName - Icon
                    Row(
                      children: [
                        Text(widget.userRideRequestInformation!.userName!,
                        style:const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent
                        ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.phone_android,color: Colors.grey,),
                        )
                      ],
                    ),
                    const SizedBox(height: 18,),
                    // User Pickup location with icon
                    Row(
                      children: [
                        Image.asset("images/origin.png",width: 30,height: 30,),
                        const SizedBox(width: 14,),
                        Expanded(

                          child: Text(widget.userRideRequestInformation!.originAddress!,
                            style:const TextStyle(
                                fontSize: 16,
                                color: Colors.grey
                            ),),
                        )

                      ],
                    ),


                    const SizedBox(height: 20,),
                    // User dropOff location with icon
                    Row(
                      children: [
                        Image.asset("images/destination.png",width: 30,height: 30,),
                        const SizedBox(width: 14,),
                        Expanded(
                          child: Text(widget.userRideRequestInformation!.destinationAddress!,
                            style:const TextStyle(
                                fontSize: 16,
                                color: Colors.grey
                            ),),
                        )

                      ],
                    ),
                    const SizedBox(height: 24,),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor!
                      ),
                        onPressed: () async
                        {
                          // Driver has arrived at user pick up location
                        if(riderRequestStatus =="accepted")
                        {

                          riderRequestStatus="arrived";
                            FirebaseDatabase.instance.ref()
                              .child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!)
                                .child("status").set(riderRequestStatus);
                            setState(() {
                              buttonTitle="Start Trip";
                              buttonColor=Colors.lightGreen;
                            });
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext c)=>ProgressDialog(
                                message: "Loading...",
                              )
                            );
                            await drawPolyLineFromSourceToDestination(
                              widget.userRideRequestInformation!.originLatLng!,
                                widget.userRideRequestInformation!.destinationLatLng!
                            );
                            Navigator.pop(context);
                        }
                          // User has been set in drivers car
                        else if(riderRequestStatus =="arrived")
                        {

                          riderRequestStatus="ontrip";
                          FirebaseDatabase.instance.ref()
                              .child("All Ride Requests").child(widget.userRideRequestInformation!.rideRequestId!)
                              .child("status").set(riderRequestStatus);
                          setState(() {
                            buttonTitle="End trip";
                            buttonColor=Colors.redAccent;
                          });
                        }
                        // User reached to the drop off location
                        else if(riderRequestStatus=="ontrip"){
                              endTrip();
                        }

                    },
                        icon: const Icon(
                            Icons.directions_car,
                          color: Colors.white,
                          size: 25,
                        ),
                        label:  Text(buttonTitle!,
                        style:const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        )
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  endTrip() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext c)=>ProgressDialog(message: "Please wait....",));
    // Get the trip direction details
    var currentPositionLatLng=LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails= await AssistantMethods.obtainOriginToDestinationDirectionDetails(
      currentPositionLatLng,
        widget.userRideRequestInformation!.originLatLng!,
        );
    //Fare Amount
    double totalFareAmount= AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!);
    FirebaseDatabase.instance.ref().child("All Ride Requests")
    .child(widget.userRideRequestInformation!.rideRequestId!)
    .child("fareAmount").set(totalFareAmount.toString());
    FirebaseDatabase.instance.ref().child("All Ride Requests")
        .child(widget.userRideRequestInformation!.rideRequestId!)
        .child("status").set("ended");
    streamSubscriptionDriverLivePosition!.cancel();
    Navigator.pop(context);
    // Display FareAmountDialog
    showDialog(context: context,
        builder: (BuildContext c)=>FareAmounCollectionDialog(totalFareAmount:totalFareAmount));
   // Save drivers total earnings
    saveFareAmountToDriverEarnings(totalFareAmount);
  }
saveAssignedDriverDetailsToUserRideRequest(){
   DatabaseReference ref= FirebaseDatabase.instance.ref().child("All Ride Requests")
        .child(widget.userRideRequestInformation!.rideRequestId!);
   Map driverLocationDataMap={
       "latitude":driverCurrentPosition!.latitude.toString(),
        "longitude":driverCurrentPosition!.longitude.toString()
   };
   ref.child("driverLocation").set(driverLocationDataMap);
   ref.child("status").set("accepted");
   ref.child("driverId").set(onlineDriverData.id);
   ref.child("driverName").set(onlineDriverData.name);
   ref.child("driverPhone").set(onlineDriverData.phone);
   Map driverCarDetailsMap={
     "car_color":onlineDriverData.car_color!,
     "car_model":onlineDriverData.car_model!,
     "car_number":onlineDriverData.car_number!
   };
   ref.child("car_details").set(driverCarDetailsMap);
//saverRideRequestIdToDriverHistory();
}
  // saverRideRequestIdToDriverHistory(){
  //  DatabaseReference tripsHistoryReference= FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("history");
  //  tripsHistoryReference.child(widget.userRideRequestInformation!.rideRequestId!).set(true);
  // }
  saveFareAmountToDriverEarnings(double totalFareAmount){
   FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
       .child("earnings").once().then((snap) {
         if(snap.snapshot.value !=null) //earnings sub child exist
         {
           double oldEarnings=double.parse(snap.snapshot.value.toString());
           double driverTotalEarnings=oldEarnings+totalFareAmount;
           FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
               .child("earnings").set(driverTotalEarnings.toString());
         }else // earnings sub child do not exist
         {
           FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
               .child("earnings").set(totalFareAmount.toString());
         }
   });

  }
}
