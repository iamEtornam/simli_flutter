import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:simli_flutter/simli_flutter.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('SimliFlutter - getPossibleFaceIDs', () {
    test('returns face IDs on successful response', () async {
      final mockClient = MockClient();

      final expectedResponse = jsonEncode({
        'face_ids': {'faceId1': 'faceId1', 'faceId2': 'faceId2'}
      });
      when(mockClient.get(Uri.parse(
              'https://example.com/api/fetch?limit=10,20,30&max=100')))
          .thenAnswer((_) async => http.Response(expectedResponse, 200));

      final simliClient =
          SimliFlutter(apiKey: 'your_api_key', client: mockClient);
      final faceIds = await simliClient.getPossibleFaceIDs();

      expect(faceIds, {
        'face_ids': ['faceId1', 'faceId2']
      });
      verify(mockClient.get(Uri.parse(
              'https://simli.com/api/getPossibleFaceIDs?apiKey=your_api_key')))
          .called(1);
    });

    test('throws exception on error response', () async {
      final mockClient = MockClient();

      final expectedResponse = jsonEncode({'detail': 'API error message'});
      when(mockClient.get(Uri.parse(
              'https://simli.com/api/getPossibleFaceIDs?apiKey=your_api_key')))
          .thenAnswer((_) async => http.Response(expectedResponse, 400));

      final simliClient =
          SimliFlutter(apiKey: 'your_api_key', client: mockClient);

      expect(() => simliClient.getPossibleFaceIDs(), throwsException);
      verify(mockClient.get(Uri.parse(
              'https://simli.com/api/getPossibleFaceIDs?apiKey=your_api_key')))
          .called(1);
    });

    test('throws exception on network error', () async {
      final mockClient = MockClient();

      when(mockClient.get(Uri.parse(
              'https://simli.com/api/getPossibleFaceIDs?apiKey=your_api_key')))
          .thenThrow(Exception('Network error'));

      final simliClient =
          SimliFlutter(apiKey: 'your_api_key', client: mockClient);

      expect(() => simliClient.getPossibleFaceIDs(), throwsException);
      verify(mockClient.get(Uri.parse(
              'https://simli.com/api/getPossibleFaceIDs?apiKey=your_api_key')))
          .called(1);
    });
  });
}
