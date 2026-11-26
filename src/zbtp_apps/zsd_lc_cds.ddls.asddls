@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Custom LC Screen CDS view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_LC_CDS 
as select from ZLC_APP02_RV
{
    key SalesDocument,
    Balance_amt 
}
