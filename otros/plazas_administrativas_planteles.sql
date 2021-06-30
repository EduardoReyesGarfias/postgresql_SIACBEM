SELECT  
			COUNT(cat_categorias.categoria) as num_plazas,

			COUNT(case when (comisiones_plaza.id_plaza_comisionada = 1 or comisiones_plaza.id_plaza_comisionada = 3
			or comisiones_plaza.id_plaza_comisionada  is NULL or plazas.id_subprograma != 135)
			and (plazas.id_status_plaza_estructura_ocupacional = 1 
			or plazas.id_status_plaza_estructura_ocupacional = 2)
			then cat_categorias.categoria  end) as suma_plazas,

			case when plazas.id_subprograma !=135  then 1 else 0 end as campo_ext,

			case when notas_explicativas_plazas.no_nota is NULL 
			then 0 else notas_explicativas_plazas.no_nota end as orden_num_nota,

			case when (plazas.id_status_plaza_estructura_ocupacional = 1 
			or plazas.id_status_plaza_estructura_ocupacional = 2)  
			then 0 else plazas.id_status_plaza_estructura_ocupacional end as congelada,

			case when (historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_desde <= 26
			and historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_hasta > 26)
			then 1 else 0 end as recategoriza,

			plazas.id_plaza,plazas.id_subprograma,cat_categorias.categoria,
			cat_categorias.descripcion_planteles,
			cat_categorias.id_clasifica_puesto,cat_clasifica_puestos.tipo_clasifica,cat_categorias.orden,cat_categorias.tipo_categoria,
			notas_explicativas_plazas.no_nota,notas_explicativas_plazas.no_nota_comisionada, 
			notas_explicativas_plazas.descripcion_nota,comisiones_plaza.id_subprograma as subprograma2,
			comisiones_plaza.id_plaza_comisionada,
			notas_explicativas_plazas.id_adcen,comisiones_plaza.id_adcen,
			comisiones_plaza.id_adcen_origen,
			historial_status_plaza_estructura_ocupacional.id_status_plaza_estructura_ocupacional,
			plazas.id_estructura_ocupacional
			,z.id_tipo_plaza_admon as itpa
			
			FROM plazas

			JOIN cat_categorias on cat_categorias.id_categoria=plazas.id_categoria 

			JOIN cat_clasifica_puestos ON cat_clasifica_puestos.id_clasifica_puesto = cat_categorias.id_clasifica_puesto

			LEFT JOIN notas_explicativas_plazas on notas_explicativas_plazas.id_plaza=plazas.id_plaza --and notas_explicativas_plazas.id_adcen = 4711

			LEFT JOIN comisiones_plaza on comisiones_plaza.id_plaza = plazas.id_plaza 
			INNER JOIN cat_tipo_plaza_admon z ON z.id_tipo_plaza_admon = plazas.id_tipo_plaza_admon

			LEFT JOIN historial_status_plaza_estructura_ocupacional
			on historial_status_plaza_estructura_ocupacional.id_plaza = plazas.id_plaza 
			and  historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_actual = 26


			WHERE (plazas.id_subprograma=135
			OR (comisiones_plaza.id_subprograma =135 and comisiones_plaza.id_adcen =4711)) 

			and (comisiones_plaza.id_adcen_origen = 4711 OR comisiones_plaza.id_adcen = 4711
			 OR comisiones_plaza.id_adcen_origen is null) 
			and plazas.id_estructura_ocupacional <= 26
			and (plazas.id_status_plaza_estructura_ocupacional = 1
			OR plazas.id_status_plaza_estructura_ocupacional = 2 
			OR plazas.id_status_plaza_estructura_ocupacional = 8
			OR plazas.id_status_plaza_estructura_ocupacional = 6) 

			and (notas_explicativas_plazas.id_adcen = 4711 OR notas_explicativas_plazas.id_adcen is null
			    OR  notas_explicativas_plazas.id_adcen = comisiones_plaza.id_adcen_origen )

			GROUP BY plazas.id_plaza,plazas.id_categoria,cat_categorias.categoria,plazas.id_subprograma,cat_categorias.categoria,
			cat_categorias.descripcion_planteles,
			cat_categorias.id_clasifica_puesto,cat_categorias.tipo_categoria,notas_explicativas_plazas.no_nota,
			notas_explicativas_plazas.no_nota_comisionada,
			notas_explicativas_plazas.descripcion_nota,
			comisiones_plaza.id_subprograma,comisiones_plaza.id_plaza_comisionada,cat_categorias.orden,
			plazas.id_status_plaza_estructura_ocupacional,
			historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_hasta,
			notas_explicativas_plazas.id_adcen,
			historial_status_plaza_estructura_ocupacional.id_status_plaza_estructura_ocupacional,
			historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_desde,
			comisiones_plaza.id_adcen,comisiones_plaza.id_adcen_origen,plazas.id_estructura_ocupacional,cat_clasifica_puestos.tipo_clasifica
			,z.id_tipo_plaza_admon

			HAVING COUNT(case when (comisiones_plaza.id_plaza_comisionada = 1 
			OR comisiones_plaza.id_plaza_comisionada  is NULL OR plazas.id_subprograma != 135)
			and (plazas.id_status_plaza_estructura_ocupacional = 1 
			OR plazas.id_status_plaza_estructura_ocupacional = 2)
			then cat_categorias.categoria  end)>0 OR
			(case when (historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_desde <= 26
			and historial_status_plaza_estructura_ocupacional.id_estructura_ocupacional_hasta > 26)
			then 1 else 0 end) = 1 OR
			plazas.id_status_plaza_estructura_ocupacional = 8
			OR comisiones_plaza.id_plaza_comisionada >0

			ORDER BY cat_categorias.orden,orden_num_nota,cat_categorias.id_clasifica_puesto,congelada
		