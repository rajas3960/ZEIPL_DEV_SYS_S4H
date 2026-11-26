@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Migo Validation Custom Field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET]
define view entity ZMM_MIGO_VD
  as select from zmm_app04_hdb as a
    inner join   zmm_app04_idb as b on  b.uuid        = a.uuid
                                    and b.gateentryno = a.gateentryno
{
  key   a.uuid               as Uuid,
  key   b.purchaseorder      as Purchaseorder,
  key   b.purchaseorderitem  as Purchaseorderitem,
  key   a.gateentryno        as Gateentryno,
        a.gateentryseries    as Gateentryseries,
        a.gateentryseriesdes as Gateentryseriesdes,
//        a.poordertype        as Poordertype,
//        a.poordertypetext    as Poordertypetext,
        a.gateentrydate      as Gateentrydate,
        a.gateentrytime      as Gateentrytime
}
where
      a.gateentryseries = 'G2'
  and a.gateentryno     is not initial
