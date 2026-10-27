# Complication Provider API 仕様書 (V1)

本ドキュメントは、当アプリのコンプリケーション機能（バックグラウンドデータ提供機能）を利用して、Garminウォッチフェイス等（コンシューマー）を開発するためのインターフェース仕様書です。

---

## 1. データフォーマット概要

コンプリケーションの `:value` プロパティには、各要素がカンマ（`,`）で連結された **1つのCSV形式の文字列（`String`）** が格納されて配信されます。

コンシューマー側では、受け取った文字列をカンマで分割（パース）し、下記の「データスキーマ」のインデックス順序に従って各値を取得してください。

### ペイロードの例
* **正常取得時:**
  `"1,1730000000,0,1729976400,1730016000,1729990000,1730030000,0.5,0.98,125"`
* **エラー発生時（例: 通信エラー）:**
  `"1,1730000000,2,0,0,0,0,0,0,0"`

---

## 2. データスキーマ (Schema V1)

分割後の配列インデックスと、各データの型・内容は以下の通りです（要素数：`10`）。

| インデックス | フィールド名 | 型 (変換後) | 説明 | エラー時の値 |
| :--- | :--- | :--- | :--- | :--- |
| `0` | `VERSION` | `Number` | スキーマバージョン（現在は `1` 固定） | `1` |
| `1` | `TIMESTAMP` | `Number` | データ生成日時（Unixタイムスタンプ / 秒） | 実行時のUnixタイムスタンプ |
| `2` | `STATUS` | `Number` | 通信・取得ステータス（詳細は後述の「ステータスコード」を参照） | 各エラーステータス値 (`1`〜`4`) |
| `3` | `SUNRISE_TIME` | `Number` | 日の出時刻（Unixタイムスタンプ / 秒） | `0` |
| `4` | `SUNSET_TIME` | `Number` | 日の入り時刻（Unixタイムスタンプ / 秒） | `0` |
| `5` | `MOONRISE_TIME` | `Number` | 月の出時刻（Unixタイムスタンプ / 秒） | `0` |
| `6` | `MOONSET_TIME` | `Number` | 月の入り時刻（Unixタイムスタンプ / 秒） | `0` |
| `7` | `MOON_PHASE` | `Float` | 月相（`0.0` 〜 `1.0`） | `0` |
| `8` | `MOON_FRACTION` | `Float` | 月の輝面比（`0.0` 〜 `1.0`） | `0` |
| `9` | `ALTITUDE` | `Number` (or `Float`) | 標高（メートル） | `0` |

---

## 3. ステータスコードとエラー時の挙動 (`STATUS`)

インデックス `2` の `STATUS` には、データ取得の結果を示す数値が入ります。
`0`（`SUCCESS`）以外の場合は、インデックス `3`〜`9` のすべてのデータフィールドに `0` がセットされます。

| 値 | ステータス名 | 発生条件 | ウォッチフェイス側での推奨ハンドリング |
| :--- | :--- | :--- | :--- |
| `0` | `SUCCESS` | データの取得・更新に成功 | 取得した値を描画、またはキャッシュを更新して表示 |
| `1` | `NO_GPS` | デバイスでGPS位置情報が取得できない（圏外・未測位） | 「GPS未取得」アイコンの表示、または前回正常取得時のキャッシュデータを表示 |
| `2` | `NETWORK_ERROR` | スマートフォンとのBluetooth切断、またはスマホ側がオフライン | 「通信オフライン」アイコンの表示、またはキャッシュデータを表示 |
| `3` | `SERVER_ERROR` | APIサーバー側の障害、またはリクエスト不備（HTTP 400〜500番台） | 「`--:--`」等のフォールバック表示、またはキャッシュデータを表示 |
| `4` | `UNKNOWN_ERROR` | 予期せぬエラー | 「`--:--`」等のフォールバック表示。`YAMAKAGE`のリポジトリにissueを投げてください。 |

> **💡 実装のヒント（キャッシュの活用）:**
> バックグラウンド通信はユーザーの移動中などに一時的な通信エラー（`NETWORK_ERROR`）やGPSロスト（`NO_GPS`）を起こすことがあります。ウォッチフェイス側では、`STATUS == 0` のときにデータを `Storage` 等にキャッシュしておき、エラー発生時は「前回のキャッシュデータを表示しつつ、小さくエラーインジケーターを出す」といった設計にすると、ユーザー体験（UX）が向上します。

---

## 4. コンプリケーションの購読とデータ取得（WatchFace 実装例）

ウォッチフェイス側で `YAMAKAGE` のコンプリケーションを検索して購読（Subscribe）し、データが更新されるたびに値を受け取る実装例です。

Garminの仕様上、サードパーティ製アプリのコンプリケーションは `Complications.getComplications()` のイテレータを回して shortLabel 等で特定し、購読を開始します。

```monkeyc
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;
import Toybox.Graphics;

class MyWatchFaceView extends WatchUi.WatchFace {
    // YAMAKAGE のコンプリケーションが持つ shortLabel 名
    private const TARGET_SHORT_LABEL = "YAMAKAGE";

    private var _yamakageCompId as Complications.Id?;
    private var _sunriseText as String = "--:--";
    private var _sunsetText as String = "--:--";

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // 1. コンプリケーションの更新コールバックを登録
        Complications.registerComplicationChangeCallback(
            self.method(:onComplicationChanged)
        );

        // 2. YAMAKAGE のコンプリケーションを検索して購読
        _findAndSubscribeComplication();
    }

    // システム内のコンプリケーション一覧から YAMAKAGE を探して購読する
    private function _findAndSubscribeComplication() as Void {
        var iter = Complications.getComplications();
        var comp = iter.next();

        while (comp != null) {
            if (comp.shortLabel != null && comp.shortLabel.equals(TARGET_SHORT_LABEL)) {
                _yamakageCompId = comp.complicationId;
                Complications.subscribeToUpdates(_yamakageCompId);
                
                // 初回データ取得
                _fetchAndParseData(_yamakageCompId);
                break;
            }
            comp = iter.next();
        }
    }

    // バックグラウンド更新などでコンプリケーションの値が変化した際に呼ばれる
    function onComplicationChanged(compId as Complications.Id) as Void {
        if (_yamakageCompId != null && compId.equals(_yamakageCompId)) {
            _fetchAndParseData(compId);
            WatchUi.requestUpdate(); // 画面を再描画
        }
    }

    // コンプリケーションから文字列を取得してパーサーに渡す
    private function _fetchAndParseData(compId as Complications.Id) as Void {
        try {
            var comp = Complications.getComplication(compId);
            if (comp.value instanceof String) {
                var rawCsv = comp.value as String;
                
                // 5章のパーサーを呼び出してデータを抽出
                var parsed = ComplicationConsumer.parseComplicationValue(rawCsv);
                if (parsed != null && parsed[:status] == ComplicationConsumer.Status.SUCCESS) {
                    _sunriseText = parsed[:sunriseStr] as String;
                    _sunsetText = parsed[:sunsetStr] as String;
                }
            }
        } catch (e instanceof Complications.ComplicationNotFoundException) {
            // アンインストール等でコンプリケーションが見つからない場合の処理
            _yamakageCompId = null;
        }
    }

    function onHide() as Void {
        if (_yamakageCompId != null) {
            Complications.unsubscribeFromUpdates(_yamakageCompId);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            "Sunrise: " + _sunriseText + "\nSunset: " + _sunsetText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```

---

## 5. パース・変換用ユーティリティ (ComplicationConsumer)

4章の _fetchAndParseData から呼び出している、CSV文字列の分割・バージョン検証・時刻フォーマット変換を行うユーティリティモジュールです。

```monkeyc
import Toybox.Lang;
import Toybox.Complications;
import Toybox.Time;
import Toybox.Time.Gregorian;

module ComplicationConsumer {
    const EXPECTED_VERSION = 1;

    module Schema {
        enum {
            VERSION = 0,
            TIMESTAMP,
            STATUS,
            SUNRISE_TIME,
            SUNSET_TIME,
            MOONRISE_TIME,
            MOONSET_TIME,
            MOON_PHASE,
            MOON_FRACTION,
            ALTITUDE,
            DATA_SIZE
        }
    }

    module Status {
        enum {
            SUCCESS = 0,
            NO_GPS,
            NETWORK_ERROR,
            SERVER_ERROR,
            UNKNOWN_ERROR
        }
    }

    // カンマ区切りの文字列を配列に分割するヘルパー関数
    function splitCsv(str as String) as Array<String> {
        var result = [] as Array<String>;
        var current = str;
        var idx = current.find(",");

        while (idx != null) {
            result.add(current.substring(0, idx));
            current = current.substring(idx + 1, current.length());
            idx = current.find(",");
        }
        result.add(current);
        return result;
    }

    // Unixタイムスタンプ（秒）をローカル時刻の "HH:MM" 形式に変換するヘルパー関数
    function formatUnixTime(unixTimestamp as Number?) as String {
        if (unixTimestamp == null || unixTimestamp <= 0) {
            return "--:--";
        }

        var moment = new Time.Moment(unixTimestamp);
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);

        return Lang.format("$1$:$2$", [
            info.hour.format("%02d"),
            info.min.format("%02d")
        ]);
    }

    // コンプリケーションの値（String）を解析する例
    function parseComplicationValue(rawValue as String?) as Array? {
        if (rawValue == null) {
            return null;
        }

        var parts = splitCsv(rawValue);
        if (parts.size() < Schema.DATA_SIZE) {
            return null; // データ要素数不足
        }

        // 1. スキーマバージョンの確認
        var version = parts[Schema.VERSION].toNumber();
        if (version != EXPECTED_VERSION) {
            // 想定外のバージョンの場合は処理を中断（将来の破壊的変更への対策）
            return null;
        }

        // 2. ステータスの確認
        var status = parts[Schema.STATUS].toNumber();

        if (status == Status.SUCCESS) {
            return parts;
        } else {
            // TODO: status に応じたエラー表示（"--:--" やアイコン）またはキャッシュ利用
            return null;
        }
    }
}
```