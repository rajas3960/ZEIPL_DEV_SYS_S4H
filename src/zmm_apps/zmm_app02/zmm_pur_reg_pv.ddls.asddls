@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register - Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_PUR_REG_PV 
as select from ZMM_PUR_REG_RE
{
    key PurchaseOrder,
    key PurchaseOrderItem,
    key PurchasingHistoryDocument,
    key SupplierInvoice,
    key SupplierInvoiceItem,
    key FiscalYear,
    PurchaseRequisition,
    Plant,
    Material,
    PurchaseOrderItemText,
    BaseUnit,
    MaterialType,
    NetAmount,
    POCurrency,
    NetPriceAmount,
    TaxCode,
    OrderQuantity,
    CompanyCode,
    PurchaseOrderDate,
    Supplier,
    PurchasingGroup,
    ScheduleLineDeliveryDate,
    BalanceOrderQuantity,
    PostingDate,
    Quantity,
    IsCompletelyDelivered,
    CreationDate,
    IGST,
    CGST,
    SGST,
    TaxPercentage,
//    SupplierInvoice,
    PlantName ,
    MaterialTypeName,
    SupplierName,
    PurchasingGroupName,
    PurchaseOrderType,
//    POHcompleted,
//    WrkflwTskCreationUTCDateTime,
//    WorkflowTaskProcessor,
//    PersonFullName,

   case
    when IGSTValue is not null and IGSTValue <> 0
    then
        cast(
             
             coalesce( cast( IGSTValue as abap.dec(15,2) ), 0 )
        as abap.dec(15,2) )

    else 0
end as IGSTAmount,


case
    when ( CGSTValue is not null and CGST <> 0 )
      or ( SGSTValue is not null and SGST <> 0 )
    then
        cast(
             
             coalesce( cast( CGSTValue as abap.dec(15,2) ), 0 )
        as abap.dec(15,2) )

    else 0
end as CGSTAmount,


case
    when ( CGSTValue is not null and CGST <> 0 )
      or ( SGSTValue is not null and SGST <> 0 )
    then
        cast(
              
             coalesce( cast( SGSTValue as abap.dec(15,2) ), 0 )
        as abap.dec(15,2) )

    else 0
end as SGSTAmount,
    
    
   case
    when coalesce( cast( IGSTValue as abap.dec(15,2) ), 0 ) <> 0
    then
        cast(
              coalesce( cast( NetAmount as abap.dec(15,2) ), 0 )
            + coalesce( cast( IGSTValue as abap.dec(15,2) ), 0 )
        as abap.dec(15,2) )

    else
        cast(
              coalesce( cast( NetAmount as abap.dec(15,2) ), 0 )
            + coalesce( cast( CGSTValue as abap.dec(15,2) ), 0 )
            + coalesce( cast( SGSTValue as abap.dec(15,2) ), 0 )
        as abap.dec(15,2) )

end as TotalAmount,


cast(
  case
    when IsCompletelyDelivered = 'X'
         //and coalesce( OrderQuantity, 0 ) < coalesce( Quantity, 0 )
    then
         coalesce( OrderQuantity, 0 )
       - coalesce( Quantity, 0 )
       
     

    else 0
  end
  as abap.dec(15,1)
) as CancelQuantity,
APP1,
APP2,
APP3,
GrnAmount,
InvoiceDate,
InvoiceReferenceNumber,
SupplierReferenceNumber,
SupplierReferenceDate


}
