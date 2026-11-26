@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor View help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_VENDOR_V as select from I_Supplier as sup
left outer join I_Address_2 as add on add.AddressID = sup.AddressID
{
   key sup.Supplier,
   key add.AddressID,
   add.OrganizationName1,
   add._EmailAddress.EmailAddress 
}
