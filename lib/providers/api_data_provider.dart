import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/startup_project.dart';

// Depending on the emulator, localhost is 10.0.2.2 on Android Simulator.
// For physical devices or iOS Simulator, consider using local network IP or localhost.
const String _baseUrl = 'http://10.0.2.2:8080';

final apiProjectsProvider = FutureProvider<List<StartupProject>>((ref) async {
  final response = await http.get(Uri.parse('$_baseUrl/startups'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) {
      return StartupProject(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        videoUrl: json['videoUrl'] ?? '',
        deckUrl: json['deckUrl'] ?? '',
        ownerPhoneNumber: json['ownerPhoneNumber'] ?? '',
        likesCount: json['likesCount'] ?? 0,
        isLikedByMe: json['isLikedByMe'] ?? false,
      );
    }).toList();
  } else {
    throw Exception('Failed to load startups from backend');
  }
});

// A robust method mapped to POST a real startup payload to our Dart backend
Future<void> submitStartupNetwork(Map<String, dynamic> startupData) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/startups'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(startupData),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to submit startup to the backend');
  }
}
