@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Group Value Help for BTP'
define view entity ZMM_MATGRP_VH
  as select from    I_ProductGroup_2     as grp
    left outer join I_ProductGroupText_2 as txt on  txt.ProductGroup = grp.ProductGroup
                                                and txt.Language     = 'E'
{
  key grp.ProductGroup     as MaterialGroup,
      txt.ProductGroupName as MaterialGroupName
}
