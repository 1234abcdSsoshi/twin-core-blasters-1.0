# Fusion Siege Mode - Connected Pointer Patch

This version keeps the smooth connected pointer behavior from the previous combined mode while preserving the new roles:

- P1 controls the connected aim pointer with WASD.
- P1 fires the fusion cannon with F.
- P2 moves the fused ship with Arrow Keys.
- P2 places bombs with L.

## Key design change

When P2 moves the fused ship, the aim pointer moves together with the ship first.
Then P1 adjusts the pointer offset. This keeps the pointer visually connected to the main body and prevents the reticle from feeling detached.

## Fusion controls

```text
P1: WASD = move pointer
P1: F    = fire toward pointer

P2: Arrow Keys = move fused ship
P2: L          = place bomb
```

## Bomb rules

- Max bombs: 3
- Cooldown: 0.8 seconds
- Auto explosion: 3.0 seconds
- Area damage radius: 185 px
- Scout / attacker enemies are destroyed in one explosion.
- Tank / elite enemies take heavy damage but survive one explosion.
