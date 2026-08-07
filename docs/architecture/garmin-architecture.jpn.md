# Garmin App Architecture (YAMAKAGE)

本ドキュメントは、Garmin Connect IQ アプリである「YAMAKAGE」の内部アーキテクチャ、モジュール構成、およびUIのレスポンシブ描画ロジックについて定義します。

## 1. モジュール構成と依存関係

Garminの `Toybox` APIへの直接的な依存を避け、テスト容易性と保守性を高めるため、レイヤードアーキテクチャを採用しています。

```mermaid
flowchart TD
    classDef entry fill:#f87171,stroke:#b91c1c,stroke-width:2px,color:#fff
    classDef ui fill:#fbbf24,stroke:#b45309,stroke-width:2px,color:#fff
    classDef system fill:#34d399,stroke:#047857,stroke-width:2px,color:#fff
    classDef hal fill:#60a5fa,stroke:#047857,stroke-width:2px,color:#fff
    classDef core fill:#818cf8,stroke:#1d4ed8,stroke-width:2px,color:#fff
    classDef toybox fill:#e5e7eb,color:#000,stroke:#6b7280,stroke-width:2px,stroke-dasharray: 5 5

    subgraph Entrypoints ["エントリポイント"]
        App[YamakageApp]:::entry
        View[YamakageView]:::entry
        Bg[YamakageBackground]:::entry
    end

    subgraph UI ["UI Layer (source/ui)"]
        ViewLogic[ViewLogic<br/>状態から表示文字を決定]:::ui
        PosConfig[PositionConfigure<br/>セーフエリア計算]:::ui
        FontMgr[FontManager<br/>最適フォント動的計算]:::ui
        Comp[Components<br/>パーツ描画]:::ui
    end

    subgraph Systems ["Systems Layer (source/systems)"]
        LatLon[LatLonSystem<br/>GPS座標の整形]:::system
        Time[TimeSystem<br/>UnixTimeの変換]:::system
        Crypt[Crypt<br/>セッションID生成]:::system
    end

    subgraph HAL ["HAL: Hardware Abstraction (source/hal)"]
        Storage[LocalStorage<br/>プロセス間データ共有]:::hal
        Device[Device<br/>デバイス情報取得]:::hal
        Strings[Strings / Icons<br/>リソース読み込み]:::hal
    end

    subgraph Core ["Core Layer (source/core)"]
        DataArena[DataArena<br/>インメモリ状態管理]:::core
        Schema[ApiSchema<br/>データ型定義]:::core
    end

    subgraph OS ["Garmin Connect IQ"]
        Toybox[Toybox API]:::toybox
    end

    View --> UI
    Bg --> Systems
    Bg --> HAL
    UI --> Core
    UI --> HAL
    UI --> Systems
    Systems --> HAL
    HAL --> Toybox

```

### 設計思想

- **HAL (Hardware Abstraction Layer)**: Garmin標準の `Toybox` APIを直接UI層から呼ばず、HALでラップしています。これにより、OSのバージョン差異の吸収や、Mockを用いた単体テスト（シミュレータなしでのテスト）を容易にしています。
- **DataArena (Core)**: UIの描画座標や文字列など、ステートフルな情報をシングルトン的に管理する場所として `DataArena` を定義し、計算ロジックと描画ロジックを分離しています。本来は状態を変更できるクロージャを提供するような設計(React的な設計)にする方が安全ですが、関数呼び出しのオーバーヘッドをなくすため直接変更を許容しています。

---

## 2. プロセス間データフロー (Foreground / Background)

GarminのDataFieldアプリにおいて、外部通信（HTTP）はバックグラウンドプロセス（Temporal Event）でしか実行できません。
バックグラウンドで取得したAPIデータを、どのようにメインアプリ（フォアグラウンド）のUIへ渡しているかを示します。

```mermaid
sequenceDiagram
    participant OS as Garmin OS
    participant App as YamakageApp<br/>(Main Process)
    participant Storage as Application.Storage
    participant Bg as YamakageBackground<br/>(Bg Process)
    participant API as YAMAKAGE API

    App->>OS: onStart: TemporalEvent 登録 (最短5分間隔)
    
    Note over OS, Bg: --- バックグラウンド処理の発火 ---
    OS->>Bg: onTemporalEvent()
    Bg->>Storage: セッションID取得
    Bg->>API: makeWebRequest()
    API-->>Bg: 200 OK (配列データ)
    Bg->>OS: Background.exit(data)

    Note over OS, App: --- フォアグラウンドへの復帰 ---
    OS->>App: onBackgroundData(data)
    App->>Storage: 取得データを永続化 (SHADOW_DATA_KEY)
    App->>Storage: 最終同期時刻を記録
    App->>OS: WatchUi.requestUpdate() (UI再描画要求)

    Note over App, Storage: --- 描画処理 (毎秒) ---
    App->>Storage: getShadowData()
    App->>App: 残り時間のカウントダウン計算
    App->>OS: 画面描画

```

### 設計のポイント

* バックグラウンドプロセスからメインプロセスへのデータの受け渡しは、`Background.exit()` の引数として渡し、`onBackgroundData()` で受け取った後に `Application.Storage` に書き込む設計としています。
* 通信エラー時も `error` オブジェクトを渡し、Storageに記録することで、メインUIが「通信中」「更新失敗」などの状態を正しく表示できるようにしています。

---

## 3. UIレスポンシブ計算ロジック

Garminデバイスは、円形・矩形・一部が隠れるなど画面形状が多様です。YAMAKAGEでは、XMLによる固定レイアウトを使用せず、**コードベースで動的にセーフエリアとフォントを計算するロジック**を採用しています。

```mermaid
flowchart TD
    Start[onLayout: デバイス画面サイズ取得<br/>width, height] --> Flag[画面の形状とObscureフラグ取得<br/>丸型か？ どこが欠けているか？]
    
    Flag --> Safe[PositionConfigure.calculateSafeArea<br/>マージンを計算し「セーフエリア」を算出]
    
    Safe --> Compact{セーフエリアの高さ < 100px <br/> OR 幅 < 140px ?}
    
    Compact -- Yes --> ModeC[isCompactMode = true<br/>UIの比率を詰める]
    Compact -- No --> ModeN[isCompactMode = false<br/>通常比率]
    
    ModeC --> Pos[各要素のX, Y座標を算出<br/>StatusBar, EventRow, Watermark]
    ModeN --> Pos
    
    Pos --> Font[FontManager.findBestFont<br/>候補フォントを大きい順にループ]
    
    Font --> Check{ダミーテキストが<br/>算出された枠内に<br/>収まるか？}
    
    Check -- No (はみ出る) --> FontDown[1つ小さいフォントを試す]
    FontDown --> Check
    
    Check -- Yes (収まる) --> FontSet[最適なフォントを決定しキャッシュ]
    
    FontSet --> Draw[onUpdate: 決定した座標とフォントで描画]

```

### 動的計算を採用した理由

- XMLレイアウト（`layout.xml`）を用いた場合、数百あるGarminデバイスごとに微調整したレイアウト定義を用意する必要があり、メンテナンス性が悪いです。
- この動的アプローチにより、画面サイズから使用可能な最大の領域を計算し、文字がはみ出さない最大のフォントを自動で選定するため、**新機種が発売されてもコードの変更なしで自動的に最適なレイアウトが適用される**設計になっています。
