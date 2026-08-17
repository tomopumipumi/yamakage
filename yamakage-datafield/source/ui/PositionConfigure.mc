import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;
import Core.DataArena.UiArena.ContentsPositionArena;
import Core.DataArena.UiArena.ContentsPositionArena.StatusBarArena;
import Core.DataArena.UiArena.ContentsPositionArena.EventRowArena;
import Core.DataArena.UiArena.ContentsPositionArena.WatermarkArena;

module Ui {
    module PositionConfigure {
        var safeX as Number = 0;
        var safeY as Number = 0;
        var safeWidth as Number = 0;
        var safeHeight as Number = 0;

        var contentX as Number = 0;
        var contentWidth as Number = 0;

        function calculateSafeArea(
            width as Number,
            height as Number,
            obscurityFlags as Number
        ) as Void {
            var isRound =
                System.getDeviceSettings().screenShape ==
                System.SCREEN_SHAPE_ROUND;

            var isObscureLeft =
                (obscurityFlags & WatchUi.DataField.OBSCURE_LEFT) != 0;
            var isObscureRight =
                (obscurityFlags & WatchUi.DataField.OBSCURE_RIGHT) != 0;
            var isObscureTop =
                (obscurityFlags & WatchUi.DataField.OBSCURE_TOP) != 0;
            var isObscureBottom =
                (obscurityFlags & WatchUi.DataField.OBSCURE_BOTTOM) != 0;

            var offsetLeft = isObscureLeft
                ? isRound
                    ? !isObscureRight
                        ? 0.25
                        : 0.12
                    : 0.1
                : 0.02;

            var offsetRight = isObscureRight
                ? isRound
                    ? !isObscureLeft
                        ? 0.25
                        : 0.12
                    : 0.1
                : 0.02;

            var offsetTop = isObscureTop
                ? isRound
                    ? !isObscureBottom
                        ? 0.2
                        : 0.12
                    : 0.1
                : 0.02;

            var offsetBottom = isObscureBottom
                ? isRound
                    ? !isObscureTop
                        ? 0.2
                        : 0.12
                    : 0.1
                : 0.02;

            var paddingLeft = (width * offsetLeft).toNumber();
            var paddingRight = (width * offsetRight).toNumber();
            var paddingTop = (height * offsetTop).toNumber();
            var paddingBottom = (height * offsetBottom).toNumber();

            safeX = paddingLeft;
            safeY = paddingTop;
            safeWidth = width - paddingLeft - paddingRight;
            safeHeight = height - paddingTop - paddingBottom;

            ContentsPositionArena.isCompactMode =
                safeHeight < 100 || safeWidth < 140;

            var maxRatio = 2.5;
            var isOverRatio = safeWidth > safeHeight * maxRatio;

            contentWidth = isOverRatio
                ? (safeHeight * maxRatio).toNumber()
                : safeWidth;

            contentX = isOverRatio
                ? safeX + ((safeWidth - contentWidth) / 2).toNumber()
                : safeX;
        }

        function setStatusBarPosition() as Void {
            var isCompact = ContentsPositionArena.isCompactMode;

            StatusBarArena.labelX = safeX + (safeWidth / 2).toNumber();
            StatusBarArena.labelY =
                safeY + (safeHeight * (isCompact ? 0.1 : 0.12)).toNumber();
            StatusBarArena.labelJustify =
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

            StatusBarArena.lineStartX =
                contentX + (contentWidth * 0.1).toNumber();
            StatusBarArena.lineStartY =
                safeY + (safeHeight * (isCompact ? 0.25 : 0.22)).toNumber();
            StatusBarArena.lineEndX =
                contentX + (contentWidth * 0.9).toNumber();
            StatusBarArena.lineEndY =
                safeY + (safeHeight * (isCompact ? 0.25 : 0.22)).toNumber();
        }

        function setEventRowPosition() as Void {
            var isCompact = ContentsPositionArena.isCompactMode;

            var sunriseYRatio = isCompact ? 0.4 : 0.45;
            var sunsetYRatio = isCompact ? 0.75 : 0.7;

            EventRowArena.iconX = contentX + (contentWidth * 0.15).toNumber();
            EventRowArena.sunrizeY =
                safeY + (safeHeight * sunriseYRatio).toNumber();
            EventRowArena.sunsetY =
                safeY + (safeHeight * sunsetYRatio).toNumber();

            EventRowArena.timeX = contentX + (contentWidth * 0.95).toNumber();
            EventRowArena.timeJustify =
                Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
        }

        function setWatermark() as Void {
            WatermarkArena.labelX = safeX + (safeWidth / 2).toNumber();
            WatermarkArena.labelY = safeY + (safeHeight * 0.9).toNumber();
            WatermarkArena.justify =
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        }
    }
}
