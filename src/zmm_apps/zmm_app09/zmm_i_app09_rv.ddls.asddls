@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manage Email Master Root View Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_I_APP09_RV as select from ZMM_VENDOR_V as ven
left outer join zmm_a_app09_htb as cis on cis.supplier = ven.Supplier and cis.addressid = ven.AddressID
{
    key ven.Supplier,
    key ven.AddressID,
    ven.OrganizationName1,
    ven.EmailAddress,
    cis.passcode,
    cis.status
    
}
