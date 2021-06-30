/*
CREATE OR REPLACE FUNCTION planteles_cantidad_docentes_dom28(id_subprograma int, id_estructura int)
RETURNS integer

AS $$

DECLARE
/* declaro variables
	contador, me dira cuantos son
	cur_docentes tiene la query para recorrerla en un for
*/
contador integer;
reg     RECORD;
cur_docentes CURSOR FOR SELECT a.id_empleado 
FROM plantilla_base_docente_rh a
INNER JOIN empleados b ON a.id_empleado = b.id_empleado
WHERE a.id_subprograma = $1 AND
a.id_estructura_ocupacional = $2 AND
a.revision_rh = true
GROUP BY a.id_empleado
ORDER BY a.id_empleado;

BEGIN
	contador:=0; /* inicializo la variable en 0 */
	/* se recorre la query */
	FOR reg IN cur_docentes LOOP
		contador := contador + 1;
	END LOOP;
	
	RETURN contador;
END; $$
LANGUAGE 'plpgsql';
*/


/*
CREATE OR REPLACE FUNCTION planteles_resumen_semestre_dom28(id_subprograma int,id_estructura int)
RETURNS TABLE(
	semestre smallint,
	semestre_texto varchar,
	no_grupos smallint,
	hsm_grupo bigint,
	total_hsm_aut bigint
)

AS $$

DECLARE
	hsm_1 bigint;
	hsm_2 bigint;
	hsm_3 bigint;
	hsm_4 bigint;
	hsm_5 bigint;
	hsm_6 bigint;
	gpos_1 bigint;
	gpos_2 bigint;
	gpos_3 bigint;
	gpos_4 bigint;
	gpos_5 bigint;
	gpos_6 bigint;
	var_id_plan1 int;
	var_id_plan2 int;
	var_id_plan3 int;
	reg_hsm RECORD;
	reg_comb RECORD;
	cur_hsm CURSOR FOR (select 
			sum(semestre1) as semestre1,
			sum(semestre2) as semestre2,
			sum(semestre3) as semestre3,
			sum(semestre4) as semestre4,
			sum(semestre5) as semestre5,
			sum(semestre6) as semestre6
			from temp_planteles_hsm_grupos_dom28); 
	cur_comb CURSOR FOR 
			(-- sacar combinacion
			SELECT 
			a.id_periodo,e.id_adcen,substring(c.periodo FROM 6 FOR 1),b.id_grupo_combinacion_plan,b.semestre1,b.semestre2
			,b.semestre3,b.semestre4,b.semestre5,b.semestre6
			,d.id_plan_grupo_activo1,d.id_plan_grupo_activo2,d.id_plan_grupo_activo3,
			(d.id_plan_grupo_activo1||','||d.id_plan_grupo_activo2||','||d.id_plan_grupo_activo3)AS id_planes_activos,
			(
				CASE WHEN CAST(substring(c.periodo FROM 6 FOR 1)as int) = 2 THEN
					'1,3,5'
				ELSE
					'2,4,6'
				END
			) as activos
			FROM periodos a
			INNER JOIN grupos b ON b.id_periodo = a.id_periodo
			INNER JOIN cat_estructuras_ocupacionales c ON c.id_estructura_ocupacional = a.id_estructura_ocupacional
			INNER JOIN grupos_combinaciones_planes d ON d.id_grupo_combinacion_plan = b.id_grupo_combinacion_plan
			INNER JOIN adcen e ON e.id_estructura_ocupacional = c.id_estructura_ocupacional
			WHERE a.id_subprograma = $1 AND
			a.id_estructura_ocupacional = $2 AND
			e.id_subprograma = $1);

BEGIN
	
	gpos_1:=1;
	gpos_2:=1;
	gpos_3:=1;
	gpos_4:=1;
	gpos_5:=1;
	gpos_6:=1;

	-- Creo tabla temporal
	CREATE TEMP TABLE temp_planteles_resumen_semestre_dom28(
		semestre smallint,
		semestre_texto varchar,
		no_grupos smallint,
		hsm_grupo bigint,
		total_hsm_aut bigint
	);
	
	-- Saco datos para generar hsm de grupos
	FOR reg_comb IN cur_comb LOOP
		var_id_plan1:= reg_comb.id_plan_grupo_activo1;
		var_id_plan2:= reg_comb.id_plan_grupo_activo2;
		var_id_plan3:= reg_comb.id_plan_grupo_activo3;
		gpos_1:= reg_comb.semestre1;
		gpos_2:= reg_comb.semestre2;
		gpos_3:= reg_comb.semestre3;
		gpos_4:= reg_comb.semestre4;
		gpos_5:= reg_comb.semestre5;
		gpos_6:= reg_comb.semestre6;
	END LOOP;
	
	-- Creo tabla temporal para ayudarme con las hsm por grupo
	CREATE TEMP TABLE temp_planteles_hsm_grupos_dom28(
		id_componente int,
		semestre int,
		semestre1 int,
		semestre2 int,
		semestre3 int,
		semestre4 int,
		semestre5 int,
		semestre6 int
	);
	
	- Inserto hrsm por grupo pos semestre 
	INSERT INTO temp_planteles_hsm_grupos_dom28(id_componente,semestre,semestre1,semestre2,semestre3,semestre4,semestre5,semestre6)
	SELECT
		e.id_componente,
		d.semestre,
		(case when d.semestre=1 then horas_totales*b.semestre1 else '0' end) as semestre_1,
		(case when d.semestre=2 then horas_totales*b.semestre2 else '0' end) as semestre_2,
		(case when d.semestre=3 then horas_totales*b.semestre3 else '0' end) as semestre_3,
		(case when d.semestre=4 then horas_totales*b.semestre4 else '0' end) as semestre_4,
		(case when d.semestre=5 then horas_totales*b.semestre5 else '0' end) as semestre_5,
		(case when d.semestre=6 then horas_totales*b.semestre6 else '0' end) as semestre_6
	FROM periodos a 
	JOIN grupos b ON b.id_periodo=a.id_periodo
	JOIN horas_autorizadas c ON c.id_grupo=b.id_grupo
	JOIN horas_componente_plan_estudios d ON d.id_hora_componente_plan_estudio=c.id_hora_componente_plan_estudio
	JOIN cat_componentes e ON e.id_componente=d.id_componente
	WHERE a.id_subprograma=$1 and 
	a.id_tipo_periodo=1 and 
	e.id_componente !=5 and
	d.id_plan_estudio in (var_id_plan1,var_id_plan2,var_id_plan3)
	and a.id_estructura_ocupacional=$2
	order by e.id_componente,d.semestre;
	
	-- saco los valores  
	FOR reg_hsm IN cur_hsm LOOP
		hsm_1:=reg_hsm.semestre1;
		hsm_2:=reg_hsm.semestre2;
		hsm_3:=reg_hsm.semestre3;
		hsm_4:=reg_hsm.semestre4;
		hsm_5:=reg_hsm.semestre5;
		hsm_6:=reg_hsm.semestre6;
	END LOOP;
	
	-- Agregar datos a la tabla 
	INSERT INTO temp_planteles_resumen_semestre_dom28(semestre,semestre_texto,no_grupos,total_hsm_aut) VALUES
	(1,'PRIMERO',gpos_1,hsm_1),(2,'SEGUNDO',gpos_2,hsm_2),(3,'TERCERO',gpos_3,hsm_3),
	(4,'CUARTO',gpos_4,hsm_4),(5,'QUINTO',gpos_5,hsm_5),(6,'SEXTO',gpos_6,hsm_6);
	
	-- Actualizar hsm_grupo los 
	UPDATE temp_planteles_resumen_semestre_dom28 t SET hsm_grupo = (
		CASE WHEN t.no_grupos > 0 AND t.total_hsm_aut > 0 THEN
			t.total_hsm_aut/t.no_grupos
		ELSE
			0
		END
	);
	
	
	RETURN QUERY SELECT * FROM temp_planteles_resumen_semestre_dom28;
	--RETURN query SELECT * FROM temp_planteles_hsm_grupos_dom28;
	
	-- Al retornar se destruye la tambla temporal
	DROP TABLE temp_planteles_resumen_semestre_dom28;
	DROP TABLE temp_planteles_hsm_grupos_dom28;
END; $$
LANGUAGE 'plpgsql';
*/


CREATE OR REPLACE FUNCTION planteles_resumen_capacitacion_dom28(id_subprograma int,id_estructura int)
RETURNS TABLE(
	semestre smallint,
	semestre_texto varchar,
	capacitacion varchar,
	no_grupos smallint,
	hsm_capacitacion bigint,
	total_hsm bigint
)

AS $$

DECLARE 
	semestre_activo1 smallint;
	semestre_activo2 smallint;
	semestre_activo3 smallint;
	var_id_plan1 smallint;
	var_id_plan2 smallint;
	var_id_plan3 smallint;
	var_id_grupo_combinacion_plan smallint;
	var_vuelta smallint;
	reg_activos RECORD;
	reg_grupos RECORD;
	cur_activos CURSOR FOR SELECT 
				(CASE WHEN (CAST(substring(periodo FROM 6 FOR 2) as int)) = 2 THEN
					'1,3,5'
				ELSE
					'2,4,6'
				END) AS activos
			FROM cat_estructuras_ocupacionales
			WHERE id_estructura_ocupacional = $2;
	cur_grupos CURSOR FOR SELECT count(a.nombre_grupo) as num_grupos
		,(CASE 
		   	WHEN substring(a.nombre_grupo from 1 for 1)='2' OR substring(a.nombre_grupo from 1 for 1)='1'  then id_plan_grupo_activo1
		    WHEN substring(a.nombre_grupo from 1 for 1)='4' OR substring(a.nombre_grupo from 1 for 1)='3' then id_plan_grupo_activo2
		    WHEN substring(a.nombre_grupo from 1 for 1)='6' OR substring(a.nombre_grupo from 1 for 1)='5' then id_plan_grupo_activo3  
			    END)id_plan_grupo_activo,GC.id_grupo_combinacion_plan
		FROM grupos_estructura_base a
		INNER JOIN horas_autorizadas b ON b.id_hora_autorizada = a.id_hora_autorizada
		INNER JOIN grupos c ON b.id_grupo = c.id_grupo
		INNER JOIN grupos_combinaciones_planes gc ON gc.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan
		INNER JOIN periodos d ON c.id_periodo = d.id_periodo
		WHERE d.id_subprograma = $1 and
		d.id_estructura_ocupacional = ($2) 
		GROUP BY substring(a.nombre_grupo from 1 for 1),id_plan_grupo_activo1,id_plan_grupo_activo2,id_plan_grupo_activo3,GC.id_grupo_combinacion_plan
		ORDER BY substring(a.nombre_grupo from 1 for 1);

BEGIN
	semestre_activo1:=1;
	semestre_activo2:=3;
	semestre_activo3:=5;
	
	FOR reg_activos IN cur_activos LOOP
		IF reg_activos.activos = '1,3,5' THEN
			semestre_activo1:=1;
		semestre_activo2:=3;
		semestre_activo3:=5;
		ELSIF reg_activos.activos = '2,4,6' THEN
			semestre_activo1:=2;
			semestre_activo2:=4;
			semestre_activo3:=6;
		END IF;	
	END LOOP;

	var_vuelta:=1;
	FOR reg_gpos IN cur_grupos LOOP
    	
		IF var_vuelta = 1 THEN
			var_id_plan1:=reg_gpos.id_plan_grupo_activo;
		ELSIF var_vuelta = 2 THEN 	
			var_id_plan2:=reg_gpos.id_plan_grupo_activo;
		ELSIF var_vuelta = 3 THEN 	
			var_id_plan3:=reg_gpos.id_plan_grupo_activo;
		END IF;	
		
		var_id_grupo_combinacion_plan:=reg_gpos.id_grupo_combinacion_plan;
		var_vuelta := var_vuelta + 1;
		
   	END LOOP;
	
	/* creo tabla temporal */
	CREATE TEMP TABLE temp_planteles_dom28_resumen_capacitacion(
		semestre smallint,
		semestre_texto varchar,
		capacitacion varchar,
		no_grupos smallint,
		hsm_capacitacion bigint,
		total_hsm bigint
	);
	
	INSERT INTO temp_planteles_dom28_resumen_capacitacion(semestre,semestre_texto,capacitacion,total_hsm,no_grupos,hsm_capacitacion
	)
	(
		SELECT
		h.semestre,
		(
			CASE WHEN h.semestre = 1 THEN
			'PRIMERO'
			 WHEN h.semestre = 2 THEN
			'SEGUNDO'
			 WHEN h.semestre = 3 THEN
			'TERCERO'
			 WHEN h.semestre = 4 THEN
			'CUARTO'
			 WHEN h.semestre = 5 THEN
			'QUINTO'
			 WHEN h.semestre = 6 THEN
			'SEXTO'
			END
		)as semestre_texto
		,componente_trabajo,sum(hora_semana_mes)as hsm_x_grupos
		--,count(componente_trabajo)/2 as num_grupos
		,(CASE count(componente_trabajo)/2
		   WHEN 0 THEN 1
		   ELSE count(componente_trabajo)/2
		END) as num_grupos
		, (sum(hora_semana_mes)/(
			CASE count(componente_trabajo)/2
			   WHEN 0 THEN 1
			   ELSE count(componente_trabajo)/2
			END
		) )
		FROM grupos_capacitacion a
		INNER JOIN horas_autorizadas b ON a.id_hora_autorizada = b.id_hora_autorizada
		INNER JOIN grupos c ON c.id_grupo = b.id_grupo
		INNER JOIN periodos d ON d.id_periodo = c.id_periodo
		INNER JOIN grupos_combinaciones_planes e ON e.id_grupo_combinacion_plan = c.id_grupo_combinacion_plan

		INNER JOIN cat_formacion_trabajo f ON f.id_formacion_trabajo = a.id_formacion_trabajo 
		INNER JOIN materias_componente_trabajo g ON g.id_formacion_trabajo = f.id_formacion_trabajo
		INNER JOIN detalle_materias h ON h.id_detalle_materia = g.id_detalle_materia
		INNER JOIN cat_materias i ON i.id_materia = h.id_materia

		WHERE d.id_subprograma = $1 and d.id_estructura_ocupacional = $2
		   and h.id_plan_estudio in(var_id_plan2,var_id_plan3)
		   and (CAST(substring(nombre_grupo_capacitacion FROM 1 FOR 1) as int) = semestre_activo2 OR CAST(substring(nombre_grupo_capacitacion FROM 1 FOR 1) as int) = semestre_activo2 )
		   and h.semestre in(semestre_activo2,semestre_activo3)
		GROUP BY componente_trabajo,h.semestre 
		ORDER BY componente_trabajo   	
	);
	
	RETURN QUERY SELECT * FROM temp_planteles_dom28_resumen_capacitacion ORDER BY semestre,capacitacion;
	
	DROP TABLE temp_planteles_dom28_resumen_capacitacion;

END; $$
LANGUAGE 'plpgsql';

SELECT * FROM planteles_resumen_capacitacion_dom28(98,26);

SELECT semestre,semestre_texto,no_grupos,hsm_grupo,total_hsm_aut 
FROM planteles_resumen_semestre_dom28(42,24)
WHERE no_grupos > 0 AND total_hsm_aut > 0;

select * from planteles_cantidad_docentes_dom28(42,24);