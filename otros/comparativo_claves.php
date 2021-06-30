<?php  
if (!isset($_POST['id_estructura_ocupacional']) AND $_POST['id_estructura_ocupacional'] > 0 AND !isset($_POST['clave_subprograma']) AND $_POST['clave_subprograma'] > 0 ) {
	echo "<br>No se obtuvieron datos";
	exit();
}


$clave_subprograma = intval($_POST['clave_subprograma']);
$id_estructura_ocupacional = intval($_POST['id_estructura_ocupacional']);
$id_usuario = intval($_POST['id_usuario']);

require_once 'comparativo_controller.php';

// Llamado a las funciones
include("../../conexiones/seconecta.php");

$subprogramas = $ids_subprogramas = $plantilla = $movimeintos = $comparativo = $altas = $bajas = $iguales = $jornada = [];

list($desde_periodo, $hasta_periodo) = periodo_desde_hasta();
list($subprogramas, $ids_subprogramas) = subprogramas($clave_subprograma);
$todos_subprogramas = todos_subprogramas();
list($id_plaza_nomina_rh_datos, $fecha_actualizado) = id_movimiento();
$plantilla = plantilla($ids_subprogramas, $id_estructura_ocupacional);
$movimientos = movimientos(explode(',', $ids_subprogramas)[0], $desde_periodo, $hasta_periodo, $id_plaza_nomina_rh_datos, $id_estructura_ocupacional);
$comparativo = $plantilla;
$comparativo = comparativo($comparativo, $movimientos);
list($altas, $bajas, $iguales, $jornada) = agrupo_por_tipo($comparativo);

$altas = reordena_arreglo($altas, 'filiacion', SORT_ASC);
$bajas = reordena_arreglo($bajas, 'filiacion', SORT_ASC);
$iguales = reordena_arreglo($iguales, 'filiacion', SORT_ASC);
$jornada = reordena_arreglo($jornada, 'filiacion', SORT_ASC);


/*echo "<pre>";
print_r($jornada);
echo "</pre>";
*/
pg_close($link);
?>


<span id="where_run" data-where="1"></span>
<p>Los datos de los movimientos fueron <span class="bold">actualizados</span> el día <span class="bold"><?php echo $fecha_actualizado; ?></span></p>

<!-- jornada -->
<h3 class="text-archivo">Plazas de jornada</h3>
<?php if(count($jornada)>0): ?>
<table class="table-archivo bordered full">
	<thead>
		<tr>
			<th>#</th>
			<th>Filiacion</th>
			<th>Empleado</th>
			<th>Clave</th>
			<th>Adscripción</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach ($jornada as $key => $row):?>
			<?php $flag_plantilla = ($row['existe_en_plantilla'] == 1) ? 'Si' : 'No'; ?>
			<?php $flag_movimiento = ($row['existe_en_movimientos'] == 1) ? 'Si' : 'No'; ?>
			<?php $clave = "${row['categoria']}/${row['num_plz']}/${row['hrs_categoria']}";?>
			<?php  
			/*if ($row['existe_en_plantilla'] == $row['existe_en_movimientos'])
				$bg_color = 'bg-default';
			else{
				if ($row['existe_en_plantilla'])
					$bg_color = 'bg-warning-danger';
				else
					$bg_color = 'bg-edit';
			}*/
			?>
			<tr>
				<td><?php echo $key+1; ?></td>
				<td><?php echo $row['filiacion']; ?></td>
				<td><?php echo $row['nombre_completo']; ?></td>
				<td><?php echo $clave; ?></td>
				<td> 
					<?php 
						$data_categoria = array(
							"id_cat_categoria_padre" => $row['id_cat_categoria_padre'], 
							"categoria_padre" => $row['categoria'] , 
							"num_plz" => $row['num_plz'], 
							"hrs_categoria" => $row['hrs_categoria']
						);	
						
						$data_general = array(
							"id_empleado" => $row['id_empleado'], 
							"id_subprograma" => null, 
							"id_cat_tipo_movimiento_personal" => 2, 
							"filiacion" => $row['filiacion'], 
							"nombre_completo" => $row['nombre_completo'], 
							"id_usuario" => $id_usuario 
						);

						EvaluaTipoEH($row, $index, $subprogramas, $todos_subprogramas, $data_general, $data_categoria);
						// EvaluaClaveEhNsubpr($row, $key, $todos_subprogramas, $data_general, $data_categoria);	
					?>
				</td>
			</tr>
		<?php endforeach; ?>
	</tbody>
</table>
<?php else: echo "<p class='text-defualt'>No hay nuevas plazas</p>"; endif;  ?>


<!-- altas -->
<h3 class="text-edit">Nuevas plazas</h3>
<?php if(count($altas)>0): ?>
<table class="table-edit bordered full">
	<thead>
		<tr>
			<th>#</th>
			<th>Filiacion</th>
			<th>Empleado</th>
			<th>Clave</th>
			<th>Adscripción</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach ($altas as $key => $row):?>
			<?php $flag_plantilla = ($row['existe_en_plantilla'] == 1) ? 'Si' : 'No'; ?>
			<?php $flag_movimiento = ($row['existe_en_movimientos'] == 1) ? 'Si' : 'No'; ?>
			<?php  
				$clave = "${row['categoria']}/${row['num_plz']}/${row['hrs_categoria']}";
			?>
			<tr>
				<td><?php echo $key+1; ?></td>
				<td><?php echo $row['filiacion']; ?></td>
				<td><?php echo $row['nombre_completo']; ?></td>
				<td><?php echo $clave; ?></td>
				<td> 
					<?php 
						$data_categoria = array(
							"id_cat_categoria_padre" => $row['id_cat_categoria_padre'], 
							"categoria_padre" => $row['categoria'] , 
							"num_plz" => $row['num_plz'], 
							"hrs_categoria" => $row['hrs_categoria']
						);	
						
						$data_general = array(
							"id_empleado" => $row['id_empleado'], 
							"id_subprograma" => null, 
							"id_cat_tipo_movimiento_personal" => 2, 
							"filiacion" => $row['filiacion'], 
							"nombre_completo" => $row['nombre_completo'], 
							"id_usuario" => $id_usuario 
						);	
						
						EvaluaClave($row, $key, $subprogramas[0], $data_general, $data_categoria);

					/*if (strpos($row['categoria'] , 'EH') !== false):
						
						if (count($subprogramas)>1):
							EvaluaClaveEhNsubpr($row, $key, $subprogramas, $data_general, $data_categoria);
						else: 
							EvaluaClaveEh1subpr($row, $key, $subprogramas[0], $data_general, $data_categoria);
						endif;	

					else:	
					endif; */
					?>
				</td>
			</tr>
		<?php endforeach; ?>
	</tbody>
</table>
<?php else: echo "<p class='text-defualt'>No hay nuevas plazas</p>"; endif;  ?>

<!-- bajas -->
<h3 class="text-warning-danger">Plazas que ya no estan activas</h3>
<?php if(count($bajas)>0): ?>
<table class="table-warning-danger bordered full">
	<thead>
		<tr>
			<th>#</th>
			<th>Filiacion</th>
			<th>Empleado</th>
			<th>Clave</th>
			<th>Ascripción</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach ($bajas as $key => $row):?>
			<?php $flag_plantilla = ($row['existe_en_plantilla'] == 1) ? 'Si' : 'No'; ?>
			<?php $flag_movimiento = ($row['existe_en_movimientos'] == 1) ? 'Si' : 'No'; ?>
			<?php  
				$clave = "${row['categoria']}/${row['num_plz']}/${row['hrs_categoria']}";
			?>
			<tr>
				<td><?php echo $key+1; ?></td>
				<td><?php echo $row['filiacion']; ?></td>
				<td><?php echo $row['nombre_completo']; ?></td>
				<td><?php echo $clave; ?></td>
				<td> 
					<span>-</span>
				</td>
			</tr>
		<?php endforeach; ?>
	</tbody>
</table>
<?php else: echo "<p class='text-defualt'>No hay baja de plazas</p>"; endif;  ?>

<!-- sin cambios -->
<h3 class="text-defualt">Sin cambios</h3>
<table class="table-def bordered full mb-1em">
	<thead>
		<tr>
			<th>#</th>
			<th>Filiacion</th>
			<th>Empleado</th>
			<th>Clave</th>
			<th>Adscripción</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach ($iguales as $key => $row):?>
			<?php $flag_plantilla = ($row['existe_en_plantilla'] == 1) ? 'Si' : 'No'; ?>
			<?php $flag_movimiento = ($row['existe_en_movimientos'] == 1) ? 'Si' : 'No'; ?>
			<?php  
				$clave = "${row['categoria']}/${row['num_plz']}/${row['hrs_categoria']}";
			?>
			<tr>
				<td><?php echo $key+1; ?></td>
				<td><?php echo $row['filiacion']; ?></td>
				<td><?php echo $row['nombre_completo']; ?></td>
				<td><?php echo $clave; ?></td>
				<td> 
					<?php $data_categoria = array("id_cat_categoria_padre" => $row['id_cat_categoria_padre'], "categoria_padre" => $row['categoria'] , "num_plz" => $row['num_plz'], "hrs_categoria" => $row['hrs_categoria']); ?>	
					<?php $data_general = array("id_empleado" => $row['id_empleado'], "id_subprograma" => null, "id_cat_tipo_movimiento_personal" => 2, "filiacion" => $row['filiacion'], "nombre_completo" => $row['nombre_completo']); ?>	

					<input 
						type="checkbox" 
						disabled="true" 
						checked="true"
						name="plaza"
						data-index = "<?php echo $key; ?>" 
						data-type = 2
						data-general = "<?php echo htmlentities(json_encode($data_general)) ?>"
						data-categoria = "<?php echo htmlentities(json_encode($data_categoria)) ?>"
					/>
					<span id="plaza_sincambio_subpr_<?php echo $key;?>" value="<?php echo $row['id_subprograma'] ?>"> 
						<?php echo $row['nombre_subprograma'] ?>
					</span>
					
				</td>
			</tr>
		<?php endforeach; ?>
	</tbody>
</table>

<button type="button" class="button--azul-obscuro margin-top" onclick="MPS_CompDoc_ProcesarEvaluaGeneral()">Procesar claves</button>

