# Step12 UI Layer Fix

この版では、ONLINE LOBBY を開いたときに `TWIN CORE BLASTERS` のタイトルUIが前面に残り、ルーム番号入力画面を操作できない問題を修正しました。

## 修正内容

- `OnlineLobbyController.layer = 80` に設定
- Online Lobby表示中は `title_layer.visible = false`
- Online Lobbyを閉じたときはタイトル画面を再表示
- 日本語コメントを追加

## 変更ファイル

```text
scripts/Main.gd
scripts/ui/OnlineLobbyController.gd
README_STEP12_UI_LAYER_FIX.md
```
