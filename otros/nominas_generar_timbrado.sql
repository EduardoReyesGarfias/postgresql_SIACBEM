select 
consecu,qnapago,b.descripcion_nomina,fecha_pago_tesoreria 
from nominas_sispagos a
inner join cat_tipo_nomina_sispagos b ON b.id_tipo_nomina = a.id_tipo_nomina
where
qnapago in (201805,201806)
and CAST(fecha_pago_tesoreria as text) like '2018-03%'
order by fecha_pago_tesoreria