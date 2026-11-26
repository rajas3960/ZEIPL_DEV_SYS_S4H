@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Compare Supplier Quotations'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_APPS01_RV
  as select from I_Requestforquotation_Api01 as rq
    inner join   I_BusinessUserBasic         as user on user.UserID = rq.CreatedByUser
    left outer join zmm_apps01_tb as stus on stus.rfq = rq.RequestForQuotation
    left outer join I_SupplierQuotation_Api01 as sq on sq.RequestForQuotation = stus.rfq
                                                    and sq.SupplierQuotation = stus.sq
  composition [0..*] of ZMM_APPS01_IRV as ITEM
{
  key rq.RequestForQuotation,
      rq.RequestForQuotationName,
      rq.CreatedByUser,
      concat(
      concat(
          user.PersonFullName,
          '('
      ),
      concat(
          rq.CreatedByUser,
          ')'
      )
      )       as CreatedByUserName,
      rq.CreationDate,
      rq.RFQPublishingDate,
      sq.QTNLifecycleStatus as RFQLifecycleStatus,
      case when sq.QTNLifecycleStatus = '01'
      then 'In Preparation'
      when sq.QTNLifecycleStatus = '02'
      then 'Submitted'
      when sq.QTNLifecycleStatus = '03'
      then 'Awarded'
      when sq.QTNLifecycleStatus = '04'
      then 'Cancelled'
      when sq.QTNLifecycleStatus = '05'
      then 'Completed'
      when sq.QTNLifecycleStatus = '06'
      then 'In Approval'
      when sq.QTNLifecycleStatus = '07'
      then 'Rejected'
      else
      ' ' end as Status,
      ITEM
}
