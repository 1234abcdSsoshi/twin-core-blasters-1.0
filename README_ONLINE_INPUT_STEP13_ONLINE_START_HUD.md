# Step 13: Online Start Transition + Online Status HUD

この版では、Step 12 のオンラインロビーをさらに進めて、`START GAME` 後の体験を整理しています。

## 追加内容

```text
・START GAME受信後にロビーUIを自動で非表示
・タイトル画面、説明画面、リザルト画面を非表示にしてゲームへ移行
・サーバーから割り当てられたP1/P2役割をInputRouterへ固定
・オンラインゲーム中専用のHUDを右上に表示
・HUDに Room / 自分の役割 / I/O送受信数を表示
・ESCまたはHUD内のLOBBYボタンでロビーに戻れる
```

## 確認方法

1. `server` フォルダでサーバーを起動します。

```powershell
cd .\server
npm install
npm start
```

2. Godotゲームを起動します。
3. `ONLINE LOBBY` を開きます。
4. 名前入力 → `CONNECT` → `CREATE ROOM`。
5. P1/P2カードを選択し、`READY`。
6. もう一方のプレイヤーもReadyになった想定で `START GAME` を押します。

> 本来は2クライアントでP1/P2が両方Readyになる必要があります。
> 1台PCだけの場合は、ロビー遷移とHUD表示を中心に確認してください。

## 操作

```text
ESC：オンラインゲーム中にロビーへ戻る
LOBBYボタン：オンラインゲーム中にロビーへ戻る
```

## 実装メモ

主要コードには日本語コメントを追加しています。

```text
scripts/Main.gd
```

主な追加関数：

```text
_start_online_game(stage_name)
_return_to_online_lobby()
_setup_online_status_hud()
_show_online_status_hud(enabled)
_update_online_status_hud()
```
