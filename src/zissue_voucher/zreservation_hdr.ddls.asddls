@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESERVATION HEADER'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZRESERVATION_HDR
  as select from    I_ReservationDocumentHeader as RDH
    inner join      I_ReservationDocumentItem   as RDI    on  RDI.Reservation     = RDH.Reservation
                                                          and RDI.ReservationItem = '0001'
    left outer join I_MaterialDocumentItem_2    as MDI    on  MDI.Reservation              =  RDI.Reservation
                                                          and MDI.ReservationItem          =  RDI.ReservationItem
                                                          and MDI.DebitCreditCode          =  'H'
                                                          and MDI.ReversedMaterialDocument <> ' '
  //                                                     and MDI.ReversedMaterialDocument = ' '
  //  and MDI.GoodsMovementType = '201'
    left outer join I_MaterialDocumentHeader_2  as MDH    on  MDH.MaterialDocument     = MDI.MaterialDocument
                                                          and MDH.MaterialDocumentYear = MDI.MaterialDocumentYear
    left outer join I_BusinessUserBasic         as b      on b.UserID = MDH.CreatedByUser

    left outer join I_Plant                     as p      on p.Plant = RDI.Plant
    left outer join I_CostCenterText            as CT     on  CT.CostCenter = RDH.CostCenter
                                                          and CT.Language   = $session.system_language
    left outer join I_BusinessUserBasic         as bu     on bu.UserID = RDH.UserID
    left outer join I_GoodsMovementTypeT        as gmt    on  gmt.GoodsMovementType = RDH.GoodsMovementType
                                                          and gmt.Language          = $session.system_language

    left outer join zreser_table                as Rtable on Rtable.reservation = RDH.Reservation

    left outer join I_ProductDescription        as pd     on  pd.Product  = RDI.Product
                                                          and pd.Language = $session.system_language



{

  key RDH.Reservation        as Requino,
      RDI.Plant              as Div,
      RDH.CostCenter         as cost,
      RDI.GoodsMovementType  as Stocktype,
      RDI.Batch              as batchno,
      RDH.GoodsRecipientName as issueto,
      //    case
      //        when MDH.CreatedByUser is not initial
      //        then b.PersonFullName
      //        else ''
      //    end as IssuedBy,


      case
          when MDI.MaterialDocument is not initial
          then b.PersonFullName
          else ''
      end                    as IssuedBy,

      //case
      //    when MDI.MaterialDocument is not initial
      //     and MDH.CreatedByUser is not initial
      //    then b.PersonFullName
      //    else ''
      //end as IssuedBy,



      //      mdi.MaterialDocument as issueno,
      //      mdi.PostingDate as issuedt,
      RDH.ReservationDate    as RequiDt,
      RDH.UserID             as Preparedby,
      p.PlantName,
      CT.CostCenterDescription,
      bu.PersonFullName,
      gmt.GoodsMovementTypeName,
      RDI.Product,
      pd.ProductDescription,
      Rtable.attachment,
      Rtable.filename,
      Rtable.mimetype
     




}
//where (
//       MDI.GoodsMovementType = '201'
//       or MDI.GoodsMovementType = '301'
//       or MDI.GoodsMovementType = '311'
//
//)
//where RDI.ReservationItem = '0001'
