@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_ORDERITEM_VH
  as select from I_SalesDocumentItem as a
{
  key a.SalesDocument     as SalesDocument,
  key a.SalesDocumentItem as SalesDocumentItem,
      a.SoldToParty       as Customer,
      a.SalesDocumentItemText as ProductDescription
}
where SDProcessStatus <> 'C'
         
//  as select from zsd_app09_idb as a
//{
//    @UI.hidden: true
//  key a.subuuid        as Subuuid,
//  key a.salesorder     as Salesdocument,
//  key a.salesorderitem as SalesdocumentItem,
//      a.customer       as Customer,
//      a.material       as Material,
//      a.vehicleno as Vehicleno
//}
//////where a.dispatchdate = $session.system_date
//group by a.subuuid,
//         a.salesorder,
//         a.salesorderitem,
//         a.customer,
//         a.material,
//         a.vehicleno
//         
