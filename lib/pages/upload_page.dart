import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker picker = ImagePicker();
  List<Uint8List> images = [];
  bool loading = false;

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 2 foto")),
      );
      return;
    }

    images = [];
    for (var img in picked) {
      images.add(await img.readAsBytes());
    }
    setState(() {});
  }

  Future<void> stitch() async {
    setState(() => loading = true);
    try {
      final result = await ApiService.stitchImages(images);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(panorama: result),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panorama Stitching")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImages,
              child: const Text("Pilih Foto"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                itemBuilder: (_, i) =>
                    Image.memory(images[i], fit: BoxFit.cover),
              ),
            ),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: images.length >= 2 ? stitch : null,
                    child: const Text("Buat Panorama"),
                  ),
          ],
        ),
      ),
    );
  }
}
