import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_app/assistants/request_assistant.dart';
import 'package:uber_clone_app/global_variables/map_keys.dart';
import 'package:uber_clone_app/models/directions_model.dart';
import 'package:uber_clone_app/models/predictions_model.dart';
import 'package:uber_clone_app/providers/app_info_provider.dart';
import 'package:uber_clone_app/widgets/progress_dialog.dart';

import '../global_variables/global_variables.dart';

class PlacePredictionTile extends StatefulWidget {
  final PredictionsModel? predictedPlaces;

  const PlacePredictionTile({
    super.key,
    this.predictedPlaces,
  });

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  void getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const ProgressDialog(
          message: 'Location Setting up...',
        );
      },
    );
    String placeDirectionDetails =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.predictedPlaces!.placeId}&key=$mapKey';

    var directionResponse =
        await RequestAssistant.receiveRequest(placeDirectionDetails);

    Navigator.pop(context);

    if (directionResponse == 'Error Occurred') {
      return;
    }
    if (directionResponse['status'] == 'OK') {
      DirectionsModel directionsModel = DirectionsModel();
      directionsModel.locationId = placeId;
      directionsModel.locationName = directionResponse['result']['name'];
      directionsModel.locationLatitude =
          directionResponse['result']['geometry']['location']['lat'];
      directionsModel.locationLongitude =
          directionResponse['result']['geometry']['location']['lng'];

      Provider.of<AppInfoProvider>(context, listen: false)
          .updateDropOffLocation(directionsModel);

      setState(() {
        userDropOffAddress = directionsModel.locationName!;
      });

      Navigator.pop(context, 'obtainedDropOff');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.placeId, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Colors.blue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${widget.predictedPlaces!.mainText}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.predictedPlaces!.secondaryText}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
