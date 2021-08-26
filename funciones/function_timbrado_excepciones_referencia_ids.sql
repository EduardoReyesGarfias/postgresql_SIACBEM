CREATE OR REPLACE FUNCTION timbrado_excepciones_referencia_ids(_id_cfdi_cancelado integer, _id_cfdi_nuevo integer)
RETURNS boolean AS
$BODY$
DECLARE

	status_update boolean;
    --id_conceptos_cancelados INTEGER[] DEFAULT  ARRAY[]::INTEGER[]; -- empty array-constructors need a cast
    reg_cancelado RECORD;
	cur_cancelado CURSOR FOR (

        SELECT id_conceptos, clave_plaza, id_pago, tipo_concepto, lpad(tipo, 3, '0') as tipo, lpad(clave, 3, '0') as clave
        FROM timbrado_conceptos_2021
        WHERE id_cfdi = _id_cfdi_cancelado
        ORDER BY id_conceptos, clave_plaza, id_pago, tipo_concepto, tipo, clave

    );

    reg_nuevo RECORD;
	cur_nuevo CURSOR FOR (

        SELECT id_conceptos, clave_plaza, id_pago, tipo_concepto, lpad(tipo, 3, '0') as tipo, lpad(clave, 3, '0') as clave
        FROM timbrado_conceptos_2021
        WHERE id_cfdi = _id_cfdi_nuevo
        ORDER BY id_conceptos, clave_plaza, id_pago, tipo_concepto, tipo, clave

    );

BEGIN
    
    status_update:= false;

    /***** CFDI *****/

    -- cancelo el cfdi del pago 
    UPDATE timbrado_cfdi_2021
    SET cancelado = true
    WHERE id_cfdi = _id_cfdi_cancelado;

    -- Referencio id cfdi nuevo con el cancelado
    UPDATE timbrado_cfdi_2021
    SET id_cfdi_original = _id_cfdi_cancelado
    WHERE id_cfdi = _id_cfdi_nuevo;


    /***** Conceptos *****/

    -- cancelo los conceptos del pago anterior
    UPDATE timbrado_conceptos_2021
    SET cancelado = true
    WHERE id_cfdi = _id_cfdi_cancelado;

    -- Guardo los ids de los conceptos en un array
    FOR reg_cancelado IN cur_cancelado LOOP

        FOR reg_nuevo IN cur_nuevo LOOP

            IF (
                reg_cancelado.clave_plaza = reg_nuevo.clave_plaza AND 
                reg_cancelado.id_pago = reg_nuevo.id_pago AND
                reg_cancelado.tipo = reg_nuevo.tipo AND
                reg_cancelado.clave = reg_nuevo.clave AND
                reg_cancelado.tipo_concepto = reg_nuevo.tipo_concepto
                ) THEN
                
                status_update:= true;
                
                UPDATE timbrado_conceptos_2021
                SET id_conceptos_original = reg_cancelado.id_conceptos
                WHERE id_cfdi = _id_cfdi_nuevo
                AND id_conceptos = reg_nuevo.id_conceptos;

            END IF;            

        END LOOP;    

    END LOOP;

    RETURN status_update;
END
$BODY$
LANGUAGE 'plpgsql';