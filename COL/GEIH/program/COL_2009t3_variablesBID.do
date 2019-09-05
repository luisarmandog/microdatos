* (Versi�n Stata 13)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: \\Sdssrv03\surveys
 * Se tiene acceso al servidor �nicamente al interior del BID.
 * El servidor contiene las bases de datos MECOVI.
 *________________________________________________________________________________________________________________*
 

global ruta = "\\Sdssrv03\surveys"

local PAIS COL
local ENCUESTA GEIH
local ANO "2009"
local ronda t3 
local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                        
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: Colombia
Encuesta: GEIH
Round: t3
Autores: Yanira Oviedo, Yessenia Loayza (desloay@hotmail.com)
Generaci�n nuevas variables LMK: Andres Felipe Sanchez, Laura Oliveri, Yessenia Loayza
Modificaci�n 2014: Mayra S�enz - Email: mayras@iadb.org - saenzmayra.a@gmail.com
�ltima versi�n: Yessenia Loayza - Email: desloay@hotmail.com | yessenial@iadb.org
Fecha �ltima modificaci�n: noviembre 2013

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************/

use `base_in', clear

***************
***region_c ***
***************
*YL: generacion "region_c" para proyecto maps America.
	
gen region_c=real(I_DPTO)
label define region_c       /// 
	5  "Antioquia"	        ///
	8  "Atl�ntico"	        ///
	11 "Bogot�, D.C"	    ///
	13 "Bol�var" 	        ///
	15 "Boyac�"	            ///
	17 "Caldas"	            ///
	18 "Caquet�"	        ///
	19 "Cauca"	            ///
	20 "Ces�r"	            ///
	23 "C�rdoba"	        ///
	25 "Cundinamarca"       ///
	27 "Choc�"	            ///
	41 "Huila"	            ///
	44 "La Guajira"	        ///
	47 "Magdalena"	        ///
	50 "Meta"	            ///
	52 "Nari�o"	            ///
	54 "Norte de Santander"	///
	63 "Quind�o"	        ///
	66 "Risaralda"	        ///
	68 "Santander"	        ///
	70 "Sucre"	            ///
	73 "Tolima"	            ///
	76 "Valle"	
label value region_c region_c
label var region_c "division politico-administrativa, departamento"


************
* Region_BID *
************
gen region_BID_c=.
replace region_BID_c=3 
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c


***************
***factor_ch***
***************
*NOTA: este factor fue dividido entre 3 tal como lo se�ala la instrucci�n del DANE al unir 3 meses.
*Esto se hizo en el �ltimo do file para MECOVI
gen factor_ch=FEX_C
label variable factor_ch "Factor de expansion del hogar"


***************
****idh_ch*****
***************

sort  DIRECTORIO SECUENCIA_P
egen idh_ch = group(DIRECTORIO SECUENCIA_P)
label variable idh_ch "ID del hogar"


*************
****idp_ci****
**************

gen idp_ci=ORDEN
label variable idp_ci "ID de la persona en el hogar"

**********
***zona***
**********
gen CLASE_ORIG=CLASE
destring CLASE, replace

gen byte zona_c=0 if CLASE==2
replace zona_c=1 if CLASE==1

label variable zona_c "Zona del pais"
label define zona_c 1 "Urbana" 0 "Rural"
label value zona_c zona_c


************
****pais****
************

gen str3 pais_c="COL"
label variable pais_c "Pais"

**********
***anio***
**********
gen anio_c=2009
label variable anio_c "Anio de la encuesta"
gen mes_c=real(substr(LLAVE_P, 9,2))
destring mes_c, replace
***************
***factor_ci***
***************
*NOTA: este factor fue dividido entre 3 tal como lo se�ala la instrucci�n del DANE al unir 3 meses.
*Esto se hizo en el �ltimo do file para MECOVI

gen factor_ci=FEX_C
label variable factor_ci "Factor de expansion del individuo"


		****************************
		***VARIABLES DEMOGRAFICAS***
		****************************

*****************
***relacion_ci***
*****************

gen relacion_ci=1 if P6050==1
replace relacion_ci=2 if P6050==2
replace relacion_ci=3 if P6050==3
replace relacion_ci=4 if P6050==4 | P6050==5
replace relacion_ci=5 if P6050==7 | P6050==8 | P6050==9
replace relacion_ci=6 if P6050==6

label variable relacion_ci "Relacion con el jefe del hogar"
label define relacion_ci 1 "Jefe/a" 2 "Esposo/a" 3 "Hijo/a" 4 "Otros parientes" 5 "Otros no parientes"
label define relacion_ci 6 "Empleado/a domestico/a", add
label value relacion_ci relacion_ci

**********
***sexo***
**********

gen sexo_ci=P6020
label var sexo_ci "Sexo del individuo" 
label define sexo_ci 1 "Hombre" 2 "Mujer"
label value sexo_ci sexo_ci

**********
***edad***
**********
gen edad_ci=P6040
label variable edad_ci "Edad del individuo"

*************************
*** VARIABLES DE RAZA ***
*************************

* MGR Oct. 2015: modificaciones realizadas en base a metodolog�a enviada por SCL/GDI Maria Olga Pe�a

gen raza_idioma_ci = . 
gen id_ind_ci = .
gen id_afro_ci = .
gen raza_ci=.
label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 
notes raza_ci: En el cuestionario no consta una pregunta relacionada con raza.

*****************
***civil_ci***
*****************

gen civil_ci=.
replace civil_ci=1 if P6070==6
replace civil_ci=2 if P6070==1 | P6070==2 | P6070==3
replace civil_ci=3 if P6070==4 
replace civil_ci=4 if P6070==5

label variable civil_ci "Estado civil"
label define civil_ci 1 "Soltero" 2 "Union formal o informal"
label define civil_ci 3 "Divorciado o separado" 4 "Viudo" , add
label value civil_ci civil_ci

**************
***jefe_ci***
*************

gen jefe_ci=(relacion_ci==1)
label variable jefe_ci "Jefe de hogar"

******************
***nconyuges_ch***
******************

by idh_ch, sort: egen nconyuges_ch=sum(relacion_ci==2)
label variable nconyuges_ch "Numero de conyuges"

***************
***nhijos_ch***
***************

by idh_ch, sort: egen nhijos_ch=sum(relacion_ci==3)
label variable nhijos_ch "Numero de hijos"

******************
***notropari_ch***
******************

by idh_ch, sort: egen notropari_ch=sum(relacion_ci==4)
label variable notropari_ch "Numero de otros familiares"

********************
***notronopari_ch***
********************

by idh_ch, sort: egen notronopari_ch=sum(relacion_ci==5)
label variable notronopari_ch "Numero de no familiares"

****************
***nempdom_ch***
****************

by idh_ch, sort: egen nempdom_ch=sum(relacion_ci==6)
label variable nempdom_ch "Numero de empleados domesticos"

*****************
***clasehog_ch***
*****************

gen byte clasehog_ch=0
**** unipersonal
replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0
**** nuclear   (child with or without spouse but without other relatives)
replace clasehog_ch=2 if (nhijos_ch>0| nconyuges_ch>0) & (notropari_ch==0 & notronopari_ch==0)
**** ampliado
replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0
**** compuesto  (some relatives plus non relative)
replace clasehog_ch=4 if ((nconyuges_ch>0 | nhijos_ch>0 | notropari_ch>0) & (notronopari_ch>0))
**** corresidente
replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0

label variable clasehog_ch "Tipo de hogar"
label define clasehog_ch 1 " Unipersonal" 2 "Nuclear" 3 "Ampliado" 
label define clasehog_ch 4 "Compuesto" 5 " Corresidente", add
label value clasehog_ch clasehog_ch

******************
***nmiembros_ch***
******************

by idh_ch, sort: egen nmiembros_ch=sum(relacion_ci>=1 & relacion_ci<=4)
label variable nmiembros_ch "Numero de familiares en el hogar"

*****************
***nmayor21_ch***
*****************
bys idh_ch: egen nmayor21_ch = sum((relacion_ci >= 1 & relacion_ci <= 4) & edad_ci >= 21 & edad_ci!=.)
label variable nmayor21_ch "Numero de familiares mayores a 21 anios"

*****************
***nmenor21_ch***
*****************
bys idh_ch: egen nmenor21_ch = sum((relacion_ci> = 1 & relacion_ci< = 4) & edad_ci < 21)
label variable nmenor21_ch "Numero de familiares menores a 21 anios"

*****************
***nmayor65_ch***
*****************
bys idh_ch: egen nmayor65_ch = sum((relacion_ci >= 1 & relacion_ci <= 4) & edad_ci >= 65 & edad_ci!=.)
label variable nmayor65_ch "Numero de familiares mayores a 65 anios"

****************
***nmenor6_ch***
****************

by idh_ch, sort: egen nmenor6_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<6)
label variable nmenor6_ch "Numero de familiares menores a 6 anios"

****************
***nmenor1_ch***
****************

by idh_ch, sort: egen nmenor1_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<1)
label variable nmenor1_ch "Numero de familiares menores a 1 anio"

****************
***miembros_ci***
****************
*gen miembros_ci=(relacion_ci<6)
* 2014,01 modificacion segun doc metodologico
gen miembros_ci=(relacion_ci<5)
label variable miembros_ci "Miembro del hogar"



		************************************
		*** VARIABLES DEL MERCADO LABORAL***
		************************************

****************
****condocup_ci*
****************

gen condocup_ci=.
replace condocup_ci=1 if OCI==1
replace condocup_ci=2 if DSI==1
replace condocup_ci=3 if INI==1
replace condocup_ci=4 if edad_ci<10
label var condocup_ci "Condicion de ocupaci�n de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de PET" 
label value condocup_ci condocup_ci


/************************************************************************************************************
* 3. Creaci�n de nuevas variables de SS and LMK a incorporar en Armonizadas
************************************************************************************************************/
*********
*lp_ci***
*********
gen lp_ci =.
replace lp_ci= 202200 if CLASE==1 /*cabecera*/
replace lp_ci= 120790 if CLASE==2  /*resto*/
label var lp_ci "Linea de pobreza oficial del pais"

*********
*lpe_ci***
*********

gen lpe_ci =.
replace lpe_ci= 86748 if CLASE==1 /*cabecera*/
replace lpe_ci= 71263 if CLASE==2  /*resto*/
label var lpe_ci "Linea de indigencia oficial del pais"


*************
**salmm_ci***
*************
gen salmm_ci=16563.3333333333*30
label var salmm_ci "Salario minimo legal"

****************
*afiliado_ci****
****************
gen afiliado_ci=(P6090==1) /*afiliacion para todas las personas*/
replace afiliado_ci=. if P6090==.
label var afiliado_ci "Afiliado a la Seguridad Social"

****************
*cotizando_ci***
****************
gen cotizando_ci=.
replace cotizando_ci=1 if P6920==1
replace cotizando_ci=0 if P6920==2 | (condocup_ci==2 & P6920!=1)
label var cotizando_ci "1 Cotizante a la Seguridad Social"

********************
*** instcot_ci *****
********************
gen instcot_ci=P6930
label var instcot_ci "instituci�n a la cual cotiza"
label define instcot_ci 1 "Fondo privado" 2 "ISS, Cajanal" 3 "Reg�menes especiales (FFMM, Ecopetrol etc)" 4 "Fondo Subsidiado (Prosperar,etc.)" 
label value instcot_ci instpen_ci


****************
*instpen_ci*****
****************
gen instpen_ci=.
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 
label define instpen_ci 1 "Fondo privado" 2 "ISS, Cajanal" 3 "Reg�menes especiales (FFMM, Ecopetrol etc)" 4 "Fondo Subsidiado (Prosperar,etc.)" 
label value instpen_ci instpen_ci

*****************
*tipocontrato_ci*
*****************
gen tipocontrato_ci=.
replace tipocontrato_ci=1 if P6460==1 & condocup_ci==1
replace tipocontrato_ci=2 if P6460==2 & condocup_ci==1
replace tipocontrato_ci=3 if P6450==1 & condocup_ci==1
replace tipocontrato_ci=3 if P6440==2 & condocup_ci==1
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci

*************
*cesante_ci* 
*************
gen cesante_ci=1 if P7310==2
replace cesante_ci=0 if P7310==1
label var cesante_ci "Desocupado - definicion oficial del pais"	

*************
*tamemp_ci***
*************
gen tamemp_ci=.
replace tamemp_ci=1 if P6870>=1 & P6870<=3
replace tamemp_ci=2 if P6870>=4 & P6870<=7
replace tamemp_ci=3 if P6870>=8 & P6870<=9
label var tamemp_ci "# empleados en la empresa"

*************
**pension_ci*
*************
* MGD 11/30/2015: No se toman en cuenta los missings en el ingreso
replace P7500S2A1= . if P7500S2A1==9999999999 | P7500S2A1==9999 | P7500S2A1==99999 | P7500S2A1==98
gen pension_ci=1 if P7500S2A1>0 & P7500S2A1!=.
recode pension_ci .=0
label var pension_ci "1=Recibe pension contributiva"

****************
*tipopen_ci*****
****************
gen tipopen_ci=.
label var tipopen_ci "Tipo de pension - variable original de cada pais" 

*************
*ypen_ci*
*************
gen ypen_ci=P7500S2A1 if P7500S2A1>0 & P7500S2A1!=.
replace ypen_ci= . if P7500S2A1==9999999999 | P7500S2A1==98
replace ypen_ci=. if pension_ci==0
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************
gen pensionsub_ci=.
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**ypensub_ci*
*****************
gen ypensub_ci=.
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

*************
*tecnica_ci**
*************
gen tecnica_ci=(P6220==3 )
label var tecnica_ci "1=formacion terciaria tecnica"

****************
*categoinac_ci**
***************
gen categoinac_ci=. 
* Modificacion MLO 2015,abr (la p7450 pregunta a desocupados)
replace categoinac_ci=2 if P6240==3 & condocup_ci==3
replace categoinac_ci=3 if P6240==4 & condocup_ci==3
recode categoinac_ci . =4 if condocup_ci==3

/*
replace categoinac_ci=1 if P7450==5
replace categoinac_ci=2 if P7450==2
replace categoinac_ci=3 if P7450==3
replace categoinac_ci=4 if P7450==1 |  P7450==4 | (P7450>=6 & P7450<=9) | P7450==0*/
label var categoinac_ci "Condici�n de inactividad"
label define categoinac_ci 1 "jubilado/pensionado" 2 "estudiante" 3 "quehaceres_domesticos" 4 "otros_inactivos"
label value categoinac_ci categoinac_ci

************
***emp_ci***
************
gen emp_ci=(condocup_ci==1)

****************
***desemp_ci***
****************
gen desemp_ci=(condocup_ci==2)

*************
***pea_ci***
*************
gen pea_ci=(emp_ci==1 | desemp_ci==1)

*************
***formal_ci***
*************
gen formal_ci=(cotizando_ci==1)

*****************
***desalent_ci***
*****************
gen desalent_ci=(P6310==5)
replace desalent_ci=. if P6310==.
label var desalent_ci "Trabajadores desalentados"


***************
***subemp_ci***
***************
gen promhora= P6800 if emp_ci==1 
*P6800: horas semanales trabajadas normalmente*
gen promhora1= P7045 
*P7045: horas semanales trabajo secundario*

egen tothoras=rowtotal(promhora promhora1), m
replace tothoras=. if promhora==. & promhora1==. 
replace tothoras=. if tothoras>=168

gen subemp_ci=0
replace subemp_ci=1 if tothoras<=30  & emp_ci==1 & P7090==1
label var subemp_ci "Personas en subempleo por horas"

*****************
***horaspri_ci***
*****************
gen horaspri_ci=P6800 
replace horaspri_ci=. if emp_ci==0
label var horaspri_ci "Horas trabajadas semanalmente en el trabajo principal"

*****************
***horastot_ci***
*****************
gen horastot_ci=tothoras  if emp_ci==1 
label var horastot_ci "Horas trabajadas semanalmente en todos los empleos"


*******************
***tiempoparc_ci***
*******************
gen tiempoparc_ci=(horastot_ci<30 & P7090==2)
replace tiempoparc_ci=. if emp_ci==0
label var tiempoparc_c "Personas que trabajan medio tiempo" 

******************
***categopri_ci***
******************
gen categopri_ci=.
replace categopri_ci=1 if P6430==5
replace categopri_ci=2 if P6430==4 
replace categopri_ci=3 if P6430==1 | P6430==2 |P6430==3 
replace categopri_ci=4 if P6430==6 | P6430==7
replace categopri_ci=0 if P6430==8 | P6430==9
replace categopri_ci=. if emp_ci==0

label define categopri_ci 1"Patron" 2"Cuenta propia" 0"Otro"
label define categopri_ci 3"Empleado" 4" No remunerado" , add
label value categopri_ci categopri_ci
label variable categopri_ci "Categoria ocupacional"


******************
***categosec_ci***
******************
gen categosec_ci=.
replace categosec_ci=1 if P7050==5
replace categosec_ci=2 if P7050==4 
replace categosec_ci=3 if P7050==1 | P7050==2 |P7050==3 
replace categosec_ci=4 if P7050==6 | P7050==7
replace categosec_ci=0 if P7050==8 | P7050==9
replace categosec_ci=. if emp_ci==0

label define categosec_ci 1"Patron" 2"Cuenta propia" 0"Otro" 
label define categosec_ci 3"Empleado" 4"No remunerado" , add
label value categosec_ci categosec_ci
label variable categosec_ci "Categoria ocupacional trabajo secundario"

*****************
***nempleos_ci***
*****************
gen nempleos_ci=.
replace nempleos_ci=1 if emp_ci==1 & P7040==2
replace nempleos_ci=2 if emp_ci==1 & P7040==1
replace nempleos_ci=. if emp_ci==0
label var nempleos_ci "N�mero de empleos" 
/*
*****************
***firmapeq_ci***
*****************

gen firmapeq_ci=.
replace firmapeq_ci=1 if P6870==1 | P6870==2 |P6870==3
replace firmapeq_ci=0 if P6870>=4 & P6870!=.
replace firmapeq_ci=. if emp_ci==0
label var firmapeq_ci "Trabajadores informales"
*/
*****************
***spublico_ci***
*****************

gen spublico_ci=(P6430==2| P7050==2 ) 
replace spublico_ci=. if emp_ci==0 
label var spublico_ci "Personas que trabajan en el sector p�blico"


**************
***ocupa_ci***
**************
destring OFICIO, replace
gen ocupa_ci=.
replace ocupa_ci=1 if (OFICIO>=1 & OFICIO<=19) & emp_ci==1  
replace ocupa_ci=2 if (OFICIO>=20 & OFICIO<=21) & emp_ci==1
replace ocupa_ci=3 if (OFICIO>=30 & OFICIO<=39) & emp_ci==1
replace ocupa_ci=4 if (OFICIO>=40 & OFICIO<=49) & emp_ci==1
replace ocupa_ci=5 if (OFICIO>=50 & OFICIO<=59) & emp_ci==1
replace ocupa_ci=6 if (OFICIO>=60 & OFICIO<=64) & emp_ci==1
replace ocupa_ci=7 if (OFICIO>=70 & OFICIO<=98) & emp_ci==1
replace ocupa_ci=9 if (OFICIO==0 | OFICIO==99) & emp_ci==1
replace ocupa_ci=. if emp_ci==0

label define ocupa_ci 1"profesional y tecnico" 2"director o funcionario sup" 3"administrativo y nivel intermedio"
label define ocupa_ci  4 "comerciantes y vendedores" 5 "en servicios" 6 "trabajadores agricolas", add
label define ocupa_ci  7 "obreros no agricolas, conductores de maq y ss de transporte", add
label define ocupa_ci  8 "FFAA" 9 "Otras ", add
label value ocupa_ci ocupa_ci

label variable ocupa_ci "Ocupacion laboral"


*************
***rama_ci***
*************

gen str RAMA2D_ORIG=RAMA2D
destring RAMA2D, replace

gen rama_ci=.
replace rama_ci=1 if (RAMA2D>=1 & RAMA2D<=5) & emp_ci==1   
replace rama_ci=2 if (RAMA2D>=10 & RAMA2D<=14) & emp_ci==1
replace rama_ci=3 if (RAMA2D>=15 & RAMA2D<=37) & emp_ci==1
replace rama_ci=4 if (RAMA2D>=40 & RAMA2D<=41) & emp_ci==1
replace rama_ci=5 if (RAMA2D==45) & emp_ci==1
replace rama_ci=6 if (RAMA2D>=50 & RAMA2D<=55) & emp_ci==1
replace rama_ci=7 if (RAMA2D>=60 & RAMA2D<=64) & emp_ci==1
replace rama_ci=8 if (RAMA2D>=65 & RAMA2D<=71) & emp_ci==1
replace rama_ci=9 if (RAMA2D>=72 & RAMA2D<=99) & emp_ci==1
replace rama_ci=. if emp_ci==0

label var rama_ci "Rama de actividad"
label def rama_ci 1"Agricultura, caza, silvicultura y pesca" 2"Explotaci�n de minas y canteras" 3"Industrias manufactureras"
label def rama_ci 4"Electricidad, gas y agua" 5"Construcci�n" 6"Comercio, restaurantes y hoteles" 7"Transporte y almacenamiento", add
label def rama_ci 8"Establecimientos financieros, seguros e inmuebles" 9"Servicios sociales y comunales", add
label val rama_ci rama_ci


****************
***durades_ci***
****************

gen durades_ci= P7250/4.3
* replace durades_ci=62 if P7250==998
replace durades_ci=. if P7250==999 | P7250==998
label variable durades_ci "Duracion del desempleo en meses"
 
*******************
***antiguedad_ci***
*******************

gen antiguedad_ci= P6426/12 
replace antiguedad_ci=. if emp_ci==0 | P6426==999
label var antiguedad_ci "Antiguedad en la actividad actual en anios"




			**************
			***INGRESOS***
			**************
/*
		
foreach var in P6500 P6510S1 P6600S1 P6590S1 P6610S1 P6620S1  P6585S1A1 P6585S2A1 P6585S3A1 P6585S4A1 P6580S1 { 
replace `var'=. if `var'<=999 & `var'!=0
}

foreach var in P6630S1A1 P6630S2A1 P6630S3A1 P6630S4A1 P6630S6A1 {
replace `var'=. if `var'<=999 & `var'!=0
}

foreach var in P6750 P550 P7070 P7500S1A1 P7500S2A1 P7500S3A1 {
replace `var'=. if `var'<=999 & `var'!=0
}

foreach var in P7510S1A1 P7510S2A1 P7510S3A1 P7510S5A1 P7510S6A1 {
replace `var'=. if `var'<=999 & `var'!=0
}

gen ymensual 	= P6500
gen yhorasext 	= P6510S1
gen yvivienda 	= P6600S1
gen yalimen 	= P6590S1
gen ytrans 		= P6610S1
gen yespecie 	= P6620S1 
gen ysubsi1		= P6585S1A1
gen ysubsi2		= P6585S2A1
gen ysubsi3		= P6585S3A1
gen ysubsi4		= P6585S4A1
gen yprimas		= P6545S1
gen yprimboni	= P6580S1

gen yprimser	= P6630S1A1
gen yprimnav 	= P6630S2A1
gen yprimvac	= P6630S3A1
gen yprimvia	= P6630S4A1
gen yprimbono	= P6630S6A1

recode P6760 (0=0.5)
replace P6760=. if P6760>=98
gen ynetoind 	= P6750/P6760
gen ycosecha 	= P550/12
gen ysecund		= P7070
gen yarrien		= P7500S1A1
gen ypension	= P7500S2A1
gen yjubila		= P7500S3A1

gen yayudafam	= P7510S1A1/12

gen yayudainst	= P7510S3A1/12
gen yintereses	= P7510S5A1/12
gen ycesantia	= P7510S6A1/12

*/

gen yremesas	= P7510S2A1/12
	
***************
***ylmpri_ci***
***************
	egen 	ylmpri_ci = rsum(impa impaes)
	replace ylmpri_ci = . if impa==. & impaes==.
	la var 	ylmpri_ci "Ingreso laboral monetario actividad principal" 

*****************
***nrylmpri_ci***
*****************
	g nrylmpri_ci = (ylmpri_ci == . & emp_ci == 1)
	la var nrylmpri_ci "ID no respuesta ingreso de la actividad principal"  

****************
***ylnmpri_ci***
****************
	egen ylnmpri_ci = rsum(ie iees)
	replace ylnmpri_ci=. if ie==. & iees==.
	/*YL -> Nota: "ie" and "iees"corresponden al ingreso por especie de la act principal*/
	la var ylnmpri_ci "Ingreso laboral NO monetario actividad principal"   

***************
***ylmsec_ci***
***************
	egen ylmsec_ci = rsum(isa isaes)
	replace ylmsec_ci=. if isa==. & isaes==.
	la var ylmsec_ci "Ingreso laboral monetario segunda actividad" 

****************
***ylnmsec_ci***
****************
	g ylnmsec_ci = . /*No se pregunta ingreso por especies para act secundaria */
	la var ylnmsec_ci "Ingreso laboral NO monetario actividad secundaria"

*****************
***ylmotros_ci***
*****************
	egen ylmotros_ci= rowtotal(imdi imdies), m
	la var ylmotros_ci "Ingreso laboral monetario de otros trabajos" 

******************
***ylnmotros_ci***
******************
	g ylnmotros_ci = .
	la var ylnmotros_ci "Ingreso laboral NO monetario de otros trabajos" 

************
***ylm_ci***
************
	egen ylm_ci = rowtotal(ylmpri_ci ylmsec_ci ylmotros_ci), m
	*YL -> Incremento el ingreso laboral de inactivos & desocupados
	la var ylm_ci "Ingreso laboral monetario total"  

*************
***ylnm_ci***
*************
	egen ylnm_ci = rowtotal(ylnmpri_ci ylnmsec_ci ylnmotros_ci), m
	la var ylnm_ci "Ingreso laboral NO monetario total"  

*************
***ynlm_ci***
*************
	egen ynlm_ci = rowtotal(iof1 iof2 iof3 iof6 iof1es iof2es iof3es iof6es), m
	la var ynlm_ci "Ingreso no laboral monetario"  

**************
***ylnm_ci***
**************
	g ynlnm_ci = .
	la var ynlnm_ci "Ingreso no laboral no monetario" 
	
************************
*** HOUSEHOLD INCOME ***
************************

*******************
*** nrylmpri_ch ***
*******************

*Creating a Flag label for those households where someone has a ylmpri_ci as missing

by idh_ch, sort: egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1
replace nrylmpri_ch=1 if nrylmpri_ch>0 & nrylmpri_ch<.
replace nrylmpri_ch=. if nrylmpri_ch==.
label var nrylmpri_ch "Hogares con alg�n miembro que no respondi� por ingresos"


**************
*** ylm_ch ***
**************

by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1
label var ylm_ch "Ingreso laboral monetario del hogar"

***************
*** ylnm_ch ***
***************

by idh_ch, sort: egen ylnm_ch=sum(ylnm_ci) if miembros_ci==1
label var ylnm_ch "Ingreso laboral no monetario del hogar"

****************
*** ylmnr_ch ***
****************

by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1
replace ylmnr_ch=. if nrylmpri_ch==1
label var ylmnr_ch "Ingreso laboral monetario del hogar"

***************
*** ynlm_ch ***
***************

by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1
label var ynlm_ch "Ingreso no laboral monetario del hogar"


**************
***ynlnm_ch***
**************

gen ynlnm_ch=.
label var ynlnm_ch "Ingreso no laboral no monetario del hogar"


********
***NA***
********
gen rentaimp_ch=.
label var rentaimp_ch "Rentas imputadas del hogar"

gen autocons_ci=.
label var autocons_ci "Autoconsumo reportado por el individuo"

gen autocons_ch=.
label var autocons_ch "Autoconsumo reportado por el hogar"



****************
***remesas_ci***
****************

*Aqui se toma el valor mensual de las remesas

gen remesas_ci=yremesas
label var remesas_ci "Remesas mensuales reportadas por el individuo" 


****************
***remesas_ch***
****************

*Aqui se toma el valor mensual de las remesas

by idh_ch, sort: egen remesas_ch=sum(remesas_ci) if miembros_ci==1
label var remesas_ch "Remesas mensuales del hogar" 

*****************
***ylhopri_ci ***
*****************

gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.3)
label var ylmhopri_ci "Salario monetario de la actividad principal" 


***************
***ylmho_ci ***
***************

gen ylmho_ci=ylm_ci/(horastot_ci*4.3)
label var ylmho_ci "Salario monetario de todas las actividades" 



****************************
***VARIABLES DE EDUCACION***
****************************
replace P6210S1=. if P6210S1==99
replace P6210=.   if P6210==9


** Se incorporan modificaciones a sintaxis de variable aedu_ci seg�n revisi�n hecha por Iv�n Bornacelly SCL/EDU **
	
gen byte aedu_ci=.
* IB: Estaban quedando con missing aquellas personas que tienen educaci�n prescolar y est�n en el grado 1.
/*
replace aedu_ci=0 if P6210==1 & P6210S1==0 
replace aedu_ci=0 if P6210==2 & P6210S1==0 
replace aedu_ci=0 if P6210==3 & P6210S1==0 
*/
replace aedu_ci=0 if P6210==1 
replace aedu_ci=0 if P6210==2 
replace aedu_ci=0 if P6210==3 & P6210S1==0 

*Primaria
replace aedu_ci=1 if P6210==2 & P6210S1==1 
replace aedu_ci=1 if P6210==3 & P6210S1==1
replace aedu_ci=2 if P6210==3 & P6210S1==2
replace aedu_ci=3 if P6210==3 & P6210S1==3
replace aedu_ci=4 if P6210==3 & P6210S1==4
replace aedu_ci=5 if P6210==3 & P6210S1==5
replace aedu_ci=5 if P6210==4 & P6210S1==0

*Secundaria
replace aedu_ci=6 if P6210==4 & P6210S1==6
replace aedu_ci=7 if P6210==4 & P6210S1==7
replace aedu_ci=8 if P6210==4 & P6210S1==8
replace aedu_ci=9 if P6210==4 & P6210S1==9
replace aedu_ci=10 if P6210==5 & P6210S1==10
replace aedu_ci=11 if P6210==5 & P6210S1==11
replace aedu_ci=11 if P6210==6 & P6210S1==0
replace aedu_ci=12 if P6210==5 & P6210S1==12
replace aedu_ci=13 if P6210==5 & P6210S1==13

*Superior o universitaria
replace aedu_ci = 11+P6210S1 if P6210==6 
label var aedu_ci "Anios de educacion aprobados" 

**************
***eduno_ci***
**************
gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
label variable eduno_ci "Sin educacion"

**************
***edupi_ci***
**************
gen byte edupi_ci=0
replace edupi_ci=1 if (aedu_ci>=1 & aedu_ci<5) 
label variable edupi_ci "Primaria incompleta"


**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==5 
label variable edupc_ci "Primaria completa"


**************
***edusi_ci***
**************

gen byte edusi_ci=0
replace edusi_ci=1 if (aedu_ci>=6 & aedu_ci<11) 
label variable edusi_ci "Secundaria incompleta"


**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if (aedu_ci>=11 & aedu_ci<=13) & P6210==5 
label variable edusc_ci "Secundaria completa"


**************
***eduui_ci***
**************

*Para la educaci�n superior no es posible saber cuantos anios dura el ciclo
*por ello se hace una aproximaci�n a trav�s de titulaci�n
g byte eduui_ci = (aedu_ci > 11 & aedu_ci!=. & P6210 == 6 & (P6220 == 1 | P6220 == 2))
label variable eduui_ci "Superior incompleto"


***************
***eduuc_ci***
***************

*Para la educaci�n superior no es posible saber cuantos anios dura el ciclo
*por ello se hace una aproximaci�n a trav�s de titulaci�n
g byte eduuc_ci = ((aedu_ci > 11 & aedu_ci!=.) & P6210 == 6 & (P6220 == 3 | P6220 == 4 | P6220 == 5))
label variable eduuc_ci "Superior completo"


***************
***edus1i_ci***
***************
gen byte edus1i_ci=0
replace edus1i_ci=1 if (aedu_ci>=6 & aedu_ci<9)
label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************
gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9
label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************
gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci==10 
label variable edus2i_ci "2do ciclo de la secundaria incompleto"

***************
***edus2c_ci***
***************
gen byte edus2c_ci=0
replace edus2c_ci=1 if (aedu_ci>=11 & aedu_ci<=13) & P6220==2
label variable edus2c_ci "2do ciclo de la secundaria completo"

local var = "eduno edupi edupc edusi edusc edusc eduui eduuc edus1i edus1c edus2i edus2c"
foreach x of local var {
replace `x'_ci=. if aedu_ci==.
}

***************
***edupre_ci***
***************
g byte edupre_ci =(P6210S1==1 & P6210==2)
label variable edupre_ci "Educacion preescolar"

***************
***asispre_ci**
***************
*Variable creada por Iv�n Bornacelly - 01/16/2017
	g asispre_ci=.
	replace asispre_ci=1 if P6210S1==0 & P6210==2 & P6170==1
	recode asispre_ci (.=0)
	la var asispre_ci "Asiste a educaci�n prescolar"

**************
***eduac_ci***
**************
gen byte eduac_ci=.
label variable eduac_ci "Superior universitario vs superior no universitario"

***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if P6170==1
replace asiste_ci=0 if P6170==2
label variable asiste_ci "Asiste actualmente a la escuela"

**************
***pqnoasis***
**************

gen pqnoasis_ci=.
label var pqnoasis_ci "Razones para no asistir a la escuela"

**************
*pqnoasis1_ci*
**************
**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**

g       pqnoasis1_ci = .

***************
***repite_ci***
***************

gen repite_ci=.
label var repite_ci "Ha repetido al menos un grado"


******************
***repiteult_ci***
******************

gen repiteult_ci=.
label var repiteult "Ha repetido el �ltimo grado"


***************
***edupub_ci***
***************

gen edupub_ci=.
replace edupub_ci=1 if P6175==1
replace edupub_ci=0 if P6175==2
label var edupub_ci "Asiste a un centro de ense�anza p�blico"

		**********************************
		**** VARIABLES DE LA VIVIENDA ****
		**********************************


****************
***aguared_ch***
****************
gen aguared_ch=(P4030S5==1)
replace aguared_ch=. if P4030S5==.
label var aguared_ch "Acceso a fuente de agua por red"


*****************
***aguadist_ch***
*****************
gen aguadist_ch=.
label val aguadist_ch aguadist_ch


*****************
***aguamala_ch***
*****************
gen aguamala_ch=(P5050==5 | P5050==6)
replace aguamala_ch=. if P5050==.
label var aguamala_ch "Agua unimproved seg�n MDG" 


*****************
***aguamide_ch***
*****************

gen aguamide_ch=.
label var aguamide_ch "Usan medidor para pagar consumo de agua"


************
***luz_ch***
************
gen luz_ch=0
replace luz_ch=1 if P4030S1==1 
label var luz_ch  "La principal fuente de iluminaci�n es electricidad"


****************
***luzmide_ch***
****************
gen luzmide_ch=.
label var luzmide_ch "Usan medidor para pagar consumo de electricidad"


****************
***combust_ch***
****************
gen combust_ch=0
replace combust_ch=1 if  P5080==1 | P5080==3 | P5080==4
label var combust_ch "Principal combustible gas o electricidad" 


*************
***bano_ch***
*************

gen bano_ch=1
replace bano_ch=0 if P5020==6 
label var bano_ch "El hogar tiene servicio sanitario"

***************
***banoex_ch***
***************

gen banoex_ch=0
replace banoex_ch=1 if P5030==1
replace banoex_ch=. if bano_ch==0
label var banoex_ch "El servicio sanitario es exclusivo del hogar"


*************
***des1_ch***
*************

gen des1_ch=.
replace des1_ch=0 if bano_ch==0
replace des1_ch=1 if P5020==1 | P5020==2
replace des1_ch=2 if P5020==3 | P5020==4
replace des1_ch=3 if P5020==5
label var des1_ch "Tipo de desague seg�n unimproved de MDG"
label def des1_ch 0"No tiene servicio sanitario" 1"Conectado a red general o c�mara s�ptica"
label def des1_ch 2"Letrina o conectado a pozo ciego" 3"Desemboca en r�o o calle", add
label val des1_ch des1_ch


*************
***des2_ch***
*************
gen des2_ch=.
replace des2_ch=0 if bano_ch==0
replace des2_ch=1 if P5020==1 | P5020==2 | P5020==3 | P5020==4
replace des2_ch=2 if P5020==5
label var des2_ch "Tipo de desague sin incluir definici�n MDG"
label def des2_ch 0"No tiene servicio sanitario" 1"Conectado a red general, c�mara s�ptica, pozo o letrina"
label def des2_ch 2"Cualquier otro caso", add
label val des2_ch des2_ch


*************
***piso_ch***
*************
gen piso_ch=1 if P4020!=1 & P4020!=.
replace piso_ch=0 if P4020==1
replace piso_ch=. if P4020==.
label var piso_ch "Materiales de construcci�n del piso"  
label def piso_ch 0"Piso de tierra" 1"Materiales permanentes"
label val piso_ch piso_ch

**************
***pared_ch***
**************
gen pared_ch=0 if P4010==8 | P4010==9
replace pared_ch=1 if P4010>=1 & P4010<=7
replace pared_ch=. if P4010==.
label var pared_ch "Materiales de construcci�n de las paredes"
label def pared_ch 0"No permanentes" 1"Permanentes"
label val pared_ch pared_ch


**************
***techo_ch***
**************
gen techo_ch=.
label var techo_ch "Materiales de construcci�n del techo"

**************
***resid_ch***
**************
gen resid_ch =0    if P5040==1
replace resid_ch=1 if P5040==4
replace resid_ch=2 if P5040==2 | P5040==3
replace resid_ch=3 if P5040==5
replace resid_ch=. if P5040==.
label var resid_ch "M�todo de eliminaci�n de residuos"
label def resid_ch 0"Recolecci�n p�blica o privada" 1"Quemados o enterrados"
label def resid_ch 2"Tirados a un espacio abierto" 3"Otros", add
label val resid_ch resid_ch

 **Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
 *********************
 ***aguamejorada_ch***
 *********************
g       aguamejorada_ch = 1 if (P5050 >=1 & P5050 <=5) | P5050 ==7
replace aguamejorada_ch = 0 if  P5050 ==6 | (P5050 >=8 & P5050 <=10)

 *********************
 ***banomejorado_ch***
 *********************
g       banomejorado_ch = 1 if ( P5020 >=1 &  P5020 <=4) & P5030 ==1
replace banomejorado_ch = 0 if (( P5020 >=1 &  P5020 <=4) & P5030 ==2) | ( P5020 >=5 &  P5020 <=6)

*************
***dorm_ch***
*************

gen dorm_ch=P5010
label var dorm_ch "Habitaciones para dormir"


****************
***cuartos_ch***
****************

gen cuartos_ch=P5000
label var cuartos_ch "Habitaciones en el hogar"
 

***************
***cocina_ch***
***************
gen cocina_ch=0 if P5070>=2 & P5070<=6
replace cocina_ch=1 if P5070==1
replace cocina_ch=. if P5070==.
label var cocina_ch "Cuarto separado y exclusivo para cocinar"


**************
***telef_ch***
**************
gen telef_ch=0
replace telef_ch=1 if P5210S1==1
replace telef_ch=. if P5210S1==.
label var telef_ch "El hogar tiene servicio telef�nico fijo"


***************
***refrig_ch***
***************

gen refrig_ch=0
replace refrig_ch=1 if  P5210S5==1
replace refrig_ch=. if  P5210S5==.
label var refrig_ch "El hogar posee refrigerador o heladera"


**************
***freez_ch***
**************

gen freez_ch=.
label var freez_ch "El hogar posee congelador"


*************
***auto_ch***
*************

gen auto_ch=0
replace auto_ch=1 if P5210S22==1
replace auto_ch=. if P5210S22==.
label var auto_ch "El hogar posee automovil particular"


**************
***compu_ch***
**************

gen compu_ch=0
replace compu_ch=1 if P5210S16==1
replace compu_ch=. if P5210S16==.
label var compu_ch "El hogar posee computador"


*****************
***internet_ch***
*****************
gen internet_ch=P5210S3==1
replace internet_ch=. if P5210S3==.
label var internet_ch "El hogar posee conexi�n a Internet"


************
***cel_ch***
************

gen temp1=(P5220==1)
replace temp1=. if P5220==.

bysort idh_ch: egen temp2=sum(temp1)
replace temp2=. if P5220==.

gen cel_ch=0
replace cel_ch=1 if temp2>=1 & temp2!=.
replace cel_ch=. if P5220==.
label var cel_ch "El hogar tiene servicio telefonico celular"
drop temp*


**************
***vivi1_ch***
**************
gen vivi1_ch=1 if P4000==1
replace vivi1_ch=2 if P4000==2
replace vivi1_ch=3 if P4000==3 | P4000==4 | P4000==5 | P4000==6
replace vivi1_ch=. if P4000==.
label var vivi1_ch "Tipo de vivienda en la que reside el hogar"
label def vivi1_ch 1"Casa" 2"Departamento" 3"Otros"
label val vivi1_ch vivi1_ch


*************
***vivi2_ch***
*************
gen vivi2_ch=0
replace vivi2_ch=1 if P4000==1 | P4000==2
replace vivi2_ch=. if P4000==.
label var vivi2_ch "La vivienda es casa o departamento"


*****************
***viviprop_ch***
*****************
gen viviprop_ch=0 if P5090==3
replace viviprop_ch=1 if P5090==1
replace viviprop_ch=2 if P5090==2
replace viviprop_ch=3 if P5090==4 |P5090==5 |P5090==6
replace viviprop_ch=. if P5090==.
label var viviprop_ch "Propiedad de la vivienda"
label def viviprop_ch 0"Alquilada" 1"Propia y totalmente pagada" 2"Propia y en proceso de pago"
label def viviprop_ch 3"Ocupada (propia de facto)", add
label val viviprop_ch viviprop_ch



****************
***vivitit_ch***
****************
gen vivitit_ch=.
label var vivitit_ch "El hogar posee un t�tulo de propiedad"


****************
***vivialq_ch***
****************
gen vivialq_ch=P5140 if P5140>=10000
label var vivialq_ch "Alquiler mensual"


*******************
***vivialqimp_ch***
*******************
gen vivialqimp_ch=P5130 if P5130>=10000
label var vivialqimp_ch "Alquiler mensual imputado"

gen  tcylmpri_ci =.
gen tcylmpri_ch=.


/*_____________________________________________________________________________________________________*/
* Asignaci�n de etiquetas e inserci�n de variables externas: tipo de cambio, Indice de Precios al 
* Consumidor (2011=100), Paridad de Poder Adquisitivo (PPA 2011),  l�neas de pobreza
/*_____________________________________________________________________________________________________*/


do "$ruta\harmonized\_DOCS\\Labels&ExternalVars_Harmonized_DataBank.do"

/*_____________________________________________________________________________________________________*/
* Verificaci�n de que se encuentren todas las variables armonizadas 
/*_____________________________________________________________________________________________________*/

order region_BID_c region_c pais_c anio_c mes_c zona_c factor_ch	idh_ch	idp_ci	factor_ci sexo_ci edad_ci ///
raza_idioma_ci  id_ind_ci id_afro_ci raza_ci  relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch ///
clasehog_ch nmiembros_ch miembros_ci nmayor21_ch nmenor21_ch nmayor65_ch nmenor6_ch	nmenor1_ch	condocup_ci ///
categoinac_ci nempleos_ci emp_ci antiguedad_ci	desemp_ci cesante_ci durades_ci	pea_ci desalent_ci subemp_ci ///
tiempoparc_ci categopri_ci categosec_ci rama_ci spublico_ci tamemp_ci cotizando_ci instcot_ci	afiliado_ci ///
formal_ci tipocontrato_ci ocupa_ci horaspri_ci horastot_ci	pensionsub_ci pension_ci tipopen_ci instpen_ci	ylmpri_ci nrylmpri_ci ///
tcylmpri_ci ylnmpri_ci ylmsec_ci ylnmsec_ci	ylmotros_ci	ylnmotros_ci ylm_ci	ylnm_ci	ynlm_ci	ynlnm_ci ylm_ch	ylnm_ch	ylmnr_ch  ///
ynlm_ch	ynlnm_ch ylmhopri_ci ylmho_ci rentaimp_ch autocons_ci autocons_ch nrylmpri_ch tcylmpri_ch remesas_ci remesas_ch	ypen_ci	ypensub_ci ///
salmm_ci tc_c ipc_c lp19_c lp31_c lp5_c lp_ci lpe_ci aedu_ci eduno_ci edupi_ci edupc_ci	edusi_ci edusc_ci eduui_ci eduuc_ci	edus1i_ci ///
edus1c_ci edus2i_ci edus2c_ci edupre_ci eduac_ci asiste_ci pqnoasis_ci pqnoasis1_ci	repite_ci repiteult_ci edupub_ci tecnica_ci ///
aguared_ch aguadist_ch aguamala_ch aguamide_ch luz_ch luzmide_ch combust_ch	bano_ch banoex_ch des1_ch des2_ch piso_ch aguamejorada_ch banomejorado_ch  ///
pared_ch techo_ch resid_ch dorm_ch cuartos_ch cocina_ch telef_ch refrig_ch freez_ch auto_ch compu_ch internet_ch cel_ch ///
vivi1_ch vivi2_ch viviprop_ch vivitit_ch vivialq_ch	vivialqimp_ch , first



compress


saveold "`base_out'", replace


log close


