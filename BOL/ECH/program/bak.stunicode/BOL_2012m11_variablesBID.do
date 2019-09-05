
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

local PAIS BOL
local ENCUESTA ECH
local ANO "2012"
local ronda m11 


local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
*local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: Bolivia
Encuesta: ECH
Round: m11
Autores:
Versi�n 2014: Melany Gualavisi
Modificaci�n 2016: Mayra S�enz
�ltima versi�n: 11/04/2016
Fecha �ltima modificaci�n: 04/09/2014

							SCL/LMK - IADB
****************************************************************************/
/***************************************************************************
Detalle de procesamientos o modificaciones anteriores:

****************************************************************************/


use `base_in', clear


foreach v of varlist _all {
	local lowname=lower("`v'")
	rename `v' `lowname'
}
	
	****************
	* region_BID_c *
	****************
	
gen region_BID_c=3

label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c
	************
	* region_c *
	************
*YL: generacion "region_c" para los a�os 2009 y +. Para proyecto maps America.	
tostring folio, replace
gen region_c=real(substr(folio,1,1))

label define region_c ///
1"Chuquisaca"         ///     
2"La Paz"             ///
3"Cochabamba"         ///
4"Oruro"              ///
5"Potos�"             ///
6"Tarija"             ///
7"Santa Cruz"         ///
8"Beni"               ///
9"Pando"              
label value region_c region_c
label var region_c "division politica, estados"

***************
***factor_ch***
***************
gen factor_ch=.
replace factor_ch = factor
label variable factor_ch "Factor de expansion del hogar"

***************
****idh_ch*****
***************
sort folio
gen idh_ch = folio
destring idh_ch, replace
label variable idh_ch "ID del hogar"

**************
****idp_ci****
**************
gen idp_ci= folio
label variable idp_ci "ID de la persona en el hogar"

**********
***zona***
**********

gen byte zona_c=0 	if area==2
replace zona_c=1 	if area==1

label variable zona_c "Zona del pais"
label define zona_c 1 "Urbana" 0 "Rural"
label value zona_c zona_c

label variable zona_c "Zona del pais"


************
****pais****
************
gen str3 pais_c="BOL"
label variable pais_c "Pais"

**********
***anio***
**********
gen anio_c=2012
label variable anio_c "Anio de la encuesta"

*********
***mes***
*********
gen mes_c=11
label variable mes_c "Mes de la encuesta"

*****************
***relacion_ci***
*****************
gen relacion_ci=.
replace relacion_ci=1 if  s1_08==1
replace relacion_ci=2 if  s1_08==2
replace relacion_ci=3 if  s1_08==3
replace relacion_ci=4 if  s1_08>=4 &  s1_08<=9
replace relacion_ci=5 if  s1_08==10 |  s1_08==12 
replace relacion_ci=6 if  s1_08==11

label variable relacion_ci "Relacion con el jefe del hogar"
label define relacion_ci 1 "Jefe/a" 2 "Esposo/a" 3 "Hijo/a" 4 "Otros parientes" 5 "Otros no parientes"
label define relacion_ci 6 "Empleado/a domestico/a", add
label value relacion_ci relacion_ci


****************************
***VARIABLES DEMOGRAFICAS***
****************************

***************
***factor_ci***
***************
gen factor_ci=factor_ch
label variable factor_ci "Factor de expansion del individuo"

**********
***sexo***
**********
gen sexo_ci = s1_03
label var sexo_ci "Sexo del individuo" 
label define sexo_ci 1 "Hombre" 2 "Mujer"
label value sexo_ci sexo_ci

**********
***edad***
**********
gen edad_ci= s1_04
label variable edad_ci "Edad del individuo"

*****************
***civil_ci***
*****************
gen civil_ci=.
replace civil_ci=1 		if s1_13==1
replace civil_ci=2 		if s1_13==2 | s1_13==3
replace civil_ci=3 		if s1_13==4 | s1_13==5
replace civil_ci=4 		if s1_13==6
label variable civil_ci "Estado civil"
label define civil_ci 1 "Soltero" 2 "Union formal o informal"
label define civil_ci 3 "Divorciado o separado" 4 "Viudo" , add
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

*************************
*** VARIABLES DE RAZA ***
*************************

* MGR Oct. 2015: modificaciones realizadas en base a metodolog�a enviada por SCL/GDI Maria Olga Pe�a
/*	
c2_05b
1	AFROBOLIVIANO
2	ARAONA
3	AYMARA
5	BAURE
7	CAVINE�O
11	CHIMAN
13	CHIQUITANO
15	GUARANI
16	GUARAYO
17	ITONAMA
18	JOAQUINIANO
19	KALLAWAYA
22	LECO
24	MATACO
25	MOJE�O
27	MOSETEN
28	MOVIMA
29	PACAHUARA
30	QUECHUA
32	SIRIONO
33	TACANA
*/	

/*
destring c2_05b, replace

gen raza_ci=.
*LMC: actualiza raza_ci==1
replace raza_ci= 1 if  (c2_05b==3 | c2_05b==13 | c2_05b==15 | c2_05b==25 | c2_05b==30)
tab s1_10a, gen(idiom_)
replace raza_ci= 1 if (idiom_2==1 | idiom_6==1 | idiom_10==1) & raza_ci==.
drop idiom_*

*replace raza_ci= 1 if  (cods2_05>=3 & cods2_05>=36)
replace raza_ci= 2 if c2_05b == 1
bys idh_ch: gen aux=raza_ci if relacion_ci==1
bys idh_ch: egen aux1 = max(aux)
replace raza_ci=aux1 if (raza_ci ==. & relacion_ci ==3)  
replace raza_ci=3 if raza_ci==. 
drop aux aux1
label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo"
*/
*Raza usando idioma
encode s1_11, gen(idioma2)

gen raza_idioma_ci = .
replace raza_idioma_ci= 1 if idioma2==3 | idioma2==4 | idioma2==7 | idioma2==9 | idioma2==12 ///
|idioma2==16 | idioma2==17 | idioma2==19 | idioma2==21 | idioma2==22
replace raza_idioma_ci= 3 if idioma2==1 | idioma2==2 | idioma2==5 | idioma2==6 | idioma2==8 ///
| idioma2==10 | idioma2==10 | idioma2==11| idioma2==13| idioma2==14| idioma2==15| idioma2==18 ///
| idioma2==20
bys idh_ch, sort: gen aux=raza_idioma_ci if s1_08==1
bys idh_ch, sort: egen aux1 = max(aux)
replace raza_idioma_ci=aux1 if (raza_idioma_ci ==. & (s1_08 ==3 | s1_08==8))  
replace raza_idioma_ci=3 if raza_idioma_ci==. 
drop aux aux1
label define raza_idioma_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros" 
label value raza_idioma_ci raza_idioma_ci 
label value raza_idioma_ci raza_idioma_ci
label var raza_idioma_ci "Raza o etnia del individuo" 

*Raza usando la definicion mas apropiada

*encode s2_05, gen(etnia)

gen raza_ci=.
replace raza_ci= 1 if  s2_05a==1
replace raza_ci= 2 if  s2_05b=="AFROBOLIVIANO"
replace raza_ci= 3 if (s2_05a==2 | s2_05a==3) 
bys idh_ch: gen aux=raza_ci if s1_08==1
bys idh_ch: egen aux1 = max(aux)
replace raza_ci=aux1 if (raza_ci ==. & (s1_08 ==3|s1_08==8))  
replace raza_ci=3 if raza_ci==. 
drop aux aux1
label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros" 
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 

gen id_ind_ci = 0
replace id_ind_ci=1 if raza_ci==1
label define id_ind_ci 1 "Ind�gena" 0 "Otros" 
label value id_ind_ci id_ind_ci 
label var id_ind_ci  "Indigena" 

gen id_afro_ci = 0
replace id_afro_ci=1 if raza_ci==2
label define id_afro_ci 1 "Afro-descendiente" 0 "Otros" 
label value id_afro_ci id_afro_ci 
label var id_afro_ci "Afro-descendiente" 


************************************
*** VARIABLES DEL MERCADO LABORAL***
************************************
/************************************************************************************************************
* L�neas de pobreza oficiales
************************************************************************************************************/
*********
*lp_ci***
*********

gen lp_ci =.
replace lp_ci=z
label var lp_ci "Linea de pobreza oficial del pais"

*********
*lpe_ci***
*********

gen lpe_ci =.
replace lpe_ci=zext

label var lpe_ci "Linea de indigencia oficial del pais"

*************
**salmm_ci***
*************
* http://www.ine.gob.bo/indice/general.aspx?codigo=41201 MGD 04/14/2014
*BOL 2011
gen salmm_ci= 	1000
label var salmm_ci "Salario minimo legal"

****************
*cotizando_ci***
****************
gen cotizando_ci=.
label var cotizando_ci "Cotizante a la Seguridad Social"

****************
*afiliado_ci****
****************
gen afiliado_ci= s5_59b==1	
recode afiliado_ci .=0  if condact>=1 & condact<=3
label var afiliado_ci "Afiliado a la Seguridad Social"

****************
*tipopen_ci*****
****************
gen tipopen_ci=.

replace tipopen_ci=1 if s6_01a>0 &  s6_01a~=.
replace tipopen_ci=2 if s6_01d>0 & s6_01d~=.
replace tipopen_ci=3 if s6_01b>0 & s6_01b~=.
replace tipopen_ci=4 if s6_01c>0 & s6_01c~=. 
replace tipopen_ci=12 if (s6_01a>0 & s6_01d>0) & (s6_01a~=. & s6_01d~=.)
replace tipopen_ci=13 if (s6_01a>0 & s6_01b>0) & (s6_01a~=. & s6_01b~=.)
replace tipopen_ci=23 if (s6_01d>0 & s6_01b>0) & (s6_01d~=. & s6_01b~=.)
replace tipopen_ci=123 if (s6_01a>0 & s6_01d>0 & s6_01b>0) & (s6_01a~=. & s6_01d~=. & s6_01b~=.)
label define  t 1 "Jubilacion" 2 "Viudez/orfandad" 3 "Benemerito" 4 "Invalidez" 12 "Jub y viudez" 13 "Jub y benem" 23 "Viudez y benem" 123 "Todas"
label value tipopen_ci t
label var tipopen_ci "Tipo de pension - variable original de cada pais" 

****************
*instpen_ci*****
****************
gen instpen_ci=.
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 
gen instcot_ci=. 


****************
****condocup_ci*
****************
/*
gen condocup_ci=.
replace condocup_ci=1 if condact==1
replace condocup_ci=2 if condact==2 | condact==3
replace condocup_ci=3 if (condact==4 | condact==5) & edad_ci>=10
replace condocup_ci=4 if edad_ci<10
label var condocup_ci "Condicion de ocupaci�n de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor que 10" 
label value condocup_ci condocup_ci
*/
* Homologacion toda la serie 05/27/2014 MGD

gen condocup_ci=.
*Mod. MLO 2015,10: se consideran otras causas excepcionales 
*replace condocup_ci=1 if s5_01==1 | s5_02<=6  | s5_03==1
replace condocup_ci=1 if s5_01==1 | s5_02<=6 | (s5_03>=1 & s5_03<=7)
*replace condocup_ci=2 if (s5_01==2 | s5_02==7 | s5_03>1) & (s5_05==1) & (s5_04==1)
replace condocup_ci=2 if (s5_01==2 | s5_02==7 | s5_03>7) & (s5_05==1) & (s5_04==1)
recode condocup_ci .=3 if edad_ci>=7
recode condocup_ci .=4 if edad_ci<7
*MLO la encuesta pregunta a partir de 7 a�os (no 10)
label var condocup_ci "Condicion de ocupaci�n de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor que 7" 
label value condocup_ci condocup_ci

ta condocup_ci condact

*************
*cesante_ci* 
*************

gen cesante_ci=1 if s5_07==1 & condocup_ci==2
*2014, 03 Modificacion MLO
replace cesante_ci=0 if s5_07==2 & condocup_ci==2
*replace cesante_ci=0 if s5_07==0 & condocup_ci==3
*replace cesante_ci=0 if condocup_ci==3 & cesante_ci != 1

label var cesante_ci "Desocupado - definicion oficial del pais"	

*************
*tamemp_ci
*************
*Bolivia Peque�a 1 a 5 Mediana 6 a 49 Grande M�s de 49
gen tamemp_ci=.
replace tamemp_ci=1 if s5_27>=1 & s5_27<=5
replace tamemp_ci=2 if s5_27>=6 & s5_27<=49
replace tamemp_ci=3 if s5_27>49 & s5_27!=.
label var tamemp_ci "# empleados en la empresa segun rangos"
label define tamemp_ci 1 "Peque�a" 2 "Mediana" 3 "Grande"
label value tamemp_ci tamemp_ci

*Bolivia micro 1 a 4 peque�a 5 a 14 Mediana 15-40 Grande mas 41
gen tamemp=.
replace tamemp=1 if s5_27>=1 & s5_27<=4
replace tamemp=2 if s5_27>=5 & s5_27<=14
replace tamemp=3 if s5_27>=15 & s5_27<=40
replace tamemp=4 if s5_27>=41 & s5_27!=.

label var tamemp "# empleados en la empresa segun rangos"
label define tamemp  1 "Micro" 2 "Peque�a" 2 "Mediana" 3 "Grande"
label value tamemp tamemp

* BOlivia comparativo OECD
gen tamemp_o=.
replace tamemp_o=1 if s5_27>=1 & s5_27<=9
replace tamemp_o=2 if s5_27>=10 & s5_27<=49
replace tamemp_o=3 if s5_27>=50 & s5_27!=.
label var tamemp_o "# empleados en la empresa segun rangos OECD"
label define tamemp_o 1 "[1-9]" 2 "[10-49]" 3 "[50 y mas]"
label value tamemp_o tamemp_o

*************
**pension_ci*
*************

egen aux_p=rsum(s6_01a s6_01b s6_01c s6_01d), missing
gen pension_ci=1 if aux_p>0 & aux_p!=.
recode pension_ci .=0 
label var pension_ci "1=Recibe pension contributiva"

*************
**ypen_ci*
*************

gen ypen_ci=aux_p 
recode ypen_ci .=0 
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************

gen aux_ps= s6_01eb if s6_01eb>1 & s6_01eb!=. 
gen byte pensionsub_ci=1 if aux_ps>0 & aux_ps!=.
recode pensionsub_ci .=0
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**ypensub_ci*
*****************
destring aux_ps, replace
gen  ypensub_ci=aux_ps
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"
	
/* Esta secci�n es para los residentes habituales del hogar mayores a 7 a�os. Sin embargo, las variables construidas 
por el centro de estad�stica tienen en cuenta a la poblaci�n con 10 a�os o m�s. Esto no es un problema dado que el 
programa para generar los indicadores de soci�metro restrige  todo a 15 o m�s a�os para que haya comparabilidad entre
pa�ses
*/

************
***emp_ci***
************
gen byte emp_ci=(condocup_ci==1)
label var emp_ci "Ocupado (empleado)"

****************
***desemp_ci***
****************
gen desemp_ci=(condocup_ci==2)
label var desemp_ci "Desempleado que busc� empleo en el periodo de referencia"
  
*************
***pea_ci***
*************
gen pea_ci=0
replace pea_ci=1 if emp_ci==1 |desemp_ci==1
label var pea_ci "Poblaci�n Econ�micamente Activa"

*****************
***desalent_ci***
*****************
gen desalent_ci=(emp_ci==0 & (s5_15==3 | s5_15==4))
replace desalent_ci=. if emp_ci==.
label var desalent_ci "Trabajadores desalentados"

*****************
***horaspri_ci***
*****************

  *29a. cuantos dias a la semana trabaja s5_29
  *29b. cuantas horas en promedio trabaja al dia en su ocupaci�n? s5_29h

gen horaspri_ci=s5_29* s5_29h
replace horaspri_ci=. if s5_29==. | s5_29h==.
replace horaspri_ci=. if emp_ci~=1
label var horaspri_ci "Horas trabajadas semanalmente en el trabajo principal"


*****************
***horastot_ci***
*****************
/*
s5_46a          double %10.0g                 46a. cuantos dias trabaj� la semana anterior ?
s5_46b1         double %10.0g      s5_46b1    46b. cuantas horas promedio al dia trabaj� la semana anterior ?

*/
gen horassec_ci= s5_46a*s5_46b1 
replace horassec_ci=. if s5_46a==. | s5_46b1==.
replace horassec_ci=. if emp_ci~=1

egen horastot_ci= rsum(horaspri_ci horassec_ci), missing
replace horastot_ci = . if horaspri_ci == . & horassec_ci == .
replace horassec_ci=. if emp_ci~=1

***************
***subemp_ci***
***************
/*
gen subemp_ci=.
replace subemp_ci=1 if s5_53== 1 & horastot_ci <= 30
replace subemp_ci=0 if s5_53== 2 & emp_ci == 1
replace subemp_ci=. if s5_53==. | horastot_ci==.
label var subemp_ci "Personas en subempleo por horas"
*/

* Se considera subempleo visible: quiere trabajar mas horas y esta disponible. MGD 06/18/2014
gen subemp_ci=0
*replace subemp_ci=1 if s5_54==1  & horaspri_ci <= 30 & emp_ci==1
replace subemp_ci=1 if (s5_54==1 & s5_53==1)  & horaspri_ci <= 30 & emp_ci==1
label var subemp_ci "Personas en subempleo por horas"

*******************
***tiempoparc_ci***
*******************
gen tiempoparc_ci=.
*replace tiempoparc_ci=1 if s5_53==2 & horastot_ci<=30 & emp_ci == 1
*replace tiempoparc_ci=0 if s5_53==2 & emp_ci == 1 & horastot_ci>30
*Mod. MLO 2015, 10
replace tiempoparc_ci=(s5_53==2 & horaspri_ci<30 & emp_ci == 1)
replace tiempoparc_ci=. if emp_ci==0
label var tiempoparc_c "Personas que trabajan medio tiempo" 

******************
***categopri_ci***
******************
gen categopri_ci=.
replace categopri_ci=1 if s5_21>=4 & s5_21<=6
replace categopri_ci=2 if s5_21==3
replace categopri_ci=3 if s5_21==1 | s5_21==2 | s5_21==8
replace categopri_ci=4 if s5_21==7
replace categopri_ci=. if emp_ci~=1
label define categopri_ci 1"Patron" 2"Cuenta propia" 
label define categopri_ci 3"Empleado" 4" No remunerado", add
label value categopri_ci categopri_ci
label variable categopri_ci "Categoria ocupacional trabajo principal"



*Bolivia Peque�a 1 a 5 Mediana 6 a 49 Grande M�s de 49
gen tamemp_ci1=.
replace tamemp_ci1=1 if s5_27>1 & s5_27<=5
replace tamemp_ci1=2 if s5_27>=6 & s5_27<=49
replace tamemp_ci1=3 if s5_27>49 & s5_27!=. & s5_27!=99

*Bolivia Peque�a 1 a 5 Mediana 6 a 49 Grande M�s de 49
gen tamemp_ci2=.
replace tamemp_ci2=1 if s5_27>=1 & s5_27<=5
replace tamemp_ci2=2 if s5_27>=6 & s5_27<=49
replace tamemp_ci2=3 if s5_27>49 & s5_27!=. & s5_27!=99

******************
***categosec_ci***
******************
gen categosec_ci=.
replace categosec_ci=1 if s5_43>=4 & s5_43<=6
replace categosec_ci=2 if s5_43==3
replace categosec_ci=3 if s5_43==1 | s5_43==2 | s5_43==8
replace categosec_ci=4 if s5_43==7
label define categosec_ci 1"Patron" 2"Cuenta propia" 
label define categosec_ci 3"Empleado" 4 "No remunerado" , add
label value categosec_ci categosec_ci
label variable categosec_ci "Categoria ocupacional trabajo secundario"

*****************
*tipocontrato_ci*
*****************

gen tipocontrato_ci=.
replace tipocontrato_ci=1 if s5_28==3 & categopri_ci==3
replace tipocontrato_ci=2 if s5_28==1 & categopri_ci==3
replace tipocontrato_ci=3 if ((s5_28==2 | s5_28==4) | tipocontrato_ci==.) & categopri_ci==3
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci


*****************
***nempleos_ci***
*****************
gen nempleos_ci=.
replace nempleos_ci=1 if emp_ci==1
replace nempleos_ci=2 if emp_ci==1 & s5_40==1
label var nempleos_ci "N�mero de empleos" 
/*
*****************
***firmapeq_ci***
*****************
gen firmapeq_ci=.
replace firmapeq_ci=1 if  s5_27>=1 & s5_27<=5 
replace firmapeq_ci=0 if  s5_27>=6 & s5_27!=.
label var firmapeq_ci "Trabajadores informales"
 */
 
*****************
***spublico_ci***
*****************
gen spublico_ci=.
replace spublico_ci=1 if s5_22==1
replace spublico_ci=0 if s5_22==2 | s5_22==3
replace spublico_ci=. if emp_ci~=1
label var spublico_ci "Personas que trabajan en el sector p�blico"

**************
***ocupa_ci***
**************
*cob_op:
*NA: No se puede estandarizar ya que no se distingue entre dos categorias:
*comerciantes y vendedores y trabajadores en servicios 

* Modificacion MGD 07/24/2014: clasificacion CIUO -08
*rename  aux
gen aux=cods5_16a
destring aux, replace
gen ocupa_ci=.
replace ocupa_ci=1 if ((aux>=210 & aux<=352) | (aux>=20 & aux<=35))& emp_ci==1
replace ocupa_ci=2 if ((aux>=110 & aux<=149) | (aux>=10 & aux<=14)) & emp_ci==1
replace ocupa_ci=3 if ((aux>=410 & aux<=449) | (aux>=40 & aux<=44))& emp_ci==1
replace ocupa_ci=4 if ((aux>=520 & aux<=529) | aux==52 | (aux>=950 & aux<=952)) & emp_ci==1
replace ocupa_ci=5 if ((aux>=510 & aux<=519) | (aux>=530 & aux<=549) | aux==51 | (aux>=910 & aux<=912) | (aux>=960 & aux<=962)) & emp_ci==1
replace ocupa_ci=6 if ((aux>=610 & aux<=639) | (aux>=71 & aux<=83) | aux==61 | aux==62 | aux==92 | aux==921) & emp_ci==1
replace ocupa_ci=7 if ((aux>=710 & aux<=839) | (aux>=930 & aux<=949) | aux==93 | aux==94)& emp_ci==1
replace ocupa_ci=8 if (aux>=0 & aux<=5) & emp_ci==1
drop aux

label define ocupa_ci 1"profesional y tecnico" 2"director o funcionario sup" 3"administrativo y nivel intermedio"
label define ocupa_ci  4 "comerciantes y vendedores" 5 "en servicios" 6 "trabajadores agricolas", add
label define ocupa_ci  7 "obreros no agricolas, conductores de maq y ss de transporte", add
label define ocupa_ci  8 "FFAA" 9 "Otras ", add
label value ocupa_ci ocupa_ci
label variable ocupa_ci "Ocupacion laboral"

*************
***rama_ci***
*************
/*
act_prin:
0 Agricultura,Ganader�a,Caza,Pesca y Silv
1 Explotaci�n de Minas y Canteras
2 Industria Manufacturera
3 Suministro de electricidad,gas,vapor y
4 Suministro de agua, evac. de aguas res,
5 Construcci�n
6 Venta por mayor y menor,reparaci�n de a
7 Transporte y Almacenamiento
8 Actividades de alojamiento y servicio d
9 Informaciones y Comunicaciones
10 Intermediaci�n Financiera y Seguros
11 Actividades inmobiliarias
12 Servicios Profesionales y T�cnicos
13 Actividades de Servicios Administrativo
14 Adm. P�blica, Defensa y Seguridad Socia
15 Servicios de Educaci�n
16 Servicios de Salud y Asistencia Social
17 Actividades artisticas,entretenimiento
18 Otras actividades de servicios
19 Actividades de Hogares Privados
20 Servicio de Organismos Extraterritorial
99 NS/NR
*/ 

gen rama_ci=.
replace rama_ci=1 if caeb_op==0 & emp_ci==1
replace rama_ci=2 if caeb_op==1 & emp_ci==1
replace rama_ci=3 if caeb_op==2 & emp_ci==1
replace rama_ci=4 if (caeb_op==3 | caeb_op==4) & emp_ci==1
replace rama_ci=5 if caeb_op==5 & emp_ci==1
replace rama_ci=6 if (caeb_op>=6 & caeb_op<=8) & emp_ci==1 
replace rama_ci=7 if caeb_op==7 & emp_ci==1
replace rama_ci=8 if (caeb_op>=10 & caeb_op<=11) & emp_ci==1
replace rama_ci=9 if (caeb_op==9 | (caeb_op>=12 & caeb_op<=20)) & emp_ci==1
label var rama_ci "Rama de actividad"
label def rama_ci 1"Agricultura, caza, silvicultura y pesca" 2"Explotaci�n de minas y canteras" 3"Industrias manufactureras"
label def rama_ci 4"Electricidad, gas y agua" 5"Construcci�n" 6"Comercio, restaurantes y hoteles" 7"Transporte y almacenamiento", add
label def rama_ci 8"Establecimientos financieros, seguros e inmuebles" 9"Servicios sociales y comunales", add
label val rama_ci rama_ci

****************
***durades_ci***
****************
gen durades_ci=.
replace durades_ci=s5_13a/4.3  if s5_13b==2
replace durades_ci=s5_13a      if s5_13b==4
replace durades_ci=s5_13a*12   if s5_13b==8
label variable durades_ci "Duracion del desempleo en meses"

*******************
***antiguedad_ci***
*******************
gen antiguedad_ci=.	
replace antiguedad_ci=s5_19a/52.14  	if s5_19b==2 & emp_ci==1
replace antiguedad_ci=s5_19a/12   if s5_19b==4 & emp_ci==1
replace antiguedad_ci=s5_19a	   	if s5_19b==8 & emp_ci==1
label var antiguedad_ci "Antiguedad en la actividad actual en anios"

*******************
***categoinac_ci***
*******************
gen categoinac_ci =1 if (s5_14==3 & condocup_ci==3)
replace categoinac_ci = 2 if  ( s5_14==1 & condocup_ci==3)
replace categoinac_ci = 3 if  ( s5_14==2 & condocup_ci==3)
replace categoinac_ci = 4 if  ((categoinac_ci ~=1 & categoinac_ci ~=2 & categoinac_ci ~=3) & condocup_ci==3)
label var categoinac_ci "Categor�a de inactividad"
label define categoinac_ci 1 "jubilados o pensionados" 2 "Estudiantes" 3 "Quehaceres dom�sticos" 4 "Otros"

*******************
***formal***
*******************
gen formal=1 if cotizando_ci==1

replace formal=1 if afiliado_ci==1 & (cotizando_ci!=1 | cotizando_ci!=0) & condocup_ci==1 & pais_c=="BOL"   /* si se usa afiliado, se restringe a ocupados solamente*/
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


**************
***INGRESOS***
**************

*************************
*********LABORAL*********
*************************
/*
s2_38f:
1  diario
2  semanal
3  quincenal
4  mensual
8  anual
*/

*******************
* salario l�quido *
*******************
gen yliquido = .
replace yliquido= s5_31a*30		if s5_31b==1
replace yliquido= s5_31a*4.3	if s5_31b==2
replace yliquido= s5_31a*2		if s5_31b==3
replace yliquido= s5_31a		if s5_31b==4
replace yliquido= s5_31a/2		if s5_31b==5
replace yliquido= s5_31a/3		if s5_31b==6
replace yliquido= s5_31a/6		if s5_31b==7
replace yliquido= s5_31a/12		if s5_31b==8

**************
* comisiones *
**************

gen ycomisio = .
replace ycomisio= s5_33a1*30	if s5_33a2==1
replace ycomisio= s5_33a1*4.3	if s5_33a2==2
replace ycomisio= s5_33a1*2		if s5_33a2==3
replace ycomisio= s5_33a1		if s5_33a2==4
replace ycomisio= s5_33a1/2		if s5_33a2==5
replace ycomisio= s5_33a1/3		if s5_33a2==6
replace ycomisio= s5_33a1/6 	if s5_33a2==7
replace ycomisio= s5_33a1/12 	if s5_33a2==8

****************
* horas extras *
****************
gen yhrsextr= .
replace yhrsextr= s5_33b1*30	if s5_33b2==1
replace yhrsextr= s5_33b1*4.3	if s5_33b2==2
replace yhrsextr= s5_33b1*2		if s5_33b2==3
replace yhrsextr= s5_33b1		if s5_33b2==4
replace yhrsextr= s5_33b1/2		if s5_33b2==5
replace yhrsextr= s5_33b1/3		if s5_33b2==6
replace yhrsextr= s5_33b1/6	    if s5_33b2==7
replace yhrsextr= s5_33b1/12	if s5_33b2==8

*********
* prima *
*********

gen yprima = .
replace yprima = s5_32a/12
replace yprima =. if  s5_32a==999999


*************
* aguinaldo *
*************

gen yaguina = .
replace yaguina = s5_32b/12
replace yaguina=. if   s5_32b==999999

*************
* alimentos *
*************
gen yalimen = .
replace yalimen= s5_36a3*30		if s5_36a2==1 & s5_36a1==1
replace yalimen= s5_36a3*4.3	if s5_36a2==2 & s5_36a1==1
replace yalimen= s5_36a3*2		if s5_36a2==3 & s5_36a1==1
replace yalimen= s5_36a3		if s5_36a2==4 & s5_36a1==1
replace yalimen= s5_36a3/2		if s5_36a2==5 & s5_36a1==1
replace yalimen= s5_36a3/3		if s5_36a2==6 & s5_36a1==1
replace yalimen= s5_36a3/6		if s5_36a2==7 & s5_36a1==1
replace yalimen= s5_36a3/12		if s5_36a2==8 & s5_36a1==1

**************
* transporte *
**************
/* No hay la categoria 7 de semestral en s6_32b2
 1  diario
 2  semanal
 3  quincenal
 4  mensual
 5  bimestral
 6  trimestral
 8  anual
*/
gen ytranspo = .
replace ytranspo= s5_36b3*30	if s5_36b2==1 & s5_36b1==1
replace ytranspo= s5_36b3*4.3	if s5_36b2==2 & s5_36b1==1
replace ytranspo= s5_36b3*2		if s5_36b2==3 & s5_36b1==1
replace ytranspo= s5_36b3		if s5_36b2==4 & s5_36b1==1
replace ytranspo= s5_36b3/2		if s5_36b2==5 & s5_36b1==1
replace ytranspo= s5_36b3/3		if s5_36b2==6 & s5_36b1==1
replace ytranspo= s5_36b3/12	if s5_36b2==8 & s5_36b1==1

**************
* vestimenta *
**************
/* No hay las categorias 1 y 2 de diario y semanal s6_32c2
 3  quincenal
 4  mensual
 5  bimestral
 6  trimestral
 7  semestral
 8  anual
*/

gen yvesti = .
replace yvesti= s5_36c3*2		if s5_36c2==3 & s5_36c1==1
replace yvesti= s5_36c3			if s5_36c2==4 & s5_36c1==1
replace yvesti= s5_36c3/2		if s5_36c2==5 & s5_36c1==1
replace yvesti= s5_36c3/3		if s5_36c2==6 & s5_36c1==1
replace yvesti= s5_36c3/6		if s5_36c2==7 & s5_36c1==1
replace yvesti= s5_36c3/12		if s5_36c2==8 & s5_36c1==1

************
* vivienda *
************
* No hay la categoria 5 de bimestrall s6_32d2

gen yvivien = .
replace yvivien= s5_36d3*30		if s5_36d2==1 & s5_36d1==1
replace yvivien= s5_36d3*4.3	if s5_36d2==2 & s5_36d1==1
replace yvivien= s5_36d3*2		if s5_36d2==3 & s5_36d1==1
replace yvivien= s5_36d3		if s5_36d2==4 & s5_36d1==1
replace yvivien= s5_36d3/3		if s5_36d2==6 & s5_36d1==1
replace yvivien= s5_36d3/6		if s5_36d2==7 & s5_36d1==1
replace yvivien= s5_36d3/12		if s5_36d2==8 & s5_36d1==1



*************
* otros *
*************
/*
1  diario
2  semanal
4  mensual
6  trimestral
7  semestral
8  anual
*/
gen yotros = .
replace yotros= s5_36e3*30		if s5_36e2==1 & s5_36e1==1
replace yotros= s5_36e3*4.3	    if s5_36e2==2 & s5_36e1==1
replace yotros= s5_36e3		    if s5_36e2==4 & s5_36e1==1
replace yotros= s5_36e3/3		if s5_36e2==6 & s5_36e1==1
replace yotros= s5_36e3/6		if s5_36e2==7 & s5_36e1==1
replace yotros= s5_36e3/12		if s5_36e2==8 & s5_36e1==1


**********************************
* ingreso act. pr independientes *
**********************************
*Aqu� se tiene en cuenta el monto de dinero que les queda a los independientes para el uso del hogar
gen yactpri = .
replace yactpri= s5_39a*30		if s5_39b==1
replace yactpri= s5_39a*4.3		if s5_39b==2
replace yactpri= s5_39a*2		if s5_39b==3
replace yactpri= s5_39a			if s5_39b==4
replace yactpri= s5_39a/2		if s5_39b==5
replace yactpri= s5_39a/3		if s5_39b==6
replace yactpri= s5_39a/6		if s5_39b==7
replace yactpri= s5_39a/12		if s5_39b==8


*********************
* salario liquido 2 *
*********************
/* No hay las categorias de semestral y anual
  1  diario
  2  semanal
  3  quincenal
  4  mensual
  5  bimestral
  6  trimestral
*/

gen yliquido2 = .
replace yliquido2= s5_48a*30	if s5_48b==1
replace yliquido2= s5_48a*4.3	if s5_48b==2
replace yliquido2= s5_48a*2		if s5_48b==3
replace yliquido2= s5_48a		if s5_48b==4
replace yliquido2= s5_48a/2		if s5_48b==5
replace yliquido2= s5_48a/3		if s5_48b==6

*****************
* Horas extra 2 *
*****************


gen yhrsextr2 = .
replace yhrsextr2=s5_49a2/12 if s5_49a1==1


***************************************
* alimentos, transporte y vestimenta2 *
***************************************


gen yalimen2 = .
replace yalimen2= s5_49b2/12	if s5_49b1==1


**************
* vivienda 2 *
**************

gen yvivien2= .
replace yvivien2= s5_49c2/12	if s5_49c1==1


*************************
******NO-LABORAL*********
*************************

*************
* intereses *
*************
gen yinteres = .
replace yinteres = s6_02a	

**************
* alquileres *
**************

gen yalqui = .
replace yalqui = s6_02b		


**************
* jubilacion *
**************

gen yjubi = .
replace yjubi = s6_01a

**************
* benemerito *
**************

gen ybene = .
replace ybene = s6_01b

*************
* invalidez *
*************

gen yinvali = .
replace yinvali = s6_01c

**********
* viudez *
**********

gen yviudez = .
replace yviudez = s6_01d


****************
* otras rentas *
****************

gen yotren = .
replace yotren = s6_02c		


************************
* alquileres agricolas *
************************

gen yalqagri = .
replace yalqagri =  s6_03a/12		


**************
* dividendos *
**************

gen ydivi = .
replace ydivi =  s6_03b/12


*************************
* alquileres maquinaria *
*************************

gen yalqmaqui = .
replace yalqmaqui = s6_03c/12

 
******************
* indem. trabajo *
******************

gen yindtr = .
replace yindtr =  s6_04a/12


******************
* indem. seguros *
******************

gen yindseg = .
replace yindseg = s6_04b/12


***********
* bonosol *
***********

gen ybono = .
*replace ybono = s6_01ea/12
*2012, 02, Modificacion MLO
*este a�o estan mensuales segun el cuestionario en un principio se pagaba anualmente, pero luego cambio a pago mensual
replace ybono = s6_01eb

******************
* otros ingresos *
******************

gen yotring = .
replace yotring = s6_04c/12



*******************
* asist. familiar *
*******************
/*
  2  semanal
  3  quincenal
  4  mensual
  5  bimestral
  6  trimestral
  7  semestral
  8  anual
*/
* No hay la categoria de diario en s6_05a2
gen yasistfam = .
replace yasistfam= s6_05a1*4.3		if s6_05a2==2
replace yasistfam= s6_05a1*2		if s6_05a2==3
replace yasistfam= s6_05a1			if s6_05a2==4
replace yasistfam= s6_05a1/2		if s6_05a2==5
replace yasistfam= s6_05a1/3		if s6_05a2==6
replace yasistfam= s6_05a1/6		if s6_05a2==7
replace yasistfam= s6_05a1/12		if s6_05a2==8


*********************
* Trans. monetarias *
*********************
* No hay la categoria de diario en s6_05b2

gen ytransmon = .
replace ytransmon= s6_05b1*4.3		if s6_05b2==2
replace ytransmon= s6_05b1*2		if s6_05b2==3
replace ytransmon= s6_05b1			if s6_05b2==4
replace ytransmon= s6_05b1/2		if s6_05b2==5
replace ytransmon= s6_05b1/3		if s6_05b2==6
replace ytransmon= s6_05b1/6		if s6_05b2==7
replace ytransmon= s6_05b1/12		if s6_05b2==8

***********
* remesas *
***********
/*
    MONEDA

A1. BOLIVIANOS 
B2. EUROS
C3. D�LARES
D4. PESOS ARGENTINOS
E5. REALES
F6. PESOS CHILENOS
G7. SOLES
8. OTRO (Especifique) 

http://www.bcb.gob.bo/?q=indicadores/cotizaciones
Al 1 de noviembre de 2012
*/

gen s6_112= .
replace s6_112 =  s6_09a 			if s6_09b== "A" /*bolivianos*/
replace s6_112 =  s6_09a*8.81	    if s6_09b== "B" /*euro*/
replace s6_112 =  s6_09a*6.86		if s6_09b== "C" /*dolar*/
replace s6_112 =  s6_09a*1.44 	    if s6_09b== "D" /*peso argentino*/
replace s6_112 =  s6_09a*3.37   	if s6_09b== "E" /*real*/
replace s6_112 =  s6_09a*0.01426	if s6_09b== "F" /*peso chileno*/
replace s6_112 =  s6_09a*2.64253   	if s6_09b== "G" /*soles*/

gen yremesas = .
replace yremesas= s6_112*4.3		if s6_07==2
replace yremesas= s6_112*2		    if s6_07==3
replace yremesas= s6_112			if s6_07==4
replace yremesas= s6_112/2			if s6_07==5
replace yremesas= s6_112/3			if s6_07==6
replace yremesas= s6_112/6			if s6_07==7
replace yremesas= s6_112/12		    if s6_07==8

/* 
ylm:
yliquido 
ycomisio 
ypropinas 
yhrsextr 
yprima 
yaguina
yactpri 
yliquido2

ylnm:
yrefrige 
yalimen 
ytranspo 
yvesti 
yvivien 
yguarde */


***************
***ylmpri_ci***
***************

egen ylmpri_ci=rsum(yliquido ycomisio yhrsextr yprima yaguina yactpri), missing
replace ylmpri_ci=. if yliquido ==. & ycomisio ==. &  yhrsextr ==. & yprima ==. &  yaguina ==. &  yactpri==.  
replace ylmpri_ci=. if emp_ci~=1
replace ylmpri_ci=0 if categopri_ci==4
label var ylmpri_ci "Ingreso laboral monetario actividad principal" 


*******************
*** nrylmpri_ci ***
*******************

gen nrylmpri_ci=(ylmpri_ci==. & emp_ci==1)
label var nrylmpri_ci "Id no respuesta ingreso de la actividad principal"  


******************
*** ylnmpri_ci ***
******************

egen ylnmprid=rsum(yalimen ytranspo yvesti yvivien yotros), missing
replace ylnmprid=. if yalimen==. & ytranspo==. & yvesti==. & yvivien==. & yotros==.   
replace ylnmprid=0 if categopri_ci==4
replace ylnmprid=. if  ylnmprid>=3000000
*Ingreso laboral no monetario de los independientes (autoconsumo)

gen ylnmprii=.

*Ingreso laboral no monetario para todos

egen ylnmpri_ci=rsum(ylnmprid ylnmprii), missing
replace ylnmpri_ci=. if ylnmprid==. & ylnmprii==.
replace ylnmpri_ci=. if emp_ci~=1
label var ylnmpri_ci "Ingreso laboral NO monetario actividad principal"   


***************
***ylmsec_ci***
***************

egen ylmsec_ci= rsum(yliquido2 yhrsextr2), missing
replace ylmsec_ci=. if emp_ci~=1 & yhrsextr2==. & yliquido2 ==.
replace ylmsec_ci=0 if categosec_ci==4
label var ylmsec_ci "Ingreso laboral monetario segunda actividad" 


******************
****ylnmsec_ci****
******************

egen ylnmsec_ci=rsum(yalimen2  yvivien2), missing
replace ylnmsec_ci=. if yalimen2==.  & yvivien2==.  
replace ylnmsec_ci=0 if categosec_ci==4
replace ylnmsec_ci=. if emp_ci==0
label var ylnmsec_ci "Ingreso laboral NO monetario actividad secundaria"

**********************************************************************************************
***TCYLMPRI_CH : Identificador de los hogares en donde alguno de los miembros reporta como
*** top-code el ingreso de la actividad principal. .
***********************************************************************************************
gen tcylmpri_ch = .
label var tcylmpri_ch "Id hogar donde alg�n miembro reporta como top-code el ingr de activ. principal"

***********************************************************************************************
***TCYLMPRI_CI : Identificador de top-code del ingreso de la actividad principal.
***********************************************************************************************
gen tcylmpri_ci = .
label var tcylmpri_ci "Identificador de top-code del ingreso de la actividad principal"

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


************
***ylm_ci***
************

egen ylm_ci=rsum(ylmpri_ci ylmsec_ci), missing
replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==.
label var ylm_ci "Ingreso laboral monetario total"  


*************
***ylnm_ci***
*************

egen ylnm_ci=rsum(ylnmpri_ci ylnmsec_ci), missing
replace ylnm_ci=. if ylnmpri_ci==. & ylnmsec_ci==.
label var ylnm_ci "Ingreso laboral NO monetario total"  


 
/* 

ynlm:

yinteres 
yalqui 
yjubi 
ybene 
yinvali 
yviudez 
yotren  
yalqagri 
ydivi 
yalqmaqui  
yindtr  
yindseg 
yheren 
ypasu 
ybono  
yotring  
yasistfam 
ytransmon 
yremesas 
yinvers 
yhipotec 
ybonos 
ypresta 
yprestata 
yinmueb 
yinmrur 
yvehi 
yelec 
ymuebles 
yjoyas */



*************
***ynlm_ci***
*************

egen ynlm_ci=rsum(yinteres yalqui yjubi ybene yinvali yviudez yotren yalqagri ydivi yalqmaqui yindtr yindseg ybono yotring yasistfam ytransmon yremesas ), missing
replace ynlm_ci=. if 	yinteres==. & yalqui==. & yjubi==. & ybene==. & yinvali==. & yviudez==. & yotren==. & yalqagri==. & ydivi==. & yalqmaqui==. & yindtr==. & yindseg==. & ///
			ybono==. & yotring==. & yasistfam==. & ytransmon==. & yremesas==. 
label var ynlm_ci "Ingreso no laboral monetario"  


**************
***ynlnm_ci***
**************

gen ynlnm_ci=.
label var ynlnm_ci "Ingreso no laboral no monetario" 


*****************
***remesas_ci***
*****************

gen remesas_ci=yremesas
label var remesas_ci "Remesas mensuales reportadas por el individuo" 




************************
*** HOUSEHOLD INCOME ***
************************

*******************
*** nrylmpri_ch ***
*******************
by idh_ch, sort: egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1, missing
replace nrylmpri_ch=1 if nrylmpri_ch>0 & nrylmpri_ch<.
replace nrylmpri_ch=. if nrylmpri_ch==.
label var nrylmpri_ch "Hogares con alg�n miembro que no respondi� por ingresos"

**************
*** ylm_ch ***
**************
by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing
label var ylm_ch "Ingreso laboral monetario del hogar"

****************
*** ylmnr_ch ***
****************
by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1, missing
replace ylmnr_ch=. if nrylmpri_ch==1
label var ylmnr_ch "Ingreso laboral monetario del hogar"

***************
*** ylnm_ch ***
***************
by idh_ch, sort: egen ylnm_ch=sum(ylnm_ci) if miembros_ci==1, missing
label var ylnm_ch "Ingreso laboral no monetario del hogar"

*******************
*** remesas_ch ***
*******************
by idh_ch, sort: egen remesas_ch=sum(remesas_ci) if miembros_ci==1, missing
label var remesas_ch "Remesas mensuales del hogar" 

***************
*** ynlm_ch ***
***************
by idh_ch, sort: egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, missing
label var ynlm_ch "Ingreso no laboral monetario del hogar"

****************
*** ynlnm_ch ***
****************
gen ynlnm_ch=.
label var ynlnm_ch "Ingreso no laboral no monetario del hogar"

*******************
*** autocons_ci ***
*******************
gen autocons_ci=.
label var autocons_ci "Autoconsumo reportado por el individuo"

*******************
*** autocons_ch ***
*******************
gen autocons_ch=.
label var autocons_ch "Autoconsumo reportado por el hogar"

*******************
*** rentaimp_ch ***
*******************
gen rentaimp_ch= .
label var rentaimp_ch "Rentas imputadas del hogar"

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

/*En esta secci�n es s�lo para los mayores a los 5 a�os de edad*/

/*
capture gen byte aedu_ci=.

replace aedu_ci=0 if s4_02a==11 | s4_02a==12 | s4_02a==13 

replace aedu_ci=1 if (s4_03a==14 | s4_02a==17 | s4_02a==19 ) & s4_02b==1
replace aedu_ci=2 if (s4_03a==14 | s4_02a==17 | s4_02a==19 ) & s4_02b==2
replace aedu_ci=3 if (s4_03a==14 | s4_02a==17 | s4_02a==19 ) & s4_02b==3
replace aedu_ci=4 if (s4_03a==14 | s4_02a==17 | s4_02a==19 ) & s4_02b==4
replace aedu_ci=5 if (s4_03a==14 | s4_02a==17 | s4_02a==19 ) & s4_02b==5

replace aedu_ci=6 if (s4_02a==17 | s4_02a==19 ) & s4_02b==6
replace aedu_ci=6 if s4_02a==15 & s4_02b==1

replace aedu_ci=7 if (s4_02a==17) & s4_02b==7
replace aedu_ci=7 if (s4_02a==20) & s4_02b==1
replace aedu_ci=7 if (s4_02a==15) & s4_02b==2

replace aedu_ci=8 if (s4_02a==17) & s4_02b==8
replace aedu_ci=8 if (s4_02a==20) & s4_02b==2
replace aedu_ci=8 if (s4_02a==15) & s4_02b==3

replace aedu_ci=9 if (s4_02a==18 | s4_02a==16) & s4_02b==1
replace aedu_ci=9 if (s4_02a==20) & s4_02b==3

replace aedu_ci=10 if (s4_02a==18 | s4_03a==16) & s4_02b==2
replace aedu_ci=10 if (s4_02a==20) & s4_02b==4

replace aedu_ci=11 if (s4_02a==20) & s4_02b==5
replace aedu_ci=11 if (s4_03a==16 | s4_02a==18) & s4_02b==3

replace aedu_ci=12 if (s4_03a==16 | s4_02a==18) & s4_02b==4
replace aedu_ci=12 if (s4_02a==20) & s4_02b==6

replace aedu_ci=13 if (s4_02a>=28 & s4_02a<=30)| (s4_02a>=34 & s4_02a<=36) & s4_02b==1
replace aedu_ci=14 if (s4_02a>=28 & s4_02a<=30)| (s4_02a>=34 & s4_02a<=36) & s4_02b==2
replace aedu_ci=15 if (s4_02a>=28 & s4_02a<=30)| (s4_02a>=34 & s4_02a<=36) & s4_02b==3
replace aedu_ci=16 if (s4_02a>=28 & s4_02a<=30)| (s4_02a>=34 & s4_02a<=36) & s4_02b==4

replace aedu_ci=16 if (s4_02a==28 | s4_02a==34 | s4_02a==35) & s4_02b==5
replace aedu_ci=17 if (s4_02a==29 | s4_02a==30 | s4_02a==36) & s4_02b==5

replace aedu_ci=16 if (s4_02a==28 | s4_02a==34 | s4_02a==35) & s4_02b==8
replace aedu_ci=17 if (s4_02a==29 | s4_02a==30 | s4_02a==36) & s4_02b==8

replace aedu_ci=18 if (s4_02a==31 | s4_02a==32 | s4_02a==33) & s4_02b==1
replace aedu_ci=19 if (s4_02a==31 | s4_02a==32 | s4_02a==33) & s4_02b==2
replace aedu_ci=20 if (s4_02a==31 | s4_02a==32 | s4_02a==33) & s4_02b==5
replace aedu_ci=21 if (s4_02a==31 | s4_02a==32 | s4_02a==33) & s4_02b==8

label var aedu_ci "Anios de educacion aprobados" 

*/

* Modificaciones Marcela Rubio - Septiembre 2014 

/*
 s4_02a

CERO A�OS DE EDUCACI�N
          11 ninguno
          12 curso de alfabetizaci�n
          13 educaci�n pre-escolar
		  37 otros cursos (menor a 1 a�o)

PRIMARIA
          14 antiguo-b�sico (1 a 5 a�os)
          15 antiguo-intermedio (1 a 3 a�os)
          16 antiguo-medio (1 a 4 a�os)
          17 anterior-primaria (1 a 8 a�os)
		  19 actual-primaria (1 a 6 a�os)
          
SECUNDARIA
		  18 anterior-secundaria (1 a 4 a�os)
          20 actual-secundaria (1 a 6 a�os)
          
SUPERIOR
          28 normal
          29 universidad  p�blica (licenciatura)
          30 universidad privada (licenciatura)
          31 posgrado diplomado
          32 postgrado maestr�a
          33 postgrado doctorado
          34 t�cnico de universidad
          35 t�cnico de instituto (mayor o igual a un a�o)
          36 institutos de formacion militar y policial

		  
*No se consideran por no ser educaci�n formal sino "Alternativa" o "No formal"
		  21 educacion b�sica de adultos (eba)
          22 centro de educaci�n media de adultos (cema)
          23 educacion juvenil alternativa (eja)
          24 educaci�n primaria de adultos(epa)
          25 educaci�n secundaria de adultos (esa)
          26 educaci�n t�cnica de adultos (eta)
          27 educaci�n especial
		  

*/

gen aedu_ci = .

* Ninguno o preescolar
replace aedu_ci = 0 if s4_02a==11 | s4_02a==12 | s4_02a==13

*Primaria & Secundaria
replace aedu_ci = 1 if s4_02b==1 & (s4_02a==14 | s4_02a==17 | s4_02a==19)
replace aedu_ci = 2 if s4_02b==2 & (s4_02a==14 | s4_02a==17 | s4_02a==19)
replace aedu_ci = 3 if s4_02b==3 & (s4_02a==14 | s4_02a==17 | s4_02a==19)
replace aedu_ci = 4 if s4_02b==4 & (s4_02a==14 | s4_02a==17 | s4_02a==19)
replace aedu_ci = 5 if s4_02b==5 & (s4_02a==14 | s4_02a==17 | s4_02a==19)
replace aedu_ci = 6 if (s4_02b==6 & (s4_02a==17 | s4_02a==19)) |  (s4_02b==1 & s4_02a==15)
replace aedu_ci = 7 if (s4_02b==7 & s4_02a==17) |  (s4_02b==2 & s4_02a==15) | (s4_02b==1 & s4_02a==20) 
replace aedu_ci = 8 if (s4_02b==8 & s4_02a==17) |  (s4_02b==3 & s4_02a==15) | (s4_02b==2 & s4_02a==20)
replace aedu_ci = 9 if (s4_02b==1 & s4_02a==16) |  (s4_02b==1 & s4_02a==18) | (s4_02b==3 & s4_02a==20)
replace aedu_ci = 10 if (s4_02b==2 & s4_02a==16) |  (s4_02b==2 & s4_02a==18) | (s4_02b==4 & s4_02a==20)
replace aedu_ci = 11 if (s4_02b==3 & s4_02a==16) |  (s4_02b==3 & s4_02a==18) | (s4_02b==5 & s4_02a==20)
replace aedu_ci = 12 if (s4_02b==4 & s4_02a==16) |  (s4_02b==4 & s4_02a==18) | (s4_02b==6 & s4_02a==20)

* Superior

replace aedu_ci = 13 if s4_02b==1 & (s4_02a==28 |  s4_02a==29 | s4_02a==30 |  s4_02a==34 | s4_02a==35 | s4_02a==36)
replace aedu_ci = 14 if s4_02b==2 & (s4_02a==28 |  s4_02a==29 | s4_02a==30 |  s4_02a==34 | s4_02a==35 | s4_02a==36)
replace aedu_ci = 15 if s4_02b==3 & (s4_02a==28 |  s4_02a==29 | s4_02a==30 |  s4_02a==34 | s4_02a==35 | s4_02a==36)
replace aedu_ci = 16 if s4_02b==4 & (s4_02a==28 |  s4_02a==29 | s4_02a==30 |  s4_02a==34 | s4_02a==35 | s4_02a==36)
replace aedu_ci = 17 if (s4_02b>=5 & s4_02b<=8) & (s4_02a==28 |  s4_02a==29 | s4_02a==30 |  s4_02a==29 | s4_02a==30 | s4_02a==34 | s4_02a==35 | s4_02a==36)

replace aedu_ci = 18 if s4_02b==1 & (s4_02a==31 |  s4_02a==32 | s4_02a==33)
replace aedu_ci = 19 if s4_02b==2 & (s4_02a==31 |  s4_02a==32 | s4_02a==33)
replace aedu_ci = 20 if s4_02b==3 & (s4_02a==31 |  s4_02a==32 | s4_02a==33)
replace aedu_ci = 21 if (s4_02b>=4 & s4_02b<=8) & (s4_02a==31 |  s4_02a==32)
replace aedu_ci = 21 if (s4_02b==4 & s4_02a==33)
replace aedu_ci = 22 if (s4_02b==5 & s4_02a==33)
replace aedu_ci = 22 if (s4_02b==8 & s4_02a==33)

**************
***eduno_ci***
**************

gen byte eduno_ci= 1 if aedu_ci == 0
replace eduno_ci= 0 if aedu_ci > 0
replace eduno_ci=. if aedu_ci==.
label variable eduno_ci "Cero anios de educacion"

**************
***edupi_ci***
**************

gen byte edupi_ci=(aedu_ci>=1 & aedu_ci<=5)
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

gen byte edusi_ci=(aedu_ci>=7 & aedu_ci<=11)
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

gen byte edus1i_ci=(aedu_ci>=6 & aedu_ci<=7)
replace edus1i_ci=. if aedu_ci==.
label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************

gen byte edus1c_ci=(aedu_ci==8)
replace edus1c_ci=. if aedu_ci==.
label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************

gen byte edus2i_ci=(aedu_ci>=9 & aedu_ci<=11)
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
* LCM: Se incorpora la restricci�n s4_02b<8 para que sea comparable con los otros a�os LCM dic 2013

gen byte eduui_ci=(aedu_ci>=13 & aedu_ci<=16 & s4_02b<8)
replace eduui_ci=. if aedu_ci==.
label variable eduui_ci "Universitaria incompleta"

***************
***eduuc_ci***
***************
/*
gen byte eduuc_ci=0
replace eduuc_ci=1 if (aedu_ci==17)
replace eduuc_ci=. if aedu_ci==.
*/
* LMC: Se cambia para universidad completa o m�s LCM DIC 2013
gen byte eduuc_ci=0
replace eduuc_ci=1 if (aedu_ci==16 & s4_02b==8) | (aedu_ci>=17 & aedu_ci<.)
replace eduuc_ci=. if aedu_ci==.
label variable eduuc_ci "Universitaria completa"

***************
***edupre_ci***
***************

gen byte edupre_ci=(s4_02a==13)
replace edupre_ci=. if aedu_ci==.
label variable edupre_ci "Educacion preescolar"

***************
***asispre_ci***
***************
*Variable a�adida por Iv�n Bornacelly - 01/12/2017
	g asispre_ci=.	
	replace asispre_ci=1 if s4_04==1 & s4_05a==13
	recode asispre_ci (.=0)
	la var asispre_ci "Asiste a educacion prescolar"

**************
***eduac_ci***
**************
/*gen byte eduac_ci=.
replace eduac_ci=1 if (s4_02a>=26 & s4_02a<=31)
replace eduac_ci=0 if (s4_02a==25 | s4_02a==32 | s4_02a==33)
*/

* LCM: Se cambia para universidad completa o m�s LCM DIC 2013
gen byte eduac_ci=.
replace eduac_ci=1 if (s4_02a>=30 & s4_02a<=35 | s4_02a==37)
replace eduac_ci=0 if (s4_02a==29 | s4_02a>=36 )
label variable eduac_ci "Superior universitario vs superior no universitario"
/*cambio de eduuc_ci de LCM introcucido por YL solo para este a�o.
YL: No estoy segura de aceptar esta definicion pero la copio para hacerla comparable con
los otros a�os*/

***************
***asiste_ci***
***************

*gen asiste_ci=(s4_12==1)

*LCM (introduciso por YL): Se cambia la forma de c�lculo porque se deben considerar los rangos de edad lcm dic2013
*Modificaci�n Mayra S�enz Enero-2017: Se genera la dummy de acuerdo al documento metodol�gico.
gen asiste_ci= s4_04==1
/* 
gen asiste_ci= 1 if s4_04==1
replace asiste_ci = 0 if s4_04==2*/
label variable asiste_ci "Asiste actualmente a la escuela"

**************
***pqnoasis***
**************

gen pqnoasis_ci=s4_13 if s4_13 != 99
label var pqnoasis_ci "Razones para no asistir a la escuela"
label def pqnoasis_ci 1"vacaci�n/receso" 2"falta de dinero" 3"por trabajo" 4"por enfermedad/accidente/discapacidad"
label def pqnoasis_ci 5"los establecimientos son distantes" 6"culmin� sus estudios" 7"edad temprana/ edad avanzada", add
label def pqnoasis_ci 8"falta de inter�s" 9"labores de casa/ embarazo/cuidado de ni�os/as" 10"otra", add
label val pqnoasis_ci pqnoasis 

**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**
	
**************
*pqnoasis1_ci*
**************
gen pqnoasis1_ci = 1 if s4_13==2
replace pqnoasis1_ci = 2 if s4_13==3
replace pqnoasis1_ci = 3 if s4_13==4 
replace pqnoasis1_ci = 4 if s4_13==8
replace pqnoasis1_ci = 5 if s4_13==9 
replace pqnoasis1_ci = 6 if s4_13==6 
replace pqnoasis1_ci = 7 if s4_13==7  
replace pqnoasis1_ci = 8 if s4_13==5
replace pqnoasis1_ci = 9 if s4_13==1  | s4_13==10

label define pqnoasis1_ci 1 "Problemas econ�micos" 2 "Por trabajo" 3 "Problemas familiares o de salud" 4 "Falta de inter�s" 5	"Quehaceres dom�sticos/embarazo/cuidado de ni�os/as" 6 "Termin� sus estudios" 7	"Edad" 8 "Problemas de acceso"  9 "Otros"
label value  pqnoasis1_ci pqnoasis1_ci


***************
***repite_ci***
***************

gen repite_ci=.
label var repite_ci "Ha repetido al menos un grado"


******************
***repiteult_ci***
******************

gen repiteult_ci=(s4_11a ==1)
replace repiteult_ci=. if s4_11a==.
label var repiteult "Ha repetido el �ltimo grado"


***************
***edupub_ci***
***************
/*Sobre los que se matricularon ese a�o*/
/*
s4_10:
   
		   
		     1 fiscal - p�blico
           2 p�blico de convenio
           3 particular - privado

*/


gen edupub_ci=(s4_10==1 | s4_10==2)
replace edupub_ci=. if s4_10==.
label var edupub_ci "Asiste a un centro de ensenanza p�blico"

**************
***tecnica_ci*
**************

gen tecnica_ci=.
replace tecnica_ci=1 if s4_02a==34 | s4_02a==35 
recode tecnica_ci .=0 
label var tecnica_ci "1=formacion terciaria tecnica"


**********************************
**** VARIABLES DE LA VIVIENDA ****
**********************************


****************
***aguared_ch***
****************

/*s8_09:
		
1 ca�er�a de red dentro de la vivienda?	
2 ca�er�a de red fuera de la vivienda
3 ca�er�a de red con pileta p�blica	
4 pozo entubado-perforado-con bomba?	
5 pozo excavado protegido-con bomba?	
6 manantial o vertiente protegido?	
7 pozo excavado no protegido, con o sin b
8 r�o-acequia-vertiente no protegida?
9 agua de lluvia?	
10 agua embotellada?	
11 carro repartidor (aguatero)?	
12 otro	
*/

gen aguared_ch=(s8_09==1 | s8_09==2 | s8_10==3)
replace aguared_ch=. if s8_10==.
label var aguared_ch "Acceso a fuente de agua por red"


****************
***aguared_ch***
****************


gen aguadist_ch=1 if s8_09==1
replace aguadist_ch=2 if s8_09==2
replace aguadist_ch=3 if (s8_09==3 | s8_09==11)
label var aguadist_ch "Ubicaci�n de la principal fuente de agua"
label def aguadist_ch 1"Dentro de la vivienda" 2"Fuera de la vivienda pero en el terreno"
label def aguadist_ch 3"Fuera de la vivienda y del terreno", add
label val aguadist_ch aguadist_ch


*****************
***aguamala_ch***
*****************

gen aguamala_ch=(s8_09==6 | s8_09==7 | s8_09==8 | s8_09==9)
replace aguamala_ch=. if s8_09==.
label var aguamala_ch "Agua unimproved seg�n MDG" 


*****************
***aguamide_ch***
*****************

gen aguamide_ch=.
label var aguamide_ch "Usan medidor para pagar consumo de agua"


************
***luz_ch***
************

gen luz_ch=(s8_14==1)
replace luz_ch =. if  s8_14== .
label var luz_ch  "La principal fuente de iluminaci�n es electricidad"


****************
***luzmide_ch***
****************

gen luzmide_ch=.
label var luzmide_ch "Usan medidor para pagar consumo de electricidad"


****************
***combust_ch***
****************

gen combust_ch= (s8_20==5 | s8_20== 7)
replace combust_ch = . if s8_20==.
label var combust_ch "Principal combustible gas o electricidad" 


*************
***bano_ch***
*************

gen bano_ch= (s8_11==1 | s8_11==2 | s8_11==3)
label var bano_ch "El hogar tiene servicio sanitario"


***************
***banoex_ch***
***************

gen banoex_ch=(s8_13==1)
label var banoex_ch "El servicio sanitario es exclusivo del hogar"


*************
***des1_ch***
*************
/*
1 alcantarilado 
2 septica
3 pozo de absorcion
4 a la superficie
5 otro
6 no sabe
*/

gen des1_ch=.
replace des1_ch=0 if bano_ch==0
replace des1_ch=1 if s8_12==1 | s8_12==2
replace des1_ch=2 if s8_12==3
replace des1_ch=3 if s8_12==4
label var des1_ch "Tipo de desague seg�n unimproved de MDG"
label def des1_ch 0"No tiene servicio sanitario" 1"Conectado a red general o c�mara s�ptica"
label def des1_ch 2"Letrina o conectado a pozo ciego" 3"Desemboca en r�o o calle", add
label val des1_ch des1_ch


*************
***des2_ch***
*************

gen des2_ch=.
replace des2_ch=0 if bano_ch==0
replace des2_ch=1 if s8_12==1 | s8_12==2 | s8_12==3 
replace des2_ch=2 if s8_12==4
label var des2_ch "Tipo de desague sin incluir definici�n MDG"
label def des2_ch 0"No tiene servicio sanitario" 1"Conectado a red general, c�mara s�ptica, pozo o letrina"
label def des2_ch 2"Cualquier otro caso", add
label val des2_ch des2_ch


*************
***piso_ch***
*************

gen piso_ch=0 if  s8_08==1 
replace piso_ch=1 if  s8_08>=2 &  s8_08<=7 
replace piso_ch=2 if  s8_08==8
label var piso_ch "Materiales de construcci�n del piso"  
label def piso_ch 0"Piso de tierra" 1"Materiales permanentes" 2 "Otros materiales"
label val piso_ch piso_ch


**************
***pared_ch***
**************

gen pared_ch=0 if s8_05 ==6
replace pared_ch=1 if s8_05==1 | s8_05==2 | s8_05==3 | s8_05==4 | s8_05==5
replace pared_ch=2 if s8_05==7
label var pared_ch "Materiales de construcci�n de las paredes"
label def pared_ch 0"No permanentes" 1"Permanentes" 2 "Otros materiales"
label val pared_ch pared_ch


**************
***techo_ch***
**************

gen techo_ch=0 if s8_07==4
replace techo_ch=1 if s8_07>=1 & s8_07<=3
replace techo_ch=2 if s8_07==5
label var techo_ch "Materiales de construcci�n del techo"
label def techo_ch 0"No permanentes" 1"Permanentes" 2 "Otros materiales"
label val techo_ch techo_ch


**************
***resid_ch***
**************


gen resid_ch =0    if s8_16  ==6
replace resid_ch=1 if s8_16  ==4 | s8_16  ==2
replace resid_ch=2 if s8_16  ==1 | s8_16  ==3
replace resid_ch=3 if s8_16  ==5 | s8_16  ==7
replace resid_ch=. if s8_16  ==.
label var resid_ch "M�todo de eliminaci�n de residuos"
label def resid_ch 0"Recolecci�n p�blica o privada" 1"Quemados o enterrados"
label def resid_ch 2"Tirados a un espacio abierto" 3"Otros", add
label val resid_ch resid_ch


**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
*********************
***aguamejorada_ch***
*********************
gen aguamejorada_ch = 1 if (s8_09 >= 1 &  s8_09 <=6) | s8_09 ==9
replace aguamejorada_ch = 0 if (s8_09 >= 7 &  s8_09 <=8) | (s8_09 >= 10 &  s8_09 <=12)
		
		
*********************
***banomejorado_ch***
*********************
gen  banomejorado_ch = 1 if ((s8_11 >= 1 & s8_11 <=2) & (s8_12 >= 1 & s8_12 <=3) & s8_13== 1)
replace banomejorado_ch = 0 if ((s8_11 >= 1 & s8_11 <=2) & (s8_12 >= 1 & s8_12 <=3) & s8_13== 2) | (s8_11 >= 3 & s8_11 <= 6)  | ((s8_11 >= 1 & s8_11 <=2)  & (s8_12 >= 4 & s8_12 <=5))
	

*************
***dorm_ch***
*************

gen dorm_ch= s8_23 
recode dorm_ch (0=1)
label var dorm_ch "Habitaciones para dormir"


****************
***cuartos_ch***
****************

gen cuartos_ch=s8_22 
label var cuartos_ch "Habitaciones en el hogar"
 

***************
***cocina_ch***
***************

gen cocina_ch=(s8_19==1)
replace cocina_ch = . if  s8_19==.
label var cocina_ch "Cuarto separado y exclusivo para cocinar"


**************
***telef_ch***
**************

gen telef_ch=(s8_26==1)
replace telef_ch = . if s8_26==.
label var telef_ch "El hogar tiene servicio telef�nico fijo"


******************
***refrig_ch***
******************
*Modificado Mayra S�enz - Noviembre, 2016. Antes se generaban como missings
gen refrig_ch= posee_3==1
label var refrig_ch "El hogar posee refrigerador o heladera"

******************
***freez_ch***
******************
gen freez_ch=.
label var freez_ch "El hogar posee congelador"

******************
***auto_ch***
******************
*Modificado Mayra S�enz - Noviembre, 2016. Antes se generaban como missings
gen auto_ch=posee_10==1
label var auto_ch "El hogar posee automovil particular"

******************
***compu_ch***
******************
*Modificado Mayra S�enz - Noviembre, 2016. Antes se generaban como missings
gen compu_ch=posee_4==1
label var compu_ch "El hogar posee computador"


*****************
***internet_ch***
*****************
gen internet_ch=(s8_28==1)
replace internet_ch = .   if  s8_28 == .
label var internet_ch "El hogar posee conexi�n a Internet"



************
***cel_ch***
************

gen cel_ch= .
label var cel_ch "El hogar tiene servicio telefonico celular"


**************
***vivi1_ch***
**************

gen vivi1_ch=1 if s8_01==1
replace vivi1_ch=2 if s8_01==3
replace vivi1_ch=3 if s8_01==2 | s8_01==3 
replace vivi1_ch=. if s8_01==.
label var vivi1_ch "Tipo de vivienda en la que reside el hogar"
label def vivi1_ch 1"Casa" 2"Departamento" 3"Otros"
label val vivi1_ch vivi1_ch


*************
***vivi2_ch***
*************

gen vivi2_ch=0
replace vivi2_ch=1 if s8_01==1 | s8_01==3
replace vivi2_ch=. if s8_01==.
label var vivi2_ch "La vivienda es casa o departamento"


*****************
***viviprop_ch***
*****************

*Se crea una variable parecida, pero con otro nombre

gen viviprop_ch=0 	if s8_02==1
replace viviprop_ch=1 	if s8_02==2
replace viviprop_ch=3 	if s8_02==3 | s8_02==4 | s8_02==5 | s8_02==6 
label var viviprop_ch "Propiedad de la vivienda"
label def viviprop_ch 0"Alquilada" 1"Propia" 
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

gen vivialq_ch= s8_03
label var vivialq_ch "Alquiler mensual"


*******************
***vivialqimp_ch***
*******************

gen vivialqimp_ch=s8_04
label var vivialqimp_ch "Alquiler mensual imputado"

*******************
*** benefdes_ci ***
*******************
g benefdes_ci=.
label var benefdes_ci "=1 si tiene seguro de desempleo"

*******************
*** ybenefdes_ci***
*******************
g ybenefdes_ci=.
label var ybenefdes_ci "Monto de seguro de desempleo"



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


