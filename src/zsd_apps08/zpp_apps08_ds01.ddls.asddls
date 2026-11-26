@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Details'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZPP_APPS08_DS01
  as select from ZPP_APPS08_DS
{
  key Customer,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( Cgst_amt ) as Cgst_amt,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( Sgst_amt ) as Sgst_amt,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( Igst_amt ) as Igst_amt,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( tot_Utilized ) as tot_Utilized,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum(
        cast(
          cast( coalesce(Cgst_amt,0) as abap.dec(15,2) )
        + cast( coalesce(Sgst_amt,0) as abap.dec(15,2) )
        + cast( coalesce(Igst_amt,0) as abap.dec(15,2) )
        + cast( coalesce(tot_Utilized,0) as abap.dec(15,2) )
          as abap.dec(15,2)
        )
      ) as TotalAmount,

//      Curr as TransactionCurrency,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(sum( NetAmount ) as abap.dec( 15, 2 )) as NetAmount,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
     cast( sum( TaxAmount )as abap.dec( 15, 2 )) as TaxAmount,

//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum(
        cast(
          cast( NetAmount as abap.dec(15,2) )
        + cast( TaxAmount as abap.dec(15,2) )
          as abap.dec(15,2)
        )
      ) as totnetamt
}
group by
  Customer
