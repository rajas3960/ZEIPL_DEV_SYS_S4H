@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Storage Location Value Help for BTP'
define view entity ZSD_SLOC_VH
  as select from I_StorageLocation
{
  key Plant               as Plant,
  key StorageLocation     as Storagelocation,
      StorageLocationName as Storagelocationname
}
