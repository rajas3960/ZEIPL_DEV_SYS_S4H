@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Way Bill and E-Invoice details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_EWAY_CDS 
as select from I_IN_ElectronicDocInvoice as E_IN
left outer join I_IN_ElectronicDocTransptRegn as E_Way on E_Way.ElectronicDocCompanyCode = E_IN.ElectronicDocCompanyCode
                                                and E_Way.ElectronicDocCountry = E_IN.ElectronicDocCountry
                                                and E_Way.ElectronicDocSourceKey = E_IN.ElectronicDocSourceKey
{
    key E_IN.ElectronicDocUUID as E_InoviceUUID,
    key E_Way.ElectronicDocUUID as E_WayUUID,
    E_IN.ElectronicDocCompanyCode,
    E_IN.ElectronicDocCountry,
    E_IN.ElectronicDocSourceType,
    E_IN.ElectronicDocSourceKey,
    E_IN.ElectronicDocType as ElectronicDocType_Ein,
    E_IN.IN_ElectronicDocAcknNmbr as EinvoiceNo,
    E_IN.IN_ElectronicDocAcknDate as EinvoiceDate,
    E_IN.IN_EDocEInvcBusinessPlace,
    E_Way.ElectronicDocType as ElectronicDocType_Eway,
    E_Way.IN_ElectronicDocEWbillNmbr as EwayBillNo, 
    E_Way.IN_EDocEWbillCreateDate as Ewaybilldate
    
}
