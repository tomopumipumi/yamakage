import Toybox.Lang;
import Toybox.Test;
import Systems.Crypt;

module Systems {
    (:test)
    module CryptTests {
        (:test)
        function testGenerateRandomSessionIdFormat(
            logger as Test.Logger
        ) as Boolean {
            var id = Crypt.generateRandomSessionId();

            Test.assertMessage(
                id instanceof String,
                "Session ID should be a string."
            );

            Test.assertMessage(
                id.length() == 17,
                "Session ID should be exactly 17 characters long."
            );

            Test.assertMessage(
                id.substring(8, 9).equals("-"),
                "The 9th character of the Session ID should be a hyphen."
            );

            logger.debug("Format test passed. Generated ID: " + id);
            return true;
        }

        (:test)
        function testGenerateRandomSessionIdUniqueness(
            logger as Test.Logger
        ) as Boolean {
            var id1 = Crypt.generateRandomSessionId();
            var id2 = Crypt.generateRandomSessionId();

            logger.debug("ID 1: " + id1);
            logger.debug("ID 2: " + id2);

            Test.assertMessage(
                !id1.equals(id2),
                "Consecutive session IDs must be unique."
            );

            logger.debug("Uniqueness test passed.");
            return true;
        }
    }
}
