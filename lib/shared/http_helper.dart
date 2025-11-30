// lib/shared/http_helper.dart (BARU: Tambahkan ini untuk API calls)
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchRank(String type, int minIdr, int maxIdr) async {
  final url = Uri.parse('https://techpilot-ml.onrender.com/rank?min=$minIdr&max=$maxIdr&type=$type');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load ranking');
}

Future<List<Map<String, dynamic>>> fetchCompare(String type, List<Map<String, dynamic>> devices) async {
  final url = Uri.parse('https://techpilot-ml.onrender.com/compare');
  final response = await http.post(
    url,
    body: json.encode({'devices': devices, 'type': type}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load comparison');
}

Future<String> fetchChat(String message, String type) async {
  final url = Uri.parse('https://techpilot-ml.onrender.com/chat');
  final response = await http.post(
    url,
    body: json.encode({'message': message, 'type': type}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    return json.decode(response.body)['reply'];
  }
  throw Exception('Failed to load chat reply');
}