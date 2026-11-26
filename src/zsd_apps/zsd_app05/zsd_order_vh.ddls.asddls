@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_ORDER_VH
  as select from I_SalesDocument as a
  inner join I_SalesDocumentItem as c on c.SalesDocument = a.SalesDocument
left outer join I_Customer_VH as b on b.Customer = a.SoldToParty  
{
  key a.SalesDocument as SalesDocument,
      a.SoldToParty   as Customer,
      b.CustomerName      
}
where c.SDProcessStatus <> 'C'
group by a.SalesDocument,
         a.SoldToParty,
         b.CustomerName


//  as select from zsd_app09_idb as a
//left outer join I_Customer_VH as b on b.Customer = a.customer  
//{
//      @UI.hidden: true
//  key a.subuuid as Subuuid,
//  key a.salesorder as SalesDocument,
//      a.customer   as Customer,
//      b.CustomerName
//}
//////where a.dispatchdate = $session.system_date
//group by a.subuuid,
//         a.salesorder,
//         a.customer,
//         b.CustomerName 
