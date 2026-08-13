# YAMAKAGE WebAssembly Engine

### 概要
YAMAKAGE APIのコアとなる、周囲の地形の仰角と太陽軌道の計算エンジンです。
数万ポイントに及ぶ地形データのシミュレーション処理を極限まで高速化するため、Rustで実装され`WebAssembly`にコンパイルして使用されます。

### 環境構築
Wasmモジュールの開発およびビルドを行うには、以下のツールが必要です。

1. **Rust ツールチェーン**
   [Rust公式サイト](https://www.rust-lang.org/tools/install) の手順に従い、`rustup` をインストールしてください。

2. **wasm-pack**
   WebAssemblyのビルド・パッケージングツールです。以下のコマンドでインストールします。
   ```sh
   cargo install wasm-pack

```

### コマンド

Wasmのビルド処理は、親ディレクトリ（`backend/yamakage`）の `pnpm` スクリプトから実行することを推奨しています。

#### ビルド（推奨）

親ディレクトリで以下のコマンドを実行すると、Wasmのビルドと、コミットの邪魔になる `pkg/.gitignore` の自動削除を行ってくれます。

```sh
# backend/yamakage ディレクトリで実行
pnpm run build:wasm

```

#### 手動ビルド

本ディレクトリ内で直接 `wasm-pack` を実行することも可能です（※自動生成される `pkg/.gitignore` は手動で削除してください）。

* **リリースビルド**（最適化あり・本番用）
```sh
wasm-pack build --target web

```


* **デバッグビルド**（開発用）
```sh
wasm-pack build --dev

```



#### テスト

純粋なRustの計算ロジックに対する単体テストを実行します。

```sh
cargo test

```

### 開発・運用上の注意点

**`pkg/` ディレクトリのGit管理について**:
通常、Wasmのビルド成果物である `pkg/` フォルダはGit管理外（`.gitignore`）にしますが、本プロジェクトでは CI/CD（GitHub Actions）の安定性とビルド速度向上のため、あえて `pkg/` フォルダを Git の管理下に含める運用としています。
Rustのコードを修正した際は、必ずローカルで `pnpm run build:wasm` を実行し、生成された `pkg/` の差分を一緒にコミットしてPushしてください。