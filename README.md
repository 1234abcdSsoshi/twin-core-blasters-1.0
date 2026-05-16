# Twin Core Blasters - V11 Design Fix

Godot 4.x project with asset integration and gameplay/UI fixes.

## What changed in V11

### Stage 1: CO-OP DEFENSE restored
- Stage 1 is now focused on cooperative play again.
- Staying near your partner or both defending the core charges `CO-OP LINK`.
- At 100%, press `G`, `K`, or `Space` to fire Twin Core Cannon and clear enemies.

### Core shield redesigned
- Shield items no longer attach shields to players.
- Shield items now protect the central core.
- The core shield absorbs enemy impact damage for a limited time.

### Stage 3: Eclipse Leviathan movement
- The raid boss now moves horizontally and vertically.
- Movement becomes stronger by phase.
- Weak cores follow the moving boss.

### Game over UI redesigned
- Added a dark overlay panel.
- Result title and score are shown clearly at the center.
- Press `R` to restart.

## Controls

### Home
- `1`: Story Mode
- `2`: Astral Court
- `3`: Eclipse Leviathan Raid
- `Enter` / `Space`: Story Mode

### P1
- `WASD`: Move
- `F`: Shoot

### P2
- Arrow keys: Move
- `L`: Shoot

### Stage 1 CO-OP DEFENSE
- `G` / `K` / `Space`: Twin Core Cannon when CO-OP LINK reaches 100%

### Astral Court
- P1: `Q` Dash / `E` Shield / `G` Ultimate
- P2: `O` Dash / `P` Shield / `K` Ultimate

### Raid
- `G` / `K`: Twin Core Cannon when Link is 100%

## Asset folder
Place your generated image assets inside:

```text
assets/
├── players/
├── enemies/
├── bosses/
├── projectiles/
├── effects/
├── items/
├── backgrounds/
├── stages/
└── ui/
```


## Online Input Step 8

See `README_ONLINE_INPUT_STEP8_INPUT_RELAY.md`.
