# Twin Core Blasters Online Input Step 7

This version adds a practical room-code join flow.

## What changed

- `F10`: connect / disconnect WebSocket server
- `F11`: create a room
- `F7`: start typing a room code
- `A-Z / 0-9`: type room code while room entry is active
- `Backspace`: delete one character
- `Enter` or `F12`: join typed room
- `Esc`: cancel room-code entry

The HUD now displays:

```text
NET <status>  ROOM <room_code>  LOCAL <P1/P2>
```

## Two-client local test

1. Start the server:

```powershell
cd .\server
npm install
npm start
```

2. Start the first Godot client.
3. Press `F10`.
4. Wait until `connected`.
5. Press `F11`.
6. Read the room code shown in the HUD and console.
7. Start the second Godot client.
8. Press `F10`.
9. Press `F7`.
10. Type the room code.
11. Press `Enter` or `F12`.

The first client should be P1 and the second client should be P2.

## Notes

This is still an online input prototype.

- The server relays input messages.
- Godot receives remote input through `NetworkInputProvider`.
- Full game-state synchronization and stage-specific online polish are planned for the next step.
