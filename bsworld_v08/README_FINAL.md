# bs.world — Final all-in-one build

This build consolidates the real Supabase chat/media/calling foundation, groups, favorites, block/report data, call history, secure media paths, race-safe WebRTC signaling, and network-adaptive outbound video encoding.

## One-time setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run **`supabase/setup.sql` once**.
3. Copy `.env.example` to `.env` and fill `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`.
4. For reliable calls on restrictive mobile networks, configure a TURN server and fill the three TURN variables. STUN-only calls can fail on some carrier/NAT combinations.
5. Because `react-native-webrtc` is native code, use an Android development/production build (EAS or a native build), not Expo Go.

## Important
- Never put a Supabase service-role key in the app.
- Push notifications for background/killed-app incoming calls still require a server-side push sender/Edge Function and Expo/APNs/FCM credentials; this ZIP does not pretend those credentials are already configured.
- The adaptive video controller changes outbound bitrate/framerate/resolution based on WebRTC stats while keeping audio enabled.
