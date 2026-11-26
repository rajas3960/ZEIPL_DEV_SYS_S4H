@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_T
as select from I_PurchaseOrderAPI01 as PO
//left outer join I_PurchaseOrderHistoryAPI01 as POH on POH.PurchaseOrder = POI.PurchaseOrder
//                                                  and POH.PurchaseOrderItem = POI.PurchaseOrderItem
left outer join I_WorkflowStatusOverview as WFSO on WFSO.SAPBusinessObjectNodeKey1 = PO.PurchaseOrder
left outer join I_WorkflowStatusDetails as WFSD on WFSD.WorkflowInternalID = WFSO.WorkflowInternalID
left outer join I_BusinessUserBasic as BUB on BUB.UserID = WFSD.WorkflowTaskProcessor

{
   key PO.PurchaseOrder as PurchaseOrder,
       WFSD.WorkflowTaskProcessor as Id,
       WFSD.WrkflwTskCompletionUTCDateTime as Time,
       BUB.PersonFullName as Name
      
}         

where WFSO.NmbrOfCmpltdWrkflwDialogTasks <> 0 
and WFSD.WorkflowTaskExternalStatus = 'COMPLETED'
















//as select from I_PurchaseOrderItemAPI01 as POI
//
//left outer join I_PurchaseOrderHistoryAPI01 as POH on POH.PurchaseOrder = POI.PurchaseOrder
//
//                                                  and POH.PurchaseOrderItem = POH.PurchaseOrderItem
//                                                  
//                                                  
// key POI.PurchaseOrder,
//
//     key POI.PurchaseOrderItem,   
//
//     @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
//
//         POI.OrderQuantity,
//
//         POI.PurchaseOrderQuantityUnit,
//
//    @Semantics.quantity.unitOfMeasure: 'POHUNIT'        
//
//         sum( POH.Quantity ) as Quantity,
//
//         POH.PurchaseOrderQuantityUnit as POHUNIT,
//
//         POI.IsCompletelyDelivered
//
//
//
//
//
//}
//
//where POH.PurchasingHistoryCategory = 'E'
//
//group by POI.PurchaseOrder,
//
//         POI.PurchaseOrderItem,
//
//         POI.OrderQuantity,
//
//         POI.PurchaseOrderQuantityUnit,
//
//         POH.PurchaseOrderQuantityUnit,
//
//         POI.IsCompletelyDelivered                                                  
//                                                  
