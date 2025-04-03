import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ZipcodeApiService {
    final apiKey = dotenv.env['ZIPCODE_API_KEY'];

    // Used to get city using zipcode
    Future<String> getCityByZip(String zipCode) async {

    final url = 'https://www.zipcodeapi.com/rest/$apiKey/info.json/$zipCode/degrees';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['city'];
    } else {
      print("Failed response (${response.statusCode}): ${response.body}");
      throw Exception('Failed to get city info');
    }
  }
    // Used for getting state using zipcode
    Future<String> getStateByZip(String zipCode) async {
    final url = 'https://www.zipcodeapi.com/rest/$apiKey/info.json/$zipCode/degrees'; 
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['state'];
    } else {
      print("Failed response (${response.statusCode}): ${response.body}");
      throw Exception('Failed to get state info');
    }
  }
    // Used to get diffrence in distance in miles for 2 zipcodes to determine potential roommates
    Future<double> distanceDifference(String zip1, String zip2) async {
      final url = 'https://www.zipcodeapi.com/rest/$apiKey/distance.json/$zip1/$zip2/miles';

      final response = await http.get(Uri.parse(url));

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['distance'];
      } else { 
        throw Exception('Failed to get distance');
      }
    }
}  