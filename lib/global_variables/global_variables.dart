import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_clone_app/models/direction_details_model.dart';
import 'package:uber_clone_app/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
UserCredential? activeUser;
UserModel? userModel;
List? activeDriversList = [];
DirectionDetailsModel? tripDirectionDetails;
String? selectedDriverId;
String cloudeMessageServerToken =
    'key=AAAAxWSdAWA:APA91bFxrO6xwms8uvoVbyEyKhRm5yxrtCUxpi4yza9GegbU9gqBcm-xf1I-wxIjR2U_sLUX9sai_Vkg24QB6MCbYD5Dy92D0V48RWDpzzUbr_0XshO60zE2jbJDDwO3o8IrFHdeSzjA';
String userDropOffAddress = '';
String driverCarDetails = '';
String driverName = '';
String driverPhone = '';
String starRatingTitle = '';
double countStarRating = 0;
