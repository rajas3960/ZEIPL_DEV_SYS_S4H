@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Code Ratio'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZTAXRATE as select from I_TaxCodeRate as a
inner join I_TaxCodeText as b on b.TaxCode = a.TaxCode
                              and b.Language = $session.system_language

{
    key a.TaxCode,
    cast( sum( a.ConditionRateRatio ) as abap.dec(15,2) ) as TotalConditionRateRatio,
    a.ConditionRateRatioUnit,
    b.TaxCodeName
}
group by a.TaxCode,
         a.ConditionRateRatio,
         a.ConditionRateRatioUnit,
         b.TaxCodeName
