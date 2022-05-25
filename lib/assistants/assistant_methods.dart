import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:drivers_app/config/configMaps.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/direction_details_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:drivers_app/models/user_model.dart';

import '../models/trips_history_model.dart';

class AssistantMethods{
  static Future<String> searchAddressForGeographicCoordinates(Position position,context) async{
    String apiUrl="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    String humanReadableAddress="";
    var requestResponse=await RequestAssistant.recieveRequest(apiUrl);
    if(requestResponse!="Error Occurred, Failed. No Response"){
     humanReadableAddress= requestResponse["results"][0]["formatted_address"];
     Directions userPickUpAddress=Directions();
     userPickUpAddress.locationLatitude=position.latitude;
     userPickUpAddress.locationLongitude=position.longitude;
     userPickUpAddress.locationName=humanReadableAddress;

     Provider.of<AppInfo>(context,listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
  return humanReadableAddress;
  }
  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng origin, LatLng destination)async{
  String urlOriginToDestinationDirectionDetails="https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey";
  var responseDirectionApi= await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionDetails);
  if(responseDirectionApi=="Error Occurred, Failed. No Response"){
    return null;
  }
  DirectionDetailsInfo directionDetailsInfo=DirectionDetailsInfo();
  directionDetailsInfo.e_points= responseDirectionApi["routes"][0]["overview_polyline"]["points"];
  directionDetailsInfo.distance_text=responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
  directionDetailsInfo.distance_value=responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
  directionDetailsInfo.duration_text=responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
  directionDetailsInfo.duration_value=responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
  return directionDetailsInfo;
  }
  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }
  static resumeLiveLocationUpdates(){
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }
  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double initialPrice=50;
    double timeTraveledFareAmountPerMinute=(directionDetailsInfo.duration_value! / 60)*10;
    double distanceTraveledFareAmountPerKilloMetter=(directionDetailsInfo.distance_value!/1000)*15;
    double totalFareAmount=initialPrice+timeTraveledFareAmountPerMinute+distanceTraveledFareAmountPerKilloMetter;
     if(driverVehicleType=="MiniVas"){
      var resultFareAmount=(totalFareAmount.truncate())*1.5;
      return resultFareAmount;
    }else if(driverVehicleType=="Motor Bicycle"){
      var resultFareAmount= (totalFareAmount.truncate()) / 2.0;
      return resultFareAmount;
    }
    else if(driverVehicleType=="Luxury"){
      var resultFareAmount= (totalFareAmount.truncate()) * 2.0;
      return resultFareAmount;
    }else{
       return totalFareAmount.truncate().toDouble();
     }

  }
  // Retrive the trip KEYS for the online users
  // trp key= ride request id
  static void readTripKeysForOnlineDriver(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid).once()
        .then((snap) {
      if(snap.snapshot.value !=null){
        Map tripKeys= snap.snapshot.value as Map;
        // share trip keys with providers;
        List<String> tripKeysList=[];
        tripKeys.forEach((key, value) {
          tripKeysList.add(key);
        });
        Provider.of<AppInfo>(context,listen: false).updateAllTripKeys(tripKeysList);

        //Trip keys data  - Obtain the complete information of the history
        readTripsHistoryInformation(context);
      }
    });
  }
  static void  readTripsHistoryInformation(context){
    var tripKeys=Provider.of<AppInfo>(context,listen: false).historyTripKeysList;
    for(String key in tripKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests")
          .child(key).once().then((snap) {
        var tripHistory=TripsHistoryModel.fromSnapShot(snap.snapshot);
        if((snap.snapshot.value as Map)["status"] =="ended"){
          // Update-add each trip to history data list
          Provider.of<AppInfo>(context,listen: false).updateAllTripHistoryData(tripHistory);
        }
      });
    }
  }
  // Read the total earnings of the driver
static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once().then((snap) {
          if(snap.snapshot.value !=null){
            String driverEarnings=snap.snapshot.value.toString();
            Provider.of<AppInfo>(context,listen: false).updateDriverTotalEarnings(driverEarnings);
          }
    });
    readTripKeysForOnlineDriver(context);
}

static void readDriverRatings(context){
  FirebaseDatabase.instance.ref().child("drivers")
      .child(fAuth.currentUser!.uid)
      .child("ratings")
      .once().then((snap) {
    if(snap.snapshot.value !=null){
      String driverRatings=snap.snapshot.value.toString();
      Provider.of<AppInfo>(context,listen: false).updateDriverAvaregeRatingss(driverRatings);
    }
  });
}
}