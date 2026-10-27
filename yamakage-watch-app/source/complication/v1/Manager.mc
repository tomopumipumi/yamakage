import Toybox.Lang;
import Toybox.Application;
import Toybox.Complications;
import Toybox.System;
import Hal.DateTime;
import Systems.TimeSystem;
import Complication.V1.Consts;
import Complication.V1.Status;
import Complication.V1.ApiSchema;
import Complication.V1.ComplicationSchema;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Complication {
    module V1 {
        module Manager {
            function update(data as Application.PersistableType) as Void {
                if (
                    data == null &&
                    !(data instanceof Array) &&
                    !(data instanceof Number)
                ) {
                    data = Status.UNKNOWN_ERROR;
                }

                var rawCompData = _serializeRawData(data);
                var sunriseCompData = _serializeSunriseData(data);
                var sunsetCompData = _serializeSunsetData(data);

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

            function _serializeRawData(
                rawData as Array or Number
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
                        :shortLabel => Application.loadResource(
                            Rez.Strings.Comp1_ShortLabelName
                        ) as String,
                        :value => _join(schemaData, ",")
                    }) as Complications.Data;

                System.println(compData);

                return compData;
            }

            function _serializeSunriseData(
                rawData as Array or Number
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

                var compData = {
                    :shortLabel => Application.loadResource(
                        Rez.Strings.Comp2_ShortLabelName
                    ) as String,
                    :value => valueStr
                };

                return compData as Complications.Data;
            }

            function _serializeSunsetData(
                rawData as Array or Number
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

                var compData = {
                    :shortLabel => Application.loadResource(
                        Rez.Strings.Comp3_ShortLabelName
                    ) as String,
                    :value => valueStr
                };

                return compData as Complications.Data;
            }

            function _join(values as Array, delimiter as String) as String {
                var result = "";

                for (var i = 0; i < values.size(); i++) {
                    if (i > 0) {
                        result += delimiter;
                    }
                    result += values[i].toString();
                }

                return result;
            }
        }
    }
}
