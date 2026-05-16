# Step C Player Roles Implementation

This version implements the P1/P2 individuality plan up to Step C.

## Step A: Numeric differentiation

- P1 `Azure Wing`
  - fast movement
  - high shot speed
  - short shooting interval
  - small precision bullets
  - lower per-shot damage

- P2 `Solar Fang`
  - slower movement
  - lower shot speed
  - longer shooting interval
  - large heavy bullets
  - higher per-shot damage

## Step B: Personalized item effects

- `Rapid Fire`
  - P1: ultra-fast precision fire
  - P2: 3-shot burst

- `Power Boost`
  - P1: piercing laser-style shot
  - P2: giant heavy shot

- `Shield`
  - P2 gets a longer shield duration than P1

- `Link Charge`
  - Story Mode: activates Twin Core Fusion
  - Raid Mode: charges Raid Link Gauge

## Step C: Fusion role change

In Story Mode, Fusion Mode can be activated by:

- collecting `Link Charge`
- reaching 100% Co-op Link and pressing `G`, `K`, or `Space`

### Fusion controls

- P1
  - `WASD`: aim
  - `F`: fire the fusion cannon

- P2
  - Arrow keys: move the fusion ship
  - `L`: activate all-direction shield

## Important refactor note

The project currently still uses `Main.gd` as the active gameplay host.
`StoryStage.gd` is a stage wrapper that calls `Main.gd`.

Therefore, this implementation intentionally adds the player role logic into `scripts/Main.gd`
while leaving comments in `scenes/stages/StoryStage.gd` for the next migration step.

The next recommended refactor is to move these Story-specific functions from `Main.gd` into `StoryStage.gd`:

- `_update_story()`
- `_shoot()` Story branch
- `_apply_item()` Story branch
- `_activate_story_fusion()`
- `_update_story_fusion()`
- `_deactivate_story_fusion()`
