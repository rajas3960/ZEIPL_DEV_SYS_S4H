@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Weighment Overall Sum Net Qty'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_SUM_WTNET 
as select from zmm_app04_idb as a
inner join zmm_app04_hdb as b on b.uuid = a.uuid
{
    key a.uuid as Uuid,
        cast ( b.grosswt as abap.dec(13,3)) as Grosswt,
    sum( cast( a.netweight as abap.dec( 13, 3 ))) as Netweight
}
group by a.uuid,
         b.grosswt
         
