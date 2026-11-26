@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Type'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSALES_TYPE
  as select from I_BillingDocumentItem as BI

    left outer join I_SalesOrder as SO on SO.SalesOrder = BI.SalesDocument
                                       and BI.BillingDocumentType  = 'F2'

    left outer join I_CreditMemoRequest as CM on CM.CreditMemoRequest = BI.SalesDocument
                                              and BI.BillingDocumentType = 'G2'
    left outer join I_CustomerReturn as CR on CR.CustomerReturn = BI.SalesDocument
                                           and BI.BillingDocumentType = 'CBRE'
    left outer join I_DebitMemoRequest as DM  on DM.DebitMemoRequest = BI.SalesDocument
                                              and BI.BillingDocumentType = 'L2'
{
    key BI.BillingDocument,
    key BI.BillingDocumentItem,

    BI.BillingDocumentType,
    BI.SalesDocument,

    case
//        when BI.BillingDocumentType = 'F2'
             when SO.SalesOrderType = 'ZDOM'
            then 'Domestic'

        when 
             SO.SalesOrderType = 'ZEXP'
            then 'Export'

        when 
            SO.SalesOrderType = 'ZJOB'
            then 'Jobwork'

        when BI.BillingDocumentType = 'G2'
            then 'Credit memo'

        when BI.BillingDocumentType = 'L2'
            then 'Debit memo'

        when BI.BillingDocumentType = 'CBRE'
            then 'Return Order'
            
//         when CM.CreditMemoRequestType = 'CR'
//         then 'Credit Memo'
//         
//         when DM.DebitMemoRequestType = 'DR'
//         then 'Debit Memo'
        else null end as Saletype,
        SO.PurchaseOrderByCustomer as Customerref,
        SO.CustomerPurchaseOrderDate as Custrefdt
        
//    SO.SalesOrderType,
//    case when SO.SalesOrderType = 'ZDOM'
//    then 'Domestic'
//    when 
//             SO.SalesOrderType = 'ZEXP'
//            then 'Export'
//        when 
//            SO.SalesOrderType = 'ZJOB'
//            then 'Jobwork'
//        when SO.SalesOrderType = 'G2'
//            then 'Credit memo'
//        when SO.SalesOrderType = 'L2'
//            then 'Debit memo'
//        when SO.SalesOrderType = 'CBRE'
//            then 'Return Order' else null end as CreditMemoRequestType,
//    CR.CustomerReturnType,
//    DM.DebitMemoRequestType

}
