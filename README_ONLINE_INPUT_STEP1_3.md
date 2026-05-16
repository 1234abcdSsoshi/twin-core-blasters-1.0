# Online Input Abstraction Step 1-3

This build adds the first online-ready input layer without adding WebSocket networking yet.

## Goal

Prepare the game so P1 and P2 can eventually play from separate PCs/browsers with the same key layout.

```text
Online controls for each PC:
Move  : Arrow keys
Action: Space
```

## Added files

```text
scripts/input/PlayerInputState.gd
scripts/input/LocalInputProvider.gd
scripts/input/NetworkInputProvider.gd
scripts/input/InputRouter.gd
```

## What changed

### Step 1: Input data class

`PlayerInputState.gd` stores one frame of player input:

```text
move
shoot
bomb
aim
dash
shield
ultimate
```

It can also convert itself to/from `Dictionary`, which will be useful for future WebSocket JSON messages.

### Step 2: InputRouter integration

`Main.gd` now has an `input_router` and uses `_get_player_input(player_id)` in the main player update and Fusion Siege Mode.

Current same-PC local mode is preserved:

```text
P1: WASD + F
P2: Arrow keys + L
```

### Step 3: Online key layout prepared

`LocalInputProvider.gd` creates these online input actions at runtime:

```text
online_move_left   = Left
online_move_right  = Right
online_move_up     = Up
online_move_down   = Down
online_shoot       = Space
online_bomb        = Space
```

In future online mode:

```text
P1 PC: Arrow keys + Space
P2 PC: Arrow keys + Space
```

Fusion Siege role mapping will be:

```text
P1: Arrow keys move the pointer, Space fires Fusion Cannon
P2: Arrow keys move the fused ship, Space places bombs
```

## Important note

This is not the WebSocket version yet. It is the input foundation needed before networking.

To test online input locally later, call this from code after room join:

```gdscript
set_online_input_mode(true, 1) # this browser controls P1
set_online_input_mode(true, 2) # this browser controls P2
```

For now, the game still starts in local same-keyboard mode to avoid breaking the existing gameplay.
