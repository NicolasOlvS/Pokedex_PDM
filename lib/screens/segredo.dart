import 'package:flutter/material.dart';

class SegredoPage extends StatelessWidget {
  const SegredoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segredo'),
      ),
      body: Center(
        child: Image.asset(
          'assets/icone.jpg', 
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
