@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document Header - Created By'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_TEST
  as select from I_MaterialDocumentHeader_2 as MDH
    left outer join I_BusinessUserBasic     as BU
      on BU.UserID = MDH.CreatedByUser
{
  key MDH.MaterialDocumentYear,
  key MDH.MaterialDocument,
      MDH.CreatedByUser,
      MDH.PostingDate,

      case
        when BU.PersonFullName is not null
         and BU.PersonFullName <> ''
          then BU.PersonFullName
        else cast( MDH.CreatedByUser as abap.char(80) )
      end as IssuedBy
}
