@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales register report'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSALES_REPORT
  as select from    I_BillingDocument             as a
    inner join      I_BillingDocumentItem         as b     on b.BillingDocument = a.BillingDocument
    left outer join ZBILLING_TAX                  as tax   on  tax.BillingDocument     = b.BillingDocument
                                                           and tax.BillingDocumentItem = b.BillingDocumentItem

    left outer join I_SalesDocumentItem           as c     on  c.SalesDocument     = b.SalesDocument
                                                           and c.SalesDocumentItem = b.SalesDocumentItem
    left outer join I_BusinessPartner             as d     on d.BusinessPartner = a.SoldToParty
    left outer join ZSALES_TYPE                   as stype on  stype.BillingDocument     = b.BillingDocument
                                                           and stype.BillingDocumentItem = b.BillingDocumentItem
    left outer join I_IN_ElectronicDocTransptRegn as ETR   on ETR.ElectronicDocSourceKey = b.BillingDocument
    left outer join I_IN_ElectronicDocInvoice     as EINV  on EINV.ElectronicDocSourceKey = b.BillingDocument
    left outer join I_SalesOrderPartner           as sop   on sop.SalesOrder = b.SalesDocument
                                                          and sop.PartnerFunction = 'ZB'
   left outer join       I_AccountingDocumentJournal (P_Language : 'E') as ADJ on  ADJ.AccountingDocument    =  a.AccountingDocument
                                                                                  and ADJ.Ledger                =  '0L' 
                                                                                  and ADJ.ReferenceDocument     =  b.BillingDocument
                                                                                  and ADJ.ReferenceDocumentItem =  b.BillingDocumentItem
                                                                                  and ADJ.BaseUnit              =  b.BaseUnit
                                                                                  and ADJ.SoldMaterial          <> ''                                                      
//   left outer join I_BillingDocumentPartner as bdp on bdp.BillingDocument = b.BillingDocument 
//                                                   and ( bdp.PartnerFunction = 'AG'or bdp.PartnerFunction = 'RE' )
left outer join I_BillingDocumentPartner as bdp_re
    on  bdp_re.BillingDocument = b.BillingDocument
    and bdp_re.PartnerFunction = 'RE'
left outer join I_Address_2 as adrs on adrs.AddressID = bdp_re.AddressID

left outer join I_BillingDocumentPartner as bdp_ag
    on  bdp_ag.BillingDocument = b.BillingDocument
    and bdp_ag.PartnerFunction = 'AG'
left outer join I_Address_2 as sadrs on sadrs.AddressID = bdp_ag.AddressID

//*********** changed by prudhvi***************************

left outer join I_BillingDocumentPartner as bdp_rg
    on  bdp_rg.BillingDocument = b.BillingDocument
    and bdp_rg.PartnerFunction = 'RG'
left outer join I_Address_2 as pyadrs on pyadrs.AddressID = bdp_rg.AddressID

left outer join I_BillingDocItemPartner as bdp_we
    on  bdp_we.BillingDocument     = b.BillingDocument
    and bdp_we.BillingDocumentItem = b.BillingDocumentItem
    and bdp_we.PartnerFunction     = 'WE'
left outer join I_Address_2 as shadrs on shadrs.AddressID = bdp_we.AddressID


//left outer join I_BillingDocItemPartner as bdp_we
//    on  bdp_we.BillingDocument = b.BillingDocument
//    and bdp_we.PartnerFunction = 'WE'
//left outer join I_Address_2 as shadrs on shadrs.AddressID = bdp_we.AddressID

//****************************************************************

     left outer join I_Customer as cus_re
    on cus_re.Customer = bdp_re.Customer

    left outer join I_Customer as cus_ag
    on cus_ag.Customer = bdp_ag.Customer  
 
// ****************prudhvi**********************************
    
    left outer join I_Customer as cus_rg
    on cus_rg.Customer = bdp_rg.Customer
    
    left outer join I_Customer as cus_we
    on cus_we.Customer = bdp_we.Customer
    
// ********************************************************   
    
//   left outer join I_Customer as cus on cus.Customer = bdp.Customer
//   left outer join I_BuPaIdentification as panid  on panid.BusinessPartner = d.BusinessPartner

left outer join I_BuPaIdentification as pan_re  on  pan_re.BusinessPartner = bdp_re.Customer
                                                    and ( pan_re.BPIdentificationType = 'ZPAN'
                                                       or pan_re.BPIdentificationType = 'PAN' )

    left outer join I_BuPaIdentification as pan_ag  on  pan_ag.BusinessPartner = bdp_ag.Customer
                                                    and ( pan_ag.BPIdentificationType = 'ZPAN'
                                                       or pan_ag.BPIdentificationType = 'PAN' )

    left outer join I_BuPaIdentification as pan_we  on  pan_we.BusinessPartner = bdp_we.Customer
                                                    and ( pan_we.BPIdentificationType = 'ZPAN'
                                                       or pan_we.BPIdentificationType = 'PAN' )

    left outer join I_BuPaIdentification as pan_rg  on  pan_rg.BusinessPartner = bdp_rg.Customer
                                                    and ( pan_rg.BPIdentificationType = 'ZPAN'
                                                       or pan_rg.BPIdentificationType = 'PAN' )
  
    left outer join I_SalesContract  as sc on sc.SalesContract = c.ReferenceSDDocument
    left outer join I_DeliveryDocument as dd on dd.DeliveryDocument = b.ReferenceSDDocument 
//    left outer join I_Businesspartnertaxnumber as gst on gst.BusinessPartner = d.BusinessPartner
//                                                     //and gst.BPTaxType = '9NP1'

left outer join I_Businesspartnertaxnumber as gst_re on gst_re.BusinessPartner = bdp_re.Customer                                                  
left outer join I_Businesspartnertaxnumber as gst_ag on gst_ag.BusinessPartner = bdp_ag.Customer                                                  
left outer join I_Businesspartnertaxnumber as gst_we on gst_we.BusinessPartner = bdp_we.Customer                                                 
left outer join I_Businesspartnertaxnumber as gst_rg on gst_rg.BusinessPartner = bdp_rg.Customer
                                                   
    left outer join I_ProductPlantBasic as ppb on ppb.Plant = b.Plant
                                              and ppb.Product = b.Material
                                              and ppb.ProfitCenter = b.ProfitCenter                                                 
         
//    left outer join I_ProductText as mattext on  mattext.Product = b.Material
//                                           and mattext.Language = $session.system_language                                                       
{
  key b.BillingDocument                                                                                      as Invno,
  key b.BillingDocumentItem,
      a.BillingDocumentDate                                                                                  as Invdate,
      a.SoldToParty                                                                                          as customercode,
      stype.Saletype,
      //a.BillingDocumentType as Saletype,
      a.Division                                                                                             as Division,
      b.Product,
      b.BillingDocumentItemText                                                                              as Productdes,
      b.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      b.BillingQuantityInBaseUnit                                                                            as invoiceqty,
     case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
     then tax.cgstamt * -1
     else tax.cgstamt end as cgstamt ,
      case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
     then tax.sgstamt * -1
     else tax.sgstamt end as sgstamt,
     case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
     then tax.igstamt * -1
     else tax.igstamt end as igstamt,
      tax.TransactionCurrency,
      case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
     then tax.Materialamt * -1
     else tax.Materialamt end as Materialamt,
      c.SalesDocument                                                                                        as salesorder,
      c.SalesDocumentDate                                                                                    as salesorderdt,
      d.BusinessPartnerFullName                                                                                       as Customername,

      //b.SoldToParty                                                                                          as Custpmercode,
      case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
      then cast( b.NetAmount as abap.dec(15,2) ) * -1 
      else  cast( b.NetAmount as abap.dec(15,2) ) 
      end as Netamount,
      case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
      then cast( b.TaxAmount as abap.dec(15,2) ) * -1
      else cast( b.TaxAmount as abap.dec(15,2) )  end as TaxAmount,
      tax.cgstper,
      tax.sgstper,
      tax.igstper,
   case when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
    then  tax.BasicRate * -1
    else tax.BasicRate end as BasicRate ,
   case  when b.BillingDocumentType = 'CBRE' or b.BillingDocumentType = 'G2'
    then cast( ( cast( b.NetAmount as abap.dec(15,2) )  + cast( b.TaxAmount as abap.dec(15,2) ) ) * -1 as abap.dec(15,2) )
    else
     cast((cast( b.NetAmount as abap.dec(15,2) ) +cast( b.TaxAmount as abap.dec(15,2) )) as abap.dec(15,2)) end as BillAmount,
      b.SalesOrganization,
      b.DistributionChannel                                                                                  as Salesdistribution,
      ETR.IN_EDocVehicleNumber                                                                               as Vehicleno,
      ETR.IN_ElectronicDocTransptrName                                                                       as Transportername,
      EINV.IN_ElectronicDocAcknNmbr                                                                          as EInvoiceAckNo,
      EINV.IN_ElectronicDocAcknDate                                                                          as EInvoiceAckDt,
      EINV.IN_ElectronicDocInvcRefNmbr                                                                       as EInvoiceIRN,
      ETR.IN_ElectronicDocEWbillNmbr                                                                         as EWaybillno,
      ETR.IN_EDocEWbillCreateDate                                                                           as EWaybillDt,
      ETR.IN_ElectronicDocVehicleType as CarrierType,
      ETR.IN_EDocTransptDocDate as LRchallandt,
      ETR.IN_EDocTransptDocNmbr as LRchallanno,
//      stype.SalesOrderType,
//      stype.CreditMemoRequestType,
//      stype.CustomerReturnType,
//      stype.DebitMemoRequestType,
      tax.Brokerrate,
      tax.Brokervalue,
      sop.Customer as Brokercode,
      sop.FullName as Brokername,
    
   bdp_re.Customer       as Billtocustomercode,
   bdp_ag.Customer       as Soldtocustomercode,
   bdp_we.Customer       as Shiptocustomercode,
   bdp_rg.Customer       as payercustomercode,
   
   cus_re.CustomerName   as Billtocustomername,
   cus_ag.CustomerName   as Soldtocustomername,
   cus_rg.CustomerName   as payercustomername,
   cus_we.CustomerName   as shiptocustomername,
   

case when stype.Saletype = 'Export' or stype.Saletype = 'Domestic'
     then gst_re.BPTaxNumber else cus_re.TaxNumber3 end                          as GSTnobillto,

case when stype.Saletype = 'Export' or stype.Saletype = 'Domestic'
     then gst_ag.BPTaxNumber else cus_ag.TaxNumber3 end                          as GSTnosoldto,

case when stype.Saletype = 'Export' or stype.Saletype = 'Domestic'
     then gst_we.BPTaxNumber else cus_we.TaxNumber3 end                          as GSTnoshipto,

case when stype.Saletype = 'Export' or stype.Saletype = 'Domestic'
     then gst_rg.BPTaxNumber else cus_rg.TaxNumber3 end                          as GSTnopayer,

pan_re.BPIdentificationNumber   as PANnobillto,
pan_ag.BPIdentificationNumber   as PANnosoldto,
pan_we.BPIdentificationNumber   as PANnoshipto,
pan_rg.BPIdentificationNumber   as PANnopayer,

     stype.Customerref,
     stype.Custrefdt,
     sc.SalesContract,
     sc.SalesContractDate,
     b.ReferenceSDDocument as Deliverychallanno,
     dd.ActualGoodsMovementDate as Deliverychallandt,
     b.Material as materialcode,
//     mattext.ProductName as materialname,
     tax.TCSrate,
     tax.TCSvalue,
     a.YY1_SDGateEntryNo_BDH as Gateentryno,
     a.YY1_GateEntryDate_BDH,
     a.YY1_GateEntryTime_BDH,
     ADJ.GLAccount as GLaccount,
     ADJ.GLAccountName as GLDescription,
     ppb.ConsumptionTaxCtrlCode as HSNcode,
 concat(concat(concat(concat(concat(concat(adrs.DistrictName, adrs.CityName), adrs.Country), adrs.StreetName), adrs.StreetPrefixName1), adrs.StreetPrefixName2), adrs.PostalCode) as BilltopartyAdrs,
     
 concat(concat(concat(concat(concat(concat(sadrs.DistrictName, sadrs.CityName), sadrs.Country), sadrs.StreetName), sadrs.StreetPrefixName1), sadrs.StreetPrefixName2), sadrs.PostalCode) as SoldtopartyAdrs,   
 
 concat(concat(concat(concat(concat(concat(pyadrs.DistrictName, pyadrs.CityName), pyadrs.Country), pyadrs.StreetName), pyadrs.StreetPrefixName1), pyadrs.StreetPrefixName2), pyadrs.PostalCode) as payerpartyAdrs,  
 
 concat(concat(concat(concat(concat(concat(shadrs.DistrictName, shadrs.CityName), shadrs.Country), shadrs.StreetName), shadrs.StreetPrefixName1), shadrs.StreetPrefixName2), shadrs.PostalCode) as shiptopartyadrs   
      


}
