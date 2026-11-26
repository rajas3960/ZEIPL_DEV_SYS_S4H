@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inpection Plan Version Group - Master IC'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZINSPECTION_PLAN
  as select from    I_InspPlnMatlAssgmtVersion_2 as a
    left outer join I_InspPlanOpCharcVersion_2   as b on  b.InspectionPlanGroup    = a.InspectionPlanGroup
                                                      and b.InspectionPlan         = a.InspectionPlan
                                                      and b.BOOOperationInternalID = a.InspPlanMatlAssgmtIntVersion
                                                      and b.IsDeleted is initial
{
  key a.Material,
  key a.Plant,
  key a.InspectionPlanGroup,
  key a.InspectionPlan,
  key a.InspPlanMatlAssignment,
  key a.InspPlanMatlAssgmtIntVersion,
  key b.BOOCharacteristic,
  key b.BOOCharacteristicVersion,
  key b.BOOOperationInternalID,
      b.InspectionSpecificationText as KPI,
      b.InspectionSpecification,
      b.InspectionSpecificationPlant,
      b.InspectionSpecificationUnit,
      b.InspSpecTargetValue,
      b.InspSpecLowerLimit,
      b.InspSpecUpperLimit,
      a.IsDeleted
}
where
  a.IsDeleted is initial
