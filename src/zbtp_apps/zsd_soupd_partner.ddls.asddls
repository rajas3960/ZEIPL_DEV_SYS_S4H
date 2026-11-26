@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - SO Partner Address for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SOUPD_PARTNER
  as select from    I_SalesOrderPartner as p
    left outer join ZPLANT_ADD          as e on  e.AddressID                 = p.AddressID
                                             and e.AddressPersonID           = p.AddressPersonID
                                             and e.AddressRepresentationCode = ''
{
  key p.SalesOrder,
  key cast( p.PartnerFunction as abap.char(2) ) as PartnerFunction,
      p.Customer,
      e.StreetName,
      e.CityName,
      e.PostalCode,
      e.CountryName,
      e.RegionName
}
