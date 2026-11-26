@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Traking'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZSD_SC_ORDER_TRAKING
  as select from I_SalesOrder     as A
    inner join   I_SalesOrderItem as B on B.SalesOrder = A.SalesOrder

    left outer join I_Customer as C on C.Customer = A.SoldToParty

    left outer join I_ProductPlantBasic as P on  P.Product = B.Product
                                             and P.Plant   = B.Plant

    left outer join ZSD_SO_INVQTY as INV on  INV.SalesOrder     = B.SalesOrder
                                         and INV.SalesOrderItem = B.SalesOrderItem

    left outer join I_SalesOrderPartner as BRK on  BRK.SalesOrder     = A.SalesOrder
                                               and BRK.PartnerFunction = 'ZB'
    left outer join I_Supplier          as BRS on  BRS.Supplier = BRK.Supplier

    left outer join I_SalesOrderItemPricingElement as SGST on  SGST.SalesOrder     = B.SalesOrder
                                                           and SGST.SalesOrderItem = B.SalesOrderItem
                                                           and SGST.ConditionType  = 'JOSG'
    left outer join I_SalesOrderItemPricingElement as IGST on  IGST.SalesOrder     = B.SalesOrder
                                                           and IGST.SalesOrderItem = B.SalesOrderItem
                                                           and IGST.ConditionType  = 'JOIG'
    left outer join I_SalesOrderItemPricingElement as CGST on  CGST.SalesOrder     = B.SalesOrder
                                                           and CGST.SalesOrderItem = B.SalesOrderItem
                                                           and CGST.ConditionType  = 'JOCG'
    left outer join I_SalesOrderItemPricingElement as RND  on  RND.SalesOrder      = B.SalesOrder
                                                           and RND.SalesOrderItem  = B.SalesOrderItem
                                                           and RND.ConditionType   = 'DRD1'
{
  key A.SalesOrder,
  key B.SalesOrderItem,
      A.ReferenceSDDocument,
      B.ReferenceSDDocumentItem,
      A.ReferenceSDDocumentCategory,
      A.CreationDate                  as SalesOrderDate,
      A.SoldToParty,
      C.CustomerName                  as SoldToPartyDesc,
      B.Division,
      A.PurchaseOrderByCustomer       as CustomerReference,
      A.CustomerPurchaseOrderDate     as CustomerReferenceDate,

      A.TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      B.NetAmount,

      B.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      B.RequestedQuantityInBaseUnit   as SalesOrderQty,

      P.ConsumptionTaxCtrlCode        as HSNCode,

      case when B.RequestedQuantityInBaseUnit <> 0
           then division( cast( B.NetAmount as abap.dec( 15, 2 ) ),
                          cast( B.RequestedQuantityInBaseUnit as abap.dec( 15, 3 ) ), 2 )
           else cast( 0 as abap.dec( 15, 2 ) )
      end                             as Rate,

      cast( coalesce( INV.InvoicedQty, cast( 0 as abap.quan( 13, 3 ) ) ) as abap.dec( 15, 3 ) ) as InvoicedQty,
      cast( B.RequestedQuantityInBaseUnit as abap.dec( 15, 3 ) )
        - cast( coalesce( INV.InvoicedQty, cast( 0 as abap.quan( 13, 3 ) ) ) as abap.dec( 15, 3 ) )
                                      as SalesOrderBalance,

      BRK.Customer                    as BrokerCode,
      BRK.FullName                    as BrokerName,

      B.ShipToParty                   as ShipTo,
      
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      B.NetAmount                     as SalesOrderMaterialValue,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SGST.ConditionAmount            as SGST,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      IGST.ConditionAmount            as IGST,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CGST.ConditionAmount            as CGST,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      RND.ConditionAmount             as Roundoff
}
