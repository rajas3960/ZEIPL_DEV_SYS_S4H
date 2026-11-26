@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection GR Debit PO'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZQM_I_PO
  as select from zqm_app03_db as a
  composition [0..*] of ZQM_I_INSP  as _Insp
  association [0..*] to ZQM_I_KMIC as _InspKPI on $projection.Uuid = _InspKPI.Uuid
                                    and $projection.Purchaseorder =  _InspKPI.Purchaseorder
                                    and $projection.Purchaseorderitem = _InspKPI.Purchaseorderitem 
{
  key a.uuid              as Uuid,
  key a.purchaseorder     as Purchaseorder,
  key a.purchaseorderitem as Purchaseorderitem,
      a.orderdate         as Orderdate,
      a.companycode       as Companycode,
      a.companycodename   as Companycodename,
      a.plant             as Plant,
      a.plantname         as Plantname,
      a.baseunit          as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.orderquantity     as Orderquantity,
      a.documentcurrency  as Documentcurrency,
      @Semantics.amount.currencyCode: 'Documentcurrency'
      a.netamount         as Netamount,
      a.material          as Material,
      a.materialdes       as Materialdes,
      a.taxcode as Taxcode,
      a.suppllier as Suppllier, 
      a.paymentterms      as Paymentterms,
      @Semantics.user.createdBy: true
      a.createdby         as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat         as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby     as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat     as Lastchangedat,
      _Insp,
      _InspKPI
}
