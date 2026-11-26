@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Gate Entry - Sales Head Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_C_SGATEHEAD 
as projection on ZSD_I_SGATEHEAD
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
    _Head : redirected to parent ZSD_C_GATEHEAD
}
