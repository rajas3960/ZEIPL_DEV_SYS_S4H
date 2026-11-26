@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Tax Calculation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_PO_TAX 
  as select from    I_PurchaseOrderAPI01           as _POH
    inner join      I_PurchaseOrderItemAPI01       as _POI  on _POI.PurchaseOrder = _POH.PurchaseOrder
//    left outer join I_PurOrdItmPricingElementAPI01 as ZDGP on ZDGP.PurchaseOrder = _POI.PurchaseOrder
//                                                and ZDGP.PurchaseOrderItem = _POI.PurchaseOrderItem
//                                                and ZDGP.ConditionType = 'ZDGP'
//    left outer join I_PurOrdItmPricingElementAPI01 as ZDGV on ZDGV.PurchaseOrder = _POI.PurchaseOrder
//                                                and ZDGV.PurchaseOrderItem = _POI.PurchaseOrderItem
//                                                and ZDGV.ConditionType = 'ZDGV'
//    left outer join I_PurOrdItmPricingElementAPI01 as ZDNP on ZDNP.PurchaseOrder = _POI.PurchaseOrder
//                                                and ZDNP.PurchaseOrderItem = _POI.PurchaseOrderItem
//                                                and ZDNP.ConditionType = 'ZDNP'                                                     
{
  key _POI.PurchaseOrder,
  key _POI.PurchaseOrderItem,
      _POI.TaxCode,
      _POI.BaseUnit,
      _POI.DocumentCurrency,
      
      cast(_POI.OrderQuantity as abap.dec( 15, 3 )) as OrderQuantity,      
      cast(_POI.NetPriceAmount as abap.dec( 15, 2 )) as NetPriceAmount,
      cast(_POI.NetAmount as abap.dec( 15, 2 )) as NetAmount,
      case
           when _POI.TaxCode = '1C' then
                cast((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 18) / 100 as abap.dec( 15, 2 ))         // Tax rate IGST 18%
           when _POI.TaxCode = '1A' then
                cast((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 5) / 100 as abap.dec( 15, 2 ))         // Tax rate IGST 5%  
           when _POI.TaxCode = '1B' then
                cast((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 12) / 100 as abap.dec( 15, 2 ))         // Tax rate IGST 12%  
           when _POI.TaxCode = '10' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3A' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3B' then cast( 0 as abap.dec(15,2) )           
                else null end as IGSTAmount,
     
     case
           when _POI.TaxCode = '1F' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 5 ) / 100 ) / 2 as abap.dec( 15, 2 ))    // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1G' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 12 ) / 100 ) / 2 as abap.dec( 15, 2 ))   // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1H' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 18 ) / 100 ) / 2 as abap.dec( 15, 2 ))   // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1E' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3E' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3F' then cast( 0 as abap.dec(15,2) )                      
                else null end as CGSTAmount,
     case
           when _POI.TaxCode = '1F' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 5 ) / 100 ) / 2 as abap.dec( 15, 2 ))    // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1G' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 12 ) / 100 ) / 2 as abap.dec( 15, 2 ))   // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1H' then
                cast(((cast(_POI.NetAmount as abap.dec( 15, 2 )) * 18 ) / 100 ) / 2 as abap.dec( 15, 2 ))   // Tax Rate CGST/SGST 5%
           when _POI.TaxCode = '1E' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3E' then cast( 0 as abap.dec(15,2) )
           when _POI.TaxCode = '3F' then cast( 0 as abap.dec(15,2) )                                 
                else null end as SGSTAmount                
//     case
//            when ZDGP.ConditionType = 'ZDGP' then cast(ZDGP.ConditionAmount as abap.dec( 15, 2 ))
//            when ZDGV.ConditionType = 'ZDGV' then  cast(ZDGV.ConditionAmount as abap.dec( 15, 2 ))
//            when ZDNP.ConditionType = 'ZDNP'  then cast(ZDNP.ConditionAmount as abap.dec( 15, 2 ))
//            else null end as DiscountAmt             
      
   
}
