select
id_cfdi,filiacion,total_percepciones
,(select sum(CASE WHEN tipo_concepto = 'P' THEN importe + importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as percepciones
,total_deducciones
,(select sum(CASE WHEN tipo_concepto = 'D' THEN importe + importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as deducciones
,total_gravado
,(select sum(CASE WHEN tipo_concepto = 'P' THEN importe ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as gravado
,total_exento
,(select sum(CASE WHEN tipo_concepto = 'P' THEN importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as exento
,total_otros_pagos
,(select sum(CASE WHEN tipo_concepto = 'O' THEN importe + importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as otros_pagos
,total_impuestos_retenidos
,(select sum(CASE WHEN tipo_concepto = 'D' and clave = '80' THEN importe + importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as impuestos_retenidos
,total_otras_deducciones
,(select sum(CASE WHEN tipo_concepto = 'D' and clave != '80' THEN importe + importe_exento ELSE 0 END) FROM timbrado_pre_conceptos b WHERE a.id_cfdi = b.id_cfdi) as otras_deducciones
,total_liquido
FROM timbrado_pre_cfdi a
ORDER BY a.id_cfdi
