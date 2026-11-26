@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help For Tax code'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsd_Taxxode_v4
  as select from   DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZTAX_CODE' )
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Optimization'
      @ObjectModel.text.element: [ 'text' ]
      value_low as name,
      @Semantics.text: true
      text,
      case
      when value_low = '10' then cast( '0'  as abap.char(2) )
      when value_low = '1A' then cast( '5'  as abap.char(2) )
      when value_low = '1B' then cast( '12' as abap.char(2) )
      when value_low = '1C' then cast( '18' as abap.char(2) )
      when value_low = '1E' then cast( '0'  as abap.char(2) )
      when value_low = '1F' then cast( '5'  as abap.char(2) )
      when value_low = '1G' then cast( '12' as abap.char(2) )
      when value_low = '1H' then cast( '18' as abap.char(2) )
      when value_low = '2A' then cast( '0'  as abap.char(2) )
      when value_low = '2C' then cast( '0' as abap.char(2) )
      when value_low = '2F' then cast( '0'  as abap.char(2) )
      when value_low = '2H' then cast( '0' as abap.char(2) )
      when value_low = '3A' then cast( '5'  as abap.char(2) )
      when value_low = '3B' then cast( '18' as abap.char(2) )
      when value_low = '3E' then cast( '5'  as abap.char(2) )
      when value_low = '3F' then cast( '18' as abap.char(2) )
      else cast( '0' as abap.char(2) )
      end       as Percentage
}
