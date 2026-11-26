@EndUserText.label: 'Item Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZRES_FORMPRINT_ITEM_CLASS'
define custom entity ZRES_ITEM_CE

{
  key Reservation            : abap.char( 10 );
  key Reservationitem        : abap.char( 4 );
  key MaterialDocument       : abap.char( 10 );
  key MaterialDocumentItem   : abap.char( 4 );
      productcode            : abap.char( 40 );
      itemdetails            : abap.char( 40 );
      um                     : abap.unit( 3 );
      @Semantics.quantity.unitOfMeasure: 'um'
      reqqty                 : abap.quan( 13, 3 );
      @Semantics.quantity.unitOfMeasure: 'um'
      issueqty               : abap.quan( 13, 3 );
      Currency               : abap.cuky( 5 );
      @Semantics.amount.currencyCode: 'Currency'
      rate                   : abap.curr( 11, 2 );
      @Semantics.amount.currencyCode: 'Currency'
      provamt                : abap.curr( 13, 2 );
      ProductWithDescription : abap.char( 83 );
      StorageLocation        : abap.char( 4 );
      Storagelocationname    : abap.char( 23 );
      Remark                 : abap.char( 50 );

}
