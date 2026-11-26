@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Billing App'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_BILLING_V4
  as select from ZSD_REPORT_RV02
{
        @Search.defaultSearchElement: true
  key   ltrim( Billing_No, '0' ) as BillingDocument,

  key   billitem                 as Item,
        @EndUserText.label: 'Billing Date'
        Billing_Date,
        @EndUserText.label: 'Broker Code'
        Broker_Code,
        @EndUserText.label: 'Broker Name'
        Broker_Name,
        PlantSupplier            as Plant,

        @Semantics.amount.currencyCode: 'TransactionCurrency'
        Broker_value             as NetValue,

        curr                     as TransactionCurrency,
        @UI.hidden: true
        case
         when PlantSupplier = '1001'
             then cast( '1001000611' as abap.numc(10) )

         when PlantSupplier = '1020'
             then cast( '1020020611' as abap.numc(10) )

         when PlantSupplier = '1030'
             then cast( '1030030611' as abap.numc(10) )

         when PlantSupplier = '1040'
             then cast( '1040050611' as abap.numc(10) )

         else cast( '0000000000' as abap.numc(10) )

        end                      as Costcenter,
        @UI.hidden: true
        '48130000'               as Gla,
        @EndUserText.label: 'Material Code'
        Material_Code,
        @EndUserText.label: 'Material Desc'
        Material_Desc,
        @Semantics.quantity.unitOfMeasure: 'uom'
        @EndUserText.label: 'Qty'
        Qty,
        @EndUserText.label: 'Uom'
        uom

}
