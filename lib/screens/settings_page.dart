import 'package:flutter/material.dart';
import 'package:quiz_app/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await DatabaseHelper.instance.resetDatabase();
            await DatabaseHelper.instance.database; // Force re-initialization
            Fluttertoast.showToast(msg: 'Database reset successfully!');
          },
          child: const Text('Reset Database'),
        ),
      ),
    );
  }
}
