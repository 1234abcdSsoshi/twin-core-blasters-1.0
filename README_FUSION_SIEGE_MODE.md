# Fusion Siege Mode Step 1-5

This build adds the requested fused-ship control system for Story Mode.

## Implemented behavior

### Step 1: P1 pointer control

During Fusion Mode, the fused ship itself does not rotate. P1 controls a pointer with WASD.

```text
P1 WASD = move the pointer around the fused ship
```

The pointer is limited to a fixed radius around the fused ship so P2's positioning still matters.

### Step 2: P1 pointer-direction cannon

P1 fires toward the pointer direction.

```text
P1 F = fire Fusion Cannon toward pointer
```

### Step 3: P2 movement

P2 controls the fused ship movement.

```text
P2 Arrow Keys = move fused ship
```

### Step 4: P2 bomb placement

P2 places bombs instead of shield.

```text
P2 L = place bomb
```

Current balance values:

```text
Max bombs: 3
Cooldown: 0.8 sec
Fuse time: 3.0 sec
Trigger radius: 34 px
Explosion radius: 185 px
```

### Step 5: Bomb area damage

Bombs explode when an enemy touches them or when the fuse timer reaches zero.

```text
Scout / Attacker enemies: one-shot destroyed
Tank / Elite / strong enemies: take 55 damage
```

## Main files changed

```text
scripts/Main.gd
scripts/AssetPaths.gd
assets/items/item_bomb.png
```

## Notes

The implementation is intentionally kept inside the existing Story Mode bridge so the current project structure remains stable. The next refactor can move these functions into `StoryStage.gd` after this behavior is confirmed in Godot.
