# YAMAKAGE (山影)

YAMAKAGE は、ユーザーの現在地周辺または指定された地点の地形データと太陽の軌道を掛け合わせ、山や周囲の障害物の影に隠れる **「真の日の入り・日の出時刻」** を計算・シミュレーションするアプリケーションシステムです。

登山中やアウトドアアクティビティにおいて、標準的な日没時刻よりも早く訪れる「実際の暗闇」を正確に予測し、安全な行動計画をサポートします。

## 📦 リポジトリ構成 (モノレポ)

本リポジトリは、バックエンドAPI、Webアプリフロントエンド、Garminスマートウォッチ向けアプリを内包するモノレポ構成となっています。

```text
.
├── backend/                # バックエンドAPI (BFF) & コア計算エンジン
│   ├── yamakage/           # 🌐 Cloudflare Workers API (TypeScript / Hono)
│   └── yamakage-wasm/      # ⚙️ コア計算エンジン (Rust / WebAssembly)
├── web-site/               # 💻 Webフロントエンド (React / TypeScript / Vite)
├── yamakage-datafield/     # ⌚️ Garmin Connect IQ アプリ のデータフィールド版(Monkey C)
├── yamakage-datafield/devtools/icon_generater/
│                           # 🔧 アイコン(svg)をGarminデバイスで使えるフォントファイルに変換するツール
└── docs/                   # 📄 アーキテクチャドキュメント・ADR

```

## 🚀 プロジェクトごとの役割

### 1. Backend API (`backend/`)

Cloudflare Workers 上で動作する BFF (Backend For Frontends) です。
エッジ環境でのCPU・メモリ制約をクリアするため、**TypeScriptとRust(Wasm)によるゼロコピー・ハイブリッドアーキテクチャ**を採用しています。

#### **`backend/yamakage/` (TypeScript / Hono / Effect):**
ネットワークI/Oとルーティングを担当。GarminやWebからのリクエストを受け付け、AWS Open Dataからの地形タイル(PNG)のフェッチやCloudflare R2へのキャッシュ処理を行います。
#### **`backend/yamakage-wasm/` (Rust / WebAssembly):**
純粋で高負荷な計算ロジック（画像デコード、標高抽出、地形プロファイル構築、太陽軌道のシミュレーション）を担当します。TS層から直接メモリに流し込まれたPNGバイナリを処理し、結果をフラットな配列としてTS層へ返却します。

### 2. Web Application (`web-site/`)

ブラウザ上で動作するシミュレーション用Webアプリです（Cloudflare Pagesでホスティング）。
地図上で任意の地点を指定し、周囲の地形プロファイル（各方位の最大仰角）や太陽の軌道グラフを視覚的に確認することができます。

- **スタック:** React, TypeScript, Vite
- **機能:** 地図クリックによる任意地点のシミュレーション、結果のグラフ表示（Skyline Chart）、SNSシェア機能など。

### 3. Garmin Data Field App (`yamakage-datafield/`)

Garmin製スマートウォッチ向けの Connect IQ データフィールドアプリです。
登山中やランニング中などのアクティビティ画面に組み込み、現在地の真の日没時刻をリアルタイムに表示します。

- **スタック:** Monkey C
- **機能:** GPSによるバックグラウンド位置情報取得、APIへの定期通信、超低メモリ環境に最適化されたUI描画とデータ処理。
    > ※重い計算処理をすべてバックエンドAPIにオフロードすることで、デバイスのバッテリー消費を抑えています。

### 4. Documentation (`docs/`)

システムのアーキテクチャ図や、設計上の意思決定記録をまとめています。

## 📖 開発環境のセットアップ

各プロジェクトのディレクトリに移動し、それぞれの `README.md` を参照してください。

---

## リポジトリルートコマンド
- `pnpm install`: リポジトリ全体のnode系プロジェクトの依存関係をインストールします。
- `pnpm clean`: リポジトリ全体の自動生成フォルダなど(node_modulesなど)を削除します。
