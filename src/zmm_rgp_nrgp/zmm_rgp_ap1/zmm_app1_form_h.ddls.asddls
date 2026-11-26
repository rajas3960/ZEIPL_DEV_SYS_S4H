@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Form Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APP1_FORM_H 
as select from I_Product as PRD
inner join I_ProductDescription as PDC on PDC.Product = PRD.Product
                                      and PDC.Language = $session.system_language

{
   
   key PRD.Product,
   PDC.ProductDescription,
   PRD.BaseUnit
   
   
    
}
