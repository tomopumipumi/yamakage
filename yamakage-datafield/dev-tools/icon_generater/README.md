# Garmin Font File Generator

## Overview

This tool converts SVG files into font files that can be used within Garmin devices.<br>
Since standard font formats (.ttf or .otf) cannot be used, it generates bitmap fonts (.fnt).

## Environment Setup

### 0. Install `pdm`
Please install `pdm` using `pipx` or a similar tool.

```sh
pipx install pdm

```

If the following command runs without errors, the installation is successful.

```sh
pdm --version

```

### 1. Resolve Dependencies

Run the following command in the same directory as `pyproject.toml`.

```sh
pdm install

```

## Execution

### 0. Prepare SVG files

Place your SVG files in the `src/resources/svgs` directory.

### 1. Run the command

Execute the following command to generate the font files.

```sh
pdm run build-icon

```

### Configuration

You can change the settings in `src/config.py`.

| Variable Name | Data Type | Description |
| --- | --- | --- |
| input_dir | pathlib.Path | Directory path where the SVG files are located. |
| output_dir | pathlib.Path | Directory path to output the built font files (will be created if it does not exist). |
| icon_sizes | tuple[int, ...] | Specifies the pixel sizes of the fonts. Font files will be created for each specified size. |
| base_font_name | str | Specifies the base name for the generated fonts. |
| start_char_id | int | Specifies the starting character code (Unicode) assigned to the icons. They will be incremented and assigned sequentially. |

## Generated Files

| File Name | Description |
| --- | --- |
| fonts.xml | Defines the font files and the IDs used within `Monkey C`. |
| IconMapping.mc | Constants for the character codes assigned to each font. |
| mapping.json | Mapping between character codes/characters and the actual displayed fonts. Not used in the `Monkey C` project. |
| [font_name]_[number].fnt | The font file. The number corresponds to the values specified in `icon_sizes`. |
| [font_name]_[number].png | The atlas image of the font. Used together with the font file. |

## How to Use the Generated Font Files

### Placement

Place the following files directly into the `resources/fonts` folder of your Garmin project:

* fonts.xml
* [font_name]_[number].fnt
* [font_name]_[number].png

Place the following file directly into the `source/ui` folder of your Garmin project:

* IconMapping.mc

### Usage

In this example, the file `YamakageIcons_40.fnt` is associated with the ID `IconFont40`.




**fonts.xml**

```xml
<resources>
    <font id="IconFont40" filename="YamakageIcons_40.fnt" />
</resources>

```

The image that originally existed as the `connecting.svg` file can be called with the character `A`.




**IconMapping.mc**

```monkeyc
module Ui {
    module Icons {
        const ICON_CONNECTING = "A";
    }
}

```

Use it as follows:

```monkeyc
import Toybox.WatchUi;
import Toybox.Graphics;

class MyWatchView extends WatchUi.View {
    var iconFont;

    function onLayout(dc) {
        // 1. Load the font using the ID defined in fonts.xml (e.g., IconFont40)
        // * Since loading every frame is resource-intensive, load it only once in onLayout
        iconFont = WatchUi.loadResource(Rez.Fonts.IconFont40);
    }

    function onUpdate(dc) {
        // Basic processing like clearing the screen
        View.onUpdate(dc);

        // 2. Set the icon color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // 3. Draw the icon using drawText
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            iconFont,
            Ui.Icons.ICON_CONNECTING, // Specify the constant generated in IconMapping.mc
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
```