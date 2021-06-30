<?php
include("../../../librerias/reordenar_arreglo.php");

/**
* Obtengo el periodo (desde-hasta) de acuerdo a  la fecha dada
*/
function periodo_desde_hasta(){
	$query_periodo = "
		SELECT * FROM fecha_a_periodo_estructura(CAST('2021-08-28 13:30:53.759914-05' AS timestamp with time zone))
		--SELECT * FROM fecha_a_periodo_estructura(now())	
	";
	$res_periodo = pg_query($query_periodo);
	$periodo = pg_fetch_array($res_periodo)[0];
	$desde_hasta = explode('-', $periodo);

	return array($desde_hasta[0], $desde_hasta[1]);
}

/**
* Obtengo los subprogramas de acuerdo a la clave subprograma
*/
function subprogramas($clave_subprograma){

	$query_subprogramas = "
		SELECT id_subprograma, nombre_subprograma, clave_subprograma, clave_extension_u_organica
		FROM subprogramas
		WHERE clave_subprograma = '$clave_subprograma'
		ORDER BY clave_extension_u_organica ASC
	";
	$res_subprogramas = pg_query($query_subprogramas);
	$subprogramas = pg_fetch_all($res_subprogramas);
	pg_free_result($res_subprogramas);

	// Separo solo los ids
	$ids_subprogramas = [];
	foreach ($subprogramas as $key => $item) {
		$ids_subprogramas[] = $item['id_subprograma'];
	}
	$ids_subprogramas = implode(',', $ids_subprogramas);

	return array($subprogramas, $ids_subprogramas);

}

/**
* Traigo todos los planteles
*/
function todos_subprogramas(){
	$query_subprogramas = "
		SELECT id_subprograma, nombre_subprograma
		FROM subprogramas
		WHERE id_programa in(1,7)
		AND fecha_fin is null
		ORDER BY nombre_subprograma
	";
	$res_subprogramas = pg_query($query_subprogramas);
	$todos_subprogramas = pg_fetch_all($res_subprogramas);
	pg_free_result($res_subprogramas);

	return $todos_subprogramas;
}

/**
* Obtengo las claves de base de la plantilla, relacionada a la clave_subprograma
*/
function plantilla($ids_subprogramas, $id_estructura_ocupacional){

	/*$query_plantilla = "
		SELECT
		TRIM(b.paterno)||' '||TRIM(b.materno)||' '||TRIM(b.nombre) AS nombre_completo
		,b.filiacion
		,d.id_subprograma, d.nombre_subprograma
		,TRIM(c.categoria_padre) AS categoria
		,TRIM(lpad(a.num_plz, 3,'0')) AS num_plz
		,lpad(CAST(a.hrs_categoria AS text),2,'0') AS hrs_categoria
		,true AS existe_en_plantilla, false AS existe_en_movimientos
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN subprogramas d ON d.id_subprograma = a.id_subprograma
		WHERE a.id_estructura_ocupacional IS NULL
		AND a.id_subprograma = ANY(ARRAY[$ids_subprogramas])
		AND revision_rh IS TRUE
		ORDER BY d.id_subprograma,filiacion,nombre_completo ASC
	";*/


	$query_plantilla = "
		SELECT
		b.id_empleado
		,TRIM(b.paterno)||' '||TRIM(b.materno)||' '||TRIM(b.nombre) AS nombre_completo
		,b.filiacion
		,d.id_subprograma, d.nombre_subprograma
		,c.id_cat_categoria_padre
		,TRIM(c.categoria_padre) AS categoria
		,TRIM(lpad(a.num_plz, 3,'0')) AS num_plz
		,lpad(CAST(a.hrs_categoria AS text),2,'0') AS hrs_categoria
		,1 AS existe_en_plantilla
		,0 AS existe_en_movimientos
		,(
			CASE WHEN c.categoria_padre ilike 'EH%' THEN
				(SELECT
				json_agg(
					cat_catego.categoria_padre||'/'||
					lpad(pbdr.num_plz, 3, '0')||'/'||
					lpad(CAST(hrs_categoria AS text), 2, '0')||'-'||
					pbdr.id_subprograma 
					ORDER BY cat_catego.categoria_padre, pbdr.num_plz, hrs_categoria
				) as claves_estructura
				FROM plantilla_base_docente_rh pbdr
				INNER JOIN cat_categorias_padre cat_catego ON cat_catego.id_cat_categoria_padre = pbdr.id_cat_categoria_padre
				INNER JOIN subprogramas subp ON subp.id_subprograma = pbdr.id_subprograma
				WHERE id_estructura_ocupacional = $id_estructura_ocupacional
				AND cat_catego.categoria_padre ilike 'EH%'
				AND revision_rh is true
				AND cat_catego.categoria_padre = c.categoria_padre
				AND lpad(pbdr.num_plz, '3', '0') = lpad(a.num_plz, '3', '0')
				)
			END
		) AS jornada_distribuida_base
		FROM plantilla_base_docente_rh a
		INNER JOIN empleados b ON a.id_empleado = b.id_empleado
		INNER JOIN cat_categorias_padre c ON c.id_cat_categoria_padre = a.id_cat_categoria_padre
		INNER JOIN subprogramas d ON d.id_subprograma = a.id_subprograma
		WHERE 
		a.id_estructura_ocupacional = $id_estructura_ocupacional
		AND a.id_subprograma = ANY(ARRAY[$ids_subprogramas])
		AND revision_rh IS TRUE
		ORDER BY d.id_subprograma,filiacion,nombre_completo ASC
	";

	$res_plantilla = pg_query($query_plantilla);
	$plant = pg_fetch_all($res_plantilla);
	pg_free_result($res_plantilla);

	$plantilla = [];

	foreach ($plant as $key => $plan) {
		
		if ($plan['jornada_distribuida_base'] !== null) {
			
			$plant[$key]['existe_en_plantilla'] = 0;
			$plant[$key]['existe_en_movimientos'] = 1;

			$jornadas = json_decode($plan['jornada_distribuida_base']);
			$sumatoria_hrs = 0;
			foreach ($jornadas as $key1 => $jornada) {
				
				$partes = explode('-', $jornada);
				$hrs_categoria = explode('/', $partes[0])[2];
				$sumatoria_hrs+=$hrs_categoria;
			}

			$plant[$key]['hrs_categoria'] = $sumatoria_hrs;
		}

		$plantilla[] = $plant[$key];

	}
	echo "<pre>$query_plantilla</pre>";

	return $plantilla;

}


/**
* Obtnego el ultimo id de plazas nomina rh
*/
function id_movimiento(){
	$query_id = "
		SELECT
		id_plaza_nomina_rh_datos, fecha_actualizado
		FROM plazas_nominas_rh_datos
		ORDER BY id_plaza_nomina_rh_datos DESC
		LIMIT 1
	";
	$res_id = pg_query($query_id);
	$mov = pg_fetch_array($res_id);

	return array($mov['id_plaza_nomina_rh_datos'], $mov['fecha_actualizado']);
}

/**
* Obtengo las claves de base de los movimientos, relacionados a la clave subprograma
*/
function movimientos($id_subprograma, $desde_periodo, $hasta_periodo, $id_plaza_nomina_rh_datos, $id_estructura_ocupacional){

	$query_mov = "
		SELECT
			pnom.filiacion
			,emp.id_empleado
			,( emp.paterno || ' ' || emp.materno || ' ' || emp.nombre ) AS nombre_completo
			,emp.id_subprograma_adscripcion
			,catego.id_cat_categoria_padre
			,TRIM(pnom.clave_plz) AS categoria
			,TRIM(pnom.numero_plz) AS num_plz
			,TRIM(pnom.numero_hr) AS hrs_categoria
			,0 AS existe_en_plantilla
			,1 AS existe_en_movimientos
			,(
				SELECT json_agg(clave_plz||'/'||numero_plz||'/'||hrs)
				FROM jornadas_sispagos_trigger a
				INNER JOIN subprogramas b ON a.subprograma = b.clave_subprograma
				WHERE filiacion = pnom.filiacion
				AND hasta between $desde_periodo AND $hasta_periodo
				AND clave_plz = pnom.clave_plz
				AND numero_plz = pnom.numero_plz
				AND ((CAST(motivo_movimiento as smallint) between 6 AND 19) OR motivo_movimiento = '59' OR motivo_movimiento = '14' OR motivo_movimiento = '35' OR motivo_movimiento = '69')
				AND b.id_subprograma = $id_subprograma
			) as jornada_distribuida
			,(
				CASE WHEN clave_plz ilike 'EH%' THEN
					(SELECT
					json_agg(
						cat_catego.categoria_padre||'/'||lpad(pbdr.num_plz, 3, '0')||'/'||lpad(CAST(hrs_categoria AS text), 2, '0')||'-'||pbdr.id_subprograma 
						ORDER BY cat_catego.categoria_padre, pbdr.num_plz, hrs_categoria
					) as claves_estructura
					FROM plantilla_base_docente_rh pbdr
					INNER JOIN cat_categorias_padre cat_catego ON cat_catego.id_cat_categoria_padre = pbdr.id_cat_categoria_padre
					INNER JOIN subprogramas subp ON subp.id_subprograma = pbdr.id_subprograma
					WHERE id_estructura_ocupacional = $id_estructura_ocupacional
					AND cat_catego.categoria_padre ilike 'EH%'
					AND revision_rh is true
					AND cat_catego.categoria_padre = pnom.clave_plz
					AND lpad(pbdr.num_plz, 3,'0') = lpad(pnom.numero_plz, 3,'0')
					)
				END
			) AS jornada_distribuida_base
		FROM plazas_nomina_rh_recibe pnom
		JOIN empleados emp ON pnom.filiacion = emp.filiacion
		LEFT JOIN cat_categorias_padre catego ON TRIM(catego.categoria_padre) = TRIM(clave_plz)
		WHERE
			pnom.id_plaza_nomina_rh_datos = $id_plaza_nomina_rh_datos
			AND pnom.estado_rec = '0'
			AND (
				pnom.tipo_nombr = '14'
				OR (
					(pnom.tipo_nombr = '15' AND pnom.hasta_plz = '999999')
					OR
					(pnom.tipo_nombr = '15'
						AND pnom.hasta_plz != '999999'
						AND pnom.motivo_mov IN (
							-- licencias sin sueldo
							'40','41','43','46','47','48','49',
							-- prorrogas de licencia sin sueldo
							'50','51','52','55','56','57'
							)
						)
				)
			)
			--AND (pnom.numero_hr != ' ' OR pnom.numero_hr IS NOT NULL)
			AND substring(pnom.subprograma, 2) = (
				SELECT
					case
						when clave_subprograma = '001'
						then clave_extension_u_organica
						else clave_subprograma
					end as clave
				FROM subprogramas
				where
					fecha_fin is null
					and id_subprograma = $id_subprograma
			)
			AND catego.tipo_categoria = ANY(ARRAY[2,4])
		ORDER BY
			--motivo_mov,
			pnom.filiacion, nombre_completo
	";
	$res_mov = pg_query($query_mov);
	$movs = pg_fetch_all($res_mov);
	pg_free_result($res_mov);

	$movimientos = [];

	foreach ($movs as $key => $mov) {
		
		if ($mov['jornada_distribuida'] == null AND $mov['jornada_distribuida_base'] == null)
			$movimientos[] = $mov;
		else{
			
			if ($mov['jornada_distribuida'] !== null) {
			
				$jornadas = json_decode($mov['jornada_distribuida']);
				
				foreach ($jornadas as $key1 => $jornada) {
					
					$clave = explode('/', $jornada);
					$categoria = $clave[0];
					$num_plz = $clave[1];
					$hrs_categoria = $clave[2];

					$movimientos[] = array(
						"filiacion" => $mov['filiacion'],
			            "id_empleado" => $mov['id_empleado'],
			            "nombre_completo" => $mov['nombre_completo'],
			            "id_subprograma_adscripcion" => null,
			            "id_cat_categoria_padre" => $mov['id_cat_categoria_padre'],
			            "categoria" => $categoria,
			            "num_plz" => $num_plz,
			            "hrs_categoria" => $hrs_categoria,
			            "existe_en_plantilla" => 0,
			            "existe_en_movimientos" => 1,
			            "jornada_distribuida" => $jornada
					);
				}

			}
	
		}

	}

	// echo "<pre>$query_mov</pre>";

	return $movimientos;
}

/**
* Comparativo entre plantilla y movimeintos
*/
function comparativo($comparativo, $movimientos){

	$array_nuevos = [];

	foreach ($movimientos as $key_mov => $mov) {

		$flag_existe = 0;
		$filiacion_mov = $mov['filiacion'];
		$clave_mov = "${mov['categoria']}/${mov['num_plz']}/${mov['hrs_categoria']}";

		foreach ($comparativo as $key => $comp) {
		
			$filiacion_comp = $comp['filiacion'];
			// $hrs_categoria = ($comp['hrs_categoria'] < 10) ? '0'.$comp['hrs_categoria'] : $comp['hrs_categoria'];
			$clave_comp = "${comp['categoria']}/${comp['num_plz']}/${comp['hrs_categoria']}";

			
			if ($filiacion_comp == $filiacion_mov AND $clave_comp == $clave_mov) {
				$flag_existe = 1;
				$comparativo[$key]['existe_en_movimientos'] = 1;
			}

		}
		
	
		// Agrego el que no se encuentre en plantilla
		if ($flag_existe == 0)
			$array_nuevos[] = $mov;

	}

	$comparativo = array_merge($comparativo, $array_nuevos);
	$comparativo = reordena_arreglo($comparativo, 'filiacion', SORT_ASC);

	return $comparativo;
}


/**
* Agrupo por tipo de "movimiento" de las plazas
*/
function agrupo_por_tipo($comparativo){

	$altas = $bajas = $iguales = $jornada = [];

	foreach ($comparativo as $key => $comp) {
		
		if (strpos($comp['categoria'] , 'EH') !== false)
			$jornada[] = $comp;
		else{
			if ($comp['existe_en_plantilla'] == $comp['existe_en_movimientos'])
				$iguales[] = $comp;
			else{
				if ($comp['existe_en_plantilla'])
					$bajas[] = $comp;
				else
					$altas[] = $comp;
			}
		}

		

	}

	return array($altas, $bajas, $iguales, $jornada);

}


function EvaluaClaveEhNsubpr($row, $index, $todos_subprogramas, $data_general, $data_categoria){

	// ver si tiene jornada distribuida base
	if ($row['jornada_distribuida_base'] !== null) {
		$jornada_distribuida_base = [];
		$jornadas = json_decode($row['jornada_distribuida_base']);

		foreach ($jornadas as $key => $jornada) {

			$partes = explode('-', $jornada);
			$partes_clave = explode('/',$partes[0]);

			$jornada_distribuida_base[] = array(
				"categoria" => $partes_clave[0],
				"num_plz" => $partes_clave[1],
				"hrs_categoria" => $partes_clave[2],
				"id_subprograma" => $partes[1],
			);

		}
	}

	for ($i=0; $i < 3 ; $i++):?>

		<?php $num_hrs = ($jornada_distribuida_base[$i])? $jornada_distribuida_base[$i]['hrs_categoria'] : 0; ?>
		<?php $checked = ($jornada_distribuida_base[$i])? 'checked' : ''; ?>
		<div class="grid-container">
			<div class="col-1">
				<input 
					type="checkbox" 
					name="plaza"
					data-index = "<?php echo $index; ?>" 
					data-child = "<?php echo $key ?>" 
					data-type = 1
					es-jornada = 1
					data-child = "<?php echo $key ?>"
					<?php echo $checked; ?>
					data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
					data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
				/>
			</div>
			<div class="col-3">
				<input 
					type="number" 
					name="num_hrs" 
					data-index = "<?php echo $index; ?>" 
					data-child = "<?php echo $key ?>" 
					class="form-control" 
					min="0" 
					max="<?php echo $row['hrs_categoria'] ?>" 
					value="<?php echo $num_hrs; ?>"
					onchange="MPS_CompDoc_ProcesarEvaluaNumHrs(this)"
				/>
			</div>
			<div class="col-8">
				<select class="form-control full" name="adscripcion_eh_n" data-index = "<?php echo $index; ?>" data-child = "<?php echo $key ?>" >
					<option value=""> -- Adscripción --</option>
					<?php foreach ($todos_subprogramas as $key1 => $subpr):?>
						<?php $selected = ($jornada_distribuida_base[$i] AND $jornada_distribuida_base[$i]['id_subprograma'] == $subpr['id_subprograma']) ? 'selected="true"' : ''; ?>
						<option value="<?php echo $subpr['id_subprograma'] ?>" <?php echo $selected; ?>><?php echo $subpr['nombre_subprograma'] ?></option>
					<?php endforeach; ?>
				</select>	
			</div>
		</div>
	<?php endfor;	

}

function EvaluaClaveEh1subpr($row, $index, $subprogramas, $data_general, $data_categoria){
?>
	<div class="grid-container">
		<div class="col-1">
			<input 
				type="checkbox" 
				disabled="true" 
				checked="true"
				name="plaza"
				es-jornada = 1
				data-index = "<?php echo $index; ?>" 
				data-type = 1
				data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
				data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
			/>
		</div>
		<div class="col-11">
			<span id="plaza_nueva_subpr_<?php echo $index;?>" value="<?php echo $subprogramas['id_subprograma']?>"> 
				<?php echo $subprogramas['nombre_subprograma']?>
			</span>
		</div>
	</div>
<?php
}

function EvaluaClave($row, $index, $subprogramas, $data_general, $data_categoria){

	?>
	<div class="grid-container">
		<div class="col-1">
			<input 
				type="checkbox" 
				disabled="true" 
				checked="true"
				name="plaza"
				data-index = "<?php echo $index; ?>" 
				data-type = 1
				data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
				data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
			/>
		</div>
		<div class="col-11">
			<span id="plaza_nueva_subpr_<?php echo $index;?>" value="<?php echo $subprogramas['id_subprograma']?>"> 
				<?php echo $subprogramas['nombre_subprograma']?>
			</span>
		</div>
	</div>
<?php
}


/*------------------------------
*/
/**
* Distingue como se debe de tratar esa EH
*/
function EvaluaTipoEH($row, $index, $subprogramas, $todos_subprogramas, $data_general, $data_categoria){
	if (array_key_exists('jornada_distribuida_base', $row) AND $row['jornada_distribuida_base'] !== null) {
		
		$jornadas = json_decode($row['jornada_distribuida_base']);
		if (count($jornadas) > 1)
			EvaluaEhConDivision($row, $index, $subprogramas, $todos_subprogramas, $data_general, $data_categoria);
		else
			EvaluaEhSinDivision($row, $index, $subprogramas, $data_general, $data_categoria);

	}
}


/**
* Se da tratamiento a las EH que tienen su base en el plantel y 
* no tienen division de hrs en otros planteles
*/
function EvaluaEhSinDivision($row, $index, $subprogramas, $data_general, $data_categoria){

	?>
	<div class="grid-container">
		<div class="col-1">
			<input 
				type="checkbox" 
				name="plaza"
				data-index = "<?php echo $index; ?>" 
				data-child = "<?php echo $key ?>" 
				data-type = 1
				es-jornada = 1
				data-child = "<?php echo $key ?>"
				checked="true"
				disabled="true" 
				data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
				data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
			/>
		</div>
		<div class="col-3">
			<input 
				type="number" 
				name="num_hrs" 
				data-index = "<?php echo $index; ?>" 
				data-child = "<?php echo $key ?>" 
				class="form-control" 
				min="0" 
				max="<?php echo $row['hrs_categoria'] ?>" 
				value="<?php echo $num_hrs; ?>"
				onchange="MPS_CompDoc_ProcesarEvaluaNumHrs(this)"
			/>
		</div>
		<div class="col-8">
			<select class="form-control full" name="adscripcion_eh_n" data-index = "<?php echo $index; ?>" data-child = "<?php echo $key ?>" >
				<option value=""> -- Adscripción --</option>
				<?php foreach ($subprogramas as $key1 => $subpr):?>
					<?php $selected = ($row['id_subprograma'] == $subpr['id_subprograma']) ? 'selected="true"' : ''; ?>
					<option value="<?php echo $subpr['id_subprograma'] ?>" <?php echo $selected; ?>><?php echo $subpr['nombre_subprograma'] ?></option>
				<?php endforeach; ?>
			</select>	
		</div>
	</div>
	<?php
}


/**
* Se da tratamiento a las EH que tienen sus hrs dividida 
* en varios planteles
*/
function EvaluaEhConDivision($row, $index, $subprogramas, $todos_subprogramas, $data_general, $data_categoria){
	
	$jornada_distribuida_base = [];
	$jornadas = json_decode($row['jornada_distribuida_base']);

	foreach ($jornadas as $key => $jornada) {

		$partes = explode('-', $jornada);
		$partes_clave = explode('/',$partes[0]);

		$jornada_distribuida_base[] = array(
			"categoria" => $partes_clave[0],
			"num_plz" => $partes_clave[1],
			"hrs_categoria" => $partes_clave[2],
			"id_subprograma" => $partes[1],
		);

	}
	
	foreach ($subprogramas as $i => $item):?>

		<?php $num_hrs = $jornada_distribuida_base[$i]['hrs_categoria']; ?>
	
		<div class="grid-container">
			<div class="col-1">
				<input 
					type="checkbox" 
					name="plaza"
					data-index = "<?php echo $index; ?>" 
					data-child = "<?php echo $key ?>" 
					data-type = 1
					es-jornada = 1
					data-child = "<?php echo $key ?>"
					checked="true"
					data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
					data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
				/>
			</div>
			<div class="col-3">
				<input 
					type="number" 
					name="num_hrs" 
					data-index = "<?php echo $index; ?>" 
					data-child = "<?php echo $key ?>" 
					class="form-control" 
					min="0" 
					max="<?php echo $row['hrs_categoria'] ?>" 
					value="<?php echo $num_hrs; ?>"
					onchange="MPS_CompDoc_ProcesarEvaluaNumHrs(this)"
				/>
			</div>
			<div class="col-8">
				<select class="form-control full" name="adscripcion_eh_n" data-index = "<?php echo $index; ?>" data-child = "<?php echo $key ?>" >
					<option value=""> -- Adscripción --</option>
					<?php foreach ($todos_subprogramas as $key1 => $subpr):?>
						<?php $selected = ($jornada_distribuida_base[$i] AND $jornada_distribuida_base[$i]['id_subprograma'] == $subpr['id_subprograma']) ? 'selected="true"' : ''; ?>
						<option value="<?php echo $subpr['id_subprograma'] ?>" <?php echo $selected; ?>><?php echo $subpr['nombre_subprograma'] ?></option>
					<?php endforeach; ?>
				</select>	
			</div>
		</div>
	<?php endforeach;	
}

?>