@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Address for BTP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_SUP_ADD 
as select from I_Supplier as Sup
inner join I_Address_2 as ADD on ADD.AddressID = Sup.AddressID 
                                and ADD.Region = Sup.Region
{
   key Sup.Supplier,
   key ADD.AddressID,
   Sup.SupplierName,
   Sup.StreetName,
   Sup.BPAddrStreetName,
   Sup.TaxNumber3 as GSTIN,
   Sup.CityName,
   Sup.PostalCode,
   Sup.BusinessPartnerPanNumber as PAN,
   Sup.PhoneNumber2 as phone,    
   Sup.Region,   
   Sup._EmailAddress.EmailAddress
   }  
