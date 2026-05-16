# Twin Core Blasters Online Input Step 6

This version adds the minimal WebSocket server.

## Added files

```text
server/package.json
server/server.js
server/README.md
tools/run_server.ps1
README_ONLINE_INPUT_STEP6_WEBSOCKET_SERVER.md
```

## Step 6 goal

The Godot client from Step 5 already has a `NetworkClient.gd`.

Step 6 adds a separate Node.js WebSocket server that can:

```text
- create rooms
- join rooms
- assign P1 / P2
- relay input messages between players
- handle disconnects
```

## How to run the server

From the project root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\run_server.ps1
```

Or manually:

```powershell
cd .\server
npm install
npm start
```

The server starts at:

```text
ws://localhost:8080
```

## How to test with Godot

1. Start the server.
2. Start the Godot game.
3. Press `F10` to connect.
4. Press `F11` to create a room.

Expected console messages:

```text
[NetworkClient] Connected.
[NetworkClient] Room created: XXXX
[NetworkClient] Assigned local player: P1
```

## Current status

This step only adds the server and confirms that the client can connect and send room messages.

Full remote-control gameplay will be connected in Step 7.
