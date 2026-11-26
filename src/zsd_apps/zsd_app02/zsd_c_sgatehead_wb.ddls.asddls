@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Head-Weigh Bridge Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_C_SGATEHEAD_WB 
as projection on ZSD_I_SGATEHEAD_WB
{
    key Uuid,
    key Salesdocument,
    Gateentryno,
    Companycode,
    Companyname,
    Customer,
    Customername,
    Fromplace,
    Toplace,
    Billingfrom,
    Consignee,
    Billto,
    Shipto,
    Broker,
    Doremark,
    Stocktype,
    Division,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _Head : redirected to parent ZSD_C_GATEHEAD_WB
}
