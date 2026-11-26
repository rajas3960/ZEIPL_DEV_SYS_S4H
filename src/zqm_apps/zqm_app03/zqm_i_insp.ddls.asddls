@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection GR Debit Memo'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_I_INSP
  as select from zqm_insp_db as a
  left outer join ZQM_SUMAMT as b on b.inspectionlot = a.inspectionlot
  association to parent ZQM_I_PO as _POHead on $projection.Uuid = _POHead.Uuid
                                    and $projection.Purchaseorder = _POHead.Purchaseorder
                                    and $projection.Purchaseorderitem = _POHead.Purchaseorderitem
  composition [0..*] of ZQM_I_KMIC as _InspKPI  
{
  key a.uuid                 as Uuid,
  key a.purchaseorder        as Purchaseorder,
  key a.purchaseorderitem    as Purchaseorderitem,
  key a.inspectionlot        as Inspectionlot,
      a.inspectiondate       as Inspectiondate,
      a.baseunit             as Baseunit,
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
      a.documentcurrency     as Documentcurrency,
      @Semantics.amount.currencyCode: 'Documentcurrency'
      b.Amtvalue             as Totalamt,
      a.postinvoiceflag      as Postinvoiceflag,
      a.suppllier            as Suppllier,
      a.taxcode              as Taxcode,
      a.paymentterms         as Paymentterms,
      a.inspindicator        as Inspindicator,
      a.getspindicator       as Getspindicator,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      _POHead,
      _InspKPI
}
