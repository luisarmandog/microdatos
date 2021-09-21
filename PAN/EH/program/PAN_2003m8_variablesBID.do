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
 


global ruta = "${surveysFolder}"

local PAIS PAN
local ENCUESTA EH
local ANO "2003"
local ronda m8

local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_orig\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
   

capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
País: Panama
Encuesta: EH
Round: Agosto
Autores: 
Versión 2010: do file preparado por Melisa Morales para Suzanne Duryea 
Última versión: María Laura Oliveri (MLO) - Email: mloliveri@iadb.org, lauraoliveri@yahoo.com
Fecha última modificación: 10 de Octubre de 2013
Modificación 2014: Mayra Sáenz - Email: mayras@iadb.org - saenzmayra.a@gmail.com
							SCL/LMK - IADB
****************************************************************************/
/***************************************************************************
Detalle de procesamientos o modificaciones anteriores:
/*
*revision 16 agosto*
1.se cambiaron los paths, se puso todo en X
revision marzo 27:
porblemas en la generacion de antiguedad_ci es p35 en lugar de "p33"
gen m=p33-100 if p35>=100 & p35<=111
gen a=p33-200 if p35>=201 & p35<299
*/
****************************************************************************/


use `base_in', clear

destring _all, replace

		**********************************
		***VARIABLES DEL IDENTIFICACION***
		**********************************
		
	****************
	* region_BID_c *
	****************
	
gen region_BID_c=1
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroamérica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"


************
* Region_c *
************
*Inclusión Mayra Sáenz - Julio 2013

destring prov, replace
gen region_c=  prov

label define region_c  ///
1	"Bocas del Toro" ///
2	"Coclé" ///
3	"Colón" ///
4	"Chiriquí" ///
5	"Darién" ///
6	"Herrera" ///
7	"Los Santos" ///
8	"Panamá" ///
9	"Veraguas" ///
10	"Kuna Yala" ///
11	"Emberá" ///
12	"Ngäbe-Buglé"		  
label value region_c region_c
label var region_c "División política, provincias"

***************
***factor_ci***
***************

gen factor_ci=fac15_e
label variable factor_ci "Factor de expansion del individuo"

**************
****idh_ch****
**************
egen idh_ch=group(prov dist corre estra unidad cuest hogar areareco)
label variable idh_ch "ID del hogar"

*************
****idp_ci***
*************

gen idp_ci=nper
label variable idp_ci "ID de la persona en el hogar"

*****************
***relacion_ci***
*****************

gen relacion_ci=.
replace relacion_ci=1 if p1==1
replace relacion_ci=2 if p1==2
replace relacion_ci=3 if p1==3
replace relacion_ci=4 if p1==4 
replace relacion_ci=5 if p1==6
replace relacion_ci=6 if p1==5

label variable relacion_ci "Relacion con el jefe del hogar"
label define relacion_ci 1 "Jefe/a" 2 "Esposo/a" 3 "Hijo/a" 4 "Otros parientes" 5 "Otros no parientes" 6 "Empleado/a domestico/a"
label value relacion_ci relacion_ci

***************
***factor_ch***
***************

**NOTE need to create new variable factorjefe, save dataset, then egen new variable factor_ch**

gen factorjefe=factor_ci if relacion_ci==1
by idh_ch, sort: egen factor_ch=sum(factorjefe)

label variable factor_ch "Factor de expansion del hogar"
drop factorjefe


**********
***zona***
**********

gen byte zona_c=0 if areareco==2
replace zona_c=1 if areareco==1
label variable zona_c "Zona del pais"
label define zona_c 1 "Urbana" 0 "Rural"
label value zona_c zona_c

************
****pais****
************

gen str3 pais_c="PAN"
label variable pais_c "Pais"

**********
***anio***
**********

gen anio_c=2003
label variable anio_c "Anio de la encuesta"

*********
***mes***
*********

gen mes_c=8
label variable mes_c "Mes de la encuesta"
label define mes_c 1 "Enero" 2 "Febrero" 3 "Marzo" 4 "Abril" 5 "Mayo" 6 " Junio" 7 "Julio" 8 "Agosto" 9 "Septiembre" 10 "Octubre" 11 "Noviembre" 12 "Diciembre"
label value mes_c mes_c

****************************
***VARIABLES DEMOGRAFICAS***
****************************


**********
***sexo***
**********

gen sexo_ci=p2
label define sexo_ci 1 "Hombre" 2 "Mujer"
label value sexo_ci sexo_ci

**********
***edad***
**********

gen edad_ci=p3
label variable edad_ci "Edad del individuo"



*****************
***estcivil_ci***
*****************
**NOTE estado civil NO EXISTE en este base de datos**

gen civil_ci=.
replace civil_ci=1 if p5==7 | p5==8
replace civil_ci=2 if p5==1 | p5==4
replace civil_ci=3 if p5==2 | p5==3 | p5==5
replace civil_ci=4 if p5==6
label variable civil_ci "Estado civil"
label define civil_ci 1 "Soltero" 2 "Union formal o informal" 3 "Divorciado o separado" 4 "Viudo"
label value civil_ci estcivil_ci


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

by idh_ch, sort: egen nempdom_ch=sum(relacion_ci==6)
label variable nempdom_ch "Numero de empleados domesticos"

*****************
***clasehog_ch***
*****************

gen clasehog_ch=.
replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0 /* unipersonal*/
replace clasehog_ch=2 if nhijos_ch>0 & notropari_ch==0 & notronopari_ch==0 /* nuclear (child with or without spouse but without other relatives)*/
replace clasehog_ch=2 if nconyuges_ch>0 & notropari_ch==0 & notronopari_ch==0 /* nuclear (spouse with or without children but without other relatives)*/
replace clasehog_ch=3 if ((clasehog_ch ==2 & notropari_ch>0) & notronopari_ch==0) |(notropari_ch>0 & notronopari_ch==0)   /* ampliado*/
replace clasehog_ch=4 if (nconyuges_ch>0 | nhijos_ch>0 | (notropari_ch>0 & notropari_ch<.)) & (notronopari_ch>0 & notronopari_ch<.) /* compuesto  (some relatives plus non relative)*/
replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 & notronopari_ch<./** corresidente*/

label variable clasehog_ch "CLASE HOGAR"
label define clasehog_ch 1 "Unipersonal" 2 "Nuclear" 3 "Ampliado" 4 "Compuesto" 5 "Corresidente"
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

gen miembros_ci=(relacion_ci<5)
label variable miembros_ci "Miembro del hogar"
	
*******************************************************
***           VARIABLES DE DIVERSIDAD               ***
*******************************************************				
* Maria Antonella Pereira & Nathalia Maya - Marzo 2021	

	***************
	*** afroind_ci ***
	***************
**Pregunta: ¿Se considera usted indígena? (indi_rec) (1 - no indígena; 2 - indígena)
**No se identifica a personas afrodescendientes. Todos los no-indígenas se categorizan como "otro". 
**En el 2011 se convierte en la EHPM (no solo EH) 

	***************
	***afroind_ci***
	***************
gen afroind_ci=. 

	***************
	***afroind_ch***
	***************
gen afroind_ch=. 

	*******************
	***afroind_ano_c***
	*******************
gen afroind_ano_c=.		

	*******************
	*** dis_ci ***
	*******************
gen dis_ci=. 

	*******************
	*** dis_ch ***
	*******************
gen dis_ch=. 

************************************
*** VARIABLES DEL MERCADO LABORAL***
************************************


****************
****condocup_ci*
****************
/* revisar
gen condocup_ci=.
replace condocup_ci=1 if p12_19 >= 1 & p12_19 <= 3 | p12_19==5
replace condocup_ci=2 if (p12_19 >= 5 & p12_19 < 15) & (p20==0 | p20==1 | (p20==2 & p21==1))  | p12_19==4
replace condocup_ci=3 if condocup_ci!=2 & condocup_ci!=1
replace condocup_ci=4 if edad_ci<10
*/
gen condocup_ci=.
replace condocup_ci=1 if p12_19 >= 1 & p12_19 <= 5
replace condocup_ci=2 if (p12_19>=6 & p12_19<=8) | (((p12_19 >= 10 & p12_19 <= 12) | p12_19==15) & p20==1)
recode condocup_ci .=3 if edad>=10
recode condocup_ci .=4 if edad<10
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

/*
************
***emp_ci***
************

gen byte emp_ci=0
replace emp_ci=1 if p12_19>=1 & p12_19<=5

/*Se esta considerando empleado a aquellos que contestan "trabajando, trabajos informales, o trabajo familiar*/

****************
***desemp1_ci***
****************

gen desemp1_ci=(emp_ci==0 & p12_19==6)

****************
***desemp2_ci*** 
****************

gen desemp2_ci=(emp_ci==0 & (p12_19==6 | p12_19==7 | p12_19==8))

****************
***desemp3_ci***
****************

gen desemp3_ci=(emp_ci==0 & (p12_19==6 | p12_19==7 | p12_19==8 | p20==1))

*************
***pea1_ci***
*************

gen pea1_ci=0
replace pea1_ci=1 if emp_ci==1 | desemp1_ci==1


*************
***pea2_ci***
*************

gen pea2_ci=0
replace pea2_ci=1 if emp_ci==1 | desemp2_ci==1

*************
***pea3_ci***
*************

gen pea3_ci=0
replace pea3_ci=1 if emp_ci==1 | desemp3_ci==1*/

*****************
***horaspri_ci***
*****************

gen horaspri_ci=p38 if p38>0 & p38<99
replace horaspri_ci=. if emp_ci==0

*****************
***horastot_ci***
*****************

egen horastot_ci=rsum(p38 p43) if p38<99 & p38>0 , missing
replace horastot_ci=horaspri_ci if p43==99 | p43==0
replace horastot_ci=. if (p38==0 & p43==0) | (p38==99 | p43==99)
replace horastot_ci=. if emp_ci==0

*****************
***desalent_ci***
*****************

gen desalent_ci=(emp_ci==0 & p12_19==9)

***************
***subemp_ci***
***************

gen subemp_ci=0
replace subemp_ci=1 if (emp_ci==1 & p45==1 & horaspri_ci<=30)

* Alternativa considerando disponibilidad. MGD 06/19/2014
gen subemp_ci1=0
replace subemp_ci1=1 if (emp_ci==1 & p45==1 & horaspri_ci<=30) & (p47==1 | (p48>=1 & p48<=3))


*******************
***tiempoparc_ci***
*******************

gen tiempoparc_ci=.
replace tiempoparc_ci=1 if p45==2 & horastot<=30
replace tiempoparc_ci=0 if p45==1 | (p45==2 & horastot>30 & horastot<.)


************************************
*** VARIABLES DE DEMANDA LABORAL***
************************************

**************
***ocupa_ci***
**************

**NOTE: No encontre fuerzas armadas en la lista. **

* Modificacion MGD 07/22/2014: se utiliza la clasificacion CNO de Panama
g aux_p28=p28
destring aux_p28, replace

g ocupa_ci=.
replace ocupa_ci=1 if (aux_p28>=140 & aux_p28<=662) & emp_ci==1
replace ocupa_ci=2 if (aux_p28>=1 & aux_p28<=139) & emp_ci==1
replace ocupa_ci=3 if (aux_p28>=663 & aux_p28<=817) & emp_ci==1
replace ocupa_ci=4 if ((aux_p28>=880 & aux_p28<=917) | (aux_p28>=1555 & aux_p28<=1565)) & emp_ci==1
replace ocupa_ci=5 if ((aux_p28>=818 & aux_p28<=879) | (aux_p28>=1566 & aux_p28<=1608)) & emp_ci==1
replace ocupa_ci=6 if (aux_p28>=918 & aux_p28<=1000)  & emp_ci==1
replace ocupa_ci=7 if ((aux_p28>=1001 & aux_p28<=1554) | (aux_p28>=1609 & aux_p28<=1649)) & emp_ci==1
replace ocupa_ci=8 if  (aux_p28>=1650 & aux_p28<=1651)& emp_ci==1
replace ocupa_ci=9 if (aux_p28>=1652 & aux_p28<=1653 ) & emp_ci==1

drop aux_p28

label define ocupa_ci 1"profesional y tecnico" 2"director o funcionario sup" 3"administrativo y nivel intermedio"
label define ocupa_ci  4 "comerciantes y vendedores" 5 "en servicios" 6 "trabajadores agricolas", add
label define ocupa_ci  7 "obreros no agricolas, conductores de maq y ss de transporte", add
label define ocupa_ci  8 "FFAA" 9 "Otras ", add
label value ocupa_ci ocupa_ci
label variable ocupa_ci "Ocupacion laboral" 

*************
***rama_ci***
*************

gen rama_ci=. 
replace rama_ci=1 if p30>=111 & p30<=502 & emp_ci==1
replace rama_ci=2 if p30>=1320 & p30<=1429 & emp_ci==1
replace rama_ci=3 if p30>=1511 & p30<=3720 & emp_ci==1
replace rama_ci=4 if p30>=4010 & p30<=4100 & emp_ci==1
replace rama_ci=5 if p30>=4510 & p30<=4550 & emp_ci==1
replace rama_ci=6 if p30>=5110 & p30<=5530 & emp_ci==1
replace rama_ci=7 if p30>=6010 & p30<=6420 & emp_ci==1
replace rama_ci=8 if p30>=6511 & p30<=7020 & emp_ci==1
replace rama_ci=9 if p30>=7111 & p30<=9900 & emp_ci==1
label var rama_ci "RAMA"
label define rama_ci 1 "Agricultura, caza, silvicultura y pesca" 2 "Explotación de minas y canteras" 3 "Industrias manufactureras" 4 "Electricidad, gas y agua" 5 "Construcción" 6 "Comercio al por mayor y menor, restaurantes, hoteles" 7 "Transporte y almacenamiento" 8 "Establecimientos financieros, seguros, bienes inmuebles" 9 "Servicios sociales, comunales y personales"
label values rama_ci rama_ci

******************
***categopri_ci***
******************

**check to see that Trabajadores Familiares are not receiving salary**

gen categopri_ci=.
replace categopri_ci=1 if p32==6 & emp_ci==1
replace categopri_ci=2 if (p32==5 | p32==8 ) & emp_ci==1
replace categopri_ci=3 if (p32==1 | p32==2 | p32==3 | p32==4 )& emp_ci==1
replace categopri_ci=4 if (p32==7 ) & emp_ci==1
*MLO: agregue la condicion que sea ocupado
label define categopri_ci 1 "Patron" 2 "Cuenta propia" 3 "Empleado" 4 "Trabajador no remunerado"
label value categopri_ci categopri_ci
label variable categopri_ci "Categoria ocupacional en la actividad principal"


******************
***categosec_ci***
******************

**solo preguntaron si el segundo trabajo es agropecuario/artesanal o no, y cuanto gana**
*no es posbile crear esta variable*

gen categosec_ci=.
label define categosec_ci 1 "Patron" 2 "Cuenta propia" 3 "Empleado" 4 "Familiar no remunerado" 
label value categosec_ci categosec_ci
label variable categosec_ci "Categoria ocupacional en la actividad secundaria"
/*
*****************
***contrato_ci***
*****************

gen contrato_ci=.
replace contrato_ci=1 if p33==2 | p33==3 | p33==4 /* contratos permanentes o transitorios */
replace contrato_ci=0 if p33==5 | p33==1 /* sin contrato o trabajadores permanentes */

***************
***segsoc_ci***
***************

**no es posible crear esta variable**

gen segsoc_ci=.*/


*****************
***nempleos_ci***
*****************

gen nempleos_ci=.
replace nempleos_ci=1 if emp_ci==1
replace nempleos_ci=2 if emp_ci==1 & (p39==1 | p39==2)

**nunca preguntan por el numero de trabajos distintos. solo preguntan por trabajo principal y secundario**

*****************
***tamfirma_ci***
*****************

gen tamfirma_ci=.
replace tamfirma_ci=0 if p31==1 /* menos de 5 */
replace tamfirma_ci=1 if p31>=2 & p31<=5 /* 5 o mas */


*****************
***spublico_ci***
*****************

gen spublico_ci=.
replace spublico_ci=1 if p32==1
replace spublico_ci=0 if p32>=2 & p32<=8


****************
***durades_ci***p20
****************
gen d=p24-200 if p24>=201 & p24<299
replace d=0.5 if p24==100

gen durades_ci= .
replace durades_ci=d
*replace durades_ci=. if emp_ci==1


*******************
***antiguedad_ci***
*******************
/* se cambio tambien en el general: PAN_ingresos*/

gen m=p35-100 if p35>=100 & p35<=111
gen a=p35-200 if p35>=201 & p35<299

gen antiguedad_ci=.
replace antiguedad_ci=a
replace antiguedad_ci=m/12 if a==.

drop a m d

******************************************************************
*********************        INGRESOS         ********************
******************************************************************

****************************
***ylmpri_ci & ylmpri1_ci***
****************************

gen ylmpri_ci=p371 if p371>0 & p371<9999 & categopri==3
replace ylmpri_ci=p373 if p373>0 & p373<9999 & (categopri==1 | categopri==2)
replace ylmpri_ci=0 if categopri==4
replace ylmpri_ci=. if emp_ci==0

gen aguin=p49f if p49f>0 & p49f<9999

egen ylmpri1_ci=rsum(ylmpri_ci agui), missing
replace ylmpri1_ci=. if ylmpri_ci==. & agui==.
replace ylmpri1_ci=. if emp_ci==0
replace ylmpri1_ci=. if ylmpri_ci==. & (p372==0 | p372==9999)

********************************
***nrylmpri_ci & nrylmpri1_ci***
********************************

**solo para personas empleadas, else missing**

gen nrylmpri_ci=(((p371>=9999 & p371<.) | (p373>=9999 & p373<.)) & emp_ci==1)
replace nrylmpri_ci=. if emp_ci==0


***************
***ylmsec_ci***
***************
gen ylmsec_ci=p44 if p44>0 & p44<9999  
replace ylmsec_ci=. if emp_ci==0


****************
***ylnmsec_ci***
****************

g ylnmsec_ci=.
label var ylnmsec_ci "Ingreso laboral NO monetario actividad secundaria"


*****************
***ylmotros_ci***
*****************
gen ylmotros_ci=.
label var ylmotros_ci "Ingreso laboral monetario de otros trabajos" 


******************
***ylnmotros_ci***
******************

gen ylnmotros_ci=.
label var ylnmotros_ci "Ingreso laboral NO monetario de otros trabajos" 

**************
*** ylm_ci ***
**************

egen ylm_ci=rsum(ylmpri_ci ylmsec_ci), missing
replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==.

egen ylm1_ci= rsum(ylmpri1_ci ylmsec_ci), missing
replace ylm1_ci=. if ylmpri1_ci==. & ylmsec_ci==.

*******************
***   ylnm_ci   ***
*******************

gen ylnmpri_ci=p372 if p372>0 & p372<9999
gen ylnm_ci=ylnmpri_ci

*************
***ynlm_ci***
*************

gen jub=p49a if p49a>0 & p49a<9999

gen ayfam=p49b if p49b>0 & p49b<9999

gen alqui=p49c if p49c>0 & p49c<9999

gen loter=p49d if p49d>0 & p49d<9999

gen becas=p49e if p49e>0 & p49e<9999

gen agro=p49g if p49g>0 & p49g<9999

gen otroy=p49h if p49h>0 & p49h<9999

egen ynlme1= rsum(jub ayfam alqui loter becas agro otroy) if emp_ci==1, missing
replace ynlme1=. if (jub==. & ayfam==. & alqui==. & becas==. & loter==. & agro==. & otroy==. & emp_ci==1)

egen ynlmd1= rsum(jub ayfam alqui loter becas agro agui otroy) if emp_ci==0, missing
replace ynlmd1=. if (jub==. & ayfam==. & alqui==. & becas==. & loter==. & agro==. & agui==. & otroy==. & emp_ci==0)

egen ynlm1_ci=rsum(ynlme1 ynlmd1), missing
replace ynlm1_ci=. if ynlme1==. & ynlmd1==.

egen ynlme= rsum(jub ayfam alqui loter becas otroy) if emp_ci==1, missing
replace ynlme=. if (jub==. & ayfam==. & alqui==. & becas==. & loter==. & otroy==. & emp_ci==1)

egen ynlmd= rsum(jub ayfam alqui loter becas agui otroy) if emp_ci==0, missing
replace ynlmd=. if (jub==. & ayfam==. & alqui==. & becas==. & loter==. & agui==. & otroy==. & emp_ci==0)

egen ynlm_ci=rsum(ynlme ynlmd), missing
replace ynlm_ci=. if ynlme==. & ynlmd==.

drop jub alqui loter becas agro otroy ayfam agui ynlme ynlmd ynlme1 ynlmd1

gen ynlnm_ci=.

************************
*** HOUSEHOLD INCOME ***
************************

*******************
*** nrylmpri_ch ***
*******************

*Creating a Flag label for those households where someone has a ylmpri_ci as missing

by idh_ch, sort: egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1, missing
replace nrylmpri_ch=1 if nrylmpri_ch>0 & nrylmpri_ch<.
replace nrylmpri_ch=. if nrylmpri_ch==.

*by idh_ch, sort: egen nrylmpri1_ch=sum(nrylmpri1_ci) if miembros_ci==1, missing
*replace nrylmpri1_ch=1 if nrylmpri1_ch>0 & nrylmpri1_ch<.
*replace nrylmpri1_ch=. if nrylmpri1_ch==.


************************
*** ylm_ch & ylm1_ch ***
************************

by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
by idh_ch, sort: egen ylm1_ch=sum(ylm1_ci) if miembros_ci==1, missing

****************************
*** ylmnr_ch & ylmnr1_ch ***
****************************

by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1 & nrylmpri_ch==0, missing
*replace ylmnr_ch=. if nrylmpri_ch==1

by idh_ch, sort: egen ylmnr1_ch=sum(ylm1_ci) if miembros_ci==1 & nrylmpri_ch==0, missing
*replace ylmnr1_ch=. if nrylmpri1_ch==1

***************
*** ylnm_ch ***
***************

by idh_ch, sort: egen ylnm_ch=sum(ylnm_ci) if miembros_ci==1, missing

******************
*** remesas_ch ***
******************
gen remesas_ci=.
gen remesas_ch=.


***************
*** ynlm_ch ***
***************
by idh_ch, sort: egen ynlm1_ch=sum(ynlm1_ci) if miembros_ci
by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci


gen ynlnm_ch=.


*****************************************************************
*identificador de top-code del ingreso de la actividad principal*
*****************************************************************

gen tcylmpri_ci=.
**************************************************
*Identificador de los hogares en donde (top code)*
**************************************************
gen tcylmpri_ch=.


*******************
*** autocons_ci ***
*******************

gen autocons_ci=.


*******************
*** autocons_ch ***
*******************

gen autocons_ch=.

*******************
*** rentaimp_ch ***
*******************

gen rentaimp_ch=.

******************************
***ylhopri_ci & ylhopri1_ci***
******************************

gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.3)

gen ylmhopri1_ci=ylmpri1_ci/(horaspri_ci*4.3)

**************************
***ylmho_ci & ylm1ho_ci***
**************************

gen ylmho_ci=ylm_ci/(horastot_ci*4.3)

gen ylmho1_ci=ylm1_ci/(horastot_ci*4.3)

*** HOUSING ***
gen aguared_ch=.

gen aguadist_ch=.

gen aguamala_ch=.

gen aguamide_ch=.

gen luz_ch=.

gen luzmide_ch=.

gen combust_ch=.

gen bano_ch=.

gen banoex_ch=.

gen des1_ch=.


gen des2_ch=.

gen piso_ch=.

gen pared_ch=.

gen techo_ch=.

gen resid_ch=. 

**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**	
gen aguamejorada_ch = .

gen  banomejorado_ch = .

gen dorm_ch=.

gen cuartos_ch=.

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

gen viviprop_ch=.

gen vivitit_ch=.

gen vivialq_ch=.

gen vivialqimp_ch=.

** EDUCACION **

gen asiste_ci=.
replace asiste_ci=1 if p9==1
replace asiste_ci=0 if p9==2
label var asiste "Personas que actualmente asisten a centros de enseñanza"

gen pqnoasis_ci=p9a if p9a>0
label var pqnoasis_ci "Razones para no asistir a centros de enseñanza"

**************
*pqnoasis1_ci*
**************
**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**

g       pqnoasis1_ci = 1 if p9a==3
replace pqnoasis1_ci = 2 if p9a==2
replace pqnoasis1_ci = 5 if p9a==4
replace pqnoasis1_ci = 8 if p9a==1
replace pqnoasis1_ci = 9 if p9a==5

label define pqnoasis1_ci 1 "Problemas económicos" 2 "Por trabajo" 3 "Problemas familiares o de salud" 4 "Falta de interés" 5	"Quehaceres domésticos/embarazo/cuidado de niños/as" 6 "Terminó sus estudios" 7	"Edad" 8 "Problemas de acceso"  9 "Otros"
label value  pqnoasis1_ci pqnoasis1_ci

gen edupub_ci=.
label var edupub_ci "Personas que asisten a centros de ensenanza publicos"

gen repiteult_ci=.
label var repiteult_ci "Personas que han repetido el ultimo grado"

gen repite_ci=.
label var repite_ci "Personas que han repetido al menos un año o grado"



gen grado=p10-10 if p10>=11 & p10<=16
replace grado=p10-20 if p10>=21 & p10<=26
replace grado=p10-30 if p10>=31 & p10<=33
replace grado=p10-40 if p10>=41 & p10<=49
replace grado=p10-50 if p10>=51 & p10<=53
replace grado=0 if p10==60

gen nivel=0 if p10==60
replace nivel=1 if p10>=11 & p10<=16
replace nivel=2 if p10>=21 & p10<=26
replace nivel=3 if p10>=31 & p10<=33
replace nivel=4 if p10>=41 & p10<=49
replace nivel=5 if p10>=51 & p10<=53

gen aedu_ci=0 if nivel==0
replace aedu_ci=grado if nivel==1
replace aedu_ci=grado+6 if nivel==2 | nivel==3
replace aedu_ci=grado+12 if nivel==4 | nivel==5

gen eduno_ci=.
replace eduno_ci=0 if aedu>0 & aedu<.
replace eduno_ci=1 if aedu==0

gen edupi_ci=.
replace edupi_ci=1 if aedu>=1 & aedu<6
replace edupi_ci=0 if aedu>=6 & aedu<.

gen edupc_ci=.
replace edupc_ci=1 if aedu==6
replace edupc_ci=0 if (aedu>=1 & aedu<6) | (aedu>6 & aedu<.)

gen edusi_ci=.
replace edusi_ci=1 if aedu>6 & aedu<12
replace edusi_ci=0 if (aedu>=1 & aedu<=6) | (aedu>=12 & aedu<.)

gen edusc_ci=.
replace edusc_ci=1 if aedu==12
replace edusc_ci=0 if (aedu>=1 & aedu<12) | (aedu>12 & aedu<.)

gen eduui_ci=.
replace eduui_ci=1 if aedu>12 & aedu<17
replace eduui_ci=0 if (aedu>=1 & aedu<=12) | (aedu>=17 & aedu<.)

gen eduuc_ci=.
replace eduuc_ci=1 if aedu>=17 & aedu<.
replace eduuc_ci=0 if (aedu>=1 & aedu<17) 

gen edus1i_ci=.
replace edus1i_ci=0 if edusi_ci==1 | edusc_ci==1
replace edus1i_ci=1 if aedu>=7 & aedu<=8

gen edus1c_ci=.
replace edus1c_ci=0 if edusi_ci==1 | edusc_ci==1
replace edus1c_ci=1 if aedu==9

gen edus2i_ci=.
replace edus2i_ci=0 if edusi_ci==1 | edusc_ci==1
replace edus2i_ci=1 if aedu==10 | aedu==11

gen edus2c_ci=.
replace edus2c_ci=0 if edusi_ci==1 | edusc_ci==1
replace edus2c_ci=1 if aedu==12


gen edupre_ci=.

gen eduac_ci=.
replace eduac_ci=0 if nivel==5
replace eduac_ci=1 if nivel==4

drop nivel grado

/************************************************************************************************************
* 3. Creación de nuevas variables de SS and LMK a incorporar en Armonizadas
************************************************************************************************************/

*************
**salmm_ci***
*************

* PAN 2003

gen salmm_ci= . /*245.42*/
replace salmm_ci= 228 if rama_ci==1
replace salmm_ci= 272.8 if rama_ci==2
replace salmm_ci= 241.6 if rama_ci==3
replace salmm_ci= 266.4 if rama_ci==4
replace salmm_ci= 332.8 if rama_ci==5
replace salmm_ci= 248 if rama_ci==6
replace salmm_ci= 262.4 if rama_ci==7
replace salmm_ci= 301.6 if rama_ci==8
replace salmm_ci= 287.2 if rama_ci==9
replace salmm_ci= 271.2 if salmm_ci==.

label var salmm_ci "Salario minimo legal"

*********
*lp_ci***
*********

gen lp_ci =.
replace lp_ci= 63.83 if zona_c==1 & dist==1 /* Cdad. Panamá*/
replace lp_ci= 63.83 if zona_c==1 & dist==3 /* Zona urbana districto san miguelito*/
replace lp_ci= 71.23 if ((dist!=1 & dist!=3) & zona_c==1) | zona_c==0  /* resto urbano o rural*/


label var lp_ci "Linea de pobreza oficial del pais"

*********
*lpe_ci**
*********

gen lpe_ci =.
replace lpe_ci= 30.33 if zona_c==1 & dist==1 /* Cdad. Panamá*/
replace lpe_ci= 30.33 if zona_c==1 & dist==3 /* Zona urbana districto san miguelito*/
replace lpe_ci= 31.52 if ((dist!=1 & dist!=3) & zona_c==1) | zona_c==0  /* resto urbano o rural*/

label var lpe_ci "Linea de indigencia oficial del pais"

****************
*cotizando_ci***
****************
gen cotizando_ci=.
label var cotizando_ci "Cotizante a la Seguridad Social"

****************
*afiliado_ci****
****************
gen afiliado_ci=.	
replace afiliado_ci =1 if p4==1
recode afiliado_ci .=0 if p12_19 >= 1 & p12_19 <= 6
label var afiliado_ci "Afiliado a la Seguridad Social"

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

****************
*instcot_ci*****
****************
gen instcot_ci=.
label var instcot_ci "Institucion proveedora de la pension - variable original de cada pais" 

*****************
*tipocontrato_ci*
*****************

gen tipocontrato_ci=.
replace tipocontrato_ci=1 if p33==1 | p33==4 & categopri_ci==3
replace tipocontrato_ci=2 if (p33==2 | p33==3) & categopri_ci==3
replace tipocontrato_ci=3 if (p33==5 | tipocontrato_ci==.) & categopri_ci==3
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci


*************
*cesante_ci* 
*************
* MGD 12/4/2015: se corrige la inclusion de ceros con p26 >100. Antes solamnte se incluia a los missings ==999
gen cesante_ci=1 if p27>100 & p27!=999 & condocup_ci==2
*gen cesante_ci=1 if p27==999 
recode cesante_ci .=0 if condocup_ci==2
label var cesante_ci "Desocupado - definicion oficial del pais"		

*******************
***formal***
*******************
gen formal=1 if cotizando_ci==1

replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="BOL"   /* si se usa afiliado, se restringiendo a ocupados solamente*/
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="CRI"
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="GTM" & anio_c>1998
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="PAN"
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="PRY" & anio_c<=2006
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="DOM"
replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="MEX" & anio_c>=2008

gen byte formal_ci=.
replace formal_ci=1 if formal==1 & (condocup_ci==1 | condocup_ci==2)
replace formal_ci=0 if formal_ci==. & (condocup_ci==1 | condocup_ci==2) 
label var formal_ci "1=afiliado o cotizante / PEA"

*************
*tamemp_ci
*************
gen tamemp_ci=1 if p31==1 
label var  tamemp_ci "Tamaño de Empresa" 
*Empresas medianas
replace tamemp_ci=2 if p31==2 | p31==3 | p31==4
*Empresas grandes
replace tamemp_ci=3 if p31==5
label define tamaño 1"Pequeña" 2"Mediana" 3"Grande"
label values tamemp_ci tamaño
tab tamemp_ci [iw= fac15_e]

*************
*categoinac_ci
*************

gen categoinac_ci=1 if p12_19==10
label var  categoinac_ci "Condición de Inactividad" 
*Estudiantes
replace categoinac_ci=2 if p12_19==11
*Quehaceres del Hogar
replace categoinac_ci=3 if p12_19==12
*Otra razon
replace categoinac_ci=4 if p12_19==13 | p12_19==14 | p12_19==15
label define inactivo 1"Pensionado y otros" 2"Estudiante" 3"Hogar" 4"Otros"
label values categoinac_ci inactivo

*************
**pension_ci*
*************
replace p49a=. if p49a==9999
egen aux_p=rsum(p49a), missing
gen pension_ci=1 if aux_p>0 & aux_p!=. & aux_p!=999999
recode pension_ci .=0
label var pension_ci "1=Recibe pension contributiva"

*************
*ypen_ci*
*************

gen ypen_ci=p49a
*2014, 02 anulo siguiente linea MLO
*replace ypen_ci=.
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************

gen pensionsub_ci=.
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**ypensub_ci*
*****************

gen byte ypensub_ci=.
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"


*************
*tecnica_ci**
*************

gen tecnica_ci=.
replace tecnica_ci=1 if  p10==31 |  p10==32|  p10==33 
recode tecnica_ci .=0
label var tecnica_ci "1=formacion terciaria tecnica"

	
/*_____________________________________________________________________________________________________*/
* Asignación de etiquetas e inserción de variables externas: tipo de cambio, Indice de Precios al 
* Consumidor (2011=100), líneas de pobreza
/*_____________________________________________________________________________________________________*/


do "$gitFolder\armonizacion_microdatos_encuestas_hogares_scl\_DOCS\\Labels&ExternalVars_Harmonized_DataBank.do"

/*_____________________________________________________________________________________________________*/
* Verificación de que se encuentren todas las variables armonizadas 
/*_____________________________________________________________________________________________________*/

order region_BID_c region_c pais_c anio_c mes_c zona_c factor_ch	idh_ch	idp_ci	factor_ci sexo_ci edad_ci ///
afroind_ci afroind_ch afroind_ano_c dis_ci dis_ch relacion_ci civil_ci jefe_ci nconyuges_ch nhijos_ch notropari_ch notronopari_ch nempdom_ch ///
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






