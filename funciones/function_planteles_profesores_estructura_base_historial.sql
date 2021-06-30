CREATE OR REPLACE FUNCTION planteles_profesores_estructura_base_historial( id_estructura int, id_usuario int default 0, id_componente int default 0,  accion int default 0 )
RETURNS TABLE(
	id_profesor_asignado_base_historial int,
	id_profesor_asignado_base int, 
	id_detalle_materia int, 
	id_grupo_estructura_base int, 
	fecha_sistema timestamp with time zone,
	id_profesor_estructura_base_administrador_historial int
)

AS $$
	
DECLARE
	
	ed_id_administrador int;
	ed_id_estructura int;
	ed_accion int;
	ed_id_usuario int;
	ed_id_componente int;
	rec_base RECORD;
	rec_capa RECORD;
	rec_opta RECORD;
	rec_para RECORD;

BEGIN
	
	ed_id_administrador:= 0;
	ed_id_estructura:= $1;
	ed_id_usuario:= $2;
	ed_id_componente:= $3;
	ed_accion:= $4; /* 0 = Solo consultar data,  1 = insertar data */

	-- Inserto data
	IF( ed_accion = 1 ) THEN


		-- Inserto en el administrador y obtengo el id
		INSERT INTO profesores_estructura_base_administrador_historial( id_estructura_ocupacional, id_usuario, fecha_sistema )
		VALUES ( ed_id_estructura, ed_id_usuario, now() )
		RETURNING profesores_estructura_base_administrador_historial.id_profesor_estructura_base_administrador_historial INTO ed_id_administrador;


		/* 
			Inserto en cada uno de las tablas de profesor_asignado...
				- Se agrega el insert en un ciclo for para ir cachando cada uno de los ids insertados
		*/	

		-- base
		FOR rec_base IN
		
			INSERT INTO profesor_asignado_base_historial( id_profesor_asignado_base, id_detalle_materia, id_grupo_estructura_base, fecha_sistema, id_profesor_estructura_base_administrador_historial )
			(
				SELECT pab.id_profesor_asignado_base, pab.id_detalle_materia, pab.id_grupo_estructura_base, pab.fecha_sistema, ed_id_administrador
				FROM profesor_asignado_base pab
				WHERE pab.id_grupo_estructura_base in (

					SELECT a.id_grupo_estructura_base
					FROM grupos_estructura_base a
					INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
					INNER JOIN grupos c ON c.id_grupo = b.id_grupo
					INNER JOIN periodos d ON d.id_periodo = c.id_periodo
					WHERE d.id_estructura_ocupacional = ed_id_estructura
				
				)
				ORDER BY pab.id_profesor_asignado_base ASC
			)
			RETURNING *
		 
		LOOP

			
			INSERT INTO profesores_profesor_asignado_base_historial( id_profesor_asignado_base_historial, id_profesor_asignado_base, id_profesores_profesor_asignado_base, id_plantilla_base_docente_rh, horas_grupo_base, id_tipo_movimiento_personal, id_usuario, status_licencia )
			(
				SELECT rec_base.id_profesor_asignado_base_historial, a.id_profesor_asignado_base, a.id_profesores_profesor_asignado_base
				,a.id_plantilla_base_docente_rh, a.horas_grupo_base, a.id_tipo_movimiento_personal, a.id_usuario, a.status_licencia
				FROM profesores_profesor_asignado_base a
				INNER JOIN profesor_asignado_base b ON a.id_profesor_asignado_base = b.id_profesor_asignado_base
				WHERE a.id_profesor_asignado_base = rec_base.id_profesor_asignado_base
				ORDER BY a.id_profesores_profesor_asignado_base ASC 
			);	

			

		END LOOP;


		-- capacitacion
		FOR rec_capa IN
		
			INSERT INTO profesor_asignado_capacitacion_historial( id_profesor_asignado_capacitacion, id_detalle_materia, id_grupo_capacitacion, fecha_sistema, id_profesor_estructura_base_administrador_historial )
			(
				SELECT pab.id_profesor_asignado_capacitacion, pab.id_detalle_materia, pab.id_grupo_capacitacion, pab.fecha_sistema, ed_id_administrador
				FROM profesor_asignado_capacitacion pab
				WHERE pab.id_grupo_capacitacion in (

					SELECT a.id_grupo_capacitacion
					FROM grupos_capacitacion a
					INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
					INNER JOIN grupos c ON c.id_grupo = b.id_grupo
					INNER JOIN periodos d ON d.id_periodo = c.id_periodo
					INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
					WHERE d.id_estructura_ocupacional = ed_id_estructura
					and id_formacion_trabajo is not null

				)
				ORDER BY pab.id_profesor_asignado_capacitacion ASC
			)
			RETURNING *
		 
		LOOP

			
			INSERT INTO profesores_profesor_asignado_capacitacion_historial( id_profesor_asignado_capacitacion_historial, id_profesor_asignado_capacitacion, id_profesores_profesor_asignado_capacitacion, id_plantilla_base_docente_rh, horas_grupo_capacitacion, id_tipo_movimiento_personal, id_usuario, status_licencia )
			(
				SELECT rec_capa.id_profesor_asignado_capacitacion_historial, a.id_profesor_asignado_capacitacion, a.id_profesores_profesor_asignado_capacitacion
				,a.id_plantilla_base_docente_rh, a.horas_grupo_capacitacion, a.id_tipo_movimiento_personal, a.id_usuario, a.status_licencia
				FROM profesores_profesor_asignado_capacitacion a
				INNER JOIN profesor_asignado_capacitacion b ON a.id_profesor_asignado_capacitacion = b.id_profesor_asignado_capacitacion
				WHERE a.id_profesor_asignado_capacitacion = rec_capa.id_profesor_asignado_capacitacion
				ORDER BY a.id_profesores_profesor_asignado_capacitacion ASC 
			);	

			

		END LOOP;


		-- optativas
		FOR rec_opta IN
		
			INSERT INTO profesor_asignado_optativas_historial( id_profesor_asignado_optativa, id_detalle_materia, id_grupo_optativa, fecha_sistema, id_profesor_estructura_base_administrador_historial )
			(
				SELECT pab.id_profesor_asignado_optativa, pab.id_detalle_materia, pab.id_grupo_optativa, pab.fecha_sistema, ed_id_administrador
				FROM profesor_asignado_optativas pab
				WHERE pab.id_grupo_optativa in (

					SELECT a.id_grupo_optativa
					FROM grupos_optativas a
					INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
					INNER JOIN grupos c ON c.id_grupo = b.id_grupo
					INNER JOIN periodos d ON d.id_periodo = c.id_periodo
					INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
					LEFT JOIN grupos_optativas_formacion f ON f.id_grupo_optativa = a.id_grupo_optativa
					WHERE d.id_estructura_ocupacional = ed_id_estructura
					AND f.id_formacion_propedeutica IS NOT null
					GROUP BY a.id_grupo_optativa

				)
				ORDER BY pab.id_profesor_asignado_optativa ASC
			)
			RETURNING *
		 
		LOOP

			
			INSERT INTO profesores_profesor_asignado_optativas_historial( id_profesor_asignado_optativa_historial, id_profesor_asignado_optativa, id_profesores_profesor_asignado_optativas, id_plantilla_base_docente_rh, horas_grupo_optativas, id_tipo_movimiento_personal, id_usuario, status_licencia )
			(
				SELECT rec_opta.id_profesor_asignado_optativa_historial, a.id_profesor_asignado_optativa, a.id_profesores_profesor_asignado_optativas
				,a.id_plantilla_base_docente_rh, a.horas_grupo_optativas, a.id_tipo_movimiento_personal, a.id_usuario, a.status_licencia
				FROM profesores_profesor_asignado_optativas a
				INNER JOIN profesor_asignado_optativas b ON a.id_profesor_asignado_optativa = b.id_profesor_asignado_optativa
				WHERE a.id_profesor_asignado_optativa = rec_opta.id_profesor_asignado_optativa
				ORDER BY a.id_profesores_profesor_asignado_optativas ASC 
			);	

			

		END LOOP;


	END IF;


	-- Retorno los datos que requiero con la estructura que quiero
	RETURN QUERY 
	SELECT  
		a.id_profesor_asignado_base_historial, a.id_profesor_asignado_base, a.id_detalle_materia, a.id_grupo_estructura_base, a.fecha_sistema, a.id_profesor_estructura_base_administrador_historial
	FROM profesor_asignado_base_historial a;

END;
$$  LANGUAGE plpgsql