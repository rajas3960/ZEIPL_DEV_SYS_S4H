@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LCApproval-Custom Screen Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_LC_APP03_PV
  provider contract transactional_query
  as projection on ZSD_LC_APP03_RV
{
  key Lnum,
      Banknam,
      BankBranch,
      Stp,
      StpName,
      @Semantics.amount.currencyCode: 'LcCurr'
      TlcAmt,
      LcCurr,
      Createdby,
      Createdon,
      Torlce,
      @Semantics.amount.currencyCode: 'LcCurr'
      LcAmt,      
      Valfrm,
      Valto,
      Lastchangedby,
      Lastchangedon,
      Project,
      Applicant,
      Ldd,
      Mark,
      relstastu,
      text,
      stuscrt,
      Beneficiary,
      Incoterm,
      Remark,
      Popi,
      @Semantics.amount.currencyCode: 'LcCurr'
      Aclcamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      Planlcamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      Totboeamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      Totavamt
}
