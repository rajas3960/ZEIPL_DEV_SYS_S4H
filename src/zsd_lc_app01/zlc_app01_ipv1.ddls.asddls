@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LC Master Maintainence Line Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZLC_APP01_IPV1
  as projection on ZLC_APP01_IV1
{
  key Lnum,
  key Lcline,
      Valfrm,
      Valto,
      Boeno,
      Boedt,
      Dudt,
      @Semantics.quantity.unitOfMeasure:'Unit'
      Boeqty,
      Unit,
      @Semantics.amount.currencyCode : 'Boecurr'
      Instdebt,
      @Semantics.amount.currencyCode : 'Boecurr'
      Fright,
      @Semantics.amount.currencyCode : 'Boecurr'
      Tboeamt,
      @Semantics.amount.currencyCode : 'Boecurr'
      Tlcamt,
      Torlce,
      Amtno,
      Amtdt,
      @Semantics.amount.currencyCode: 'Boecurr'
      Boeamt,
      Boecurr,
      Noofdays,
      Accbstus,
      @Semantics.amount.currencyCode: 'LcCurr'
      LcAmt,
      LcCurr,
      Remark,
      Mark,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdon,
      Inst,
      /* Associations */
      _Hdr : redirected to parent ZLC_APP01_RPV
}
