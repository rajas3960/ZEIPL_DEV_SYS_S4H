@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for the  Sales LC Utilization'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_F4
  as select from    ZLC_APP02_VH    as m

    left outer join ZLC_APP02_UAMT  as i on i.Lnum = m.Lnum
{
  key m.Lnum,
      m.stp,
      m.Lccurr,
      @Semantics.amount.currencyCode: 'Lccurr'
      cast(
        cast(m.lcamt as abap.dec(15,2))
        -
        cast(
          coalesce(
            cast(i.UsedAmount as abap.dec(15,2)),
            cast(0 as abap.dec(15,2))
          )
          as abap.dec(15,2)
        )
        as abap.dec(15,2)
      ) as lcamt
}
where
  cast(
    cast(m.lcamt as abap.dec(15,2))
    -
    cast(
      coalesce(
        cast(i.UsedAmount as abap.dec(15,2)),
        cast(0 as abap.dec(15,2))
      )
      as abap.dec(15,2)
    )
    as abap.dec(15,2)
  ) > 0
