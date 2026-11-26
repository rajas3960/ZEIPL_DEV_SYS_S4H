@EndUserText.label: 'Carrier Allocation Excel Upload'
define root abstract entity ZMM_A_TMUPLOAD
{
  @Semantics.largeObject: { mimeType: 'MimeType',
                            fileName: 'FileName',
                            acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                            contentDispositionPreference: #INLINE }
  @EndUserText.label: 'Excel File (.xlsx)'
  Attachment : abap.rawstring(0);
  @UI.hidden: true
  @Semantics.mimeType: true
  MimeType   : abap.char(128);
  @UI.hidden: true
  FileName   : abap.char(255);
}
