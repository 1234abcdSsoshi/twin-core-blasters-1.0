# Stage Loader Step

This ZIP is the next safe refactor step.

## What changed

The current project now has a `StageRoot` node in `scenes/Main.tscn` and stage controller scripts under:

```text
res://scenes/stages/
├── StageBase.gd
├── StoryStage.gd
├── AstralCourtStage.gd
└── RaidStage.gd
```

## Important

This step does **not** fully move the gameplay code out of `Main.gd` yet.

Instead, each stage file is a thin controller:

```text
StoryStage.gd        -> calls Main.gd _start_story() / _update_story(delta)
AstralCourtStage.gd  -> calls Main.gd _start_astral_court() / _update_astral_court(delta)
RaidStage.gd         -> calls Main.gd _start_raid() / _update_raid(delta)
```

This keeps the game behavior close to the current version while confirming that stage loading works.

## How to test

Open the project in Godot and run `scenes/Main.tscn`.

On the title screen:

```text
1 / Enter / Space : Story Mode
2                 : Astral Court
3                 : Eclipse Leviathan Raid
```

You should also see debug messages in the Godot Output panel:

```text
[StageBase] setup: Story Mode
[StoryStage] start
```

or similar messages for the other modes.

## Backup

The previous `Main.gd` is kept here:

```text
res://scripts/backups/Main_before_stage_loader_step.gd
```

## Next step

The recommended next step is to move only Story Mode logic into `StoryStage.gd`, starting with:

```text
base_hp
core_shield_time
enemy_spawn_timer
item_spawn_timer
_create_players()
_spawn_enemy()
_spawn_item()
_update_story(delta)
```

Do not move Astral Court and Raid logic at the same time. Move one stage at a time.
