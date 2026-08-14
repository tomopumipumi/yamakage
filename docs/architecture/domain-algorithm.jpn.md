TypeScriptベースの計算ロジックがWebAssembly（Rust）に移植された現在のアーキテクチャに合わせて、ドメインアーキテクチャ図と説明文をアップデートしました。

計算負荷の高い空間サンプリングとシミュレーションを **Wasm（Rust）** に寄せ、I/Oが伴う標高データの取得を **TypeScript（Effect）** が担当してWasmのメモリ空間に直接データを注入する、ハイブリッドな構成を明確に表現しています。

---

# ドメインアーキテクチャ図

## 1. バックエンド計算アルゴリズム (TypeScript + WebAssembly)

```mermaid
flowchart TD
    classDef wasm fill:#e0e7ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    classDef ts fill:#fef08a,stroke:#c2165b,stroke-width:2px,color:#831843
    classDef data fill:#f3f4f6,color:#000,stroke:#6b7280,stroke-width:1px,stroke-dasharray: 5 5
    classDef external fill:#fce7f3,stroke:#db2777,stroke-width:2px,color:#be185d

    Start((計算開始<br/>緯度,経度,時刻))

    subgraph Phase1 [1. 空間サンプリング]
        TSE[generate_sampling_points<br/>Wasm / Rust]:::wasm
        Note1(近傍ノイズを防ぐため100m先から開始。<br/>Quality設定に応じて最大30kmまで放射状に生成)
        TPE_MEM[(Wasm Memory)]:::data
        TSE -.- Note1
    end

    subgraph Phase2 [2. 標高データ取得・注入]
        UseCase[CalculateShadowUseCase<br/>TypeScript]:::ts
        Repo[TileElevationRepository<br/>標高データ取得]:::external
        Note2(TS側で座標に対応するタイルを取得・デコードし、<br/>Wasmのメモリ空間に直接標高値を書き込む)
        UseCase -.- Note2
    end

    subgraph Phase3 [3. 地形プロファイル構築]
        TPE[calculate_azimuth_profiles<br/>Wasm / Rust]:::wasm
        Note3(地球の曲率と大気差を考慮し<br/>各方位の「最大障害物仰角」を算出)
        TPE -.- Note3
    end

    subgraph Phase4 [4. 太陽軌道と山影の交差シミュレーション]
        SCE[simulate_sun_path<br/>Wasm / Rust]:::wasm
        SPE[get_sun_position<br/>Wasm / Rust]:::wasm
        Note4(過去12時間から未来48時間まで1分ずつ進め<br/>太陽の上端高度と地形仰角の逆転タイミングを検出)
        
        SCE --> |分単位の時刻| SPE
        SPE --> |太陽の方位角・高度| SCE
        SCE -.- Note4
    end

    End((真の日没・日の出時刻<br/>+ 現在地・最高地点の標高))

    Start --> |Start Lat/Lng| TSE
    TSE --> |Panorama座標リスト| TPE_MEM
    TPE_MEM --> |Lats/Lngs| UseCase
    UseCase --> |座標リスト| Repo
    Repo --> |ElevationsMap| UseCase
    UseCase --> |標高データを注入| TPE_MEM
    
    TPE_MEM --> |緯度/経度/標高| TPE
    TPE --> |AzimuthProfiles<br/>方位角ごとの最大仰角| SCE
    Start --> |緯度,経度,時刻| SCE
    
    SCE --> End


```

### TypeScriptとWasmのメモリ共有アーキテクチャ

パフォーマンスのボトルネックとなる計算処理をRust(Wasm)化しつつ、非同期I/O通信が必要な標高タイルの取得をTypeScript側で担っています。TypeScript側で取得した大量の標高データをWasmのメモリ空間へ直接書き込むことで、シリアライズ/デシリアライズのオーバーヘッドをゼロに抑えています。

### サンプリング間隔の最適化

計算量を抑えつつ近景の精度を上げ、かつ足元のノイズを誤検知しないよう、距離に応じてサンプリング間隔を動的に変更しています（Quality2の場合）。

* 100〜2000m: 30m間隔
* 2.1km〜10km: 90m間隔
* 10.2km〜30km: 200m間隔

### 地球の曲率と大気差の考慮 (TerrainProfileEngine)

遠くの山ほど地球の丸みで沈んで見えるため、単純な標高差ではなく `(距離^2 / 2R) * 0.86` （※0.86は大気差などを考慮した係数）を用いて見かけの標高低下を補正しています。また、ユーザーの視界を正確にシミュレーションするため、現在地の標高に `1.5m`（目の高さ）を加算した上で仰角を計算しています。

### 分単位のシミュレーション (ShadowCalculationEngine)

数式で一発で交点を出すのは困難なため、指定時刻の **過去12時間前から未来48時間先（-720〜2880分）** まで1分ずつ時間を進めるシミュレーションアプローチを採用しています。各分ごとに太陽位置を計算し、地形プロファイル（方位角ごとの最大仰角）を線形補間して、太陽高度が地形仰角を下回った/上回った瞬間を日没/日の出としています。さらに太陽の視半径（約0.266度）を加味し、太陽の上端が隠れる/現れる瞬間を正確に判定します。
