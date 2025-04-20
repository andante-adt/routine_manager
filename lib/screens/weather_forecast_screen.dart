import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherForecastScreen extends StatefulWidget {
  final String? location;
  const WeatherForecastScreen({super.key, required this.location});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = '';
  List<dynamic> _hourlyData = [];
  bool _isLoading = false;
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.location ?? '';
    if (_selectedLocation.isNotEmpty) {
      _fetchHourlyForecast(_selectedLocation);
    }
  }

  Future<void> _fetchHourlyForecast(String location) async {
    setState(() {
      _isLoading = true;
      _hourlyData = [];
    });

    final url = Uri.parse(
      'http://api.weatherapi.com/v1/forecast.json?key=49d3d49cf23c4cef8db101513253003&q=$location&days=1&aqi=no&alerts=no',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedLocation = data['location']['name'];
          _hourlyData = data['forecast']['forecastday'][0]['hour'];
        });
      } else {
        _showErrorDialog('Unable to fetch weather forecast.');
      }
    } catch (_) {
      _showErrorDialog('Error occurred while fetching forecast.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _onSearch(String input) async {
    if (input.isEmpty) return;

    final url = Uri.parse(
      'http://api.weatherapi.com/v1/search.json?key=49d3d49cf23c4cef8db101513253003&q=$input',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((e) => e['name'] as String).toList();
        });
      }
    } catch (_) {
      setState(() => _searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030052),
      appBar: AppBar(
        backgroundColor: const Color(0xFF030052),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Weather Forecast', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                ],
              ),
            ),
          ),

          if (_searchResults.isNotEmpty)
            Container(
              color: Colors.white,
              child: Column(
                children: _searchResults.map((loc) {
                  return ListTile(
                    title: Text(loc),
                    onTap: () {
                      _searchController.text = loc;
                      _searchResults.clear();
                      _fetchHourlyForecast(loc);
                    },
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // 🌤 Weather Header
          Text(
            _selectedLocation.isNotEmpty ? 'Weather in $_selectedLocation' : 'No location selected',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ⏰ Hourly Forecast
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hourlyData.isEmpty
                    ? const Center(
                        child: Text(
                          'No data available.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _hourlyData.length,
                        itemBuilder: (context, index) {
                          final hour = _hourlyData[index];
                          final time = hour['time'].split(' ')[1]; // HH:MM
                          final condition = hour['condition']['text'];
                          final icon = 'https:${hour['condition']['icon']}';
                          final temp = '${hour['temp_c'].round()}°C';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Image.network(
                                icon,
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 40),
                              ),
                              title: Text(
                                time,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(condition),
                              trailing: Text(
                                temp,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
