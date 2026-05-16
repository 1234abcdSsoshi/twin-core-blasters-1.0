# Online Input Step 8: Input Relay Integration

This version connects the WebSocket room flow to gameplay input routing.

## What changed

- Local input is sent to the WebSocket server at 30 Hz after joining a room.
- Remote input messages are received from the server.
- Remote input is stored in `NetworkInputProvider`.
- `InputRouter` can feed local/remote input into the existing gameplay code.
- HUD shows network relay counters: `I/O sent/received`.
- `F6` prints local and remote input states to the Godot output log.

## Controls for online clients

Each PC uses the same controls:

```text
Arrow Keys: move / aim
Space: shot / action
```

In Story Fusion Mode:

```text
P1: Arrow Keys move the pointer, Space fires Fusion Cannon
P2: Arrow Keys move the fused ship, Space places bombs
```

## Test flow

Start the Node.js server:

```powershell
cd .\server
npm install
npm start
```

Client 1:

```text
F10: connect
F11: create room
```

Client 2:

```text
F10: connect
F7: start room-code entry
Type the room code
Enter or F12: join
```

Debug:

```text
F6: print online input state
```

## Notes

This step relays input. It does not yet make the entire game state authoritative on the server. Enemy spawning, bullets, HP and item state still run locally, so the next step should make one stage authoritative or implement host-state synchronization.
