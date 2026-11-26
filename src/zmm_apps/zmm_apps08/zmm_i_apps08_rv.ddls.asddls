@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Request For Quotation Root View Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_I_APPS08_RV
  as select from    I_RfqBidder_Api01           as bid
    inner join      I_Requestforquotation_Api01 as rfqh on rfqh.RequestForQuotation = bid.RequestForQuotation
    left outer join I_IncotermsClassificationText as inco on inco.IncotermsClassification = rfqh.IncotermsClassification and inco.Language = 'E'
    left outer JOIN I_PaymentTermsText AS prm on prm.PaymentTerms = rfqh.PaymentTerms and prm.Language = 'E'
    left outer join I_CompanyCode               as COMP on COMP.CompanyCode = rfqh.CompanyCode
    left outer join I_PurchasingGroup           as pur  on pur.PurchasingGroup = rfqh.PurchasingGroup
    inner join      ZMM_I_APP09_RV              as ven  on ven.Supplier = bid.Supplier
    left outer join ZMM_APPS08_GRP              as sup  on  sup.RequestForQuotation = rfqh.RequestForQuotation
                                                        and sup.Supplier            = bid.Supplier
    left outer join zmm_a_apps08_htb            as hdr  on  hdr.requestforquotation = rfqh.RequestForQuotation
                                                        and hdr.supplier            = bid.Supplier
  composition [0..*] of ZMM_C_APPS08_IV as _Item

{
  key bid.Supplier,
  key rfqh.RequestForQuotation,
      ven.EmailAddress,
      ven.passcode                      as Passcode,
      ven.OrganizationName1             as SupplierName,
      pur.PurchasingGroupName           as PurchasingGroup,
      rfqh.PurchasingOrganization,
      rfqh.BindingPeriodValidityEndDate,
      rfqh.RequestForQuotationName,
      COMP.CompanyCodeName              as CompanyCode,
      rfqh.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      rfqh.TargetAmount,
      rfqh.QuotationLatestSubmissionDate,
    
      PRM.PaymentTermsName             as PaymentTerms,
      rfqh.CashDiscount1Days,
      rfqh.CashDiscount1Percent,
      rfqh.CashDiscount2Days,
      rfqh.CashDiscount2Percent,
      
        rfqh.IncotermsVersion       as IncotermsVersion,
         
        
        INCO.IncotermsClassificationName       as IncotermsClassification,
      case when hdr.incotermslocation1 is not initial
            then
            hdr.incotermslocation1
            else
            rfqh.IncotermsLocation1 end as IncotermsLocation1,
      rfqh.IncotermsLocation2,
      case when sup.SupplierQuotation is not initial
      then 'X'
      else  null
       end                              as mark,

      case
        when sup.SupplierQuotation is null
             and rfqh.QuotationLatestSubmissionDate >= $session.system_date
          then cast( 'Open' as abap.char(20) )

        when sup.SupplierQuotation is not initial
             and rfqh.QuotationLatestSubmissionDate >= $session.system_date
          then cast( 'In Preparation' as abap.char(20) )

        when rfqh.QuotationLatestSubmissionDate < $session.system_date
          then cast( 'Closed' as abap.char(20) )

        else cast( '' as abap.char(20) )
      end                               as Status,

      sup.SupplierQuotation,
      hdr.remarks as Remarks,


      _Item



}
