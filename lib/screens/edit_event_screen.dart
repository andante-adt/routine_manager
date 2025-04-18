import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import 'time_table_screen.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _title = widget.event.title;
    _description = widget.event.description;
    _selectedDate = widget.event.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _startTime != null &&
        _endTime != null) {
      _formKey.currentState!.save();

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Invalid Time'),
          content: const Text('End time must be after start time.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _formKey.currentState!.save();

      Provider.of<EventProvider>(context, listen: false).updateEvent(
        id: widget.event.id,
        title: _title,
        description: _description,
        startTime: startDateTime,
        endTime: endDateTime,
        categoryId: widget.event.categoryId,
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: const Text('Edit Event',style: const TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Color(0xFF030052),
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.white), //
            actions: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                color:Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimeTableScreen()),
                  );
                },
              )
            ],
          ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startTime == null
                          ? 'Start Time: --:--'
                          : 'Start Time: ${_startTime!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickStartTime,
                    child: const Text('Pick Start Time'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endTime == null
                          ? 'End Time: --:--'
                          : 'End Time: ${_endTime!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickEndTime,
                    child: const Text('Pick End Time'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 5, 0, 137), // Color for the button background
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text(
                            'Are you sure you want to delete this event?'),
                      actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                              Navigator.of(ctx).pop(); // Close the dialog
                              Provider.of<EventProvider>(context, listen: false)
                                .deleteEvent(widget.event.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                 content: Text('Event deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                        },
                          child: const Text(
                              'Delete',style: TextStyle(color: Colors.red), // Color for the "Delete" action in the dialog
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white), // White color for the button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
