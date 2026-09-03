import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

import Systems.TimeSystem;

module Systems {
    module Tests {
        (:test)
        module TimeSystemTests {
            (:test)
            function testFormatUnixTime(logger as Test.Logger) as Boolean {
                Test.assertMessage(
                    TimeSystem.formatUnixTime(null).equals("--:--"),
                    "Should return fallback string '--:--' for null."
                );
                Test.assertMessage(
                    TimeSystem.formatUnixTime(0).equals("--:--"),
                    "Should return fallback string '--:--' for 0."
                );
                Test.assertMessage(
                    TimeSystem.formatUnixTime(-100).equals("--:--"),
                    "Should return fallback string '--:--' for negative values."
                );

                var validUnixTime = 1700000000l;
                var result = TimeSystem.formatUnixTime(validUnixTime);

                Test.assertMessage(
                    !result.equals("--:--"),
                    "Valid timestamp should not return fallback string."
                );
                Test.assertMessage(
                    result.length() == 5,
                    "Valid timestamp should be formatted as 5 characters (e.g., 14:05)."
                );

                logger.debug("testFormatUnixTime passed.");
                return true;
            }

            (:test)
            function testFormatUnixDate(logger as Test.Logger) as Boolean {
                Test.assertMessage(
                    TimeSystem.formatUnixDate(null).equals(""),
                    "Should return empty string for null."
                );
                Test.assertMessage(
                    TimeSystem.formatUnixDate(0).equals(""),
                    "Should return empty string for 0."
                );
                Test.assertMessage(
                    TimeSystem.formatUnixDate(-500l).equals(""),
                    "Should return empty string for negative values."
                );

                var validUnixTime = 1700000000l;
                var result = TimeSystem.formatUnixDate(validUnixTime);

                Test.assertMessage(
                    !result.equals(""),
                    "Valid timestamp should not return empty string."
                );
                Test.assertMessage(
                    result.substring(0, 1).equals("("),
                    "Formatted date should start with '('."
                );
                Test.assertMessage(
                    result
                        .substring(result.length() - 1, result.length())
                        .equals(")"),
                    "Formatted date should end with ')'."
                );

                logger.debug("testFormatUnixDate passed.");
                return true;
            }
        }
    }
}
