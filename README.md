# SFDC fiscal code calculator

Independent class for Italian fiscal code calculation and format checking in Salesforce

## Informations

The logic has been implemented following the rules explained [here](http://www.dotnethell.it/articles/CalcoloCodiceFiscale.aspx).

The check on the cadastral code (codice catastale) is stubbed since it would need an external table, such as a custom metadata/setting.
The complete list of cities is available for download on the [ISTAT website](https://www.istat.it/it/archivio/6789).

## Example usage

```apex
// Note: birthDate is of Date type, the rest are strings
String myFiscalCode = FiscalCode.calculate( 
                        new FiscalCode.Request('<firstName>','<lastname>','<sex>','<birthDate>','<birthPlace>') 
                      );
```

In case of second names (e.g.: Mario Luigi Rossi), it would be:

```apex
FiscalCode.Request.firstName = 'Mario Luigi';
```
