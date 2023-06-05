// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_app/assistants/geofire_assistant.dart';
import 'package:uber_clone_app/global_variables/global_variables.dart';
import 'package:uber_clone_app/models/active_drivers_model.dart';
import 'package:uber_clone_app/providers/app_info_provider.dart';
import 'package:uber_clone_app/screens/active_drivers_screen.dart';
import 'package:uber_clone_app/screens/rating_screen.dart';
import 'package:uber_clone_app/screens/search_place_screen.dart';
import 'package:uber_clone_app/widgets/my_drawer.dart';
import 'package:uber_clone_app/widgets/pay_fare_dialog.dart';
import 'package:uber_clone_app/widgets/progress_dialog.dart';

import '../assistants/assistant_methods.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationHeight = 300;
  double driverResponseHeight = 0;
  double assignedDriverInfoHeight = 0;
  double mapBottomPadding = 0;
  bool openNavigationDrawer = true;

  String driverStatus = 'On the way';
  String rideRequestStatus = '';
  bool requestPositionInfo = true;
  StreamSubscription<DatabaseEvent>? tripRideRequestSubscription;

  Position? userCurrentPosition;
  LocationPermission? _locationPermission;

  allowLocationPermission() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  userLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userCurrentPosition = currentPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        cameraPosition,
      ),
    );

    await AssistantMethods.reverseGeocoding(userCurrentPosition!, context);

    initializeGeoFire();

    AssistantMethods.readTripKeys(context);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void mapDarkTheme() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  @override
  void initState() {
    super.initState();
    allowLocationPermission();
  }

  List<LatLng> polyLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  Future<void> drawPolyLines() async {
    var originData =
        Provider.of<AppInfoProvider>(context, listen: false).userPickUpLocation;
    var destinationData = Provider.of<AppInfoProvider>(context, listen: false)
        .userDropOffLocation;

    var originDirection =
        LatLng(originData!.locationLatitude!, originData.locationLongitude!);
    var destinationDirection = LatLng(
        destinationData!.locationLatitude!, destinationData.locationLongitude!);

    showDialog(
      context: context,
      builder: (context) {
        return const ProgressDialog(
          message: 'Please wait...',
        );
      },
    );

    var directionDetails = await AssistantMethods.getDirectionDetail(
        originDirection, destinationDirection);

    setState(() {
      tripDirectionDetails = directionDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLineList =
        polylinePoints.decodePolyline(directionDetails!.points!);

    polyLineCoordinatesList.clear();

    if (decodedPolyLineList.isNotEmpty) {
      for (PointLatLng pointLatLng in decodedPolyLineList) {
        polyLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyLineId'),
        points: polyLineCoordinatesList,
        color: Colors.blue,
        width: 2,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (originDirection.latitude > destinationDirection.latitude &&
        originDirection.longitude > destinationDirection.longitude) {
      latLngBounds = LatLngBounds(
        southwest: destinationDirection,
        northeast: originDirection,
      );
    } else if (originDirection.longitude > destinationDirection.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          originDirection.latitude,
          destinationDirection.longitude,
        ),
        northeast: LatLng(
          destinationDirection.latitude,
          originDirection.longitude,
        ),
      );
    } else if (originDirection.latitude > destinationDirection.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          destinationDirection.latitude,
          originDirection.longitude,
        ),
        northeast: LatLng(
          originDirection.latitude,
          destinationDirection.longitude,
        ),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: originDirection,
        northeast: destinationDirection,
      );
    }

    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 65),
    );

    Marker originMarker = Marker(
      markerId: const MarkerId('originId'),
      infoWindow: InfoWindow(title: originData.locationName, snippet: 'Origin'),
      position: originDirection,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationId'),
      infoWindow: InfoWindow(
          title: destinationData.locationName, snippet: 'Destination'),
      position: destinationDirection,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId('originId'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originDirection,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationId'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationDirection,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  bool activeDriversNearby = false;

  initializeGeoFire() {
    Geofire.initialize('activeDrivers');

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveDriversModel activeDriversModel = ActiveDriversModel();

            activeDriversModel.driverId = map['key'];
            activeDriversModel.driverLatitude = map['latitude'];
            activeDriversModel.driverLongitude = map['longitude'];

            GeoFireAssistant.activeDriversList.add(activeDriversModel);

            if (activeDriversNearby == true) {
              activeDriversPosition();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeActiveDriver(map['key']);
            activeDriversPosition();

            break;

          case Geofire.onKeyMoved:
            ActiveDriversModel activeDriversModel = ActiveDriversModel();

            activeDriversModel.driverId = map['key'];
            activeDriversModel.driverLatitude = map['latitude'];
            activeDriversModel.driverLongitude = map['longitude'];

            GeoFireAssistant.updateActiveDriver(activeDriversModel);
            activeDriversPosition();

            break;

          case Geofire.onGeoQueryReady:
            activeDriversNearby = true;
            activeDriversPosition();

            break;
        }
      }

      setState(() {});
    });
  }

  BitmapDescriptor? activeDriverCustomMarker;

  void activeDriversCustomMarker() async {
    if (activeDriverCustomMarker == null) {
      ImageConfiguration imageConfiguration =
          const ImageConfiguration(size: Size(2, 2));

      var newMarker = await BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'assets/images/car.png');

      activeDriverCustomMarker = newMarker;
    }
  }

  void activeDriversPosition() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarker = {};

      for (ActiveDriversModel activeDrivers
          in GeoFireAssistant.activeDriversList) {
        LatLng latLng = LatLng(
            activeDrivers.driverLatitude!, activeDrivers.driverLongitude!);

        Marker marker = Marker(
          markerId: MarkerId('driver ${activeDrivers.driverId!}'),
          position: latLng,
          icon: activeDriverCustomMarker!,
          rotation: 360,
        );

        driversMarker.add(marker);
      }
      setState(() {
        markerSet = driversMarker;
      });
    });
  }

  DatabaseReference? rideRef;

  void saveRideRequest() {
    rideRef = FirebaseDatabase.instance.ref().child('All Ride Requests').push();

    var originLocation =
        Provider.of<AppInfoProvider>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfoProvider>(context, listen: false)
            .userDropOffLocation;

    Map originLocationMap = {
      'latitude': originLocation!.locationLatitude,
      'longitude': originLocation.locationLongitude,
    };

    Map destinationLocationMap = {
      'latitude': destinationLocation!.locationLatitude,
      'longitude': destinationLocation.locationLongitude,
    };

    Map userInfoMap = {
      'origin': originLocationMap,
      'destination': destinationLocationMap,
      'time': DateTime.now().toString(),
      'userName': userModel!.name,
      'userPhone': userModel!.phone,
      'originAddress': originLocation.locationName,
      'destinationAddress': destinationLocation.locationName,
      'driverId': 'waiting',
    };

    rideRef!.set(userInfoMap);

    tripRideRequestSubscription = rideRef!.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if ((event.snapshot.value as Map)['car_details'] != null) {
        setState(() {
          driverCarDetails = (event.snapshot.value as Map)['car_details'];
        });
      }
      if ((event.snapshot.value as Map)['driverName'] != null) {
        setState(() {
          driverName = (event.snapshot.value as Map)['driverName'];
        });
      }
      if ((event.snapshot.value as Map)['driverPhone'] != null) {
        setState(() {
          driverPhone = (event.snapshot.value as Map)['driverPhone'];
        });
      }

      if ((event.snapshot.value as Map)['status'] != null) {
        rideRequestStatus = (event.snapshot.value as Map)['status'];
      }

      if ((event.snapshot.value as Map)['driverLocation'] != null) {
        double driverPositionLat = double.parse(
            (event.snapshot.value as Map)['driverLocation']['latitude']
                .toString());
        double driverPositionLng = double.parse(
            (event.snapshot.value as Map)['driverLocation']['longitude']
                .toString());

        LatLng driverPositionLatLng =
            LatLng(driverPositionLat, driverPositionLng);

        if (rideRequestStatus == 'accepted') {
          updateDriverArrivalTime(driverPositionLatLng);
        }
        if (rideRequestStatus == 'arrived') {
          setState(() {
            driverStatus = 'Driver has Arrived';
          });
        }
        if (rideRequestStatus == 'onTrip') {
          updateDestinationArrivalTime(driverPositionLatLng);
        }
        if (rideRequestStatus == 'ended') {
          if ((event.snapshot.value as Map)['fareAmount'] != null) {
            double fareAmount = double.parse(
                (event.snapshot.value as Map)['fareAmount'].toString());

            var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PayFareDialog(
                fareAmount: fareAmount,
              ),
            );
            if (response == 'cashPaid') {
              if ((event.snapshot.value as Map)['driverId'] != null) {
                String assignedDriverId =
                    (event.snapshot.value as Map)['driverId'];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RatingScreen(assignedDriverId: assignedDriverId),
                  ),
                );
                rideRef!.onDisconnect();
                tripRideRequestSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    activeNearestDriversList();
  }

  updateDestinationArrivalTime(driverPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfoProvider>(context, listen: false)
          .userDropOffLocation;

      LatLng userDropOffPosition = LatLng(dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!);
      var directionDetailsInfo = await AssistantMethods.getDirectionDetail(
          driverPositionLatLng, userDropOffPosition);

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverStatus =
            'Towards Destination: ${directionDetailsInfo.durationText}';
      });

      requestPositionInfo = true;
    }
  }

  updateDriverArrivalTime(driverPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickupPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo = await AssistantMethods.getDirectionDetail(
          driverPositionLatLng, userPickupPosition);

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverStatus = 'On the way: ${directionDetailsInfo.durationText}';
      });

      requestPositionInfo = true;
    }
  }

  void activeNearestDriversList() async {
    List availableDriversList = GeoFireAssistant.activeDriversList;

    if (availableDriversList.isEmpty) {
      rideRef!.remove();

      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circleSet.clear();
        polyLineCoordinatesList.clear();
      });

      Fluttertoast.showToast(
        msg: 'No drivers currently available, Please try again after sometime',
      );

      SystemNavigator.pop();

      return;
    }

    await retrieveActiveDriversInfo(availableDriversList);

    var response = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveDriversScreen(rideRef: rideRef),
      ),
    );

    if (response == 'selectedDriver') {
      FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(selectedDriverId!)
          .once()
          .then((snapshot) {
        if (snapshot.snapshot.value != null) {
          sendNotificationToDriver(selectedDriverId!);

          showDriverResponse();

          FirebaseDatabase.instance
              .ref()
              .child('drivers')
              .child(selectedDriverId!)
              .child('driverStatus')
              .onValue
              .listen((event) {
            if (event.snapshot.value == 'idle') {
              Fluttertoast.showToast(
                  msg:
                      'The driver has cancelled your request. Please choose another driver');
              Future.delayed(
                const Duration(seconds: 3),
                () {
                  Fluttertoast.showToast(msg: 'Restarting your app');
                  SystemNavigator.pop();
                },
              );
            }

            if (event.snapshot.value == 'accepted') {
              showAssignedDriverInfo();
            }
          });
        } else {
          Fluttertoast.showToast(msg: 'This Driver not exist.');
        }
      });
    }
  }

  showAssignedDriverInfo() {
    setState(() {
      driverResponseHeight = 0;
      searchLocationHeight = 0;
      assignedDriverInfoHeight = 300;
    });
  }

  showDriverResponse() {
    setState(() {
      searchLocationHeight = 0;
      driverResponseHeight = 300;
    });
  }

  sendNotificationToDriver(String selectedDriverId) {
    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(selectedDriverId)
        .child('driverStatus')
        .set(rideRef!.key);

    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(selectedDriverId)
        .child('fcmToken')
        .once()
        .then((token) {
      if (token.snapshot.value != null) {
        String fcmToken = token.snapshot.value.toString();

        AssistantMethods.sendNotificationToDriver(
          fcmToken,
          rideRef!.key.toString(),
        );

        Fluttertoast.showToast(msg: 'Notification sent Successfully');
      } else {
        Fluttertoast.showToast(msg: 'Please choose another driver');
        return;
      }
    });
  }

  retrieveActiveDriversInfo(List availableDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('drivers');

    for (int i = 0; i < availableDriversList.length; i++) {
      await ref
          .child(availableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;

        activeDriversList!.add(driverKeyInfo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locationData =
        Provider.of<AppInfoProvider>(context, listen: false).userPickUpLocation;
    var dropOffData = Provider.of<AppInfoProvider>(context, listen: false)
        .userDropOffLocation;

    activeDriversCustomMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer: MyDrawer(
        name: userModel == null ? 'Name' : userModel!.name,
        email: userModel == null ? 'Email' : userModel!.email,
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding, top: 20),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;

              //for Dark Theme
              mapDarkTheme();
              userLocation();
              setState(() {
                mapBottomPadding = 320;
              });
            },
          ),
          Positioned(
            top: 36,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(microseconds: 120),
              child: Container(
                height: searchLocationHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                locationData != null
                                    ? '${locationData.locationName!.substring(0, 29)}...'
                                    : 'Pick Up Location',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          var responseSearchScreen = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchPlaceScreen(),
                            ),
                          );
                          if (responseSearchScreen == 'obtainedDropOff') {
                            setState(() {
                              openNavigationDrawer = false;
                            });

                            await drawPolyLines();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'To',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  dropOffData != null
                                      ? '${dropOffData.locationName}'
                                      : 'Where To?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (dropOffData == null) {
                            Fluttertoast.showToast(
                                msg: 'Please select Drop off location first');
                          } else {
                            saveRideRequest();
                          }
                        },
                        child: const Text('Request a Ride'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: driverResponseHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting for driver response',
                        duration: const Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ScaleAnimatedText(
                        'Please wait...',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 30.0,
                          fontFamily: 'Canterbury',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                height: assignedDriverInfoHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          driverStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        driverCarDetails,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        driverName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone_android,
                            color: Colors.blue,
                            size: 16,
                          ),
                          label: const Text(
                            'Call Driver',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
