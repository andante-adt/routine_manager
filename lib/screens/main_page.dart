// 📄 main_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import '../providers/event_provider.dart';
import '../models/event.dart';
import 'time_table_screen.dart';
import 'weather_forecast_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  String? _selectedLocation;
  String _temperature = '';
  String _condition = '';
  String _icon = '';
  bool _isLoadingWeather = false;
  bool _hasCheckedLocation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedLocation) {
      _hasCheckedLocation = true;
      _getCurrentLocationAndFetchWeather();
    }
  }

  Future<void> _getCurrentLocationAndFetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url = Uri.parse(
        'http://api.weatherapi.com/v1/search.json?key=49d3d49cf23c4cef8db101513253003&q=${position.latitude},${position.longitude}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _selectedLocation = data[0]['name'];
          });
          _fetchWeather(_selectedLocation!);
        }
      }
    } catch (_) {
      // Ignore errors silently
    }
  }

  Future<void> _fetchWeather(String location) async {
    setState(() => _isLoadingWeather = true);
    final url = Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=49d3d49cf23c4cef8db101513253003&q=$location',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = '${data['current']['temp_c']}°C';
          _condition = data['current']['condition']['text'];
          _icon = 'https:${data['current']['condition']['icon']}';
        });
      } else {
        setState(() {
          _temperature = 'N/A';
          _condition = 'Not found';
        });
      }
    } catch (_) {
      setState(() {
        _temperature = 'N/A';
        _condition = 'Error';
      });
    } finally {
      setState(() => _isLoadingWeather = false);
    }
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
          _searchResults = data.map((item) => item['name'] as String).toList();
        });
      } else {
        setState(() => _searchResults = []);
      }
    } catch (_) {
      setState(() => _searchResults = []);
    }
  }

  String _getDayLabel(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  Color getDayColor(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return const Color.fromARGB(255, 255, 210, 59);
      case DateTime.tuesday:
        return Colors.purple;
      case DateTime.wednesday:
        return Colors.green;
      case DateTime.thursday:
        return Colors.orange;
      case DateTime.friday:
        return Colors.blue;
      case DateTime.saturday:
        return Colors.deepPurple;
      case DateTime.sunday:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final today = DateTime.now();
        final eventsToday = eventProvider.events.where((event) {
          return event.startTime.year == today.year &&
              event.startTime.month == today.month &&
              event.startTime.day == today.day;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Routine Manager', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: const Color(0xFF030052),
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimeTableScreen()),
                  );
                },
              )
            ],
          ),
          backgroundColor: const Color(0xFF384584),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔍 Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search for location',
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

              if (_searchResults.isNotEmpty)
                ..._searchResults.map((location) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    margin: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: ListTile(
                        title: Text(location),
                        onTap: () {
                          _selectedLocation = location;
                          _searchController.text = location;
                          _searchResults.clear();
                          _fetchWeather(location);
                        },
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // 🌤 Weather Info
              if (_selectedLocation != null && _selectedLocation!.isNotEmpty)
                Center(
                  child: _isLoadingWeather
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WeatherForecastScreen(location: _selectedLocation!),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _selectedLocation!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Image.network(
                                  _icon,
                                  height: 64,
                                  width: 64,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image, color: Colors.black);
                                  },
                                ),
                                Text(
                                  _temperature,
                                  style: const TextStyle(fontSize: 32, color: Colors.black),
                                ),
                                Text(
                                  _condition,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

              const SizedBox(height: 32),

              // 📅 Day Label
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF030052),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 108),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getDayLabel(today),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 📋 Event List
              Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: eventsToday.isEmpty
                    ? const Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No events for today.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : Column(
                        children: eventsToday.map((event) {
                          final time =
                              '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
                          return Card(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: getDayColor(event.startTime),
                                ),
                              ),
                              title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(event.title),
                              trailing: Switch(
                                value: event.isNotificationOn,
                                onChanged: (val) {
                                  eventProvider.toggleNotification(event.id, val);
                                },
                                activeTrackColor: Colors.blue,
                                inactiveTrackColor: const Color.fromARGB(255, 240, 240, 240),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}
