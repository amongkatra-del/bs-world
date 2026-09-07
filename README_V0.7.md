# bs.world v0.7 — integrated calling fix

This build fixes the call-session flow: starting a voice/video call creates a real `call_sessions` row and passes its id into the call screen. Incoming calls can be accepted/rejected when routed with `incoming=1`. Signaling uses Supabase Realtime and media uses react-native-webrtc.

Run `supabase/calls.sql` after the base schema/features SQL. A TURN relay is still required for reliable worldwide connectivity on restrictive/NAT-heavy networks; do not put TURN credentials or Supabase service-role keys in the mobile client.
