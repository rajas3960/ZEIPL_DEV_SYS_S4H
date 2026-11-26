@EndUserText.label: 'Custom Entity For Header Material'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_APP1_PRINT'
define custom entity ZMM_APP1_CE1
// with parameters parameter_name : parameter_type
{

  key uuid    : sysuuid_x16 ;
  ruler         : abap.char(100);
  cmpname       : abap.char(100);
  addrs         : abap.char(200);
  gstin         : abap.char(15);
  pan           : abap.char(10);
  email         : abap.char(50);
  statecode     : abap.char(15);
  Plnrtndate    : abap.dats; 
  name          : abap.char(30);
  houseno       : abap.char(25);
  streetname    : abap.char(30);
  district      : abap.char(30);
  postalcode    : abap.char(30);
  typ           : abap.char(5);
  rgpno         : abap.char(15);
  city          : abap.char(30);
  cost          : abap.char(30);
  division      : abap.char(30);
  stocktype     : abap.char(20);
  batchno       : abap.char(10);
  particular    : abap.char(30);
  roomno        : abap.char(30);
  gatepassno    : abap.char(16);
  gatepassdt    : abap.datn;
  issuedate      : abap.dats;
  sp_name       : abap.char(50);
  sp_add1       : abap.char(50);
  sp_add2       : abap.char(50);
  supaddress    : abap.char(150);
  sp_city       : abap.char(20);
  sp_pcode      : abap.char(10);
  sp_cin        : abap.char(25);
  sp_pno        : abap.char(13);
  sp_email      : abap.char(20);
  sp_pan        : abap.char(20);
  sp_gstin      : abap.char(15);
  sp_statename  : abap.char(15);
  ewaybill_no   : abap.char(15);
  ewaybill_date : abap.dats;
  tdname        : abap.char(50);
  lrno          : abap.numc(5);
  lrdate        : abap.dats;
  vehicleno     : abap.char(15);
  tdmode        : abap.char(10);
  formplace     : abap.char(30);
  placeofsupply : abap.char(30);
  fregts        : abap.char(40);
  grosswgt      : abap.dec(15,3);
  tarewgt       : abap.dec(15,3);
  netwgt        : abap.dec(15,3);
  td_empname    : abap.char(50);
  exp_retu_d    : abap.dats;
  bi_add1       : abap.char(30);
  bi_add2       : abap.char(30);
  bi_city       : abap.char(20);
  bi_pstcode    : abap.numc(10);
  bi_statename  : abap.char(30);
  bi_gstin      : abap.char(25);
  bi_gstpan     : abap.char(15);
  bi_stocde     : abap.numc(2);
  bi_phone      : abap.numc(13);
  bi_email      : abap.char(30);
  sh_add1       : abap.char(30);
  sh_add2       : abap.char(30);
  sh_city       : abap.char(20);
  sh_pstcode    : abap.numc(10);
  sh_statename  : abap.char(30);
  sh_gstin      : abap.char(25);
  sh_gstpan     : abap.char(15);
  sh_stocde     : abap.numc(2);
  sh_phone      : abap.numc(13);
  sh_email      : abap.char(30);
  Contpr        : abap.char(30);
  valueinword   : abap.char(200);
  t_gp_value    : abap.numc(10);
  hsncode       : abap.char(10);
  remark        : abap.char(100);
  createdby      : abp_creation_user;
  createdat      : abap.dats;
  dt            : abap.dats;
  zattachment   : zattachment2;
  slno          : abap.numc(4);
  minetype      : abap.char(128);
  filename      : abap.char(128);
  
  @ObjectModel.filter.enabled: false
  _item : association[1..*] to ZPP_APPS05_CITM on _item.uuid = $projection.uuid ;
 
  
}
