@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LC Master Maintainence'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZLC_APP01_RV
  as select from zlc_app01_tb1
  composition [0..*] of ZLC_APP01_IV1 as _Line
  //  composition [0..*] of ZLC_APP01_IV2 as _Lineboi
{
  key lnum          as Lnum,
      valfrm        as Valfrm,
      valto         as Valto,
      banknam       as Banknam,
      bankbranch    as BankBranch,
      stp           as Stp,
      stpname       as StpName,
      @Semantics.amount.currencyCode: 'LcCurr'
      tlcamt        as TlcAmt,
      @Semantics.amount.currencyCode: 'LcCurr'
      tlcutilz      as TlcUtilz,
      @Semantics.amount.currencyCode: 'LcCurr'
      totbalance    as TotBalance,
      lccurr        as LcCurr,
      @Semantics.user.createdBy: true
      createdby     as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdon     as Createdon,
      @Semantics.user.lastChangedBy: true
      lastchangedby as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedon as Lastchangedon,
      project       as Project,
      applicant     as Applicant,
      ldd           as Ldd,
      mark          as Mark,
      beneficiary   as Beneficiary,
      incoterm      as Incoterm,
      remark        as Remark,
      @Semantics.quantity.unitOfMeasure : 'unit'
      totalqty      as Totalqty,
      unit          as Unit,
      popi          as Popi,
      //      @Semantics.imageUrl: true
      //@Semantics.imageUrl: true
      //     _image.IMAGES as IMAGES,
      @Semantics.amount.currencyCode : 'LcCurr'
      aclcamt       as Aclcamt, // Actual LC Received(Total BOE Value)
      @Semantics.amount.currencyCode : 'LcCurr'
      planlcamt     as Planlcamt, //Planned Balance
      @Semantics.amount.currencyCode : 'LcCurr'
      totboeamt     as Totboeamt, //Total BOE Value
      @Semantics.amount.currencyCode : 'LcCurr'
      totavamt      as Totavamt,
      torlce        as Torlce,
      relstastu     as relstastu,
      case  when relstastu = 'A' 
      then 'Approved' 
      when relstastu = 'R'
      then 'Reject'
      else 'Not Approved' end as relstu,     
      approveby     as approveby,
      approveon     as approveon,
      _Line
      //      _Lineboi
}
