@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Counter measure description'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMAINT_CONT_DES as select from I_MaintOrderOperationBasic
//association to parent ZMAINTENANCE as _hdr on _hdr.MaintenanceNotification = $projection. 
{
    key MaintenanceOrder,
    key MaintenanceOrderOperation,
        OperationDescription
//        _hdr
}
