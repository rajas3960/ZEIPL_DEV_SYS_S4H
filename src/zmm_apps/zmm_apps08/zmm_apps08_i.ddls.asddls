@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoterms View Help v4'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_APPS08_I as select from I_IncotermsClassificationText
{
    key IncotermsClassification,
    key Language,
    IncotermsClassificationName,
    /* Associations */
    _IncotermsClassification,
    _Language
} 
