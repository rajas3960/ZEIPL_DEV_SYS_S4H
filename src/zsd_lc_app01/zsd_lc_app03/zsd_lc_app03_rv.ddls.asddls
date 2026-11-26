@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LC Approval -  Custom Screen Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_LC_APP03_RV
  as select from    ZLC_APP01_RV  as h
    left outer join ZLC_APP01_IV1 as i on i.Lnum = h.Lnum
  association [1..1] to zsd_app03_st as stus on stus.name = $projection.relstastu
{
  key h.Lnum,
      h.Banknam,
      h.BankBranch,
      h.Stp,
      h.StpName,
      @Semantics.amount.currencyCode: 'LcCurr'
      h.TlcAmt,
      h.LcCurr,
      h.Createdby,
      h.Createdon,
      h.Torlce,
      h.relstastu,
      stus.text,
      case stus.name
      when 'A'
      then 3
      else 1 end   as stuscrt,
      h.approveby,
      h.approveon,
      h.Valfrm,
      h.Valto,
      h.Lastchangedby,
      h.Lastchangedon,
      h.Project,
      h.Applicant,
      h.Ldd,
      h.Mark,
      h.Beneficiary,
      h.Incoterm,
      h.Remark,
      h.Popi,
      @Semantics.amount.currencyCode: 'LcCurr'
      h.Aclcamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      h.Planlcamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      h.Totboeamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      h.Totavamt,
      @Semantics.amount.currencyCode: 'LcCurr'
      sum(i.LcAmt) as LcAmt
}
group by
  h.Lnum,
  h.Banknam,
  h.BankBranch,
  h.Stp,
  h.StpName,
  h.TlcAmt,
  h.LcCurr,
  h.Createdby,
  h.Createdon,
  h.Torlce,
  h.relstastu,
  h.approveby,
  h.approveon,
  h.relstu,
  h.Valfrm,
  h.Valto,
  h.Lastchangedby,
  h.Lastchangedon,
  h.Project,
  h.Applicant,
  h.Ldd,
  h.Mark,
  h.Beneficiary,
  h.Incoterm,
  h.Remark,
  h.Totalqty,
  h.Popi,
  h.Aclcamt,
  h.Planlcamt,
  h.Totboeamt,
  h.Totavamt,
  stus.text,
    stus.name
