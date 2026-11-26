@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Details Comparison'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZPP_APPS08_DS02
  as select from ZPP_APPS08_DS01
{
  key Customer,

      case
        when totnetamt > TotalAmount
          then totnetamt
        else TotalAmount
      end as Total_utlize
}
