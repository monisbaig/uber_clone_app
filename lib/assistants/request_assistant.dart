import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    final response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200) {
        String responseData = response.body;
        var decodedResponse = jsonDecode(responseData);
        return decodedResponse;
      } else {
        return 'Error Occurred, No response';
      }
    } catch (e) {
      return 'Error Occurred';
    }
  }
}
