@EndUserText.label: 'Material Details Parameter'
define abstract entity ZFI_MD_INPUT
{
  @EndUserText.label    : 'Material Description'
  purchaseorderitemtext : abap.char(40);
  @EndUserText.label    : 'HSN/SAC Code'
  hsncode               : abap.char(16);
  @Semantics.quantity.unitOfMeasure: 'baseunit'
  @EndUserText.label    : 'Quantity'
  quantity              : abap.quan(13,3);
  @EndUserText.label    : 'UOM'
  baseunit              : abap.unit(3);
  @EndUserText.label    : 'PO Rate'
  rate                  : abap.dec(15,2);
}
