# YAMAKAGE (Garmin Connect IQ App)

## 概要

Garminデバイス（Edge, Fenix, Forerunnerなど）向けに、周囲の地形（標高）を考慮した「本当の日の出・日の入り時刻」を表示するWatchApp(DeviceApp)です。

専用のバックエンドサーバー（YAMAKAGE API）と通信を行い、現在地から周囲の山や障害物の高さを計算して、正確な日照時間を予測します。

## 事前準備（Garmin SDKのセットアップ）

開発を始める前に、Garmin Connect IQの公式開発環境を準備する必要があります。

### 1. Connect IQ SDK Managerのインストール

Garminの[開発者サイト](https://developer.garmin.com/connect-iq/overview/)から「Connect IQ SDK Manager」をダウンロードしてインストールし、最新のSDKをダウンロードしてください。

### 2. デベロッパーキーの作成

アプリをビルド・署名するための秘密鍵（`.der` ファイル）を作成します。
ターミナルを開き、SDKの `bin` ディレクトリにある `monkeyc` コマンドを使って鍵を生成します。

```sh
# 鍵の生成コマンド例（自身の環境のbinパスに読み替えてください）
/path/to/connectiq-sdk/bin/monkeyc -a developer_key.der

```

作成した `developer_key.der` は、プロジェクトのルートディレクトリ等に配置してください（※ `.gitignore` で除外されているためGitにはコミットされません）。

---

## 環境構築

### 1. `pnpm` のインストール

パッケージマネージャーおよびスクリプトランナーとして `pnpm` を使用しています。

```sh
npm install -g pnpm

```

### 2. 依存環境の解決

`package.json` があるディレクトリ階層で以下のコマンドを実行し、コードフォーマッター（Prettier）などの開発ツールをインストールします。

```sh
pnpm install

```

### 3. 環境変数の用意

プロジェクトルートにある `.env.example` をコピーして `.env` を作成し、必要な環境変数を設定してください。

```sh
cp .env.example .env

```

`.env` ファイルには以下の内容をご自身の環境に合わせて入力してください。

| 変数名 | 説明 | 設定例 (Windows) | 設定例 (Mac) |
| --- | --- | --- | --- |
| `GARMIN_DEVICE` | シミュレーターで起動・テストする対象のデバイスID | `edge1040` | `edge1040` |
| `GARMIN_KEY_PATH` | 作成したデベロッパーキーの絶対（または相対）パス | `C:\keys\developer_key.der` | `/Users/name/keys/developer_key.der` |
| `GARMIN_SDK_BIN` | ダウンロードしたGarmin SDKの `bin` フォルダの絶対パス | `C:\Users\name\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-X.Y.Z\bin` | `/Users/name/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-X.Y.Z/bin` |

---

## ローカル環境での実行・開発

### 1. シミュレーターの起動

以下のコマンドを実行すると、自動的にコードがビルドされ、設定した `GARMIN_DEVICE` のシミュレーターが起動します。

```sh
pnpm run dev

```

---

## 各種コマンド

| コマンド | 説明 |
| --- | --- |
| `pnpm run dev` | デバッグビルドを実行し、シミュレーターを起動します。 |
| `pnpm run dev:release` | リリースビルド（最適化あり）でシミュレーターを起動します。 |
| `pnpm run test` | 単体テストをビルドし、シミュレーター上でテストを実行します。 |
| `pnpm run fmt` | Prettier (monkeycプラグイン) を使用してコードのフォーマットを行います。 |
| `pnpm run export` | Connect IQストアへの申請用ファイル（`.iq`）をエクスポートします。 |

---

## ストア公開用ファイルの作成

Connect IQストアにアプリを申請するための `.iq` ファイルを出力する手順です。
以下のコマンドを実行してください。

```sh
pnpm run export

```

処理が完了すると、プロジェクトの `bin` ディレクトリ内に `yamakage-watch-app.iq` というファイルが生成されます。

このファイルを [Garmin Developer Dashboard](https://www.google.com/search?q=https://developer.garmin.com/connect-iq/overview/) からアップロードすることで、ストアへの公開申請が完了します。

---

## ライセンス

本プロジェクトは [MIT License](https://www.google.com/search?q=./LICENSE) のもとで公開されています。