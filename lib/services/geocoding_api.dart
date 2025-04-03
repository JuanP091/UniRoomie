import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingApi {
  final apiKey = 'AIzaSyBxbabTned6lo_eQj1vu917c5R5t9X_zQ0';
  
  Future<Map<String, String>> getCityAndState(
    double latitude, double longitude) async {
  final url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(jsonEncode(data));
    final results = data['results'];

    if (results != null && results.isNotEmpty) {
      String? city;
      String? state;

      for (var result in results) {
        final components = result['address_components'] as List<dynamic>;
        for (var component in components) {
          final types = List<String>.from(component['types']);
          if (types.contains('locality')) {
            city = component['long_name'];
          }
          if (city == null && types.contains('sublocality')) {
            city = component['long_name'];
          }
          if (types.contains('administrative_area_level_1')) {
            state = component['short_name'];
          }
        }
      }

      if (city != null && state != null) {
        return {'city': city, 'state': state};
      }
    }

    print('⚠️ Could not extract city or state');
    throw Exception('Cannot extract city and state from results');
  } else {
    print('❌ Failed response: ${response.body}');
    throw Exception('Failed to fetch geocode data: ${response.statusCode} $apiKey');
  }
}
}
