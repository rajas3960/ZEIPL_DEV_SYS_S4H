@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For the Sale Order'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP01_SO as select from I_SalesDocument
{
    key SalesDocument as SalesDocument
}
