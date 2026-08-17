# ガーミン用フォントファイル生成ツール

## 概要

svgファイルをガーミン内で使えるフォントファイルに変換して生成します。<br>
ファイル形式は一般的なフォントファイル(.ttfや.otf)は使えないため、ビットマップフォント(.fnt)となります。

## 環境構築
### 0. `pdm`のインストール
pipxなどで`pdm`をインストールしてください。

```sh
pipx install pdm
```

以下のコマンドでエラーが出なければ成功です。

```sh
pdm --version
```

### 1. 依存環境の解決
`pyproject.toml`と同じ階層で以下のコマンドを実行してください。

```sh
pdm install
```

## 実行
### 0. svgファイルを用意
`src/resources/svgs`内にsvgファイルを配置。

### 1. コマンド実行
以下のコマンドを実行してフォントファイルを生成してください。
```sh
pdm run build-icon
```

### 各種設定
`src/config.py`の内容を変更してください。

|変数名|データ型|説明|
|:---|:---|:---|
|input_dir|pathlib.Path|svgファイルを配置しているフォルダパス|
|output_dir|pathlib.Path|ビルドしたフォントファイルを出力するフォルダパス(ない場合は作成される)|
|icon_sizes|tuple[int, ...]|フォントのピクセル数を指定する。指定した数だけフォントファイルが作成される|
|base_font_name|str|生成されるフォントのベースとなるフォント名を指定|
|start_char_id|int|アイコンに割り当てる最初の文字コード(Unicode)を指定。icon_sizesに指定した順に繰り上げて割り当てられる。|

## 生成物

|ファイル名|説明|
|:---|:---|
|fonts.xml|フォントファイルと`Monkey C`内で指定するIdを定義する|
|IconMapping.mc|各フォントに割り当てられた文字コードの定数|
|mapping.json|文字コード・文字と実際に表示されるフォントとの対応。`Monkey C`プロジェクト内では使わない。|
|フォント名_数字.fnt|フォントファイル。数字は`icon_sizes`で指定した数字がつけられる。|
|フォント名_数字.png|フォントのアトラス画像。フォントファイルとセットで使われる。|


## 生成されたフォントファイルの使い方
### 配置
ガーミンプロジェクト内の`resources/fonts`フォルダ直下に以下のファイルを配置してください。
- fonts.xml
- フォント名_数字.fnt
- フォント名_数字.png

ガーミンプロジェクト内の`source/ui`フォルダ直下に以下のファイルを配置してください。
- IconMapping.mc

### 使い方

`YamakageIcons_40.fnt`というファイルがid`IconFont40`と紐づいている状況です。<br>
**fonts.xml**
```xml
<resources>
    <font id="IconFont40" filename="YamakageIcons_40.fnt" />
</resources>
```

元々`connecting.svg`というファイルで存在していた画像が`A`という文字で呼び出せます。<br>
**IconMapping.mc**
```monkeyc
module Ui {
    module Icons {
        const ICON_CONNECTING = "A";
    }
}
```

以下のように使用します。
```monkeyc
import Toybox.WatchUi;
import Toybox.Graphics;

class MyWatchView extends WatchUi.View {
    var iconFont;

    function onLayout(dc) {
        // 1. fonts.xml で定義された ID (例: IconFont40) を使ってフォントをロード
        // ※ 毎フレームロードすると重いため、onLayout で一度だけロードします
        iconFont = WatchUi.loadResource(Rez.Fonts.IconFont40);
    }

    function onUpdate(dc) {
        // 画面のクリアなどの基本処理
        View.onUpdate(dc);

        // 2. アイコンの色を指定
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // 3. drawText を使ってアイコンを描画
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            iconFont,
            Ui.Icons.ICON_CONNECTING, // IconMapping.mc で生成された定数を指定
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```