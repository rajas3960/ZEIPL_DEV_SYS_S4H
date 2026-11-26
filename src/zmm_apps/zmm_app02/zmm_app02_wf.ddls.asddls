@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow For Purchase Order Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APP02_WF
as select from ZMM_PUR_REG_AUT2 as AUT2
inner join I_WorkflowStatusOverview as WFO on WFO.SAPBusinessObjectNodeKey1 = AUT2.PurchaseOrder

inner join I_WorkflowStatusDetails as WFS  on WFS.WorkflowInternalID = WFO.WorkflowInternalID
                                          and WFS.WrkflwTskCompletionUTCDateTime = AUT2.secTime
left outer join  I_BusinessUserBasic  as BUS on BUS.UserID  = WFS.WorkflowTaskProcessor                                       
//inner join I_WorkflowStatusDetails as WFS on WFS.WorkflowInternalID = AUT2.PurchaseOrder
//                                          and WFS.WrkflwTskCompletionUTCDateTime = AUT2.secTime
//left outer join I_WorkflowStatusOverview as WFS on WFS.SAPBusinessObjectNodeKey1 = PO.PurchaseOrder
//left outer join I_WorkflowStatusDetails as WFSD on WFSD.WorkflowInternalID = 
//                                                and WFSD.

                                                
//                                                and WFSD.WorkflowTaskProcessor <> ''
{
    key AUT2.PurchaseOrder,
        WFS.WorkflowTaskProcessor,
        AUT2.secTime,
        BUS.PersonFullName
}

