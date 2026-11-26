@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transporter ID Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_BP_TRP_VH
  as select from I_BusinessPartner
{
  key BusinessPartner     as Transporterid,
      BusinessPartnerName as Transportername
}
where
      BusinessPartnerCategory = '2'
  and BusinessPartnerGrouping = 'ZTRP'
