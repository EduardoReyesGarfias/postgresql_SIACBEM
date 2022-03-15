<?php  

$ids_nomina = implode(',',  $_POST['nomina']);
$array_excedente = array();

/*
$array_excedente[] = array( "categoria" => 'T05004', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'T05004', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'T05004', "qnapago" => 202021 );

$array_excedente[] = array( "categoria" => 'T06027', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'T06027', "qnapago" => 202006 );

$array_excedente[] = array( "categoria" => 'A2404', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A2404', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A2404', "qnapago" => 202003 );

$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202024 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202025 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202026 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202027 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202028 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202029 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 2020210 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 2020215 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A2405', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 2020019 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'CF12027', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'CF22811', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'CF22811', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'CF22811', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'CF22811', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'E3103', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A01001', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 2020010 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'CF34015', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08005', "qnapago" => 202015 );

$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'EH4627', "qnapago" => 202017 );

$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'EH4727', "qnapago" => 202017 );

$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'EH4827', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'EH4629', "qnapago" => 202007 );

$array_excedente[] = array( "categoria" => 'T06018', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'T06018', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'T06018', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'T06018', "qnapago" => 202004 );

$array_excedente[] = array( "categoria" => 'CF21850', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'CF21850', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'CF21850', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202024 );
$array_excedente[] = array( "categoria" => 'A08002', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202005 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202020 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202024 );
$array_excedente[] = array( "categoria" => 'A2403', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202001 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202002 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202003 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202004 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202007 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202008 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202011 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202013 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202014 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202015 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202016 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202017 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202018 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202019 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202021 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202022 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202023 );
$array_excedente[] = array( "categoria" => 'A08004', "qnapago" => 202024 );

$array_excedente[] = array( "categoria" => 'CF33116', "qnapago" => 202006 );

$array_excedente[] = array( "categoria" => 'S14003', "qnapago" => 202006 );
$array_excedente[] = array( "categoria" => 'S14003', "qnapago" => 202009 );
$array_excedente[] = array( "categoria" => 'S14003', "qnapago" => 202010 );
$array_excedente[] = array( "categoria" => 'S14003', "qnapago" => 202012 );
$array_excedente[] = array( "categoria" => 'S14003', "qnapago" => 202013 );*/

// echo "<pre>";
// print_r($array_excedente);
// echo "</pre>";
// exit();

// obtengo lista de los pds
function get_pds(){

	$query_pds = "
		SELECT 
			(CASE WHEN id_tipo_pd = 1 THEN
				'P'||clave
			ELSE
				'D'||clave
			END
			) as pds	
		FROM cat_percepciones_deducciones_sispagos a
		ORDER BY clave ASC
	";
	$res_pds = pg_query($query_pds);
	$data = pg_fetch_all($res_pds);
	pg_free_result($res_pds);

	return $data;

}


// obtengo la data del body
function get_data($ids_nomina){

	$query_nomina = "
		SELECT 
			(
				CASE WHEN c.tipo_nomina != 'Ordinaria' THEN 'C'
				ELSE 'O'
				END		
			)as tipo_nomina,
			d.rfc,
			d.curp,
			d.paterno||' '||d.materno||' '||d.nombre as nom_emp,
			d.id_empleado,
			-- f.clave_sep,
			(
				CASE WHEN CAST(e.clave_extension_u_organica as int) > 600 AND CAST(e.clave_extension_u_organica as int) < 700  THEN
					(
					SELECT 
						sep.clave_sep||'|'||sub.nombre_subprograma
					FROM plazas_nomina_rh_recibe plz
					INNER JOIN subprogramas sub on (
								substr( plz.subprograma, 2 ) = sub.clave_extension_u_organica 
								or (substr( plz.subprograma, 2 ) = sub.clave_subprograma and sub.clave_extension_u_organica = '0')
					)
					INNER JOIN claves_sep sep ON sub.id_sep = sep.id_sep 
					WHERE plz.id_plaza_nomina_rh_datos = (
						SELECT
							id_plaza_nomina_rh_datos id_datos
						FROM plazas_nominas_rh_datos
						ORDER BY id_plaza_nomina_rh_datos DESC
						LIMIT 1
					)
					AND filiacion = d.filiacion
					AND CAST(g.qnapago as text) BETWEEN desde_plz AND hasta_plz
					AND sub.id_subprograma != 197
					ORDER BY desde_plz DESC
					LIMIT 1)
		
				ELSE
					f.clave_sep||'|'||e.nombre_subprograma
				END		
			) as clave_sep,
			b.categoria,
			/*(
				CASE 
					WHEN nueva_categoria is not null AND b.categoria = 'CF01005' THEN nueva_categoria
					WHEN b.categoria = 'CBV' THEN 'CBIV'
				ELSE b.categoria
				END		
			) as categoria,*/
			b.numero_hr,
			g.id_pago,
			string_agg(DISTINCT CAST(g.desde_pag as text),',') as desde_pag,
			string_agg(DISTINCT CAST(g.hasta_pag as text),',') as hasta_pag,
			string_agg(DISTINCT CAST(g.qnapago as text),',') as qnapago,
			(
				CASE WHEN i.id_tipo_pago = 1 OR i.id_tipo_pago = 2 THEN
					'EL'
				ELSE
					'CH'
				END	
			) as tipo_pago,
			b.num_che,
			(
				CASE WHEN i.id_tipo_pago = 1 OR i.id_tipo_pago = 3 OR i.id_tipo_pago = 4 THEN
					j.bcaserfin
				ELSE
					j.ctahsbc
				END	
			) as num_cta,
			string_agg(DISTINCT CAST(g.qnapago as text),',') as qnapago,
			(
				CASE WHEN i.id_tipo_pago = 1 OR i.id_tipo_pago = 3 OR i.id_tipo_pago = 4 THEN
					'SANTANDER'
				ELSE
					'HSBC'
				END	
			) as banco,
			COALESCE(SUM(
				CASE WHEN h.id_tipo_pd = 1 THEN
					importe
				END	
			),0) as tot_per, 
			COALESCE(SUM(
				CASE WHEN h.id_tipo_pd = 2 THEN
					importe
				END	
			),0) as tot_ded,
			poliza.num_poliza,
			a.consecu,
			b.clave_tipo_nombramiento,
			cat_nomb.descripcion,
			/*STRING_AGG(
				(
				-- Si es categoria CBV y codigo 60 y es nomina ordinaria
				CASE 
					WHEN b.categoria = 'CBV' AND g.cod_pd = '60' AND a.id_tipo_nomina = 1 THEN
					(
						SELECT g.cod_pd||'**'||(tab_recibe.importe_mensual_60 * b.numero_hr)
						FROM tabulador_recibe_2019 tab_recibe
						WHERE
							(
								CASE 
									WHEN g.qnapago <= 202001 THEN
										tab_recibe.id_tabulador_datos = 11
									WHEN g.qnapago between 202002 AND 202024 THEN
										tab_recibe.id_tabulador_datos = 12
								END		

							)
						AND tab_recibe.id_zona_economica = e.id_zona_economica	
						AND tab_recibe.id_cat_categoria_padre = 16
					)
					ELSE	
						g.cod_pd||'**'||g.importe
				END			
			), ',' ORDER BY g.cod_pd ASC
			) as codigos,*/
			STRING_AGG(
				g.cod_pd||'**'||g.importe
				, ',' ORDER BY g.cod_pd ASC
			) as codigos,
			a.id_tipo_nomina,
			b.categoria as categoria_original,
			STRING_AGG((
				CASE  WHEN cod_pd = '60' THEN CAST(importe as text) END
			),',') as cod_60,
			d.filiacion,
			zona_eco.zona_economica,
			catego.nivel_interno
		FROM nominas_sispagos a
		INNER JOIN pagos_sispagos b ON a.id_nomina = b.id_nomina
		LEFT JOIN cat_categorias_padre catego ON catego.categoria_padre = b.categoria 
		INNER JOIN cat_tipo_nomina_sispagos c ON c.id_tipo_nomina = a.id_tipo_nomina
		INNER JOIN empleados d ON d.id_empleado = b.id_empleado 
		INNER JOIN subprogramas e ON e.id_subprograma = b.id_subprograma
		INNER JOIN cat_zonas_economicas zona_eco ON zona_eco.id_zona_economica = e.id_zona_economica
		INNER JOIN claves_sep f ON f.id_sep = e.id_sep
		INNER JOIN percepciones_deducciones_sispagos g ON g.id_pago = b.id_pago
		INNER JOIN cat_percepciones_deducciones_sispagos h ON h.clave = g.cod_pd
		INNER JOIN cat_tipo_pago_sispagos i ON i.id_tipo_pago = b.id_tipo_pago
		INNER JOIN cat_tipo_nombramiento cat_nomb ON cat_nomb.clave_tipo_nombramiento = CAST(b.clave_tipo_nombramiento as int)
		LEFT JOIN nominas_sispagos_num_poliza poliza ON poliza.consecutivo = CAST(a.consecu AS INT)
		LEFT JOIN empleados_sispagos_envia j ON j.filiacion = b.filiacion
		LEFT JOIN cat_puestos_cambio_auditoria cat_audi ON cat_audi.id_empleado = d.id_empleado
		WHERE 
			-- b.filiacion = 'JUTS880226000' AND
			a.id_nomina = ANY(ARRAY[$ids_nomina])
			--a.id_nomina = ANY(ARRAY[999,976,1002,977,973,949,957,958,953,961,968,972,986,987,984,979,994,1003,992,991,989,981,990,970,995,1006,1015,1009,1004,1011,964,971,982,1010,1013,997,1000,998,985,978])
			--AND a.id_tipo_nomina != 2
		GROUP BY 
			c.tipo_nomina,
			d.rfc,
			d.curp,
			d.paterno,
			d.materno,
			d.nombre,
			d.id_empleado,
			f.clave_sep,
			b.categoria,
			b.numero_hr,
			b.categoria,
			b.numero_plz,
			g.id_pago,
			b.num_che,
			i.id_tipo_pago,
			b.filiacion,
			j.bcaserfin,
			j.ctahsbc,
			poliza.num_poliza,
			a.consecu,
			b.clave_tipo_nombramiento,
			cat_nomb.descripcion,
			g.qnapago,
			d.filiacion,
			e.nombre_subprograma,
			zona_eco.zona_economica,
			e.clave_extension_u_organica,
			cat_audi.nueva_categoria,
			a.id_tipo_nomina,
			catego.nivel_interno
		ORDER BY b.filiacion
	";
	$res_nomina = pg_query($query_nomina);

	$data = [];
	$conceptos = [];
	while ($row = pg_fetch_array($res_nomina)) {

		$data[] = $row;
		unset($data[count($data)-1][22]);
		$conceptos[] = $row['codigos'];

	}
	pg_free_result($res_nomina);

	// echo "<pre>$query_nomina</pre>";

	return array( $data, $conceptos );
}


/*

*/
function cambia_categoria( $categoria, $array_excedente, $qnapago, $id_tipo_nomina ){

	// 09/06/2021 se quito para otra auditoria
	/*$encontrado = undefined;

	if (intval($id_tipo_nomina) == 1) {
		
		if (count($array_excedente)>0) {
			
			foreach ($array_excedente as $key => $row) {
				
				// echo "<br>Comparacion: ".trim($row['categoria'])." == ".trim($categoria)." AND ".intval($row['qnapago'])." == ".intval($qnapago);

				if (trim($row['categoria']) == trim($categoria) AND intval($row['qnapago']) == intval($qnapago)) {
					$encontrado = $key;
					$categoria = trim($categoria)."E";
				}

			}

			if ($encontrado !== undefined) {
				unset($array_excedente[$encontrado]);
				$array_excedente = array_values($array_excedente);
			}

		}	
	
	}*/

	return array( $categoria, $array_excedente );

}

/*
Para ciertas filiacions cambiar el subprograma ya que sigue 
apareciendo el de su comision y no el de su base
*/
/*function comision_a_base( $filiacion, $nombre_subprograma, $clave_sep ){

	if ($filiacion == 'CACL701010000' AND trim($nombre_subprograma) == 'Personal de apoyo docente y administrativo al área de Planeación') {
		$clave_sep = '16ECB0083R';
		$nombre_subprograma = 'Plantel Morelia';
	}elseif ($filiacion == 'TOPE600412000' AND trim($nombre_subprograma) == 'Comisión Mixta de Capacitación') {
		$clave_sep = '16ECB0068Y';
		$nombre_subprograma = 'Centro de Educación Mixta Patzcuaro';
	}elseif ($filiacion == 'CARL700108000' AND trim($nombre_subprograma) == 'Personal de apoyo docente y administrativo al área de Planeación') {
		$clave_sep = '16ACD0001T';
		$nombre_subprograma = 'Departamento de Organización y Métodos';
	}elseif ($filiacion == 'MANM610301000' AND trim($nombre_subprograma) == 'Comisión Mixta de Capacitación') {
		$clave_sep = '16ACD0001T';
		$nombre_subprograma = 'Departamento de Proyectos';
	}elseif ($filiacion == 'TAMG680512000' AND trim($nombre_subprograma) == 'Comisión de Seguridad e Higiene') {
		$clave_sep = '16ECB0026Z';
		$nombre_subprograma = 'Plantel Santa Clara del Cobre';
	}

	return array($clave_sep, $nombre_subprograma);

}*/

// Pinta los headers del archivo
function draw_headers( $file, $pds ){

	$cellHeader = [
	    'ENTIDAD/MUNICIPI',
	    'CLAVE_DEPEN',
	    'DEPEN',
	    'TIPONOMINA',
	    'RFC',
	    'CURP',
	    'NOM_EMP',
	    'PLAZA o en su caso CVE_PRESUP',
	    'UNIDAD',
	    'CAT_PUESTO',
	    'HORAS',
	    'QNA_INI',
	    'QNA_FIN',
	    'QNA_PROC',
	    'TIPO_PAGO',
	    'NUM_CHEQUE/NUM_TRANSF',
	    'NUM_CTA',
	    'BANCO',
	    'T_PERCCHEQ',
	    'T_DEDCHEQ',
	    'T_NETOCHEQ'
	];

	foreach ($pds as $key => $pd) {
		$cellHeader[] = $pd['pds'];
	}

	$cellHeader[] = 'NUM_POL';
	$cellHeader[] = 'CONSECU';
	$cellHeader[] = 'CLAVE TIPO NOMBRAMIENTO';
	$cellHeader[] = 'DESC TIPO NOMBRAMIENTO';
	$cellHeader[] = 'NOMBRE SUBPROGRAMA';
	$cellHeader[] = 'ID EMPLEADO';
	$cellHeader[] = 'ZONA ECONOMICA';
	$cellHeader[] = 'NIVEL PLZ';

	fputcsv($file, $cellHeader);
	return $file;
}


// pinta el body
function draw_body( $file, $data, $conceptos, $array_excedente ){

	$posiciones = array();
	$cellBody = array();

	for ($i=0; $i < 119; $i++) { 
		$posiciones[$i] = 0.00;
	}

	foreach ($data as $key => $row) {

		$codigos = $conceptos[$key];
		list($clave_sep, $nombre_subprograma) = explode('|', $row['clave_sep']);

		// list($clave_sep, $nombre_subprograma) = comision_a_base( $row['filiacion'] , $nombre_subprograma, $clave_sep );
		list($categoria, $array_excedente) = cambia_categoria( $row['categoria'], $array_excedente, $row['qnapago'], trim($row['id_tipo_nomina']) );
		
		$cellBody = $posiciones;
		$cellBody[0] = 'MICHOACAN';
		$cellBody[1] = '051';
		$cellBody[2] = 'COLEGIO DE BACHILLERES DEL ESTADO DE MICHOACAN';
		$cellBody[3] = $row['tipo_nomina'];
		$cellBody[4] = $row['rfc'];
		$cellBody[5] = $row['curp'];
		$cellBody[6] = $row['nom_emp'];
		$cellBody[7] = '';
		$cellBody[8] = $clave_sep;
		$cellBody[9] = $categoria;
		$cellBody[10] = $row['numero_hr'];
		$cellBody[11] = $row['desde_pag'];
		$cellBody[12] = $row['hasta_pag'];
		$cellBody[13] = $row['qnapago'];
		$cellBody[14] = $row['tipo_pago'];
		$cellBody[15] = $row['num_che'];
		$cellBody[16] = $row['num_cta'];
		$cellBody[17] = $row['banco'];
		$cellBody[18] = $row['tot_per']*1;
		$cellBody[19] = $row['tot_ded']*1;
		$cellBody[20] = $row['tot_per'] - $row['tot_ded'];

		// empezar a pintar codigos
		$parCodigo = explode(',', $codigos);

	/*	echo "<pre>";
		print_r($parCodigo);
		echo "</pre>";*/

		$columna = 20;

		$nuevo_60 = 0;
		$nuevo_06 = 0;

		foreach ($parCodigo as $key => $cod_pd) {
			
			list($cod, $importe) = explode('**', $cod_pd);
			$indice = (intval($cod) > 38) ? intval($columna-1) + intval($cod) : intval($columna) + intval($cod);

			/*echo "<br>indicie: ".$indice;
			echo "<br>Cod: ".$cod;
			echo "<br>importe: ".$importe;*/
			// nuevo_60 para los CBV
			if (trim($row['categoria_original']) == 'CBV' AND trim($cod) == 60 AND intval($row['id_tipo_nomina']) == 1 ) {
				
				$nuevo_60 = $importe / 2;
				$nuevo_06 = $row['cod_60'] - $nuevo_60;
				$importe = $nuevo_60;

				$cellBody[26] = $nuevo_06;
			}
			
			// $cellBody[$indice] = $importe*1;
			$cellBody[$indice]+= $importe;
		}

		$cellBody[120] = $row['num_poliza'];
		$cellBody[121] = $row['consecu'];
		$cellBody[122] = $row['clave_tipo_nombramiento'];
		$cellBody[123] = $row['descripcion'];
		$cellBody[124] = $nombre_subprograma;
		$cellBody[125] = $row['id_empleado'];
		$cellBody[126] = $row['zona_economica'];
		$cellBody[127] = $row['nivel_interno'];

		fputcsv($file, $cellBody);

	}

	return $file;
}


include("../../conexiones/seconecta_gbautista.php");

list($data_body, $data_codigos) = get_data( $ids_nomina );
$pds = get_pds();
pg_close($link);

$hoy = date("d-m-Y H:i");
$anio = date('Y')-1;
$fileName = "Reporte_nom_ord_$anio_$hoy.csv";
header('Content-Disposition: attachment; charset=utf-8; filename="'.$fileName.'";');
$file = fopen('php://output', 'w');
fputs($file, $bom =( chr(0xEF) . chr(0xBB) . chr(0xBF) )); //add BOM to fix UTF-8 in Excel
$file = draw_headers( $file, $pds );
$file = draw_body( $file, $data_body, $data_codigos, $array_excedente );
fclose($file);
?>