import 'package:firebase_database/firebase_database.dart';

class HistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? carDetails;
  String? driverName;

  HistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.carDetails,
    this.driverName,
  });

  HistoryModel.fromSnapshot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)['time'];
    originAddress = (dataSnapshot.value as Map)['originAddress'];
    destinationAddress = (dataSnapshot.value as Map)['destinationAddress'];
    status = (dataSnapshot.value as Map)['status'];
    fareAmount = (dataSnapshot.value as Map)['fareAmount'];
    carDetails = (dataSnapshot.value as Map)['car_details'];
    driverName = (dataSnapshot.value as Map)['driverName'];
  }
}
