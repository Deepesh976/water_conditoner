import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
      };

  Future<http.Response> get(String url) async {
    try {
      final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      throw Exception("Connection failed");
    }
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await client
          .post(
            Uri.parse(url),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      throw Exception("Connection failed");
    }
  }

  Future<http.Response> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await client
          .put(
            Uri.parse(url),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      throw Exception("Connection failed");
    }
  }

  Future<http.Response> patch(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await client
          .patch(
            Uri.parse(url),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      throw Exception("Connection failed");
    }
  }

  Future<http.StreamedResponse> multipartRequest({
    required String method,
    required String url,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.fields.addAll(fields);
      request.files.addAll(files);
      final response = await request.send().timeout(const Duration(seconds: 25));
      return response;
    } catch (e) {
      throw Exception("Multipart request failed");
    }
  }
}
