import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../generated/l10n.dart';
class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestInformation;
  NotificationDialogBox({this.userRideRequestInformation});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24)
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin:const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            const SizedBox(height: 14,),
              Image.asset("images/car_logo.png",
              width: 160,),
            // Title
            const SizedBox(height: 10),
             Text(
              S.of(context).newRideRequest,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 14,),
            const Divider(
              height: 3,
              thickness: 3,
              color: Colors.green,
            ),
            // Ride Request Addresses
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Origin location with icon
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
                  // Destination location with icon
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
                ],
              ),
            ),
         const Divider(
           height: 3,
           thickness: 3,
           color: Colors.green,
         ),
         // Action Buttons
           Padding(
             padding: const EdgeInsets.all(20.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red
                    ),
                      onPressed: (){
                      assetsAudioPlayer.pause();
                      assetsAudioPlayer.stop();
                      assetsAudioPlayer=AssetsAudioPlayer();
                    // Cancel ride request
                      FirebaseDatabase.instance.ref().child("All Ride Requests")
                      .child(widget.userRideRequestInformation!.rideRequestId!)
                      .remove().then((value){
                        FirebaseDatabase.instance.ref()
                            .child("drivers")
                            .child(currentFirebaseUser!.uid)
                            .child("newRideStatus").set("idle")
                        .then((value){
                          FirebaseDatabase.instance.ref()
                              .child("drivers").child(currentFirebaseUser!.uid)
                              .child("tripsHistory").child(widget.userRideRequestInformation!.rideRequestId!).remove();
                        }).then((value){
                          Fluttertoast.showToast(msg:  S.of(context).rideRequestCancelledSuccessfully+
                              "!");
                        });
                      });
                      Future.delayed(const Duration(milliseconds: 3000),(){
                        SystemNavigator.pop();
                      });
                  },
                      child: Text(S.of(context).cancel.toUpperCase(),style: const TextStyle(
                        fontSize: 14,

                      ),)),
                  const SizedBox(width: 25.0,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green
                      ),
                      onPressed: (){
                        assetsAudioPlayer.pause();
                        assetsAudioPlayer.stop();
                        assetsAudioPlayer=AssetsAudioPlayer();
                    // Accept the  ride request
                    acceptRideRequest(context);
                  },
                      child: Text(S.of(context).accept.toUpperCase(),style: const TextStyle(
                        fontSize: 14,

                      ),))
                ],
             ),
           )
          ],
        ),
      ),
    );
  }
  acceptRideRequest(BuildContext context){
    String getRideRequestId="";
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus").once().then((snap){
          if(snap.snapshot.value !=null){
            getRideRequestId=snap.snapshot.value.toString();
          }else{
            Fluttertoast.showToast(msg: S.of(context).theRideHasBeenCanceled);
          }
          if(getRideRequestId == widget.userRideRequestInformation!.rideRequestId) {
            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(currentFirebaseUser!.uid)
                .child("newRideStatus").set("accepted");
            AssistantMethods.pauseLiveLocationUpdates();
            // Send rider to new ride screen
            Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(userRideRequestInformation:widget.userRideRequestInformation)));
          }else{
            Fluttertoast.showToast(msg: S.of(context).theRideHasBeenCanceled);
          }
    });
  }
}
