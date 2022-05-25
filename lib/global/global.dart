import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';

final FirebaseAuth fAuth=FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AssetsAudioPlayer assetsAudioPlayer=AssetsAudioPlayer();
Position? driverCurrentPosition;
DriverData onlineDriverData=DriverData();
String? driverVehicleType="";
String titleStarsRating="Good";
bool isDriverActive=false;
String statusText="Now Offline";
Color buttonColor=Colors.grey;