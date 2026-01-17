import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl =
      "https://burhanuddindhikaf-apipanorama.hf.space";

  static Future<Uint8List> stitchImages(
    List<Uint8List> images, {
    required String engine,
  }) async {
    late Uri uri;

    // ================= PILIH ENGINE =================
    if (engine == "sift") {
      uri = Uri.parse(
        "$baseUrl/stitch?engine=sift&ratio=0.75&ransac=4.0",
      );
    } else if (engine == "opencv") {
      uri = Uri.parse(
        "$baseUrl/stitch?engine=opencv",
      );
    } else {
      throw Exception("Engine panorama tidak dikenal");
    }

    final request = http.MultipartRequest("POST", uri);

    // ================= TAMBAH FILE =================
    for (int i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "files",
          images[i],
          filename: "image_$i.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    print("🚀 Engine: $engine");
    print("📡 Endpoint: $uri");
    print("🖼️ Jumlah gambar: ${images.length}");

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        return await response.stream.toBytes();
      } else {
        final errorData = await response.stream.bytesToString();
        throw Exception(
          errorData
              .replaceAll('"', '')
              .replaceAll('{detail:', '')
              .replaceAll('}', ''),
        );
      }
    } on SocketException {
      throw Exception("Gagal terhubung ke server.");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}
