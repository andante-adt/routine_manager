import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  static const double hourHeight = 60.0;
  static const double columnWidth = 48.0;

  Color getDayColor(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return Colors.red;
      case DateTime.monday:
        return Colors.yellow;
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    // แยก event ตามวัน
    Map<int, List<Event>> weekMap = {for (var i = 0; i < 7; i++) i: []};
    for (final event in events) {
      int weekday = event.startTime.weekday % 7; // Sunday = 0
      weekMap[weekday]!.add(event);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Table', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF030052),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: columnWidth * 7 + 40,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              // Header Row
              Row(
                children: [
                  const SizedBox(width: 40),
                  ...['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].asMap().entries
                      .map((entry) {
                    Color dayColor;
                    switch (entry.key) {
                      case 1:
                        dayColor = Colors.yellow;
                        break;
                      case 2:
                        dayColor = Colors.purple;
                        break;
                      case 3:
                        dayColor = Colors.green;
                        break;
                      case 4:
                        dayColor = Colors.orange;
                        break;
                      case 5:
                        dayColor = Colors.blue;
                        break;
                      case 6:
                        dayColor = Colors.deepPurple;
                        break;
                      case 0:
                      default:
                        dayColor = Colors.red;
                        break;
                    }
                    return Container(
                      width: columnWidth,
                      height: 40,
                      color: dayColor,
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Time Table Rows
              SizedBox(
                height: hourHeight * 18,
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Labels
                        Column(
                          children: List.generate(18, (index) {
                            final hour = 6 + index;
                            return SizedBox(
                              height: hourHeight,
                              width: 40,
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ),

                        // Day Columns
                        ...List.generate(7, (day) {
                          final dayEvents = weekMap[day]!;
                          return Container(
                            width: columnWidth,
                            height: hourHeight * 18,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Stack(
                              children: dayEvents.map((event) {
                                final start = event.startTime;
                                final end = event.endTime;

                                final topOffset =
                                    ((start.hour + start.minute / 60.0) - 6) *
                                        hourHeight;
                                final height =
                                    ((end.difference(start).inMinutes) / 60.0) *
                                        hourHeight;

                                return Positioned(
                                  top: topOffset,
                                  left: 4,
                                  right: 4,
                                  height: height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: getDayColor(event.startTime).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ],
                    ),

                    // Horizontal lines
                    ...List.generate(18, (index) {
                      final top = index * hourHeight;
                      return Positioned(
                        top: top,
                        left: 40,
                        right: 0,
                        child: Divider(height: 1, color: Colors.grey.shade300),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
