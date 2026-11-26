@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESERVATION HEADER INTERFACE'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZRESERVATION_HDR_I
  as select from ZRESERVATION_HDR
  composition [0..*] of ZRESERVATION_ITEM_I as _item

{
  key Requino,
      Div,
      cost,
      Stocktype,
      batchno,
          issueto,
      //    issueno,
      //    issuedt,
      RequiDt,
      Preparedby,
      PlantName,
      CostCenterDescription,
      PersonFullName,
      GoodsMovementTypeName,
      Product,
      ProductDescription,
      attachment,
      filename,
      mimetype,
      _item
}
