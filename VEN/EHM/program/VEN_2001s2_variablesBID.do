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

local PAIS VEN
local ENCUESTA EHM
local ANO "2001"
local ronda s2 
local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                        
capture log close
log using "`log_file'", replace 

/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: 
Encuesta: EHM
Round: s2
Autores: Mayra S�enz - saenzmayra.a@gmail.com - mayras@iadb.org - Diciembre 2013
Versi�n 2006: Victoria
Generaci�n nuevas variables LMK: Yessenia Loayza (desloay@hotmail.com | yessenial@iadb.org)
�ltima versi�n: Yessenia Loayza - Email: desloay@hotmail.com | yessenial@iadb.org
Fecha �ltima modificaci�n: octubre 2013

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************/
use `base_in', clear

cap qui destring _all, replace

***********
* Region_c *
************
gen region_c=  entidad
label define region_c  ///
1	"Distrito Federal"  ///
2	"Amazonas " ///
3	"Anzoategui"  ///
4	"Apure " ///
5	"Aragua " ///
6	"Barinas " ///
7	"Bol�var " ///
8	"Carabobo " ///
9	"Cojedes " ///
10	"Delta Amacuro"  ///
11	"Falc�n"  ///
12	"Gu�rico"  ///
13	"Lara"  ///
14	"M�rida"  ///
15	"Miranda"  ///
16	"Monagas"  ///
17	"Nueva Esparta"  /// 
18	"Portuguesa"  ///
19	"Sucre"  ///
20	"T�chira"  ///
21	"Trujillo"  ///
22	"Yaracuy"  ///
23	"Zulia"  ///
24	"Vargas" 
label value region_c region_c
label var region_c " Primera Divisi�n pol�tica - Entidades Federativas"

************************
*** region seg�n BID ***
************************
gen region_BID_c=3 
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c

gen str pais_c="VEN"
gen anio_c=2001
gen mes_c=.
/* No se cuenta con informacion especifica sobre la semana de planificacion para esta encuesta */
replace mes_c= 7  if sema_levan>=1  & sema_levan<=4
replace mes_c= 8  if sema_levan>=5  & sema_levan<=8
replace mes_c= 9  if sema_levan>=9  & sema_levan<=12
replace mes_c= 10 if sema_levan>=13 & sema_levan<=16
replace mes_c= 11 if sema_levan>=17 & sema_levan<=20
replace mes_c= 12 if sema_levan>=21 & sema_levan<=24

*** average week of the survey is 12.79
replace mes_c= 9 if mes_c==.

label var mes_c "Mes de la Encuesta: Segundo Semestre de 2001"
label define mes_c 7 "JUL" 8 "AUG" 9 "SEP" 10 "OCT" 11 "NOV" 12 "DEC" 
label values mes_c mes_c

gen zona_c=.
replace zona_c=1 if dominio==1 | dominio==2 | dominio==3 | dominio==4
recode zona_c .=0
label define zona_c 0 "Rural" 1 "Urbana"
label value zona_c zona_c

ren id_hogar idh_ch
label var idh_ch "Identificador Unico del Hogar"
gen idp_ci=num_per
label var idp_ci "Identificador Individual dentro del Hogar"

gen factor_ch=pesoh
label var factor_ch "Factor de expansion del Hogar"

gen relacion_ci=.
replace relacion_ci=1 if pp19==1
replace relacion_ci=2 if pp19==2
replace relacion_ci=3 if pp19==3
replace relacion_ci=4 if pp19>=4 & pp19<=14 /* Otros familiares */
replace relacion_ci=5 if pp19==15  
replace relacion_ci=6 if pp19==16 | pp19==17 /*Es el sevicio domestico, Incluye a familiares del Serv. Domestico en pp19==17 */
label var relacion_ci "Relacion con el Jefe de Hogar"
label define relacion_ci 1 "Jefe de Hogar" 2 "Conyuge/Pareja" 3 "Hijo(a)/Hijastro(a)" 4 "Otros Parientes" 5 "Otros No parientes" 6 "Servicio Domestico (inc fam Serv. Dom.)"
label value relacion_ci relacion_ci

gen factor_ci=peso
label var factor_ci "Factor de Expansion del Individuo"

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

****************************
***VARIABLES DEMOGRAFICAS***
****************************

gen sexo_ci=pp18
label var sexo "Sexo del Individuo"
label define sexo_ci 1 "Masculino" 2 "Femenino"
label value sexo_ci sexo_ci

** Generating Edad
gen edad_ci=pp20
replace edad=. if edad==99
label var edad_ci "Edad del Individuo"

gen byte civil_ci=.
replace civil_ci=1 if pp21==-1 | pp21==7
replace civil_ci=2 if pp21==1 | pp21==2 | pp21==3 | pp21==4
replace civil_ci=3 if pp21==5
replace civil_ci=4 if pp21==6

label var civil_ci "Estado Civil"
label define civil_ci 1 "Soltero" 2 "Union Formal o Informal" 3 "Divorciado o Separado" 4 "Viudo"
label value civil_ci civil_ci

************
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

************************************
*** VARIABLES DEL MERCADO LABORAL***
************************************

****************
****condocup_ci*
****************
/*
gen condocup_ci=.
replace condocup_ci=1 if (codigo_sum>=1 & codigo_sum <=3) 
replace condocup_ci=2 if codigo_sum==4 | codigo_sum==11 
replace condocup_ci=3 if condocup_ci!=1 & condocup_ci!=2
replace condocup_ci=4 if edad_ci<15
label define condocup_ci 1"ocupados" 2"desocupados" 3"inactivos" 4"menor de PET"
label value condocup_ci condocup_ci
label var condocup_ci "Condicion de ocupacion utilizando definicion del pais"
*/
* Cambio edad minima de la encuesta (10 a�os). MGD 06/10/2014
gen condocup_ci=.
replace condocup_ci=1 if (codigo_sum>=1 & codigo_sum <=3) 
replace condocup_ci=2 if codigo_sum==4 | codigo_sum==11 
replace condocup_ci=3 if (condocup_ci!=1 & condocup_ci!=2) & edad_ci>=10
replace condocup_ci=4 if edad_ci<10
label define condocup_ci 1"ocupados" 2"desocupados" 3"inactivos" 4"menor de PET"
label value condocup_ci condocup_ci
label var condocup_ci "Condicion de ocupacion utilizando definicion del pais"

****************
*afiliado_ci****
****************
gen afiliado_ci=.
label var afiliado_ci "Afiliado a la Seguridad Social"

****************
*cotizando_ci***
****************
gen cotizando_ci=0     if condocup_ci==1 | condocup_ci==2
foreach var of varlist  pp48a pp48b pp48c {
replace cotizando_ci=1 if (`var'==3) & cotizando_ci==0 /*solo a emplead@s y asalariad@s, difiere con los otros paises*/
}
label var cotizando_ci "Cotizante a la Seguridad Social"

****************
*instpen_ci*****
****************
gen instpen_ci=.
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 

****************
*tipopen_ci*****
****************
gen tipopen_ci=.
label var tipopen_ci "Tipo de pension - variable original de cada pais" 


********************
*** instcot_ci *****
********************
gen instcot_ci=.
label var instcot_ci "instituci�n a la cual cotiza"

*****************
*tipocontrato_ci*
*****************
gen tipocontrato_ci=.
label var tipocontrato_ci "Tipo de contrato segun su duracion en act principal"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci

*************
*tamemp_ci***
*************
/*
gen tamemp_ci=pp45
label define tamemp_ci 1"una" 2"2-4 personas" 3"5 personas" 4"6-10 personas" 5"11-20 personas" 6"m�s de 20 personas"
label var tamemp_ci "# empleados en la empresa de la actividad principal"
*/
gen tamemp_ci=1 if pp45==1 | pp45==2
label var  tamemp_ci "Tama�o de Empresa" 
*Empresas medianas
replace tamemp_ci=2 if pp45==3 | pp45==4 | pp45==5
*Empresas grandes
replace tamemp_ci=3 if pp45==6
label define tama�o 1"Peque�a" 2"Mediana" 3"Grande"
label values tamemp_ci tama�o
tab tamemp_ci [iw=factor_ci]
/*
*Genera la variable para clasificar a los inactivos
*Jubilados, pensionados e incapacitados

gen categoinac_ci=1 if pp29==7
label var  categoinac_ci "Condici�n de Inactividad" 
*Estudiantes
replace categoinac_ci=2 if pp29==5
*Quehaceres del Hogar
replace categoinac_ci=3 if pp29==6
*Otra razon
replace categoinac_ci=4 if pp29==2 | pp29==8 | pp29==9 | pp29==10
label define inactivo 1"Pensionado y otros" 2"Estudiante" 3"Hogar" 4"Otros"
label values categoinac_ci inactivo
*/
gen categoinac_ci = .
replace categoinac_ci = 1 if ((pp29==7) & condocup_ci==3)
replace categoinac_ci = 2 if ((pp29==5) & condocup_ci==3)
replace categoinac_ci = 3 if ((pp29==6) & condocup_ci==3)
replace categoinac_ci = 4 if  ((categoinac_ci ~=1 & categoinac_ci ~=2 & categoinac_ci ~=3) & condocup_ci==3)
label var categoinac_ci "Categor�a de inactividad"
label define categoinac_ci 1 "Jubilados o pensionados" 2 "Estudiantes" 3 "Quehaceres dom�sticos" 4 "Otros"
label values categoinac_ci categoinac_ci

*************
**pension_ci*
*************
gen pension_ci=0 
foreach var of varlist pp53a pp53b pp53c pp53d pp53e pp53f pp53g pp53h pp53i {
replace pension_ci=1 if (`var'==1 | `var'==5 | `var'==6) /*A todas las per mayores de diez a�os */
}
label var pension_ci "1=Recibe pension contributiva"
 
*************
*  ypen_ci  *
*************
destring pp53j, replace force
gen ypen_ci=pp53j/1000 if pension_ci==1
replace ypen_ci=. if pp53j<0
label var ypen_ci "Valor de la pension contributiva"

***************
*pensionsub_ci*
***************
gen pensionsub_ci=.
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"

*****************
**  ypensub_ci  *
*****************
gen ypensub_ci=.
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

*************
*cesante_ci* 
*************
generat cesante_ci=0 if condocup_ci==2
replace cesante_ci=1 if (pp40==1) & condocup_ci==2
label var cesante_ci "Desocupado - definicion oficial del pais"

*********
*lp_ci***
*********
gen lp_ci=.
replace lp_ci=68150.3 if zona_c==1
replace lp_ci=54520.2 if zona_c==0
label var lp_ci "Linea de pobreza oficial del pais"

***********
*lpe_ci ***
***********
gen lpe_ci =.
label var lpe_ci "Linea de indigencia oficial del pais"

*************
**salmm_ci***
*************
/*Yessenia Loayza/Nota:
"Con la firma del Decreto Ley de Reconversi�n Monetaria, 
el presidente Ch�vez autoriz� la eliminaci�n de tres ceros a
 la moneda nacional a partir del 1� de enero de 2008"
 Bs (Bolivares Actuales)
 Bsf (Bolivares Fuertes)
 
 conversion:
 *----------
 1 BsF= 1000Bs/1000
 */
* 2015 MGD: salario m�nimo segun mes (promedio urbano-rural)
gen salmm_ci=.
replace salmm_ci=151800/1000 if zona_c==1 /*en Bs*/
replace salmm_ci=142560/1000 if zona_c==0 
label var salmm_ci "Salario minimo legal"
*Y.L. divido al salmm_ci entre 1000 para hacerlo comparable a lo largo del tiempo*/


*************
***tecnica_ci**
*************
gen tecnica_ci=(pp25a==5)
label var tecnica_ci "=1 formacion terciaria tecnica"	

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

capture drop ocupa_ci 
gen ocupa_ci=.
replace ocupa_ci=1 if pp43>=0 & pp43<=9
replace ocupa_ci=2 if pp43>=10 & pp43<=19
replace ocupa_ci=3 if pp43>=20 & pp43<=23
replace ocupa_ci=4 if pp43>=25 & pp43<=29
replace ocupa_ci=6 if pp43>=30 & pp43<=35
replace ocupa_ci=7 if pp43>=40 & pp43<=79
replace ocupa_ci=5 if pp43>=80 & pp43<=89
replace ocupa_ci=8 if pp43>=90 & pp43<=91
replace ocupa_ci=9 if pp43>=99
label variable ocupa_ci "Ocupacion Laboral en la Actividad Principal"
label define ocupa_ci 1 "PROFESIONALES Y TECNICOS" 2 "GERENTES, DIRECTORES Y FUNCIONARIOS SUPERIORES"  3 "PERSONAL ADMINISTRATIVO Y NIVEL INTERMEDIO" 4 "COMERCIANTES Y VENDEDORES" 5 "TRABAJADORES EN SERVICIOS" 6"TRABAJADORES AGRICOLAS Y AFINES" 7 "OBREROS NO AGRICOLAS, CONDUCTORES DE MAQUINAS Y VEHICULOS DE TRANSPORTE Y SIMILARES" 8"FUERZAS ARMADAS" 9"OTRAS OCUPACIONES NO CLASIFICADAS ANTERIORMENTE"
label values ocupa_ci ocupa_ci

*************
**rama_ci ***
*************
gen rama_ci=.
replace rama_ci=1 if (pp44>=111 & pp44<=141) & emp_ci==1
replace rama_ci=2 if (pp44>=210 & pp44<=290) & emp_ci==1
replace rama_ci=3 if (pp44>=311 & pp44<=390) & emp_ci==1
replace rama_ci=4 if (pp44>=410 & pp44<=420) & emp_ci==1
replace rama_ci=5 if pp44==500 & emp_ci==1
replace rama_ci=6 if (pp44>=610 & pp44<=632) & emp_ci==1
replace rama_ci=7 if (pp44>=711 & pp44<=720) & emp_ci==1
replace rama_ci=8 if (pp44>=810 & pp44<=833) & emp_ci==1
replace rama_ci=9 if (pp44>=910 & pp44<=960) & emp_ci==1
label var rama_ci "RAMA"
label define rama_ci 1 "Agricultura, caza, silvicultura y pesca" 2 "Explotaci�n de minas y canteras" 3 "Industrias manufactureras" 4 "Electricidad, gas y agua" 5 "Construcci�n" 6"Comercio al por mayor y menor, restaurantes, hoteles" 7"Transporte y almacenamiento" 8"Establecimientos financieros, seguros, bienes inmuebles" 9"Servicios sociales, comunales y personales"
label values rama_ci rama_ci

capture drop horaspri_ci
gen byte horaspri_ci=.
replace horaspri_ci=pp34 if pp34<=110 & pp34>=0
label var horaspri_ci "Horas totales trabajadas la semana pasada en la Actividad Principal"

gen byte horastot_ci=.
replace horastot_ci=pp35 if pp35<=110 & pp35>=0 & pp35>=pp34
replace horastot_ci=pp34 if pp34>=pp35 & pp34>=0
label var horastot_ci "Horas totales trabajadas la semana pasada en todas las Actividades"

gen antiguedad_ci=.
label var antiguedad_ci "Antiguedad en la Ocupacion Actual (en anios)"

/*gen durades_ci=pp41a  if pp41a >0 /* sin filtros & desemp_ci==1*/
replace durades_ci=pp41b*12 if pp41b>0 & durades_ci==./* sin filtros & desemp_ci==1*/
*/
* Modificacion MGD 07/11/2014: si hay la variable, para este anio es la pp41a/b.
g meses=pp41a if pp41a>0
g anios=pp41b*12 if pp41b>0
egen durades_ci = rsum(meses anios), missing
replace durades_ci=. if condocup_ci==3
*Se ponen como missing values las personas que llevan m�s tiempo desempleadas que tiempo de vida:
gen edad_meses=edad_ci*12
replace durades_ci=. if durades_ci>edad_meses
drop edad_meses


/*gen meses=.
gen agnos=.
replace meses=pp41a if pp41a~=-1 & pp41a!=-2 & pp41a!=-3
replace meses=0 if pp41a==-1
replace agnos=pp41b if pp41b~=-1 & pp41b!=-2 & pp41b!=-3
replace agnos=0 if pp41b==-1
replace durades_ci=(agnos*12)+meses 
recode durades_ci 0=.
replace durades_ci=0 if pp41a==0
*replace durades_ci=. if durades_ci>48
capture drop meses agnos
label var durades "Duracion del Desempleo (en meses)"*/

replace horaspri_ci=. if emp_ci==0

capture drop desalent_ci
gen byte desalent_ci=0
replace desalent_ci=1 if (pp29>4 & pp29<10) & pp30==11 & pp31==2 & pp36==2 & (pp39==1 | pp39==2 )
replace desalent=. if edad_ci<10
label var desalent_ci "Trabajadores desalentados, personas que creen que por alguna razon no conseguiran trabajo" 

gen subemp_ci=.
label var subemp_ci "Trabajadores subempleados"

gen tiempoparc_ci=.
label var tiempoparc_ci "Trabajadores a medio tiempo"

* Modificacion MGD 07/14/2014: Condicionado a que esten ocupados.
gen categopri_ci=.
replace categopri_ci=1 if pp46==7 & condocup_ci==1
replace categopri_ci=2 if pp46==6 | pp46==5  & condocup_ci==1
replace categopri_ci=3 if pp46>=1 & pp46<=4 & condocup_ci==1
replace categopri_ci=4 if pp46==8 & condocup_ci==1

label var categopri_ci "CATEGORIA OCUPACIONAL ACTIVIDAD PRINCIPAL"
label define categopri_ci 1 "Patron" 2 "Cuenta Propia" 3 "Asalariado" 4 "Trabajador No Remunerado" 
label values categopri_ci categopri_ci

gen categosec_ci=.
label var categosec_ci "CATEGORIA OCUPACIONAL ACTIVIDAD SECUNDARIA"

gen contrato_ci=.
label var contrato "Personas empleadas que han firmado un contrato de trabajo"

capture drop segsoc_ci
gen byte segsoc_ci=0
replace segsoc_ci=1 if (pp48a==3 |pp48b==3 |pp48c==3)
replace segsoc_ci=. if edad_ci<10
label variable segsoc_ci "Personas que cuentan con seguro social"

capture drop nempleos_ci
gen byte nempleos_ci=.
replace nempleos_ci=1 if emp==1 & pp33a==2
replace nempleos_ci=2 if emp==1 & pp33a==1 & pp33b>=1 & pp33b!=.
label var nempleos_ci "Numero de empleos"
label define nempleos_ci 1 "un trabajo" 2 "dos o mas trabajos"
label values nempleos_ci nempleos_ci

capture drop tamfirma_ci
gen byte tamfirma_ci=.
replace tamfirma_ci=1 if emp==1 & (pp45>=3 & pp45<=6)
replace tamfirma_ci=0 if emp==1 & (pp45==1 | pp45==2)
label var tamfirma "Trabajadores formales"
label define tamfirma_ci 1 "5 o mas trabajadores" 0 "Menos de 5 trabajadores"
label values tamfirma_ci tamfirma_ci
/*
gen firmapeq_ci=1 if tamfirma_ci==0
replace firmapeq_ci=0 if tamfirma_ci==1
replace firmapeq_ci=. if emp_ci==0
		*/
capture drop spublico_ci
gen byte spublico_ci=.
replace spublico_ci=1 if emp==1 & (pp46==1 | pp46==2) 
replace spublico_ci=0 if emp==1 & (pp46>2 & pp46<=8) 
label var spublico_ci "Personas que trabajan en el sector publico"
*************************************************************************************
*******************************INGRESOS**********************************************
*************************************************************************************

gen YOCUPAPM=pp51
gen YOCUPAM=pp52
gen pp53=pp53j if pp53j>=0 &  pp53j<9999998
gen YOTROS=pp53
gen EDAD=edad_ci

capture drop ylmpri_ci
gen ylmpri_ci=.
replace ylmpri_ci=YOCUPAPM if YOCUPAPM~=-1 & YOCUPAPM~=-2 & YOCUPAPM~=-3
* The values '-3': '-2' and '-1' are 'he/she doesn't remember'; 'he/she doesn't answer' and 'don't aply' respectively
replace ylmpri_ci=. if EDAD<10
label var ylmpri_ci "Ingreso Laboral Monetario de la Actividad Principal"
replace ylmpri_ci=ylmpri_ci/1000
*Y.L. divido al ingreso entre 1000 para hacerlo comparable a lo largo del tiempo

g nrylmpri_ci=(ylmpri_ci==. & emp_ci==1)
replace nrylmpri_ci=. if emp_ci!=1 | categopri_ci==4 /*excluding unpaid workers*/
label var nrylmpri_ci "Id no respuesta ingreso de la actividad principal"  


gen ylmsec_ci=.	
label var ylmsec_ci "Ingreso Laboral Monetario de la Actividad Secundaria"

gen ylmotros_ci=.
label var ylmotros_ci "Ingreso Laboral Monetario Otros Trabajos"

gen ylnmpri_ci=.
label var ylnmpri_ci "Ingreso Laboral NO Monetario de la Actividad Principal"

gen ylnmsec_ci=.	
label var ylnmsec_ci "Ingreso Laboral NO Monetario de la Actividad Secundaria"

gen ylnmotros_ci=.
label var ylnmotros_ci "Ingreso Laboral NO Monetario Otros Trabajos"

gen ylm_ci=.
replace ylm_ci=YOCUPAM if (YOCUPAM~=-1 & YOCUPAM~=-2 & YOCUPAM~=-3) & /*
	*/(YOCUPAPM~=-1 & YOCUPAPM~=-2 & YOCUPAPM~=-3) & (YOCUPAPM<=YOCUPAM)
replace ylm_ci=YOCUPAPM if (YOCUPAPM~=-1 & YOCUPAPM~=-2 & YOCUPAPM~=-3) & (YOCUPAPM>YOCUPAM)
* The values '-3': '-2' and '-1' are 'he/she doesn't remember'; 'he/she doesn't answer' and 'don't aply' respectively
* The survey gives directly ylmpri_ci and ylm_ci through YOCUPAPM and YOCUPAM but for some observations YOCUPAPM > YOCUPAM;
replace ylm_ci=. if EDAD<10
label var ylm_ci "Ingreso Laboral Monetario Total"
replace ylm_ci=ylm_ci/1000
*Y.L. divido al ingreso entre 1000 para hacerlo comparable a lo largo del tiempo

gen ylnm_ci=.
label var ylnm_ci "Ingreso Laboral NO Monetario Total"

gen ynlm_ci=.
replace ynlm_ci=YOTROS if YOTROS~=-1 & YOTROS~=-2 & YOTROS~=-3
replace ynlm_ci=. if EDAD<10
label var ynlm_ci "Ingreso NO Laboral Monetario"
replace ynlm_ci=ynlm_ci/1000
*Y.L. divido al ingreso entre 1000 para hacerlo comparable a lo largo del tiempo

gen ynlnm_ci=.
label var ynlnm_ci "Ingreso NO Laboral NO Monetario"

capture drop nrylmpri_ci
gen nrylmpri_ci=.
replace nrylmpri_ci=0 if (YOCUPAPM~=-1 & YOCUPAPM~=-2 & YOCUPAPM~=-3)
replace nrylmpri_ci=1 if (YOCUPAPM==-2 | YOCUPAPM==-3) 
label var nrylmpri_ci "Identificador de No Respuesta del Ingreso Monetario de la Actividad Principal"

gen autocons_ci=.
label var autocons_ci "Autoconsumo Individual"

gen remesas_ci=.
label var remesas_ci "Remesas Individuales"

capture drop nrylmpri_ch
sort idh
egen nrylmpri_ch=sum(nrylmpri_ci) if miembro==1, by(idh) 
replace nrylmpri_ch=1 if nrylmpri_ch>1 & nrylmpri_ch~=. & miembro==1 
label var nrylmpri_ch "Identificador de Hogares en donde alguno de los miembros No Responde el Ingreso Monetario de la Actividad Principal"

egen ylm_ch=sum(ylm_ci) if miembros_ci==1, by(idh_ch)
label var ylm_ch "Ingreso Laboral Monetario del Hogar"

egen ylmnr_ch=sum(ylm_ci) if miembros_ci==1 & nrylmpri_ch==0, by(idh_ch)
label var ylmnr_ch "Ingreso Laboral Monetario del Hogar, considera 'missing' la No Respuesta"

egen ylnm_ch=sum(ylnm_ci) if miembros_ci==1, by(idh_ch)
label var ylnm_ch "Ingreso Laboral No Monetario del Hogar"

egen ynlm_ch=sum(ynlm_ci) if miembros_ci==1, by(idh_ch)
label var ynlm_ch "Ingreso No Laboral Monetario del Hogar"

egen ynlnm_ch=sum(ynlnm_ci) if miembros_ci==1, by(idh_ch)
label var ynlnm_ch "Ingreso No Laboral No Monetario del Hogar"

egen autocons_ch=sum(autocons_ci) if miembros_ci==1, by(idh_ch)
label var autocons_ch "Autoconsumo del Hogar"

egen remesas_ch=sum(remesas_ci) if miembros_ci==1, by(idh_ch)
label var remesas_ch "Remesas del Hogar (monetario + especies)"

replace ylnm_ch=. if ylnm_ci==.
replace ynlnm_ch=. if ynlnm_ci==.
replace autocons_ch=. if autocons_ci==.
replace remesas_ch=. if remesas_ci==.
replace ylm_ch =. if miembros_ci==0
replace ylmnr_ch =. if miembros_ci==0
replace ylnm_ch =. if miembros_ci==0
replace ynlnm_ch =. if miembros_ci==0
replace autocons_ch =. if miembros_ci==0
replace remesas_ch =. if miembros_ci==0
replace ynlm_ch =. if miembros_ci==0

gen ylmhopri_ci=.
replace ylmhopri_ci=ylmpri_ci/(horaspri*4.3)
label var ylmhopri_ci "Salario Horario Monetario de la Actividad Principal"

gen ylmho_ci=.
label var ylmho_ci "Salario Horario Monetario de todas las Actividades"
gen tcylmpri_ci=.
gen tcylmpri_ch=.
gen rentaimp_ch=.

***********************************************
* VARIABLES DE EDUCACI�N
***********************************************
gen NIVEL=pp25a
gen GRADO=pp25b
gen ULTSEM=pp25c
gen ASIST=pp27

capture drop asiste_ci
gen byte asiste_ci=.
replace asiste_ci=1 if ASIST==1
replace asiste_ci=0 if ASIST==2
label var asiste "Personas que actualmente asisten a centros de ense�anza"

capture drop aedu_ci
gen byte aedu_ci=.
replace aedu=0 if NIVEL==1 | NIVEL==2
replace aedu=GRADO if NIVEL==3 & GRADO>0
replace aedu=GRADO+9 if NIVEL==4 & GRADO>0 & GRADO<=2
replace aedu=11 if NIVEL==4 & GRADO>2
replace aedu=GRADO+11 if (NIVEL==5 | NIVEL==6) & GRADO>0 
replace aedu=int(ULTSEM/2)+11 if (NIVEL==5 | NIVEL==6) & ULTSEM>0 
label variable aedu_ci "A�os de Educacion"


* Unfortunately, we found people with more years of education that years of life. 
* Then, assuming that everyone enters to school not before 5 years old. To correct this:
forvalues i=0(1)18 {
if `i'==0 {
replace aedu=`i' if (aedu>`i' & aedu~=.) & (edad_ci==3 | edad_ci==4 | edad_ci==5)
}
if `i'~=0 {
replace aedu=`i' if (aedu>`i' & aedu~=.) & edad_ci==(`i'+5)
}
}

gen eduno_ci=.
replace eduno=1 if NIVEL==1
replace eduno=0 if NIVEL>1 & NIVEL<=6
label var eduno_ci "1 = personas sin educacion (excluye preescolar)"

gen edupre_ci=.
replace edupre=1 if NIVEL==2
replace edupre=0 if NIVEL>2 | NIVEL==1
label var edupre_ci "Educacion preescolar"

gen edupi_ci=.
replace edupi=1 if aedu>0 & aedu<6
replace edupi=0 if aedu==0 | (aedu>=6 & aedu!=.)
label var edupi_ci "1 = personas que no han completado el nivel primario"

gen edupc_ci=.
replace edupc=1 if aedu==6
replace edupc=0 if (aedu>=0 & aedu<6)  | (aedu>6 & aedu!=.) 
label var edupc_ci "1 = personas que han completado el nivel primario"

gen edusi_ci=.
replace edusi=1 if aedu>6 & aedu<11
replace edusi=0 if (aedu>=0 & aedu<=6) | (aedu>=11 & aedu!=.)
label var edusi_ci "1 = personas que no han completado el nivel secundario"

gen edusc_ci=.
replace edusc=1 if aedu==11 
replace edusc=0 if (aedu>=0 & aedu<11) | (aedu>11 & aedu!=.) 
label var edusc_ci "1 = personas que han completado el nivel secundario"

/*
gen eduui_ci=.
replace eduui=1 if aedu>11 & ((aedu<14 & NIVEL==5) | (aedu<16 & NIVEL==6))
replace eduui=0 if (aedu>=0 & aedu<=11) | (aedu>=16 & aedu!=. & NIVEL==6) | (aedu>=14 & aedu!=. & NIVEL==5) | (NIVEL==4 & GRADO==3 & aedu==12)
label var eduui_ci "1 = personas que no han completado el nivel universitario o superior"

gen eduuc_ci=.
replace eduuc=1 if (aedu>=16 & aedu!=. & NIVEL==6) | (aedu>=14 & aedu!=. & NIVEL==5)
replace eduuc=0 if aedu>=0 & ((aedu<14) | (aedu<16 & NIVEL==6))
label var eduuc_ci "1 = personas que han completado el nivel universitario o superior"
*/

gen eduui_ci=.
replace eduui=1 if aedu>11 & aedu<16
replace eduui=0 if (aedu>=0 & aedu<=11) | (aedu>=16 & aedu!=.) 
label var eduui_ci "1 = personas que no han completado el nivel universitario o superior"

gen eduuc_ci=.
replace eduuc=1 if aedu>=16 & aedu!=.
replace eduuc=0 if (aedu>=1 & aedu<16) 
label var eduuc_ci "1 = personas que han completado el nivel universitario o superior"


gen edus1i_ci=.
replace edus1i=0 if edusi==1 | edusc==1 
replace edus1i=1 if edusi==1 & (NIVEL==3 & (GRADO==7 | GRADO==8))
label var edus1i_ci "1 = personas que no han completado el primer ciclo de la educacion secundaria"

gen edus1c_ci=.
replace edus1c=0 if edusi==1 | edusc==1 
replace edus1c=1 if edusi==1 & (NIVEL==3 & GRADO==9)
label var edus1c_ci "1 = personas que han completado el primer ciclo de la educacion secundaria"

gen edus2i_ci=.
replace edus2i=0 if edusi==1 | edusc==1 
replace edus2i=1 if edusi==1 & (NIVEL==4 & GRADO<2) 
label var edus2i_ci "1 = personas que no han completado el segundo ciclo de la educacion secundaria"

gen edus2c_ci=.
replace edus2c=0 if edusi==1 
replace edus2c=1 if edusc==1
label var edus2c_ci "1 = personas que han completado el segundo ciclo de la educacion secundaria"

gen eduac_ci=.
replace eduac=0 if eduui==1 | eduuc==1
replace eduac=1 if NIVEL==6
label var eduac_ci "Educacion terciaria acad�mica versus educaci�n terciaria no-acad�mica "

gen repite_ci=.
label var repite_ci "Personas que han repetido al menos un a�o o grado"

gen repiteult_ci=.
label var repiteult_ci "Personas que han repetido el ultimo grado"

gen edupub_ci=.
label var edupub_ci "1 = personas que asisten a centros de ense�anza publicos"

** Generating pqnoasis
gen byte pqnoasis_ci=.
replace pqnoasis=pp28 if pp28>0
label variable pqnoasis "Razones para no asistir a centros de ense�anza"
label define pqnoasis 1 "Culmino sus estudios" 2 "No hay grado o agnos superiores" 3 "No hay cupo, escuela distante, desordenes estudiantiles, inasistencia de maestros o profesores" /*
*/ 4 "falta de recursos economicos" 5 "esta trabajando" 6 "asiste a un curso de capacitacion" 7 "no quiere estudiar" 8 "enfermedad o defecto fisico" /*
*/ 9 "problemas de conducta o de aprendizaje" 10 "cambio de residencia" 11 "edad mayor que la regular" 12 "tiene que ayudar en la casa" /*
*/ 13 "edad menor que la regular" 14 "va a tener un hijo o se caso" 15 "otros"
label values pqnoasis_ci pqnoasis_ci

**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**
	
**************
*pqnoasis1_ci*
**************
g       pqnoasis1_ci = 1 if pp28 ==4
replace pqnoasis1_ci = 2 if pp28 ==5
replace pqnoasis1_ci = 3 if pp28 ==8  | pp28 ==9
replace pqnoasis1_ci = 4 if pp28 ==7
replace pqnoasis1_ci = 5 if pp28 ==12 | pp28 ==14
replace pqnoasis1_ci = 6 if pp28 ==1
replace pqnoasis1_ci = 7 if pp28 ==11 | pp28 ==13
replace pqnoasis1_ci = 8 if pp28 ==2  | pp28 ==3 
replace pqnoasis1_ci = 9 if pp28 ==6  | pp28 ==10 | pp28 ==15

label define pqnoasis1_ci 1 "Problemas econ�micos" 2 "Por trabajo" 3 "Problemas familiares o de salud" 4 "Falta de inter�s" 5	"Quehaceres dom�sticos/embarazo/cuidado de ni�os/as" 6 "Termin� sus estudios" 7	"Edad" 8 "Problemas de acceso"  9 "Otros"
label value  pqnoasis1_ci pqnoasis1_ci

********************************************
***Variables de Infraestructura del hogar***
********************************************

gen aguared_ch=.
replace aguared_ch=1 if pv7==1
replace aguared_ch=0 if pv7==2 | pv7==3 | pv7==4

gen aguadist_ch=.

gen aguamala_ch=.

gen aguamide_ch=.

gen luz_ch=.
replace luz_ch=1 if pv11a==1
replace luz_ch=0 if pv11a==2

gen luzmide_ch=.

gen combust_ch=.
replace combust_ch=1 if ph14d==1
replace combust_ch=0 if ph14d==2

gen bano_ch=.
replace bano_ch=1 if pv8==1 | pv8==2 | pv8==3
replace bano_ch=0 if pv8==4

gen banoex_ch=.
replace banoex=1 if ph13a==1
replace banoex=0 if ph13a==2

gen des1_ch=.

gen des2_ch=.
replace des2_ch=1 if pv8==1 | pv8==2
replace des2_ch=2 if pv8==3
replace des2_ch=0 if pv8==4

gen piso_ch=.
replace piso_ch=0 if pv4==3
replace piso_ch=1 if pv4==1 | pv4==2
replace piso_ch=2 if pv4==4

gen pared_ch=.
replace pared_ch=0 if pv2==4 | pv2==5 
replace pared_ch=1 if pv2==1 | pv2==2 | pv2==3 
replace pared_ch=2 if pv2==6

gen techo_ch=.
replace techo_ch=0 if pv3==1 
replace techo_ch=1 if pv3==2 | pv3==3 | pv3==4 
replace techo_ch=2 if pv3==5

gen resid_ch=.

gen resid2_ch=.
replace resid2_ch=1 if pv11b==1
replace resid2_ch=0 if pv11b==2

**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
*********************
***aguamejorada_ch***
*********************
gen aguamejorada_ch =.
		
		
*********************
***banomejorado_ch***
*********************
gen  banomejorado_ch =.

gen dorm_ch=.
replace dorm_ch=pv6 if pv6>=0

gen cuartos_ch=.
replace cuartos_ch=pv5 if pv5>=0

gen cocina_ch=.

gen telef_ch=.
replace telef_ch=1 if pv11d==1
replace telef_ch=0 if pv11d==2

gen refrig_ch=.
replace refrig_ch=1 if ph14a==1
replace refrig_ch=0 if ph14a==2

gen freez_ch=.

gen auto_ch=.
replace auto_ch=1 if ph15>0 & ph15<.
replace auto_ch=0 if ph15<=0

gen compu_ch=.

gen internet_ch=.

gen cel_ch=.

gen vivi1_ch=.
replace vivi1_ch=1 if pv1==1 | pv1==2 | pv1==5
replace vivi1_ch=2 if pv1==3 | pv1==4
replace vivi1_ch=3 if pv1>5 & pv1<.

gen vivi2_ch=.
replace vivi2_ch=1 if vivi1_ch==1 | vivi1_ch==2
replace vivi2_ch=0 if vivi1_ch==3

gen viviprop_ch=.
replace viviprop_ch=0 if ph16a==3 | ph16a==4
replace viviprop_ch=1 if ph16a==1
replace viviprop_ch=2 if ph16a==2
replace viviprop_ch=3 if ph16a>4 & ph16a<.

gen vivitit_ch=.

gen vivialq_ch=.
replace vivialq_ch=ph16b if ph16b>=0

gen vivialqimp_ch=.


drop YOCUPAPM YOCUPAM YOTROS EDAD NIVEL GRADO ULTSEM ASIST

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









/*
**********************
*** VENEZUELA 2001 ***
**********************

/* 
pp19. Relaci�n de parentesco
 1. Jefe del hogar
 2. Esposa(o), compa�ero(a)
 3. Hijos(as), hijastros(as)
 4. Nietos(as)
 5. Yernos, nueras
 6. Padre, madre
 7. Suegro(a)
 8. Hermano(a)
 9. Cu�ado(a)
 10. Sobrino(a)
 11. T�o(a)
 12. Primo(a)
 13. Abuelo(a)
 14. Otro pariente
 15. No pariente
 16. Servicio dom�stico
 17. Familiares del servicio dom�stico
*/

 gen 	 incl=1 if (pp19>=1  & pp19<=15)
 replace incl=0 if (pp19>=16 & pp19<=17)

* Variables

gen sexo = pp18
gen parentco = pp19
gen edad = pp20
gen alfabet = pp24
gen nivel = pp25a
gen grado = pp25b
gen ultsem = pp25c
gen asiste = pp27
gen factorex = peso /*Indica el peso de la persona dentro de la muestra para el semestre Nacional */
gen rama = pp44
gen categ = pp46
gen ocup = pp43
gen agua = pv7
gen excretas = pv8
gen tipoviv = pv1
gen tenencia = ph16a
gen pared = pv2
gen piso = pv4


** Gender classification of the population refering to the head of the household.

* Household ID 

 sort entidad control localidad area linea num_hog parentco num_per

 gen id_hogar_=1 if parentco==1
 gen id_hogar=sum(id_hogar_)
 gen vectoruno=1
 
 egen pers=sum(vectoruno), by(id_hogar)
 
 sort id_hogar parentco num_per
 
 by id_hogar: gen nper=sum(vectoruno)
 
 sort id_hogar nper

 gen     sexo_d_=1 if parentco==1 & sexo==1
 replace sexo_d_=2 if parentco==1 & sexo==2

 egen sexo_d=max(sexo_d_), by(id_hogar)
  
** Years of education. 

/*

ALFABET �Sabe leer y escribir? (pp24)

NIVEL (pp25a)	
-3: No recuerda
-2: No responde
-1: No aplicable
 1: Sin nivel
 2: Preescolar
 3: B�sica
 4: Media diversificada y profesional
 5: T�cnico superior
 6: Universitario

GRADO (pp25b) 
-3 a 9

ULTSEM (pp25c)
-3 a 14
*/

 gen	 anoest=0  if (nivel==1) | (nivel==2)
 replace anoest=1  if (nivel==3 & grado==1) | (nivel==3 & (grado==-3 | grado==-2)) 
 replace anoest=2  if (nivel==3 & grado==2)
 replace anoest=3  if (nivel==3 & grado==3)
 replace anoest=4  if (nivel==3 & grado==4)
 replace anoest=5  if (nivel==3 & grado==5)
 replace anoest=6  if (nivel==3 & grado==6)
 replace anoest=7  if (nivel==3 & grado==7)
 replace anoest=8  if (nivel==3 & grado==8)
 replace anoest=9  if (nivel==3 & grado==9)
 replace anoest=10 if (nivel==4 & grado==1) | (nivel==4 & (grado==-3 | grado==-2))
 replace anoest=11 if (nivel==4 & grado==2)
 replace anoest=12 if ((nivel==6 | nivel==5) & (grado==1 | (ultsem==1  | ultsem==2))) | (nivel==4 & grado==3) | ((nivel==6 | nivel==5) & ((ultsem==-3 | ultsem==-2) | (grado==-3 | grado==-2)))
 replace anoest=13 if ((nivel==6 | nivel==5) & (grado==2 | (ultsem==3  | ultsem==4)))
 replace anoest=14 if ((nivel==6 | nivel==5) & (grado==3 | (ultsem==5  | ultsem==6)))
 replace anoest=15 if ((nivel==6 | nivel==5) & (grado==4 | (ultsem==7  | ultsem==8)))
 replace anoest=16 if ((nivel==6 | nivel==5) & (grado==5 | (ultsem==9  | ultsem==10)))
 replace anoest=17 if ((nivel==6 | nivel==5) & (grado==6 | (ultsem==11 | ultsem==12)))
 replace anoest=18 if ((nivel==6 | nivel==5) & (grado==7 | (ultsem==13 | ultsem==14)))


 
** Economic Active Population  (10 years or more of age)

* codigo_sum
/* Condici�n de Actividad
0. Edad<=9
1. Trabajo
2. Trabajo (Ayudante Familiar)
3. No trabajo pero tiene Trabajo
4. Busca Trabajo
5. Estudiante 
6. Oficio del Hogar 
7. Jubilado
8. Rentista
9. Otra Situaci�n
10.Incapacitado
11.Buscando Trabajo por Primera vez 
12.Desocupado que no  Busca Trabajo
*/

 gen	 peaa=1 if (codigo_sum==1 | codigo_sum==2  | codigo_sum==3)
 replace peaa=2 if (codigo_sum==4 | codigo_sum==11 | codigo_sum==12)
 replace peaa=3 if (codigo_sum==5 | codigo_sum==6  | codigo_sum==7 | codigo_sum==8 | codigo_sum==9 | codigo_sum==10)

 gen	 TASADESO=0 if peaa==1
 replace TASADESO=1 if peaa==2



 destring entidad, replace

* Divisi�n Pol�tico Administrativa

/*

- Regiones			Estados
   Regi�n Capital 		=> Distrito Federal, Miranda, Vargas
   Regi�n Central 		=> Aragua, Carabobo, Cojedes
   Regi�n de los Llanos		=> Apure, Gu�rico
   Regi�n Centro - Occidental	=> Falc�n, Lara, Portuguesa, Yaracuy	
   Regi�n Zuliana		=> Zulia	
   Regi�n de los Andes		=> Barinas, M�rida, T�chira, Trujillo		
   Regi�n Nor-Oriental		=> Anzo�tegui, Monagas, Nueva Esparta, Sucre
   Regi�n Guayana		=> Amazonas, Bol�var, Delta Amacuro
*/

 gen	 region=1 if entidad==1  | entidad==15 | entidad==24
 replace region=2 if entidad==5  | entidad==8  | entidad==9
 replace region=3 if entidad==4  | entidad==12
 replace region=4 if entidad==11 | entidad==13 | entidad==18 | entidad==22
 replace region=5 if entidad==23
 replace region=6 if entidad==6  | entidad==14 | entidad==20 | entidad==21
 replace region=7 if entidad==3  | entidad==16 | entidad==17 | entidad==19
 replace region=8 if entidad==2  | entidad==7  | entidad==10

 
************************
*** MDGs CALCULATION ***
************************

/*
ALFABET �Sabe leer y escribir? (pp24)

NIVEL (pp25a)	
-3: No recuerda
-2: No responde
-1: No aplicable
 1: Sin nivel
 2: Preescolar
 3: B�sica
 4: Media diversificada y profesional
 5: T�cnico superior
 6: Universitario

GRADO (pp25b) 
-3 a 9

ULTSEM (pp25c)
-3 a 14

ASISTE (pp27)
Personas entre 3 y 21 a�os
Asistencia a un centro de educaci�n

*/

*** GOAL 2. ACHIEVE UNIVERSAL PRIMARY EDUCATION

** Target 3, Indicator: Net Attendance Ratio in Primary
* ISCED 1

 gen	 NERP=0 if (edad>=6 & edad<=11) & (asiste==1 | asiste==2)  
 replace NERP=1 if (edad>=6 & edad<=11) & (asiste==1) & ((nivel==2) | (nivel==3 & (grado>=1 & grado<=5)))

** Target 3, Additional Indicator: Net Attendance Ratio in Secondary
* ISCED 2 & 3

 gen	 NERS=0 if (edad>=12 & edad<=16) & (asiste==1 | asiste==2) 
 replace NERS=1 if (edad>=12 & edad<=16) & (asiste==1) & ((nivel==3 & (grado>=6 & grado<=9)) | (nivel==4 & grado==1))

* Upper secondary
* Media diversificada y profesional

 gen	 NERS2=0 if (edad>=15 & edad<=16) & (asiste==1 | asiste==2)
 replace NERS2=1 if (edad>=15 & edad<=16) & (asiste==1) & ((nivel==3 & grado==9) | (nivel==4 & grado==1))
	
** Target 3, Indicator: Literacy Rate of 15-24 Years Old
* At least 5 years of formal education

 gen	 ALFABET=0 if (edad>=15 & edad<=24) & (anoest>=0 & anoest<99) 
 replace ALFABET=1 if (edad>=15 & edad<=24) & (anoest>=5 & anoest<99) 

** Target 3, Indicator: Literacy Rate of 15-24 Years Old
* Read & write

 gen	 ALFABET2=0 if (edad>=15 & edad<=24) & (alfabet==1 | alfabet==2)
 replace ALFABET2=1 if (edad>=15 & edad<=24) & (alfabet==1)

*** GOAL 3 PROMOTE GENDER EQUALITY AND EMPOWER WOMEN

 gen prim=1 if  (asiste==1) & ((nivel==2) | (nivel==3 & (grado>=1 & grado<=5)))
 gen sec=1  if  (asiste==1) & ((nivel==3 & (grado>=6 & grado<=9)) | (nivel==4 & grado==1))
 gen ter=1  if  (asiste==1) & (anoest>=11 & anoest<=15)

** Target 4, Indicator: Ratio Girls to boys in primary, secondary and tertiary (%)

** Target 4, Ratio of Girls to Boys in Primary*

 gen RPRIMM=1 if (prim==1) & sexo==2 
 replace RPRIMM=0 if RPRIMM==. 
 gen RPRIMH=1 if (prim==1) & sexo==1 
 replace RPRIMH=0 if RPRIMH==.

 gen RATIOPRIM=0 if     (prim==1) & sexo==2  
 replace RATIOPRIM=1 if (prim==1)  & sexo==1   
	
** Target 4, Ratio of Girls to Boys in Secondary*

 gen RSECM=1 if (sec==1) & sexo==2 
 replace RSECM=0 if RSECM==.
 gen RSECH=1 if (sec==1) & sexo==1 
 replace RSECH=0 if RSECH==.

 gen RATIOSEC=0     if (sec==1) & sexo==2 
 replace RATIOSEC=1 if (sec==1) & sexo==1  
	
** Target 4, Indicator: Ratio of Girls to Boys in Tertiary*

 gen RTERM=1 if (ter==1) & sexo==2 
 replace RTERM=0 if RTERM==.
 gen RTERH=1 if (ter==1) & sexo==1 
 replace RTERH=0 if RTERH==.

 gen RATIOTER=0     if (ter==1) & sexo==2 
 replace RATIOTER=1 if (ter==1) & sexo==1  

** Target 4, Indicator: Ratio of Girls to Boys in Primary, Secondary and Tertiary*

 gen RALLM=1 if (prim==1 | sec==1 | ter==1) & sexo==2 
 replace RALLM=0 if RALLM==.
 gen RALLH=1 if (prim==1 | sec==1 | ter==1) & sexo==1 
 replace RALLH=0 if RALLH==.

 gen     RATIOALL=0 if (prim==1 | sec==1 | ter==1) & sexo==2  
 replace RATIOALL=1 if (prim==1 | sec==1 | ter==1) & sexo==1    

** Target 4, Indicator: Ratio of literate women to men 15-24 year olds*
* At least 5 years of formal education

 gen MA=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace MA=0 if MA==.
 gen HA=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==1)) 
 replace HA=0 if HA==.

 gen     RATIOLIT=0 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace RATIOLIT=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==1)) 

** Target 4, Indicator: Ratio of literate women to men 15-24 year olds*
* Knows how to read & write

 gen MA2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace MA2=0 if MA2==.
 gen HA2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==1)) 
 replace HA2=0 if HA2==.

 gen     RATIOLIT2=0 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace RATIOLIT2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==1)) 
	
** Target 4, Indicator: Share of women in wage employment in the non-agricultural sector (%)

/*
PP46 CATEGORIA DE OCUPACI�N		 PP44 RAMA	PP43 OCUPACION
46: En su trabajo principal es (era:)			81. Trabajadores de servicios 	
1. Empleado gubernamental				dom�sticos (en hogares particulares)
2. Obrero gubernamental
3. Empleado en empresa particular
4. Obrero en empresa particular
5. Miembro de cooperativa (o sociedades de personas solo a partir de 2003)
6. Trabajador por cuenta propia
7. Patrono o empleador
8. Ayudante no remunerado (familiar o no familiar)
*/

* Without Domestic Service

 gen	 WENAS=0 if (edad>=15 & edad<=64) & (categ>=1 & categ<=4) & (rama>=210 & rama<=960) & (peaa==1) & (ocup!=81)
 replace WENAS=1 if (edad>=15 & edad<=64) & (categ>=1 & categ<=4) & (rama>=210 & rama<=960) & (peaa==1) & (ocup!=81) & (sexo==2)

** Target 4, Indicator: Share of women in wage employment in the non-agricultural sector (%)
* With domestic servants

 gen	 WENASD=0 if (edad>=15 & edad<=64) & (categ>=1 & categ<=4) & (rama>=210 & rama<=960) & (peaa==1)
 replace WENASD=1 if (edad>=15 & edad<=64) & (categ>=1 & categ<=4) & (rama>=210 & rama<=960) & (peaa==1) & (sexo==2)

*** GOAL 7 ENSURE ENVIROMENTAL SUSTAINABILITY

** Target 10, Indicator: Proportion of the population with sustainable access to an improved water source (%)

/*
pv1. Tipo de vivienda
 1. Quinta (o casa quinta 2003)
 2. Casa
 3. Apartamento en edificio
 4. Apartamento en quinta o casa-quinta (� casa solo 2003)
 5. Casa de vecindad
 6. Vivienda Rustica o (Rancho)
 7. Rancho campesino
 8. Otro tipo ==> -1 (pv2 - pv10, pv11a - pv11c)
 9. Colectividad
*/

 gen	 excl_hou=1 if tipoviv==8
 recode  excl_hou (.=0)

** Electricity. Additional Indicator

/*
SERVICIO EL�CTRICO P�BLICO
PV11A	Servicio el�ctrico p�blico

*/

* Gender classification of the population refers to the head of the household.

 gen	 ELEC=0 if (pv11a>=1 & pv11a<=5) /* Total population excluding missing information */
 replace ELEC=1 if (pv11a==1 | pv11a==2)

** Target 10, Indicator: Proportion of the population with sustainable access to an improved water source (%)
 	
* Gender classification of the population refers to the head of the household.

/*
pv7. Agua
7: A esta vivienda llega el agua por:
-1. No aplicable
 1. Acueducto
 2. Pila p�blica
 3. Cami�n
 4. Otros medios
*/

 gen	 WATER=0 if (agua>=1 & agua<=4) /* Total population excluding missing information */
 replace WATER=1 if (agua>=1 & agua<=2)

** Target 10, Indicator: Proportion of Population with Access to Improved Sanitation, Urban and Rural (%)
/*
pv8. excretas
8: Esta vivienda tiene:
-1. No aplicable
1. Poceta a cloaca
2. Poceta a pozo s�ptico
3. Excusado a hoyo o letrina
4. No tiene poceta o excusado
*/

* Gender classification of the population refers to the head of the household.

 gen	 SANITATION=0 if (excretas>=1 & excretas<=4) /* Total population excluding missing information */
 replace SANITATION=1 if (excretas>=1 & excretas<=2)

** Target 11, Indicator: Proportion of the population with access to secure tenure (%)

/*
pv1. Tipo de vivienda
 1. Quinta (o casa quinta 2003)
 2. Casa
 3. Apartamento en edificio
 4. Apartamento en quinta o casa-quinta (� casa solo 2003)
 5. Casa de vecindad
 6. Vivienda Rustica o (Rancho)
 7. Rancho campesino
 8. Otro tipo ==> -1 (pv2 - pv10, pv11a - pv11c)
 9. Colectividad

ph16a. Tenencia
16: Para este hogar la vivienda es:
 1. Propia pagada totalmente
 2. Propia pag�ndose
 3. Alquilada
 4. Alquilada parte de la vivienda
 5. Cedida por razones de trabajo
 6. Cedida por familiar o amigo
 7. Tomada
 8. Otra forma

pv2. Paredes
2: El material predominante en las paredes exteriores es:
-1. No aplicable
 1. Bloque o ladrillo frisado (acabado) (concreto prefabricado 2003)
 2. Bloque o ladrillo sin frisar
 3. Madera aserrada (Formica de vidrio y similares 2003)
 4. Adobe - tapia - bahareque frisado
 5. Adobe - tapia - bahareque sin frisar
 6. Otros (ca�a, palos, tablas, etc)

pv4. Piso
4: El material predominante en el piso es:
-1. No aplicable
 1. Mosaico, granito, vinil,ceramica, ladrillo, terracota, parquet, alfombra y similares (marmol, s�lo a partir de 2003)
 2. Cemento
 3. Tierra
 4. Otros 

pv5. N�mero de cuartos

Contando sala, comedor, cuartos para dormir y otros cuartos.
�Cu�ntos cuartos en total tiene esta vivienda?
-1. No aplicable
*/

 gen nrocuart=pv5 if pv5>0

 gen persroom=pers/nrocuart 

* Indicator components

* 1. Non secure tenure or type of dwelling.

 gen secten_1=0     if ((tenencia>=1 & tenencia<=9) & (tipoviv>=1 & tipoviv<=8)) /* Total population excluding missing information */
 replace secten_1=1 if ((tenencia>=5 & tenencia<=9) | (tipoviv>=6 & tipoviv<=8))

* 2. Low quality of the floor or walls materials.

 gen secten_2=0     if ((pared>=1 & pared<=6) & (piso>=1 & piso<=4))         /* Total population excluding missing information */
 replace secten_2=1 if ((pared>=5 & pared<=6) | (piso>=3 & piso<=4))

* 3. Crowding (defined as not more than two people sharing the same room)

 gen secten_3=1     if (persroom>2) 
 
* 4. Lack of basic services

 gen secten_4=1	   if (SANITATION==0 | WATER==0) 

* Gender classification of the population refers to the head of the household.

 gen     SECTEN=1 if  (secten_1>=0 & secten_1<=1) & (secten_2>=0 & secten_2<=1) /* Total population excluding missing information */
 replace SECTEN=0 if  (secten_1==1 | secten_2==1 | secten_3==1 | secten_4==1)

* Dirt floors ** Additional indicator

* Gender classification of the population refers to the head of the household.

 gen	 DIRT=0 if (piso>=1 & piso<=4)
 replace DIRT=1 if (piso==3)

** GOAL 8. DEVELOP A GLOBAL PARTNERSHIP FOR DEVELOPMENT

** Target 16, Indicator: Unemployment Rate of 15 year-olds (%)

 gen	 UNMPLYMENT15=0 if (TASADESO==0 | TASADESO==1) & (edad>=15 & edad<=24)
 replace UNMPLYMENT15=1 if (TASADESO==1) 	       & (edad>=15 & edad<=24)

*** Target 18, Indicator: "Telephone lines and celullar subscribers per 100 population"

/*
pv11d. �Posee servicio Telef�nico fijo?

Variables at household level
*/

gen tel = pv11d
 
* Gender classification of the population refers to the head of the household.

 gen     TELCEL=0 if  (tel==1 | tel==2)
 replace TELCEL=1 if  (tel==1)

** FIXED LINES

* Gender classification of the population refers to the head of the household.

 gen     TEL=0 if  (tel==1 | tel==2)
 replace TEL=1 if  (tel==1)

** Target 18, Indicator: "Personal computers in use per 100 population"

* NA

** Target 18, Indicator: "Internet users per 100 population"

* NA

*************************************************************************
**** ADDITIONAL SOCIO - ECONOMIC COMMON COUNTRY ASESSMENT INDICATORS ****
*************************************************************************

** CCA 19. Proportion of children under 15 who are working
* 12 to 14

 gen     CHILDREN=0 if (edad>=12 & edad<=14) 
 replace CHILDREN=1 if (edad>=12 & edad<=14) & peaa==1

** CCA 41 Number of Persons per Room*

 generate PERSROOM2=persroom if parentco==1


 gen 	 popinlessthan2=1 if persroom<=2
 replace popinlessthan2=0 if popinlessthan2==.

* Gender classification of the population refers to the head of the household.

 gen     PLT2=0 if persroom<. 		/* Total population excluding missing information */
 replace PLT2=1 if (popinlessthan2==1)
	
/*
codigo_sum
0. Edad<=9
1. Trabajo
2. Trabajo (Ayudante Familiar)
3. No trabajo pero tiene Trabajo
4. Busca Trabajo
5. Estudiante 
6. Oficio del Hogar 
7. Jubilado
8. Rentista
9. Otra Situaci�n
10.Incapacitado
11.Buscando Trabajo por Primera vez 
12.Desocupado que no  Busca Trabajo

*/

 gen	 DISCONN=0 if (edad>=15 & edad<=24)
 replace DISCONN=1 if (edad>=15 & edad<=24) & (codigo_sum==7 | codigo_sum==9 | codigo_sum==12) 

******************************************************
**** ADDITIONAL INDICATORS RELATED TO EDUCATION ******
******************************************************

*** Rezago escolar

 gen	 rezago=0	if (anoest>=0 & anoest<99)  & edad==6 /* This year of age is not included in the calculations */
	 
 replace rezago=1 	if (anoest>=0 & anoest<1 )  & edad==7
 replace rezago=0 	if (anoest>=1 & anoest<99)  & edad==7

 replace rezago=1 	if (anoest>=0 & anoest<2 )  & edad==8
 replace rezago=0	if (anoest>=2 & anoest<99)  & edad==8

 replace rezago=1 	if (anoest>=0 & anoest<3 )  & edad==9
 replace rezago=0	if (anoest>=3 & anoest<99)  & edad==9

 replace rezago=1 	if (anoest>=0 & anoest<4 )  & edad==10
 replace rezago=0	if (anoest>=4 & anoest<99)  & edad==10

 replace rezago=1 	if (anoest>=0 & anoest<5 )  & edad==11
 replace rezago=0	if (anoest>=5 & anoest<99)  & edad==11

 replace rezago=1	if (anoest>=0 & anoest<6)   & edad==12
 replace rezago=0	if (anoest>=6 & anoest<99)  & edad==12

 replace rezago=1 	if (anoest>=0 & anoest<7)   & edad==13
 replace rezago=0	if (anoest>=7 & anoest<99)  & edad==13

 replace rezago=1 	if (anoest>=0 & anoest<8)   & edad==14
 replace rezago=0	if (anoest>=8 & anoest<99)  & edad==14

 replace rezago=1 	if (anoest>=0 & anoest<9 )  & edad==15
 replace rezago=0	if (anoest>=9 & anoest<99)  & edad==15
 
 replace rezago=1 	if (anoest>=0  & anoest<10) & edad==16
 replace rezago=0	if (anoest>=10 & anoest<99) & edad==16
 
* Primary and Secondary [ISCED 1, 2 & 3]

 gen 	 REZ=0 if  (edad>=7 & edad<=16) & (rezago==1 | rezago==0)
 replace REZ=1 if  (edad>=7 & edad<=16) & (rezago==1)

* Primary completion rate [15 - 24 years of age]

 gen     PRIMCOMP=0 if  (edad>=15 & edad<=24) & (anoest>=0  & anoest<99)
 replace PRIMCOMP=1 if  (edad>=15 & edad<=24) & (anoest>=6  & anoest<99)
	
* Average years of education of the population 15+

 gen     AEDUC_15=anoest if  ((edad>=15) & (anoest>=0 & anoest<99))
 gen     AEDUC_15_24=anoest if  ((edad>=15 & edad<=24) & (anoest>=0 & anoest<99))
 gen     AEDUC_25=anoest if  ((edad>=25) & (anoest>=0 & anoest<99))
	
* Grade for age

 gen GFA=(anoest/(edad-6)) if (edad>=7 & edad<=16) & (anoest>=0 & anoest<99)
	
* Grade for age primary

 gen GFAP=(anoest/(edad-6)) if (edad>=7 & edad<=11) & (anoest>=0 & anoest<99)
	
* Grade for age Secondary

 gen GFAS=(anoest/(edad-6)) if (edad>=12 & edad<=16) & (anoest>=0 & anoest<99)


