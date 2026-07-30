# Mac Studio リモートアクセス構成

MacBook Air から Mac Studio の画面共有へ、SSH ポートフォワードを使わずに接続するための復旧手順です。

## 接続名

| 接続先 | 経路 | 用途 |
| --- | --- | --- |
| `vnc://studio-ts` | Tailscale | 通常利用 |
| `vnc://studio-cf` | Cloudflare Tunnel | Tailscale が使えない場合の予備経路 |

`studio-ts` は Mac Studio の Tailscale IPv4 アドレス、`studio-cf` は MacBook Air の `127.0.0.2` を参照します。Cloudflare 側は MacBook Air 上の `cloudflared access tcp` が `127.0.0.2:5900` を Mac Studio の VNC へ中継します。

## リポジトリへ保存しない情報

- Tailscale IP アドレス
- Cloudflare Tunnel UUID
- `~/.cloudflared/*.json`
- `~/.cloudflared/cert.pem`
- Access token
- Cloudflare や Tailscale の認証情報

この文書とテンプレートでは、実際の Cloudflare 公開ホスト名を `VNC_HOSTNAME`、Tunnel UUID を `TUNNEL_UUID` と表記します。

## Mac Studio

### 1. 基本環境

dotfiles のセットアップを実行します。`.Brewfile.shared` から `cloudflared`、`.Brewfile.darwin` から Tailscale アプリが導入されます。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

Tailscale にログインし、MagicDNS 上のマシン名が `mymacstudio` になっていることを確認します。Tailscale IPv4 アドレスは次のコマンドで取得します。

```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4
```

### 2. 画面共有

システム設定の「一般」から「共有」を開き、「画面共有」を有効にします。TCP 5900 の VNC 応答を確認します。

```bash
/usr/bin/nc -G 15 127.0.0.1 5900
```

成功時は `RFB 003.889` のような応答が返ります。

### 3. Cloudflare Tunnel

Cloudflare の OAuth セッションでログインし、VNC 専用 Tunnel を作成します。

```bash
cloudflared tunnel login
cloudflared tunnel create mac-studio-vnc
```

`~/.cloudflared/mac-studio-vnc.yml` を次の形で作成します。

```yaml
tunnel: TUNNEL_UUID
credentials-file: /Users/username/.cloudflared/TUNNEL_UUID.json

ingress:
  - hostname: VNC_HOSTNAME
    service: tcp://127.0.0.1:5900
  - service: http_status:404
```

設定を検証し、DNS を Tunnel へ割り当てます。

```bash
cloudflared tunnel --config /Users/username/.cloudflared/mac-studio-vnc.yml ingress validate
cloudflared tunnel --config /Users/username/.cloudflared/mac-studio-vnc.yml route dns --overwrite-dns TUNNEL_UUID VNC_HOSTNAME
```

Cloudflare Zero Trust Access では、`VNC_HOSTNAME` を対象とする Self-hosted application と認証ポリシーを設定します。

`docs/templates/com.cloudflare.mac-studio-vnc.plist` を `~/Library/LaunchAgents/com.cloudflare.mac-studio-vnc.plist` へ配置し、起動します。

```bash
launchctl bootstrap "gui/$(id -u)" /Users/username/Library/LaunchAgents/com.cloudflare.mac-studio-vnc.plist
launchctl print "gui/$(id -u)/com.cloudflare.mac-studio-vnc"
```

この構成は LaunchAgent のため、Cloudflare Tunnel は Mac Studio のユーザーがログインした後に起動します。

## MacBook Air

### 1. 接続名

Mac Studio で取得した Tailscale IPv4 アドレスを使い、`/etc/hosts` に次の 2 行を追加します。旧 `studio` エントリは削除します。

```text
TAILSCALE_IPV4 studio-ts
127.0.0.2 studio-cf
```

`.ssh/config` に VNC 用の `LocalForward` は設定しません。

### 2. Cloudflare クライアント

`docs/templates/com.cloudflare.vnc-studio-cf.plist` を `~/Library/LaunchAgents/com.cloudflare.vnc-studio-cf.plist` へ配置し、`VNC_HOSTNAME` を実際の公開ホスト名へ置き換えます。

```bash
launchctl bootstrap "gui/$(id -u)" /Users/username/Library/LaunchAgents/com.cloudflare.vnc-studio-cf.plist
launchctl print "gui/$(id -u)/com.cloudflare.vnc-studio-cf"
```

## 動作確認

MacBook Air で両方の VNC 応答を確認します。

```bash
/usr/bin/nc -G 15 studio-ts 5900
/usr/bin/nc -G 15 studio-cf 5900
```

両方から `RFB 003.889` のような応答が返れば、画面共有から次の URL を使用できます。

```text
vnc://studio-ts
vnc://studio-cf
```

## Mac Studio 買い替え時

1. 新しい Mac Studio で dotfiles、Tailscale、画面共有を設定する
2. 新しい Cloudflare Tunnel を作成する
3. 同じ `VNC_HOSTNAME` の DNS を新しい Tunnel へ上書きする
4. MacBook Air の `studio-ts` を新しい Tailscale IPv4 アドレスへ更新する
5. `studio-ts` と `studio-cf` の両方で VNC 応答を確認する
6. 接続確認後に古い Mac Studio の Tunnel と Tailscale デバイスを廃止する

新旧 Mac Studio 間で Tunnel credential をコピーせず、新しい Tunnel を作成して DNS を切り替えます。MacBook Air の Cloudflare LaunchAgent は公開ホスト名が同じなら変更不要です。
