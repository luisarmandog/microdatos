
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

local PAIS PRY
local ENCUESTA EPH
local ANO "2012"
local ronda m10_m12

local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
*local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_orig\\`PAIS'_`ANO'`ronda'.dta"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                                                    
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: Paraguay
Encuesta: EPH
Round: Octubre-Diciembre
Autores: Mayra S�enz

�ltima versi�n: Mayra S�enz - Email: mayras@iadb.org, saenzmayra.a@gmail.com
Fecha �ltima modificaci�n: 4 de Septiembre de 2013

							SCL/LMK - IADB
****************************************************************************/
/***************************************************************************
Detalle de procesamientos o modificaciones anteriores:

****************************************************************************/
use `base_in', clear

************
* Region_c *
************
*Inclusi�n Mayra S�enz - Julio 2013
/*
gen region_c=  dptorep

label define region_c  ///
           0 "Asunci�n" ///
           2 "San Pedro" ///
           5 "Caaguaz�" ///
           7 "Itap�a" ///
          10 "Alto Paran�" ///
          11 "Central" ///
          20 "Resto"

label value region_c region_c
label var region_c "Divisi�n pol�tica, departamento"*/

*Modificaci�n Mayra S�enz - Septiembre 2014		  
gen region_c    = 1 if dptorep == 0
replace region_c= 2 if dptorep == 2		  
replace region_c= 3 if dptorep == 5		  
replace region_c= 4 if dptorep == 7
replace region_c= 5 if dptorep == 10
replace region_c= 6 if dptorep == 11
replace region_c= 7 if dptorep == 20  
label define region_c ///
1 "Asunci�n" ///
2 "San Pedro" ///
3 "Caaguaz�" ///
4 "Itap�a" ///
5 "Alto Paran�" ///
6 "Central" ///
7 "Resto" 
label value region_c region_c
label var region_c "Divisi�n pol�tica"
***************
***factor_ch***
***************

gen factor_ch=fex 
label variable factor_ch "Factor de expansion del hogar"


***************
****idh_ch*****
***************
gen upms=string(upm)
gen nvivis=string(nvivi)
gen nhogas=string(nhoga)
gen idh_ch=upms+nvivis+nhogas
sort idh_ch
label variable idh_ch "ID del hogar"
drop upms nvivis nhogas

*Se elimina este hogar que est� compuesto por un s�lo individuo que se repite 12 veces.
*Los ingresos son altos y afecta a los resultados.
*2014,05 modif MLO
*el problema era que estaba mal hecho el merge de la base (revisar do file que hace merge)
*ahora con el reshape esta solucionado
*drop if idh_ch == "17891"

**************
****idp_ci****
**************

*cap bysort idh_ch:gen idp_ci=_n 
gen idp_ci=l02
label variable idp_ci "ID de la persona en el hogar"

**********
***zona***
**********

gen byte zona_c=(area==1)

label variable zona_c "Zona del pais"
label define zona_c 1 "Urbana" 0 "Rural"
label value zona_c zona_ci

************
****pais****
************

gen str3 pais_c="PRY"
label variable pais_c "Pais"

**********
***anio***
**********

gen anio_c=2012
label variable anio_c "Anio de la encuesta"

*****************
*** region seg�n BID ***
*****************
gen region_BID_c=.
replace region_BID_c=4 if pais=="PRY" 
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

******************************
*	mes_c
******************************
gen mes_c=. 
label variable mes_c "Mes de la encuesta"

***************
****muestra****
***************
*1995 y 1997-2006 es nacional (N)

gen muestra_AMA=0
replace muestra_AMA=1 if dpto==0
label variable muestra_AMA "Asuncion Metropolitana"
	 	
gen muestra_N=1
label variable muestra_N "Muestra Nacional"

gen muestra_U=0
replace muestra_U=1 if zona_c==1
label variable muestra_U "Muestra Urbana"

*********
***mes***
*********

gen mes=.
*En este a�o no viene la variable mes.

*****************
***relacion_ci***
*****************

gen relacion_ci=.
replace relacion_ci=1 if p03==1
replace relacion_ci=2 if p03==2 
replace relacion_ci=3 if p03==3 | p03==4
replace relacion_ci=4 if p03==5 | p03==6 | p03==7 | p03==8 | p03==9
replace relacion_ci=5 if p03==10 
replace relacion_ci=6 if p03>=11


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

gen factor_ci=fex 
label variable factor_ci "Factor de expansion del individuo"

**********
***sexo***
**********

gen sexo_ci=.
replace sexo_ci=1 if p06==1
replace sexo_ci=2 if p06==6

label define sexo_ci 1 "Hombre" 2 "Mujer"
label value sexo_ci sexo_ci

**********
***edad***
**********

gen edad_ci=p02
label variable edad_ci "Edad del individuo"


*****************
***civil_ci***
*****************
/*
      estado |
       civil |  
 ------------+
 1casado     | 
 2unido      | 
 3separado   | 
 4viudo      | 
 5soltero    | 
 6divorciado | 
 ------------+
       Total |  
*/

gen estcivil=p09
gen civil_ci=.
replace civil_ci=1 if estcivil==5
replace civil_ci=2 if estcivil==1 | estcivil==2 
replace civil_ci=3 if estcivil==3 | estcivil==6 
replace civil_ci=4 if estcivil==4 

label variable civil_ci "Estado civil"
label define civil_ci 1 "Soltero" 2 "Union formal o informal"
label define civil_ci 3 "Divorciado o separado" 4 "Viudo" , add
label value civil_ci civil_ci
drop estcivil

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

by idh_ch, sort: egen nmayor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad>=21)
label variable nmayor21_ch "Numero de familiares mayores a 21 anios"

*****************
***nmenor21_ch***
*****************

by idh_ch, sort: egen nmenor21_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad<21)
label variable nmenor21_ch "Numero de familiares menores a 21 anios"

*****************
***nmayor65_ch***
*****************

by idh_ch, sort: egen nmayor65_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci>=65 )
label variable nmayor65_ch "Numero de familiares mayores a 65 anios"

****************
***nmenor6_ch***
****************

by idh_ch, sort: egen nmenor6_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad<6)
label variable nmenor6_ch "Numero de familiares menores a 6 anios"

****************
***nmenor1_ch***
****************

by idh_ch, sort: egen nmenor1_ch=sum((relacion_ci>=1 & relacion_ci<=4) & edad<1)
label variable nmenor1_ch "Numero de familiares menores a 1 anio"

****************
***miembros_ci***
****************

gen miembros_ci=(relacion_ci<5)
label variable miembros_ci "Miembros del hogar"


************************************************************************************************************
* 3. Creaci�n de nuevas variables de SS and LMK a incorporar en Armonizadas
************************************************************************************************************/
	
*********
*lp_ci***
*********
/*En 2011
gen lp_ci =.
replace lp_ci= 562925  if dominio==1 | dominio==2   /*area metropolitana*/
replace lp_ci= 349375 if dominio==3 | dominio==5   /*rural*/
replace lp_ci= 403669 if dominio==4  /*resto urbano*/
label var lp_ci "Linea de pobreza oficial del pais"
*/

*  En 2012: No est�n disponibles los datos oficiales. Tampoco est� la variable dominio.
gen lp_ci =.
label var lp_ci "Linea de pobreza oficial del pais"


*********
*lpe_ci***
*********
/*En 2011
gen lpe_ci =.
replace lpe_ci= 343212  if dominio==1 | dominio==2   /*area metropolitana*/
replace lpe_ci= 243721 if dominio==3 | dominio==5   /*rural*/
replace lpe_ci= 263386 if dominio==4  /*resto urbano*/
label var lpe_ci "Linea de indigencia oficial del pais"
*/

* En 2012: No est�n disponibles los datos oficiales. Tampoco est� la variable dominio.
gen lpe_ci =.

****************
*cotizando_ci***
****************
gen cotizando_ci=.
replace cotizando_ci=1 if b10==1 | c07==1
replace cotizando_ci=0 if (b10==6 | b10==.) & (c07==6 | c07==.)
replace cotizando_ci = 0 if peaa == 2 
label var cotizando_ci "Cotizante a la Seguridad Social"

****************
*cotizapri_ci***
****************
gen cotizapri_ci=.
replace cotizapri_ci=1 if b10==1 
replace cotizapri_ci=0 if (b10==6 | b10==.) 
replace cotizapri_ci = 0 if peaa == 2 
label var cotizapri_ci "Cotizante a la Seguridad Social en actividad ppal."

****************
*cotizasec_ci***
****************
gen cotizasec_ci=.
replace cotizasec_ci=1 if  c07==1
replace cotizasec_ci=0 if (c07==6 | c07==.)
replace cotizasec_ci = 0 if peaa == 2 
label var cotizasec_ci "Cotizante a la Seguridad Social en actividad sec."

****************
*afiliado_ci****
****************
gen afiliado_ci=.	

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
replace instcot_ci=1 if b11==1 

label var instpen_ci "Institucion a la que cotiza - variable original de cada pais" 


****************
****condocup_ci*
****************
/*
gen condocup_ci=.
replace condocup_ci=1 if peaa==1
replace condocup_ci=2 if peaa==2
replace condocup_ci=3 if peaa==3 & edad_ci>=10
replace condocup_ci=. if peaa == 0
replace condocup_ci=4 if edad_ci<10 

label var condocup_ci "Condicion de ocupaci�n de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de PET" 
label value condocup_ci condocup_ci
*/
* Comprobacion que no se toma en cuenta el desempleo oculto. MGD 05/27/2014
* No coincide con la variable creada pead ya que se condiciona por busqueda de trabajo y disponibilidad para trabajar.
gen condocup_ci=.
replace condocup_ci=1 if (pead==1 | pead==4 | pead==5)
replace condocup_ci=2 if (pead==2 | pead==6) & edad_ci >=10
recode condocup_ci .=3 if (pead==3) | (condocup_ci==. & edad_ci >=10) 
recode condocup_ci .=4 if edad_ci<10

label var condocup_ci "Condicion de ocupaci�n de acuerdo a def de cada pais"
label define condocup_ci 1 "Ocupado" 2 "Desocupado" 3 "Inactivo" 4 "Menor de PET" 
label value condocup_ci condocup_ci


*************
*cesante_ci* 
*************

gen cesante_ci=1 if a12==1 &  peaa==2 & edad_ci>=10
replace cesante_ci=0 if a12==6 &  peaa==2 & edad_ci>=10
label var cesante_ci "Desocupado - definicion oficial del pais"	

*************
**pension_ci*
*************

gen pension_ci=1 if (e01g>0 & e01g<. & e01g!=999999999) | (e01i>0 & e01i<. & e01i!=999999999)
recode pension_ci .=0 
label var pension_ci "1=Recibe pension contributiva"

*************
*ypen_ci*
*************
replace e01g=. if (e01g >= 999999999 & e01g!=.)
replace e01i=. if (e01i >= 999999999 & e01i!=.)
egen ypen_ci=rowtotal(e01g e01i)
replace ypen_ci=. if pension_ci==0
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************
* Programa Adulto Mayor
gen pensionsub_ci=.
replace pensionsub_ci=1 if (e01k>0 & e01k<. & e01k!=999999999)
recode pensionsub_ci .=0
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**ypensub_ci*
*****************
replace e01k=. if (e01k >= 999999999)
gen ypensub_ci=e01k
replace ypensub_ci=0 if pensionsub_ci==0
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

*************
**salmm_ci***
*************

* Se mantiene PRY 2011
gen salmm_ci= 	1658232
label var salmm_ci "Salario minimo legal"


************
***emp_ci***
************

gen byte emp_ci=(condocup_ci==1)

****************
***desemp_ci***
****************

gen desemp_ci=(condocup_ci==2)

*************
***pea_ci***
*************
gen pea_ci=0
replace pea_ci=1 if emp_ci==1 |desemp_ci==1

*****************
***desalent_ci***
*****************

gen desalent_ci=. /*Se intenta construir como en el 2009 pero no existe la variable a09*/
*gen desalent_ci=(a09==2)

***************
***subemp_ci***
***************
gen holune=int(b03lu) if b03lu<99
gen homart=int(b03ma) if b03ma<99
gen homier=int(b03mi) if b03mi<99
gen hojuev=int(b03ju) if b03ju<99
gen hovier=int(b03vi) if b03vi<99
gen hosab=int(b03sa)  if b03sa<99
gen hodom=int(b03do)  if b03do<99

gen minlune=b03lu-holune
gen minmart=b03ma-homart
gen minmier=b03mi-homier
gen minjuev=b03ju-hojuev
gen minvier=b03vi-hovier
gen minsab=b03sa-hosab
gen mindom=b03do-hodom

egen horas=rsum(holune homart homier hojuev hovier hosab hodom), missing
egen min = rsum(minlune minmart minmier minjuev minvier minsab mindom), missing
replace min=min*100
gen horas2 =min/60
egen tothoras=rsum(horas horas2), missing


gen subemp_ci=0
replace subemp_ci=1 if (tothoras>=1 & tothoras<=30) & (emp_ci==1 & d01==1)
drop min* 

*******************
***tiempoparc_ci***
*******************
* 10/21/2015 MGD: se considera solo la restricci�n de si quiere trabajar m�s.  No la de disponibilidad

gen tiempoparc_ci=0
replace tiempoparc_ci=1 if (tothoras>=1 & tothoras<30) & emp_ci==1 /*& d01==1*/  & d03==6

*****************
***horaspri_ci***
*****************
egen hr_seman=rsum(b03lu b03ma b03mi b03ju b03vi b03sa b03do), missing
gen hr_sem_s=tothoras
gen horaspri_ci=hr_seman if emp_ci==1 


*****************
***horastot_ci***
*****************

gen horastot_ci=hr_sem_s  if emp_ci==1 

******************
***categopri_ci***
******************
/*
           categoria de |
        ocupacion (act. |
             principal) |
  ----------------------+
0 na                      |     11,257       53.47       53.47
1 empleado/obrero p�blico |        807        3.83       57.30
2 empleado/obrero privado |      3,037       14.43       71.73
3 empleador o patr�n      |        467        2.22       73.95
4 cuenta propia           |      3,678       17.47       91.42
5 famil. no remunerado    |      1,054        5.01       96.42
6 empleado dom�stico      |        750        3.56       99.99
9 nr                      |          3        0.01      100.00
  ----------------------+
                  Total |

*/

	gen categopri_ci=.
	replace categopri_ci=1 if cate_pea==3 
	replace categopri_ci=2 if cate_pea==4 
	replace categopri_ci=3 if cate_pea==1 | cate_pea==2 | cate_pea==6 
	replace categopri_ci=4 if cate_pea==5 
	replace categopri_ci=. if emp_ci~=1

	label define categopri_ci 1 "Patron" 2 "Cuenta propia" 
	label define categopri_ci 3 "Empleado" 4 " Familiar no remunerado" , add
	label value categopri_ci categopri_ci
	label variable categopri_ci "Categoria ocupacional"


******************
***categosec_ci***
******************

gen categosec_ci=.
replace categosec_ci=1 if c09==3
replace categosec_ci=2 if c09==4 
replace categosec_ci=3 if c09==1 | c09==2 | c09==6
replace categosec_ci=4 if c09==5 
replace categosec_ci=. if emp_ci~=1 

label define categosec_ci 1"Patron" 2 "Cuenta propia" 
label define categosec_ci 3"Empleado" 4"Familiar no remunerado" , add
label value categosec_ci categosec_ci
label variable categosec_ci "Categoria ocupacional trabajo secundario"

*****************
*tipocontrato_ci*
*****************

gen tipocontrato_ci=. /* Solo asalariados*/
replace tipocontrato_ci=1 if b28==1 & categopri_ci==3
replace tipocontrato_ci=2 if (b28==2 | b28==4) & categopri_ci==3
replace tipocontrato_ci=3 if (b28==3 | tipocontrato_ci==.) & categopri_ci==3
label var tipocontrato_ci "Tipo de contrato segun su duracion"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci

*****************
***nempleos_ci***
*****************

gen nempleos_ci=0
replace nempleos_ci=1 if b33==6 
replace nempleos_ci=2 if b33==1
replace nempleos_ci=. if pea_ci==0

/*
*************
*firmapeq_ci*
*************
capture drop firmapeq_ci
recode b08 (1/2=1) (3/8=0), gen(firmapeq_ci)
replace firmapeq_ci=. if b08>8 | b08==.
label var firmapeq_ci "Trabajadores formales"
label define firmapeq_ci 0 "mas de 5 trabajadores" 1 "Menos de 5 o menos trabajadores"
label values firmapeq_ci firmapeq_ci
*/
*****************
***spublico_ci***
*****************

* 10/21/2015 MGD: correcci�n peque�a para que se tomen en cuenta a todos los ocupados.
gen spublico_ci=0 if emp_ci==1
replace spublico_ci=1 if cate_pea==1 & emp_ci==1
/*replace spublico_ci=0 if cate_pea!=1 & cate_pea!=9
replace spublico_ci=. if emp_ci==.*/

**************
***ocupa_ci***
**************
/*no habra categoria 5 porque servicios y comerciantes estan en la misma codificacion
OCUP: 5112 a 5230: Trabajadores de los servicios y vendedores de comercios y mercados
*/	

gen ocupa_ci=.
replace ocupa_ci=1 if (ocup_pea>=2 & ocup_pea <=3) & emp_ci==1
replace ocupa_ci=2 if (ocup_pea==1)                & emp_ci==1
replace ocupa_ci=3 if (ocup_pea==4)          	   & emp_ci==1
replace ocupa_ci=4 if (ocup_pea==5)           	   & emp_ci==1
replace ocupa_ci=6 if (ocup_pea==6)           	   & emp_ci==1
replace ocupa_ci=7 if (ocup_pea>=7 & ocup_pea <=8) & emp_ci==1
replace ocupa_ci=8 if (ocup_pea==10)          	   & emp_ci==1
replace ocupa_ci=9 if (ocup_pea==9 | ocup_pea==99) & emp_ci==1


*************
***rama_ci***
*************

generat rama_ci=. 
replace rama_ci= 1 if b02rec==1 & emp_ci==1
replace rama_ci= 3 if b02rec==2 & emp_ci==1
replace rama_ci= 4 if b02rec==3 & emp_ci==1
replace rama_ci= 5 if b02rec==4 & emp_ci==1
replace rama_ci= 6 if b02rec==5 & emp_ci==1
replace rama_ci= 7 if b02rec==6 & emp_ci==1
replace rama_ci= 8 if b02rec==7 & emp_ci==1
replace rama_ci= 9 if b02rec==8 & emp_ci==1

****************
***durades_ci***
****************

recode a11a (9=.)
recode a11m (99=.)
recode a11s (9=.)
gen durades_ci=(a11a*12)+a11m+(a11s/4.3 )
replace durades_ci=. if durades_ci==0

*******************
***antiguedad_ci***
*******************

*b07 es cuanto tiempo de su vida ha trabajado en esta ocupacion 
*b09 es cuanto lleva trabajando en la empresa
*gen antiguedad_ci=.
*replace antiguedad_ci=b09a+(b09m/12)+(b09s/52) if b09a!=99 & b09m~=99 & b09s~=9 & emp_ci==1 
*2014,05 modificacion MLO
gen atenure=b09a if b09a!=99
gen stenure=b09s/52.17 if b09s!=9
gen mtenure=b09m/12 if b09m!=99
egen antiguedad_ci=rowtotal(atenure stenure mtenure), m

*************
*tamemp_ci
*************
/*
na               
solo               
2 a 5 personas      
6 a 10 personas     
11 a 20 personas    
21 a 50 personas    
51 a 100 personas   
101 a 500 personas  
m�s de 500 personas 
empleado dom�stico 
no sabe             
nr         
               

*/
*Paraguay Peque�a 1 a 5, Mediana 6 a 50, Grande M�s de 50

gen tamemp_ci = 1 if b08>=1 & b08<=2
replace tamemp_ci = 2 if (b08>=3 & b08<=5)
replace tamemp_ci = 3 if (b08>=6 & b08<=8)

label define tamemp_ci 1 "Peque�a" 2 "Mediana" 3 "Grande"
label value tamemp_ci tamemp_ci
label var tamemp_ci "Tama�o de empresa"

gen tamemp_ci1 = 1 if b08>1 & b08<=2
replace tamemp_ci1 = 2 if (b08>=3 & b08<=5)
replace tamemp_ci1 = 3 if (b08>=6 & b08<=8)

gen tamemp_o = 1 if b08>=1 & b08<=3
replace tamemp_o = 2 if (b08>=4 & b08<=5)
replace tamemp_o = 3 if (b08>=6 & b08<=8)

label define tamemp_o 1 "[1-9]" 2 "[10-49]" 3 "[50 y mas]"
label value tamemp_o tamemp_o
label var tamemp_o "Tama�o de empresa"




*******************
***categoinac_ci*** 
*******************
/*gen categoinac_ci =.
La variable es la a09, pero no consta en la base de datos.
gen categoinac_ci =1 if ((a09==14 | a09==15) & condocup_ci==3)
replace categoinac_ci = 2 if  (a09==7 & condocup_ci==3)
replace categoinac_ci = 3 if  (a09==6 & condocup_ci==3)
replace categoinac_ci = 4 if  ((categoinac_ci ~=1 & categoinac_ci ~=2 & categoinac_ci ~=3) & condocup_ci==3)
label var categoinac_ci "Categor�a de inactividad"
label define categoinac_ci 1 "jubilados o pensionados" 2 "Estudiantes" 3 "Quehaceres dom�sticos" 4 "Otros" 
*/
*10/21/15 MGD:  Se usa la nueva variable para construir la variable categoinac
gen categoinac_ci =1 if ((ra06ya09==7) & condocup_ci==3)
replace categoinac_ci = 2 if  (ra06ya09==1 & condocup_ci==3)
replace categoinac_ci = 3 if  (ra06ya09==2 & condocup_ci==3)
replace categoinac_ci = 4 if  ((categoinac_ci ~=1 & categoinac_ci ~=2 & categoinac_ci ~=3) & condocup_ci==3)
label var categoinac_ci "Categor�a de inactividad"
label define categoinac_ci 1 "jubilados o pensionados" 2 "Estudiantes" 3 "Quehaceres dom�sticos" 4 "Otros" 

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
*************************************************************************************
*******************************INGRESOS**********************************************
*************************************************************************************

****************
***ylmpri_ci ***
****************

/*Ingresos netos por remuneracion al trabajo*/
gen ylmpri_ci=e01aimde if emp_ci==1 
replace ylmpri_ci=. if e01aimde<=0 | e01aimde>=999999999
replace ylmpri_ci=0 if categopri_ci==4


*****************
***nrylmpri_ci***
*****************

gen nrylmpri_ci=(ylmpri_ci==. & emp_ci==1)


*****************
*** ylnmpri_ci***
*****************
/*
gen ylnmpri_ci=.
*/
*Inclusi�n Mayra S�enz - Septiembre 2013
recode b22t (99999999999=.)
egen ylnmpri_ci=rsum(b22t), missing
replace ylnmpri_ci=. if b22t==. 
replace ylnmpri_ci=. if emp_ci~=1
label var ylnmpri_ci "Ingreso laboral NO monetario actividad principal"   

***************
***ylmsec_ci***
***************

/*existen unas actividades ocacionales-las pongo en secundario*/
gen ysec1=e01bimde
replace ysec1=. if ysec==0 | ysec>=999999999 /*No aplicable*/

gen ylmsec_ci=ysec1
replace ylmsec_ci=. if emp_ci~=1
replace ylmsec_ci=. if ysec1==. 

drop ysec1 

*************
*ylmotros_ci*
*************
gen yocasio1=e01cimde 
replace yocasio1=. if yocasio==0 | yocasio>=999999999 /*No aplicable*/

gen ylmotros_ci= yocasio1
replace ylmsec_ci=. if emp_ci~=1
replace ylmsec_ci=. if yocasio1==.
drop yocasio1

******************
****ylnmsec_ci****
******************
gen ylnmsec_ci=.

************
***ylm_ci***
************


egen ylm_ci=rsum(ylmpri_ci ylmsec_ci), missing
replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==.

*****************************************************************
*identificador de top-code del ingreso de la actividad principal*
*****************************************************************

gen tcylmpri_ci=.


*************
***ylnm_ci***
*************

gen ylnm_ci=.

*************
***ynlm_ci***
*************

local var="e01dde e01ede e01fde e01gde e01hde e01ide e01jde e01kde e01lde e02l1bde e02l2bde"

foreach x of local var {
gen `x'1=`x'
replace `x'1=. if `x'==0 | `x'>=999999999 /*No aplicable*/
}


egen ynlm_ci=rsum(e01dde1 e01ede1 e01fde1 e01gde1 e01hde1 e01ide1 e01jde1 e01kde1 e01lde1 e02l1bde1 e02l2bde1), missing
replace ynlm_ci=. if e01dde1==. & e01ede1==. & e01fde1==. & e01gde1==. & e01hde1==. & e01ide1==. & e01jde1==. & e01kde1-09==. & e01lde1==.

drop e01dde1 e01ede1 e01fde1 e01gde1 e01hde1 e01ide1 e01jde1 e01kde1 e01lde1

*********************************************
*Ingreso laboral no monetario otros trabajos*
*********************************************

gen ylnmotros_ci=.

*****************
***remesas_ci***
*****************
* 2014, 05 MLO, revisar si esta creada bien la variable porque estaba hecho mal el merge de la base
replace e02l1bde1 =. if e02l1bde1 > 7575000

egen remesas_ci= rsum(e02l1bde1 e02l2bde1), missing
replace remesas_ci=. if e02l1bde1>=999999999 & e02l2bde1>=999999999
gen ynlnm_ci=.

************************
*** HOUSEHOLD INCOME ***
************************

/*Dado que el ingreso del hogar no tiene en cuenta el ingreso de las empleadas dom�sticas
voy a crear una flag que me identifique a las mismas como para que en este caso figure un missing
en el ingreso del hogar, las empleadas dom�sticas en este caso se identifican con un 9 en la variable parentco*/

******************
*** nrylmpri_ch***
******************
*Creating a Flag label for those households where someone has a ylmpri_ci as missing

by idh_ch, sort: egen nrylmpri_ch=sum(nrylmpri_ci) if miembros_ci==1, missing
replace nrylmpri_ch=1 if nrylmpri_ch>0 & nrylmpri_ch<.
replace nrylmpri_ch=. if nrylmpri_ch==.


*************
*** ylm_ch***
*************

by idh_ch, sort: egen ylm_ch=sum(ylm_ci) if miembros_ci==1, missing

**************************************************
*Identificador de los hogares en donde (top code)*
**************************************************

gen tcylmpri_ch=.

****************
*** ylmnr_ch ***
****************

by idh_ch, sort: egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1, missing
replace ylmnr_ch=. if nrylmpri_ch==1

***************
*** ylnm_ch ***
***************

by idh_ch, sort: egen ylnm_ch=sum(ylnm_ci) if miembros_ci==1, missing

**********************************
*** remesas_ch & remesasnm_ch ***
**********************************

gen remesash=.

by idh_ch, sort: egen remesasi=sum(remesas_ci) if miembros_ci==1, missing
replace remesasi=. if remesasi==0
egen remesas_ch=rsum(remesasi remesash), missing
replace remesas_ch=. if remesasi==. 

gen remesasnm_ch=.


***************
*** ynlm_ch ***
***************

by idh_ch, sort: egen ynlm=sum(ynlm_ci) if miembros_ci==1, missing
egen ynlm_ch=rsum(ynlm remesash), missing
replace ynlm_ch=. if ynlm==. 
drop ynlm

****************
*** ynlnm_ch ***
****************

gen ynlnm_ch=remesasnm_ch

*******************
*** autocons_ci ***
*******************

gen autocons_ci=.


*******************
*** autocons_ch ***
*******************

by idh_ch, sort: egen autocons_ch=sum(autocons_ci) if miembros_ci==1, missing

*******************
*** rentaimp_ch ***
*******************

gen rentaimp_ch=v19  /*Si tuviera que alquilar esta vivienda cuanto estimar�a que le Pag.. por mes*/
replace rentaimp_ch=. if v19>=15000000 

*****************
***ylhopri_ci ***
*****************

gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.3)


***************
***ylmho_ci ***
***************

gen ylmho_ci=ylm_ci/(horastot_ci*4.3)


****************************
***VARIABLES DE EDUCACION***
****************************
/*
	0	sin instrucci�n        
	101	1� educaci�n especial  
	102	2� educaci�n especial  
	103	3� educaci�n especial  
	104	4� educaci�n especial  
	105	5� educaci�n especial  
	106	6� educaci�n especial  
	107	7� educaci�n especial  
	108	8� educaci�n especial  
	109	9� educaci�n especial  
	110	prejard�n educacion especial   
	111	jard�n educaci�n especial      
	112	preescolar educaci�n especial  
	210	prejard�n     
	211	jard�n        
	212	preescolar    
	301	1er. grado    
	302	2do. grado    
	303	3er. grado    
	304	4to. grado    
	305	5to. grado    
	306	6to. grado    
	407	7mo. grado    
	408	8vo. grado    
	409	9no. grado    
	501	1� b�sico     
	502	2� b�sico     
	503	3� b�sico     
	604	4� curso human�stico-cient�fico  
	605	5� curso human�stico-cient�fico  
	606	6� curso human�stico-cient�fico  
	704	4� curso t�cnico-comercial  
	705	5� curso t�cnico-comercial  
	706	6� curso t�cnico-comercial  
	803	3� bachillerato a distancia 
	901	1� ed. media cient�fica 
	902	2� ed. media cient�fica 
	903	3� ed. media cient�fica 
	1001	1� ed. media t�cnica 
	1002	2� ed. media t�cnica 
	1003	3� ed. media t�cnica 
	1101	1er. ciclo ed. b�sica bil. de j�venes y adultos  
	1102	2do. ciclo ed. b�sica bil. de j�venes y adultos  
	1103	3er. ciclo ed. b�sica bil. de j�venes y adultos  
	1104	4to. ciclo ed. b�sica bil. de j�venes y adultos  
	1201	1er. sem. ed. media a dist. para j�venes y adultos 
	1202	2do. sem. ed. media a dist. para j�venes y adultos 
	1203	3er. sem. ed. media a dist. para j�venes y adultos 
	1204	4to. sem. ed. media a dist. para j�venes y adultos 
	1301	1er. sem. ed. b�sica altern. de j�venes y adultos  
	1302	2do. sem. ed. b�sica altern. de j�venes y adultos  
	1303	3er. sem. ed. b�sica altern. de j�venes y adultos  
	1401	1er. sem. ed. media altern. de j�venes y adultos  
	1402	2do. sem. ed. media altern. de j�venes y adultos  
	1403	3er. sem. ed. media altern. de j�venes y adultos  
	1404	4to. sem. ed. media altern. de j�venes y adultos  
	1501	1� formaci�n profesional no bachillerao de la media
	1502	2� formaci�n profesional no bachillerao de la media
	1503	3� formaci�n profesional no bachillerao de la media
	1601	programas de alfabetizaci�n  
	1700	grado especial  
	1801	1� t�cnica superior  
	1802	2� t�cnica superior  
	1803	3� t�cnica superior  
	1804	4� t�cnica superior  
	1901	1� form. docente     
	1902	2� form. docente     
	1903	3� form. docente     
	1904	4� form. docente     
	2001	1er. sem. profesionalizaci�n docente 
	2002	2do. sem. profesionalizaci�n docente 
	2003	3er. sem. profesionalizaci�n docente 
	2004	4to. sem. profesionalizaci�n docente 
	2005	5to. sem. profesionalizaci�n docente 
	2006	6to. sem. profesionalizaci�n docente 
	2101	1� form. militar-policial 
	2102	2� form. militar-policial 
	2103	3� form. militar-policial 
	2104	4� form. militar-policial 
	2201	1� universitario 
	2202	2� universitario 
	2203	3� universitario 
	2204	4� universitario 
	2205	5� universitario 
	2206	6� universitario 
	8888	na 
	9999	nr nivel y grado 
*/
/*
*** people who have missings
gen nivgra=ed0504
gen byte yedc=.
replace yedc=. if nivgra==9999 

**<5 and no education
replace yedc=0 if nivgra==0 | nivgra==100| nivgra==1601| nivgra==1700 

*** preescolar o jardin o pre-primaria
replace yedc=0 if nivgra>=110 & nivgra<=300 

*** primaria 
replace yedc=1 if nivgra==301 
replace yedc=2 if nivgra==302 
replace yedc=3 if nivgra==303 

replace yedc=4 if nivgra==304 
replace yedc=5 if nivgra==305 
replace yedc=6 if nivgra==306 

*** secundaria 
replace yedc=7  if nivgra==407 | nivgra==501 | nivgra==1101
replace yedc=8  if nivgra==408 | nivgra==502 | nivgra==1102
replace yedc=9  if nivgra==409 | nivgra==503 | nivgra==1103
replace yedc=10 if nivgra==604 | nivgra==704 | nivgra==801 | nivgra==901 |nivgra==1001 | nivgra==1104 | nivgra==1201 | nivgra==1202|nivgra==1301 |nivgra==1302 | nivgra==1401 | nivgra==1402
replace yedc=11 if nivgra==605 | nivgra==705 | nivgra==802 | nivgra==902 |nivgra==1002  | nivgra==1203 |nivgra==1204 |nivgra==1303 |nivgra==1304 | nivgra==1403 | nivgra==1404
replace yedc=12 if nivgra==606 | nivgra==706 | nivgra==903 | nivgra==1003

*** superior no universitario  *** 
replace yedc=13 if nivgra==1501 | nivgra==1901 | nivgra==1801 | nivgra==2101 | nivgra==2001 | nivgra==2002
replace yedc=14 if nivgra==1502 | nivgra==1902 | nivgra==1802 | nivgra==2102 | nivgra==2003 | nivgra==2004
replace yedc=15 if nivgra==1503 | nivgra==1903 | nivgra==1803 | nivgra==2103 | nivgra==2005 | nivgra==2006
replace yedc=16 if nivgra==1504 | nivgra==1904 | nivgra==1804 | nivgra==2104 

*** universitario
replace yedc=13 if nivgra==2201 
replace yedc=14 if nivgra==2202 
replace yedc=15 if nivgra==2203  
replace yedc=16 if nivgra==2204 
replace yedc=17 if nivgra==2205 
replace yedc=18 if nivgra==2206 
gen byte aedu_ci=yedc

*/
/*
*Modificaci�n Mayra S�enz -02/01/2016: Se incorpora la nueva sintaxis para la generaci�n de las variables
asiste_ci y aedu_ci elaborada por Iv�n Bornacelly SCL/EDU.
*/

capture drop nivgra
gen nivgra=ed0504
tostring nivgra, gen(nivgra_str)
gen aedu_temp=substr(nivgra_str,-1,1)
destring aedu_temp, replace
replace aedu_temp=. if nivgra==9999 // No sabe no responde
replace aedu_temp=. if nivgra>=1100 & nivgra<=1700 // Educaci�n para adultos
replace aedu_temp=. if nivgra>=101 & nivgra<=112 // Educaci�n Especial

gen aedu_ci=aedu_temp
replace aedu_ci=0 if nivgra>=210 & nivgra<=212 // Educaci�n Inicial o Prescolar
replace aedu_ci=aedu_temp+6 if nivgra>=501 & nivgra<=503 // Ciclo b�sico de sencudaria antiguo
replace aedu_ci=aedu_temp+6 if nivgra>=604 & nivgra<=803 // Educaci�n Secundaria y Bachillerato
replace aedu_ci=aedu_temp+9 if nivgra>=900 & nivgra<=1003 // Educaci�n Media 
replace aedu_ci=aedu_temp+12 if nivgra>=1800 & nivgra<=2206 // Educaci�n superior (t�cnica, tecnol�gica, universitaria)
replace aedu_ci=aedu_temp+12+5 if ed06c==8 // Doctorado
replace aedu_ci=aedu_temp+12+2 if ed06c==9 // Maestria
replace aedu_ci=aedu_temp+12+1 if ed06c==10 // Especializaci�n

**************
***eduno_ci***
**************

gen byte eduno_ci=0
replace eduno_ci=1 if aedu_ci==0
replace eduno_ci=. if aedu_ci==.
label variable eduno_ci "Cero anios de educacion"

**************
***edupi_ci***
**************

gen byte edupi_ci=0
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<6
replace edupi_ci=. if aedu_ci==.
label variable edupi_ci "Primaria incompleta"

**************
***edupc_ci***
**************

gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==6
replace edupc_ci=. if aedu_ci==.
label variable edupc_ci "Primaria completa"

**************
***edusi_ci***
**************

gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>6 & aedu_ci<12
replace edusi_ci=. if aedu_ci==.
label variable edusi_ci "Secundaria incompleta"

**************
***edusc_ci***
**************

gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==12
replace edusc_ci=. if aedu_ci==.
label variable edusc_ci "Secundaria completa"

***************
***edus1i_ci***
***************

gen byte edus1i_ci=0
replace edus1i_ci=1 if aedu_ci>6 & aedu_ci<9
replace edus1i_ci=. if aedu_ci==.
label variable edus1i_ci "1er ciclo de la secundaria incompleto"

***************
***edus1c_ci***
***************

gen byte edus1c_ci=0
replace edus1c_ci=1 if aedu_ci==9
replace edus1c_ci=. if aedu_ci==.
label variable edus1c_ci "1er ciclo de la secundaria completo"

***************
***edus2i_ci***
***************

gen byte edus2i_ci=0
replace edus2i_ci=1 if aedu_ci>9 & aedu_ci<12
replace edus2i_ci=. if aedu_ci==.
label variable edus2i_ci "2do ciclo de la secundaria incompleto"
***************
***edus2c_ci***
***************

gen byte edus2c_ci=0
replace edus2c_ci=1 if aedu_ci==12
replace edus2c_ci=. if aedu_ci==.
label variable edus2c_ci "2do ciclo de la secundaria completo"

**************
***eduui_ci***
**************

gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>12 & aedu_ci<17
replace eduui_ci=. if aedu_ci==.
label variable eduui_ci "Universitaria incompleta"

***************
***eduuc_ci****
***************

gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci>=17
replace eduuc_ci=. if aedu_ci==.
label variable eduuc_ci "Universitaria incompleta o mas"


***************
***edupre_ci***
***************

gen byte edupre_ci=. 
label variable edupre_ci "Educacion preescolar"
replace edupre_ci=1 if nivgra>=100 & nivgra!=.
replace edupre_ci=0 if nivgra==0

***************
***asis_pre***
***************

gen byte asispre_ci=. /* Por que no se construyo esta variable si tenemos la informacion??? */
label variable edupre_ci "Asistencia a Educacion preescolar"

**************
***eduac_ci***
**************
gen byte eduac_ci=. 
label variable eduac_ci "Superior universitario vs superior no universitario"

/*
***************
***asiste_ci***
***************

gen asiste_ci=.
replace asiste_ci=1 if ed09==1 |ed09==2|ed09==3
replace asiste_ci=0 if asiste_ci==.
label variable asiste_ci "Asiste actualmente a la escuela"

*/
/*
*Modificaci�n Mayra S�enz -02/01/2016: Se incorpora la nueva sintaxis para la generaci�n de las variables
asiste_ci y aedu_ci elaborada por Iv�n Bornacelly SCL/EDU.

Iv�n Bornacelly: La variable ed09 indica quienes de los que asisten est�n en una instituci�n p�blico,
privada o privada subvencionada. Los valores que son �missing� no necesariamente indican que no asiste
a alguna instituci�n. Los valores �missing� tambi�n pueden ser por que hay poblaci�n menor a 5 a�os de 
edad a la cu�l no se le hace la pregunta y se est� incluyendo dentro del conteo. Por lo tanto el c�digo
deber�a ser el siguiente:
*/

/*
***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if ed08>=1 & ed08<=19
replace asiste_ci=0 if ed08==20
*Los que �no saben o no responden� quedan como �missing�
label variable asiste_ci "Asiste actualmente a la escuela"
*/

/*Modificaci�n Mayra S�enz -01/23/2017: Se incluye a los que no asisten o no asistieron a una instituci�n de ense�anza educativa ed03==6 porque la ed08 s�lo responden los que 
                                        responden que s� asisten o asistieron a una instituci�n */
***************
***asiste_ci***
***************
gen asiste_ci=.
replace asiste_ci=1 if ed08>=1 & ed08<=19
replace asiste_ci=0 if ed08==20 | ed03==6
label variable asiste_ci "Asiste actualmente a la escuela"


*****************
***pqnoasis_ci***
*****************

gen pqnoasis_ci = ed10

**************
*pqnoasis1_ci*
**************
**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**

g       pqnoasis1_ci = 1 if ed10 ==1 | ed10 ==3
replace pqnoasis1_ci = 2 if ed10 ==2
replace pqnoasis1_ci = 3 if ed10 ==11 | ed10 ==12 | ed10 ==14
replace pqnoasis1_ci = 4 if ed10 ==15
replace pqnoasis1_ci = 5 if ed10 ==13
replace pqnoasis1_ci = 6 if ed10 ==5
replace pqnoasis1_ci = 7 if ed10 ==4
replace pqnoasis1_ci = 8 if ed10 ==6  | ed10 ==7  | ed10 ==8  | ed10 ==9 | ed10 ==10 
replace pqnoasis1_ci = 9 if ed10 ==16 | ed10 ==17 | ed10 ==18

label define pqnoasis1_ci 1 "Problemas econ�micos" 2 "Por trabajo" 3 "Problemas familiares o de salud" 4 "Falta de inter�s" 5	"Quehaceres dom�sticos/embarazo/cuidado de ni�os/as" 6 "Termin� sus estudios" 7	"Edad" 8 "Problemas de acceso"  9 "Otros"
label value  pqnoasis1_ci pqnoasis1_ci

***************
***repite_ci***
***************


gen repite_ci=. 
label variable repite_ci "Esta repitendo el grado o curso"

******************
***repiteult_ci***
******************

gen repiteult_ci=.
label variable repiteult_ci "Esta repitendo ultimo grado o curso"

***************
***edupub_ci***
***************

gen edupub_ci=1 if ed09==1 
replace edupub_ci=0 if ed09>=2 & ed09<=3

***************
***tecnica_ci**
***************

gen tecnica_ci=.
replace tecnica_ci=1 if ed0504>=1801 & ed0504<=1804
recode tecnica_ci .=0 
label var tecnica_ci "1=formacion terciaria tecnica"


********************************************
***Variables de Infraestructura del hogar***
********************************************

***************
**aguared_ch***
***************

gen aguared_ch=(v06==1 | v06==2 |v06==3|v06==4)  


****************
**aguadist_ch***
****************

gen aguadist_ch=. 

	replace aguadist_ch=1 if v09==2
	replace aguadist_ch=2 if v09==1| v09==4
	
	label var aguadist_ch "Ubicaci�n de la principal fuente de agua"
	label def aguadist_ch 1"Dentro de la vivienda" 2"Fuera de la vivienda pero en el terreno"
	label def aguadist_ch 3"Fuera de la vivienda y del terreno", add
	label val aguadist_ch aguadist_ch

****************
**aguamala_ch***
****************

gen aguamala_ch=0 
replace aguamala_ch=(v08>=5)
label var aguamala_ch "Agua unimproved seg�n MDG" 

****************
**aguamide_ch***
****************

gen aguamide_ch=.


****************
*****luz_ch*****
****************
ren v10 luz_ch
replace luz_ch=0 if luz_ch==6

****************
***luzmide_ch***
****************

gen luzmide_ch=.

****************
***combust_ch***
****************

gen combust_ch=1 if v14b==4 | v14b==2
replace combust_ch=0 if v14b==1 | v14b==3 | v14b==5 | v14b==6 
 

****************
****bano_ch*****
****************
* Si existe la pregunta tiene ba�o (v12) pero se obtiene los mismos resultados con la v13 
* que pregunta del tipo de desague sanitario.
gen bano_ch=v12==1


****************
****banoex_ch***
****************

gen banoex_ch=. 

****************
****des1_ch*****
****************

gen des1_ch=.
replace des1_ch=0 if v12==6
replace des1_ch=1 if v13==1 | v13==2
replace des1_ch=2 if v13==5 |v13==6 |v13==7 | v13==3
replace des1_ch=3 if v13==4 


****************
****des2_ch*****
****************

gen des2_ch=.
replace des2_ch=1 if des1_ch==1| des1_ch==2
replace des2_ch=0 if des1_ch==0
 
****************
****piso_ch*****
****************

gen piso_ch=.
replace piso_ch=0 if v04==1
replace piso_ch=1 if v04>=2 & v04<=8
replace piso_ch=2 if v04==9


****************
****pared_ch****
****************


gen muros1=v03
gen pared_ch=.
replace pared_ch=0 if muros1==7
replace pared_ch=1 if muros1>=1 & muros1<=5
replace pared_ch=2 if muros1==6 | muros1==9
drop muros1


****************
****techo_ch****
****************
gen techo1=v05
gen techo_ch=.
replace techo_ch=0 if techo1>=6 & techo1<=8
replace techo_ch=1 if techo1>=1 & techo1<=5
replace techo_ch=2 if techo1==9
drop techo1
****************
****resid_ch****
****************

gen basura=v15
gen resid_ch=0 if basura==2 | basura==3
replace resid_ch=1 if basura==1 | basura==4
replace resid_ch=2 if basura>=5 & basura<=8
drop basura

**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
*********************
***aguamejorada_ch***
*********************
g       aguamejorada_ch = 1 if (v06 >=1 & v06 <=7) | v06 == 10
replace aguamejorada_ch = 0 if (v06 >=8 & v06 <=9) | v06 == 11
		
*********************
***banomejorado_ch***
*********************
g       banomejorado_ch = 1 if (v13 >=1 & v13 <=3) | (v13 >=5 & v13 <=6) 
replace banomejorado_ch = 0 if  v13 ==4 | (v13 >=7 & v13 <=8) | v12==6


****************
****dorm_ch*****
****************

gen dorm_ch=.
replace dorm_ch=v02b
replace dorm_ch=. if dorm_ch==99

****************
***cuartos_ch***
****************

gen cuartos_ch=v02a

****************
***cocina_ch****
****************

gen cocina_ch=v14a 
replace cocina_ch=0 if cocina==6 


****************
****telef_ch****
****************

gen telef_ch=v11a 
replace telef_ch=0 if telef_ch==6
 
****************
****refrig_ch***
****************

gen refrig1=v2403 
gen refrig_ch=.
replace refrig_ch=1 if refrig1==1
replace refrig_ch=0 if refrig1==6
drop refrig1

****************
****freez_ch****
****************

gen freez_ch=.


****************
****auto_ch*****
****************
gen automovil=v2413
gen auto_ch=.
replace auto_ch=1 if automovil==1
replace auto_ch=0 if automovil==6
drop automovil 

****************
****compu_ch****
****************

gen compu_ch=v23a
replace compu_ch= 0 if v23a ==6

****************
**internet_ch***
****************

gen internet_ch=v23b 
replace internet_ch= 0 if v23b == 6


****************
****cel_ch******
****************

gen cel_ch=v11b 
replace cel_ch=0 if v11b==6


****************
****vivi1_ch****
****************

gen vivi1_ch=.
replace vivi1_ch=3 if v01>0
replace vivi1_ch=1 if v01==1
replace vivi1_ch=2 if v01==3


****************
****vivi2_ch****
****************

gen vivi2_ch=0
replace vivi2_ch=0 if v01>0
replace vivi2_ch=1 if v01==1 | v01==3


*******************
****viviprop_ch****
*******************

gen viviprop_ch=.
replace viviprop_ch=0 if v16==4
replace viviprop_ch=1 if v16==1 | v16==3
replace viviprop_ch=2 if v16==2
replace viviprop_ch=3 if v16==5 | v16==6 

******************
****vivitit_ch****
******************

gen vivitit_ch=.

*******************
****vivialq_ch****
*******************
recode v17 (99999999999=.)
gen vivialq_ch=v17

*********************
****vivialqimp_ch****
*********************
recode v19 (99999999999=.)
gen vivialqimp_ch=v19

*********
*raza_ci*
*********
/*
gen raza_ci=1 if ed01==1 
replace raza_ci=0 if ed01==2 | ed01==3 | ed01==4 | ed01==5
*/
/*
*Mayra S�enz- Octubre 2013
gen raza_ci=.
replace raza_ci= 1 if ed01 ==1 
replace raza_ci= 3 if ed01 ==2 | ed01 ==3 | ed01 ==4 |raza_ci==.
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

*Modificaci�n Mayra S�enz 10/20/2015: modificaciones realizadas en base a metodolog�a enviada por SCL/GDI Maria Olga Pe�a

gen raza_idioma_ci=.
replace raza_idioma_ci= 1 if ed01 ==1 
replace raza_idioma_ci= 3 if ed01 ==2 | ed01 ==3 | ed01 ==4 |raza_idioma_ci==.
bys idh_ch: gen aux=raza_idioma_ci if p03==1
bys idh_ch: egen aux1 = max(aux)
replace raza_idioma_ci=aux1 if (raza_idioma_ci ==. & (p03 ==3|p03==5))  
replace raza_idioma_ci=3 if raza_idioma_ci==. 
drop aux aux1
label define raza_idioma_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros" 
label value raza_idioma_ci raza_idioma_ci 
label value raza_idioma_ci raza_idioma_ci
label var raza_idioma_ci "Raza o etnia del individuo"

gen raza_ci=.

gen id_ind_ci = 0
replace id_ind_ci=1 if raza_idioma_ci==1 
label define id_ind_ci 1 "Ind�gena" 0 "Otros" 
label value id_ind_ci id_ind_ci 
label var id_ind_ci  "Indigena" 

gen id_afro_ci = 0
replace id_afro_ci=1 if raza_idioma_ci==2 
label define id_afro_ci 1 "Afro-descendiente" 0 "Otros" 
label value id_afro_ci id_afro_ci 
label var id_afro_ci "Afro-descendiente"




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
