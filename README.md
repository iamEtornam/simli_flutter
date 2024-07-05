# simli_flutter

Simli lets developers create Lipsynced AI avatars. Ready to make your first one? Your journey begins here.


### An API with endless possibilities.
With visual lipsynced AI avatars like our API gives you, anything is possible: mock interviews, sales assistants, language training, coaching, CS training, historical characters and so much more. [Try our demo](https://www.simli.com/demo).

[alt text](Background_avatars.gif)


## How it works?
Using our LipsyncStream API is simple. Through a bi-directional websocket communication, you send us audio and we send you back video and audio frames.

You can then use these video and audio frame bytes to render video and playback audio in sync. You can also use our ```simli_flutter``` to handle WebSocket communication, decode received bytes and sync audio & video playback.

## Getting started

### simli_flutter for Streaming
This document outlines the key concepts for getting started with ```simli_flutter``` to enable livestreaming functionalities.

### Key Concepts
- API Key: All API endpoints require an API key. You can obtain one by creating an account at [Create an account](https://simli.com/sign-up-in). The API key allows you to track usage and control access to Simli functionalities.

- Faces: You can access all available Simli avatar faces through the ```/getPossibleFaceIDs``` endpoint. The library is constantly expanding with new faces.

- WebSocket: To receive video and audio bytes for decoding, stream PCM16 audio bytes to the LipsyncStream WebSocket. Decoding is done according to the WebSocket scheme.

- ```simli_flutter```: This library simplifies the process. It handles WebSocket communication, decodes received bytes, and synchronizes audio and video playback.

## Key features
- Retrieve available avatar faces using ```getPossibleFaceIDs```.
- Check for active sessions with ```isSessionAvailable```.
- Initiate audio-to-video sessions with ```startAudioToVideoSession```.
- Establish a WebSocket connection for real-time lipsync streaming through ```lipsyncStream```.

## Usage

#### Stream Live Animations with Ease
This example demonstrates how to use the SimliFlutter class to interact with the Simli API and enable livestreaming functionalities in your Flutter application.

```dart
import 'package:simli_flutter/simli_flutter.dart';

// Replace with your actual API key
final String apiKey = 'YOUR_API_KEY';

Future<void> main() async {
  final simli = SimliFlutter(apiKey: apiKey);

  // Get available face IDs
  try {
    final faceIds = await simli.getPossibleFaceIDs();
    print('Available Face IDs: $faceIds');
  } catch (error) {
    print('Error fetching face IDs: $error');
  }

  // Check session availability
  final isSessionAvailable = await simli.isSessionAvailable();
  print('Session Available: $isSessionAvailable');

  // Initiate audio-to-video session
  final String faceId = '101bef0dB62d4fbeA6b489bc3fc66ec6'; // Replace with desired face ID
  final String sessionToken = await simli.startAudioToVideoSession(
    syncAudio: true, // Set to true to synchronize audio and video
    isJPG: true, // Set to true to receive JPG video frames
    faceId: faceId,
  );
  print('Session Token: $sessionToken');

  // Establish lipsync stream (implementation details omitted)
  await simli.lipsyncStream(
    // Provide video reference URL, face detection results URL, etc.
  );
}
```

Replace ```YOUR_API_KEY``` with your actual Simli API key.
The lipsyncStream implementation requires additional logic for handling binary response data based on the received format.
This example provides a basic structure for using SimliFlutter to interact with the Simli API and initiate livestreaming functionalities. You can customize it further based on your specific needs.
```

## Contributing

- I would like to keep this library as small as possible.
- Please don't send a PR without opening an issue and discussing it first.
- If proposed change is not a common use case, I will probably not accept it.
