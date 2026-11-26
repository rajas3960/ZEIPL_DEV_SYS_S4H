@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Group Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_MATGROUP_VH 
as select from I_ProductGroup
{
    key MaterialGroup as Materialgroup,
    _Text.MaterialGroupName
}
