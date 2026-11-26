@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Lot Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZQM_I_INSP_HEAD
  as select from zqm_app01_db as a
  left outer join ZQM_DEBIT_AMT as b on b.Uuid = a.uuid
  composition [0..*] of ZQM_I_INSP_RESULT as _InspResult
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
      a.usagedecisioncode    as Usagedecisioncode,
      a.usagedecisiontext    as Usagedecisiontext,
      a.createindicator      as Createindicator,
      a.updateindicator      as Updateindicator,
      a.udcodeindicator      as Udcodeindicator,
      a.reference            as Reference,
      a.postingdate          as Postingdate,
      a.supplierinvoice      as Supplierinvoice,
      a.fiscalyear           as Fiscalyear,
      a.postinvoiceflag      as Postinvoiceflag,
      a.suppllier            as Suppllier,
      a.paymentterms         as Paymentterms,
      a.taxcode              as Taxcode,
      a.inspindicator        as Inspindicator,
      a.createdby            as Createdby,
      a.createdat            as Createdat,
      a.lastchangedby        as Lastchangedby,
      a.lastchangedat        as Lastchangedat,
      b.Amtvalue             as Totalamt,
      _InspResult
}
