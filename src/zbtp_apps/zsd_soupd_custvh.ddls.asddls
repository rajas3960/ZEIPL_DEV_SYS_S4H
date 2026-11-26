@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry - Customer VH for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_SOUPD_CUSTVH
  as select from I_Customer_VH
{
  key Customer,
      CustomerName
}
