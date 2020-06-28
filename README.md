# SFDC fiscal code calculator

Independent class for Italian fiscal code calculation and format checking in Salesforce

## Example usage

```apex
// Note: birthDate is of Date type, the rest are strings
String myFiscalCode = FiscalCode.calculate( 
                        new FiscalCode.Request('<firstName>','<lastname>','<sex>','<birthDate>','<birthPlace>') 
                      );
```
