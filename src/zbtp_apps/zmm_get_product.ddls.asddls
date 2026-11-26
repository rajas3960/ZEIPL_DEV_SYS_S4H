@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RGP&NRGP Get the Product'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_GET_PRODUCT
  as select from    I_ProductPlantBasic     as pla
    left outer join I_ProductValuationBasic as _Valu on  _Valu.Product       = pla.Product
                                                     and _Valu.ValuationArea = pla.Plant
  association [1..1] to I_Plant                as _PLANT   on  $projection.Plant = _PLANT.Plant
  association [1..1] to I_Product              as _Product on  $projection.Product = _Product.Product
  association [0..1] to I_ProductDescription_2 as _Desc    on  $projection.Product = _Desc.Product
                                                           and _Desc.Language      = $session.system_language

{

  key pla.Product,
  key pla.Plant,
      _Product.BaseUnit          as Baseunit,
      _Desc.ProductDescription   as Prodesc,
      _PLANT.PlantName           as PlantName,
      @UI.hidden: true
      pla.ConsumptionTaxCtrlCode as Hsncode,
      @UI.hidden: true
      @Semantics.amount.currencyCode: 'Currency'
      case when _Valu.InventoryValuationProcedure = 'S'
      then  _Valu.StandardPrice
      else
      _Valu.MovingAveragePrice
      end                        as Netprice,
      @UI.hidden: true
      _Valu.Currency             as Currency
}
