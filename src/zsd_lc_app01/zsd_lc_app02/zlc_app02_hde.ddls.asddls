@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HEADER DETAILS OF SALES UTILIZATION'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_HDE
  as select from    I_SalesDocument              as S

    left outer join I_SalesDocumentItem          as si on si.SalesDocument = S.SalesDocument

    left outer join I_DeliveryDocumentItem       as d  on  d.ReferenceSDDocument  = S.SalesDocument
                                                       and d.Material             = si.Material
                                                       and d.DeliveryDocumentItem = si.SalesDocumentItem
                                                       and d.GoodsMovementStatus  = 'C'

    left outer join I_SalesDocItemPricingElement as cg on  cg.SalesDocument     = S.SalesDocument
                                                       and cg.SalesDocumentItem = si.SalesDocumentItem
                                                       and cg.ConditionType     = 'JOCG'

    left outer join I_SalesDocItemPricingElement as sg on  sg.SalesDocument     = S.SalesDocument
                                                       and sg.SalesDocumentItem = si.SalesDocumentItem
                                                       and sg.ConditionType     = 'JOSG'

    left outer join I_SalesDocItemPricingElement as ig on  ig.SalesDocument     = S.SalesDocument
                                                       and ig.SalesDocumentItem = si.SalesDocumentItem
                                                       and ig.ConditionType     = 'JOIG'

    left outer join I_BillingDocumentItem        as b  on  b.SalesDocument     = S.SalesDocument
                                                       and b.SalesDocumentItem = si.SalesDocumentItem

{
  key S.SalesDocument,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(
        sum(
          cast(
            cast(
              d.ActualDeliveredQtyInBaseUnit
                as abap.dec(15,2)
            ) *
            cast(
              si.NetPriceAmount
                as abap.dec(15,2)
            )
            as abap.dec(15,2)
          ) *
          cast(
            cg.ConditionRateRatio
              as abap.dec(15,2)
          ) / 100
        ) as abap.dec(15,2)
      )                     as Cgst_amt,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(
        sum(
          cast(
            cast(
              d.ActualDeliveredQtyInBaseUnit
                as abap.dec(15,2)
            ) *
            cast(
              si.NetPriceAmount
                as abap.dec(15,2)
            )
            as abap.dec(15,2)
          ) *
          cast(
            sg.ConditionRateRatio
              as abap.dec(15,2)
          ) / 100
        ) as abap.dec(15,2)
      )                     as Sgst_amt,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(
        sum(
          cast(
            cast(
              d.ActualDeliveredQtyInBaseUnit
                as abap.dec(15,2)
            ) *
            cast(
              si.NetPriceAmount
                as abap.dec(15,2)
            )
            as abap.dec(15,2)
          ) *
          cast(
            ig.ConditionRateRatio
              as abap.dec(15,2)
          ) / 100
        ) as abap.dec(15,2)
      )                     as Igst_amt,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(
        sum(
          cast(
            cast(
              d.ActualDeliveredQtyInBaseUnit
                as abap.dec(15,2)
            ) *
            cast(
              si.NetPriceAmount
                as abap.dec(15,2)
            )*  cast(S.PriceDetnExchangeRate as abap.dec( 7, 2 ))
            as abap.dec(15,2)
          )
        ) as abap.dec(15,2)
      )                     as tot_Utilized,

      si.TransactionCurrency,

      @Semantics.amount.currencyCode: 'Curr'
      sum(
        cast(
          b.NetAmount as abap.curr(15,2)
        )
      )                     as NetAmount,

      b.TransactionCurrency as Curr,

      @Semantics.amount.currencyCode: 'Curr'
      sum(
        cast(
          b.TaxAmount as abap.curr(15,3)
        )
      )                     as TaxAmount

}

group by
  S.SalesDocument,
  si.TransactionCurrency,
  b.TransactionCurrency
