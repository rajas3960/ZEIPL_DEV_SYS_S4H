@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO Item for Carrier Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #L, dataClass: #TRANSACTIONAL }
@Search.searchable: true
define view entity ZSD_SO_TMSOITEM
  as select from    I_SalesDocumentItem as a
    left outer join I_SalesDocument     as d on a.SalesDocument = d.SalesDocument
    left outer join I_ProductText       as c on  a.Material = c.Product
                                             and c.Language = $session.system_language
    left outer join I_Customer          as e on d.SoldToParty = e.Customer
{
      @Search.defaultSearchElement: true
  key a.SalesDocument       as SalesOrder,
  key a.SalesDocumentItem   as SalesOrderItem,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      a.OrderQuantity,
      a.OrderQuantityUnit,
      a.Material,
      @Search.defaultSearchElement: true
      c.ProductName,
      a.Plant,
      @Search.defaultSearchElement: true
      d.SoldToParty,
      e.CustomerName,
      d.SalesDocumentDate
}
where a.SDProcessStatus <> 'C' and (  a.SalesDocumentType = 'ZDOM' or       // new one added on 23.11.2026
  a.SalesDocumentType = 'ZEXP' or
  a.SalesDocumentType = 'ZJOB' or
  a.SalesDocumentType = 'CBRE' ) and a.SalesDocumentRjcnReason = ''
//where
//      a.SDDocumentCategory      = 'C'     // sales orders only        Removed on 23.11.2026 
//  and a.SalesDocumentRjcnReason = ''      // rejected items left out
