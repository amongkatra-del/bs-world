# bs.world — easiest phone setup

1. Download the ZIP.
2. Upload/extract it in the phone-based coding/hosting service you are using.
3. Create a Supabase project.
4. In Supabase SQL Editor, run:
   - supabase/schema.sql
   - supabase/calls.sql
5. Add the two public Supabase values from your project to the environment:
   EXPO_PUBLIC_SUPABASE_URL
   EXPO_PUBLIC_SUPABASE_ANON_KEY
6. Start the Expo app.
7. Test Signup → Login → Contacts → Profile.

## Important
The public/anon key is intended for the client when Row Level Security is correctly configured.
Never put the Supabase service-role/secret key in the mobile app.

## Next
After this foundation is running, implement:
- conversation creation between two users
- message pagination and read receipts
- photo/video/file Storage uploads
- push notifications
- WebRTC audio/video + TURN fallback
- adaptive video bitrate/resolution based on connection statistics

## v0.8 database update
After the earlier SQL files, run `supabase/v0.8_fix.sql` in Supabase SQL Editor. It adds the real chat-list RPC and atomic read helper.
