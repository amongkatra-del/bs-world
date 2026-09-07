# bs.world real calling architecture

The UI is intentionally designed for a real calling implementation, not a fake call animation.

## Media
Use WebRTC for peer-to-peer audio/video. The app must request microphone/camera permissions and create an RTCPeerConnection.

## Signaling
Supabase Realtime carries offer/answer/ICE signaling through call_signals.

## Network adaptation
The video sender should use adaptive encoding/simulcast where supported, monitor connection statistics, and lower resolution/bitrate/frame rate when packet loss or RTT rises. When the connection improves, quality can be raised again.

## Connectivity
STUN is useful for discovering routes, but reliable worldwide calling generally also needs TURN fallback for restrictive NAT/mobile networks. A production TURN service must be configured and monitored; this cannot honestly be guaranteed to be free or zero-configuration.

## Quality target
Prefer stable audio and a smooth picture over forcing HD on a weak connection. Start conservatively, then adapt upward.

## Security
Never ship a Supabase service-role key or any TURN credential that is intended to be secret. Temporary TURN credentials should be issued server-side.

## Testing
Real calling must be tested on:
- Wi-Fi to Wi-Fi
- mobile data to mobile data
- Wi-Fi to mobile data
- weak/unstable networks
- background/foreground transitions
- camera/mic permission denial
- incoming call while another call is active
