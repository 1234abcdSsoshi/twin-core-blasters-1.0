# Step 14: Online Gameplay Input Integration

この版では、Step 13までに作ったオンラインロビーと入力リレーを、実際のゲーム操作へより強く接続しました。

## 目的

オンライン中は各PCで同じ操作にします。

```text
移動：矢印キー
ショット / アクション：Space
```

## 実装内容

```text
・通常のP1/P2移動とショットは InputRouter 経由で動作
・Story Mode の合体発動をオンラインSpace入力に対応
・Fusion Siege Mode の P1照準 / P2移動 / P2爆弾をオンライン入力に対応
・Astral Court のUltimateをオンラインSpace入力に対応
・Raid Mode のTwin Core CannonをオンラインSpace入力に対応
・オンラインHUDに ARROWS + SPACE を表示
```

## コード上の考え方

Main.gd では、可能な限り次の形で入力を取得します。

```gdscript
var p1_input := _get_player_input(1)
var p2_input := _get_player_input(2)
```

これにより、ゲーム側は「ローカル入力」か「ネットワーク入力」かを意識しなくてよくなります。

## 重要

このStep 14は、オンライン入力をゲームに反映する段階です。  
まだ完全なゲーム状態同期、敵・弾・アイテムの同期保証までは行っていません。

次のStep 15では、Story / Astral / Raid のステージごとにオンライン同期を安定化します。
