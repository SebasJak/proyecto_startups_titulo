import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// In-Memory Database for MVPs
final List<Map<String, dynamic>> startupsDb = [
  {
    "id": "1",
    "name": "EcoPack",
    "description": "Building sustainable custom 3D printed packaging. Hardware B2B.",
    "videoUrl": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "deckUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "ownerPhoneNumber": "+1234567890",
    "likesCount": 12,
    "isLikedByMe": false,
  },
  {
    "id": "2",
    "name": "GlobalTech",
    "description": "Next generation AI-driven enterprise software solutions. HealthTech B2C.",
    "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "deckUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "ownerPhoneNumber": "+1234567890",
    "likesCount": 350,
    "isLikedByMe": false,
  }
];

final _router = Router()
  ..get('/', _rootHandler)
  ..get('/startups', _getStartupsHandler)
  ..post('/startups', _postStartupsHandler);

Response _rootHandler(Request req) {
  return Response.ok('Pegasus Backend is active!\n');
}

Response _getStartupsHandler(Request req) {
  return Response.ok(
    jsonEncode(startupsDb),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _postStartupsHandler(Request req) async {
  final payload = await req.readAsString();
  try {
    final Map<String, dynamic> newStartup = jsonDecode(payload);
    
    // Inject generated metadata before saving
    newStartup['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    newStartup['likesCount'] = 0;
    newStartup['isLikedByMe'] = false;
    
    // Inject required mock videos/pdfs if empty
    if(newStartup['videoUrl'] == null || newStartup['videoUrl'].isEmpty) {
      newStartup['videoUrl'] = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
    }
    if(newStartup['deckUrl'] == null || newStartup['deckUrl'].isEmpty) {
      newStartup['deckUrl'] = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    }
    if(newStartup['ownerPhoneNumber'] == null || newStartup['ownerPhoneNumber'].isEmpty) {
      newStartup['ownerPhoneNumber'] = "+1234567890";
    }

    // Unshift to the start of the list so it appears first in the feed
    startupsDb.insert(0, newStartup);
    
    return Response.ok(
      jsonEncode({"status": "success", "data": newStartup}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.badRequest(body: 'Invalid JSON payload - Failed to parse Startup');
  }
}

void main(List<String> args) async {
  // Bind to all interfaces (necessary for Android emulators pointing to 10.0.2.2)
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // Binding on port 8080 by default.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server eagerly listening on port ${server.port}');
}
