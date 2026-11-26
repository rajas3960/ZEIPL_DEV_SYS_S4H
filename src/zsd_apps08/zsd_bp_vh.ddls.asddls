@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Partner Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_BP_VH as select from I_BusinessPartner
{
    key BusinessPartner,
    BusinessPartnerName
    
}
