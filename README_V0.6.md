# bs.world v0.6 — integrated media + calling

This is one project. It adds:
- image/video/file message types with Supabase Storage
- voice/video call screen using react-native-webrtc
- Supabase call signaling (offer/answer/ICE/hangup)
- microphone/camera permissions
- call buttons from chat

Important: native WebRTC requires a native development build; it is not expected to work in Expo Go. The included STUN server is for connectivity discovery. For reliable worldwide calling, production needs a TURN relay and real-device network testing.
