# Twin Core Blasters Online Input Step 5

This version adds the Godot-side WebSocket client foundation.

## What was added

```text
scripts/network/NetworkMessages.gd
scripts/network/NetworkClient.gd
```

`Main.gd` now creates `NetworkClient` safely at startup.

## Current state

This step does not require a WebSocket server yet.

Local play still works as before:

```text
P1: WASD + F
P2: Arrow Keys + L
```

Fake online mode from Step 4 still works:

```text
F8: Toggle fake online mode
F9: Switch local player P1/P2
```

## Step 5 debug hotkeys

These are preparation hotkeys for the future WebSocket server.

```text
F10: Connect / disconnect to ws://localhost:8080
F11: Send create-room request
F12: Send join-room request for room TEST
```

If no server is running, pressing F10 will print a connection warning, but the game should continue running normally.

## Future online controls

When the future server assigns this browser as P1 or P2, the game switches to online input mode.

Each PC/browser will use:

```text
Move: Arrow Keys
Action / Shot: Space
```

Fusion mode design:

```text
P1: Arrow Keys move the pointer, Space fires Fusion Cannon
P2: Arrow Keys move the fused ship, Space places a bomb
```

## Next step

Step 6 should add a minimal WebSocket server:

```text
server/
├── package.json
└── server.js
```

The server should support:

```text
create_room
join_room
player_assigned
input relay
disconnect handling
```

## Notes

This ZIP was prepared by static file editing. It has not been runtime-tested inside Godot in this environment.
