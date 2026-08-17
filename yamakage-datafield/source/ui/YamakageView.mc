import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Ui.FontManager;
import Ui.ViewLogic;
import Ui.ConnectionLabelSet;
import Ui.Components;
import Ui.PositionConfigure;
import Hal.Strings;
import Hal.Strings.Icons;
import Core.DataArena.UiArena;
import Core.DataArena.UiArena.ContentsPositionArena;
import Core.DataArena.UiArena.ContentsPositionArena.EventRowArena;

class YamakageView extends WatchUi.DataField {
    private var _fontSets as FontManager.FontSetType?;
    private var _connLabelSets as Ui.ConnectionLabelSetType;

    private var _iconFonts as Array<Graphics.FontType>?;

    private var _waterMark as String = "";

    function initialize() {
        DataField.initialize();

        _waterMark = Strings.getAppTitle();

        _connLabelSets = [
            Strings.getCommunicatingLabel(),
            Strings.getUpdateFailedLabel(),
            Strings.getUpdatingLabel()
        ];
    }

    function compute(info as Activity.Info) as Void {
        ViewLogic.update(_connLabelSets);
    }

    function onLayout(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        var obscurityFlags = getObscurityFlags();

        PositionConfigure.calculateSafeArea(width, height, obscurityFlags);
        PositionConfigure.setStatusBarPosition();
        PositionConfigure.setEventRowPosition();
        PositionConfigure.setWatermark();

        _fontSets = FontManager.calculateFonts(
            dc,
            _iconFonts != null ? _iconFonts : Icons.getIconFonts()
        );
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var fontSets = _fontSets as FontManager.FontSetType;

        var drawSunrise = Ui.Icons.ICON_SUNRISE;
        var drawSunset = Ui.Icons.ICON_SUNSET;

        var bgColor = getBackgroundColor();
        var fgColor =
            bgColor == Graphics.COLOR_BLACK
                ? Graphics.COLOR_WHITE
                : Graphics.COLOR_BLACK;
        var subColor =
            bgColor == Graphics.COLOR_BLACK
                ? Graphics.COLOR_LT_GRAY
                : Graphics.COLOR_DK_GRAY;

        var sunriseColor = fgColor;
        var sunsetColor = fgColor;

        if (
            !UiArena.isFailed &&
            (UiArena.currentSunrise > 0 || UiArena.currentSunset > 0)
        ) {
            if (UiArena.currentSunrise < UiArena.currentSunset) {
                sunriseColor =
                    UiArena.currentSunrise <= 15
                        ? Graphics.COLOR_GREEN
                        : UiArena.currentSunrise <= 30
                          ? Graphics.COLOR_YELLOW
                          : Graphics.COLOR_BLUE;
            } else {
                sunsetColor =
                    UiArena.currentSunset <= 15
                        ? Graphics.COLOR_RED
                        : UiArena.currentSunset <= 30
                          ? Graphics.COLOR_YELLOW
                          : Graphics.COLOR_GREEN;
            }
        }

        dc.setColor(bgColor, bgColor);
        dc.clear();

        Components.drawStatusBar(
            dc,
            UiArena.syncStatus,
            UiArena.isFailed,
            subColor,
            fontSets[FontManager.FontSet.STATUS_FONT],
            fontSets[FontManager.FontSet.STATUS_ICON_FONT]
        );

        Components.drawEventRow(
            dc,
            EventRowArena.sunrizeY,
            drawSunrise,
            UiArena.sunriseTime,
            Graphics.COLOR_YELLOW,
            sunriseColor,
            subColor,
            fontSets[FontManager.FontSet.EVENT_TIME_FONT],
            fontSets[FontManager.FontSet.EVENT_ICON_FONT]
        );

        Components.drawEventRow(
            dc,
            EventRowArena.sunsetY,
            drawSunset,
            UiArena.sunsetTime,
            Graphics.COLOR_PURPLE,
            sunsetColor,
            subColor,
            fontSets[FontManager.FontSet.EVENT_TIME_FONT],
            fontSets[FontManager.FontSet.EVENT_ICON_FONT]
        );

        if (
            !ContentsPositionArena.isCompactMode &&
            PositionConfigure.safeHeight >= 130
        ) {
            Components.drawWatermark(
                dc,
                _waterMark,
                subColor,
                fontSets[FontManager.FontSet.WATERMARK_FONT]
            );
        }
    }
}
