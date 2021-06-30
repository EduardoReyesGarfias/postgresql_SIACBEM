CREATE OR REPLACE FUNCTION planteles_firmantes(id_subprograma int, id_estructura int)
RETURNS TABLE(
	id_empleado_director int,
	prefijo_director text,
	nombre_director text,
	puesto_director text,
	id_empleado_coordinador int,
	prefijo_coordinador text,
	nombre_coordinador text,
	puesto_coordinador text
)
AS $$

DECLARE
	var_tipo smallint;
	var_plantel integer;
	var_plantel_extension integer;
	var_clave_subprograma varchar;
	num_registros integer;

BEGIN
	num_registros:=0;
	var_plantel = $1;
	/* se crea tabla temp */
	CREATE TEMP TABLE temp_planteles_firmantes(
		id_empleado_director int,
		prefijo_director text,
		nombre_director text,
		puesto_director text,
		id_empleado_coordinador int,
		prefijo_coordinador text,
		nombre_coordinador text,
		puesto_coordinador text
	);
	
	/* saber el tipo de subprograma que es para saber si tratarlo como plantel, extensión, coordinacion, CEM u otro */
	SELECT INTO var_tipo
	(
		CASE WHEN ((a.nombre_subprograma like 'Plantel%') AND (a.id_programa = 1)) THEN
			CASE WHEN ((a.nombre_subprograma ilike '%Extensión%') AND (a.id_programa = 1) AND (a.clave_extension_u_organica::int > 0) ) THEN
				4
			ELSE 
				1
			END
		WHEN( (a.nombre_subprograma like 'COORDINACIÓN SECTORIAL No.%') AND (a.id_programa = 7) ) THEN
			2
		WHEN ( (a.nombre_subprograma like 'Centro de Educación Mixta%') AND (a.id_programa = 7) ) THEN
			1
		ELSE
			3
		END
	)
	FROM subprogramas a
	INNER JOIN programas b ON a.id_programa = b.id_programa
	WHERE a.id_subprograma = var_plantel
	ORDER BY a.nombre_subprograma;

	/* si es una extension entonces veo quien es su subprograma padre para sacar de ahi el director */
	IF( var_tipo = 4 ) THEN
		SELECT INTO var_plantel 
		s.id_subprograma
		FROM subprogramas s
		WHERE s.clave_subprograma = (
			SELECT ss.clave_subprograma
			FROM subprogramas ss
			WHERE ss.id_subprograma = var_plantel
		)
		AND s.clave_extension_u_organica = '0';
		var_tipo:= 1;
	END IF;		
	
	/* se pide desde un plantel la info */
IF(var_tipo = 1) THEN
	/* se inserta el director */
	INSERT INTO temp_planteles_firmantes(id_empleado_director,prefijo_director,nombre_director,puesto_director)
	(
		SELECT 
		c.id_empleado,(
			(
				SELECT
					CASE WHEN c.genero = 'M' THEN
						g.prefijo
					ELSE
						g.prefijo_fem
					END
				FROM curricula_estudios_empleados f
				INNER JOIN cat_profesiones g ON g.id_profesion = f.id_profesion
				INNER JOIN cat_grados_academicos h ON h.id_grado_academico = g.id_grado_academico
				WHERE f.id_empleado = c.id_empleado
				ORDER BY h.nivel_grado_academico DESC
				LIMIT 1
			)
		),c.nombre || ' ' || c.paterno || ' ' || c.materno,
		(
			CASE WHEN c.genero = 'M' THEN
				'DIRECTOR DEL PLANTEL'
			ELSE
				'DIRECTORA DEL PLANTEL'
			END
		)
		FROM plantilla_base_Administrativo_plantel a
		INNER JOIN subprogramas b ON b.id_subprograma = a.id_subprograma
		INNER JOIN empleados c ON a.id_empleado = c.id_empleado 
		INNER JOIN plazas d ON d.id_plaza = a.id_plaza
		INNER JOIN cat_categorias e ON e.id_categoria = d.id_categoria
		WHERE a.id_estructura_ocupacional = $2
		AND a.id_subprograma = var_plantel
		and e.categoria IN ('A2405','A2404','A2406')
	);
	
	-- ver si si tiene director
	SELECT INTO num_registros 
	count(*) 
	FROM temp_planteles_firmantes;
	IF num_registros = 0 THEN
		INSERT INTO temp_planteles_firmantes(id_empleado_director,prefijo_director,nombre_director,puesto_director)
		VALUES (0,'','','DIRECTOR DEL PLANTEL');
	END IF;

	/* se inserta el coordinador */
	UPDATE temp_planteles_firmantes tempp 
	SET 
	id_empleado_coordinador = c.id_empleado,
	prefijo_coordinador = (
		SELECT
			CASE WHEN c.genero = 'M' THEN
				g.prefijo
			ELSE
				g.prefijo_fem
			END
		FROM curricula_estudios_empleados f
		INNER JOIN cat_profesiones g ON g.id_profesion = f.id_profesion
		INNER JOIN cat_grados_academicos h ON h.id_grado_academico = g.id_grado_academico
		WHERE f.id_empleado = c.id_empleado
		ORDER BY h.nivel_grado_academico DESC
		LIMIT 1
	)
	,nombre_coordinador = c.nombre || ' ' || c.paterno || ' ' || c.materno
	,puesto_coordinador = (
			CASE WHEN c.genero = 'M' THEN
				'COORDINADOR SECTORIAL'
			ELSE
				'COORDINADORA SECTORIAL'
			END
		)
	FROM plantilla_base_Administrativo_plantel a
	INNER JOIN subprogramas b ON b.id_subprograma = a.id_subprograma
	INNER JOIN empleados c ON a.id_empleado = c.id_empleado 
	INNER JOIN plazas d ON d.id_plaza = a.id_plaza
	INNER JOIN cat_categorias e ON e.id_categoria = d.id_categoria
	WHERE a.id_estructura_ocupacional = $2
	AND a.id_subprograma = (
		SELECT subp.id_subprograma
		FROM subprogramas as subp
		WHERE subp.nombre_subprograma 
		LIKE 'COORDINACIÓN SECTORIAL No. '||(select s.coordinacion from subprogramas as s where s.id_subprograma = var_plantel)||'%'
		LIMIT 1
	)
	and e.categoria = 'CF01005';
	
ELSIF(var_tipo = 2) THEN

	INSERT INTO temp_planteles_firmantes(id_empleado_coordinador,prefijo_coordinador,nombre_coordinador,puesto_coordinador)
	(
		SELECT
		c.id_empleado,(
			SELECT		   
			CASE WHEN c.genero = 'M' THEN
					g.prefijo
				ELSE
					g.prefijo_fem
				END
			FROM curricula_estudios_empleados f
			INNER JOIN cat_profesiones g ON g.id_profesion = f.id_profesion
			INNER JOIN cat_grados_academicos h ON h.id_grado_academico = g.id_grado_academico
			WHERE f.id_empleado = c.id_empleado
			ORDER BY h.nivel_grado_academico DESC
			LIMIT 1
		),c.nombre || ' ' || c.paterno || ' ' || c.materno,(
			CASE WHEN c.genero = 'M' THEN
				'COORDINADOR SECTORIAL'
			ELSE
				'COORDINADORA SECTORIAL'
			END
		)
		FROM plantilla_base_Administrativo_plantel a
		INNER JOIN subprogramas b ON b.id_subprograma = a.id_subprograma
		INNER JOIN empleados c ON a.id_empleado = c.id_empleado 
		INNER JOIN plazas d ON d.id_plaza = a.id_plaza
		INNER JOIN cat_categorias e ON e.id_categoria = d.id_categoria
		WHERE a.id_estructura_ocupacional = $2
		AND a.id_subprograma = (
			SELECT subp.id_subprograma
			FROM subprogramas as subp
			WHERE subp.id_subprograma = var_plantel
			LIMIT 1
		)
		and e.categoria = 'CF01005'
	);
	
ELSIF(var_tipo = 3) THEN
	
	/* inserta responsable de servicios y pagos a terceros */
	INSERT INTO temp_planteles_firmantes(id_empleado_director,prefijo_director,nombre_director,puesto_director)
	(
		SELECT 
		c.id_empleado,(
			CASE WHEN c.genero = 'M' THEN
				e.prefijo
			ELSE
				e.prefijo_fem
			END
		),c.paterno||' '||c.materno||' '||c.nombre, ('Responsable de '||g.nombre_oficina)
		FROM responsables_por_oficina b 
		INNER JOIN empleados c ON c.id_empleado = b.id_empleado_reviso
		INNER JOIN curricula_estudios_empleados d ON d.id_empleado = c.id_empleado
		INNER JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
		INNER JOIN cat_grados_academicos f ON f.id_grado_academico = e.id_grado_academico
		INNER JOIN oficinas_subprogramas g ON g.id_oficina = b.id_oficina
		WHERE b.id_responsable_oficina = 2
	);
	
	/* inserto jefe de recursos humanos */
	UPDATE temp_planteles_firmantes tempp 
	SET id_empleado_coordinador = b.id_empleado
	,prefijo_coordinador = (
		CASE WHEN b.genero = 'M' THEN
			e.prefijo
		ELSE
			e.prefijo_fem
		END
	)
	,nombre_coordinador = b.paterno||' '||b.materno||' '||b.nombre
	,puesto_coordinador = ('Responsable de '||g.nombre_subprograma)
	FROM responsables_departamentos a 
	INNER JOIN empleados b ON b.id_empleado = a.id_empleado_responsable
	INNER JOIN curricula_estudios_empleados d ON d.id_empleado = b.id_empleado
	INNER JOIN cat_profesiones e ON e.id_profesion = d.id_profesion
	INNER JOIN cat_grados_academicos f ON f.id_grado_academico = e.id_grado_academico
	INNER JOIN subprogramas g ON g.id_subprograma = a.id_subprograma	
	WHERE a.id_responsable_oficina = 13;
		
END IF;
	
	
	/* regreso query con los datos */
	RETURN QUERY SELECT * 
				 FROM temp_planteles_firmantes t;
	
	/* Al retornar se destruye la tambla temporal */
	DROP TABLE temp_planteles_firmantes;
END; $$ 
 
LANGUAGE 'plpgsql';
	
/* plantel */	
select * from planteles_firmantes(36,26);	
	
/* coordinacion */	
select * from planteles_firmantes(6,26);

/* CEM */	
select * from planteles_firmantes(221,26);

/* oficina */	
select * from planteles_firmantes(2,26);

/* Extension de plantel */
select * from planteles_firmantes(47,27);
select * from planteles_firmantes(48,27);




-- 221,228,229,230
