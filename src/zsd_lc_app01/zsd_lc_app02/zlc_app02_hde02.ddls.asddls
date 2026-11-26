@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HEADER DETAILS OF SALES UTILIZATION'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_HDE02
  as select from ZLC_APP02_HDE as H
//  left outer join zlc_app02_idb as i on i.salesdocument = H.SalesDocument
{
  key H.SalesDocument,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
     cast( sum(
      cast( coalesce(H.Cgst_amt,0) as abap.dec( 15, 2 ) )
      + cast( coalesce(H.Sgst_amt,0) as abap.dec( 15, 2 ) )
      + cast( coalesce(H.Igst_amt,0) as abap.dec( 15, 2 ) )
      + cast( coalesce(H.tot_Utilized,0) as abap.dec( 15, 2 ) )
      ) as abap.dec( 15, 2 )) as Tot_Utilized,
      H.TransactionCurrency,
//     sum( cast( i.lcamount as abap.dec( 15, 2 )) )as TotLCamt,
     @Semantics.amount.currencyCode: 'TransactionCurrency'
     cast( H.NetAmount as abap.curr( 15, 2 ) ) + cast( H.TaxAmount as abap.curr( 15, 2 ))
     as  biTot_Utilized
     
     
}
group by
H.SalesDocument,
H.TransactionCurrency,
H.NetAmount,
H.TaxAmount




