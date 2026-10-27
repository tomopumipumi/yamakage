import Toybox.Lang;
import Toybox.Application;
import Toybox.Complications;
import Toybox.System;
import Shared.Core.Consts;
import Hal.Complication.V1.Status;
import Hal.DateTime;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Hal.Complication.V1.Schema as HalSchema;
using Core.ComplicationApiSchema as ApiSchema;

module Hal {
    module Complication {
        module V1 {
            const VERSION = 1;

            module Manager {
                function update(data as Application.PersistableType) as Void {
                    if (
                        data == null &&
                        !(data instanceof Array) &&
                        !(data instanceof Number)
                    ) {
                        data = Status.UNKNOWN_ERROR;
                    }

                    var compData = _serialize(data);

                    Complications.updateComplication(
                        Consts.COMPLICATION_ID_EPHEMERIS.toNumber(),
                        compData
                    );
                }

                function _serialize(
                    rawData as Array or Number
                ) as Complications.Data {
                    var schemaData = new [HalSchema.DATA_SIZE];
                    schemaData[HalSchema.VERSION] = VERSION;
                    schemaData[HalSchema.TIMESTAMP] =
                        DateTime.createTargetUnixTime();

                    // Error
                    if (rawData instanceof Number) {
                        var errorStatus = rawData;
                        schemaData[HalSchema.STATUS] = errorStatus;
                        schemaData[HalSchema.SUNRISE_TIME] = 0;
                        schemaData[HalSchema.SUNSET_TIME] = 0;
                        schemaData[HalSchema.MOONRISE_TIME] = 0;
                        schemaData[HalSchema.MOONSET_TIME] = 0;
                        schemaData[HalSchema.MOON_PHASE] = 0;
                        schemaData[HalSchema.MOON_FRACTION] = 0;
                        schemaData[HalSchema.ALTITUDE] = 0;
                    }

                    // Success
                    else {
                        schemaData[HalSchema.STATUS] = Status.SUCCESS;
                        schemaData[HalSchema.SUNRISE_TIME] =
                            rawData[ApiSchema.SUNRISE_TIME];
                        schemaData[HalSchema.SUNSET_TIME] =
                            rawData[ApiSchema.SUNSET_TIME];
                        schemaData[HalSchema.MOONRISE_TIME] =
                            rawData[ApiSchema.MOONRISE_TIME];
                        schemaData[HalSchema.MOONSET_TIME] =
                            rawData[ApiSchema.MOONSET_TIME];
                        schemaData[HalSchema.MOON_PHASE] =
                            rawData[ApiSchema.MOON_PHASE];
                        schemaData[HalSchema.MOON_FRACTION] =
                            rawData[ApiSchema.MOON_FRACTION];
                        schemaData[HalSchema.ALTITUDE] =
                            rawData[ApiSchema.ALTITUDE];
                    }

                    var compData =
                        ({
                            :shortLabel => Application.loadResource(
                                Rez.Strings.ShortLabelName
                            ) as String,
                            :value => _join(schemaData, ",")
                        }) as Complications.Data;

                    System.println(compData);

                    return compData;
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
}
