import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Icons;

import Features.Details.Components.DetailsMoonRow;
import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsSeparators;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Details {
        (:test)
        module SmokeTests {
            (:test)
            function testDetailsRowRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var layoutCtx = TestFixture.createDummyLayoutCtx();

                try {
                    DetailsRow.render(
                        dc,
                        60,
                        "SUNRISE",
                        "06:30",
                        Graphics.COLOR_YELLOW,
                        Icons.ICON_SUNRISE,
                        layoutCtx
                    );
                    logger.debug("DetailsRow.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "DetailsRow.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testDetailsMoonRowRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var layoutCtx = TestFixture.createDummyLayoutCtx();

                try {
                    DetailsMoonRow.render(
                        dc,
                        180,
                        "ILLUM",
                        "85.0%",
                        Graphics.COLOR_BLUE,
                        0.85,
                        0.5,
                        layoutCtx
                    );
                    logger.debug(
                        "DetailsMoonRow.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "DetailsMoonRow.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testDetailsSeparatorsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    DetailsSeparators.render(dc, 240, 240, 3); // Sun mode (3 rows)
                    DetailsSeparators.render(dc, 240, 240, 4); // Moon mode (4 rows)
                    logger.debug(
                        "DetailsSeparators.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "DetailsSeparators.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
