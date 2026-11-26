@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO Slab Master Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZQM_C_SLAB 
as projection on ZQM_I_SLAB
{
    key Uuid,
    key Plangroup,
    key Boocharacteristic,
    key Granduuid,
    Slabno,
    Minusplus,
    Fromslab,
    Fromuom,
    Toslab,
    Touom,
    Debitcreditindicator,
    Currency,
    @Semantics.amount.currencyCode: 'Currency'
    Amount,
    Amountnew,
    Perrate,
    Poqtyuom,
    Fromslabamt,
    Toslabamt,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Header : redirected to ZQM_C_HEAD,
    _ItemMIC : redirected to parent ZQM_C_MIC
}
