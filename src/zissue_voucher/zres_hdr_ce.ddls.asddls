@EndUserText.label: 'RESERVATION HEADER CUSTOM ENTITY'
@ObjectModel.query.implementedBy: 'ABAP:ZRES_FORMPRINTING_CLASS'
define custom entity ZRES_HDR_CE

{
  key Reservation       : abap.char( 10 );
      cost              : abap.char( 10 );
      Stocktype         : abap.char( 3 );
      Batchno           : abap.char( 10 );
      issueto           : abap.char( 10 );
      issuedby          : abap.char( 80 );
      issueno           : abap.char( 10 );
      issuedt           : abap.char( 10 );
      Plant             : abap.char( 4 );
      RequiDt           : abap.dats;
      Preparedby        : abap.char( 12 );
      Department        : abap.char( 50 );
      plantName         : abap.char( 30 );
      Costcentername    : abap.char( 40 );
      movementtypename  : abap.char( 30 );
      Username          : abap.char( 80 );
      Chargable         : abap.char( 10 );
      PurchaseOrder     : abap.char( 10 );
      PurchaseOrderDate : bedat;
      Supplier          : abap.char( 10 );
      SupplierName      : abap.char( 80 );
      issuebyfinal      : abap.char( 12 );
      issuebyname       : abap.char( 80 );
            @ObjectModel.filter.enabled: false
      // _Item       : association [1..*] to ZRESERVATION_ITEM_I on $projection.Reservation = _Item.Reservation;
      _Item             : association [1..*] to ZRES_ITEM_CE on $projection.Reservation = _Item.Reservation;

}
