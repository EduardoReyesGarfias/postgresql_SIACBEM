select 
			nombre, paterno, materno,genero,fecha_nacimiento,curp,categoria, descripcion_cat_padre,nombre_subprograma,
			email_institucional, email_institucional_alias,telefono,d_mnpio, d_ciudad, d_asenta, calle, no_ext, no_int, d_codigo
			,SUM(
				CASE WHEN id_tipo_pd = 1 THEN
			    	importe
			    ELSE
			    	0
			    END
			)as percepciones

			,SUM(
				CASE WHEN id_tipo_pd = 1 THEN
			    	importe
			    ELSE
			    	importe * -1
			    END
			)as liquido

			,(
				select  
					prefijo||'_'||grado_academico||'_'||profesion||'_'||nombre_institucion
				from empleado_grados_academicos
				join cat_grados_academicos
				on cat_grados_academicos.id_grado_academico=empleado_grados_academicos.id_grado_academico
				left join curricula_estudios_empleados 
				on curricula_estudios_empleados.id_empleado_grado_academico=empleado_grados_academicos.id_empleado_grado_academico
				left join cat_profesiones  
				on cat_profesiones.id_profesion=curricula_estudios_empleados.id_profesion
				left join cat_instituciones_educativas 
				on cat_instituciones_educativas.id_institucion_educativa=curricula_estudios_empleados.id_institucion_educativa 
				where empleado_grados_academicos.id_empleado = d.id_empleado
				order by nivel_grado_academico DESC limit 1
			)as formacion_academica

			,(
				select
			desde_plz||' al '||hasta_plz
				from plazas_nomina_rh_recibe 
				where id_plaza_nomina_rh_datos=30
					and filiacion=d.filiacion
					and estado_rec='0'
			        --and tipo_nombr = '15'
			    and clave_plz in ('E3103','CF04020','CF01006','CF01005','CF01001','A2406','A2405','A2404','A2403','A2402')
				order by id_plaza_nomina_rh_recibe DESC 
				LIMIT 1
			)efectos_del_puesto

			from pagos_sispagos a
			join percepciones_deducciones_sispagos b on b.id_pago = a.id_pago
			INNER JOIN cat_percepciones_deducciones_sispagos i ON i.clave = b.cod_pd
			join nominas_sispagos c on c.id_nomina = a.id_nomina
			join empleados d on d.id_empleado = a.id_empleado
			join subprogramas e on e.id_subprograma = a.id_subprograma
			join cat_categorias_padre f on f.categoria_padre = a.categoria
			---
			left join pagos_sispagos_cancelados g on g.id_pago = a.id_pago
			----
			join codigos_postales h on h.id_cp = d.id_cp
			where id_tipo_nomina = 1
			and b.qnapago between 201905 and 201905
			and b.desde_pag between 201905 and 201905
			and hasta_pag between 201905 and 201905
			and categoria in ('E3103','CF04020','CF01006','CF01005','CF01001','A2406','A2405','A2404','A2403','A2402')
			and g.id_pago is null
			--and tipo_categoria=1
			--and nombre ='ERASTO'
			group by 
			d.id_empleado,nombre, paterno, materno,genero,fecha_nacimiento,curp,
			categoria, descripcion_cat_padre,nombre_subprograma,
			email_institucional, email_institucional_alias,
			telefono,d_mnpio, d_ciudad, d_asenta, calle, no_ext, no_int, d_codigo
			order by paterno, materno, nombre, categoria asc
			--LIMIT 1