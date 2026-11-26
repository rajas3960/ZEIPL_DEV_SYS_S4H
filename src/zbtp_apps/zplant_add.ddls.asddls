@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant Address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPLANT_ADD 
as select from I_Address_2 as a
inner join I_CountryText as b on b.Country = a.Country
                            and b.Language = $session.system_language
inner join I_RegionText as c on c.Region = a.Region
                            and c.Country = a.Country
                            and c.Language = $session.system_language                            
{
    key a.AddressID,
    key a.AddressPersonID,
    key a.AddressRepresentationCode,
    a.CityName,
    a.PostalCode,
    a.StreetName,
    a.Country,
    a.Region,
    b.CountryName,
    c.RegionName 
    }
 