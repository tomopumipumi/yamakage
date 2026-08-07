# ドメインアーキテクチャ図


```mermaid
flowchart TD
    classDef engine fill:#e0e7ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    classDef data fill:#f3f4f6,stroke:#6b7280,stroke-width:1px,stroke-dasharray: 5 5
    classDef external fill:#fce7f3,stroke:#db2777,stroke-width:2px,color:#be185d

    Start((計算開始<br/>緯度,経度,時刻))

    subgraph Phase1 [1. 空間サンプリング]
        TSE[TerrainSamplingEngine]:::engine
        Note1(近距離は細かく、遠距離は粗く<br/>最大20kmまで15度刻みで放射状にサンプリング座標を生成)
        TSE -.- Note1
    end

    Repo[ElevationRepository<br/>標高データ取得]:::external

    subgraph Phase2 [2. 地形プロファイル構築]
        TPE[TerrainProfileEngine]:::engine
        Note2(地球の曲率を考慮し<br/>各方位の「最大障害物仰角」を算出)
        TPE -.- Note2
    end

    subgraph Phase3 [3. 太陽軌道と山影の交差シミュレーション]
        SCE[ShadowCalculationEngine]:::engine
        SPE[SunPositionEngine]:::engine
        Note3(時間を1分ずつ進めながら<br/>太陽の高度と、補間した地形仰角の<br/>逆転タイミングを検出)
        
        SCE --> |分単位の時刻| SPE
        SPE --> |太陽の方位角・高度| SCE
        SCE -.- Note3
    end

    End((真の日没・日の出時刻))

    Start --> |Start Lat/Lng| TSE
    TSE --> |Panorama<br/>座標リスト| Repo
    
    TSE --> |Panorama<br/>座標リスト| TPE
    Repo --> |ElevationsMap<br/>標高マップ| TPE
    
    TPE --> |AzimuthProfiles<br/>方位角ごとの最大仰角| SCE
    Start --> |緯度,経度,時刻| SCE
    
    SCE --> End
```


### サンプリング間隔の最適化 (TerrainSamplingEngine)

計算量を抑えつつ近景の精度を上げるため、距離に応じてサンプリング間隔を動的に変更しています。

- 0〜500m: 100m間隔

- 500〜2km: 300m間隔

- 2km〜10km: 2000m間隔

- 10km〜20km: 5000m間隔


### 地球の曲率と大気差の考慮 (TerrainProfileEngine)

遠くの山ほど地球の丸みで沈んで見えるため、単純な標高差ではなく (距離^2 / 2R) * 0.86 （※0.86は大気差などを考慮した係数）を用いて、
見かけの標高低下を補正した上で仰角を計算しています。


### 分単位のシミュレーション (ShadowCalculationEngine)

数式で一発で交点を出すのは困難なため、指定時刻から最大48時間（2880分）先まで1分ずつ時間を進めるシミュレーションアプローチを採用しています。

各分ごとに SunPositionEngine (SunCalcのラッパー) で太陽位置を出し、地形プロファイル（15度刻み）を線形補間（getInterpolatedObstacleAngle）して、太陽高度が地形仰角を下回った（上回った）瞬間を答えとしています。