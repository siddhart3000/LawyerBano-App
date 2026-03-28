import 'package:flutter/material.dart';

class BareActsScreen extends StatelessWidget {
  const BareActsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bare Acts"),
        backgroundColor: const Color(0xFF4CD964),
      ),
      body: const Center(
        child: Text("Bare Acts Repository Coming Soon!"),
      ),
    );
  }
}
