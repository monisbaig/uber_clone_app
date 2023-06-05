import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_clone_app/assistants/request_assistant.dart';
import 'package:uber_clone_app/global_variables/global_variables.dart';
import 'package:uber_clone_app/global_variables/map_keys.dart';
import 'package:uber_clone_app/models/direction_details_model.dart';
import 'package:uber_clone_app/models/directions_model.dart';
import 'package:uber_clone_app/models/history_model.dart';
import 'package:uber_clone_app/models/user_model.dart';
import 'package:uber_clone_app/providers/app_info_provider.dart';

class AssistantMethods {
  static Future<String> reverseGeocoding(Position position, context) async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    String readableAddress = '';
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != 'Error Occurred') {
      readableAddress = requestResponse['results'][0]['formatted_address'];

      DirectionsModel userPickUpAddress = DirectionsModel();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = readableAddress;

      Provider.of<AppInfoProvider>(context, listen: false)
          .updatePickUpLocation(userPickUpAddress);
    }
    return readableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(firebaseAuth.currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModel = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<DirectionDetailsModel?> getDirectionDetail(
      LatLng origin, LatLng destination) async {
    String directionUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey';

    var directionResponse = await RequestAssistant.receiveRequest(directionUrl);

    if (directionResponse == 'Error Occurred') {
      return null;
    }

    DirectionDetailsModel directionDetailsModel = DirectionDetailsModel();

    directionDetailsModel.points =
        directionResponse['routes'][0]['overview_polyline']['points'];

    directionDetailsModel.distanceText =
        directionResponse['routes'][0]['legs'][0]['distance']['text'];

    directionDetailsModel.distanceValue =
        directionResponse['routes'][0]['legs'][0]['distance']['value'];

    directionDetailsModel.durationText =
        directionResponse['routes'][0]['legs'][0]['duration']['text'];

    directionDetailsModel.durationValue =
        directionResponse['routes'][0]['legs'][0]['duration']['value'];

    return directionDetailsModel;
  }

  static double calculateTripFee(DirectionDetailsModel directionDetailsModel) {
    double amountPerMin = (directionDetailsModel.durationValue! / 60) * 0.1;
    double amountPerKM = (directionDetailsModel.durationValue! / 1000) * 0.1;

    double totalAmount = amountPerMin + amountPerKM;

    double totalInPKR = totalAmount * 120;

    return double.parse(totalInPKR.toStringAsFixed(0));
  }

  static sendNotificationToDriver(String fcmToken, String rideRequestId) {
    String destinationAddress = userDropOffAddress;

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': cloudeMessageServerToken,
    };

    Map notificationBody = {
      "body": "Destination Address: \n$destinationAddress",
      "title": "Trip Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": rideRequestId
    };

    Map notificationFormat = {
      "notification": notificationBody,
      "priority": "high",
      "data": dataMap,
      "to": fcmToken
    };

    var response = http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: header,
      body: jsonEncode(notificationFormat),
    );
  }

  static void readTripKeys(context) {
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .orderByChild('userName')
        .equalTo(userModel!.name)
        .once()
        .then((userKeyData) {
      if (userKeyData.snapshot.value != null) {
        Map tripKeys = userKeyData.snapshot.value as Map;

        int tripCounter = tripKeys.length;

        Provider.of<AppInfoProvider>(context, listen: false)
            .updateTripCounter(tripCounter);

        List<String> tripKeysList = [];

        tripKeys.forEach((key, value) {
          tripKeysList.add(key);
        });

        Provider.of<AppInfoProvider>(context, listen: false)
            .updateTripKeys(tripKeysList);

        readTripHistoryInfo(context);
      }
    });
  }

  static void readTripHistoryInfo(context) {
    var allTripKeys = Provider.of<AppInfoProvider>(context, listen: false)
        .tripHistoryKeysList;

    for (String getKey in allTripKeys) {
      FirebaseDatabase.instance
          .ref()
          .child('All Ride Requests')
          .child(getKey)
          .once()
          .then((key) {
        var tripHistory = HistoryModel.fromSnapshot(key.snapshot);

        if ((key.snapshot.value as Map)['status'] == 'ended') {
          Provider.of<AppInfoProvider>(context, listen: false)
              .updateTripHistoryInfo(tripHistory);
        }
      });
    }
  }
}
