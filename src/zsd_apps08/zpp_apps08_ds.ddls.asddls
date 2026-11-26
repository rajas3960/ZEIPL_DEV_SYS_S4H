@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZPP_APPS08_DS
  as select from    I_SalesDocument              as sd
    left outer join I_SalesDocumentPartner       as S  on  S.SalesDocument   = sd.SalesDocument
                                                       and S.PartnerFunction = 'ZB'

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
    left outer join I_SalesDocument              as sa on sa.SalesDocument = S.SalesDocument

{
  key S.Customer,
      //  key S.SalesDocument,

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
            ) * cast(sa.PriceDetnExchangeRate as abap.dec( 7, 2 ))
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
where
  sd.DistributionChannel = '30'

group by
  S.Customer,
  //  S.SalesDocument,
  si.TransactionCurrency,
  b.TransactionCurrency
