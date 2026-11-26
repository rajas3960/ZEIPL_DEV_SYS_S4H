@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Credit - Debit Note Amount View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZQM_DEBIT_AMT 
as select from zqm_mic_db as a
{
    key a.uuid as Uuid,
    sum( a.amtvalue ) as Amtvalue

}
group by a.uuid
