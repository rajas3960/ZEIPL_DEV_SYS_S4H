@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Report RV'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_ASSET_RV
  as select from    I_FixedAsset                   as FAS
    left outer join ZFA_ASSET_VALUE                as FA   on  FA.CompanyCode      = FAS.CompanyCode
                                                           and FA.FixedAsset       = FAS.FixedAsset
                                                           and FA.MasterFixedAsset = FAS.MasterFixedAsset
                                                           and FA.Currency         = 'INR'
    left outer join ZFA_ASSET_AUC                  as AUC  on  AUC.CompanyCode      = FAS.CompanyCode
                                                           and AUC.FixedAsset       = FAS.FixedAsset
                                                           and AUC.MasterFixedAsset = FAS.MasterFixedAsset
    left outer join ZFA_ASSET_VALUE                as AU   on  AU.CompanyCode      = AUC.CompanyCode
                                                           and AU.FixedAsset       = AUC.PartnerFixedAsset
                                                           and AU.MasterFixedAsset = AUC.PartnerMasterFixedAsset
                                                           and AU.Currency         = 'INR'
    left outer join I_FixedAsset                   as AUCE on  AUCE.CompanyCode      = AUC.CompanyCode
                                                           and AUCE.FixedAsset       = AUC.PartnerFixedAsset
                                                           and AUCE.MasterFixedAsset = AUC.PartnerMasterFixedAsset
    left outer join ZFA_AUC                        as AUCI on  AUCI.CompanyCode      = AUC.CompanyCode
                                                           and AUCI.FixedAsset       = AUC.PartnerFixedAsset
                                                           and AUCI.MasterFixedAsset = AUC.PartnerMasterFixedAsset
    left outer join I_EntProjWrkBrkdwnStrucElmntVH as WBSE on  WBSE.WBSElementInternalID = AUCI.WBSElementInternalID
                                                           and WBSE.CompanyCode          = AUCI.CompanyCode
    left outer join ZFA_ASSET_SI                   as SI   on SI.WBSElementInternalID = AUCI.WBSElementInternalID
    left outer join I_Supplier                     as SUP  on SUP.Supplier = SI.Supplier
    left outer join ZFA_ALL                        as ALLd on  ALLd.CompanyCode          = AUC.CompanyCode
                                                           and ALLd.MasterFixedAsset     = AUC.PartnerMasterFixedAsset
                                                           and ALLd.FixedAsset           = AUC.PartnerFixedAsset
                                                           and ALLd.WBSElementInternalID = SI.WBSElementInternalID
                                                           and ALLd.AUCAmt               = SI.ItemAmount
{
  key FAS.CompanyCode,
  key FAS.FixedAsset,
  key FAS.MasterFixedAsset,
  key AUC.PartnerMasterFixedAsset                                    as AssetUnderConstruction,
  key AUCI.WBSElementInternalID,
  key SI.SupplierInvoice,
      FAS.FixedAssetExternalID,
      AUCE.FixedAssetExternalID                                      as AUCExternalID,
      WBSE.ProjectElement                                            as WBSElementExternalID,
      WBSE.Project,
      FA.Currency                                                    as Curr,
      @Semantics.amount.currencyCode: 'Curr'
      //      FA.TotalAmount              as FA_Amount,
      ALLd.FAAmt                                                     as FA_Amount,
      @Semantics.amount.currencyCode: 'Curr'
      //      cast( coalesce( cast( AU.TotalAmount as abap.dec( 23, 2 ) ), 0 ) - coalesce( cast( FA.TotalAmount as abap.dec( 23, 2 ) ), 0 ) as abap.curr( 23, 2 ) ) as AUC_Amount,
      //      AU.TotalAmount              as AUC_Amount,
      case when ALLd.FAAmt is null then ALLd.AUCAmt else null end as AUC_Amount,
      @Semantics.amount.currencyCode: 'Curr'
      //      WBS.AmountInCompanyCodeCurrency as WBS_Amount,
      SI.ItemAmount                                                  as WBS_Amount,
      SI.Supplier,
      SUP.SupplierFullName                                           as SupplierName
}
