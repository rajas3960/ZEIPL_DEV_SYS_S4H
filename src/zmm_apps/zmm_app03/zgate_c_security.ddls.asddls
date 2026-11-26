@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Security Master Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZGATE_C_SECURITY 
provider contract transactional_query
as projection on ZGATE_I_SECURITY
{
    @ObjectModel.text.element: [ 'Usrname' ]
    key Userid,
    @ObjectModel.text.element: [ 'Gatenodes' ]
    key Gateno,
    @ObjectModel.text.element: [ 'Deptdes' ]    
    key Dept,
    Usrname,
    @ObjectModel.text.element: [ 'Plantname' ]
    Plant,
    Plantname, 
    WebsiteLinkText,
    Websiteurl,
    Websiteurl1,
    @ObjectModel.text.element: [ 'Createdname' ]
    Createdby,
    Createdname,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    Gatenodes,
    Deptdes
}
