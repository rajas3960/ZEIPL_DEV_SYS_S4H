@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESERVATION HEADER consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZRESERVATION_HDR_C
  provider contract transactional_query
  as projection on ZRESERVATION_HDR_I
{
  key Requino,
     @ObjectModel.text.element: ['PlantName']
      Div,
      @ObjectModel.text.element: ['CostCenterDescription']
      cost,
      @ObjectModel.text.element: ['GoodsMovementTypeName']
      Stocktype,
      batchno,
          issueto,
      //    issueno,
      //    issuedt,
      RequiDt,
      @ObjectModel.text.element: ['PersonFullName']
      Preparedby,
      PlantName,
      CostCenterDescription,
      PersonFullName,
      GoodsMovementTypeName,
      @ObjectModel.text.element: ['ProductDescription']
      Product,
      ProductDescription,
      @Semantics.largeObject: {   mimeType: 'mimetype', 
                                fileName: 'filename', 
                                contentDispositionPreference: #INLINE }   
      attachment,
      filename,
      mimetype,
      /* Associations */
      _item : redirected to composition child ZRESERVATION_ITEM_C
}
