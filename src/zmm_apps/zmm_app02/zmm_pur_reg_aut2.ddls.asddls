@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register Authorization2'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_AUT2 
as select from I_PurchaseOrderAPI01       as PO
 left outer join I_WorkflowStatusOverview      as  WFS   on WFS.SAPBusinessObjectNodeKey1 = PO.PurchaseOrder
    
 left outer join I_WorkflowStatusDetails       as  WFSD  on WFSD.WorkflowInternalID = WFS.WorkflowInternalID
                                                         and WFSD.WorkflowTaskProcessor <> ''
 left outer join  ZMM_PUR_REG_AUT              as AUT     on AUT.PurchaseOrder = PO.PurchaseOrder
//                                                          and AUT.PurchaseOrderItem = POI.PurchaseOrderItem   
 left outer join I_BusinessUserBasic as BUB on BUB.UserID = WFSD.WorkflowTaskProcessor                                                  
{
    key PO.PurchaseOrder,
//    key POI.PurchaseOrderItem, 
    min(WFSD.WrkflwTskCompletionUTCDateTime) as secTime
//     BUB.PersonFullName as NDLEVEL,
//    'L2'as LE
    
}
where AUT.Time <> WFSD.WrkflwTskCompletionUTCDateTime
group by
    PO.PurchaseOrder
//    BUB.PersonFullName
//    POI.PurchaseOrderItem



