CREATE OR REPLACE FUNCTION timbrado_subsidio_causado_division( _qna int)
RETURNS BOOLEAN
AS $$
DECLARE

    flag boolean;

    reg_subsidio RECORD;

	cur_subsidio CURSOR FOR 
        SELECT 
        emp.id_empleado,
        emp.filiacion,
        nom.consecu,
        nom.qnapago,
        sub.subsidio_causado
        FROM timbrado_subsidio_causado_empleados_nueva sub
        INNER JOIN empleados emp ON emp.id_empleado = sub.id_empleado
        INNER JOIN nominas_sispagos nom ON nom.id_nomina = sub.id_nomina
        WHERE 
            nom.qnapago = _qna
            --AND emp.id_empleado = 9102
        ORDER BY emp.filiacion;

    reg_nominas RECORD;     

    total_subsidio_causado numeric(12,2); 
    subsi_cau numeric(12,2);   

BEGIN

    flag:= false;
    subsi_cau:= 0;
    total_subsidio_causado:= 0;

    -- Recorro cada persona que tiene subsidio causado (subido desde la nómina y guardado por Roger)
    FOR reg_subsidio IN cur_subsidio LOOP

        total_subsidio_causado:= reg_subsidio.subsidio_causado;

        -- Busco las nominas en las que se le pago para ir dividiendo el total del subsidio en cada nomina pagada
        FOR reg_nominas IN (
                                SELECT 
                                    nom.id_nomina,
                                    CAST(consecu as int),
                                    id_tipo_nomina, 
                                    sum(
                                        CASE WHEN cod_pd = '42' THEN importe ELSE 0 END
                                    ) as importe_42
                                FROM nominas_sispagos nom
                                INNER JOIN pagos_sispagos pagos ON pagos.id_nomina = nom.id_nomina
                                INNER JOIN percepciones_deducciones_sispagos pds ON pds.id_pago = pagos.id_pago
                                WHERE
                                    pagos.id_empleado = reg_subsidio.id_empleado
                                    AND nom.qnapago = _qna
                                GROUP BY 
                                    nom.id_nomina,
                                    nom.consecu,
                                    id_tipo_nomina
                                ORDER BY 
                                    id_tipo_nomina DESC
                            )  LOOP

            -- Si se le pago codigo 42 le agrego subsidio, de lo contrario no es necesario
            IF (reg_nominas.id_tipo_nomina != 1) THEN
                IF( reg_nominas.importe_42 > 0 AND total_subsidio_causado > reg_nominas.importe_42) THEN

                    flag:= true;
                    subsi_cau:= reg_nominas.importe_42;
                    total_subsidio_causado:= total_subsidio_causado - subsi_cau;

                    INSERT INTO timbrado_subsidio_causado_empleados(filiacion, qna_pago, consecu, subsidio_causado)
                    VALUES(reg_subsidio.filiacion, reg_subsidio.qnapago, reg_nominas.consecu, subsi_cau);

                END IF;
            ELSE
                   flag:= true;
                    subsi_cau:= reg_nominas.importe_42;
                    total_subsidio_causado:= total_subsidio_causado - subsi_cau;

                    INSERT INTO timbrado_subsidio_causado_empleados(filiacion, qna_pago, consecu, subsidio_causado)
                    VALUES(reg_subsidio.filiacion, reg_subsidio.qnapago, reg_nominas.consecu, subsi_cau);  
            END IF;

        END LOOP;

        -- Al ultimo registro insertado le doy el resto del subsidio
        UPDATE timbrado_subsidio_causado_empleados
        SET subsidio_causado = (total_subsidio_causado + subsi_cau)
        WHERE id_timbrado_subsidio_causado_empleado = 
        (SELECT
            id_timbrado_subsidio_causado_empleado
        FROM timbrado_subsidio_causado_empleados subsidio
        INNER JOIN empleados emp ON emp.filiacion = subsidio.filiacion
        WHERE qna_pago = _qna
        AND emp.filiacion = reg_subsidio.filiacion
        ORDER BY emp.filiacion, id_timbrado_subsidio_causado_empleado DESC
        LIMIT 1
        );


    END LOOP;

    return flag;

END; $$ 
LANGUAGE 'plpgsql';