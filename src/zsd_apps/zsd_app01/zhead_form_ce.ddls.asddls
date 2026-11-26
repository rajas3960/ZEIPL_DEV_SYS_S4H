@EndUserText.label: 'From Print Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZFORM_IMP_CLASS'
define custom entity ZHEAD_FORM_CE
// with parameters parameter_name : parameter_type
{
  key uuid            : sysuuid_x16;
  plant             : werks_d;
  gateentrytype :abap.char(30);
  
}
