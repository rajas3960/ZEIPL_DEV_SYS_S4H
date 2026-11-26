@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LC Master Maintainence B Line Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZLC_APP01_IPV2 as select from ZLC_APP01_IV2
{
    key vbeln,
    key Lnum,
    key Lcline,
    @EndUserText.label: 'BOE No::'
   key Boeno,
    Boedt,
    Dudt,  
    @Semantics.quantity.unitOfMeasure : 'Unit'
    Boeqty,
    Unit,
       @Semantics.amount.currencyCode: 'Boecurr'
    Instdebt,
      @Semantics.amount.currencyCode: 'Boecurr'
    Fright,
      @Semantics.amount.currencyCode: 'Boecurr'
    Tboeamt,
      @Semantics.amount.currencyCode: 'Boecurr'
    Boeamt,
    Boecurr,
    Createdby,
    Createdon
    /* Associations */
//    _Hdr : redirected to parent ZLC_APP01_RPV
}
