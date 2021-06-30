/* ver datos del registro */
select 
id_cfdi,ct,nombre_ct,filiacion,no_empleado,receptor_nombre
,monto_recurso_propio,fecha_ingreso,fecha_pago,fecha_inicial_pago,fecha_final_pago,nss
,receptor_rfc
FROM timbrado_cfdi
WHERE id_cfdi IN(11918)

/* ver datos en empleados */
select no_seguridad_social,fecha_ingreso,filiacion,curp,rfc 
from empleados where id_empleado in ('380')


/* ver id_pago */
select *
FROM timbrado_conceptos 
where id_cfdi = 15048

select * 
from percepciones_deducciones_sispagos
WHERE id_pago = 1239495

/* CAMBIAR NUMERO DE SEGURIDAD SOCIAL */
UPDATE 
  timbrado_cfdi t1  
SET  
  nss = t2.no_seguridad_social
FROM 
  empleados t2  
WHERE 
  t1.id_cfdi in(11690) 
  and CAST(t1.no_empleado as int) = t2.id_empleado;
  
/* CAMBIAR FECHA DE INGRESO */
UPDATE 
  timbrado_cfdi t1  
SET  
  fecha_ingreso = t2.fecha_ingreso
FROM 
  empleados t2  
WHERE 
  t1.id_cfdi in(11690) 
  and CAST(t1.no_empleado as int) = t2.id_empleado;  
 
 
select * from timbrado_cfdi where id_cfdi = 213


select *
from timbrado_cfdi
where filiacion = 'AIGC831106000'
and CAST(nominas as int) = (select id_nomina from nominas_sispagos where consecu = '4568')


/*********************************************************
	RASTREAR LOS QUE NO HAN SUFRIDO CAMBIO
**********************************************************/

/* numero de seguro social */
select (paterno||' '||materno||' '||nombre)as nombre,id_empleado,nss,no_seguridad_social
,(CASE WHEN (nss != no_seguridad_social) then 'SI' ELSE 'NO' end ) AS diferente
FROM timbrado_cfdi
INNER JOIN empleados ON empleados.id_empleado = cast(timbrado_cfdi.no_empleado as int)
WHERE id_cfdi in (
    11690,20078,21408,15004,15028,15034,15584,15661,177551,17282,17788
,18511,21985,21986,22012,22016,22021,22032,22416,22665,26739,22034,22035,22051,22053
    ,32977,36711,42931,44420,44426,38734,44191,44430,49068,49760,51667,51760,46002,47907,47998
    ,57326,57447,60316,60500,63330,53121,53543,55461,55553,60383,61096,63002,63093,64366,66652
,71096,85587,84127,85587,77719,78201,78732,80031,80473,84865,85091,86047,86493,87027,87512,87828
,87958


)
GROUP BY id_empleado,nss,no_seguridad_social
order by diferente,nombre

/* RFC */
select (paterno||' '||materno||' '||nombre)as nombre,id_empleado,receptor_rfc,rfc
,(CASE WHEN (receptor_rfc != rfc) then 'SI' ELSE 'NO' end ) AS diferente
FROM timbrado_cfdi
INNER JOIN empleados ON empleados.id_empleado = cast(timbrado_cfdi.no_empleado as int)
WHERE id_cfdi in (
    11918,19270,12367,19664,13169,20385,13481,20659,13778,20924,13984,21106,14106,21217,14430,21504,11816,11911,19263
	,15773,22780,15780,22787,16195,23218,16943,23985,17228,24278,17502,24755,17692,25149,17811,25391,25817,18107,26007
	,25850,30213,33959,25864,30220,33966,26752,30664,34405,27680,31453,35190,27980,31752,35490,28272,32043,35781,28477
,32248,35985,28600,32369,36106,28817,32586,36323,28916,32684,36420,37685,39459,37692,39473,38295,40362,39874,41934,40476
,42532,41067,43120,41479,43459,41720,43577,42356,43899,38539,40602,42160,43800,48976,45218,48983,45226,50213,46459,50518
,46763,50812,47058,51020,47266,51141,47389,51460,47707,48232,44464,51360,49457,45699,45670,49429,45790,49548
,56542,52764,56550,52772,56994,53214,57789,54005,58096,54311,58603,54609,59020,54816,59268,54940,59910,55259
,57114,53333,59679,64039,67508,59695,64045,67515,60569,64455,67892,61557,68566,61862,65495,68828,62156,65770,69074,62362
,65961,69245,62486,66078,69350,62802,66379,69620,69541,59745,64070,67540,60851,64588,62760,66340,69588,60805,67998
,71178,74150,70799,76372,73215,74080,70766,74094,70773,74627,75347,71918,75616,72197,75881,72468,76065,72658,76173
,72799,74740,71293,81440,81448,81475,81877,82643,82933,83221,83421,83538,83756,88925,88932,88959,89351,90712,91286,91862
,92255,92485,92913,89467,81994,76936,81440,81448,81475,81877,82643,82933,83221,83421,83538,83756,88925,88932,88959
,89351,90712,91286,91862,92255,92485,92913,89467,81994,76936,77682,77690,77720,78133,78928,79234,79530,79737,79857,80080
,80181,85121,85129,85158,85575,86385,86700,87000,87209,87340,87561,87788,80717,80719,78253,85700,78528,94894
,95437,97304,98749,99293,101150,102601,103145,105002,106447,106992,94856,98711,102563,106409,94864,98719,102571,106417
,96129,99981,107684,96447,100298,108004,95314,99170,103022,106868,100599,104451,96957,108515,97081,100927
,104779,108637
)
GROUP BY id_empleado,receptor_rfc,rfc
order by diferente,nombre


/* fecha ingreso */
select (paterno||' '||materno||' '||nombre)as nombre,id_empleado,timbrado_cfdi.fecha_ingreso as timbrado_fecha_ingreso,empleados.fecha_ingreso as siacbem_fecha_ingreso
,(CASE WHEN (timbrado_cfdi.fecha_ingreso != CAST(empleados.fecha_ingreso as char)) then 'SI' ELSE 'NO' end ) AS diferente
FROM timbrado_cfdi
INNER JOIN empleados ON empleados.id_empleado = cast(timbrado_cfdi.no_empleado as int)
WHERE id_cfdi in (
	11855,12998,13066,13454,13470,13635,14684,11652,11658,20233,20649
	,16787,17218,23824,24267,22033,27515,27954,31288,31726,35464
    ,40424,41733,42482,50491,50507,45066,45530,46737,46752,51565
	,58070,58085,54285,54300,61836,61851,65470,65484,74503,91266
	,94216,94482,94511,95093,95439,96180,96376,96421,96868
)
GROUP BY id_empleado,timbrado_cfdi.fecha_ingreso,empleados.fecha_ingreso
order by diferente,nombre





select id_empleado,rfc,paterno,materno,nombre,fecha_nacimiento
from empleados
where id_empleado in (
	6394,9954,9867,2830,380,1246,275,10350,10618,5126,1088,5472,3010,3086,5250,3937,1911,9698
)


