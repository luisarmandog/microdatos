* (Versi�n Stata 12)
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

local PAIS URY
local ENCUESTA ECH
local ANO "2015"
local ronda a 


local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
*local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_orig\\`PAIS'_`ANO'`ronda'.dta"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: Uruguay
Encuesta: ECH
Round: a
Autores: Marcela G. Rubio
�ltima versi�n: Marcela Rubio E-mail: mrubio@iadb.org / marcelarubio28@gmail.com
�ltima modificaci�n: Daniela Zuluaga (DZ) E-mail: danielazu@iadb.org, da.zuluaga@hotmail.com
Fecha �ltima modificaci�n: Octubre de 2017

							SCL/SCL - IADB
****************************************************************************/
/***************************************************************************
Detalle de procesamientos o modificaciones anteriores:

****************************************************************************/

use `base_in', clear

/************************************************************************/
/*				VARIABLES DEL HOGAR			*/
/************************************************************************/


gen region_c = dpto
label define region_c  1 "Montevideo" ///
           2 "Artigas" /// 
           3 "Canelones" /// 
           4 "Cerro Largo" /// 
           5 "Colonia" /// 
           6 "Durazno" /// 
           7 "Flores" /// 
           8 "Florida" /// 
           9 "Lavalleja" /// 
          10 "Maldonado" /// 
          11 "Paysand�" /// 
          12 "R�o Negro" /// 
          13 "Rivera" /// 
          14 "Rocha" /// 
          15 "Salto" /// 
          16 "San Jos�" /// 
          17 "Soriano" /// 
          18 "Tacuaremb�" ///
          19 "Treinta y Tres" 
label value region_c region_c

****************
* region_BID_c *
****************
gen region_BID_c=.
replace region_BID_c=4 
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

*1. Factor de expansi�n del hogar: 
gen factor_ch=pesoano

*2. Identificador del hogar
gen idh_ch=numero
destring idh_ch, replace
format idh_ch %13.0g

*3. Identificador de persona
gen idp_ci=nper

*4. Zona urbana versus rural

/*Mayra S�enz - Noviembre 2013: 
A partir de 2006 se incluye una muestra rural, sin embargo en 2006-2009 s�lo se desagregan 3 categor�as:
 (1) montevideo, (2) Interior con m�s de 5000 habitantes, y (3) interior con menos de 5000 habitantes y rural. 
 En cambio, en 2010 se desagregan 4 categor�as: (1) montevideo, (2) Interior con m�s de 5000 habitantes, 
 (3) interior con menos de 5000 habitantes y (4) rural. 
 Por lo tanto, para hacer comparables los datos se genera la variable zona considerando a las zonas de
 menos de 5000 habitantes como rural. Es decir, zona rural=interior con menos de 5000 habitantes y rural.*/
 
gen zona_c=.
replace zona_c=1 if region_4 == 1 | region_4 == 2
replace zona_c=0 if region_4 == 3 | region_4 == 4

label variable zona_c "Zona del pais"
label define zona_c 1 "Urbana" 0 "Rural"
label value zona_c zona_c

*5. Pa�s
gen str3 pais_c="URY"

*6. Anio de la encuesta
gen anio_c=2015
label variable anio_c "Anio de la encuesta" 

*7. Mes de la encuesta
destring mes, replace
gen mes_c=mes

*8. Relaci�n o parentesco con el jefe de hogar
/*

e30:
           1 Jefe/a 
           2 Esposo/a o compa�ero/a 
           3 Hijo/a de ambos 
           4 Hijo/a solo del jefe/a 
           5 Hijo/a solo del esposo/a compa�ero/a 
           6 Yerno/nuera 
           7 Padre/madre 
           8 Suegro/a 
           9 Hermano/a 
          10 Cu�ado/a 
          11 Nieto/a 
          12 Otro pariente 
          13 Otro no pariente 
          14 Servicio dom�stico o familiar del mismo

*/

gen relacion_ci=.
replace relacion_ci=1 if e30==1
replace relacion_ci=2 if e30==2
replace relacion_ci=3 if e30==4 | e30==5 | e30==3
replace relacion_ci=4 if e30>=6 & e30<=12
replace relacion_ci=5 if e30==13
replace relacion_ci=6 if e30==14
label define relacion_ci 1 "Jefe" 2 "Conyuge" 3 "Hijo" 4 "Otros Parientes" 5 "Otros no Parientes" 6 "Servicio Domestico"
label values relacion_ci relacion_ci

*9. Factor de expansi�n a nivel individual

gen factor_ci=pesoano 


*10. Sexo

/*
e26	1	Hombre
	2	Mujer
*/

gen sexo_ci=e26
label var sexo_ci "Sexo del Individuo"
label define sexo_ci 1 "Hombre" 2 "Mujer"
label value sexo_ci sexo_ci

*11. Edad

/*
e27	A�os	A�os cumplidos
*/

gen edad_ci=e27
label var edad_ci "Edad del Individuo"


*12. Estado civil 

/*
ESTADO CIVIL ACTUAL	e36	
e36:
           1 Separado / a de uni�n libre anterior 
           2 Divorciado / a 
           3 Casado / a. Incluye separado /a y a�n 
> no se divorci�. 
           4 Viudo / a de casamiento 
           5 Soltero / a
           6 Viudo /  de uni�n libre




gen civil_ci=1 		if e36==6
replace civil_ci=2 	if e36==3
replace civil_ci=3 	if e36==1 | e36==2
replace civil_ci=4 	if e36==4 | e36==5

label var civil_ci "Estado Civil"
label define civil_ci 1 "Soltero" 2 "Union Formal o Informal" 3 "Divorciado o Separado" 4 "Viudo"
label value civil_ci civil_ci
*/

*Modificado por SCGR - Abril 2017
*Unión formal o informal*
gen civil_ci=2 		if e33==1
replace civil_ci=1  if e36==5 & e33==2
replace civil_ci=3  if (e36==1 | e36==2 | e36==3) & e33==2
replace civil_ci=4 	if (e36==4 | e36==6) & e33==2

label var civil_ci "Estado Civil"
label define civil_ci 1 "Soltero" 2 "Union Formal o Informal" 3 "Divorciado o Separado" 4 "Viudo"
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
replace clasehog_ch=3 if ((clasehog_ch ==2 & notropari_ch>0) & notronopari_ch==0) |(notropari_ch>0 & notronopari_ch==0)  
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

gen miembros_ci=(relacion_ci<5)
label variable miembros_ci "Miembro del hogar" 

**********
***raza***
**********
/*gen raza_ci= .
replace raza_ci = 1 if e29_4==1
replace raza_ci = 2 if e29_1==1
replace raza_ci = 3 if e29_2==1 | e29_3==1 | e29_5==1 | raza_ci ==.

label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 
*/
*Modificaci�n Mayra S�enz 10/20/2015: modificaciones realizadas en base a metodolog�a enviada por SCL/GDI Maria Olga Pe�a

gen raza_ci= .
replace raza_ci=1 if e29_6==4
replace raza_ci=2 if e29_6==1
replace raza_ci=3 if raza_ci== .

label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 

gen raza_idioma_ci=.

*NOTE: HERE WE DOUBLE COUNT ACROSS POPULATIONS. There could be a case in which
*someone said that he or she is indigenous and afro-d. We are counting that person
*both in the indigenous and afro dummies to measure statistics WITHIN each population
*However, if we want to sum every population up to 100%, we should use raza_ci instead

*This will apply for the following years as well

gen id_ind_ci = 0
replace id_ind_ci=1 if e29_4==1
label define id_ind_ci 1 "Ind�gena" 0 "Otros" 
label value id_ind_ci id_ind_ci 
label var id_ind_ci  "Indigena" 

gen id_afro_ci = 0
replace id_afro_ci=1 if e29_1==1
label define id_afro_ci 1 "Afro-descendiente" 0 "Otros" 
label value id_afro_ci id_afro_ci 
label var id_afro_ci "Afro-descendiente" 

*****************************************************************************************
*  VARIABLES DE MERCADO LABORAL
*****************************************************************************************


****************
****condocup_ci*
****************
gen condocup_ci=.
*replace condocup_ci=1 if f66==1  | f67==1 | f68==1 
replace condocup_ci=1 if f66==1  | f67==1 | (f68==1  & f69!=.) /* MLO, 2015,11 : se incluye condicion que no trabajo por razones extraordinarias*/
*replace condocup_ci=2 if f106==1 & [(f110>=1 & f110<=6) | ((f108>=1 & f108<=3) & (f110>=1 & f110<=6))]
*replace condocup_ci=2 if [f106==1 & (f107==1 | f109==1) & (f110>=1 & f110<=6)] | (f106==1 &(f108==2 & f108==3)) /* asi lo define el INE*/
replace condocup_ci=2 if f106==1 & f107==1 & (f110>=1 & f110<=6) /* SGR, Modificado Mayo 2017 */
replace condocup_ci=2 if f106==1 & f107==2 & ((f108==2 | f108==3) | ((f108==1 | f108==4 | f108==5 | f108==6) & f109==1 & (f110>=1 & f110<=6))) /* SGR, Modificado Mayo 2017 */
replace condocup_ci=3 if condocup_ci!=1 & condocup_ci!=2
replace condocup_ci=4 if edad_ci<14
label define condocup_ci 1"ocupados" 2"desocupados" 3"inactivos" 4"menor que 14"
label value condocup_ci condocup_ci
label var condocup_ci "Condicion de ocupacion utilizando definicion del pais"

************
***emp_ci***
************

gen byte emp_ci=(condocup_ci==1)

****************
***desemp_ci****
****************

gen desemp_ci=(condocup_ci==2)

*************
***pea_ci****
*************
gen pea_ci=0
replace pea_ci=1 if emp_ci==1 |desemp_ci==1

*********
*lp_ci***
*********

gen lp_ci =.
replace lp_ci = 7312 if mes==1 & region_3==1
replace lp_ci = 7597 if mes==2 & region_3==1
replace lp_ci = 7701 if mes==3 & region_3==1
replace lp_ci = 7742 if mes==4 & region_3==1
replace lp_ci = 7787 if mes==5 & region_3==1
replace lp_ci = 7827 if mes==6 & region_3==1
replace lp_ci = 7868 if mes==7 & region_3==1
replace lp_ci = 7928 if mes==8 & region_3==1
replace lp_ci = 8003 if mes==9 & region_3==1
replace lp_ci = 8066 if mes==10 & region_3==1
replace lp_ci = 8121 if mes==11 & region_3==1
replace lp_ci = 8162 if mes==12 & region_3==1


replace lp_ci = 4120  if mes==1 & region_3==2
replace lp_ci = 4352  if mes==2 & region_3==2
replace lp_ci = 4402  if mes==3 & region_3==2
replace lp_ci = 4428  if mes==4 & region_3==2
replace lp_ci = 4456  if mes==5 & region_3==2
replace lp_ci = 4473  if mes==6 & region_3==2
replace lp_ci = 4496  if mes==7 & region_3==2
replace lp_ci = 4518  if mes==8 & region_3==2
replace lp_ci = 4558  if mes==9 & region_3==2
replace lp_ci = 4576  if mes==10 & region_3==2
replace lp_ci = 4615  if mes==11 & region_3==2
replace lp_ci = 4634  if mes==12 & region_3==2


replace lp_ci = 2296  if mes==1 & region_3==3
replace lp_ci = 2375  if mes==2 & region_3==3
replace lp_ci = 2396  if mes==3 & region_3==3
replace lp_ci = 2415  if mes==4 & region_3==3
replace lp_ci = 2434  if mes==5 & region_3==3
replace lp_ci = 2444  if mes==6 & region_3==3
replace lp_ci = 2458  if mes==7 & region_3==3
replace lp_ci = 2472  if mes==8 & region_3==3
replace lp_ci = 2499  if mes==9 & region_3==3
replace lp_ci = 2511  if mes==10 & region_3==3
replace lp_ci = 2537  if mes==11 & region_3==3
replace lp_ci = 2545  if mes==12 & region_3==3

label var lp_ci "Linea de pobreza oficial del pais"

*********
*lpe_ci***
*********
gen lpe_ci =.
replace lpe_ci = 2556  if mes==1 & region_3==1
replace lpe_ci = 2584  if mes==2 & region_3==1
replace lpe_ci = 2605  if mes==3 & region_3==1
replace lpe_ci = 2626  if mes==4 & region_3==1
replace lpe_ci = 2632  if mes==5 & region_3==1
replace lpe_ci = 2651  if mes==6 & region_3==1
replace lpe_ci = 2656  if mes==7 & region_3==1
replace lpe_ci = 2705  if mes==8 & region_3==1
replace lpe_ci = 2739  if mes==9 & region_3==1
replace lpe_ci = 2769  if mes==10 & region_3==1
replace lpe_ci = 2777  if mes==11 & region_3==1
replace lpe_ci = 2784  if mes==12 & region_3==1

replace lpe_ci = 2382  if mes==1 & region_3==2
replace lpe_ci = 2418  if mes==2 & region_3==2
replace lpe_ci = 2437  if mes==3 & region_3==2
replace lpe_ci = 2454  if mes==4 & region_3==2
replace lpe_ci = 2464  if mes==5 & region_3==2
replace lpe_ci = 2476  if mes==6 & region_3==2
replace lpe_ci = 2475  if mes==7 & region_3==2
replace lpe_ci = 2513  if mes==8 & region_3==2
replace lpe_ci = 2561  if mes==9 & region_3==2
replace lpe_ci = 2581  if mes==10 & region_3==2
replace lpe_ci = 2573  if mes==11 & region_3==2
replace lpe_ci = 2586  if mes==12 & region_3==2

replace lpe_ci = 2153  if mes==1 & region_3==3
replace lpe_ci = 2187  if mes==2 & region_3==3
replace lpe_ci = 2206  if mes==3 & region_3==3
replace lpe_ci = 2222  if mes==4 & region_3==3
replace lpe_ci = 2231  if mes==5 & region_3==3
replace lpe_ci = 2241  if mes==6 & region_3==3
replace lpe_ci = 2239  if mes==7 & region_3==3
replace lpe_ci = 2274  if mes==8 & region_3==3
replace lpe_ci = 2317  if mes==9 & region_3==3
replace lpe_ci = 2336  if mes==10 & region_3==3
replace lpe_ci = 2327  if mes==11 & region_3==3
replace lpe_ci = 2338  if mes==12 & region_3==3

label var lpe_ci "Linea de indigencia oficial del pais"


/************************************************************************************************************
* 3. Creaci�n de nuevas variables de SS and LMK a incorporar en Armonizadas
************************************************************************************************************/

****************
*cotizando_ci***
****************
gen cotizando_ci=0 if condocup_ci==1 | condocup_ci==2
replace cotizando_ci=1 if (f82==1 | f96==1) & cotizando_ci==0
label var cotizando_ci "Cotizante a la Seguridad Social"

* Formalidad sin restringir a PEA
gen cotizando_ci1=0 if condocup_ci>=1 & condocup_ci<=3
replace cotizando_ci1=1 if (f82==1 | f96==1) & cotizando_ci1==0
label var cotizando_ci1 "Cotizante a la Seguridad Social"


gen cotizapri_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizapri_ci=1 if (f82==1) & cotizando_ci==0 
label var cotizapri_ci "Cotizante a la Seguridad Social por su trabajo principal"

gen cotizasec_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizasec_ci=1 if (f96==1) & cotizando_ci==0 
label var cotizasec_ci "Cotizante a la Seguridad Social por su trabajo secundario"

****************
*afiliado_ci****
****************
gen msp =.
replace msp =1 if (e45_1_1==1) &  e45_1==1
replace msp =0 if (e45_1_1==2) |  e45_1==2

gen iamc=.
replace iamc=1 if (e45_2_1==1) &  e45_2==1
replace iamc=0 if (e45_2_1==2) |  e45_2==2

gen spm =.
replace spm =1 if (e45_3_1==1) & e45_3==1
replace spm =0 if (e45_3_1>=2 & e45_3_1<=3) | e45_3==2

gen hpm =.
replace hpm=1 if e45_4==1
replace hpm=0 if e45_4==2

gen bps=.
replace bps=1 if e45_5==1
replace bps=0 if e45_5==2

gen afiliado_ci=(msp==1 | iamc==1 | spm==1 | hpm==1 | bps==1)
replace afiliado_ci=. if msp==. & iamc==. & spm==. & hpm==. & bps==.
label var afiliado_ci "Afiliado a la Seguridad Social"
drop msp iamc spm hpm bps
*Nota: seguridad social comprende solo los que en el futuro me ofrecen una pension.

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


********************
*** instcot_ci *****
********************

gen instcot_ci=f83
replace instcot_ci=. if instcot_ci==0
label define  instcot_ci 1"bps" 2"bps y afap" 3"policial" 4"militar" 5"profesional" 6 "notarial" 7"bancaria" 8"en el exterior"
label value instcot_ci instcot_ci
label var instcot_ci "instituci�n a la cual cotiza por su trabajo"


*****************
*tipocontrato_ci*
*****************

gen tipocontrato_ci=. /* No preguntan*/
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci

*************
*cesante_ci* 
*************
gen cesante_ci=1 if f116==1 & condocup_ci==2
replace cesante_ci=0 if f116==2 & condocup_ci==2
label var cesante_ci "Desocupado - definicion oficial del pais"	

*************
**pension_ci*
*************

egen aux1=rowtotal(g148_1_1 g148_1_2 g148_1_3 g148_1_4 g148_1_5 g148_1_6 g148_1_7 g148_1_8 g148_1_9), mis /*Se excluyen pensiones recibidas del exterior*/
egen aux2=rowtotal(g148_2_1 g148_2_2 g148_2_3 g148_2_4 g148_2_5 g148_2_6 g148_2_7 g148_2_8 g148_2_9), mis /*Se excluyen pensiones recibidas del exterior*/

* MGR, Aug 2015: correci�n en sint�xis, se generaba como el 100%
egen ypension = rowtotal(aux1 aux2), missing

gen pension_ci= (ypension>0 & ypension!=.)
label var pension_ci "1=Recibe pension contributiva"

*************
*ypen_ci*
*************


* Cambio MGD 07/2015:mal generada, hay que sumar
recode aux1 aux2 (0=.)
egen 	ypen_ci=rsum(aux1 aux2),m
replace ypen_ci=. if pension_ci==0
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************

/*DZ Octubre 2017- Se crea variable pension subsidiada* Dado que la pregunta es excluyente y el programa de pensi�n subsidiada en Uruguay es para Adultos mayores y/o discapacitados
se pone la condicion de mayor de 70 a�os (edad para recivir el beneficio) en las personas que afirmaron tener pension por invalidez*/
gen pensionsub_ci= ((f125==1) | (f125==3 & edad_ci>69))
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**ypensub_ci*
*****************

gen ypensub_ci=.
*replace ypensub_ci=. if edad_ci<65 | pensionsub_ci==0
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

*************
**salmm_ci***
*************
*http://presidencia.gub.uy/comunicacion/comunicacionnoticias/suledo-minimo
gen salmm_ci=10000
label var salmm_ci "Salario minimo legal"

*****************
***desalent_ci***
*****************
* Se utiliza la pregunta Razones por las cuales no busc� o no estableci� su negocio f108 (Busc� antes, no encontr� y dej� de buscar)
gen desalent_ci=(emp_ci==0 & f108==4 )
replace desalent_ci=. if emp_ci==.

*27. Horas totales trabajadas en la actividad principal

gen horaspri_ci=f85
replace horaspri_ci=. if f85==99 | emp_ci==0

*28. Horas totales trabajadas en todas las actividades

gen horastot_ci=f85+f98

*64. Trabajadores sub-empleados: personas dispuestas a trabajar m�s pero trabajan 30 horas a la semana o menos

* Modificacion MGD 06/23/2014: horas de la actividad principaln y considerando disponibilidad (subempleo visible).
gen subemp_ci=0
replace subemp_ci=1 if (horaspri_ci>=1 & horaspri_ci<=30) & (f102==1 & f103==1)


*65. Trabajadores a medio tiempo: personas que trabajan menos de 30 horas a la semana y no quieren trabajar m�s
*gen tiempoparc_ci=(horastot_ci>=1 & horastot_ci<=30 & f102==2)
gen tiempoparc_ci=(horaspri_ci>=1 & horaspri_ci<30 & f102==2)
replace tiempoparc_ci=. if emp_ci==0

*66. Categor�a ocupacional en la actividad principal

/*
f73	1	Asalariado/a privado/a
	2	Asalariado/a p�blico/a
	3	Miembro de cooperativa de producci�n
	4	Patr�n/a
	5	Cuenta propia sin local ni inversi�n
	6	Cuenta propia con local o inversi�n
	7	Miembro del hogar no remunerado
	8	Trabajador/a de un programa social de empleo

*/

gen categopri_ci=1 	if f73==4
replace categopri_ci=2 	if f73==5 | f73==6 | f73==3
replace categopri_ci=3 	if f73==1 | f73==2 | f73==8
replace categopri_ci=4 	if f73==7 
replace categopri_ci=. 	if emp_ci!=1
/*
*Modificaci�n MLO
replace categopri_ci=0 if f73==8 & condocup_ci==1
*/
label define categopri_ci 1"Patron" 2"Cuenta propia" 
label define categopri_ci 3"Empleado" 4"No remunerado", add
label value categopri_ci categopri_ci
label variable categopri_ci "Categoria ocupacional trabajo principal"

*67. Categor�a ocupacional en la actividad secundaria

/*
f92	1	Asalariado/a privado/a
	2	Asalariado/a p�blico/a
	3	Miembro de cooperativa de producci�n
	4	Patr�n/a
	5	Cuenta propia sin local ni inversi�n
	6	Cuenta propia con local o inversi�n
	7	Miembro del hogar no remunerado

*/

gen categosec_ci=1 if f92==4
replace categosec_ci=2 if f92==5 | f92==6 | f92==3
replace categosec_ci=3 if f92==1 | f92==2 | f92==8
replace categosec_ci=4 if f92==7 
label define categosec_ci 1"Patron" 2"Cuenta propia" 
label define categosec_ci 3"Empleado" 4" No remunerado", add
label value categosec_ci categosec_ci
label variable categosec_ci "Categoria ocupacional trabajo principal"


*70. N�mero de empleos

gen nempleos_ci=1 if f70==1
replace nempleos_ci=2 if f70>1 & f70!=.

*71. Trabajadores formales

/*
TAMA�O  DE LA EMPRESA 	f77
				1	Una persona
				2	2 a 4 personas
				3	5 a 9 personas
				4	10 a 49  personas
				5	50 o m�s personas
*/

*72. Personas que trabajan en el sector p�blico

gen spublico_ci=(emp_ci==1 & f73==2)
replace spublico =. if emp_ci==.

* Modificacion MGD 07/15/2014: mal generada la variable, se dejaban de  lado categorias.
*Genera la variable para empresas peque�as
gen tamemp_ci=1 if f77==1 | f77==2 
label var  tamemp_ci "Tama�o de Empresa" 
*Empresas medianas
replace tamemp_ci=2 if f77==3 | f77==6 | f77==7
*Empresas grandes
replace tamemp_ci=3 if f77==5
label define tama�o 1"Peque�a" 2"Mediana" 3"Grande"
label values tamemp_ci tama�o
tab tamemp_ci [iw=pesoano]

*Genera la variable para clasificar a los inactivos
*Jubilados y pensionados
gen categoinac_ci=1 if f124_1==1 | f124_2==1
label var  categoinac_ci "Condici�n de Inactividad" 
*Estudiantes
replace categoinac_ci=2 if f124_4==1
*Quehaceres del Hogar
replace categoinac_ci=3 if f124_5==1
*Otra razon
replace categoinac_ci=4 if f124_3==1 
label define inactivo 1"Pensionado" 2"Estudiante" 3"Hogar" 4"Otros"
label values categoinac_ci inactivo
tab categoinac_ci [iw=pesoano]


*******************
***formal***
*******************

gen byte formal_ci=(cotizando_ci==1)
label var formal_ci "1=afiliado o cotizante / PEA"

* Formalidad sin restringir a PEA
gen byte formal_1=(cotizando_ci1==1)


*25. Ocupaci�n laboral actividad principal *** 

* Modificacion MGD 07/15/2014: mal clasificado, se usa la CIUO-08.
destring f71_2, replace

gen ocupa_ci=.
replace ocupa_ci=1 if (f71_2>=2111 & f71_2<=3522) & emp_ci==1
replace ocupa_ci=2 if (f71_2>=1111 & f71_2<=1439) & emp_ci==1
replace ocupa_ci=3 if (f71_2>=4110 & f71_2<=4419 | f71_2>=410 & f71_2<=430) & emp_ci==1
replace ocupa_ci=4 if ((f71_2>=5211 & f71_2<=5249) | (f71_2>=9510 & f71_2<=9520)) & emp_ci==1
replace ocupa_ci=5 if ((f71_2>=5111 & f71_2<=5169) | (f71_2>=5311 & f71_2<=5419) | (f71_2>=9111 & f71_2<=9129) | (f71_2>=9611 & f71_2<=9624) ) & emp_ci==1 /*Aunque no esta desagregado en la base, esta es la desagregaci�n a tres digitos de la CIUO-88*/
replace ocupa_ci=6 if ((f71_2>=6111 & f71_2<=6340) | (f71_2>=9211 & f71_2<=9216)) & emp_ci==1
replace ocupa_ci=7 if ((f71_2>=7111 & f71_2<=8350) | (f71_2>=9311 & f71_2<=9412)) & emp_ci==1 /*Incluye artesanos y operarios en hilanderias*/
replace ocupa_ci=8 if (f71_2>=110 & f71_2<=310) & emp_ci==1
replace ocupa_ci=9 if (f71_2==9629) & emp_ci==1

label variable ocupa_ci "Ocupacion laboral"
label define ocupa_ci 1"Profesional y tecnico" 2"Director o funcionario sup" 3"Administrativo y nivel intermedio"
label define ocupa_ci  4 "Comerciantes y vendedores" 5 "En servicios" 6 "Trabajadores agricolas", add
label define ocupa_ci  7 "Obreros no agricolas, conductores de maq y ss de transporte", add
label define ocupa_ci  8 "FFAA" 9 "Otras ", add
label value ocupa_ci ocupa_ci


*26. Rama laboral de la actividad principal   
/*
destring f72_2, replace force
recode f72_2 (0000/0400=1 "Agricultura, caza, silvicultura y pesca") (0500/1000=2 "Explotaci�n de minas y canteras") (1010/3400=3 "Industrias manufactureras") /*
*/ (3500/4000=4 "Electricidad, gas y agua") (4100/4400=5 "Construcci�n") (4400/4800=6 "Comercio, restaurantes y hoteles") /*
*/ (4900/6400=7 "Transporte y almacenamiento") (6410/8300=8 "Establecimientos financieros, seguros e inmuebles") /*
*/ (8400/9900=9 "Servicios sociales y comunales"),gen(rama_ci)
replace rama_ci=. if condocup_ci !=1
*/
destring f72_2, replace
gen rama_ci=.
replace rama_ci=1 if (f72_2>0 & f72_2<=400) & emp_ci==1
replace rama_ci=2 if (f72_2>=500 & f72_2<=1000) & emp_ci==1
replace rama_ci=3 if (f72_2>=1010 & f72_2<=3400) & emp_ci==1
replace rama_ci=4 if (f72_2>=3500 & f72_2<=4000) & emp_ci==1
replace rama_ci=5 if (f72_2>=4100 & f72_2<=4400) & emp_ci==1
replace rama_ci=6 if ((f72_2>=4500 & f72_2<=4800) | (f72_2>=5500 & f72_2<=5700))& emp_ci==1
replace rama_ci=7 if ((f72_2>=4900 & f72_2<=5400) | (f72_2>=6100 & f72_2<=6199)) & emp_ci==1
replace rama_ci=8 if (f72_2>=6400 & f72_2<=8300) & emp_ci==1
replace rama_ci=9 if ((f72_2>=5800 & f72_2<=6090) | (f72_2>=6200 & f72_2<=6399) | (f72_2>=8400 & f72_2<=9900))& emp_ci==1

*55a. Duraci�n del desempleo

gen durades_ci=f113/4.3 if f113>0
replace durades_ci=. if f116==99

*****************
**antiguedad_ci**
*****************
*Modificaci�n MLO
gen antigenanio=(f88_1/12)
egen antiguedad_ci=rowtotal(antigenanio  f88_2)
recode antiguedad_ci 0=. if condocup_ci !=1
	
*********************************************************************************************************
*                                       INGRESOS                                                        *
*********************************************************************************************************

*29. Ingreso laboral monetario actividad principal

/* Relacion de Dependencia
SUELDO O JORNALES L�QUIDOS	                            g126_1		
COMISIONES, INCENTIVOS, HORAS EXTRAS, HABILITACIONES	g126_2	
VI�TICOS NO SUJETOS A RENDICI�N	                        g126_3	
PROPINAS	                                            g126_4	
AGUINALDO	                                            g126_5	
SALARIO VACACIONAL	                                    g126_6	
PAGOS ATRASADOS	                                        g126_7	

Cuenta propia
DISTRIBUCI�N DE UTILIDADES	g143	$	

INGRESO POR MEDIANER�A O APARCER�A	g145	$	
INGRESO POR PASTOREO	g146	$	
INGRESO POR GANADO A CAPITALIZACI�N	g147	$	

Trabajador agropecuario
* �Cu�nto dinero gan� por la venta de esos productos en los �ltimos 12 meses? 
RETIRO REALIZADO PARA GASTOS DEL HOGAR	g142	$
*/

gen g143_ = g143/12
gen g145_ = g145/12
gen g146_ = g146/12
gen g147_ = g147/12

egen ylmpri_ci=rsum(g126_1 g126_2  g126_3  g126_4  g126_5  g126_6  g126_7  g142 g143_ g145_ g146_ g147_ g133_2) if emp_ci==1 , missing
replace ylmpri_ci=. if (g126_1==. & g126_2==. & g126_3==. &  g126_4==. &  g126_5==. &  g126_6==. &  g126_7==. &  g143_==. & g145_==. & g146_==. & g147_==.)

* Nota Marcela G. Rubio - Abril 2014
* Se filtra ingreso s�lo para las personas ocupadas emp_ci==1

*****************
***nrylmpri_ci***
*****************
g nrylmpri_ci=(ylmpri_ci==. & emp_ci==1)
replace nrylmpri_ci=. if emp_ci!=1 | categopri_ci==4 /*excluding unpaid workers*/
label var nrylmpri_ci "Id no respuesta ingreso de la actividad principal" 

*30. Ingreso laboral no monetario actividad principal
*BOLETOS DE TRANSPORTE	                                g126_8	
*Alimentos g127_3
*Tickets de alimentacion g128_1
*Vivienda o alojamiento g129_2
* Otra retribuci�n en especie g130_1
* Otro tipo de complemento pagado por el empleador g131_1
*Principal: �Cu�nto hubiera tenido que pagar por esos productos que consumi� el mes pasado? g133_1
/*
	

RETIRO DE PRODUCTOS PARA CONSUMO PROPIO (trabajador no agropecuario)	g144_1	$	Monto que habr�a tenido que pagar por esos bienes
RETIRO DE PRODUCTOS PARA CONSUMO PROPIO (trabajador agropecuario)	
    g144_2_1	$	Valor de lo consumido en carnes o chacinados
	g144_2_2	$	Valor de lo consumido en l�cteos
	g144_2_3	$	Valor de lo consumido en huevos y aves
	g144_2_4	$	Valor de lo consumido en productos de la huerta
	g144_2_5	$	Valor consumido en otros alimentos


g127_1	N�	Cantidad de desayunos / meriendas
g127_2	N�	Cantidad de almuerzos / cenas
g127_3	$	Otros - Monto estimado
*/


gen desay=(g127_1*mto_desay)
gen almue= (g127_2*mto_almue)
*gen cuota = En este a�o no se pregunta acerca de la cuota mutual.
/*
DERECHO A PASTOREO	g132_1	N�	Vacunos
DERECHO A PASTOREO	g132_2	N�	Ovinos
DERECHO A PASTOREO	g132_3	N�	Equinos
*/


gen vacas = (g132_1*mto_vacas)
gen oveja = (g132_2*mto_oveja)
gen caballo = (g132_3*mto_caball)

*No costa la variable disse en el formulario.

egen ylnmpri_ci= rsum( desay almue vacas oveja caballo g126_8 g127_3  g128_1 g129_2 g130_1 g131_1 g133_1 g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5 ) if emp_ci==1, missing

* Nota Marcela G. Rubio - Abril 2014
* Se filtra ingreso s�lo para las personas ocupadas emp_ci==1

*31. Ingreso Laboral Monetario actividad secundaria
/*
SUELDO O JORNALES L�QUIDOS	g134_1	
COMISIONES, INCENTIVOS, HORAS EXTRAS, HABILITACIONES	g134_2	
VI�TICOS NO SUJETOS A RENDICI�N	g134_3	
PROPINAS	g134_4	
AGUINALDO	g134_5	
SALARIO VACACIONAL	g134_6	
PAGOS ATRASADOS	g134_7	
DERECHO A CULTIVO PARA CONSUMO PROPIO g141_2	$	Monto percibido por la venta de esos productos
*/
egen ylmsec_ci=rsum(g134_1 g134_2  g134_3  g134_4  g134_5  g134_6  g134_7 g141_2) if emp_ci == 1, missing 

* Nota Marcela G. Rubio - Abril 2014
* Se filtra ingreso s�lo para las personas ocupadas emp_ci==1

*32. Ingreso laboral no monetario actividad secundaria
/*
BOLETOS DE TRANSPORTE	g134_8	
COMIDAS Y MERIENDAS	g135_3	
TIQUES DE ALIMENTACI�N	g136_1	
RECIBI� VIVIENDA O ALOJAMIENTO	g137_2	
RECIBI� OTRO TIPO DE RETRIBUCI�N EN ESPECIE	g138_1	
RECIBI� ALG�N OTRO TIPO DE COMPLEMENTO PAGADO POR EL EMPLEADOR	g139_1	$	Monto estimado

*/

**Secundaria: DERECHO A CULTIVO PARA CONSUMO PROPIO g141_1	$	Monto que habr�a tenido que pagar por esos productos
/*RECIBI� ALIMENTOS O BEBIDAS	g135_1	N�	N�mero de desayunos / meriendas
RECIBI� ALIMENTOS O BEBIDAS	g135_2	N�	N�mero de almuerzos / cenas
DERECHO A PASTOREO	g140_1	N�	Vacunos
DERECHO A PASTOREO	g140_2	N�	Ovinos
DERECHO A PASTOREO	g140_3	N�	Equinos
*/

gen desaysec=(g135_1*mto_desay)
gen almuesec= (g135_2*mto_almue)
*gen cuota = En este a�o no se pregunta acerca de la cuota mutual.

gen vacassec = (g140_1*mto_vacas)
gen ovejasec = (g140_2*mto_oveja)
gen caballosec = (g140_3*mto_caball)

egen ylnmsec_ci=rsum(desaysec almuesec vacassec ovejasec caballosec g134_8 g135_3 g136_1 g137_2 g138_1 g139_1 g141_1) if emp_ci ==1, missing

* Nota Marcela G. Rubio - Abril 2014
* Se filtra ingreso s�lo para las personas ocupadas emp_ci==1

*33. Ingreso laboral monetario otros trabajos

egen ylmotros_ci=rsum(g126_1 g126_2  g126_3  g126_4  g126_5  g126_6  g126_7  g142 g143_ g145_ g146_ g147_ g133_2 g134_1 g134_2  g134_3  g134_4  g134_5  g134_6  g134_7 g141_2) if emp_ci==0 , missing

* Nota Marcela G. Rubio - Abril 2014
* estimo variable ingreso laboral monetario otros trabajos para todos los a�os

*34. Ingreso laboral no monetario otros trabajos

egen ylnmotros_ci=rsum( desay almue vacas oveja caballo g126_8 g127_3  g128_1 g129_2 g130_1 g131_1 g133_1 g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5 desaysec almuesec vacassec ovejasec caballosec g134_8 g135_3 g136_1 g137_2 g138_1 g139_1 g141_1) if emp_ci==0, missing

* Nota Marcela G. Rubio - Abril 2014
* estimo variable ingreso laboral no monetario otros trabajos para todos los a�os

*35. Identificador de No respuesta (NR) del ingreso de la actividad principal

gen nrylmpri=.

*36. Identificador del top-code del ingreso de la actividad principal

gen tcylmpri_ci=.

****************
*** ynlnm_ch ***
****************

gen ynlnm_ch=.

*37. Ingreso laboral monetario total

egen ylm_ci=rsum(ylmpri_ci ylmsec_ci ylmotros_ci) 
replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==. & ylmotros_ci==.

* Nota Marcela G. Rubio - Abril 2014
* Incluyo ingreso laboral monetario otros como parte del ingreso laboral monetario total ya que no hab�a sido incluido

*38. Ingreso laboral no monetario total

egen ylnm_ci=rsum(ylnmpri_ci ylnmsec_ci ylnmotros_ci) 
replace ylnm_ci=. if ylnmpri_ci==. & ylnmsec_ci==. & ylnmotros_ci==.

* Nota Marcela G. Rubio - Abril 2014
* Incluyo ingreso laboral no monetario otros como parte del ingreso laboral no monetario total ya que no hab�a sido incluido

*39. Ingreso no laboral monetario (otras fuentes)
/*
Recibi� el mes pasado por JUBILACIONES:			
BPS - CAJA INDUSTRIA Y COMERCIO	g148_1_1	$	
BPS - CAJA CIVIL Y ESCOLAR	g148_1_2	$	
BPS - RURAL Y SERVICIO DOM�STICO	g148_1_3	$	
UNI�N POSTAL	g148_1_4	$	
POLICIAL	g148_1_5	$	
MILITAR	g148_1_6	$	
PROFESIONAL	g148_1_7	$	
NOTARIAL	g148_1_8	$	
BANCARIA	g148_1_9	$	
AFAP (ingresos provenientes �nicamente de alguna AFAP)	g148_1_12	$	
OTRA 	g148_1_10	$	
OTRO PA�S	g148_1_11	$	
Recibi� el mes pasado por PENSIONES:			
BPS - CAJA INDUSTRIA Y COMERCIO	g148_2_1	$	
BPS - CAJA CIVIL Y ESCOLAR	g148_2_2	$	
BPS - RURAL Y SERVICIO DOM�STICO	g148_2_3	$	
UNI�N POSTAL	g148_2_4	$	
POLICIAL	g148_2_5	$	
MILITAR	g148_2_6	$	
PROFESIONAL	g148_2_7	$	
NOTARIAL	g148_2_8	$	
BANCARIA	g148_2_9	$	
AFAP (ingresos provenientes �nicamente de alguna AFAP)	g148_2_12	$	
OTRA 	g148_2_10	$	
OTRO PA�S	g148_2_11	$	
SEGURO DE DESEMPLEO	g148_3	$	
COMPENSACIONES POR ACCIDENTE, MATERNIDAD O ENFERMEDAD	g148_4	$	
BECAS, SUBSIDIOS, DONACIONES	g148_5_1	$	Del pa�s
	g148_5_2	$	Del extranjero

RECIBE PENSI�N ALIMENTICIA O ALGUNA CONTRIBUCI�N POR DIVORCIO O SEPARACI�N		
	g153_1	$	Del pa�s
	g153_2	$	Del extranjero
G4 OTROS INGRESOS			
	g154_1	$	Monto que cobr� el mes pasado


RECIBE DINERO DE ALG�N FAMILIAR U OTRO HOGAR EN EL PA�S	h155_1	$
TARJETA ALIMENTARIA DE INDA/MIDES	h157_1	$


* Variables anuales	a nivel de hogar		
	FUERON ALQUILADAS 	h160_1	$	Alquileres del pa�s
	FUERON ALQUILADAS 	h160_2	$	Alquileres del extranjero
	RECIBI� POR ARRENDAMIENTO	h163_1	$	Arrendamientos del pa�s
	RECIBI� POR ARRENDAMIENTO	h163_2	$	Arrendamientos del extranjero
	RECIBI� POR MEDIANER�A	h164	$	
	RECIBI� POR PASTOREO	h165	$	
	RECIBI� POR GANADO A CAPITALIZACI�N	h166	$	
	RECIBI� POR INTERESES	h167_1_1	$	Intereses del pa�s 
	RECIBI� POR INTERESES	h167_1_2	$	Intereses del extranjero
	RECIBI� POR UTILIDADES Y DIVIDENDOS DE ALG�N NEGOCIO EN EL QUE NO TRABAJA	h170_1	$	Utilidades y dividendos del pa�s
	RECIBI� POR UTILIDADES Y DIVIDENDOS DE ALG�N NEGOCIO EN EL QUE NO TRABAJA	h170_2	$	Utilidades y dividendos del extranjero
	RECIBI� INDEMINZACI�N POR DESPIDO	h171_1	$	
remesas	RECIBI� ALGUNA COLABORACI�N ECON�MICA DE ALG�N FAMILIAR EN EL EXTERIOR	h172_1	$	
	RECIBI� ALG�N INGRESO EXTRAORDINARIO	h173_1	$	

           
*/

foreach i in h160_1 h160_2 h163_1 h163_2 h164 h165 h166 h167_1_1 h167_1_2 h170_1 h170_2 h171_1 h172_1 h173_1{
gen `i'm=`i'/12 /*Estos estan definidos en base anual!*/
}

bys idh_ch: egen numper = sum(miembros_ci)
bys idh_ch: egen npermax = max(numper)
drop numper
* Los ingresos a nivel de hogar se dividen para los miembros del hogar y se obtiene un per capita.
egen inghog1 = rsum(h155_1 h160_1m h160_2m h163_1m h163_2m h164m h165m h166m h167_1_1m h167_1_2m h170_1m h170_2m h171_1m h172_1m h173_1m), missing
gen inghog= inghog1/npermax

*Transferencias de programas sociales

/*

TIPO DE CANASTA	e246	1	Bajo peso (riesgo nutricional)
		2	Plomo
		3	Pensionistas
		4	Diab�ticos
		5	Renales
		6	Renal-diab�tico
		7	Cel�acos
		8	Tuberculosis
		9	Oncol�gicos
		10	Sida (VIH+)
		11	Otra

*/		
		
/*  Marcela G. Rubio - Abril 2014
La variable canasta pensionistas que correspond�a a e246=3 en la encuesta 2012 ya no aparece en la encuesta 2013 por lo que la canasta 3 que antes
correspond�a a la canasta de Pensionistas se convierte ahora en la canasta para Diab�ticos y as� sucesivamente. */

gen canasta_1 = (e247* indabajo) if e246 ==1
gen canasta_2 = (e247 * indaplomo) if e246 ==2
gen canasta_3 = (e247 * indadiabet) if e246 ==4
gen canasta_4 = (e247 * indarenal) if e246 ==5
gen canasta_5 = (e247 * indarendia) if e246 ==6 
gen canasta_6 = (e247 * indaceliac) if e246 ==7 
gen canasta_7 = (e247 * indatuberc) if e246 ==8 
gen canasta_8 = (e247 * indaoncolo) if e246 ==9 
gen canasta_9 = (e247 * indasida) if e246 ==10

*gen salvcana = (e249*mto_almu) este a�o no existe esta variable

*HOGAR CONSTITUIDO	mto_hogcon	$	Valor del hogar constituido
*COBRA HOGAR CONSTITUIDO	g149	1 = S� / 2 = No	
*	g149_1	1 = S� / 2 = No	Declarado en el sueldo

gen hogcosnt = mto_hogcon if g149==1 & g149_1==2

* Total transferencias
egen transf= rsum(canasta_* hogcosnt), missing

/* Marcela Rubio - Abril 2014
Cambios en nombre de variables de encuesta 2012 a encuesta 2013
g148_1_10 = g148_1_b Recibido por jubilaciones de otra caja
g148_1_11 = g148_1_c Recibido por jubilaciones de otro pais
g148_1_12 = g148_1_a Recibido por jubilaciones AFAP

g148_2_10 = g148_2_b pensiones recibido de otra caja
g148_2_11 = g148_2_c pensiones recibido de otro pais
g148_2_12 = g148_2_a pensiones recibido de AFAP
*/

egen ynlm_ci=rsum(inghog transf g148_1_1 g148_1_2  g148_1_3 g148_1_4  g148_1_5  g148_1_6  g148_1_7  g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1 g148_2_2 g148_2_3 g148_2_4 g148_2_5 g148_2_6 g148_2_7 g148_2_8 g148_2_9 g148_2_12 g148_2_10 g148_2_11 g148_3 g148_4 g148_5_1 g148_5_2 g153_1 g153_2 g154_1 )

*40. Ingreso no laboral no monetario

gen ynlnm_ci= (h156_1/npermax)
label var ynlnm_ci "Ingreso no laboral no monetario" 

*41. Identificador de los hogares en donde alguno de los miembros no sabe/No responde el ingreso de
*la actividad principal.

by idh_ch, sort: egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1
replace nrylmpri_ch=1 if nrylmpri_ch>0 & nrylmpri_ch<.
replace nrylmpri_ch=. if nrylmpri_ch==.
label var nrylmpri_ch "Hogares con alg�n miembro que no respondi� por ingresos"

* Nota Marcela G. - Abril 2014
* Variable hab�a sido generada como missing

*42. Identificador de los hogares en donde alguno de los miembros reporta
*como top code el ingreso de la actividad principal

gen tcylmpri_ch=.


*43. Ingreso laboral monetario del hogar	
by idh_ch: egen ylm_ch=sum(ylm_ci)if relacion_ci!=6

****************
*** ylmnr_ch ***
****************

by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1
replace ylmnr_ch=. if nrylmpri_ch==1

*44. Ingreso laboral no monetario del hogar

by idh_ch: egen ylnm_ch=sum(ylnm_ci)if relacion_ci!=6


*45. Ingreso no laboral monetario del hogar


*46. Ingreso no laboral monetario del hogar
* gen ylmnr_ch=. if nrylmpri_ch==1
by idh_ch: egen ynlm_ch=sum(ynlm_ci) if relacion_ci!=6


*47. Salario monetario de la actividad principal en horas

gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.2)
replace ylmhopri_ci=. if ylmhopri_ci<=0

*48. Salario monetario de todas las actividades

gen ylmho_ci=ylm_ci/(horastot_ci*4.2)
replace ylmho_ci=. if ylmho_ci<=0



*51. Autoconsumo reportado por el individuo
*Principal: �Cu�nto hubiera tenido que pagar por esos productos que consumi� el mes pasado? g133_1
*Secundaria: DERECHO A CULTIVO PARA CONSUMO PROPIO g141_1	$	Monto que habr�a tenido que pagar por esos productos
/*

RETIRO DE PRODUCTOS PARA CONSUMO PROPIO (trabajador no agropecuario)	g144_1	$	Monto que habr�a tenido que pagar por esos bienes
RETIRO DE PRODUCTOS PARA CONSUMO PROPIO (trabajador agropecuario)	
    g144_2_1	$	Valor de lo consumido en carnes o chacinados
	g144_2_2	$	Valor de lo consumido en l�cteos
	g144_2_3	$	Valor de lo consumido en huevos y aves
	g144_2_4	$	Valor de lo consumido en productos de la huerta
	g144_2_5	$	Valor consumido en otros alimentos

*/
             
egen autocons_ci=rsum(g141_1 g133_1 g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5), missing


*52. Autoconsumo del hogar

bys idh_ch: egen autocons_ch=sum(autocons_ci) if miembros_ci==1
la var autocons_ch "Autoconsumo del Hogar"

*53. Remesas reportadas por el individuo

gen remesas_ci= (h172_1m/npermax)
label var remesas_ci "Remesas mensuales reportadas por el individuo" 

	****************
	***remesas_ch***
	****************
	by idh_ch, sort: egen remesas_ch=sum(remesas_ci) if miembros_ci==1
	label var remesas_ch "Remesas mensuales del hogar"	


*55. Antig�edad en la actividad actual

*74. Anios de educaci�n
gen post=1 if e51_11>=1 & e51_11!=9
replace post=0 if e51_11==0

gen terc=1 if e51_10>=1 & e51_10!=9
replace terc=0 if e51_10==0

gen univ=1 if e51_9>=1 & e51_9!=9
replace univ=0 if e51_9==0

gen mag=1 if e51_8>=1 & e51_8!=9
replace mag=0 if e51_8==0

gen enst=1 if e51_7>=1 & e51_7!=9
replace enst=0 if e51_7==0

gen bachtec=1 if e51_6>=1 & e51_6!=9
replace bachtec=0 if e51_6==0

gen bachsec=1 if e51_5>=1 & e51_5!=9
replace bachsec=0 if e51_5==0

gen cbliceo=1 if e51_4>=1 & e51_4!=9
replace cbliceo=0 if e51_4==0

gen priesp=1 if e51_3>=1 & e51_3!=9
replace priesp=0 if e51_3==0

gen pricom=1 if e51_2>=1 & e51_2!=9
replace pricom=0 if e51_2==0

gen preesc=1 if e193==1 | e193==2
replace preesc=0 if  e193==3

/*  Criterios para la elaboraci�n de a�os de educaci�n aprobados:
       > No se toma en cuenta los a�os de preescolar
	   > Los a�os de educacion primaria especial tambi�n son 6 a�os, como la primaria comun
*/

/*Entendiendo los niveles educativos.
"9" Cursando el primera a�o de alg�n nivel y aun no lo ha aprobado. Tambi�n marcar� 9 en aquellos casos que la persona asisti� al nivel y no alcanzo a aprobar el primer a�o. 
--> Esto quiere decir que tiene cero a�os de educaci�n en ese nivel.

Observaciones
**A�os aprobados en Primaria Especial
Para los que concurren a una escuela especial, en a�os aprobados deber� registrarse, 1, 2, 3, o 4 seg�n corresponda. 
En caso de no recordar el �ltimo a�o aprobado deber� registrarse �2�.


*Ajustando �9� � �No saben/No responden� 

gen e51_2n=e51_2 // Primaria Com�n
replace e51_2n=0 if e51_2==9

gen e51_4n=e51_4 // Ciclo b�sico Liceo o  UTU
replace e51_4n=0 if e51_4==9

gen  e51_5n=e51_5 // Bachillerato Secundario
replace e51_5n=0 if e51_5==9

gen e51_6n=e51_6 // Bachiellrato Tecnol�gico UTU
replace e51_6n=0 if e51_6==9

gen e51_8n=e51_8 //Magisterio
replace e51_8n=0 if e51_8==9

gen e51_9n=e51_9 // Universidad
replace e51_9n=0 if e51_9==9

gen e51_10n=e51_10 // Terciario No Universitario
replace e51_10n=0 if e51_10==9

gen e51_11n=e51_11 // Postgrados
replace e51_11n=0 if e51_11==9

gen aedu_ci=.
replace aedu_ci=0 if preesc==1
replace aedu_ci= e51_2n  + e51_4n + e51_5n +  e51_8n + e51_9n + e51_10n + e51_11n if e51_5n>=e51_6n
replace aedu_ci= e51_2n  + e51_4n + e51_6n + e51_8n + e51_9n + e51_10n + e51_11n if e51_6n> e51_5n 
replace aedu_ci=.  if e51_3>=1 & e51_3<=9 // Educaci�n Especial
replace aedu_ci=.  if e51_7_1>=1 & e51_7_1<=9 // Educaci�n para Adultos
replace aedu_ci=0 if e51_2n==0 & e51_4n==0 & e51_5n==0 & e51_6n==0 & e51_8n==0 & e51_9n==0 & e51_10n==0 & e51_11n==0
*/

** Aug, 2015: Se efectuan cambios en sintaxis de variable aedu_ci en base a revisi�n por Iv�n Bornacelly SCL/EDU **
** Ajustado Jul, 2017 por Iv�n Bornacelly SCL/EDU

gen aedu_ci=.
replace aedu_ci= 0            if preesc==1 
replace aedu_ci= 0           if (e51_2==9  | e51_3==9)
replace aedu_ci= e51_3        if priesp==1  & e51_3<9
replace aedu_ci= e51_2        if pricom==1  & e51_2<9 
replace aedu_ci= e51_4 + 6    if cbliceo==1 & e51_4<9
replace aedu_ci= e51_5 + 9    if bachsec==1 & e51_5<9
replace aedu_ci= e51_6 + 9    if bachtec==1 & (e51_6>e51_5) & (e51_6<9 )
replace aedu_ci= e51_7 + 12   if enst==1 & (e51_7_1==1 | aedu_ci>=12 & aedu_ci!=.) & e51_7<9
replace aedu_ci= e51_8 + 12   if mag==1  & e51_8<9
replace aedu_ci= e51_9 + 12   if univ==1 & e51_9<9
replace aedu_ci= e51_10 + 12  if terc==1 & (e51_10>e51_9) & e51_10<9
replace aedu_ci= e51_11 + 17  if post==1 & e51_11<9 
replace aedu_ci=0             if e49==2 & (edad>=5 & edad!=.)
replace aedu_ci=0             if e49==1 & (edad>=5 & edad!=.) & aedu_ci==. // Poblaci�n que declara estar asistiendo o haber asistido, pero no reporta ning�n nivel o a�os de educaci�n aprobado


**************
***eduno_ci***
**************

gen byte eduno_ci=(aedu_ci==0) 
replace eduno_ci=. if aedu_ci==.
label variable eduno_ci "Cero anios de educacion"

**************
***edupi_ci***
**************

gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<6)
replace edupi_ci=. if aedu_ci==.
label variable edupi_ci "Primaria incompleta"

**************
***edupc_ci***
**************

gen byte edupc_ci=(aedu_ci==6)
replace edupc_ci=. if aedu_ci==.
label variable edupc_ci "Primaria completa"

**************
***edusi_ci***
**************

gen byte edusi_ci=(aedu_ci>6 & aedu_ci<12)
replace edusi_ci=. if aedu_ci==.
label variable edusi_ci "Secundaria incompleta"

**************
***edusc_ci***
**************


gen byte edusc_ci=(aedu_ci==12)
replace edusc_ci=. if aedu_ci==.
label variable edusc_ci "Secundaria completa"

***************
***edus1i_ci***
***************

gen byte edus1i_ci=(aedu_ci>6 & aedu_ci<9)
replace edus1i_ci=. if aedu_ci==.
label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************

gen byte edus1c_ci=(aedu_ci==9)
replace edus1c_ci=. if aedu_ci==.
label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************

gen byte edus2i_ci=(aedu_ci>9 & aedu_ci<12)
replace edus2i_ci=. if aedu_ci==.
label variable edus2i_ci "2do ciclo de la secundaria incompleto"

***************
***edus2c_ci***
***************

gen byte edus2c_ci=(aedu_ci==12)
replace edus2c_ci=. if aedu_ci==.
label variable edus2c_ci "2do ciclo de la secundaria completo"

**************
***eduui_ci***
**************

gen byte eduui_ci=(aedu_ci>12 & aedu_ci<16)
replace eduui_ci=. if aedu_ci==.
label variable eduui_ci "Universitaria incompleta"

***************
***eduuc_ci***
***************

gen byte eduuc_ci=(aedu_ci>=16) 
replace eduuc_ci=. if aedu_ci==.
label variable eduuc_ci "Universitaria completa o mas"

***************
***edupre_ci***
***************

gen edupre_ci=(e193==1)
replace edupre_ci=. if aedu_ci==.
label variable edupre_ci "Educacion preescolar"

****************
***asispre_ci***
****************
	g asispre_ci=.
	replace asispre_ci=1 if e193==1 & e27>=4
	recode asispre_ci (.=0)
	la var asispre_ci "Asiste a educacion prescolar"

***************
***eduac_ci****
***************

* e51_9: a�os educaci�n universitaria
* e51_10: a�os educaci�n terciario no universitario

gen eduac_ci=.
replace eduac_ci = 1 if e51_9>0
replace eduac_ci = 0 if e51_10>0
replace eduac_ci =. if e51_9>=10 | e51_10>=10

/* Nota Marcela G. Rubio - Abril 2014
Variable hab�a sido generada como missing, estimo variable con las respectivas preguntas de educaci�n universitaria y no universitaria /// 
de cuestionario*/

*88. Personas que actualmente asisten a centros de ensenanza

gen asiste_ci=.
*cambio MLO 01,2014
*replace asiste_ci=1 if e197 == 1 | e201 == 1 |  e212 == 1 | e215 == 1 |  e218 == 1 |   e221 == 1 | e224 == 1
* cambio MGR 06,2015
replace asiste_ci=1 if e193==1 | e197 == 1 | e201 == 1 |  e212 == 1 | e215 == 1 |  e218 == 1 |   e221 == 1 | e224 == 1
recode asiste_ci .=0
/* 
*Primaria
replace asiste_ci= 1 if e197 == 1
replace asiste_ci= 0 if e197 == 2 | e197 == 3
*Educaci�n media 
replace asiste_ci= 1 if e201 == 1
replace asiste_ci= 0 if e201 == 2 | e201 == 3
*Tecnica
replace asiste_ci= 1 if e212 == 1
replace asiste_ci= 0 if e212 == 2 | e212 == 3
*Normal
replace asiste_ci= 1 if e215 == 1
replace asiste_ci= 0 if e215 == 2 | e215 == 3
*Universitario
replace asiste_ci= 1 if e218 == 1
replace asiste_ci= 0 if e218 == 2 | e218 == 3
*No universitario 
replace asiste_ci= 1 if e221 == 1
replace asiste_ci= 0 if e221 == 2 | e221 == 3
*Postgrado
replace asiste_ci= 1 if e224 == 1
replace asiste_ci= 0 if e224 == 2 | e224 == 3
 */

*89. Razones para no asistir a la escuela
* Se genera como mising porque no hay para todas las preguntas. 
gen pqnoasis_ci=.

**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**
	
**************
*pqnoasis1_ci*
**************
g       pqnoasis1_ci =.

*90. Personas que han repetido al menos un ano o grado

gen repite_ci=.

*91. Personas que han repetido el �ltimo grado

gen repiteult_ci=.

*92. Personas que asisten a centros de ensenanza p�blicos

gen edupub_ci=.
*Primaria
replace edupub_ci=1 if e198 ==1 & e197 == 1
replace edupub_ci=0 if e198 ==2 & e197 == 1
*Educaci�n media 
replace edupub_ci=1 if e210_1 ==1 & e201 == 1
replace edupub_ci=0 if e210_1 ==2 & e201 == 1
*Tecnica
replace edupub_ci=1 if e213 ==1 & e212 == 1
replace edupub_ci=0 if e213 ==2 & e212 == 1
*Normal
replace edupub_ci=1 if e216 ==1 & e215 == 1
replace edupub_ci=0 if e216 ==2 & e215 == 1
*Universitaria
replace edupub_ci=1 if e219 ==1 & e218 == 1
replace edupub_ci=0 if e219 ==2 & e218 == 1
*No universitaria
replace edupub_ci=1 if e222 ==1 & e221 == 1
replace edupub_ci=0 if e222 ==2 & e221 == 1
*Postgrado
replace edupub_ci=1 if e225 ==1 & e224 == 1
replace edupub_ci=0 if e225 ==2 & e224== 1


*************
**tecnica_ci*
*************

gen tecnica_ci=.
replace tecnica_ci=1 if e51_10>=1 & e51_10<=9
replace tecnica_ci=0 if e51_9>=1 & e51_9<=9
label var tecnica_ci "1=formacion terciaria tecnica"



*93. Acceso a una fuente de agua por red

/*
d11
1 Red general
2 Pozo surgente no protegido
3 Pozo surgente protegido
4 Aljibe
5 Arroyo, r�o
6 Otro
*/

gen aguared_ch=(d11==1)
replace aguared_ch =. if d11==.

*94. Ubicaci�n principal de la fuente de agua

gen aguadist_ch=d12
replace aguadist_ch=. if d12==4

*95. La principal fuente de agua es unimproved seg�n los mdg

gen aguamala_ch=(d11==4 | d11==5) 
replace aguamala_ch =. if d11==.

*96. El hogar usa un medidor para pagar por su consumo de agua


gen aguamide_ch=.

*97. La principal fuente de iluminaci�n es electricidad

gen luz_ch=(d18==1)

*98. El hogar usa un medidor para pagar la electricidad

gen luzmide_ch=.

*99. El combustible principal usado en el hogar es gas o electricidad

gen combust_ch=1 if d20==1 | d20==2 | d20==3 | d20==4
replace combust_ch=0 if combust_ch==.

*100. El hogar tiene alg�n tipo de servicio hig�enico

gen bano_ch=1 if d13<3
replace bano_ch=0 if d13==3

*101. El servicio higi�nico es de uso exclusivo del hogar

gen banoex_ch=1 if d15==1
replace banoex_ch=0 if d15==2

*102. Tipo de desag�e incluyendo la definici�n de unimproved del MDG

gen des1_ch=.
replace des1_ch=0 if d13==3
replace des1_ch=1 if d16==1 | (d16==2 & d13==1)
replace des1_ch=2 if (d16==2 & d13==2)
replace des1_ch=3 if d16==3 | d16==4 

*103. Tipo de desag�e sin incluir la definici�n de unimproved del mdg

gen des2_ch=.
replace des2_ch=0 if d13==3
replace des2_ch=1 if d16==1 | d16==2 
replace des2_ch=2 if d16==3 | d16==4 

*104. Materiales de construcci�n del piso

gen piso_ch=.
replace piso_ch=0 if c4==5
replace piso_ch=1 if c4==1 | c4==2 | c4==3
replace piso_ch=2 if c4==4

*105. Materiales de construcci�n de las paredes

gen pared_ch=.
replace pared_ch=0 if c2==6
replace pared_ch=1 if c2<6

*106. Materiales de construcci�n del techo

gen techo_ch=.
replace techo_ch=0 if c3==6 | c3==5
replace techo_ch=1 if c3<5

*107. M�todo de eliminaci�n de residuos

gen resid_ch=.

**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
*********************
***aguamejorada_ch***
*********************
g       aguamejorada_ch = 1 if d11 ==1 | d11 ==3 
replace aguamejorada_ch = 0 if d11 ==2 | (d11 >=4 & d11 <=6)

*********************
***banomejorado_ch***
*********************
g       banomejorado_ch = 1 if (d13 ==1 | d13 ==2) & d15 ==1 & (d16 ==1 | d16 ==2)
replace banomejorado_ch = 0 if  ((d13 ==1 | d13 ==2) & d15 ==2) | d13 ==3 | ((d13 ==1 | d13 ==2) & d15 ==1 & (d16 ==3 | d16 ==4))


*108. Cantidad de habitaciones que se destinan exclusivamente para dormir
gen dorm_ch=d10

*109. Cantidad de habitaciones en el hogar

gen cuartos_ch=d9

*110. Si existe un cuarto separado para cocinar

gen cocina_ch=.
replace cocina_ch=1 if d19==1 | d19==2
replace cocina_ch=0 if d19==3

*111. El hogar tiene servicio telef�nico fijo

gen telef_ch=(d21_17==1)


*112. El hogar posee heladera o refrigerador

gen refrig_ch=(d21_3==1)

*113. El hogar posee freezer o congelador

gen freez_ch=.

*114. El hogar posee autom�vil particular

gen auto_ch=(d21_18==1)

*115. El hogar posee computadora

gen compu_ch=(d21_15==1)

*116. El hogar posee conexi�n a internet

gen internet_ch=(d21_16==1)

*117. El hogar tiene servicio telef�nico celular

replace e60=0 if e60==2
bys idh_ch: egen byte cel=sum(e60)
gen cel_ch=1 if cel>=1 & cel!=.
replace cel_ch=0 if cel==0

*118. Tipo de vivienda en la que reside el hogar

gen vivi1_ch=1 if c1==1
replace vivi1_ch=2 if c1==3 | c1==4
replace vivi1_ch=3 if c1==2 | c1==5

*119. La vivienda en la que reside el hogar es una casa o un departamento

gen vivi2_ch=1 if c1!=5
replace vivi2=0 if vivi2==.
*120. Propiedad de la vivienda

gen viviprop_ch=.
replace viviprop_ch=0 if  d8_1==5
replace viviprop_ch=1 if d8_1==2 | d8_1==4
replace viviprop_ch=2 if d8_1==1 | d8_1==3
replace viviprop_ch=3 if d8_1>=6 & d8_1<=9


*121. El hogar posee un t�tulo de propiedad

gen vivitit_ch=.

*122. Alquiler mensual

gen vivialq_ch=d8_3 if viviprop_ch==0


*123. Alquiler mensual imputado

gen vivialqimp_ch=d8_3 if viviprop_ch~=0

*50. Rentas imputadas del hogar

gen rentaimp_ch=vivialqimp_ch

*******************
***  seguro_ci  ***
*******************

g benefdes_ci=0 if desemp_ci==1
replace benefdes_ci=1 if  f117==1  & desemp_ci==1
label var benefdes_ci "=1 si tiene seguro de desempleo"

*******************
*** yseguro_ci  ***
*******************
g ybenefdes_ci=g148_3 if benefdes_ci==1
label var ybenefdes_ci "Monto de seguro de desempleo"

/*_____________________________________________________________________________________________________*/
* Asignaci�n de etiquetas e inserci�n de variables externas: tipo de cambio, Indice de Precios al 
* Consumidor (2011=100), l�neas de pobreza
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