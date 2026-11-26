@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Max Date Of Material Posting'
@Metadata.ignorePropagatedAnnotations: true
define view entity zmm_Maxdate as select from I_MaterialDocumentItem_2 as Md

{
    key Material,
    max( PostingDate ) as LastPostingDate
//    max( MaterialDocument ) as LastDocument
}
where GoodsMovementType = '101'
group by Material
