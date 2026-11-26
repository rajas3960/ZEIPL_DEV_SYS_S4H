@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport Master Value Help'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMM_BP_ZTRP_VH 
  as select from I_BusinessPartner
{
  key BusinessPartner     as Transporterid,
      BusinessPartnerName as Transportername
}
where
      BusinessPartnerCategory = '2'
  and BusinessPartnerGrouping = 'ZTRP'
