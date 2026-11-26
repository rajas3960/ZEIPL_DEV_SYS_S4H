@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register Authorization3'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_AUT3
as select from I_PurchaseOrderAPI01       as PO
 left outer join I_WorkflowStatusOverview      as  WFS   on WFS.SAPBusinessObjectNodeKey1 = PO.PurchaseOrder
    
 left outer join I_WorkflowStatusDetails       as  WFSD  on WFSD.WorkflowInternalID = WFS.WorkflowInternalID
                                                            and WFSD.WorkflowTaskProcessor <> ''
 left outer join I_BusinessUserBasic as BUB on BUB.UserID = WFSD.WorkflowTaskProcessor  
{
    key PO.PurchaseOrder,
//    key POI.PurchaseOrderItem,      
    max( WFSD.WrkflwTskCompletionUTCDateTime) as finalTime,
    min(BUB.PersonFullName) as RDFULLNAME,
    'L3'as LE
       
}
group by
    PO.PurchaseOrder
//    POI.PurchaseOrderItem






















 
//as select from ZMM_PUR_REG_T 
//
//{
//
//    key PurchaseOrder,
//    key PurchaseOrderItem,
//    @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
//    OrderQuantity,
//    PurchaseOrderQuantityUnit,
//    @Semantics.quantity.unitOfMeasure: 'POHUNIT'
//    Quantity,
//    POHUNIT,
//    IsCompletelyDelivered,
//    cast(
//  case
//    when IsCompletelyDelivered = 'X'
//    then
//      coalesce( OrderQuantity, 0 )
//      - coalesce( Quantity, 0 )
//
//    else 0
//  end
//  as abap.dec(15,3)
//) as CancelQuantity
//    
//
//}






