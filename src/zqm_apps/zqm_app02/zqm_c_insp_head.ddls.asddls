@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection Lot Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZQM_C_INSP_HEAD 
provider contract transactional_query
as projection on ZQM_I_INSP_HEAD
{
    key Uuid,
    Purchaseorder,
    Purchaseorderitem,
    Orderdate,
    @ObjectModel.text.element: [ 'Companycodename' ]    
    Companycode,
    Companycodename,
    @ObjectModel.text.element: [ 'Plantname' ]    
    Plant,
    Plantname,
    Baseunit,
    @Semantics.quantity.unitOfMeasure: 'Baseunit'
    Orderquantity,
    Documentcurrency,
    @Semantics.amount.currencyCode: 'Documentcurrency'
    Netamount,
    @ObjectModel.text.element: [ 'Materialdes' ]
    Material,
    Materialdes,
    Inspectionlot,
    Inspectiondate,
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
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    @Semantics.amount.currencyCode: 'Documentcurrency'    
    Totalamt,
    /* Associations */
    _InspResult : redirected to composition child ZQM_C_INSP_RESULT
}
