import Toybox.Lang;
import Toybox.Application;
import Toybox.Complications;
import Toybox.System;
import Toybox.Time;
import Hal.DateTime;
import Systems.TimeSystem;
import Complication.V1.Consts;
import Complication.V1.Status;
import Complication.V1.ApiSchema;
import Complication.V1.ComplicationSchema;

using Complication.V1.Context as cx;

module Complication {
    module V1 {
        (:background)
        module Manager {
            (:background)
            const CSV_FORMAT = "$1$,$2$,$3$,$4$,$5$,$6$,$7$,$8$,$9$,$10$";

            (:background)
            function update(data as Array or Number) as Void {
                var rawCompData = _serializeRawData(
                    data,
                    cx.RawData_ShortLabelName
                );
                var sunriseCompData = _serializeSunriseData(
                    data,
                    cx.Sunrise_ShortLabelName
                );
                var sunsetCompData = _serializeSunsetData(
                    data,
                    cx.Sunset_ShortLabelName
                );

                try {
                    Complications.updateComplication(
                        Consts.COMPLICATION_ID_ROW_DATA.toNumber(),
                        rawCompData
                    );

                    Complications.updateComplication(
                        Consts.COMPLICATION_ID_SUNRISE.toNumber(),
                        sunriseCompData
                    );

                    Complications.updateComplication(
                        Consts.COMPLICATION_ID_SUNSET.toNumber(),
                        sunsetCompData
                    );
                } catch (ex) {
                    System.println("エラー: " + ex.getErrorMessage());
                    ex.printStackTrace();
                }
            }

            (:background)
            function _serializeRawData(
                rawData as Array or Number,
                shortLabelName as String
            ) as Complications.Data {
                var schemaData = new [ComplicationSchema.DATA_SIZE];
                schemaData[ComplicationSchema.VERSION] = Consts.VERSION;
                schemaData[ComplicationSchema.TIMESTAMP] =
                    DateTime.createTargetUnixTime();

                // Error
                if (rawData instanceof Number) {
                    var errorStatus = rawData;
                    schemaData[ComplicationSchema.STATUS] = errorStatus;
                    schemaData[ComplicationSchema.SUNRISE_TIME] = 0;
                    schemaData[ComplicationSchema.SUNSET_TIME] = 0;
                    schemaData[ComplicationSchema.MOONRISE_TIME] = 0;
                    schemaData[ComplicationSchema.MOONSET_TIME] = 0;
                    schemaData[ComplicationSchema.MOON_PHASE] = 0;
                    schemaData[ComplicationSchema.MOON_FRACTION] = 0;
                    schemaData[ComplicationSchema.ALTITUDE] = 0;
                }

                // Success
                else {
                    schemaData[ComplicationSchema.STATUS] = Status.SUCCESS;
                    schemaData[ComplicationSchema.SUNRISE_TIME] =
                        rawData[ApiSchema.SUNRISE_TIME];
                    schemaData[ComplicationSchema.SUNSET_TIME] =
                        rawData[ApiSchema.SUNSET_TIME];
                    schemaData[ComplicationSchema.MOONRISE_TIME] =
                        rawData[ApiSchema.MOONRISE_TIME];
                    schemaData[ComplicationSchema.MOONSET_TIME] =
                        rawData[ApiSchema.MOONSET_TIME];
                    schemaData[ComplicationSchema.MOON_PHASE] =
                        rawData[ApiSchema.MOON_PHASE];
                    schemaData[ComplicationSchema.MOON_FRACTION] =
                        rawData[ApiSchema.MOON_FRACTION];
                    schemaData[ComplicationSchema.ALTITUDE] =
                        rawData[ApiSchema.ALTITUDE];
                }

                var compData =
                    ({
                        :shortLabel => shortLabelName,
                        :value => Lang.format(CSV_FORMAT, schemaData)
                    }) as Complications.Data;

                System.println(compData);

                return compData;
            }

            (:background)
            function _serializeSunriseData(
                rawData as Array or Number,
                shortLabelName as String
            ) as Complications.Data {
                var valueStr = "--:--";

                if (
                    rawData instanceof Array &&
                    rawData[ApiSchema.SUNRISE_TIME] != null
                ) {
                    valueStr = TimeSystem.formatUnixTime(
                        rawData[ApiSchema.SUNRISE_TIME]
                    );
                }

                var compData =
                    ({
                        :shortLabel => shortLabelName,
                        :value => valueStr
                    }) as Complications.Data;

                return compData;
            }

            (:background)
            function _serializeSunsetData(
                rawData as Array or Number,
                shortLabelName as String
            ) as Complications.Data {
                var valueStr = "--:--";

                if (
                    rawData instanceof Array &&
                    rawData[ApiSchema.SUNSET_TIME] != null
                ) {
                    valueStr = TimeSystem.formatUnixTime(
                        rawData[ApiSchema.SUNSET_TIME]
                    );
                }

                var compData =
                    ({
                        :shortLabel => shortLabelName,
                        :value => valueStr
                    }) as Complications.Data;

                return compData;
            }
        }
    }
}
