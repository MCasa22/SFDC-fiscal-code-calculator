/**
 *  Exercise based on the instructions found at:
 *  http://www.dotnethell.it/articles/CalcoloCodiceFiscale.aspx
 * 
 *  The cadastral code (codice catastale) is not calculated as it would need an external table (such as a custom metadata).
 *  The complete list can be found here:
 *  https://www.istat.it/it/archivio/6789
 *
 *  Comments and debugs are mainly for explanatory purposes.
 */
public class FiscalCode {

    /**
     *  check on Fiscal Code pattern coherency
     */
    public static Boolean isFormattedCorrectly (String fiscalCode) {
        return Pattern.matches(CF_PATTERN, fiscalCode);
    }

    /**
     *  Calculates the full fiscal code given standard info
     */
    public static String calculate (Request req) {
        try {
            String partialFiscalCode = calcLastName(req.lastName) + calcFirstName(req.firstName) + calcBirthDate(req.birthDate, req.sex) + 
                                        + calcCadastralCode(req.birthPlace);
            
            return ( partialFiscalCode + calcCtrlChar(partialFiscalCode) );
        
        } catch (Exception e) {
            throw new FiscalCodeException('Error during fiscal code calculation: '+ e.getMessage() + ' | ' + e.getCause() + ' | ' + e.getStackTraceString());    
        }
    }

    /**
     *  Calculates the first three characters given the first name
     *  N.B.: second names are accepted
     */
    private static String calcFirstName (String firstName){
        return calcName(firstName, true);
    }

    /**
     *  Calculates the first three characters given the last name
     */
    private static String calcLastName (String lastName) {
        return calcName(lastName, false);
    }

    /**
     *  Generalized method for first and last name calculation
     */
    private static String calcName (String name, Boolean isFirstName){

        String charCode=''; // the 3 char code to return
        String nameVowels=''; //used in case the name has less than 3 consonants
        name = checkForBadChars(name);
        System.debug('Name to handle is: <'+name+'>');
        Integer length = name.length();

        // create a string of only consonants
        for(Integer i=0;i<length;i++){
            String curLetter = name.substring(i,i+1);
            System.debug('checking letter: <'+curLetter+'>');
            if(!VOWELS.contains(curLetter)){
                charCode+=curLetter;
                System.debug('charCode is <'+charCode+'> at iteration number <'+i+'>');
            }
        }
        //if string length is already 3, return it
        if(charCode.length() == 3) return charCode;
        //if string length is at least 4 => return first, third and fourth characters (only made for the first name)
        if(charCode.length() >= 4 && isFirstName) return ( charCode.substring(0,1) + charCode.substring(2,4) );
        // if string length is more than 3, return the first three consonants (last name case)
        if(charCode.length() >= 4 && !isFirstName) return charCode.substring(0,3);

        //if string length is less than 3, manage missing chars
        for(Integer j=0;j<length;j++){
            String curLetter = name.substring(j,j+1);
            System.debug('checking letter: <'+curLetter+'>');
            if(VOWELS.contains(curLetter)){
                nameVowels+=curLetter;
                System.debug('nameVowels is <'+nameVowels+'> at iteration number <'+j+'>');
            }
        }
        // new 3 letter char code with consonants and vowels.
        // padding and trimming are needed for cases where we have a 2 characters long charCode (e.g.: "Mario Li")
        charCode = (charCode + nameVowels + '   ').substring(0,3).trim();
        
        System.debug('charCode is <'+charCode+'> after padding with vowels <'+nameVowels+'>');
        if(charCode.length() == 3) return charCode;
        // last resort, pad with X's
        System.debug('charCode <'+charCode+'>  to be padded with X\'s');
        return charCode.rightPad(3,'X');
    }

    /**
     *  Calculates the date part of the fiscal code given the birth date and the individual's sex
     */
    private static String calcBirthDate (Date birthDate, String sex) {
        String yearChar = String.valueOf( birthDate.year() ).substring(2,4);
        String monthChar = MONTHS.get(birthDate.month());
        Integer days = birthDate.day();
        String dayChar;

        // add 40 days for women
        if('F'.equalsIgnoreCase(sex)) days += 40;

        dayChar = String.valueOf( days ).leftPad(2,'0');
        System.debug('calculated <'+yearChar + monthChar + dayChar+'> from <'+birthDate+'> and <'+sex+'>');

        return yearChar + monthChar + dayChar;
    }

    /**
     *  Stub for the method that should calculate the cadastral code (codice catastale)
     *  It always returns "F205" which is Milan
     */
    private static String calcCadastralCode (String birthPlace) {

        System.debug('calcCadastralCode | WARNING, sending hardcoded codice catastale, implement your own.');
        /**
        One possible implementation:
        List<Some_custom_metadata__mdt> codeList = [SELECT City__c, code__c 
                                                        FROM Some_custom_metadata__mdt 
                                                        WHERE City__c = :birthPlace];
        if(codeList.isEmpty()) throw new FiscalCodeException('UNKNOWN_BIRTH_PLACE | '+birthPlace+' is not a recognized city');
        return codelist[0].code__c;
         */
        return 'F205';
    }

    /**
     *  Calculates the control character (last) based on the first 15 others
     */
    private static String calcCtrlChar(String partialCode) {
        
        Integer length = partialCode.length();
        Integer evenSum = 0;
        Integer oddSum = 0;

        for(Integer k=0;k<length;k++){
            String curLetter = partialCode.substring(k,k+1);
            // X: consider chars in even positions, convert them using EVEN_CHARS map and sum them
            if(Math.mod(k,2)==0)
            {
                oddSum += ODD_CHARS.get(curLetter);
            } 
            // Y: consider chars in odd positions, convert them using ODD_CHARS map and sum them
            else 
            {
                evenSum += EVEN_CHARS.get(curLetter);
            }
        }
        // calculate modulus of the sum
        Integer rest = Math.mod((evenSum + oddSum),26);
        // convert the modulus using CTRL_CHARS map
        return ( CTRL_CHARS.get(rest) );
    }

    /**
     *  Switches possible accented letters with their non-accented version and eliminates apostrophes
     */
    private static String checkForBadChars(String name){
        String newName = name;
        for(String badChar : BAD_CHARS.keySet()){
            newName = newName.replace(badChar, BAD_CHARS.get(badChar));
        }
        System.debug('FiscalCode.checkForBadChars | name was ' + name + ' and now is ' + newName.toUpperCase());
        return newName.toUpperCase();
    }

    /**
     *  Wrapper class for calculating the fiscal code
     */
    public class Request {
        public String firstName;
        public String lastName;
        public String sex;
        public Date birthDate;
        public String birthPlace;

        public Request (String firstName, String lastName, String sex, Date birthDate, String birthPlace){
            this.firstName = firstName;
            this.lastName = lastName;
            if(sex == 'M' || sex == 'F'){
                this.sex = sex;
            } else {
                throw new FiscalCodeException('INVALID_INPUT | '+sex+' is not accepted, choose either M or F');
            }
            this.birthDate = birthDate;
            this.birthPlace = birthPlace;

        }
    }

    private class FiscalCodeException extends Exception {}

    /********************************************************************************************************************************/
    /** END OF LOGIC, JUST STATIC PROPERTIES FROM HERE ON */

    private static final string CF_PATTERN = '^([A-Za-z]{6}[0-9lmnpqrstuvLMNPQRSTUV]{2}[abcdehlmprstABCDEHLMPRST]{1}[0-9lmnpqrstuvLMNPQRSTUV]{2}[A-Za-z]{1}[0-9lmnpqrstuvLMNPQRSTUV]{3}[A-Za-z]{1})|([0-9]{11})$';  

    private static final List<String> VOWELS = new List<String>{'A','E','I','O','U','a','e','i','o','u'};

    // month in numerical order: january = 1, august = 8, etc...
    private static final Map<Integer, String> MONTHS = new Map<Integer, String>{
        1   => 'A',
        2   => 'B',
        3   => 'C',
        4   => 'D',
        5   => 'E',
        6   => 'H',
        7   => 'L',
        8   => 'M',
        9   => 'P',
        10  => 'R',
        11  => 'S',
        12  => 'T'
    };

    private static final Map<String, Integer> EVEN_CHARS = new Map<String, Integer>{
        '0' =>  0,
        '1' =>  1,
        '2' =>  2,
        '3' =>  3,
        '4' =>  4,
        '5' =>  5,
        '6' =>  6,
        '7' =>  7,
        '8' =>  8,
        '9' =>  9,
        'A' =>  0,
        'B' =>  1,
        'C' =>  2,
        'D' =>  3,
        'E' =>  4,
        'F' =>  5,
        'G' =>  6,
        'H' =>  7,
        'I' =>  8,
        'J' =>  9,
        'K' =>  10,
        'L' =>  11,
        'M' =>  12,
        'N' =>  13,
        'O' =>  14,
        'P' =>  15,
        'Q' =>  16,
        'R' =>  17,
        'S' =>  18,
        'T' =>  19,
        'U' =>  20,
        'V' =>  21,
        'W' =>  22,
        'X' =>  23,
        'Y' =>  24,
        'Z' =>  25
    };

    private static final Map<String, Integer> ODD_CHARS = new Map<String, Integer>{
        '0' =>  1,
        '1' =>  0,
        '2' =>  5,
        '3' =>  7,
        '4' =>  9,
        '5' =>  13,
        '6' =>  15,
        '7' =>  17,
        '8' =>  19,
        '9' =>  21,
        'A' =>  1,
        'B' =>  0,
        'C' =>  5,
        'D' =>  7,
        'E' =>  9,
        'F' =>  13,
        'G' =>  15,
        'H' =>  17,
        'I' =>  19,
        'J' =>  21,
        'K' =>  2,
        'L' =>  4,
        'M' =>  18,
        'N' =>  20,
        'O' =>  11,
        'P' =>  3,
        'Q' =>  6,
        'R' =>  8,
        'S' =>  12,
        'T' =>  14,
        'U' =>  16,
        'V' =>  10,
        'W' =>  22,
        'X' =>  25,
        'Y' =>  24,
        'Z' =>  23
    }; 

    private static final Map<Integer, String> CTRL_CHARS = new Map<Integer, String>{
        0 =>  'A',
        1 =>  'B',
        2 =>  'C',
        3 =>  'D',
        4 =>  'E',
        5 =>  'F',
        6 =>  'G',
        7 =>  'H',
        8 =>  'I',
        9 =>  'J',
        10 =>  'K',
        11 =>  'L',
        12 =>  'M',
        13 =>  'N',
        14 =>  'O',
        15 =>  'P',
        16 =>  'Q',
        17 =>  'R',
        18 =>  'S',
        19 =>  'T',
        20 =>  'U',
        21 =>  'V',
        22 =>  'W',
        23 =>  'X',
        24 =>  'Y',
        25 =>  'Z'
    };

    private static final Map<String,String> BAD_CHARS = new Map<String,String>{
        '\''    => '',
        ' '     => '',
        'à'     => 'A',
        'è'     => 'E',
        'ì'     => 'I',
        'ò'     => 'O',
        'ù'     => 'U',
        'À'     => 'A',
        'É'     => 'E',
        'Ì'     => 'I',
        'Ò'     => 'O',
        'Ù'     => 'U'        
    };
}
