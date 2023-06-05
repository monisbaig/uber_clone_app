import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uber_clone_app/global_variables/global_variables.dart';

import '../assistants/assistant_methods.dart';

class ActiveDriversScreen extends StatefulWidget {
  final DatabaseReference? rideRef;

  const ActiveDriversScreen({super.key, this.rideRef});

  @override
  State<ActiveDriversScreen> createState() => _ActiveDriversScreenState();
}

class _ActiveDriversScreenState extends State<ActiveDriversScreen> {
  String totalFee = '';

  typeFeeAmount(int index) {
    var totalFeeByType =
        AssistantMethods.calculateTripFee(tripDirectionDetails!);
    var type = activeDriversList![index]['car_details']['car_type'];

    if (tripDirectionDetails != null) {
      if (type == 'bike') {
        totalFee = (totalFeeByType / 2).toStringAsFixed(0);
      }
      if (type == 'uber-x') {
        totalFee = (totalFeeByType * 2).toStringAsFixed(0);
      }
      if (type == 'uber-go') {
        totalFee = totalFeeByType.toString();
      }
    }
    return totalFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearest Online Drivers',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            widget.rideRef!.remove();

            Fluttertoast.showToast(
              msg: 'Your cancelled the ride',
            );

            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: activeDriversList!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDriverId = activeDriversList![index]['id'].toString();
              });
              Navigator.pop(context, 'selectedDriver');
            },
            child: Card(
              color: Colors.blue,
              elevation: 3,
              shadowColor: Colors.white,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Image.asset(
                  'assets/images/${activeDriversList![index]['car_details']['car_type']}.png',
                  width: 70,
                ),
                title: Column(
                  children: [
                    Text(
                      activeDriversList![index]['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      activeDriversList![index]['car_details']['car_model'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SmoothStarRating(
                      rating: activeDriversList![index]['ratings'] == null
                          ? 0.0
                          : double.parse(activeDriversList![index]['ratings']),
                      allowHalfRating: true,
                      color: Colors.yellow,
                      borderColor: Colors.yellow,
                      starCount: 5,
                      size: 20,
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs ${typeFeeAmount(index)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      tripDirectionDetails!.durationText ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        tripDirectionDetails!.distanceText ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
