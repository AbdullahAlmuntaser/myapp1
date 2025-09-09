import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الوضع الداكن',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeTrackColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Add more settings options here
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                'حول التطبيق',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to an "About" screen or show a dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'نظام إدارة الطلاب',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2023 تطبيقي. جميع الحقوق محفوظة.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
