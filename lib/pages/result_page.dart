import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final Uint8List panorama;

  const ResultPage({super.key, required this.panorama});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int? _width;
  int? _height;
  double _rotationAngle = 0.0;


  @override
  void initState() {
    super.initState();
    _getImageDimensions();
  }

  // Fungsi untuk mendapatkan resolusi gambar asli
  Future<void> _getImageDimensions() async {
    final image = await decodeImageFromList(widget.panorama);
    setState(() {
      _width = image.width;
      _height = image.height;
    });
  }

  // Fungsi Dummy untuk Simpan (Nanti Anda bisa pasang package 'image_gallery_saver')
  void _saveImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur Simpan akan segera hadir!")),
    );
  }
  void _rotateLeft() {
  setState(() {
    _rotationAngle -= 90 * (3.1415926535 / 180);
  });
}

void _rotateRight() {
  setState(() {
    _rotationAngle += 90 * (3.1415926535 / 180);
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam agar fokus ke gambar
      extendBodyBehindAppBar: true, // Agar gambar bisa full screen di balik AppBar
      appBar: AppBar(
        title: const Text("Hasil Panorama", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.5), // Semi transparan
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
actions: [
  IconButton(
    icon: const Icon(Icons.rotate_left),
    onPressed: _rotateLeft,
  ),
  IconButton(
    icon: const Icon(Icons.rotate_right),
    onPressed: _rotateRight,
  ),
  IconButton(
    icon: const Icon(Icons.info_outline),
    onPressed: () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Detail Gambar"),
          content: Text(
            "Resolusi: ${_width ?? '-'} x ${_height ?? '-'}\n"
            "Ukuran: ${(widget.panorama.lengthInBytes / 1024).toStringAsFixed(2)} KB",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            )
          ],
        ),
      );
    },
  ),
],

      ),
      body: Stack(
        children: [
          // 1. Layer Gambar Utama
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              clipBehavior: Clip.none,
             child: Transform.rotate(
  angle: _rotationAngle,
  child: Image.memory(
    widget.panorama,
    fit: BoxFit.contain,
  ),
),

            ),
          ),

          // 2. Layer Info Resolusi & Tombol Aksi di Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Teks Info Resolusi
                  if (_width != null)
                    Text(
                      "$_width x $_height pixels",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 15),
                  
                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke upload
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Ulangi"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveImage,
                          icon: const Icon(Icons.download),
                          label: const Text("Simpan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}