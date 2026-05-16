# Step 9-12: Online Lobby / Pilot Select / Waiting Room / Start Game

このZIPでは、これまでの `F10 / F11 / F7 / F12` によるデバッグ操作に加えて、ユーザー向けのオンラインUIを追加しました。

## 追加された機能

```text
Step 9  : Online Lobby UI
Step 10 : P1 / P2 の画像カード選択
Step 11 : Waiting Room + Ready表示
Step 12 : Start Game メッセージで全クライアントがゲーム開始
```

## 使い方

### 1. サーバーを起動

```powershell
cd .\server
npm install
npm start
```

成功すると以下が表示されます。

```text
Twin Core Blasters WebSocket server listening on ws://0.0.0.0:8080
```

### 2. ゲームを起動

タイトル画面で **ONLINE LOBBY** をクリックします。

### 3. ホスト側

```text
1. Player Name を入力
2. CONNECT を押す
3. CREATE ROOM を押す
4. P1 / P2 のカードをクリックして役割を選択
5. READY を押す
6. もう1人がReadyになったら START GAME を押す
```

### 4. 参加側

```text
1. Player Name を入力
2. CONNECT を押す
3. Room Code にホストのルームコードを入力
4. JOIN ROOM を押す
5. 空いているP1 / P2カードをクリック
6. READY を押す
```

## 操作

オンラインゲーム中は、各PCで同じキーを使います。

```text
矢印キー : 移動 / 照準
Space    : ショット / アクション
```

合体後の役割は以下です。

```text
P1 : ポインター操作 + Fusion Cannon
P2 : 合体機体移動 + Bomb設置
```

## 変更ファイル

```text
scripts/Main.gd
scripts/ui/OnlineLobbyController.gd
scripts/network/NetworkClient.gd
scripts/network/NetworkMessages.gd
server/server.js
README_ONLINE_INPUT_STEP12_LOBBY_UI.md
```

## 注意

この段階では、オンライン入力リレーと開始フローの土台を作っています。敵・弾・アイテムなどの完全なゲーム状態同期は、次のステップでステージ別に強化します。
