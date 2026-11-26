@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Inspection GR Debit PO'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZQM_C_PO 
provider contract transactional_query
as projection on ZQM_I_PO
{
    key Uuid,
    key Purchaseorder,
    key Purchaseorderitem,
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
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Insp : redirected to composition child ZQM_C_INSP,
    _InspKPI : redirected to ZQM_C_KMIC
}
