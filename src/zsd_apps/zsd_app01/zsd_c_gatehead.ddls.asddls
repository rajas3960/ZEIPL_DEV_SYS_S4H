@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SD Gate Entry Apps Head Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_C_GATEHEAD
provider contract transactional_query 
as projection on ZSD_I_GATEHEAD
{
    key Uuid,
    @ObjectModel.text.element: ['Plantname']
    Plant,
    Plantname,
    @ObjectModel.text.element: ['Companycodename']    
    Companycode,
    Companycodename,
    Gateentryid,
    Gateentryiddate,
    @ObjectModel.text.element: ['Gateentrytypetext'] 
    Gateentrytype,
    Gateentrytypetext,
    Gateentryno,
    Gateentrysequence,
    Gateentrytime,
    Gateentrydate,
    Transportid,
    Transportname,
    Vehicleno,
    Packingdetails,
    Dispinstrdetails,
    Contactdetails,
    Drivername,
    Driveraddress,
    Driverlicensenumber,
    Drivermobile,
    Remarks,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    @Semantics.largeObject: {   mimeType: 'Mimetype', 
                                fileName: 'Filename', 
                                contentDispositionPreference: #INLINE }    
    Attachment,
    Filename,
    Mimetype,
    /* Associations */
    _SalesHead : redirected to composition child ZSD_C_SGATEHEAD,
    _SalesItem : redirected to composition child ZSD_C_SGATEITEM
}
