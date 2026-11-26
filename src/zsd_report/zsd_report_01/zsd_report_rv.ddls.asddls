@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Report Against Broker Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_REPORT_Rv
  as select from    I_BillingDocument              as b
    left outer join I_BillingDocumentItem          as Bi on Bi.BillingDocument = b.BillingDocument
    inner join      I_BusinessPartner              as sp on sp.BusinessPartner = b.SoldToParty
    left outer join I_BillingDocItemPartner       as bp on  bp.BillingDocument = b.BillingDocument
                                                        and bp.BillingDocumentItem = Bi.BillingDocumentItem
                                                         and bp.PartnerFunction = 'WE'
    left outer join I_BusinessPartner              as c  on c.BusinessPartner = bp.Customer
    left outer join I_SalesDocumentPartner         as BC on  BC.SalesDocument   = Bi.SalesDocument
                                                         and BC.PartnerFunction = 'ZB'
    left outer join I_BusinessPartner              as Bn on Bn.BusinessPartner = BC.Customer
    left outer join I_BillingDocumentItemPrcgElmnt as R  on  R.BillingDocument         =  b.BillingDocument
                                                         and R.BillingDocumentItem     =  Bi.BillingDocumentItem
                                                         and R.ConditionInactiveReason <> 'X'
                                                         and R.ConditionType           =  'ZPRO'
    left outer join I_BillingDocumentItemPrcgElmnt as bR on  bR.BillingDocument         =  b.BillingDocument
                                                         and bR.BillingDocumentItem     =  Bi.BillingDocumentItem
                                                         and bR.ConditionType           =  'ZCOQ'
                                                         and bR.ConditionInactiveReason <> 'X'
      left outer join I_SalesOrderItem as sd on sd.SalesOrder = Bi.SalesDocument
                                                and sd.SalesOrderItem = Bi.SalesDocumentItem
    left outer join zsd_billing_itb as it on it.sales_billing_no = ltrim( b.BillingDocument, '0' )
                                          and it.sales_billing_item = Bi.BillingDocumentItem


{
  key b.BillingDocument                                 as Billing_No,
  key Bi.BillingDocumentItem                            as billitem,
      Bi.SalesDocument                                  as SalesOredr,
      Bi.SalesDocumentItem                              as salesOrderitem,    
      sd.ReferenceSDDocument                            as Salescontract,
      sd.ReferenceSDDocumentItem                        as Salescontractitem,
      Bi.Plant                                          as PlantSupplier,
      b.BillingDocumentDate                             as Billing_Date,
      Bi.Product                                        as Material_Code,
      Bi.BillingDocumentItemText                        as Material_Desc,
      @Semantics.quantity.unitOfMeasure: 'uom'
      Bi.BillingQuantity                                as Qty,
      Bi.BillingQuantityUnit                            as uom,
      b.SoldToParty                                     as Customer_code,
      sp.BusinessPartnerFullName                        as Customer_Name,
      bp.Customer                                       as Consignee_Code,
      c.BusinessPartnerFullName                         as Consignee_Name,
      BC.Customer                                       as Broker_Code,
      Bn.BusinessPartnerFullName                        as Broker_Name,
      @Semantics.amount.currencyCode: 'curr'
      Bi.NetAmount                                      as Net_Value,
      Bi.TransactionCurrency                            as TransactionCurrency,
      @Semantics.amount.currencyCode: 'curr'
      Bi.TaxAmount                                      as Tax_Value,
      cast(R.ConditionRateValue as abap.dec( 15, 2 ) )  as Rate_value,
      bR.ConditionCurrency                              as curr,
      @Semantics.amount.currencyCode: 'curr'
      cast(bR.ConditionRateValue as abap.dec( 15, 2 ) ) as Broker_rate,
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      @Semantics.amount.currencyCode: 'curr'
      case
       when Bi.TransactionCurrency = 'USD'
       then cast(
         Bi.BillingQuantity * bR.ConditionRateValue
         as abap.dec(23,2)
       )
       else cast(
        bR.ConditionAmount
         as abap.dec(23,2)
       )
       end                                              as Broker_value,
      ' '                                               as Open_value,
      ' '                                               as Cleared_value,
      @Semantics.amount.currencyCode: 'currency_key'
      it.amount,
      it.currency_key,
      it.tax_code
} where b.BillingDocumentType = 'F2'
and b.BillingDocumentIsCancelled <> 'X'    
