@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QM Manage PO Debit/Credit Master'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZQM_C_HEAD
  provider contract transactional_query
  as projection on ZQM_I_HEAD
{
  key Uuid,
      Purchaseorder,
      Purchaseorderitem,
      Orderdate,
      @ObjectModel.text.element: [ 'Companycodename' ]
      Companycode,
      Companycodename,     
      @ObjectModel.text.element: [ 'Plantname' ]
      Plant,
      Plantname,
      Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Orderquantity,
      Documentcurrency,
      @Semantics.amount.currencyCode: 'Documentcurrency'
      Netamount,
      @ObjectModel.text.element: [ 'Materialdes' ]
      Material,
      Materialdes,
      @Consumption.semanticObject: 'InspectionLot'
//      @Consumption.semanticObject: 'InspectionCharacteristic'     
      Inspectionlot,
      Inspectiondate,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'      
      Inspectionlotqty,
      Inspectionlottype,
      Materialdocument,
      Materialdocumentitem,
      Materialdocumentyear,
      Suppllier,
      Paymentterms,
      Taxcode,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdat,
      @Semantics.user.lastChangedBy: true
      Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      Lastchangedat,
      /* Associations */
      _ItemMIC : redirected to composition child ZQM_C_MIC,
      _ItemSlab : redirected to ZQM_C_SLAB
}
