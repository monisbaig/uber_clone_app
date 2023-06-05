import 'package:flutter/material.dart';
import 'package:uber_clone_app/assistants/request_assistant.dart';
import 'package:uber_clone_app/global_variables/map_keys.dart';
import 'package:uber_clone_app/widgets/place_prediction_tile.dart';

import '../models/predictions_model.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  List<PredictionsModel> predictionList = [];

  void searchPlaceAutoComplete(String inputText) async {
    if (inputText.length > 1) {
      String urlPlaceAutoComplete =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:PK';

      var responseAutoComplete =
          await RequestAssistant.receiveRequest(urlPlaceAutoComplete);
      if (responseAutoComplete == 'Error Occurred') {
        return;
      }
      if (responseAutoComplete['status'] == 'OK') {
        var placePredictions = responseAutoComplete['predictions'];
        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictionsModel.fromJson(jsonData))
            .toList();

        setState(() {
          predictionList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 155,
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  const SizedBox(height: 38),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Search & Set DropOff Location',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            searchPlaceAutoComplete(value);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search Here...',
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              top: 8,
                              left: 11,
                              bottom: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          predictionList.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    itemCount: predictionList.length,
                    separatorBuilder: (context, index) {
                      return const Padding(padding: EdgeInsets.all(4));
                    },
                    itemBuilder: (context, index) {
                      return PlacePredictionTile(
                        predictedPlaces: predictionList[index],
                      );
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
