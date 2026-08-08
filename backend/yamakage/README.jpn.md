# YAMAKAGE API

## 概要

Garminアプリ向けに、山影を考慮した真の日の出・日の入り時刻を計算し提供するAPIサーバー（BFF）です。<br>
`Cloudflare Workers` 上で動作し、標高データの取得には `AWS Open Data` のパブリックデータセット を、キャッシュ機能として `Cloudflare R2` を利用しています。

## 環境構築

### 0. `pnpm`のインストール

パッケージマネージャーとして `pnpm` を使用しています。インストールしていない場合は `npm` 等経由でインストールしてください。

```sh
npm install -g pnpm

```

以下のコマンドでバージョンが表示されれば成功です。

```sh
pnpm --version

```

### 1. 依存環境の解決

`package.json` があるディレクトリ階層で以下のコマンドを実行してください。

```sh
pnpm install

```

## ローカル環境での実行・開発

### 0. 環境変数の用意

`.dev.vars.example` をコピーして `.dev.vars` を作成し、必要な環境変数を設定してください。

```sh
cp .dev.vars.example .dev.vars

```

| 変数名 | 説明 |
| --- | --- |
| `YAMAKAGE_API_KEY` | APIの認証(Bearer Token)に使用するキーです。任意の文字列を設定してください。 |
| `TURNSTILE_SECRET_KEY` |Bot検証を行うTurnstileのシークレットキーです。Turnstileウィジェットの管理画面で表示されるキーを入力します。|

### 1. バケットのセットアップ

Cloudflare R2 のバケットを作成します。以下のコマンドを実行してください。

```sh
pnpm run r2:create

```

### 2. 開発サーバーの起動

以下のコマンドを実行してローカルサーバーを起動します。

```sh
pnpm run dev
```

※APIのドキュメント（Swagger UI）をブラウザで同時に開きたい場合は、以下のコマンドを使用します。

```sh
pnpm run dev:ui

```

## 各種コマンド

| コマンド | 説明 |
| --- | --- |
| `pnpm run dev` | ローカル開発サーバーを起動します。 |
| `pnpm run dev:ui` | ローカル開発サーバーを起動し、ブラウザでSwagger UIを開きます。 |
| `pnpm run test` | Vitestを用いてテストを実行します。 |
| `pnpm run fmt` | Biomeを使用してコードのフォーマットを行います。 |
| `pnpm run lint` | Biomeを使用してコードの静的解析（Lint）を行います。 |
| `pnpm run fix` | BiomeによるLintエラーの自動修正およびフォーマットを行います。 |

## 本番環境へのデプロイ設定

Cloudflare へデプロイする際の手順です。

### 1. シークレットキーの設定

`.dev.vars` に記載した機密情報を Cloudflare の本番環境に登録します。
以下のコマンドを実行し、対話プロンプトに従って `YAMAKAGE_API_KEY` の値を入力してください。

```sh
pnpm run register:apikey

```

### 4. デプロイ

以下のコマンドで Cloudflare Workers へデプロイします。

```sh
pnpm run deploy

```