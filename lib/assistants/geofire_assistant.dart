import 'package:uber_clone_app/models/active_drivers_model.dart';

class GeoFireAssistant {
  static List<ActiveDriversModel> activeDriversList = [];

  static void removeActiveDriver(String? driverId) {
    int driverIndex =
        activeDriversList.indexWhere((element) => element.driverId == driverId);
    activeDriversList.removeAt(driverIndex);
  }

  static void updateActiveDriver(ActiveDriversModel activeDriversModel) {
    int driverIndex = activeDriversList.indexWhere(
        (element) => element.driverId == activeDriversModel.driverId);

    activeDriversList[driverIndex].driverLatitude =
        activeDriversModel.driverLatitude;

    activeDriversList[driverIndex].driverLongitude =
        activeDriversModel.driverLongitude;
  }
}
