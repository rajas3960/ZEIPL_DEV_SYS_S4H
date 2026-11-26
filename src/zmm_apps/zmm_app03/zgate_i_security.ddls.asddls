@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Security Master Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZGATE_I_SECURITY
  as select from zmm_app03_db as a
  left outer join ZGATE_NO_VH as b on b.value_low = a.gateno
  left outer join ZGATE_DEPT_VH as c on b.value_low = a.dept  
{
  key a.userid        as Userid,
  key a.gateno        as Gateno,
  key a.dept          as Dept,
      a.usrname       as Usrname,
      a.plant         as Plant,
      a.plantname     as Plantname,
      a.createdname as Createdname,
      b.text as Gatenodes,
      c.text as Deptdes,
      cast(
  case
    when a.websiteurl1 is null or a.websiteurl1 = ''
      then ''
    else 'S4H System'
  end
  as abap.char(20)
) as WebsiteLinkText,
      a.websiteurl  as Websiteurl,
      a.websiteurl1 as Websiteurl1,
      @Semantics.user.createdBy: true
      a.createdby     as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat     as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat as Lastchangedat
}
