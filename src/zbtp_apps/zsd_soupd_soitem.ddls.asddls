@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - Sales Order Item for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SOUPD_SOITEM
  as select from    I_SalesDocumentItem as a
    left outer join I_Plant             as b on b.Plant = a.Plant
    left outer join I_ProductText       as c on  c.Product  = a.Product
                                             and c.Language = $session.system_language
    left outer join I_Customer          as d on d.Customer = a.SoldToParty
    left outer join ZPLANT_ADD          as e on  e.AddressID                 = b.AddressID
                                             and e.AddressPersonID           = ''
                                             and e.AddressRepresentationCode = ''
{
  key a.SalesDocument,
  key a.SalesDocumentItem,
      a.Plant,
      a.Product,
      a.Batch,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      a.OrderQuantity,
      a.OrderQuantityUnit,
      a.BaseUnit,
      a.SoldToParty,
      a.Division,
      a.SalesDocumentType,
      a.DistributionChannel,
      a.ShippingPoint,
      a.IndependentRequirementType,
      a.IncotermsClassification,
      a.OverdelivTolrtdLmtRatioInPct,
      a.SDProcessStatus,
      b.PlantName,
      c.ProductName,
      d.CustomerName,
      e.StreetName  as PlantStreet,
      e.CityName    as PlantCity,
      e.PostalCode  as PlantPostalCode,
      e.CountryName as PlantCountryName,
      e.RegionName  as PlantRegionName
}
