CREATE OR REPLACE FUNCTION planteles_valida_perfil_tf_descarga_empleado(_id_empleado int, _id_estructura int, _id_materia int, _hora_semana_mes int)
RETURNS boolean
AS $$
DECLARE
	_validado boolean;
	_es_habilitado boolean;
	_id_subprograma integer;
	_filiacion character varying;
	_horas_descarga smallint;
	_horas_asignadas_tf smallint;

BEGIN
	
	_validado:= false;
	_es_habilitado:= false;
	_id_subprograma:= 0;
	_horas_descarga:= 0;
	_horas_asignadas_tf:= 0;

	/**
	* 1.- Debe ser habilitado
	* 2.- Debe tener horas en descarga de sus plazas de base
	* 3.- La materia debe ser una de las que tiene habilitadas
	* 4.- Revisar de las asignadas en tiempo fijo cuantas tiene en alta 14
	*/

	-- Ver si es habilitado en la materia y en la estructura
	SELECT INTO _es_habilitado
	CASE WHEN (habilitado.id_profesor_habilitado) > 0 THEN true ELSE false END 
	FROM profesores_habilitados habilitado
	WHERE 
		habilitado.id_estructura_ocupacional = _id_estructura
		AND habilitado.id_empleado = _id_empleado
		AND habilitado.id_detalle_materia = _id_materia
	LIMIT 1;

	IF (_es_habilitado IS NULL) THEN
		_es_habilitado:= false;
	END IF;
	
	-- Ver si le sobran horas
	IF(_es_habilitado) THEN

		-- Saber un plantel en donde tiene plaza el empleado
		SELECT INTO _id_subprograma, _filiacion
			plantilla.id_subprograma, emp.filiacion
		FROM plantilla_base_docente_rh plantilla
		INNER JOIN empleados emp ON emp.id_empleado = plantilla.id_empleado
		WHERE 
		emp.id_empleado = _id_empleado
		AND plantilla.id_estructura_ocupacional = _id_estructura
		AND plantilla.revision_rh is true
		LIMIT 1;

		IF(_id_subprograma IS NOT NULL) THEN

			SELECT INTO _horas_descarga
			hrs_desc
			FROM planteles_dom05_1(_id_subprograma, _id_estructura) dom05
			WHERE dom05.filiacion = _filiacion
			LIMIT 1;

			IF( _horas_descarga IS NOT NULL ) THEN
			
				-- Ver cuantas horas tiene asignadas en tiempo fijo en alta 14
				SELECT INTO _horas_asignadas_tf
				CAST(SUM(horas_grupo) as smallint)
				FROM view_horas_asignadas_empleado_tf asignados_tf
				WHERE 
				asignados_tf.id_empleado = _id_empleado
				AND id_estructura_ocupacional = _id_estructura;

				IF(_horas_asignadas_tf IS NOT NULL) THEN

					IF(_horas_descarga + _horas_asignadas_tf >= _hora_semana_mes) THEN
						_validado:= true;
					END IF;	

				END IF;	

			END IF;
		
		END IF;

	END IF;	


	RETURN _validado;

END; $$ 
LANGUAGE 'plpgsql';