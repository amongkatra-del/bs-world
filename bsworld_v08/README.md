# bs.world — FINAL 1.0

A real Expo/React Native mobile app foundation for bs.world with the locked premium UI and real Supabase-backed messaging/calling architecture.

### Included
- Supabase email/password auth and profiles
- Real-time 1-to-1 chat and group creation
- Photo/video/file upload through private Supabase Storage
- Signed media URLs generated when opened
- Read receipts and typing indicator
- Chat filters: All / Unread / Groups / Favorites
- Favorites, block and report database support
- Real voice/video WebRTC signaling
- Race-safe call signal recovery
- 60-second ringing timeout
- Call history
- Network-adaptive outbound video: bitrate, FPS and resolution scale respond to WebRTC stats
- Optional TURN server support through environment variables
- Android/iOS native configuration and EAS build config

## Supabase
Run `supabase/setup.sql` in the Supabase SQL Editor. It is designed to be re-runnable.

Never put a Supabase service-role key in the mobile app.

## Environment
Copy `.env.example` to `.env` and set the Supabase URL and anon key. Add TURN credentials for production calling.

## Build
`react-native-webrtc` is native code. Use an EAS/native Android build; Expo Go is not the production target for calling.

## Push notifications
Foreground realtime incoming-call routing is included. Background/killed-app push calling additionally needs a server-side push sender (Expo/FCM/APNs credentials and a deployed Edge Function). This project does not claim those external credentials are already deployed.
