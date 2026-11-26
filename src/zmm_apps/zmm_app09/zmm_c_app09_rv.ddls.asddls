@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Email Master Projection View Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_C_APP09_RV provider contract transactional_query
as projection on  ZMM_I_APP09_RV
{
    key Supplier,
    key AddressID,
    OrganizationName1,
    EmailAddress,
    passcode,
    status
}
