# Complication Provider API Specification (V1)

This document specifies the interface for developing Garmin watch faces and other consumer applications that use the complication feature of this app (a background data provider).

---

## 1. Data Format Overview

The `:value` property of the complication contains a **single CSV-formatted string (`String`)** in which each field is separated by a comma (`,`).

On the consumer side, split the received string by commas and retrieve each value according to the index order defined in the **Data Schema** below.

### Example Payloads

- **Successful data retrieval:**

  `"1,1730000000,0,1729976400,1730016000,1729990000,1730030000,0.5,0.98,125"`

- **Error (e.g., a network error):**

  `"1,1730000000,2,0,0,0,0,0,0,0"`

---

## 2. Data Schema (Schema V1)

The following table defines the array index, data type after conversion, and description of each field. The total number of elements is `10`.

| Index | Field Name | Type (After Conversion) | Description | Value on Error |
|---|---|---|---|---|
| `0` | `VERSION` | `Number` | Schema version (currently fixed at `1`) | `1` |
| `1` | `TIMESTAMP` | `Number` | Data generation time (Unix timestamp in seconds) | Current Unix timestamp at execution time |
| `2` | `STATUS` | `Number` | Communication and data retrieval status (see the Status Codes section below) | Corresponding error status (`1`–`4`) |
| `3` | `SUNRISE_TIME` | `Number` | Sunrise time (Unix timestamp in seconds) | `0` |
| `4` | `SUNSET_TIME` | `Number` | Sunset time (Unix timestamp in seconds) | `0` |
| `5` | `MOONRISE_TIME` | `Number` | Moonrise time (Unix timestamp in seconds) | `0` |
| `6` | `MOONSET_TIME` | `Number` | Moonset time (Unix timestamp in seconds) | `0` |
| `7` | `MOON_PHASE` | `Float` | Moon phase (`0.0`–`1.0`) | `0` |
| `8` | `MOON_FRACTION` | `Float` | Fraction of the Moon's illuminated surface (`0.0`–`1.0`) | `0` |
| `9` | `ALTITUDE` | `Number` (or `Float`) | Altitude in meters | `0` |

---

## 3. Status Codes and Error Handling (`STATUS`)

The `STATUS` field at index `2` contains a numeric value indicating the result of data retrieval.

When `STATUS` is anything other than `0` (`SUCCESS`), all data fields at indices `3`–`9` are set to `0`.

| Value | Status Name | Condition | Recommended Handling on the Watch Face |
|---|---|---|---|
| `0` | `SUCCESS` | Data retrieval and update succeeded | Display the retrieved values, or update the cache and display the cached data |
| `1` | `NO_GPS` | The device cannot obtain GPS location information (e.g., no GPS signal or no position fix) | Display a "GPS unavailable" icon, or display data from the last successful retrieval |
| `2` | `NETWORK_ERROR` | The Bluetooth connection to the smartphone is disconnected, or the smartphone is offline | Display a "Network offline" icon, or display cached data |
| `3` | `SERVER_ERROR` | The API server is experiencing an issue, or the request is invalid (HTTP status codes in the 400–500 range) | Display a fallback value such as `"--:--"`, or display cached data |
| `4` | `UNKNOWN_ERROR` | An unexpected error occurred | Display a fallback value such as `"--:--"`. Please file an issue in the `YAMAKAGE` repository |

> **💡 Implementation Tip: Use Caching**
>
> Background communication may occasionally encounter temporary network errors (`NETWORK_ERROR`) or GPS signal loss (`NO_GPS`), for example, while the user is moving.
>
> To improve the user experience (UX), consider caching the data whenever `STATUS == 0`, using `Storage` or a similar mechanism. When an error occurs, continue displaying the previously cached data while showing a small error indicator.

---

## 4. Subscribing to Complications and Retrieving Data (Watch Face Implementation Example)

The following example demonstrates how a watch face searches for the `YAMAKAGE` complication, subscribes to updates, and receives its value whenever the data changes.

According to Garmin's API, third-party app complications can be identified by iterating through the results of `Complications.getComplications()` and checking properties such as `shortLabel`. Once the desired complication is found, the consumer can subscribe to its updates.

```monkeyc
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;
import Toybox.Graphics;

class MyWatchFaceView extends WatchUi.WatchFace {
    // The shortLabel name of the YAMAKAGE complication
    private const TARGET_SHORT_LABEL = "YAMAKAGE";

    private var _yamakageCompId as Complications.Id?;
    private var _sunriseText as String = "--:--";
    private var _sunsetText as String = "--:--";

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // 1. Register the complication change callback
        Complications.registerComplicationChangeCallback(
            self.method(:onComplicationChanged)
        );

        // 2. Find and subscribe to the YAMAKAGE complication
        _findAndSubscribeComplication();
    }

    // Search the system's complication list for YAMAKAGE and subscribe to it
    private function _findAndSubscribeComplication() as Void {
        var iter = Complications.getComplications();
        var comp = iter.next();

        while (comp != null) {
            if (comp.shortLabel != null && comp.shortLabel.equals(TARGET_SHORT_LABEL)) {
                _yamakageCompId = comp.complicationId;
                Complications.subscribeToUpdates(_yamakageCompId);

                // Retrieve the initial data
                _fetchAndParseData(_yamakageCompId);
                break;
            }
            comp = iter.next();
        }
    }

    // Called when the complication's value changes, such as after a background update
    function onComplicationChanged(compId as Complications.Id) as Void {
        if (_yamakageCompId != null && compId.equals(_yamakageCompId)) {
            _fetchAndParseData(compId);
            WatchUi.requestUpdate(); // Redraw the screen
        }
    }

    // Retrieve the string from the complication and pass it to the parser
    private function _fetchAndParseData(compId as Complications.Id) as Void {
        try {
            var comp = Complications.getComplication(compId);
            if (comp.value instanceof String) {
                var rawCsv = comp.value as String;

                // Call the parser described in Section 5 to extract the data
                var parsed = ComplicationConsumer.parseComplicationValue(rawCsv);
                if (parsed != null && parsed[:status] == ComplicationConsumer.Status.SUCCESS) {
                    _sunriseText = parsed[:sunriseStr] as String;
                    _sunsetText = parsed[:sunsetStr] as String;
                }
            }
        } catch (e instanceof Complications.ComplicationNotFoundException) {
            // Handle cases where the complication cannot be found, such as after uninstallation
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

## 5. Parsing and Conversion Utility (`ComplicationConsumer`)

This utility module is called by `_fetchAndParseData` in Section 4. It splits the CSV string, validates the schema version, and converts timestamps into formatted time strings.

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

    // Helper function to split a comma-separated string into an array
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

    // Helper function to convert a Unix timestamp (seconds) into local time in "HH:MM" format
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

    // Example implementation for parsing the complication value (String)
    function parseComplicationValue(rawValue as String?) as Array? {
        if (rawValue == null) {
            return null;
        }

        var parts = splitCsv(rawValue);
        if (parts.size() < Schema.DATA_SIZE) {
            return null; // Insufficient number of data elements
        }

        // 1. Validate the schema version
        var version = parts[Schema.VERSION].toNumber();
        if (version != EXPECTED_VERSION) {
            // Stop processing if the version is unsupported, protecting against future breaking changes
            return null;
        }

        // 2. Check the status
        var status = parts[Schema.STATUS].toNumber();

        if (status == Status.SUCCESS) {
            return parts;
        } else {
            // TODO: Handle errors according to status, such as displaying "--:--" or an icon, or using cached data
            return null;
        }
    }
}
```