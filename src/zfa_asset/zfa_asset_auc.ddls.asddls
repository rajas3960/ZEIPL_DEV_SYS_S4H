@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset AUC List'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_ASSET_AUC
  as select from I_JournalEntryItem
{
  key CompanyCode,
  key MasterFixedAsset,
  key FixedAsset,
      PartnerMasterFixedAsset,
      PartnerFixedAsset
}
where
      Ledger                  = '0L'
  and MasterFixedAsset        is not initial
  and FixedAsset              is not initial
  and PartnerMasterFixedAsset is not initial
  and PartnerFixedAsset       is not initial
  and IsReversal              is initial
  and IsReversed              is initial
group by
  CompanyCode,
  MasterFixedAsset,
  FixedAsset,
  PartnerMasterFixedAsset,
  PartnerFixedAsset
