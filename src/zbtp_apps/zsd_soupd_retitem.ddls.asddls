@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - Return Item for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SOUPD_RETITEM
  as select from    I_CustomerReturnItem as a
    inner join      I_CustomerReturn     as r on r.CustomerReturn = a.CustomerReturn
    left outer join I_Plant              as b on b.Plant = a.Plant
    left outer join I_ProductText        as c on  c.Product  = a.Product
                                              and c.Language = $session.system_language
    left outer join I_Customer           as d on d.Customer = a.SoldToParty
    left outer join ZPLANT_ADD           as e on  e.AddressID                 = b.AddressID
                                              and e.AddressPersonID           = ''
                                              and e.AddressRepresentationCode = ''
{
  key a.CustomerReturn                        as SalesDocument,
  key a.CustomerReturnItem                    as SalesDocumentItem,
      a.Plant,
      a.Product,
      a.Batch,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      a.OrderQuantity,
      a.OrderQuantityUnit,
      a.BaseUnit,
      a.SoldToParty,
      a.Division,
      case when a.IncotermsClassification <> ''
           then a.IncotermsClassification
           else r.IncotermsClassification end as IncotermsClassification, // item first, else header (24.11.2026)
      r.CustomerReturnType                    as SalesDocumentType,
      a.DistributionChannel,
      a.ShippingPoint,
      b.PlantName,
      c.ProductName,
      d.CustomerName,
      e.StreetName                            as PlantStreet,
      e.CityName                              as PlantCity,
      e.PostalCode                            as PlantPostalCode,
      e.CountryName                           as PlantCountryName,
      e.RegionName                            as PlantRegionName
}
