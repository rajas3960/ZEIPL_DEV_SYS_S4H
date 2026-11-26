@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for the  Sales LC Utilization'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZLC_APP02_VH as select from zlc_app01_tb1 as h
left outer join zlc_app01_tb2 as i on i.lnum = h.lnum 
{
    key h.lnum as Lnum,
    key h.stp,
    @Semantics.amount.currencyCode: 'Lccurr'
    sum( cast( i.tlcamt as abap.curr( 15, 2 ))) as lcamt,
    i.lccurr as Lccurr

}where h.relstastu = 'A'
group by
h.lnum,
h.stp,
i.lccurr
