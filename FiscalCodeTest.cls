@isTest
private class FiscalCodeTest {

    @isTest
    private static void checkPatternTest () {
        String code = 'RSSMRA80A01F205X';

        Boolean res = FiscalCode.isFormattedCorrectly(code);

        System.assert(res == true);
    }

    @isTest
    private static void calculateFiscalCode () {

        String firstName = 'mario';
        String lastname = 'rossi';
        String sex = 'M';
        Date birthDate = Date.newInstance(1980, 1, 1);
        String birthPlace = 'Milano';
        String expectedFiscalCode = 'RSSMRA80A01F205X';

        FiscalCode.Request req = new FiscalCode.Request(firstName,lastname,sex,birthDate,birthPlace);

        String myFiscalCode = FiscalCode.calculate(req);

        System.assert(myFiscalCode == expectedFiscalCode);
    }
    
    @isTest
    private static void calculateFiscalCode_NotEnoughLetters () {

        String firstName = 'mario';
        String lastname = 'li';
        String sex = 'M';
        Date birthDate = Date.newInstance(1980, 1, 1);
        String birthPlace = 'Milano';
        String expectedFiscalCode = 'LIXMRA80A01F205W';

        FiscalCode.Request req = new FiscalCode.Request(firstName,lastname,sex,birthDate,birthPlace);

        String myFiscalCode = FiscalCode.calculate(req);
		
        System.assert(myFiscalCode == expectedFiscalCode);
    }
    
    @isTest
    private static void invalidSex () {
        try {
            String firstName = 'mario';
            String lastname = 'li';
            String sex = 'A';
            Date birthDate = Date.newInstance(1980, 1, 1);
            String birthPlace = 'Milano';

            FiscalCode.Request req = new FiscalCode.Request(firstName,lastname,sex,birthDate,birthPlace);
        } catch (Exception e){
            System.assert(e.getMessage() == 'INVALID_INPUT | A is not accepted, choose either M or F');
        } 
    }
}