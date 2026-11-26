@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Report PV'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZFA_ASSET_PV
  as projection on ZFA_ASSET_RV
{
  key CompanyCode,
      @UI.hidden: true
  key FixedAsset,
      @UI.hidden: true
  key MasterFixedAsset,
      @UI.hidden: true
  key AssetUnderConstruction,
      @UI.hidden: true
  key WBSElementInternalID,
  key SupplierInvoice,
      @EndUserText.label: 'Fixed Asset'
      FixedAssetExternalID,
      @EndUserText.label: 'Asset Under Construction'
      AUCExternalID,
      @EndUserText.label: 'WBS Element'
      WBSElementExternalID,
      @EndUserText.label: 'Project'
      Project,
      Curr,
      @Semantics.amount.currencyCode: 'Curr'
      FA_Amount,
      @Semantics.amount.currencyCode: 'Curr'
      AUC_Amount,
      @Semantics.amount.currencyCode: 'Curr'
      WBS_Amount,
      Supplier,
      SupplierName
}
