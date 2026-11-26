@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HEADER DETAILS OF SALES UTILIZATION'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_HDE03
  as select from    ZLC_APP02_HDE02 as h
    left outer join zlc_app02_idb   as i on i.salesdocument = h.SalesDocument
{
  key h.SalesDocument,

      h.TransactionCurrency,

      sum( cast( i.lcamount as abap.dec( 15, 2 )) ) as TotLCamt,

      @EndUserText.label: 'Utilized Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case
        when cast( h.biTot_Utilized as abap.dec( 31, 2 ) )
           > cast( h.Tot_Utilized as abap.dec( 31, 2 ) )
        then cast( h.biTot_Utilized as abap.dec( 31, 2 ) )
        else cast( h.Tot_Utilized as abap.dec( 31, 2 ) )
      end                                           as Utilized_amt,

      @EndUserText.label: 'Balance Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(
      sum(
        cast( i.lcamount as abap.dec( 31, 2 ) )
      ) as abap.dec( 31, 2 )
      )
      -
      case
      when coalesce(cast(  h.biTot_Utilized as abap.dec( 31, 2 )) ,0)
       > cast( coalesce( h.Tot_Utilized, 0 ) as abap.dec( 31, 2 ) )
      then coalesce(cast(h.biTot_Utilized as abap.dec( 31, 2 ) ),0)
      else cast( coalesce( h.Tot_Utilized, 0 ) as abap.dec( 31, 2 ) )
      end                                           as Balance_amt


}
group by
  h.SalesDocument,
  h.TransactionCurrency,
  h.biTot_Utilized,
  h.Tot_Utilized
