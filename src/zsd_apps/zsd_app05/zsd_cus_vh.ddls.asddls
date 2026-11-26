@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_CUS_VH 
as select from zsd_app09_idb as a
left outer join I_Customer_VH as b on b.Customer = a.customer
{
    @UI.hidden: true
    key a.subuuid as uuid,
    key a.customer as Customer,
    
        b.CustomerName

}
////where a.dispatchdate = $session.system_date
group by a.subuuid,
         a.customer,
         b.CustomerName
