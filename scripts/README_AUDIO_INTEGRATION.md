# Twin Core Blasters - scripts with audio integration

Replace your current `scripts/` folder with this folder.

## Included files

- `Main.gd`
- `AssetPaths.gd`
- `AudioManager.gd`
- `README_AUDIO_INTEGRATION.md`

## Required audio folder

Make sure your project has:

```text
assets/audio/bgm/
assets/audio/sfx/
```

The code expects `.ogg` files such as:

```text
assets/audio/bgm/bgm_home_menu.ogg
assets/audio/bgm/bgm_story_battle.ogg
assets/audio/bgm/bgm_astral_court_duel.ogg
assets/audio/bgm/bgm_eclipse_raid_phase1.ogg
assets/audio/bgm/bgm_victory_result.ogg

assets/audio/sfx/sfx_shot_azure.ogg
assets/audio/sfx/sfx_shot_solar.ogg
assets/audio/sfx/sfx_item_pickup.ogg
assets/audio/sfx/sfx_shield_activate.ogg
...
```

## Audio behavior

- Home screen: `bgm_home_menu.ogg`
- Story Mode: `bgm_story_battle.ogg`
- Astral Court: `bgm_astral_court_duel.ogg`
- Eclipse Leviathan: `bgm_eclipse_raid_phase1.ogg`
- Victory / clear: `bgm_victory_result.ogg`
- Game over: stops BGM and plays `sfx_game_over.ogg`
- Shots, items, shield, dash, boss shots, and Twin Core Cannon play SFX.
