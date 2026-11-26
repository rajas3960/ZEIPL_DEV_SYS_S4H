@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Batch Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]
@Search.searchable: true
define view entity ZSD_BATCH_VH
  as select from I_BatchStdVH
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key Batch,
  key Material,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH  
  key Plant

}
where Plant is not initial
