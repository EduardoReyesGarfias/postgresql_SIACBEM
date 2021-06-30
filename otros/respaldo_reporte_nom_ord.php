<?php 

if (isset($_GET['i'])) {

	$ids_nomina = $_GET['i'];

	function get_data($ids_nomina){

		$query_nomina = "
			SELECT 
			--*,
				'MICHOACAN' as entidad,
				'051' as clave_depen,
				'COLEGIO DE BACHILLERES DEL ESTADO DE MICHOACAN' as depen,
				substring(c.tipo_nomina,1,1) as tipo_nomina,
				d.rfc,
				d.curp,
				d.paterno||' '||d.materno||' '||d.nombre as nom_emp,
				'' as plaza,
				f.clave_sep,
				b.categoria,
				b.numero_hr,
				g.id_pago,
				string_agg(DISTINCT CAST(g.desde_pag as text),',') as desde_pag,
				string_agg(DISTINCT CAST(g.hasta_pag as text),',') as hasta_pag,
				string_agg(DISTINCT CAST(g.qnapago as text),',') as qnapago,
				'' as tipo_pago,
				b.num_che,
				'' as num_cta,
				'' as banco,
				COALESCE(SUM(
					CASE WHEN h.id_tipo_pd = 1 THEN
						importe
					END	
				),0) as tot_per, 
				COALESCE(SUM(
					CASE WHEN h.id_tipo_pd = 2 THEN
						importe
					END	
				),0) as tot_ded
			FROM nominas_sispagos a
			INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
			INNER JOIN cat_tipo_nomina_sispagos c ON c.id_tipo_nomina = a.id_tipo_nomina
			INNER JOIN empleados d ON d.id_empleado = b.id_empleado 
			INNER JOIN subprogramas e ON e.id_subprograma = b.id_subprograma
			INNER JOIN claves_sep f ON f.id_sep = e.id_sep
			INNER JOIN percepciones_deducciones_sispagos g ON g.id_pago = b.id_pago
			INNER JOIN cat_percepciones_deducciones_sispagos h ON h.clave = g.cod_pd
			WHERE 
				b.filiacion = 'AAAA770111000' AND 
				a.id_nomina = ANY(ARRAY[$ids_nomina])
			GROUP BY 
				c.tipo_nomina,
				d.rfc,
				d.curp,
				d.paterno,
				d.materno,
				d.nombre,
				f.clave_sep,
				b.categoria,
				b.numero_hr,
				g.id_pago,
				b.num_che
		";
		$res_nomina = pg_query($query_nomina);
		$data = pg_fetch_all($res_nomina);
		pg_free_result($res_nomina);

		// echo "<pre>$query_nomina</pre>";

		return $data;
	}

	function get_pds(){

		$query_pds = "
			SELECT 
			STRING_AGG((
			CASE WHEN id_tipo_pd = 1 THEN
				'P'||clave
			ELSE
				'D'||clave
			END
			),',' ORDER BY clave ASC) as pds	
			FROM cat_percepciones_deducciones_sispagos a
		";
		$res_pds = pg_query($query_pds);
		$data = pg_fetch_array($res_pds)[0];
		pg_free_result($res_pds);

		return $data;

	}

	// Pinta el ecabezado de cada fila
	function draw_headers( $instancia, $pds ){

		$fila = 1;
		$columna = 0;

		$instancia->getActiveSheet()
			->setCellValueByColumnAndRow($columna++, $fila, 'ENTIDAD/MUNICIPIO')
			->setCellValueByColumnAndRow($columna++, $fila, 'CLAVE_DEPEN')
			->setCellValueByColumnAndRow($columna++, $fila, 'DEPEN')
			->setCellValueByColumnAndRow($columna++, $fila, 'TIPONOMINA')
			->setCellValueByColumnAndRow($columna++, $fila, 'RFC')
			->setCellValueByColumnAndRow($columna++, $fila, 'CURP')
			->setCellValueByColumnAndRow($columna++, $fila, 'NOM_EMP')
			->setCellValueByColumnAndRow($columna++, $fila, 'PLAZA o en su caso CVE_PRESUP')
			->setCellValueByColumnAndRow($columna++, $fila, 'UNIDAD')
			->setCellValueByColumnAndRow($columna++, $fila, 'CAT_PUESTO')
			->setCellValueByColumnAndRow($columna++, $fila, 'HORAS')
			->setCellValueByColumnAndRow($columna++, $fila, 'QNA_INI')
			->setCellValueByColumnAndRow($columna++, $fila, 'QNA_FIN')
			->setCellValueByColumnAndRow($columna++, $fila, 'QNA_PROC')
			->setCellValueByColumnAndRow($columna++, $fila, 'TIPO_PAGO')
			->setCellValueByColumnAndRow($columna++, $fila, 'NUM_CHEQUE/NUM_TRANSF')
			->setCellValueByColumnAndRow($columna++, $fila, 'NUM_CTA')
			->setCellValueByColumnAndRow($columna++, $fila, 'BANCO')
			->setCellValueByColumnAndRow($columna++, $fila, 'T_PERCCHEQ')
			->setCellValueByColumnAndRow($columna++, $fila, 'T_DEDCHEQ')
			->setCellValueByColumnAndRow($columna++, $fila, 'T_NETOCHEQ');

		$partes = explode(',', $pds);	
		foreach ($partes as $key => $pd) {
			$instancia->getActiveSheet()->setCellValueByColumnAndRow($columna++, $fila, $pd);
		}	

		
	}

	// Pinto la información en el cuerpo del archivo
	function draw_data_body( $data, $instancia ){
		
		$fila_inicial = 1;

		foreach ($data as $key => $campo) {

			$columna = 0;
			$fila = $fila_inicial +1;

			$instancia->getActiveSheet()
				->setCellValueByColumnAndRow($columna++, $fila, $campo['entidad'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['clave_depen'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['depen'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['tipo_nomina'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['rfc'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['curp'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['nom_emp'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['plaza'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['clave_sep'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['categoria'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['numero_hr'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['desde_pag'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['hasta_pag'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['qnapago'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['tipo_pago'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['num_che'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['num_cta'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['banco'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['tot_per'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['tot_ded'])
				->setCellValueByColumnAndRow($columna++, $fila, $campo['tot_per'] - $campo['tot_ded']);
			$fila_inicial = $fila;
		}
		
		// return $instancia;	

	}


	// Con a la BD
	include("../../conexiones/seconecta.php");
	// Se importa la libreria
	require_once('../../../librerias/PHPExcel/Classes/PHPExcel.php');

	// Se crea una instancia a la clase PHPExcel
	$instancia = new PHPExcel();

	// Cabeceras del documento
	$instancia->getProperties()
	        ->setCreator("SIACBEM")
	        ->setLastModifiedBy("SIACBEM")
	        ->setTitle("Reporte de nominas ordinarias")
	        ->setSubject("Reporte de nominas ordinarias")
	        ->setDescription("Reporte de nominas ordinarias")
	        ->setKeywords("nómina, ordinarias, auditoria")
	        ->setCategory("Auditoria");

	// Página 1
	$instancia->setActiveSheetIndex(0);
	$instancia->getActiveSheet()->setTitle('Nom_Ord'); 

	$data = get_data($ids_nomina);
	$pds = get_pds();
	pg_close($link);

	// pinto Cabeceras
	draw_headers( $instancia, $pds );
	// Pinto datos en el cuerpo del archivo
	draw_data_body( $data, $instancia );

	$hoy = date("d-m-Y H : i");
	$anio = date('Y')-1;
	$nombre_reporte = "Reporte nom ord $anio $hoy";

// exit();
	header('Content-Type: application/vnd.ms-excel;charset=utf-8');
	header('Content-Disposition: attachment;filename="'.$nombre_reporte.'.xls"');
	header('Cache-Control: max-age=0');
		
	$objWriter = PHPExcel_IOFactory::createWriter($instancia, 'Excel5');
	$objWriter->save('php://output');
} 
?>