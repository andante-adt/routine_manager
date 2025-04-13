import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
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
            value: true, // 🔁 Replace with actual state
            onChanged: (value) {
              // TODO: Implement toggle logic
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
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Support'),
            subtitle: const Text('Contact us for feedback'),
            onTap: () {
              // TODO: Add support link / mailto
            },
          ),
        ],
      ),
    );
  }
}
