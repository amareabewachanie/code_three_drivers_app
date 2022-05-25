import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? userName;
  String? userPhone;
  String? rideRequestId;
  UserRideRequestInformation({
    this.userName,this.destinationAddress,this.userPhone,
    this.originAddress,this.destinationLatLng,
    this.originLatLng, this.rideRequestId,
});
}