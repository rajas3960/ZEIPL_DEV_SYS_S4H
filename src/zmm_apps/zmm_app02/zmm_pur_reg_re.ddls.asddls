@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register - Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_RE
  as select from    I_PurchaseOrderItemAPI01       as POI
  
    left outer join I_PurchaseOrderAPI01           as PO    on PO.PurchaseOrder = POI.PurchaseOrder
    
    left outer join I_PurchaseOrderItemMonitor     as POIM  on  POIM.PurchaseOrder     = POI.PurchaseOrder
                                                            and POIM.PurchaseOrderItem = POI.PurchaseOrderItem
                                                                                                                     
    left outer join ZMM_PUR_REG_H                  as POH   on  POH.PurchaseOrder     = POI.PurchaseOrder
                                                            and POH.PurchaseOrderItem = POI.PurchaseOrderItem

    left outer join I_PurchaseRequisitionItemAPI01 as PRI   on  PRI.PurchaseRequisition     = POI.PurchaseRequisition
                                                            and PRI.PurchaseRequisitionItem = POI.PurchaseRequisitionItem

    left outer join I_SuplrInvcItemPurOrdRefAPI01  as SIPOR on  SIPOR.PurchaseOrder     = POI.PurchaseOrder
                                                            and SIPOR.PurchaseOrderItem = POI.PurchaseOrderItem
                                                            and SIPOR.ReferenceDocument = POH.ReferenceDocument
                                                            and SIPOR.ReferenceDocumentItem = POH.ReferenceDocumentItem
                                                            
    left outer join I_SupplierInvoiceAPI01   as suppinv     on suppinv.SupplierInvoice = SIPOR.SupplierInvoice
                                                            and suppinv.FiscalYear      = SIPOR.FiscalYear
                                                            
    
    left outer join I_Plant                        as PL    on PL.Plant = POI.Plant 
    
    left outer join I_ProductTypeText              as PTT   on  PTT.ProductType = POI.MaterialType
                                                            and PTT.Language    = $session.system_language  
                                                             
    left outer join I_Supplier                     as SUP   on SUP.Supplier = PO.Supplier   
    
    left outer join I_PurchasingGroup              as PG    on PG.PurchasingGroup = PO.PurchasingGroup  
    
    left outer join I_Plant                        as SPL   on SPL.Plant = PO.SupplyingPlant
                                                                                                             

//    left outer join ZMM_PUR_REG_T                  as ZPRT  on ZPRT.PurchaseOrder = PO.PurchaseOrder
//                                                           //and ZPRT.Id = PO.CreatedByUser

    left outer join      ZMM_PUR_REG_AUT                as ZPRA  on  ZPRA.PurchaseOrder     = PO.PurchaseOrder and ZPRA.LE = 'L1'
//                                                            and ZPRA.PurchaseOrderItem = POI.PurchaseOrderItem

//    left outer join      ZMM_PUR_REG_AUT2               as ZPRA2 on  ZPRA2.PurchaseOrder     = PO.PurchaseOrder and ZPRA2.LE = 'L2'
//                                                            and ZPRA2.PurchaseOrderItem = POI.PurchaseOrderItem

    left outer join      ZMM_PUR_REG_AUT3               as ZPRA3 on  ZPRA3.PurchaseOrder     = PO.PurchaseOrder and  ZPRA3.LE = 'L3'
//                                                            and ZPRA3.PurchaseOrderItem = POI.PurchaseOrderItem
    
    left outer join ZMM_APP02_WF                        as ZWF on ZWF.PurchaseOrder = PO.PurchaseOrder

{
  key POI.PurchaseOrder,
  key POI.PurchaseOrderItem,
  key POH.PurchasingHistoryDocument,
  key SIPOR.SupplierInvoice   as SupplierInvoice,
  key SIPOR.SupplierInvoiceItem as SupplierInvoiceItem,
  key SIPOR.FiscalYear as FiscalYear,
      POI.PurchaseRequisition,
      POI.Plant,
      POI.Material,
      POI.PurchaseOrderItemText,
      POI.BaseUnit,
      POI.MaterialType,
//      cast( POI.NetAmount as abap.dec( 15, 2 ) ) as NetAmount,
      case
       when PO.PurchaseOrderType = 'ZRVT'
       then cast( -1 * POI.NetAmount as abap.dec(15,2) )
      else
       cast( POI.NetAmount as abap.dec(15,2) )
      end as NetAmount,
      POI.DocumentCurrency          as POCurrency,
      POI.TaxCode,
//      cast ( POI.OrderQuantity as abap.dec( 15, 1 ) ) as OrderQuantity,
      case
       when PO.PurchaseOrderType = 'ZRVT'
       then cast( -1 * POI.OrderQuantity as abap.dec(15,1) )
      else
       cast( POI.OrderQuantity as abap.dec(15,1) )
      end as OrderQuantity,
//      cast( POI.NetPriceAmount as abap.dec( 11, 2 ) ) as NetPriceAmount,
      case
        when PO.PurchaseOrderType = 'ZRVT'
        then cast( -1 * POI.NetPriceAmount as abap.dec(11,2) )
      else
        cast( POI.NetPriceAmount as abap.dec(11,2) )
      end as NetPriceAmount,
      PO.CompanyCode,
      PO.PurchaseOrderDate,
//      PO.Supplier,
    case 
      when PO.PurchaseOrderType = 'ZSTO'
      then PO.SupplyingPlant
    else PO.Supplier
      end as Supplier,
      PO.PurchasingGroup,
      POIM.ScheduleLineDeliveryDate,
      POIM.PurchaseOrderQuantityUnit,
      cast( POIM.StillToBeDeliveredQuantity as abap.dec( 15, 3 ) ) as BalanceOrderQuantity,
      POH.PostingDate,
      POH.PurchaseOrderQuantityUnit as POHUnit,
//      POH.IsCompletelyDelivered as POHcompleted,
      cast( POH.Quantity as abap.dec( 13, 3 ) ) as Quantity,     
      POI.IsCompletelyDelivered,
      PRI.CreationDate,
  //    @Semantics.amount.currencyCode: 'POCurrency'
      case POI.TaxCode
      when '10'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(0 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1A'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(5 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1B'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(12 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1C'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(18 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      else null end                 as IGSTValue,

 //     @Semantics.amount.currencyCode: 'POCurrency'
      case POI.TaxCode
      when '1E'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(0 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1F'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(2.5 as abap.dec(13,3)) / cast(100 as abap.int2) as abap.dec( 13, 3 ))
      when '1G'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(6 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1H'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(9 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      else null end                 as CGSTValue,

 //     @Semantics.amount.currencyCode: 'POCurrency'
      case POI.TaxCode
      when '1E'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(0 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1F'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(2.5 as abap.dec(13,3)) / cast(100 as abap.int2) as abap.dec( 13, 3 ))
      when '1G'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(6 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      when '1H'
      then cast (POI.NetAmount as abap.dec (13, 2) ) * cast ( cast(9 as abap.dec(13,1)) / cast(100 as abap.int2) as abap.dec( 13, 2 ))
      else null end                 as SGSTValue,
      case POI.TaxCode
      when '10' then cast(0 as abap.dec(13,1))
      when '1A' then cast(5 as abap.dec(13,1))
      when '1B' then cast(12 as abap.dec(13,1))
      when '1C' then cast(18 as abap.dec(13,1))
      else null end                 as IGST,

      case POI.TaxCode
      when '1E' then cast(0 as abap.dec(13,1))
      when '1F' then cast(2.5 as abap.dec(13,1))
      when '1G' then cast(6 as abap.dec(13,1))
      when '1H' then cast(9 as abap.dec(13,1))
      else null end                 as CGST,

      case POI.TaxCode
      when '1E' then cast(0 as abap.dec(13,1))
      when '1F' then cast(2.5 as abap.dec(13,1))
      when '1G' then cast(6 as abap.dec(13,1))
      when '1H' then cast(9 as abap.dec(13,1))
      else null end                 as SGST,

      case POI.TaxCode
      when '10'
      then 'Input IGST 0%'
      when '1A'
      then 'Input IGST 5%'
      when '1B'
      then 'Input IGST 12%'
      when '1C'
      then 'Input IGST 18%'
      when '1D'
      then 'Input IGST 28%'
      when '1E'
      then 'Input CGST 0% + SGST 0%'
      when '1F'
      then 'Input CGST 2.5% + SGST 2.5%'
      when '1G'
      then 'Input CGST 6% + SGST 6%'
      when '1H'
      then 'Input CGST 9% + SGST 9%'
      else null     end             as TaxPercentage,

//     SIPOR.SupplierInvoice         as SupplierInvoice,
//      max(SIPOR.SupplierInvoice) as SupplierInvoice,
      PL.PlantName,
      PTT.MaterialTypeName,
//      SUP.SupplierName,
    case
      when PO.PurchaseOrderType = 'ZSTO'
      then SPL.PlantName
    else SUP.SupplierName
      end as SupplierName,
      PG.PurchasingGroupName,
      PO.PurchaseOrderType,
//      PO.SupplyingPlant,
//      SPL.PlantName as SupplyingPlantName

//      ZPRT.Id as WorkflowTaskProcessor,
//      BUB.PersonFullName,
      ZPRA.STLEVL as APP1,
      ZWF.PersonFullName as APP2,
//	  ZPRA3.RDFULLNAME as APP3
      case
    when ZPRA.STLEVL = ZPRA3.RDFULLNAME
      then cast( '' as abap.char(40) )

    when ZWF.PersonFullName = ZPRA3.RDFULLNAME
      then cast( '' as abap.char(40) )

    else ZPRA3.RDFULLNAME
 end as APP3,
 
 cast(
    cast( POI.NetPriceAmount as abap.dec(15,2) ) *
    cast( POH.Quantity as abap.dec(15,3) )
    as abap.dec(18,2)
) as GrnAmount,

suppinv.PostingDate as InvoiceDate,
suppinv.SupplierInvoiceIDByInvcgParty as InvoiceReferenceNumber,
PO.YY1_SupplierRefNo_PDH as SupplierReferenceNumber,
PO.YY1_SupplierRefDate_PDH as SupplierReferenceDate
	
	 
//	  ZPRA2.secTime as Level3Time,
	
	  
	  






}
group by
  POI.PurchaseOrder,
  POI.PurchaseOrderItem,
  POI.PurchaseRequisition,
  POI.Plant,
  POI.Material,
  POI.PurchaseOrderItemText,
  POI.BaseUnit,
  POI.MaterialType,
  POI.NetAmount,
  POI.DocumentCurrency,
  POI.TaxCode,
  POI.NetPriceAmount,
  PO.CompanyCode,
  PO.PurchaseOrderDate,
  PO.Supplier,
  PO.PurchasingGroup,
  POIM.ScheduleLineDeliveryDate,
  POIM.StillToBeDeliveredQuantity,
  POIM.PurchaseOrderQuantityUnit,
  POH.PostingDate,
  POH.PurchaseOrderAmount,
  POH.DocumentCurrency,
  POH.QtyInPurchaseOrderPriceUnit,
  POH.BaseUnit,
  POH.Quantity,
  POH.PurchaseOrderQuantityUnit,
  POI.IsCompletelyDelivered,
  PRI.CreationDate,
  SIPOR.SupplierInvoice,
  PL.PlantName,
  PTT.MaterialTypeName,
  SUP.SupplierName,
  PG.PurchasingGroupName,
  POI.OrderQuantity,
  PO.PurchaseOrderType,
  PO.SupplyingPlant,
  SPL.PlantName,
  POH.PurchasingHistoryDocument,
  SIPOR.SupplierInvoiceItem,
  SIPOR.FiscalYear,
//    POH.IsCompletelyDelivered
  ZPRA.STLEVL,
  ZPRA3.RDFULLNAME,
  ZWF.PersonFullName,
  suppinv.PostingDate,
  suppinv.SupplierInvoiceIDByInvcgParty,
   PO.YY1_SupplierRefNo_PDH,
   PO.YY1_SupplierRefDate_PDH    
    
     
//      ZPRA2.secTime,
    
   
      

  


