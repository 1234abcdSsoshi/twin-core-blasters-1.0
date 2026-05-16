# Step 8: UI / Audio / Autoload整理

このZIPでは、既存のゲーム動作を壊さないことを優先しながら、Step 8 の土台を追加しています。

## 変更内容

- `AudioManager.gd` を Autoload として登録
- `Main.gd` は `/root/AudioManager` を優先して使用
- BGM とシールド音の手動ループ処理を追加
- タイトル画面にマウス操作可能なステージ選択ボタンを追加
- ステージ選択後に説明パネルを表示
- 結果画面に `RETRY` / `HOME` ボタンを追加
- 将来的なUI分離用に `scenes/ui/*.gd` を追加

## 操作

- マウスで `STORY MODE` / `ASTRAL COURT` / `ECLIPSE RAID` を選択
- 説明パネルで `START` を押して開始
- `BACK` でステージ選択へ戻る
- 結果画面では `RETRY` / `HOME` をクリック
- 従来通り、`1 / 2 / 3` と `R` キーも使用可能

## 注意

今回のStep 8では、UIを完全な `.tscn` シーンにはまだ移していません。  
安全性を優先し、まずは `Main.gd` にマウスUIを追加し、次の段階で `TitleMenu.tscn` / `InstructionScreen.tscn` / `ResultScreen.tscn` に切り出せる状態にしています。
