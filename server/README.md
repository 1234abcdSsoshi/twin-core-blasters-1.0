# Twin Core Blasters WebSocket Server

This is the minimal Step 6 server.

## Install

```powershell
cd .\server
npm install
```

## Run

```powershell
npm start
```

The server listens on:

```text
ws://localhost:8080
```

## Test flow with Godot

1. Run the server.
2. Run the Godot game.
3. Press `F10` to connect.
4. Press `F11` to create a room.
5. On another client later, use the room ID and join.

At Step 6, the server relays input messages, but full online gameplay synchronization is still implemented in later steps.
