@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Number Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP }
@Search.searchable: true
define view entity ZMMGATE_NOVH 
as select from zmm_app03_db as a
left outer join ZGATE_NO_VH as b on b.value_low = a.gateno
{
  @UI.hidden: true
  key a.userid as Userid,
  @EndUserText.label: 'Gate Number'
  @Search.defaultSearchElement: true    
  key a.gateno as Gateno,
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Gate Des'
  b.text as Gatenodes
}
where a.userid = $session.user and
a.dept = 'MM'
