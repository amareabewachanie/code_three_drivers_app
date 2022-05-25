import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? userPhone;
  String? userName;

  TripsHistoryModel({this.userName,this.destinationAddress,
    this.originAddress,this.fareAmount,
    this.userPhone,this.status,this.time});
  TripsHistoryModel.fromSnapShot(DataSnapshot snapshot){
    time=(snapshot.value as Map)["time"];
    originAddress=(snapshot.value as Map)["originAddress"];
    destinationAddress=(snapshot.value as Map)["destinationAddress"];
    status=(snapshot.value as Map)["status"];
    fareAmount=(snapshot.value as Map)["fareAmount"];
    userName=(snapshot.value as Map)["driverName"];
    userPhone=(snapshot.value as Map)["userPhone"];
  }
}