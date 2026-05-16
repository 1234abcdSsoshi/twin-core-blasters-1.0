# Online Input Step 4: Fake Online Mode

This build adds a safe **fake online mode** before real WebSocket networking.

## Goal

Test the game with the online input structure:

```text
local player input
remote player input
```

without requiring a server yet.

## Current controls

### Classic local mode

```text
P1: WASD + F
P2: Arrow keys + L
```

### Fake online test mode

Press these debug keys during the game:

```text
F8: Toggle Fake Online Mode
F9: Switch local player between P1 and P2
```

When fake online mode is enabled:

```text
Local player: Arrow keys + Space
Remote player: simulated by NetworkInputProvider
```

This means you can test whether the game can handle:

```text
P1 input source = local or remote
P2 input source = local or remote
```

without implementing WebSocket yet.

## What changed

```text
scripts/input/NetworkInputProvider.gd
- Added fake remote input generator.

scripts/input/InputRouter.gd
- Added helper methods for online mode state.

scripts/Main.gd
- Added fake_online_test_mode.
- Added F8 / F9 debug hotkeys.
- Added remote input update loop.
- Added HUD display for fake online mode.
```

## Why this step matters

The next step is WebSocket. Before adding communication, we need to prove the game can already separate:

```text
local input
remote input
```

Step 5 will replace the fake remote generator with actual WebSocket messages.

## Important

This mode is only for development. It is not the final online multiplayer system.
