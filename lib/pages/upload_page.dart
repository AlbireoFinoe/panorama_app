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
  String selectedEngine = "sift"; // default

  final ImagePicker picker = ImagePicker();
  List<Uint8List> images = [];
  bool loading = false;

  // ================= PICK IMAGE =================
  Future<void> pickImage(ImageSource source) async {
    if (loading) return;

    try {
      if (source == ImageSource.gallery) {
        final pickedFiles = await picker.pickMultiImage(
          imageQuality: 100,
        );

        if (pickedFiles.isNotEmpty) {
          List<Uint8List> newImages = [];
          for (var img in pickedFiles) {
            newImages.add(await img.readAsBytes());
          }
          setState(() {
            images.addAll(newImages);
          });
        }
      } else {
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 100,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            images.add(bytes);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ================= REMOVE IMAGE =================
  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  // ================= CLEAR ALL =================
  void clearAll() {
    setState(() {
      images.clear();
    });
  }

  // ================= STITCH =================
  Future<void> stitch() async {
    if (images.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Minimal diperlukan 2 foto dengan overlap."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final result = await ApiService.stitchImages(
  images,
  engine: selectedEngine,
);


      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(panorama: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Panorama"),
        actions: [
          if (images.isNotEmpty && !loading)
            IconButton(
              onPressed: clearAll,
              icon: const Icon(Icons.delete_sweep),
              tooltip: "Hapus Semua",
            ),
        ],
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Instruksi Pengambilan Foto",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Pilih minimal 2 foto yang diambil secara berurutan dengan "
                  "area yang saling bertumpuk (overlap) agar sistem dapat "
                  "menggabungkan gambar menjadi panorama.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Catatan Teknis:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "• Overlap antar foto ±30%\n"
                  "• Posisi kamera relatif sama\n"
                  "• Hindari objek bergerak\n"
                  "• Perbedaan pencahayaan tidak ekstrem",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    children: [
      const Text(
        "Algoritma Panorama:",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedEngine,
          items: const [
            DropdownMenuItem(
              value: "sift",
              child: Text("SIFT (Feature-Based)"),
            ),
            DropdownMenuItem(
              value: "opencv",
              child: Text("OpenCV Stitcher"),
            ),
          ],
          onChanged: loading
              ? null
              : (value) {
                  setState(() {
                    selectedEngine = value!;
                  });
                },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    ],
  ),
),


          // ==========================================================
          // BAGIAN TOMBOL AKSI
          // ==========================================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Kamera"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // GRID PREVIEW
          // ==========================================================
          Expanded(
            child: images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada foto.\nAmbil foto berurutan dengan overlap.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: images.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!loading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "${images.length} Foto Terpilih (minimal 2 foto)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 15),
                            Text("Sedang menggabungkan foto menjadi panorama..."),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: images.length >= 2 ? stitch : null,
                          child: const Text(
                            "GABUNGKAN (STITCH)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          ),

Padding(
  padding: const EdgeInsets.only(bottom: 12, top: 4),
  child: Column(
    children: const [
      Divider(thickness: 1),
      SizedBox(height: 6),
      Text(
        "Dibuat oleh:",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
      SizedBox(height: 4),
      Text(
        "Albireo Musyaffa Finoe\n"
        "Burhanuddin Dhika\n"
        "Malfino Wildan Akhya",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}
