import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 1. OPSI URL (Pilih salah satu sesuai device)
  
  // A. Jika pakai Android Emulator:
  static const String baseUrl = "http://10.0.2.2:8000";
  
  // B. Jika pakai iOS Simulator:
  // static const String baseUrl = "http://127.0.0.1:8000"; 
  
  // C. Jika pakai HP ASLI (Fisik) & Laptop (Satu WiFi):
  // Ganti angka ini dengan IPv4 Laptop Anda (cek di cmd > ipconfig)
  // static const String baseUrl = "http://192.168.1.XX:8000"; 

  static Future<Uint8List> stitchImages(List<Uint8List> images) async {
    final uri = Uri.parse("$baseUrl/stitch");
    final request = http.MultipartRequest("POST", uri);

    // Tambahkan gambar ke request
    for (int i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "files", // Harus sama dengan parameter di FastAPI: files: list[UploadFile]
          images[i],
          filename: "image_$i.jpg",
          contentType: MediaType("image", "jpeg"), 
        ),
      );
    }

    print("🚀 Mengirim ${images.length} gambar ke $uri...");
    print("⏳ Mohon tunggu, proses stitching sedang berjalan...");

    try {
      // Kirim request
      final response = await request.send();

      // Cek Status Code
      if (response.statusCode == 200) {
        print("✅ Stitching Sukses! Mengunduh hasil...");
        return await response.stream.toBytes();
      } else {
        // Jika Error (400, 422, 500)
        final errorData = await response.stream.bytesToString();
        print("❌ Server Error: ${response.statusCode}");
        print("Pesan: $errorData");
        
        // Throw error bersih agar muncul di SnackBar
        // Hapus karakter aneh json jika ada
        throw Exception(errorData.replaceAll('"', '').replaceAll('{detail:', ''));
      }
    } on SocketException {
      throw Exception("Gagal terhubung ke server. Pastikan Backend menyala & IP benar.");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}