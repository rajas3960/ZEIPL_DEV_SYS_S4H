@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Document partner function'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_PARTNER 
as select from I_SalesOrderPartner
{
    key SalesOrder,
    key PartnerFunction,
    Customer,
    AddressID,
    AddressPersonID
}
