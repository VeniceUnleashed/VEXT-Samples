# nohavok

This mod replaces all static model groups (StaticModelGroupEntityData) with individual entities for easier manipulation.

## Known issues

This mod doesn't currently work on some maps:

| Map | Behavior |
| --- | -------- |
| Teheran Highway (MP_003) | Client kicked |
| Seine Crossing (MP_011) | Server crash |
| Operation Metro (MP_Subway) | Server crash |
| Death Valley (XP3_Valley) | Server crash |
| Nebandan Flats (XP5_002) | Server crash |
| Strike at Karkand (XP1_001) | Client kicked |
| Sharqi Peninsula (XP1_003) | Client kicked |
| Operation 925 (XP2_Office) | Server crash |

Other issues:
- When setting an entity scale higher than `1.0`, the server crashes.
- In some maps, it creates invisible collision boxes (might be related to scale).
- On high-latency connections, the client will fail to receive the relevant data and get kicked after loading the level because of data mismatch.
