@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing document Tax Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBILLING_TAX 
as select from I_BillingDocumentItem as  a  
left outer join I_BillingDocumentItemPrcgElmnt as ZPRO  on ZPRO.BillingDocument = a.BillingDocument
                                                       and ZPRO.BillingDocumentItem = a.BillingDocumentItem
                                                       and ZPRO.ConditionType = 'ZPRO' 
left outer join I_BillingDocumentItemPrcgElmnt as JOCG  on JOCG.BillingDocument = a.BillingDocument
                                                       and JOCG.BillingDocumentItem = a.BillingDocumentItem
                                                       and JOCG.ConditionType = 'JOCG'
  left outer join I_BillingDocumentItemPrcgElmnt as JOSG  on JOSG.BillingDocument = a.BillingDocument
                                                       and JOSG.BillingDocumentItem = a.BillingDocumentItem
                                                       and JOSG.ConditionType = 'JOSG'
  left outer join I_BillingDocumentItemPrcgElmnt as JOIG  on JOIG.BillingDocument = a.BillingDocument
                                                       and JOIG.BillingDocumentItem = a.BillingDocumentItem
                                                       and JOIG.ConditionType = 'JOIG'   
 left outer join I_BillingDocumentItemPrcgElmnt as ZCOQ on ZCOQ.BillingDocument = a.BillingDocument
                                                       and ZCOQ.BillingDocumentItem = a.BillingDocumentItem
                                                       and ZCOQ.ConditionType = 'ZCOQ'  
 left outer join  I_BillingDocumentItemPrcgElmnt as JTC1  on JTC1.BillingDocument = a.BillingDocument
                                                         and JTC1.BillingDocumentItem = a.BillingDocumentItem
                                                         and JTC1.ConditionType = 'JTC1'                                                                                                                                                      
{
    key a.BillingDocument,
    key a.BillingDocumentItem,
    a.TransactionCurrency,
    cast(ZPRO.ConditionRateAmount * a.BillingQuantity as abap.dec( 14, 2 )) as Materialamt,
    cast(JOCG.ConditionAmount as abap.dec( 14, 2 )) as cgstamt,
    cast(JOSG.ConditionAmount as abap.dec( 14, 2 )) as sgstamt,
    cast(JOIG.ConditionAmount as abap.dec( 14, 2 )) as igstamt,
    cast(JOCG.ConditionRateValue as abap.dec( 14, 2 )) as cgstper,
    cast(JOSG.ConditionRateValue as abap.dec( 14, 2 )) as sgstper,
    cast(JOIG.ConditionRateValue as abap.dec( 14, 2 )) as igstper,
    cast(ZPRO.ConditionRateAmount as abap.dec( 14, 2 )) as BasicRate,
    cast(ZCOQ.ConditionAmount as abap.dec( 14, 2 )) as Brokervalue,
    cast(ZCOQ.ConditionRateValue as abap.dec( 14, 2 )) as Brokerrate,
    cast(JTC1.ConditionRateValue as abap.dec( 14, 2 )) as TCSrate,
    cast(JTC1.ConditionAmount as abap.dec( 14, 2 )) as TCSvalue
    
   
}
