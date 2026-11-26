@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Credit - Debit Memo Amount View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_SUMAMT 
as select from zqm_kpi_db
{
  key inspectionlot,
  sum(amtvalue) as Amtvalue    
}
group by inspectionlot
