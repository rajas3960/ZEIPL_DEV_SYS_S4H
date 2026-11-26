 @AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Contract Report - Root View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZSD_SC_REPORT_RV
  as select from    I_SalesContract        as Header

    inner join      I_SalesContractItem    as Item       on Header.SalesContract = Item.SalesContract

    left outer join I_SalesContractPartner as Partner    on  Header.SalesContract    = Partner.SalesContract
                                                         and Partner.PartnerFunction = 'WE'

    left outer join ZSD_SC_ORDER_QTY       as OrderQty   on  OrderQty.SalesContract     = Header.SalesContract
                                                         and OrderQty.SalesContractItem = Item.SalesContractItem

    left outer join ZSD_SC_INVOICE_QTY     as InvoiceQty on  InvoiceQty.SalesContract     = Header.SalesContract
                                                         and InvoiceQty.SalesContractItem = Item.SalesContractItem

    left outer join I_Customer             as SoldTo     on Header.SoldToParty = SoldTo.Customer

    left outer join I_Customer             as ShipTo     on Partner.Customer = ShipTo.Customer

    left outer join ZSD_SC_ORDER_TRAKING   as SO         on  SO.ReferenceSDDocument         = Item.SalesContract
                                                         and SO.ReferenceSDDocumentItem     = Item.SalesContractItem
                                                         and SO.ReferenceSDDocumentCategory = 'G'

    left outer join ZSD_SC_FIRST_SO        as FirstSO    on  FirstSO.SalesContract     = Item.SalesContract
                                                         and FirstSO.SalesContractItem = Item.SalesContractItem
{
  key Header.SalesContract                  as SalesContract,
  key Item.SalesContractItem                as SalesContractItem,
  key SO.SalesOrder                         as SalesOrder,
  key SO.SalesOrderItem                     as SalesOrderItem,

      Item.Product                          as MaterialCode,
      Item.SalesContractItemText            as MaterialDescription,
      Header.SoldToParty                    as SoldToParty,
      SoldTo.CustomerName                   as SoldToPartyDescription,
      Partner.Customer                      as ShipToParty,
      ShipTo.CustomerName                   as ShipToPartyDescription,
      Header.SalesContractValidityStartDate as ContractValidFrom,
      Header.SalesContractValidityEndDate   as ContractValidTo,

      Item.TransactionCurrency              as Currency,

@Semantics.amount.currencyCode: 'Currency'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then Item.NetPriceAmount
           else cast( 0 as abap.curr( 15, 2 ) ) end            as ContractRateValue,

      @Semantics.amount.currencyCode: 'Currency'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then Item.NetAmount
           else cast( 0 as abap.curr( 15, 2 ) ) end            as ContractNetValue,

      @Semantics.amount.currencyCode: 'Currency'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then Item.TaxAmount
           else cast( 0 as abap.curr( 15, 2 ) ) end            as ContractTaxValue,

      Item.RequestedQuantityUnit            as Unit,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then cast( Item.RequestedQuantity as abap.quan( 15, 3 ) )
           else cast( 0 as abap.quan( 15, 3 ) ) end            as ContractQuantity,

      coalesce( OrderQty.RequestedQuantityUnit, Item.RequestedQuantityUnit ) as Requnit,
      @Semantics.quantity.unitOfMeasure: 'Requnit'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then cast( coalesce( OrderQty.TotalSalesOrderQty, 0 ) as abap.quan( 15, 3 ) )
           else cast( 0 as abap.quan( 15, 3 ) ) end            as TotalSalesOrderQty,

      coalesce( InvoiceQty.BaseUnit, Item.RequestedQuantityUnit )            as BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then cast( coalesce( InvoiceQty.InvoicedQty, 0 ) as abap.quan( 15, 3 ) )
           else cast( 0 as abap.quan( 15, 3 ) ) end            as InvoicedQty,

      Item.RequestedQuantityUnit            as BalanceUnit,
      @Semantics.quantity.unitOfMeasure: 'BalanceUnit'
      case when FirstSO.FirstKey is null
             or FirstSO.FirstKey = concat( SO.SalesOrder, SO.SalesOrderItem )
           then cast( coalesce( Item.RequestedQuantity, 0 )
                    - coalesce( InvoiceQty.InvoicedQty, 0 ) as abap.quan( 15, 3 ) )
           else cast( 0 as abap.quan( 15, 3 ) ) end            as BalanceQty,

      SO.SalesOrderDate                     as SalesOrderDate,
      SO.CustomerReference                  as CustomerReference,
      SO.CustomerReferenceDate              as CustomerReferenceDate,
      SO.Division                           as Division,
      SO.HSNCode                            as HSNCode,
      SO.ShipTo                             as SOShipTo,
      SO.BrokerCode                         as BrokerCode,
      SO.BrokerName                         as BrokerName,

      SO.TransactionCurrency                as SOCurrency,
      @Semantics.amount.currencyCode: 'SOCurrency'
      SO.NetAmount                          as SONetAmount,
      @Semantics.amount.currencyCode: 'SOCurrency'
      SO.SGST                               as SGST,
      @Semantics.amount.currencyCode: 'SOCurrency'
      SO.CGST                               as CGST,
      @Semantics.amount.currencyCode: 'SOCurrency'
      SO.IGST                               as IGST,
      @Semantics.amount.currencyCode: 'SOCurrency'
      SO.Roundoff                           as Roundoff,

      SO.BaseUnit                           as SOUnit,
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      SO.SalesOrderQty                      as SOQty,
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      cast( SO.InvoicedQty as abap.quan( 15, 3 ) )        as SOInvoicedQty,
      
      @Semantics.quantity.unitOfMeasure: 'SOUnit'
      cast( SO.SalesOrderBalance as abap.quan( 15, 3 ) )  as SOBalanceQty
}


////*************************   manoj routh ****************************

//define root view entity ZSD_SC_REPORT_RV
//  as select from    I_SalesContract        as Header
//
//    inner join      I_SalesContractItem    as Item       on Header.SalesContract = Item.SalesContract
//
//    left outer join I_SalesContractPartner as Partner    on  Header.SalesContract    = Partner.SalesContract
//                                                         and Partner.PartnerFunction = 'WE'
//
//    left outer join ZSD_SC_ORDER_QTY       as OrderQty   on  OrderQty.SalesContract     = Header.SalesContract
//                                                         and OrderQty.SalesContractItem = Item.SalesContractItem
//
//    left outer join ZSD_SC_INVOICE_QTY     as InvoiceQty on  InvoiceQty.SalesContract     = Header.SalesContract
//                                                         and InvoiceQty.SalesContractItem = Item.SalesContractItem
//
//    left outer join I_Customer             as SoldTo     on Header.SoldToParty = SoldTo.Customer
//
//    left outer join I_Customer             as ShipTo     on Partner.Customer = ShipTo.Customer
//    
//    
//{
//  key Header.SalesContract                  as SalesContract,
//  key Item.SalesContractItem                as SalesContractItem,
//      Item.Product                          as MaterialCode,
//      Item.SalesContractItemText            as MaterialDescription,
//      //      @Semantics.quantity.unitOfMeasure: 'Unit'
//      //      Item.RequestedQuantity                as ContractQuantity,
//      //      Item.RequestedQuantityUnit            as Unit,
//      @Semantics.amount.currencyCode: 'Currency'
//      Item.NetPriceAmount                   as ContractRateValue,
//      Item.TransactionCurrency              as Currency,
//      @Semantics.amount.currencyCode: 'Currency'
//      Item.NetAmount                        as ContractNetValue,
//      @Semantics.amount.currencyCode: 'Currency'
//      Item.TaxAmount                        as ContractTaxValue,
//      Header.SoldToParty                    as SoldToParty,
//      SoldTo.CustomerName                   as SoldToPartyDescription,
//      Partner.Customer                      as ShipToParty,
//      ShipTo.CustomerName                   as ShipToPartyDescription,
//      Header.SalesContractValidityStartDate as ContractValidFrom,
//      Header.SalesContractValidityEndDate   as ContractValidTo,
//      //      @Semantics.quantity.unitOfMeasure: 'Requnit'
//      //      OrderQty.TotalSalesOrderQty           as TotalSalesOrderQty,
//      //      OrderQty.RequestedQuantityUnit        as Requnit,
//      //      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
//      //      InvoiceQty.InvoicedQty,
//      //      InvoiceQty.BaseUnit                   as BaseUnit,
//      //      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
//      //      cast(
//      //        coalesce( Item.RequestedQuantity, 0 )
//      //        - coalesce( InvoiceQty.InvoicedQty, 0 )
//      //        as abap.quan( 15, 3 )
//      //      )                                     as BalanceQty,
//
//      // Contract Quantity
//      @Semantics.quantity.unitOfMeasure: 'Unit'
//      Item.RequestedQuantity                as ContractQuantity,
//      Item.RequestedQuantityUnit            as Unit,
//
//      // Total Sales Order Quantity
//      @Semantics.quantity.unitOfMeasure: 'Requnit'
//      cast(
//        coalesce( OrderQty.TotalSalesOrderQty, 0 )
//        as abap.quan(15,3)
//      )                                     as TotalSalesOrderQty,
//
//      coalesce(
//        OrderQty.RequestedQuantityUnit,
//        Item.RequestedQuantityUnit
//      )                                     as Requnit,
//
//      // Invoiced Quantity
//      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
//      cast(
//        coalesce( InvoiceQty.InvoicedQty, 0 )
//        as abap.quan(15,3)
//      )                                     as InvoicedQty,
//
//      coalesce(
//        InvoiceQty.BaseUnit,
//        Item.RequestedQuantityUnit
//      )                                     as BaseUnit,
//
//
//      // Balance Quantity
//      @Semantics.quantity.unitOfMeasure: 'BalanceUnit'
//      cast(
//        coalesce( Item.RequestedQuantity, 0 )
//        - coalesce( InvoiceQty.InvoicedQty, 0 )
//        as abap.quan(15,3)
//      )                                     as BalanceQty,
//
//      Item.RequestedQuantityUnit            as BalanceUnit
//
//}
