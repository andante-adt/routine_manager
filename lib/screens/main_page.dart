import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/event_provider.dart';
import '../models/event.dart';
import 'time_table_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  String _selectedLocation = 'Salaya';
  String _temperature = '';
  String _condition = '';
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather(_selectedLocation);
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
            title: const Text('Routine Manager'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimeTableScreen()),
                  );
                },
              )
            ],
          ),
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
                  return ListTile(
                    title: Text(location),
                    onTap: () {
                      _selectedLocation = location;
                      _searchController.text = location;
                      _searchResults.clear();
                      _fetchWeather(location);
                    },
                  );
                }),

              const SizedBox(height: 24),

              // 🌤 Weather Info
              Center(
                child: _isLoadingWeather
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          Text(
                            _selectedLocation,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _temperature,
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                            _condition,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 32),

              // 🗓️ Day Label
              Text(
                _getDayLabel(today),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 📅 Event List
              if (eventsToday.isEmpty)
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No events for today.'),
                    ],
                  ),
                )
              else
                ...eventsToday.map((event) {
                  final time = '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        time,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(event.title),
                      trailing: Switch(
                        value: event.isNotificationOn,
                        onChanged: (val) {
                          eventProvider.toggleNotification(event.id, val);
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
