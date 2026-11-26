@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Specification'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZQM_C_INSP 
as projection on ZQM_I_INSP
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
    key Inspectionlot,
    Inspectiondate,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Inspectionlotqty,
    Inspectionlottype,
    Materialdocument,
    Materialdocumentyear,
    Materialdocumentitem,
    @ObjectModel.text.element: [ 'Usagedecisiontext' ]
    Usagedecisioncode,
    Usagedecisiontext,
    Createindicator,
    Updateindicator,
    Udcodeindicator,
    Reference,
    Postingdate,
    Supplierinvoice,
    Fiscalyear,
    Documentcurrency,
    @Semantics.amount.currencyCode: 'Documentcurrency'
    Totalamt,
    Postinvoiceflag,
    Suppllier,
    Taxcode,
    Paymentterms,
    Inspindicator,
    Getspindicator,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _InspKPI : redirected to composition child ZQM_C_KMIC,
    _POHead : redirected to parent ZQM_C_PO
}
