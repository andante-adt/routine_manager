import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = '49d3d49cf23c4cef8db101513253003';
  static const _baseUrl = 'https://api.weatherapi.com/v1/current.json';

  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey&q=$city&aqi=no');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'location': data['location']['name'],
        'country': data['location']['country'],
        'temperature': data['current']['temp_c'],
        'condition': data['current']['condition']['text'],
        'iconUrl': 'https:${data['current']['condition']['icon']}',
      };
    } else {
      throw Exception('Failed to fetch weather');
    }
  }
}
