import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class SimliFlutter {
  final String baseUrl = 'https://simli.com/api';
  String? _apiKey;
  String get apiKey => _apiKey!;
  http.Client? _client;
  http.Client get client => _client!;

  set setApiKey(String value) {
    if (value.isEmpty) {
      throw Exception('API key cannot be empty.');
    }

    _apiKey = value;
  }

  set setClient(http.Client value) {
    _client = value;
  }

  SimliFlutter({required String apiKey, http.Client? client}) {
    setApiKey = apiKey;
    setClient = client ?? http.Client();
  }

  Future<Map<String, dynamic>> getPossibleFaceIDs() async {
    final url = Uri.parse('$baseUrl/getPossibleFaceIDs?apiKey=$apiKey');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          throw Exception('${data['detail']}');
        } else {
          return data;
        }
      } else {
        throw Exception(
            'Failed to get possible face IDs. Status code: ${response.statusCode}');
      }
    } on Exception catch (error) {
      throw Exception('Error fetching possible face IDs: $error');
    }
  }

  Future<bool> isSessionAvailable() async {
    final url = Uri.parse('$baseUrl/isSessionAvailable');
    final body = jsonEncode({'apiKey': apiKey});

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Parse the response body (assuming JSON format)
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          throw Exception('${data['detail']}');
        } else {
          return data['isAvailable'] ?? false;
        }
      } else {
        throw Exception(
            'Failed to check session availability. Status code: ${response.statusCode}');
      }
    } on Exception catch (error) {
      throw Exception('Error checking session availability: $error');
    }
  }

  Future<String> startAudioToVideoSession(
    bool syncAudio,
    bool isJPG,
    String faceId,
  ) async {
    final url = Uri.parse('$baseUrl/startAudioToVideoSession');
    final body = jsonEncode({
      'apiKey': apiKey,
      'syncAudio': syncAudio,
      'isJPG': isJPG,
      'faceId': faceId,
    });

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        // Parse the response body (assuming JSON format)
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          throw Exception('${data['detail']}');
        } else {
          return data['session_token'];
        }
      } else {
        throw Exception(
            'Failed to start audio-to-video session. Status code: ${response.statusCode}');
      }
    } on Exception catch (error) {
      throw Exception('Error starting audio-to-video session: $error');
    }
  }

  Future<Stream<LipsyncStreamResult>> lipsyncStream(
    String videoReferenceUrl,
    String faceDetectionResultsUrl,
    bool isJPG,
    bool syncAudio,
  ) async {
    final url = Uri.parse('wss://api.simli.ai/LipsyncStream');

    final initialRequest = {
      'video_reference_url': videoReferenceUrl,
      'face_det_results': faceDetectionResultsUrl,
      'isJPG': isJPG,
      'syncAudio': syncAudio,
    };
    final channel = WebSocketChannel.connect(url);
    final controller = StreamController<LipsyncStreamResult>.broadcast();

    try {
      // Send the initial request as JSON
      channel.sink.add(jsonEncode(initialRequest));

      channel.stream.listen((message) {
        // Handle incoming binary response data
        final data = message as Uint8List;

        // Process the response based on syncAudio flag
        final result = _processData(data, isJPG, syncAudio);
        if (result != null) {
          controller.add(result);
        }
      });
      return controller.stream;
    } catch (error) {
      log('Error connecting to LipsyncStream: $error');
      controller.addError(error);
      return controller.stream;
    } finally {
      // Close the WebSocket connection
      await channel.sink.close();
      controller.close();
    }
  }


  LipsyncStreamResult? _processData(
      Uint8List data, bool isJPG, bool syncAudio) {
    // Implement logic to parse the binary data based on the response format
    // and extract video frame and optional audio frame.
    // ... (replace with your implementation)

    // Example (replace with actual implementation):
    if (isJPG) {
      // Handle JPG video frame extraction
      return LipsyncStreamResult(data);
    } else {
      // Handle raw video frame and optional audio frame extraction
      if (syncAudio) {
        // Separate video and audio data based on format
        final videoFrame = data.sublist(0, data.length ~/ 2);
        final audioFrame = data.sublist(data.length ~/ 2);
        return LipsyncStreamResult(videoFrame, audioFrame: audioFrame);
      } else {
        return LipsyncStreamResult(data);
      }
    }
  }
}

class LipsyncStreamResult {
  final Uint8List videoFrame; // Raw video data (may be JPG or raw bytes)
  final Uint8List?
      audioFrame; // Optional audio data (present only if syncAudio is true)

  LipsyncStreamResult(this.videoFrame, {this.audioFrame});
}
