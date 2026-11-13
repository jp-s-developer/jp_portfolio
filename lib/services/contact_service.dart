import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactService {
  ContactService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> send({
    required String endpoint,
    required String name,
    required String email,
    required String message,
  }) async {
    if (endpoint.isEmpty) {
      throw Exception('Contact form is not configured yet. Please email me directly.');
    }

    final response = await _client.post(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'message': message,
        '_subject': 'Portfolio enquiry from $name',
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Message could not be sent. Please try again or email directly.');
    }
  }

  void dispose() => _client.close();
}
