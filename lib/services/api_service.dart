import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Uint8List> stitchImages(List<Uint8List> images) async {
    final uri = Uri.parse("$baseUrl/stitch");
    final request = http.MultipartRequest("POST", uri);

    for (int i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "files",
          images[i],
          filename: "img_$i.jpg",
          contentType: MediaType("image", "jpeg"), // 🔥 WAJIB
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      final err = await response.stream.bytesToString();
      throw Exception("Backend error: $err");
    }
  }
}
