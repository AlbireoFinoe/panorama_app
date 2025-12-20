import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Uint8List panorama;

  const ResultPage({super.key, required this.panorama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Panorama")),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Image.memory(panorama),
        ),
      ),
    );
  }
}
