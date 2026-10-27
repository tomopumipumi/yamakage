# Complication Provider API Specification (V1)

This document describes the interface for developing consumer applications, such as Garmin watch faces, that use the complication feature of YAMAKAGE (a background data provider).

---

## 1. Data Update Mechanism and Initial Setup

YAMAKAGE's complication data is kept up to date by periodically communicating with the backend API in the background.

- **Configuring the update interval:**

  Users can change the background data update interval as desired from the Settings screen in **YAMAKAGE - WatchApp**.

- **Initial setup (default state):**

  Immediately after installing YAMAKAGE - WatchApp, background updates are set to **Off** to prevent unintended battery consumption and network activity.

  When using or recommending this complication in a third-party watch face or similar application, instruct users to open YAMAKAGE and enable a background update interval (e.g., `10 Min`) from the Settings screen.

---

## 2. Required Manifest Configuration (`manifest.xml`)

To subscribe to YAMAKAGE's complication from a consumer application, add the following permission to the watch face project's `manifest.xml` file:

```xml
<iq:uses-permission id="ComplicationSubscriber"/>
```

---

## 3. Complication Identifiers

The following information can be used to identify YAMAKAGE's complication from a watch face:

- `shortLabel`: `"YAMAKAGE"`
- `longLabel`: `"YAMAKAGE"`

> **⚠️ Development Note**
>
> According to Garmin's API, complication IDs (`Complications.Id`) are assigned dynamically depending on the device and installation state.
>
> Therefore, do not use a hard-coded ID. Instead, iterate through the results of `getComplications()` and dynamically find the target complication by its `longLabel` or `shortLabel`, as shown in the implementation example below.

---

## 4. Data Format Overview

The complication's `:value` property contains a **single CSV-formatted string (`String`)**, in which each field is separated by a comma (`,`).

On the consumer side, split the received string by commas and retrieve each value according to the index order defined in the **Data Schema** below.

### Example Payloads

- **Successful data retrieval:**

  `"1,1730000000,0,1729976400,1730016000,1729990000,1730030000,0.5,0.98,125"`

- **Error (e.g., a network error):**

  `"1,1730000000,2,0,0,0,0,0,0,0"`

---

## 5. Data Schema (Schema V1)

The following table defines the array index, the data type after conversion, and the description of each field. The total number of elements is `10`.

| Index | Field Name | Type (After Conversion) | Description | Value on Error |
| :--- | :--- | :--- | :--- | :--- |
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

## 6. Status Codes and Error Handling (`STATUS`)

The `STATUS` field at index `2` contains a numeric value indicating the result of data retrieval.

When `STATUS` is anything other than `0` (`SUCCESS`), all data fields at indices `3`–`9` are set to `0`.

| Value | Status Name | Condition | Recommended Handling on the Watch Face |
| :--- | :--- | :--- | :--- |
| `0` | `SUCCESS` | Data retrieval and update succeeded | Display the retrieved values, or update the cache and display the cached data |
| `1` | `NO_GPS` | The device cannot obtain GPS location information (e.g., no GPS signal or no position fix) | Display a "GPS unavailable" icon, or display data from the last successful retrieval |
| `2` | `NETWORK_ERROR` | The Bluetooth connection to the smartphone is disconnected, or the smartphone is offline | Display a "Network offline" icon, or display cached data |
| `3` | `SERVER_ERROR` | The API server is experiencing an issue, or the request is invalid (HTTP status codes in the 400–500 range) | Display a fallback value such as `"--:--"`, or display cached data |
| `4` | `UNKNOWN_ERROR` | An unexpected error occurred | Display a fallback value such as `"--:--"`. Please file an issue in the `YAMAKAGE` repository. |

> **💡 Implementation Tip: Use Caching**
>
> Background communication may occasionally encounter temporary network errors (`NETWORK_ERROR`) or GPS signal loss (`NO_GPS`), for example, while the user is moving.
>
> To improve the user experience (UX), consider caching the data using `Storage` or a similar mechanism whenever `STATUS == 0`. When an error occurs, continue displaying the previously cached data while showing a small error indicator.

---