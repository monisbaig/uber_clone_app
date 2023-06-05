import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uber_clone_app/global_variables/global_variables.dart';

class RatingScreen extends StatefulWidget {
  final String assignedDriverId;

  const RatingScreen({super.key, required this.assignedDriverId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          margin: const EdgeInsets.all(12),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Rate Trip Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                thickness: 4,
                height: 4,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              SmoothStarRating(
                rating: countStarRating,
                allowHalfRating: false,
                starCount: 5,
                size: 40,
                color: Colors.orangeAccent,
                onRatingChanged: (rating) {
                  countStarRating = rating;
                  if (countStarRating == 1) {
                    setState(() {
                      starRatingTitle = 'Very Bad';
                    });
                  }
                  if (countStarRating == 2) {
                    setState(() {
                      starRatingTitle = 'Bad';
                    });
                  }
                  if (countStarRating == 3) {
                    setState(() {
                      starRatingTitle = 'Good';
                    });
                  }
                  if (countStarRating == 4) {
                    setState(() {
                      starRatingTitle = 'Very Good';
                    });
                  }
                  if (countStarRating == 5) {
                    setState(() {
                      starRatingTitle = 'Excellent';
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                starRatingTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  DatabaseReference ref = FirebaseDatabase.instance
                      .ref()
                      .child('drivers')
                      .child(widget.assignedDriverId)
                      .child('ratings');

                  ref.once().then((ratingData) {
                    if (ratingData.snapshot.value == null) {
                      ref.set(countStarRating.toString());
                      SystemNavigator.pop();
                    } else {
                      double pastRatings =
                          double.parse(ratingData.snapshot.value.toString());
                      double ratingsAverage =
                          (pastRatings + countStarRating) / 2;
                      ref.set(ratingsAverage.toString());
                      SystemNavigator.pop();
                    }
                    Fluttertoast.showToast(msg: 'Restarting your app');
                  });
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
