import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/pushNotifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../generated/l10n.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging=FirebaseMessaging.instance;
  Future initializeCloudMessaging(BuildContext context)async{
  // 1). Terminated
    // When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage()
    .then((RemoteMessage? remoteMessage) {
        if(remoteMessage !=null){
            // Display user information who has requested a ride
           readRideRequestInformation(remoteMessage.data["rideRequestId"],context);
        }
    });
    // 2). Foreground
    // When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage !=null) {
        readRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });
    // 3). Background
    // When the app is in the background and app opens directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage !=null) {
        readRideRequestInformation(remoteMessage.data["rideRequestId"],context);
      }
    });
  }
  readRideRequestInformation(String requestId,BuildContext context){
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests").child(requestId).once().then((snapData) {
          if(snapData.snapshot.value !=null){
            assetsAudioPlayer.open(Audio("music/music_notification.mp3"));
            assetsAudioPlayer.play();
            UserRideRequestInformation userRideRequestInformation=UserRideRequestInformation();
            userRideRequestInformation.originAddress=(snapData.snapshot.value! as Map)["originAddress"];
            userRideRequestInformation.destinationAddress=(snapData.snapshot.value! as Map)["destinationAddress"];
            userRideRequestInformation.userPhone=(snapData.snapshot.value! as Map)["userPhone"];
            userRideRequestInformation.userName=(snapData.snapshot.value! as Map)["userName"];
            userRideRequestInformation.destinationLatLng=LatLng(double.parse((snapData.snapshot.value as Map)["destination"]["Latitude"]), double.parse((snapData.snapshot.value as Map)["destination"]["Longitude"]));
            userRideRequestInformation.originLatLng=LatLng(double.parse((snapData.snapshot.value as Map)["origin"]["Latitude"]),double.parse((snapData.snapshot.value as Map)["origin"]["Longitude"]));
            userRideRequestInformation.rideRequestId=requestId;
            showDialog(context: context,
              builder: (BuildContext context)=>NotificationDialogBox(userRideRequestInformation:userRideRequestInformation),
            );
          }else{
            Fluttertoast.showToast(msg: S.of(context).theRideNotExist);
          }
    });

  }
  Future generateAndGetToken()async{
    String? registrationToken=await messaging.getToken();
    FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
        .child("token").set(registrationToken);
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}