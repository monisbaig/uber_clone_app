import 'package:flutter/material.dart';
import 'package:uber_clone_app/models/directions_model.dart';
import 'package:uber_clone_app/models/history_model.dart';

class AppInfoProvider extends ChangeNotifier {
  DirectionsModel? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> tripHistoryKeysList = [];
  List<HistoryModel> tripHistoryInfoList = [];

  void updatePickUpLocation(DirectionsModel userPickupAddress) {
    userPickUpLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropOffLocation(DirectionsModel userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  void updateTripCounter(int tripCounter) {
    countTotalTrips = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> tripKeysList) {
    tripHistoryKeysList = tripKeysList;
    notifyListeners();
  }

  void updateTripHistoryInfo(HistoryModel tripHistory) {
    tripHistoryInfoList.add(tripHistory);
    notifyListeners();
  }
}
