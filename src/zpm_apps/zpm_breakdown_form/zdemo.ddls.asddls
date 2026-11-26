@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Demo'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDEMO 
as select from I_GLAccountText 

{
   
    key GLAccount,   
    GLAccountName

}
where Language = 'E'
group by GLAccount, GLAccountName
