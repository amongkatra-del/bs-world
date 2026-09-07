# bs.world v0.5 — All-in-one real communication build

This build keeps the existing visual design and combines the communication work into one Expo/React Native project.

Included in this build:
- Supabase authentication/profile foundation
- Real 1-to-1 conversation creation and realtime messages
- Read receipts
- Typing indicator via realtime broadcast
- Photo/video/file picker + Supabase Storage upload foundation
- Call database/signaling foundation from v0.4
- React Native WebRTC dependency added for the real audio/video calling implementation

Important: WebRTC calling is **not claimed production-ready merely because the dependency is installed**. A real worldwide call requires device permissions, native development build configuration, signaling/ICE handling, and a TURN server for networks where direct peer-to-peer connectivity fails. Those pieces must be tested on physical devices before release.
