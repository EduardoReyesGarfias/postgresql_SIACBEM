/* ver datos del registro */
select 
id_cfdi,ct,nombre_ct,filiacion,no_empleado,receptor_nombre
,monto_recurso_propio,fecha_ingreso,fecha_pago,fecha_inicial_pago,fecha_final_pago,nss
,receptor_rfc
FROM timbrado_cfdi
WHERE id_cfdi IN()

/* ver datos en empleados */
select no_seguridad_social,fecha_ingreso,filiacion,curp,rfc 
from empleados where id_empleado in ()

/* CAMBIAR NUMERO DE SEGURIDAD SOCIAL */
UPDATE 
  timbrado_cfdi t1  
SET  
  nss = t2.no_seguridad_social
FROM 
  empleados t2  
WHERE 
  t1.id_cfdi in() 
  and CAST(t1.no_empleado as int) = t2.id_empleado;
  
  
/* CAMBIAR FECHA DE INGRESO */
UPDATE 
  timbrado_cfdi t1  
SET  
  fecha_ingreso = t2.fecha_ingreso
FROM 
  empleados t2  
WHERE 
  t1.id_cfdi in() 
  and CAST(t1.no_empleado as int) = t2.id_empleado;  



/* CAMBIAR RFC */
UPDATE 
  timbrado_cfdi t1  
SET  
  receptor_rfc = t2.rfc
FROM 
  empleados t2  
WHERE 
  t1.id_cfdi in() 
  and CAST(t1.no_empleado as int) = t2.id_empleado;  
