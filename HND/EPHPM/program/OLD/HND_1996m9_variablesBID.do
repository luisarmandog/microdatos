* (Versión Stata 12)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: ${surveysFolder}
 * Se tiene acceso al servidor únicamente al interior del BID.
 * El servidor contiene las bases de datos MECOVI.
 *________________________________________________________________________________________________________________*
 


*global ruta = "${surveysFolder}"

local PAIS HND
local ENCUESTA EPHPM
local ANO "1996"
local ronda m9

local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_orig\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
   
capture log close
log using "`log_file'", replace 

log off
/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
País: Honduras
Encuesta: EPHPM
Round: m9
Autores: Revised March, 2008 (by tede) 
Última versión: María Laura Oliveri (MLO) - Email: mloliveri@iadb.org, lauraoliveri@yahoo.com
Fecha última modificación: 9 de Septiembre de 2013

							SCL/LMK - IADB
****************************************************************************/
/***************************************************************************
Detalle de procesamientos o modificaciones anteriores:
 opened on:  16 Aug 2006, 12:39:18
 Modificación marzo 2013: Andres Felipe Sanchez
Email: andressa@iadb.org, anfesanz@gmail.com

 Modificación 4 de Octubre de 2013: Mayra Sáenz
Email: mayras@iadb.org, saenzmayra.a@gmail.com


*******************************************************************************************************
******                                    HONDURAS 1996                                              **
******            EPHPM 1996 (Encuesta Permenente de Hogares de Propositos Multiples                 **
******                                    6.428 hogares                                              **
******                                   33.172 personas                                             **
*******************************************************************************************************
****************************************************************************/

clear all
set more off
use "`base_in'", clear
/*foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }
*/
		**********************************
		***VARIABLES DEL IDENTIFICACION***
		**********************************
		
	****************
	* region_BID_c *
	****************
	
gen region_BID_c=1

label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

************
* Region_c *
************
*Inclusión Mayra Sáenz - Julio 2013

gen region_c=  depto
label define region_c 1 "Atlántida" 2 "Colón" 3 "Comayagua" ///
4 "Copán" 5 "Cortés" 6 "Choluteca" 7 "El Paraíso" 8 "Francisco de Morazán" ///
10 "Intibuca" 12 "La Paz" 13 "Lempira" 14 "Ocotepeque" 15 "Olancho" 16 "Santa Bárbara" ///
17 "Valle" 18 "Yoro"
label var region_c "División política"


***************
***factor_ch***
***************
gen factor_ch=FACTOREX

***************
****idh_ch*****
*************** 
egen idh_ch=group(DOMINIO SEGMENTO VIVIENDA HOGAR)

*************
****idp_ci****
**************
gen idp_ci=ORDENPER
label var idp_ci "Identificador Individual dentro del Hogar"
           
**********
***zona***
**********
gen zona_c=1 if DOMINIO==1 | DOMINIO==2 | DOMINIO==3 | DOMINIO==4
replace zona_c=0 if DOMINIO==5
label define zona_c 0 "Rural" 1 "Urbana" 
label value zona_c zona_c

**********
***raza***
**********
gen raza_ci= .
label define raza_ci 1 "Indígena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 

************
****pais****
************
gen pais_c="HND"

**********
***anio***
**********
gen anio_c=1996

*********
***mes***
*********
gen mes_c=9
label define mes_c 3 "Marzo" 5 "Mayo" 9 "Septiembre"
label value mes_c mes_c


*****************
***relacion_ci***
*****************
gen relacion_ci=.
replace relacion_ci=1 if PARENTCO==1
replace relacion_ci=2 if PARENTCO==2
replace relacion_ci=3 if PARENTCO==3 
replace relacion_ci=4 if PARENTCO==4 | PARENTCO==5 | PARENTCO==6
replace relacion_ci=5 if PARENTCO==7
replace relacion_ci=6 if PARENTCO==8
label var relacion_ci "Relacion con el Jefe de Hogar"
label define relacion 1 "Jefe de Hogar" 2 "Conyuge" 3 "Hijos" 4 "Otros Parientes" 5 "Otros no Parientes" 6 "Servicio Domestico"
label value relacion relacion

	****************************
	***VARIABLES DEMOGRAFICAS***
	****************************

***************
***factor_ci***
***************
gen factor_ci=factor_ch

**********
***sexo***
**********
gen sexo_ci=SEXO
label var sexo "Sexo del Individuo"
label define sexo_ci 1 "Masculino" 2 "Femenino"
label value sexo_ci sexo_ci

**********
***edad***
**********
gen edad_ci=EDAD if EDAD<99
label var edad_ci "Edad del Individuo"

*****************
***civil_ci***
*****************
gen civil_ci=.
replace civil_ci=1 if ESTCIVIL==5
replace civil_ci=2 if ESTCIVIL==1 | ESTCIVIL==6
replace civil_ci=3 if ESTCIVIL==3 | ESTCIVIL==4
replace civil_ci=4 if ESTCIVIL==2
label var civil_ci "Estado Civil"
label define civil_ci 1 "Soltero" 2 "Union Formal o Informal" 3 "Divorciado o Separado" 4 "Viudo"
label value civil_ci civil_ci

*************
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

by idh_ch, sort: egen nmayor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci>=21)
label variable nmayor21_ch "Numero de familiares mayores a 21 anios"

*****************
***nmenor21_ch***
*****************

by idh_ch, sort: egen nmenor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<21)
label variable nmenor21_ch "Numero de familiares menores a 21 anios"

*****************
***nmayor65_ch***
*****************

by idh_ch, sort: egen nmayor65_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci>=65)
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

gen miembros_ci=(relacion_ci<6)
label variable miembros_ci "Miembro del hogar"

************************************
*** VARIABLES DEL MERCADO LABORAL***
************************************


****************
****condocup_ci*
****************

gen miembros_ci=1 if PARENTCO>=1 & PARENTCO<=7

replace miembros_ci=0 if PARENTCO==8




gen uno=1 if miembros_ci==1

egen nmiembros_ch=sum(uno), by(idh_ch)

replace nmiembros_ch=. if miembros_ci!=1

label var nmiembros_ch "Numero de miembros del Hogar"

drop uno




gen jefe_ci=0

replace jefe_ci=1 if PARENTCO==1

label var jefe_ci "Jefe de Hogar Declarado"





egen byte nconyuges_ch=sum(PARENTCO==2), by (idh)

label variable nconyuges "Numero de Conyuges"


egen byte nhijos_ch=sum(PARENTCO==3), by (idh)

label variable nhijos_ch "Numero de Hijos menores de 18"


egen byte notropari_ch=sum(PARENTCO==4 | PARENTCO==5 | PARENTCO==6),by (idh)

label variable notropari_ch "Numero de Otros Parientes "


egen byte notronopari_ch=sum(PARENTCO==7), by(idh)

label variable notronopari_ch "Numero de Otros NO Parientes "


egen byte nempdom_ch=sum(PARENTCO==8), by(idh)

label variable nempdom_ch "Numero de Empleados Domesticos"


gen clasehog_ch=.

replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0 /* unipersonal*/

replace clasehog_ch=2 if nhijos_ch>0 & notropari_ch==0 & notronopari_ch==0 /* nuclear (child with or without spouse but without other relatives)*/
replace clasehog_ch=2 if nconyuges_ch>0 & notropari_ch==0 & notronopari_ch==0 /* nuclear (spouse with or without children but without other relatives)*/

replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0 /* ampliado*/


replace clasehog_ch=4 if (nconyuges_ch>0 | nhijos_ch>0 | (notropari_ch>0 & notropari_ch<.)) & (notronopari_ch>0 & notronopari_ch<.) /* compuesto  (some relatives plus non relative)*/

replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 & notronopari_ch<./** corresidente*/

label variable clasehog_ch "CLASE HOGAR"

label define clasehog_ch 1 "Unipersonal" 2 "Nuclear" 3 "Ampliado" 4 "Compuesto" 5 "Corresidente"

label value clasehog_ch clasehog_ch


egen nmayor21_ch=sum((PARENTCO>0 & PARENTCO<=7) & (edad>=21)), by (idh)

label variable nmayor21_ch "Numero de personas de 21 años o mas dentro del Hogar"


egen nmenor21_ch=sum((PARENTCO>0 & PARENTCO<=7) & (edad<21)), by (idh)

label variable nmenor21_ch "Numero de personas menores a 21 años dentro del Hogar"


egen nmayor65_ch=sum((PARENTCO>0 & PARENTCO<=7) & (edad>=65)), by (idh)

label variable nmayor65_ch "Numero de personas de 65 años o mas dentro del Hogar"


egen nmenor6_ch=sum((PARENTCO>0 & PARENTCO<=7) & (edad<6)), by (idh)

label variable nmenor6_ch "Numero de niños menores a 6 años dentro del Hogar"


egen nmenor1_ch=sum((PARENTCO>0 & PARENTCO<=7) & (edad<1)),  by (idh)

label variable nmenor1_ch "Numero de niños menores a 1 año dentro del Hogar"





gen asiste_ci=.

replace asiste_ci=1 if ASISTE==1

replace asiste_ci=0 if ASISTE==6

label var asiste_ci "Personas que actualmente asisten a centros de enseñanza"

drop ASISTE


gen pqnoasis_ci=.

label var pqnoasis_ci "Razones para no asistir a centros de enseñanza"


gen repiteult_ci=.

label var repiteult_ci "Personas que han repetido el ultimo grado"


gen repite_ci=.

label var repite_ci "Personas que han repetido al menos un año o grado"


* Años de educacion aprobados **
replace GRADO=. if GRADO==9

gen aedu_ci=.

replace aedu_ci=0 if (NIVEL>=1 & NIVEL<=3) | (NIVEL==4 & GRADO==0)

*consistent approach*
replace aedu_ci=GRADO if NIVEL==4 & GRADO>=1

replace aedu_ci=GRADO+6 if (NIVEL==5 | NIVEL==6) & GRADO>=0

replace aedu_ci=GRADO+12 if (NIVEL==7 | NIVEL==8) & GRADO>=0

*replace aedu_ci=GRADO+16 if NIVEL==9
label var aedu_ci "Años de educacion aprobados"


gen eduno_ci=.

replace eduno=1 if (NIVEL==1 & edad>=5) 

replace eduno=0 if (NIVEL>3 & NIVEL<9 & edad>=5)     

label var eduno_ci "1 = personas sin educacion (excluye preescolar)"


gen edupi_ci=.

replace edupi=1 if (NIVEL==4 & GRADO<6 & GRADO>=0) 

replace edupi=0 if ((NIVEL>=5 & NIVEL<9) | (NIVEL==4 & GRADO>=6)) | (eduno==1)

label var edupi_ci "1 = personas que no han completado el NIVEL primario"


gen edupc_ci=.

replace edupc=1 if (NIVEL==4 & GRADO==6) 

replace edupc=0 if (edupi==1 | eduno==1) | (NIVEL==4 & GRADO>6) | (NIVEL>4 & GRADO<9 & NIVEL<9) 

replace edupi=1 if NIVEL==4 & (GRADO==0 | GRADO==.)

label var edupc_ci "1 = personas que han completado el NIVEL primario"


gen edusi_ci=.

replace edusi=1 if (NIVEL==4 & GRADO>6 & GRADO<.) | (NIVEL==5 & GRADO<6 & GRADO>=0) | (NIVEL==6 & GRADO<3 & GRADO>=0)

replace edusi=0 if (edupi==1 | eduno==1 | edupc==1) | (NIVEL==5 & GRADO>=6 & GRADO<.) | (NIVEL==6 & GRADO>=3 & GRADO<.) | (NIVEL>=7 & NIVEL<9) 

label var edusi_ci "1 = personas que no han completado el NIVEL secundario"


gen edusc_ci=.

replace edusc=1 if (NIVEL==5 & GRADO>=6 & GRADO<.) | (NIVEL==6 & GRADO>=3 & GRADO<.) 

replace edusc=0 if (edupi==1 | eduno==1 | edupc==1 | edusi==1) | (NIVEL>6 & NIVEL<9) 

label var edusc_ci "1 = personas que han completado el NIVEL secundario"


gen eduui_ci=.

replace eduui=1 if (NIVEL==7 & GRADO<3 & GRADO>=0) | (NIVEL==8 & GRADO<5 & GRADO>=0) 

replace eduui=0 if (edupi==1 | eduno==1 | edupc==1 | edusi==1 | edusc==1) | (NIVEL==7 & GRADO>=3) | (NIVEL==8 & GRADO>=5) 

label var eduui_ci "1 = personas que no han completado el NIVEL universitario"


gen eduuc_ci=.


replace eduuc=1 if (NIVEL==7 & GRADO>=3 & GRADO<.) | (NIVEL==8 & GRADO>=5 & GRADO<.)


replace eduuc=0 if (edupi==1 | eduno==1 | edupc==1 | edusi==1 | edusc==1 | eduui==1) 


label var eduuc_ci "1 = personas que han completado el NIVEL universitario"

replace edupi=1 if NIVEL==4 & GRADO==.

replace edupc=0 if NIVEL==4 & GRADO==.

replace edusi=1 if (NIVEL==5 | NIVEL==6) & GRADO==.

replace edusc=0 if (NIVEL==5 | NIVEL==6) & GRADO==.

replace eduui=1 if (NIVEL==7 | NIVEL==8) & GRADO==.

replace eduuc=0 if (NIVEL==7 | NIVEL==8) & GRADO==.


gen edus1i_ci=.

replace edus1i=0 if edusi==1 | edusc==1 

replace edus1i=1 if edusi==1 & (NIVEL==5 & GRADO<3 & GRADO>=0) | (NIVEL==6 & GRADO<3 & GRADO>=0)

label var edus1i_ci "1 = personas que no han completado el primer ciclo de la educacion secundaria"


gen edus1c_ci=.

replace edus1c=0 if edusi==1 | edusc==1 

replace edus1c=1 if edusi==1 & (NIVEL==5 & GRADO==3) | (NIVEL==6 & GRADO==3)

label var edus1c_ci "1 = personas que han completado el primer ciclo de la educacion secundaria"


gen edus2i_ci=.

replace edus2i=0 if edusi==1 | edusc==1 

replace edus2i=1 if edusi==1 & ((NIVEL==5 | NIVEL==6) & GRADO>3 & GRADO<6) 

label var edus2i_ci "1 = personas que no han completado el segundo ciclo de la educacion secundaria"


gen edus2c_ci=.

replace edus2c=0 if edusi==1 | edusc==1 

replace edus2c=1 if edusi==1 & ((NIVEL==5 | NIVEL==6) & GRADO>=6 & GRADO<.) 

label var edus2c_ci "1 = personas que han completado el segundo ciclo de la educacion secundaria"


gen edupre_ci=.

replace edupre=0 if eduno==1 | edupi==1 | edupc==1 | edusi==1 | edusc==1 | eduui==1 | eduuc==1


replace edupre=1 if NIVEL==2 

label var edupre_ci "Educacion preescolar"


gen eduac_ci=.


replace eduac=0 if eduui==1 | eduuc==1


replace eduac=1 if NIVEL==8 


label var eduac_ci "Educacion universitaria vs educacion terciaria"


gen edupub_ci=.


label var edupub_ci "1 = personas que asisten a centros de enseñanza publicos"

/*
gen emp_ci=.
replace emp_ci=1 if TRABAJO==1 | REALITRB==1
replace emp_ci=0 if TRABAJO==6 & REALITRB==6
label var emp_ci "Empleado en la semana de referencia"
*/

****************
****condocup_ci*
****************

recode CONDACT (1=1) (2 3=2) (4/9=3), gen(condocup_ci)
replace condocup_ci=4 if edad_ci<10
label var condocup_ci "Condicion de ocupación de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de PET" 
label value condocup_ci condocup_ci

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

gen categopri_ci=1 if CATEG==7


replace categopri_ci=2 if CATEG==4 | CATEG==5 | CATEG==6


replace categopri_ci=3 if CATEG==1 | CATEG==2 | CATEG==3


replace categopri_ci=4 if CATEG==8

label var categopri_ci "Categoria ocupacional actividad principal"

label define categopri_ci 1 "Patron" 2 "Cuenta Propia" 3 "Empleado" 4 "Trabajador no remunerado"

label value categopri_ci categopri_ci


gen ylmpri_ci=.


replace ylmpri_ci=YOCUPP if YOCUPP<99999 & EDAD>9 & YOCUPP>0

replace ylmpri_ci=GANOCUPP if GANOCUPP<99999 & EDAD>9 & GANOCUPP>0

replace ylmpri_ci=0 if YOCUPP==0 & GANOCUPP==0 & EDAD>9 & (TRABAJO==1 | REALITR==1)

replace ylmpri_ci=0 if CATEG==8 & EDAD>9 & (TRABAJO==1 | REALITR==1)

label var ylmpri_ci "Ingreso Laboral Monetario de la Actividad Principal"


gen ylmsec_ci=.

replace ylmsec_ci=YOCUPS if YOCUPS<99999 & EDAD>9 & YOCUPS>0

replace ylmsec_ci=GANOCUPS if GANOCUPS<99999 & EDAD>9 & GANOCUPS>0

replace ylmsec_ci=0 if YOCUPS==0 & GANOCUPS==0 & EDAD>9 & OTROTR==1

label var ylmsec_ci "Ingreso Laboral Monetario de la Actividad Secundaria"


egen ylm_ci=rsum(ylmpri_ci ylmsec_ci)

replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==.

label var ylm_ci "Ingreso Laboral Monetario Total"


gen horaspri_ci=HRSOCUPP if  HRSOCUPP<99 &  HRSOCUPP>0

label var horaspri "Horas totales trabajadas la semana pasada en la Actividad Principal"

gen horassec_ci=HRSOCUPS if  HRSOCUPS<99 &  HRSOCUPS>0


egen horastot=rsum(horaspri horassec)

replace horastot=. if horaspri==. & horassec==.


label var horassec "Horas totales trabajadas la semana pasada en todas las Actividades"

drop horassec

gen ylmhopri_ci=ylmpri_ci/(4.3*horaspri)

label var ylmhopri_ci "Salario Horario Monetario de la Actividad Principal"

gen ylmho_ci=ylm_ci/(4.3*horastot)

label var ylmho_ci "Salario Horario Monetario de todas las Actividades"


gen durades_ci=.

replace durades_ci=TPOBUS if TPOBUS<99 & TPOBUS>0

replace durades=0.5 if CTPOBUS==1 & TPOBUS==0

label var durades "Duracion del Desempleo (en meses)"


gen antiguedad=ANOSTRAB if emp_ci==1 & ANOSTRAB<99 & ANOSTRAB>0

replace antiguedad=0.5 if TPOTRABA==1

label var antiguedad "Antiguedad en la Ocupacion Actual (en anios)"

/*
gen desemp1_ci=.

replace desemp1_ci=1 if BUSCOSEM==1 


replace desemp1_ci=0 if BUSCOSEM==6 | emp==1

label var desemp1_ci "Personas que no tienen trabajo y han buscado trabajo la semana pasada"

gen desemp2_ci=.

replace desemp2_ci=0 if desemp1==0

replace desemp2_ci=1 if desemp1_ci==1 | PQNOBUS==3 | PQNOBUS==4


label var desemp2_ci "desemp1 + personas que no tienen trabajo ni lo buscaron, pero esperan respuesta de una solicitud de empleo, entrevista o temporada agricola"

gen desemp3_ci=.


replace desemp3_ci=0 if desemp2==0 


replace desemp3_ci=1 if desemp2==1 | BUSCOMES==1 


label var desemp3_ci "desemp2 + personas que no tienen trabajo pero han buscado trabajo durante las 4 semanas anteriores a la semana pasada"

gen byte pea1_ci=.

replace pea1=1 if emp==1 | desemp1==1

replace pea1=0 if emp==0 & desemp1==0

label variable pea1_ci "Poblacion Economicamente Activa utilizando la definicion 'desemp1'"

gen byte pea2_ci=.

replace pea2=1 if emp==1 | desemp2==1


replace pea2=0 if emp==0 & desemp2==0


label variable pea2_ci "Poblacion Economicamente Activa utilizando la definicion 'desemp2'"


gen byte pea3_ci=.

replace pea3=1 if emp==1 | desemp3==1

replace pea3=0 if emp==0 & desemp3==0

label variable pea3_ci "Poblacion Economicamente Activa utilizando la definicion 'desemp3'"*/


gen desalent_ci=.

replace desalent=0 if pea==1

replace desalent=1 if PQNOBUS==5

label var desalent_ci "Trabajadores desalentados, personas que creen que por alguna razon no conseguiran trabajo" 

gen subemp_ci=.

replace subemp=0 if emp_ci==0 | emp_ci==1

replace subemp=1 if horastot<30 & DESTRB==1

label var subemp "Trabajadores subempleados"

gen tiempoparc=.

replace tiempoparc=0 if emp_ci==0 | emp_ci==1

replace tiempoparc=1 if horastot<30 & DESTRB==6

label var tiempoparc "Trabajadores a medio tiempo"


*gen contrato_ci=.

*label var contrato "Peronas empleadas que han firmado un contrato de trabajo"


*gen segsoc_ci=.

*label var segsoc "Personas que cuentan con seguro social"


gen nempleos_ci=1 if emp_ci==1

replace nempleos=2 if emp_ci==1 & OTROTRAB==1

replace nempleos=0 if emp_ci==0

label var nempleos "Numero de empleos"


gen tamfirma_ci=.

replace tamfirma=1 if TAMAEST==2

replace tamfirma=0 if TAMAEST==1

label var tamfirma "Trabajadores formales: 1 = + de 10 empleados"


gen spublico_ci=.

label var spublico "Personas que trabajan en el sector publico"


gen nrylmpri_ci=0 

replace nrylmpri_ci=1 if YOCUPP==99999

replace nrylmpri_ci=1 if GANOCUPP==99999

label var nrylmpri_ci "Identificador de No Respuesta del Ingreso Monetario de la Actividad Principal"


egen ylmnr_ci=rsum(ylmpri_ci ylmsec_ci) if nrylmpri_ci==0

replace ylmnr_ci=. if ylmpri_ci==. 

label var ylmnr_ci "Ingreso Laboral Monetario Total, considera 'missing' la No Respuesta "

egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1, by(idh_ch)

replace nrylmpri_ch=1 if nrylmpri_ch>1 & nrylmpri_ch<.

label var nrylmpri_ch "Identificador de Hogares en donde alguno de los miembros No Responde el Ingreso Monetario de la Actividad Principal"

egen ylm_ch=sum(ylm_ci) if miembros_ci==1, by(idh_ch)

label var ylm_ch "Ingreso Laboral Monetario del Hogar"


egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1 & nrylmpri_ch==0, by(idh_ch)

label var ylmnr_ch "Ingreso Laboral Monetario del Hogar, considera 'missing' la No Respuesta"


gen rama_ci=RAMAOCR

replace rama_ci=. if RAMAOCR<1 | emp_ci==0

/************************************************************************************************************
* 3. Creación de nuevas variables de SS and LMK a incorporar en Armonizadas
************************************************************************************************************/
foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }

**********
**tc_ci***
**********
gen tc_ci=12.93
label var tc_ci "Tipo de cambio LCU/USD"

*************
**salmm_ci***
*************
* HON 1996
gen salmm_ci= 	665.16
label var salmm_ci "Salario minimo legal"

****************
*afiliado_ci****
****************
gen afiliado_ci=.
label var afiliado_ci "Afiliado a la Seguridad Social"

****************
*cotizando_ci***
****************
gen cotizando_ci=.
label var cotizando_ci "Cotizante a la Seguridad Social"

*****************
*tipocontrato_ci*
*****************
gen tipocontrato_ci=.
label var tipocontrato_ci "Tipo de contrato segun su duracion"

*************
*tamemp_ci
*************
recode tamaest (1=1) (2=2) (nonmissing=.), gen(tamemp_ci)
label var tamemp_ci "# empleados en la empresa"
label define tamemp_ci  1 "Menos de 10" 2 "10 o mas"


*************
*cesante_ci* 
*************
gen cesante_ci=trabant if trabant==1 & condocup_ci==2
label var cesante_ci "Desocupado -definicion oficial del pais- que ha trabajado antes"	

****************
*tipopen_ci*****
****************
gen tipopen_ci=.
label var tipopen_ci "Tipo de pension - variable original de cada pais" 

****************
*instpen_ci*****
****************
gen instpen_ci=.
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 

*************
**ypen_ci*
*************
gen ypen_ci=.
label var ypen_ci "Valor de la pension contributiva"


*************
**pension_ci*
*************

gen pension_ci=.
label var pension_ci "1=Recibe pension contributiva"

*****************
**ypensub_ci*
*****************

gen ypensub_ci=.
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

***************
*pensionsub_ci*
***************

gen pensionsub_ci=.
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"


*************
***tecnica_ci**
*************
gen tecnica_ci=.
replace tecnica_ci=nivel==6|nivel==7
recode tecnica_ci .=0 
label var tecnica_ci "=1 formacion terciaria tecnica"

*Poverty

*********
*lp25_ci
*********
gen lp25_ci = .

label var lp25_ci "Linea de pobreza de uds1.25 por dia en moneda local"

*********
*lp4_ci*
*********
gen lp4_ci = .

label var lp4_ci "Linea de pobreza de uds4 por dia en moneda local"


*********
*lp_ci***
*********
capture drop lp_ci
gen lp_ci =.
label var lp_ci "Linea de pobreza oficial del pais"

*********
*lpe_ci***
*********

gen lpe_ci =.
label var lpe_ci "Linea de indigencia oficial del pais"

**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************
gen aguared_ch=.

gen aguadist_ch=.

replace aguadist_ch=1 if AGUAB==6

replace aguadist_ch=2 if AGUAB==7 

replace aguadist_ch=3 if AGUAB==8

gen aguamala_ch=.

replace aguamala_ch=1 if AGUAA>=4 & AGUAA<=5

replace aguamala_ch=0 if AGUAA>=1 & AGUAA<=3

gen aguamide_ch=.

gen luz_ch=.

replace luz_ch=1 if LUZ==1 | LUZ==2 | LUZ==3

replace luz_ch=0 if LUZ==4

gen luzmide_ch=.

gen combust_ch=.

gen bano_ch=.

replace bano_ch=1 if SERVSANA==1 | SERVSANA==2

replace bano_ch=0 if SERVSANA==3

gen banoex_ch=.

replace banoex=1 if USOSERV==7

replace banoex=0 if USOSERV==8

gen des1_ch=.

gen des2_ch=.

replace des2_ch=1 if SERVSANB==4 | SERVSANB==5 

replace des2_ch=2 if SERVSANB==6 

replace des2_ch=0 if SERVSANB==0


gen piso_ch=.

replace piso_ch=0 if PISO==5

replace piso_ch=1 if PISO>=1 & PISO<=4 

*replace piso_ch=2 if PISO==

gen pared_ch=.

replace pared_ch=0 if PAREDES==4 | PAREDES==5

replace pared_ch=1 if PAREDES>=1 & PAREDES<=3

*replace pared_ch=2 if PAREDES==6

gen techo_ch=.

gen resid_ch=.

gen dorm_ch=.

replace dorm_ch=NRODORM 


gen cuartos_ch=.

replace cuartos_ch=NROHAB

gen cocina_ch=.

gen telef_ch=.

gen refrig_ch=.

gen freez_ch=.

gen auto_ch=.

gen compu_ch=.

gen internet_ch=.

gen cel_ch=.

gen vivi1_ch=.

gen vivi2_ch=.

replace vivi2_ch=1 if TIPOVIV==1

replace vivi2_ch=0 if TIPOVIV>=2 & TIPOVIV<=6

gen viviprop_ch=.

replace viviprop_ch=0 if TENENCIA==3

replace viviprop_ch=1 if TENENCIA==1

replace viviprop_ch=2 if TENENCIA==2

replace viviprop_ch=3 if TENENCIA==4 | TENENCIA==5 | TENENCIA==6

gen vivitit_ch=.

gen vivialq_ch=.

replace vivialq_ch=PAGOMENS if PAGOMENS>0 & PAGOMENS<9999


gen vivialqimp_ch=.


*falta armar las siguientes variables:
gen ylnm_ci=.
gen ynlm_ci=.
gen ynlnm_ci=.
gen antiguedad_ci=.
gen ocupa_ci=.
gen firmapeq_ci=.

gen horastot_ci=.
gen ylmotros_ci =.
gen ylnmotros_ci=.
gen tcylmpri_ci=.
gen tcylmpri_ch =.
gen rentaimp_ch=.
gen autocons_ci=.
gen autocons_ch=.
gen tiempoparc_ci=.
gen raza_ci=.
gen instcot_ci=.
gen ylnmpri_ci =.
gen ylnmsec_ci =.
gen categosec_ci=.
gen  ylnm_ch =.
gen  ynlm_ch=.
gen  ynlnm_ch =.
gen  remesas_ci=.
gen remesas_ch =.

ren region_bid_c region_BID_c
**Verificación de que se encuentren todas las variables del SOCIOMETRO y las nuevas de mercado laboral
qui sum factor_ch	idh_ch	idp_c	zona_c	pais_c	anio_c	mes_c	relacion_ci	factor_ci	sexo_ci	edad_ci	civil_ci	///
jefe_ci	nconyuges_ch	nhijos_ch	notropari_ch	notronopari_ch	nempdom_ch	clasehog_ch	nmiembros_ch	///
miembros_ci	nmayor21_ch	nmenor21_ch	nmayor65_ch	nmenor6_ch	nmenor1_ch	ocupa_ci	rama_ci	horaspri_ci	///
horastot_ci	ylmpri_ci	ylnmpri_ci	ylmsec_ci	ylnmsec_ci	ylmotros_ci	ylnmotros_ci	nrylmpri_ci	tcylmpri_ci ///
ylm_ci	ylnm_ci	ynlm_ci	ynlnm_ci	nrylmpri_ch	tcylmpri_ch	ylm_ch	ylnm_ch	ylmnr_ch	ynlm_ch	ynlnm_ch	///
ylmhopri_ci	ylmho_ci	rentaimp_ch	autocons_ci	autocons_ch	remesas_ci	remesas_ch	durades_ci	antiguedad_ci ///
emp_ci	desemp_ci	pea_ci	 desalent_ci	subemp_ci	tiempoparc_ci ///
categopri_ci	categosec_ci	nempleos_ci	firmapeq_ci	spublico_ci	aedu_ci	eduno_ci ///
edupi_ci	edupc_ci	edusi_ci	edusc_ci	eduui_ci	eduuc_ci	edus1i_ci	edus1c_ci	edus2i_ci ///
edus2c_ci	edupre_ci	eduac_ci	asiste_ci	pqnoasis	repite_ci	repiteult_ci	edupub_ci	///
aguared_ch	aguadist_ch	aguamala_ch	aguamide_ch	luz_ch	luzmide_ch	combust_ch	bano_ch	banoex_ch	///
des1_ch	des2_ch	piso_ch	pared_ch	techo_ch	resid_ch	dorm_ch	cuartos_ch	cocina_ch	telef_ch ///
refrig_ch	freez_ch	auto_ch	compu_ch	internet_ch	cel_ch	vivi1_ch	vivi2_ch	viviprop_ch	///
vivitit_ch	vivialq_ch	vivialqimp_ch region_BID_c region_c raza_ci        lp25_ci	       lp4_ci	 ///
lp_ci	       lpe_ci	       cotizando_ci	         afiliado_ci	///
tipopen_ci	   instpen_ci	   instcot_ci	   instpen_ci	   tipocontrato_ci 	   condocup_ci 	   cesante_ci ///
tamemp_ci 	   pension_ci 	   ypen_ci 	   pensionsub_ci 	   ypensub_ci 	   salmm_ci	   tecnica_ci	///
tamemp_ci categoinac_ci formal_ci



qui destring $var, replace
 

* Activar solo si es necesario
*keep *_ci  *_c  idh_ch 
qui compress



saveold "`base_out'", replace


log close



