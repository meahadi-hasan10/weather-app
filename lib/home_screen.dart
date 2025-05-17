import 'package:flutter/material.dart';
import 'package:WeatherApp/models/weather_model.dart';
import 'package:WeatherApp/services/weather_services.dart';
import 'package:WeatherApp/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _weatherServices = WeatherServices();
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Weather? _weather;
  String? _error;

  void _getWeather() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _weather = null;
    });

    try {
      final weather = await _weatherServices.fetchWeather(_controller.text.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Search Input
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'City Name',
                  hintText: 'e.g. Dhaka, New York',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _getWeather,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city name';
                  }
                  if (!RegExp(r'^[a-zA-Z\s,]+$').hasMatch(value)) {
                    return 'Only letters and commas allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud),
                  label: const Text('Get Weather'),
                  onPressed: _getWeather,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              
              // Error Display
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Try Again'),
                        onPressed: _getWeather,
                      ),
                    ],
                  ),
                ),
              
              // Empty State
              if (_weather == null && !_isLoading && _error == null)
                Column(
                  children: [
                    const Icon(Icons.search, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      'Search for a city to see weather',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Try: "Dhaka,BD" or "New York"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              
              // Weather Display
              if (_weather != null)
                WeatherCard(weather: _weather!),
            ],
          ),
        ),
      ),
    );
  }
}