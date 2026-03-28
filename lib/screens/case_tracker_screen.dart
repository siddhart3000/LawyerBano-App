import 'package:flutter/material.dart';

class CaseTrackerScreen extends StatelessWidget {
  const CaseTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Tracker"),
        backgroundColor: const Color(0xFF007AFF),
      ),
      body: const Center(
        child: Text("Track your legal cases in real-time!"),
      ),
    );
  }
}
