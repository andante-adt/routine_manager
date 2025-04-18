import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title:
                const Text('Settings', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: const Color(0xFF030052),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            children: [
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive reminders for your events'),
                value: eventProvider.notificationsEnabled,
                onChanged: (value) {
                  eventProvider.toggleGlobalNotifications(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications enabled'
                            : 'Notifications disabled',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 32),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.contact_support_outlined),
                title: const Text('Support'),
                subtitle: const Text('Contact us for feedback'),
              ),
            ],
          ),
        );
      },
    );
  }
}
