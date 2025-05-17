import 'package:WeatherApp/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:WeatherApp/constants.dart';
import 'dart:async'; 

class WeatherServices {
  Future<Weather> fetchWeather(String cityName) async {
    final url = Uri.parse(
        '${Constants.openWeatherBaseUrl}/weather?q=$cityName&appid=${Constants.openWeatherApiKey}&units=metric'
        );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['name'] == null ||
            jsonData['weather'] == null ||
            jsonData['main'] == null ||
            jsonData['sys'] == null) {
          throw Exception(Constants.invalidData);
        }

        return Weather.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception(Constants.cityNotFound);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(Constants.networkError);
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Failed to load weather data');
    }
  }
}
