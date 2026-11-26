@EndUserText.label: 'Custom Entity for Purchase Register'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_PUR_REG'
    }
}

@UI: {
    headerInfo: {
        typeName: 'Purchase Register Report',
        typeNamePlural: 'Purchase Register Reports'
    }
}

define custom entity ZMM_PUR_REG_CE
{
      /*------------------------------------------------------------*/
      /* Purchase Order                                             */
      /*------------------------------------------------------------*/

      @UI.facet                     : [
          {
              id                    : 'PurchaseOrder',
              purpose               : #STANDARD,
              type                  : #IDENTIFICATION_REFERENCE,
              label                 : 'Purchase',
              position              : 10
          }
      ]

      @UI.lineItem                  : [
          {
              position              : 10,
              label                 : 'Order Number'
          }
      ]

      @UI.selectionField            : [
          {
              position              : 10
          }
      ]

      @UI.identification            : [
          {
              position              : 10,
              label                 : 'Order Number'
          }
      ]

      @Consumption.valueHelpDefinition: [
          {
              entity                : {
                  name              : 'ZMM_PUR_VH',
                  element           : 'PurchaseOrder'
              }
          }
      ]

  key PurchaseOrder                 : ebeln;


      /*------------------------------------------------------------*/
      /* Purchase Order Item                                        */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 20,
              label                 : 'Order Item'
          }
      ]

      @UI.selectionField            : [
          {
              position              : 20
          }
      ]

      @UI.identification            : [
          {
              position              : 20,
              label                 : 'Order Item'
          }
      ]

  key PurchaseOrderItem             : ebelp;


      /*------------------------------------------------------------*/
      /* Purchasing History Document                                */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 30,
              label                 : 'Material Document Number '
          }
      ]

      @UI.identification            : [
          {
              position              : 30,
              label                 : 'Material Document Number '
          }
      ]

  key PurchasingHistoryDocument     : mblnr;


      /*------------------------------------------------------------*/
      /* Supplier Invoice                                           */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 40,
              label                 : 'MIRO Number'
          }
      ]

      @UI.identification            : [
          {
              position              : 40,
              label                 : 'MIRO Number'
          }
      ]

  key SupplierInvoice               : belnr_d;


      /*------------------------------------------------------------*/
      /* Supplier Invoice Item                                      */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 50,
              label                 : 'Supplier Invoice Item'
          }
      ]

      @UI.identification            : [
          {
              position              : 50,
              label                 : 'Supplier Invoice Item'
          }
      ]

  key SupplierInvoiceItem           : rblgp;


      /*------------------------------------------------------------*/
      /* Fiscal Year                                                */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 60,
              label                 : 'Fiscal Year'
          }
      ]

      @UI.identification            : [
          {
              position              : 60,
              label                 : 'Fiscal Year'
          }
      ]

  key FiscalYear                    : gjahr;


      /*------------------------------------------------------------*/
      /* Purchase Requisition                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 70,
              label                 : 'Purchase Requisition Number'
          }
      ]

      @UI.identification            : [
          {
              position              : 70,
              label                 : 'Purchase Requisition Number'
          }
      ]

      PurchaseRequisition           : banfn;


      /*------------------------------------------------------------*/
      /* Plant                                                       */
      /*------------------------------------------------------------*/

      @UI.hidden                    : true

      Plant                         : ewerk;


      /*------------------------------------------------------------*/
      /* Material                                                    */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 80,
              label                 : 'Item Code'
          }
      ]

      @UI.identification            : [
          {
              position              : 80,
              label                 : 'Item Code'
          }
      ]

      Material                      : matnr;


      /*------------------------------------------------------------*/
      /* Item Text                                                   */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 90,
              label                 : 'Item Name'
          }
      ]

      @UI.identification            : [
          {
              position              : 90,
              label                 : 'Item Name'
          }
      ]

      PurchaseOrderItemText         : abap.char(40);


      /*------------------------------------------------------------*/
      /* Base Unit                                                   */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 100,
              label                 : 'UM'
          }
      ]

      @UI.identification            : [
          {
              position              : 100,
              label                 : 'UM'
          }
      ]

      BaseUnit                      : meins;


      /*------------------------------------------------------------*/
      /* Material Type                                               */
      /*------------------------------------------------------------*/

      @UI.hidden                    : true

      MaterialType                  : mtart;


      /*------------------------------------------------------------*/
      /* Net Amount                                                  */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 110,
              label                 : 'Basic Value'
          }
      ]

      @UI.identification            : [
          {
              position              : 110,
              label                 : 'Basic Value'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      NetAmount                     : abap.curr(13,2);


      /*------------------------------------------------------------*/
      /* Currency                                                    */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 120,
              label                 : 'Currency'
          }
      ]

      @UI.identification            : [
          {
              position              : 120,
              label                 : 'Currency'
          }
      ]

      DocumentCurrency              : waers;


      /*------------------------------------------------------------*/
      /* Tax Code                                                    */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 130,
              label                 : 'Tax Code'
          }
      ]

      @UI.identification            : [
          {
              position              : 130,
              label                 : 'Tax Code'
          }
      ]

      TaxCode                       : mwskz;


      /*------------------------------------------------------------*/
      /* Order Quantity                                              */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 140,
              label                 : 'Order Quantity'
          }
      ]

      @UI.identification            : [
          {
              position              : 140,
              label                 : 'Order Quantity'
          }
      ]

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'

      OrderQuantity                 : abap.quan(13,3);


      /*------------------------------------------------------------*/
      /* Net Price                                                    */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 150,
              label                 : 'Rate'
          }
      ]

      @UI.identification            : [
          {
              position              : 150,
              label                 : 'Rate'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      NetPriceAmount                : abap.curr(11,2);


      /*------------------------------------------------------------*/
      /* Company Code                                                */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 160,
              label                 : 'Company Code'
          }
      ]

      @UI.selectionField            : [
          {
              position              : 30
          }
      ]

      @UI.identification            : [
          {
              position              : 160,
              label                 : 'Company Code'
          }
      ]

      CompanyCode                   : bukrs;


      /*------------------------------------------------------------*/
      /* Purchase Order Date                                        */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 170,
              label                 : 'Order Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 170,
              label                 : 'Order Date'
          }
      ]

      PurchaseOrderDate             : bedat;


      /*------------------------------------------------------------*/
      /* Supplier                                                    */
      /*------------------------------------------------------------*/

      @UI.hidden                    : true

      Supplier                      : abap.char(10);


      /*------------------------------------------------------------*/
      /* Purchasing Group                                            */
      /*------------------------------------------------------------*/

      @UI.hidden                    : true

      PurchasingGroup               : ekgrp;


      /*------------------------------------------------------------*/
      /* Delivery Date                                               */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 180,
              label                 : 'Delivery Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 180,
              label                 : 'Delivery Date'
          }
      ]

      ScheduleLineDeliveryDate      : datum;


      /*------------------------------------------------------------*/
      /* Purchase Order Quantity Unit                                */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 190,
              label                 : 'Purchase Order Quantity Unit'
          }
      ]

      @UI.identification            : [
          {
              position              : 190,
              label                 : 'Purchase Order Quantity Unit'
          }
      ]

      PurchaseOrderQuantityUnit     : meins;


      /*------------------------------------------------------------*/
      /* Balance Order Quantity                                      */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 200,
              label                 : 'Balance Order Quantity'
          }
      ]

      @UI.identification            : [
          {
              position              : 200,
              label                 : 'Balance Order Quantity'
          }
      ]

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'

      BalanceOrderQuantity          : abap.dec(15,3);


      /*------------------------------------------------------------*/
      /* GRN Date                                                    */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 210,
              label                 : 'GRN Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 210,
              label                 : 'GRN Date'
          }
      ]

      PostingDate                   : budat;


      /*------------------------------------------------------------*/
      /* POH Unit                                                    */
      /*------------------------------------------------------------*/

//      @UI.lineItem                  : [
//          {
//              position              : 220,
//              label                 : 'POH Unit'
//          }
//      ]
//
//      @UI.identification            : [
//          {
//              position              : 220,
//              label                 : 'POH Unit'
//          }
//      ]
      @UI.hidden: true

      POHUnit                       : meins;


      /*------------------------------------------------------------*/
      /* Executed Quantity                                           */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 230,
              label                 : 'Executed Qty (GRN)'
          }
      ]

      @UI.identification            : [
          {
              position              : 230,
              label                 : 'Executed Qty (GRN)'
          }
      ]

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'

      Quantity                      : abap.quan(13,3);


      /*------------------------------------------------------------*/
      /* Completely Delivered                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 240,
              label                 : 'Is Completely Delivered'
          }
      ]

      @UI.identification            : [
          {
              position              : 240,
              label                 : 'Is Completely Delivered'
          }
      ]

      IsCompletelyDelivered         : elikz;


      /*------------------------------------------------------------*/
      /* Creation Date                                               */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 250,
              label                 : 'Purchase Requisition Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 250,
              label                 : 'Purchase Requisition Date'
          }
      ]

      CreationDate                  : erdat;


      /*------------------------------------------------------------*/
      /* IGST Amount                                                 */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 260,
              label                 : 'IGST Amount'
          }
      ]

      @UI.identification            : [
          {
              position              : 260,
              label                 : 'IGST Amount'
          }
      ]

      IGSTAmount                    : abap.dec(13,2);


      /*------------------------------------------------------------*/
      /* CGST Amount                                                 */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 270,
              label                 : 'CGST Amount'
          }
      ]

      @UI.identification            : [
          {
              position              : 270,
              label                 : 'CGST Amount'
          }
      ]

      CGSTAmount                    : abap.dec(13,2);


      /*------------------------------------------------------------*/
      /* SGST Amount                                                 */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 280,
              label                 : 'SGST Amount'
          }
      ]

      @UI.identification            : [
          {
              position              : 280,
              label                 : 'SGST Amount'
          }
      ]

      SGSTAmount                    : abap.dec(13,2);


      /*------------------------------------------------------------*/
      /* IGST                                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 290,
              label                 : 'IGST Tax Rate'
          }
      ]

      @UI.identification            : [
          {
              position              : 290,
              label                 : 'IGST Tax Rate'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      IGST                          : abap.curr(13,2);


      /*------------------------------------------------------------*/
      /* CGST                                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 300,
              label                 : 'CGST Tax Rate'
          }
      ]

      @UI.identification            : [
          {
              position              : 300,
              label                 : 'CGST Tax Rate'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      CGST                          : abap.curr(13,2);


      /*------------------------------------------------------------*/
      /* SGST                                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 310,
              label                 : 'SGST Tax Rate'
          }
      ]

      @UI.identification            : [
          {
              position              : 310,
              label                 : 'SGST Tax Rate'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      SGST                          : abap.curr(13,2);


      /*------------------------------------------------------------*/
      /* Tax Percentage                                              */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 320,
              label                 : 'Description'
          }
      ]

      @UI.identification            : [
          {
              position              : 320,
              label                 : 'Description'
          }
      ]

      TaxPercentage                 : abap.char(20);


      /*------------------------------------------------------------*/
      /* Plant Name                                                  */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 330,
              label                 : 'Division Name'
          }
      ]

      @UI.identification            : [
          {
              position              : 330,
              label                 : 'Division Name'
          }
      ]

      PlantName                     : abap.char(30);


      /*------------------------------------------------------------*/
      /* Material Type Name                                          */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 340,
              label                 : 'Item Nature'
          }
      ]

      @UI.identification            : [
          {
              position              : 340,
              label                 : 'Item Nature'
          }
      ]

      MaterialTypeName              : abap.char(25);


      /*------------------------------------------------------------*/
      /* Supplier Name                                               */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 350,
              label                 : 'Supplier Name'
          }
      ]

      @UI.identification            : [
          {
              position              : 350,
              label                 : 'Supplier Name'
          }
      ]

      SupplierName                  : abap.char(80);


      /*------------------------------------------------------------*/
      /* Purchasing Group Name                                       */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 360,
              label                 : 'Department Name'
          }
      ]

      @UI.identification            : [
          {
              position              : 360,
              label                 : 'Department Name'
          }
      ]

      PurchasingGroupName           : abap.char(18);


      /*------------------------------------------------------------*/
      /* Purchase Order Type                                         */
      /*------------------------------------------------------------*/

      @UI.hidden                    : true

      PurchaseOrderType             : abap.char(4);


      /*------------------------------------------------------------*/
      /* GRN Amount                                                  */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 370,
              label                 : 'GRN Amount'
          }
      ]

      @UI.identification            : [
          {
              position              : 370,
              label                 : 'GRN Amount'
          }
      ]

      @Semantics.amount.currencyCode: 'DocumentCurrency'

      GrnAmount                     : abap.dec(18,2);


      /*------------------------------------------------------------*/
      /* Invoice Date                                                */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 380,
              label                 : 'Invoice Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 380,
              label                 : 'Invoice Date'
          }
      ]

      InvoiceDate                   : datum;


      /*------------------------------------------------------------*/
      /* Invoice Reference                                           */
      /*------------------------------------------------------------*/

      @UI.lineItem                  : [
          {
              position              : 390,
              label                 : 'Invoice Reference Number'
          }
      ]

      @UI.identification            : [
          {
              position              : 390,
              label                 : 'Invoice Reference Number'
          }
      ]

      SupplierInvoiceIDByInvcgParty : xblnr1;
//       @UI.lineItem                  : [
//          {
//              position              : 400,
//              label                 : 'WorkflowProcessor'
//          }
//      ]
//
//      @UI.identification            : [
//          {
//              position              : 400,
//              label                 : 'WorkflowProcessor'
//          }
//      ]
//      WorkflowProcessor : abap.char( 12 );
//      @UI.hidden: true
//      WorkflowCompletionTime : abap.dec( 21, 7 );
        @UI.lineItem                  : [
          {
              position              : 400,
              label                 : 'Approval level 1 user name'
          }
      ]

      @UI.identification            : [
          {
              position              : 400,
              label                 : 'Approval level 1 user name'
          }
      ]
        WorkflowProcessor1 : abap.char( 40 );
              @UI.lineItem                  : [
          {
              position              : 410,
              label                 : 'Approval level 2 user name'
          }
      ]

      @UI.identification            : [
          {
              position              : 410,
              label                 : 'Approval level 2 user name'
          }
      ]
        WorkflowProcessor2 : abap.char( 40 );
              @UI.lineItem                  : [
          {
              position              : 420,
              label                 : 'Approval level 3 user name'
          }
      ]

      @UI.identification            : [
          {
              position              : 420,
              label                 : 'Approval level 3 user name'
          }
      ]
        WorkflowProcessor3 : abap.char( 40 );  
        @UI.hidden: true
        WorkflowProcessor  : abap.char( 30 );
                   @UI.lineItem                  : [
          {
              position              : 430,
              label                 : 'Approval level 1 Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 430,
              label                 : 'Approval level 1 Date'
          }
      ]
        WorkflowCompletionTime1 : abap.char( 50 );
       
                      @UI.lineItem                  : [
          {
              position              : 440,
              label                 : 'Approval level 2 Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 440,
              label                 : 'Approval level 2 Date'
          }
      ]
        WorkflowCompletionTime2 : abap.char( 50 );
        
        
                        @UI.lineItem                  : [
          {
              position              : 450,
              label                 : 'Approval level 3 Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 450,
              label                 : 'Approval level 3 Date'
          }
      ]
        WorkflowCompletionTime3 : abap.char( 50 );
        
                               @UI.lineItem                  : [
          {
              position              : 460,
              label                 : 'Supplier Reference Number'
          }
      ]

      @UI.identification            : [
          {
              position              : 460,
              label                 : 'Supplier Reference Number'
          }
      ]
        SupplierReferenceNumber : abap.char( 50 );
        
                                 @UI.lineItem                  : [
          {
              position              : 470,
              label                 : 'Supplier Reference Date'
          }
      ]

      @UI.identification            : [
          {
              position              : 470,
              label                 : 'Supplier Reference Date'
          }
      ]    
        SupplierReferenceDate : datum;
}
