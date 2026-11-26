@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO Debit/Credit Master'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZQM_I_HEAD
  as select from zqm_app01_db as a
  composition [0..*] of ZQM_I_MIC  as _ItemMIC
  association [0..*] to ZQM_I_SLAB as _ItemSlab on $projection.Uuid = _ItemSlab.Uuid
{
  key a.uuid                 as Uuid,
      a.purchaseorder        as Purchaseorder,
      a.purchaseorderitem    as Purchaseorderitem,
      a.orderdate            as Orderdate,
      a.companycode          as Companycode,
      a.companycodename      as Companycodename,
      a.plant                as Plant,
      a.plantname            as Plantname,
      a.baseunit             as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.orderquantity        as Orderquantity,
      a.documentcurrency     as Documentcurrency,
      @Semantics.amount.currencyCode: 'Documentcurrency'
      a.netamount            as Netamount,
      a.material             as Material,
      a.materialdes          as Materialdes,
      a.inspectionlot        as Inspectionlot,
      a.inspectiondate       as Inspectiondate,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.inspectionlotqty     as Inspectionlotqty,
      a.inspectionlottype    as Inspectionlottype,
      a.materialdocument     as Materialdocument,
      a.materialdocumentyear as Materialdocumentyear,
      a.materialdocumentitem as Materialdocumentitem,
      a.suppllier            as Suppllier,
      a.paymentterms         as Paymentterms,
      a.taxcode              as Taxcode,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      _ItemMIC,
      _ItemSlab
}
