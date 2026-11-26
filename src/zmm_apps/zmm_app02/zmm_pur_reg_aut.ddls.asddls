@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register Authorization'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_PUR_REG_AUT 
as select from I_PurchaseOrderAPI01       as PO
 left outer join I_WorkflowStatusOverview      as  WFS   on WFS.SAPBusinessObjectNodeKey1 = PO.PurchaseOrder
    
 left outer join I_WorkflowStatusDetails       as  WFSD  on WFSD.WorkflowInternalID = WFS.WorkflowInternalID
                                                            and WFSD.WorkflowTaskProcessor <> ''
                                                            
 left outer join I_BusinessUserBasic as BUB on BUB.UserID = WFSD.WorkflowTaskProcessor
{
    key PO.PurchaseOrder,
//    key POI.PurchaseOrderItem,
      //  WFSD.WorkflowTaskProcessor,
       min( WFSD.WrkflwTskCompletionUTCDateTime) as Time,
       //BUB.PersonFullName as STLEVL,
       max( BUB.PersonFullName ) as STLEVL,
       'L1'as LE
      // WFSD.WorkflowTaskProcessor
       
}
//where WFSD.WorkflowTaskExternalStatus = 'COMPLETED' 
group by
    PO.PurchaseOrder
   // WFSD.WorkflowTaskProcessor
//    BUB.PersonFullName
//    POI.PurchaseOrderItem
   // WFSD.WorkflowTaskProcessor

