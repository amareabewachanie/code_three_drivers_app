
import 'package:flutter/cupertino.dart';

import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AppInfo extends ChangeNotifier{
Directions? userPickUpLocation, userDropOffLocation;
Locale _currentLocal= Locale("en");
Locale get currentLocal => _currentLocal;
List<String> historyTripKeysList=[];
List<TripsHistoryModel> listOfTripHistories=[];
String driverTotalEarnings="0";
String driverAverageRatings="0";

void updatePickUpLocationAddress(Directions userPickupAddress){
  userPickUpLocation=userPickupAddress;
  notifyListeners();
}
void updateDropOffLocationAddress(Directions userDropOffAddress){
  userDropOffLocation=userDropOffAddress;
  notifyListeners();
}
 changeLanguagePreference(String _locale){
  _currentLocal=Locale(_locale);
  notifyListeners();
}
 updateAllTripKeys(List<String> tripKeysList){
historyTripKeysList=tripKeysList;
notifyListeners();
}
 updateAllTripHistoryData(TripsHistoryModel tripHistories){
   listOfTripHistories.add(tripHistories);
   notifyListeners();
}
updateDriverTotalEarnings(String driverEarnings){
 driverTotalEarnings=driverEarnings;
 notifyListeners();
}
updateDriverAvaregeRatingss(String averageRatings){
  driverAverageRatings=averageRatings;
  notifyListeners();
}
}