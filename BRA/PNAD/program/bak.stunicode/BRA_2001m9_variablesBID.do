* (versi�n Stata 13)
clear
set more off
*________________________________________________________________________________________________________________*

 * Activar si es necesario (dejar desactivado para evitar sobreescribir la base y dejar la posibilidad de 
 * utilizar un loop)
 * Los datos se obtienen de las carpetas que se encuentran en el servidor: \\Sdssrv03\surveys
 * Se tiene acceso al servidor �nicamente al interior del BID.
 * El servidor contiene las bases de datos MECOvI.
 *________________________________________________________________________________________________________________*
 

global ruta = "\\Sdssrv03\surveys"

local PAIS BRA
local ENCUESTA PNAD
local ANO "2001"
local ronda m9 
local log_file = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\log\\`PAIS'_`ANO'`ronda'_variablesBID.log"
local base_in  = "$ruta\survey\\`PAIS'\\`ENCUESTA'\\`ANO'\\`ronda'\data_merge\\`PAIS'_`ANO'`ronda'.dta"
local base_out = "$ruta\harmonized\\`PAIS'\\`ENCUESTA'\data_arm\\`PAIS'_`ANO'`ronda'_BID.dta"
                        
capture log close
log using "`log_file'", replace 


/***************************************************************************
                 BASES DE DATOS DE ENCUESTA DE HOGARES - SOCIOMETRO 
Pa�s: Brasil
Encuesta: PNAD
Round: m9
Autores: 
Generaci�n nuevas variables LMK: Yessenia Loayza (desloay@hotmail.com)
Modificaci�n 2014: Mayra S�enz - Email: mayras@iadb.org - saenzmayra.a@gmail.com
versi�n 2010: Yanira Oviedo
�ltima versi�n: Yessenia Loayza - Email: desloay@hotmail.com | yessenial@iadb.org
�ltima modificaci�n: Daniela Zuluaga E-mail: danielazu@iadb.org, da.zuluaga@hotmail.com
Fecha �ltima modificaci�n: Octubre de 2017

							SCL/LMK - IADB
****************************************************************************/
****************************************************************************/

*Nota: Bases de datos con nuevos pesos (descargadas el 30 septiembre 2013)

use `base_in', clear

*****************
*** region_ci ***
*****************
*YL: generacion "region_c" proyecto maps America.		
destring uf, replace
gen region_c = uf
label define region_c ///
11 "Rond�nia" ///
12 "Acre" ///
13 "Amazonas" ///
14 "Roraima" ///
15 "Par�" ///
16 "Amap�" ///
17 "Tocantins" ///
21 "Maranh�o" ///
22 "Piau�" ///
23 "Cear�" ///
24 "Rio Grande do Norte" ///
25 "Para�ba" ///
26 "Pernambuco" ///
27 "Alagoas" ///
28 "Sergipe" ///
29 "Bahia" ///
31 "Minas Gerais" ///
32 "Esp�rito Santo" ///
33 "Rio de Janeiro" ///
35 "S�o Paulo" ///
41 "Paran�" ///
42 "Santa Catarina" ///
43 "Rio Grande do Sul" ///
50 "Mato Grosso do Sul" ///
51 "Mato Grosso" ///
52 "Goi�s" ///
53 "Distrito Federal"
label value region_c region_c

************************
*** region seg�n BID ***
************************
gen region_BID_c=4 
label var region_BID_c "Regiones BID"
label define region_BID_c 1 "Centroam�rica_(CID)" 2 "Caribe_(CCB)" 3 "Andinos_(CAN)" 4 "Cono_Sur_(CSC)"
label value region_BID_c region_BID_c


/********************************/
/*    vARIABLES DEL HOGAR	*/
/********************************/

***************
****idh_ch*****
***************
*YL: A nivel de familia.
sort uf v0102 v0103 v0403
egen idh_ch=group(uf v0102 v0103 v0403)
label variable idh_ch "ID del hogar"

capture rename v4755 v4714
capture rename v4760 v4710
capture rename v4759 v4709
gen idp_ci=v0301
gen factor_ch=v4611
gen zona_c=1 if v4105>=1 & v4105<=3
replace zona_c=0 if v4105>=4 & v4105<=8
gen str3 pais_c="BRA"
gen anio_c=2001
gen mes_c=9
gen relacion_ci=v0402
replace relacion_ci=5 if v0402==5|v0402==6|v0402==8
replace relacion_ci=6 if v0402==7
label define relacion_ci 1 "Jefe" 2 "Conyuge" 3 "Hijo" 4 "Otros Parientes" 5 "Otros no Parientes" 6 "Servicio Domestico"
label values relacion_ci relacion_ci

/************************************************************************/
/*			vARIABLES DE INFRAESTRUCTURA DEL HOGAR		*/
/************************************************************************/	
gen aguared_ch=(v0212==2 | v0213==1)
gen aguadist_ch=1 if v0211==1 |v0213==1
replace aguadist_ch=2 if v0214==2
replace aguadist_ch=3 if v0214==4
replace aguadist_ch=0 if v0214==9 
gen aguamala_ch=(v0212==6) /*"Otra"*/	
gen aguamide_ch=.
gen luz_ch=(v0219==1)
replace luz_ch=. if v0219==9
gen luzmide_ch=.
gen combust_ch=(v0223==1|v0223==2|v0223==5)
replace combust_ch=. if v0223==9
gen bano_ch=(v0215==1)
replace bano_ch=. if v0215==9
gen banoex_ch=(v0216==2)
replace banoex_ch=. if bano_ch==0 | bano_ch==.|v0216==9
gen des1_ch=1 if v0217>=1 & v0217<=3
replace des1_ch=2 if v0217==4
replace des1_ch=3 if v0217>=5
replace des1_ch=0 if bano_ch==0
replace des1_ch=. if v0217==9

*************
***des2_ch***
*************
*El indicador deber�a ser una reclasificaci�n de des1_ch, por ello se cambia aqu�: 
gen des2_ch=0 if des1_ch==0
replace des2_ch=1 if des1_ch==1 | des1_ch==2 
replace des2_ch=2 if des1_ch==3
label var des2_ch "Tipo de desague sin incluir definici�n MDG"
label def des2_ch 0"No tiene servicio sanitario" 1"Conectado a red general, c�mara s�ptica, pozo o letrina"
label def des2_ch 2"Cualquier otro caso", add
label val des2_ch des2_ch

gen piso_ch=.


**************
***pared_ch***
**************
* Se cambia la construcci�n de la variable incluyendo: tapia sin revestir y de paja 
/*
gen pared_ch=0
replace pared_ch=1 if v0203==1 | v0203==2 |v0203==4
replace pared_ch=2 if v0203==6 | v0203==3 |v0203==5
replace pared_ch=. if v0203==9
label var pared_ch "Materiales de construcci�n de las paredes"
label def pared_ch 0"No permanentes" 1"Permanentes" 2"Otros materiales:otros"
label val pared_ch pared_ch
*/
* MGR Jul, 2015: se modifica sint�xis para incluir opci�n 5 (paja) como material impermanente
gen pared_ch=0 if v0203==5 
replace pared_ch=1 if v0203==1 | v0203==2 |v0203==4
replace pared_ch=2 if v0203==6 | v0203==3 
replace pared_ch=. if v0203==9
label var pared_ch "Materiales de construcci�n de las paredes"
label def pared_ch 0"No permanentes" 1"Permanentes" 2"Otros materiales:otros"
label val pared_ch pared_ch

**************
***techo_ch***
**************
/*
*No se inclu�an los techos de paja
gen techo_ch=0
replace techo_ch=1 if v0204<=5
replace techo_ch=2 if v0204==7 |v0204==6
replace techo_ch=. if v0204==9
label var techo_ch "Materiales de construcci�n del techo"
*/
* MGR Jul, 2015: se modifica sint�xis para incluir opci�n 6 (paja) como material impermanente
gen techo_ch=0 if v0204==6
replace techo_ch=1 if v0204<=5
replace techo_ch=2 if v0204==7
replace techo_ch=. if v0204==9
label var techo_ch "Materiales de construcci�n del techo"

gen resid_ch=0 if v0218==1 | v0218==2
replace resid_ch=1 if v0218==3
replace resid_ch=2 if v0218==4 | v0218==5
replace resid_ch=3 if v0218==6
replace resid_ch=. if v0218==9

**Daniela Zuluaga- Enero 2018: Se agregan las variables aguamejorada_ch y banomejorado_ch cuya sintaxis fue elaborada por Mayra Saenz**
	
*********************
***aguamejorada_ch***
*********************
g       aguamejorada_ch = 1 if v0212 == 2 | v0212 ==4
replace aguamejorada_ch = 0 if v0212 == 6
				
*********************
***banomejorado_ch***
*********************
g       banomejorado_ch = 1 if (v0215 == 1 & (v0217 >= 1 & v0217 <=3) & v0216 == 2 )
replace banomejorado_ch = 0 if (v0215 == 1 & (v0217 >= 1 & v0217 <=3) & v0216 == 4) | v0215 == 3 | (v0215 == 1 & (v0217 >= 4 & v0217<=7))
	
	
gen dorm_ch=v0206
replace dorm_ch=. if v0206==99 |v0206==-1
gen cuartos_ch=v0205
replace cuartos_ch=. if v0205==99 | v0205==-1
gen cocina_ch=.
gen refrig_ch=(v0228==2 |v0228==4)
replace refrig_ch=. if v0228==9
gen freez_ch=(v0229==1)
replace freez_ch=. if v0229==9
gen auto_ch=.
gen telef_ch=(v2020==2)
replace telef_ch=. if v2020==9
capture gen compu_ch=(v0231==1)
capture gen internet_ch=(v0232==2)
gen cel_ch=(v0220==2)
gen viv1_ch=1 if v0202==2
replace viv1_ch=2 if v0202==4
replace viv1_ch=3 if v0202==6
gen viv2_ch=(viv1_ch==1 | viv1_ch==2)
replace viv2_ch=. if viv1_ch==.
gen viviprop_ch=0 if v0207==3
replace viviprop_ch=1 if v0207==1
replace viviprop_ch=2 if v0207==2
replace viviprop_ch=4 if v0207>=4
replace viviprop_ch=. if v0207==9
gen vivialq_ch=v0208
replace vivialq_ch=. if vivialq_ch>=999999999 | vivialq_ch<0
gen vivialqimp_ch=.

/************************************************************************/
/*				vARIABLES DEMOGRAFICAS			*/
/************************************************************************/
****************
***miembros_ci***
****************
gen miembros_ci=(relacion_ci<5)
label variable miembros_ci "Miembro del hogar"

*************************
*** VARIABLES DE RAZA ***
*************************

* MGR Oct. 2015: modificaciones realizadas en base a metodolog�a enviada por SCL/GDI Maria Olga Pe�a

/*COR OU RACA V0404
2 BRANCA
4 PRETA
6 AMARELA
8 PARDA
0 INDIGENA
9 IGNORADA*/

gen raza_ci=.
replace raza_ci= 1 if  (v0404 ==0)
replace raza_ci= 2 if  (v0404 ==4 | v0404 ==8)
replace raza_ci= 3 if (v0404==2 | v0404==6 | v0404== 9)& raza_ci==.
label define raza_ci 1 "Ind�gena" 2 "Afro-descendiente" 3 "Otros"
label value raza_ci raza_ci 
label value raza_ci raza_ci
label var raza_ci "Raza o etnia del individuo" 


gen raza_idioma_ci=.

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

gen factor_ci=v4611 /*AUN CUANDO HAY UN FACTOR DE PERSONAS ES IDENTICO AL DE HOGARES, EXCEPTO PARA EL '93 EN DONDE SE REGISTRAN vALORES NEGATIvOS! PARA HOMOGENEIZAR,A TODOS LES PONEMOS EL FACTOR DE EXPANSION DEL HOGAR*/
gen sexo_ci=1 if v0302==2
replace sexo_ci=2 if v0302==4
gen edad_ci=v8005
replace edad_ci=. if edad_ci==999
gen civil_ci=.
capture replace civil_ci=1 if v1001==3 & v1003==3 /*EN ALGUNOS A�OS NO ESTA EL MODULO DE NUPCIALIDAD!*/
capture replace civil_ci=2 if v1001==1
capture replace civil_ci=3 if v1004==2
capture replace civil_ci=4 if v1004==4
gen jefe_ci=(v0402==1)
sort idh_ch
by idh_ch: egen byte nconyuges_ch=sum(relacion_ci==2) 
by idh_ch: egen byte nhijos_ch=sum(relacion_ci==3)
by idh_ch: egen byte notropari_ch=sum(relacion_ci==4)
by idh_ch: egen byte notronopari_ch=sum(relacion_ci==5)
by idh_ch: egen byte nempdom_ch=sum(relacion_ci==6)
gen byte clasehog_ch=0
replace clasehog_ch=1 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch==0 /*Unipersonal*/
replace clasehog_ch=2 if nhijos_ch>0 & notropari_ch==0 & notronopari_ch==0 /*Nuclear (child with or without spouse but without other relatives)*/
replace clasehog_ch=2 if nhijos_ch==0 & nconyuges_ch>0 & notropari_ch==0 & notronopari_ch==0 /*Nuclear (spouse with or without children but without other relatives)*/
replace clasehog_ch=3 if notropari_ch>0 & notronopari_ch==0 /*Ampliado*/
replace clasehog_ch=4 if ((nconyuges_ch>0 | nhijos_ch>0 | notropari_ch>0) & (notronopari_ch>0))/*Compuesto (some relatives plus non relative)*/
replace clasehog_ch=5 if nhijos_ch==0 & nconyuges_ch==0 & notropari_ch==0 & notronopari_ch>0 /*Corresidente*/
sort idh_ch
by idh_ch:egen byte nmiembros_ch=sum(relacion_ci>0 & relacion_ci<5) if miembros_ci==1
by idh_ch:egen byte nmayor21_ch=sum((relacion_ci>0 & relacion_ci<5) & (edad_ci>=21 & edad_ci<=98))
by idh_ch:egen byte nmenor21_ch=sum((relacion_ci>0 & relacion_ci<5) & (edad_ci<21))
by idh_ch:egen byte nmayor65_ch=sum((relacion_ci>0 & relacion_ci<5) & (edad_ci>=65))
by idh_ch:egen byte nmenor6_ch=sum((relacion_ci>0 & relacion_ci<5) & (edad_ci<6))
by idh_ch:egen byte nmenor1_ch=sum((relacion_ci>0 & relacion_ci<5) & (edad_ci<1))

/******************************************************************************/
/*				vARIABLES DE DEMANDA LABORAL		      */
/******************************************************************************/

****************
****condocup_ci*
****************
gen condocup_ci=.
replace condocup_ci=1 if (v9001==1 | v9002==2 | v9003==1 | v9004==2)
replace condocup_ci=2 if  v9004==4 & (v9115==1 & (v9119>=1 & v9119<=8)) /*tomaron alguna providencia en la semana de referencia*/
replace condocup_ci=3 if  condocup_ci!=1 & condocup_ci!=2
replace condocup_ci=4 if edad_ci<10
label define condocup_ci 1"ocupados" 2"desocupados" 3"inactivos" 4"menor 10 a�os"
label value condocup_ci condocup_ci
label var condocup_ci "Condicion de ocupacion utilizando definicion del pais"


/*
Definiciones:
* Popula��o ocupada: Aquelas pessoas que, num determinado per�odo de refer�ncia,
trabalharam ou tinham trabalho mas n�o trabalharam (por exemplo, pessoas em f�rias).

* Popula��o Desocupada: aquelas pessoas que n�o tinham trababalho, num determinado 
per�odo de refer�ncia, mas estavam dispostas a trabalhar, e que, para isso, tomaram
alguma provid�ncia efetiva (consultando pessoas, jornais, etc.).

Popula��o N�o Economicamente Ativa: pessoas n�o classificadas como ocupadas ou 
desocupadas

PET: >=10 a�os de edad
*/

****************
*afiliado_ci****
****************
gen afiliado_ci=.
label var afiliado_ci "Afiliado a la Seguridad Social"

****************
*cotizando_ci***
****************
gen cotizando_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizando_ci=1 if (v9059==1 | v9099==1 | v9103==1 | v9120==2) & cotizando_ci==0 /*solo a emplead@s y asalariad@s, difiere con los otros paises*/
label var cotizando_ci "Cotizante a la Seguridad Social"

gen cotizapri_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizapri_ci=1 if (v9059==1) & cotizando_ci==0 
label var cotizapri_ci "Cotizante a la Seguridad Social por su trabajo principal"

gen cotizasec_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizasec_ci=1 if (v9099==1) & cotizando_ci==0 
label var cotizasec_ci "Cotizante a la Seguridad Social por su trabajo secundario"

gen cotizaotros_ci=0     if condocup_ci==1 | condocup_ci==2 
replace cotizaotros_ci=1 if (v9103==1 | v9120==2) & cotizando_ci==0 
label var cotizaotros_ci "Cotizante a la Seguridad Social por otro trabajos o por aporte privado"

********************
*** instcot_ci *****
********************
gen instcot_ci=.
label var instcot_ci "instituci�n a la cual cotiza"

*****************
*tipocontrato_ci*
*****************
gen tipocontrato_ci=. /*solo se pregunta si tiene o no contrato*/
label var tipocontrato_ci "Tipo de contrato segun su duracion en act principal"
label define tipocontrato_ci 1 "Permanente/indefinido" 2 "Temporal" 3 "Sin contrato/verbal" 
label value tipocontrato_ci tipocontrato_ci

*************
**pension_ci*
*************
*sum v1252 v1255 v1258 v1261
* 2014, 01 revision MLO
foreach var of varlist v1252 v1255 v1258 v1261{ 
replace `var'=. if `var'>=999999 | `var'==-1
}

gen pension_ci=0 
replace pension_ci=1 if (v1252>0 & v1252!=.) | (v1255>0 & v1255!=.) | (v1258>0 & v1258!=.) | (v1261>0 & v1261!=.) /*A todas las per mayores de diez a�os*/
label var pension_ci "1=Recibe pension contributiva"
 
*************
*ypen_ci*
*************
sum v1252 v1255 v1258 v1261
egen ypen_ci=rsum (v1252 v1255 v1258 v1261)
replace ypen_ci=. if ypen_ci<=0
label var ypen_ci "valor de la pension contributiva"

****************
*instpen_ci*****
****************
gen instpen_ci=.
label var instpen_ci "Institucion proveedora de la pension - variable original de cada pais" 

***************
*pensionsub_ci*
***************
/*DZ Octubre 2017- Creacion de la variable  pension subsidiada*
http://dds.cepal.org/bdps/programa/?id=43
segun la fuente, el monto bpc para adultos mayores fue de 180 reales. Se encuentran beneficiarios con dicho monto*/
gen pensionsub_ci=(v1273==180)
label var pensionsub_ci "1=recibe pension subsidiada / no contributiva"


*****************
**  ypensub_ci  *
*****************
/*DZ Octubre 2017- Creacion de la variable valor de la pension subsidiada*
http://dds.cepal.org/bdps/programa/?id=43
segun la fuente, el monto bpc para adultos mayores fue de 180 reales. Se encuentran beneficiarios con dicho monto*/
gen ypensub_ci=v1273 if v1273==180
label var ypensub_ci "Valor de la pension subsidiada / no contributiva"

*************
*cesante_ci* 
*************
generat cesante_ci=0 if condocup_ci==2
replace cesante_ci=1 if (v9067==1 | v9106==2) & condocup_ci==2
label var cesante_ci "Desocupado - definicion oficial del pais"

*****************
*region /area ***
*****************

gen region=.	
replace region=1	if uf>=11 & uf<=17
replace region=2	if uf>=21 & uf<=29
replace region=3	if uf>=31 & uf<=35
replace region=4	if uf>=41 & uf<=43
replace region=5	if uf>=50 & uf<=53
label define region 1"norte" 2"Nordeste" 3"Sudeste/leste" 4"sul" 5"Centro_Oeste"
label value region region
label var region "distribuci�n regional del pa�s"


gen area=.
replace area=1 if zona_c==1
replace area=2 if zona_c==0
replace area=3 if v4107==1
label define area 1"urbana" 2"rural" 3"metropolitana" 
label value area area
label var area "area del pais"

*********
*lp_ci***
*********
gen lp_ci =.
replace lp_ci=114.3444979	if region==4	& area==1		/*sur-urbana*/
replace lp_ci=104.0929222	if region==4	& area==2		/*sur-rural */
replace lp_ci=116.7102461	if region==2	& area==1		/*noreste-urbana*/
replace lp_ci=104.0929222	if region==2	& area==2		/*noreste-rural*/
replace lp_ci=91.47559831	if region==3	& area==1		/*sudeste-urbano*/
replace lp_ci=78.06969166	if region==3	& area==2		/*sudeste-rural*/
replace lp_ci=119.8645771	if region==1	& area==1		/*norte-urbano*/
replace lp_ci=104.881505	if region==1	& area==2		/*norte-rural */
replace lp_ci=96.99567752	if region==5	& area==1		/*centro oeste-urbano*/
replace lp_ci=85.16693636	if region==5	& area==2		/*centro oeste-rural */
replace lp_ci=130.1161528	if uf==33	& area==3		/*Rio de janeiro-metropolitano*/
replace lp_ci=110.4015842	if uf==33	& area==1		/*Rio de janeiro-urbano*/
replace lp_ci=99.36142575	if uf==33	& area==2		/*Rio de janeiro-rural*/
replace lp_ci=130.9047355	if uf==35	& area==3		/*Sao Paulo-metropolitano*/
replace lp_ci=115.9216634	if uf==35	& area==1		/*Sao paulo-urbano*/
replace lp_ci=94.62992929	if uf==35	& area==2		 /*Sao paulo-rural*/
replace lp_ci=112.7673324	if uf==53	& area==3		/*Distrito federal-metropolitana*/
replace lp_ci=145.0992249	if region==4	& area==3	& uf==43	/*Porto alegre: sur-metropolitana-rio grande de sul*/
replace lp_ci=119.8645771	if region==4	& area==3	& uf==41	/*curitiba:     sur-metropolitana-paran�*/
replace lp_ci=103.3043395	if region==2	& area==3	& uf==23	/*Fortaleza:    noreste-metropolitana-cear�*/
replace lp_ci=135.636232	if region==2	& area==3	& uf==26	/*recife:       noreste-metropolitana-pernambuco*/
replace lp_ci=127.7504045	if region==2	& area==3	& uf==29	/*salvador:     noreste-metropolitana-bahia*/
replace lp_ci=101.727174	if region==3	& area==3	& uf==31	/*belo horizonte:sureste-metropolitana-minas gerais*/
replace lp_ci=115.9216634	if region==1	& area==3	& uf==15	/*belem: noreste-metropolitana-par�*/
label var lp_ci "Linea de pobreza oficial del pais"

***********
*lpe_ci ***
***********
gen lpe_ci =.
replace lpe_ci=57.17224895	if region==4	& area==1		/*sur-urbana*/
replace lpe_ci=52.0464611	if region==4	& area==2		/*sur-rural */
replace lpe_ci=58.35512305	if region==2	& area==1		/*noreste-urbana*/
replace lpe_ci=52.0464611	if region==2	& area==2		/*noreste-rural*/
replace lpe_ci=45.737799155	if region==3	& area==1		/*sudeste-urbano*/
replace lpe_ci=39.03484583	if region==3	& area==2		/*sudeste-rural*/
replace lpe_ci=59.93228855	if region==1	& area==1		/*norte-urbano*/
replace lpe_ci=52.4407525	if region==1	& area==2		/*norte-rural */
replace lpe_ci=48.49783876	if region==5	& area==1		/*centro oeste-urbano*/
replace lpe_ci=42.58346818	if region==5	& area==2		/*centro oeste-rural */
replace lpe_ci=65.0580764	if uf==33	& area==3		/*Rio de janeiro-metropolitano*/
replace lpe_ci=55.2007921	if uf==33	& area==1		/*Rio de janeiro-urbano*/
replace lpe_ci=49.680712875	if uf==33	& area==2		/*Rio de janeiro-rural*/
replace lpe_ci=65.45236775	if uf==35	& area==3		/*Sao Paulo-metropolitano*/
replace lpe_ci=57.9608317	if uf==35	& area==1		/*Sao paulo-urbano*/
replace lpe_ci=47.314964645	if uf==35	& area==2		 /*Sao paulo-rural*/
replace lpe_ci=56.3836662	if uf==53	& area==3		/*Distrito federal-metropolitana*/
replace lpe_ci=72.54961245	if region==4	& area==3	& uf==43	/*Porto alegre: sur-metropolitana-rio grande de sul*/
replace lpe_ci=59.93228855	if region==4	& area==3	& uf==41	/*curitiba:     sur-metropolitana-paran�*/
replace lpe_ci=51.65216975	if region==2	& area==3	& uf==23	/*Fortaleza:    noreste-metropolitana-cear�*/
replace lpe_ci=67.818116	if region==2	& area==3	& uf==26	/*recife:       noreste-metropolitana-pernambuco*/
replace lpe_ci=63.87520225	if region==2	& area==3	& uf==29	/*salvador:     noreste-metropolitana-bahia*/
replace lpe_ci=50.863587	if region==3	& area==3	& uf==31	/*belo horizonte:sureste-metropolitana-minas gerais*/
replace lpe_ci=57.9608317	if region==1	& area==3	& uf==15	/*belem: noreste-metropolitana-par�*/
label var lpe_ci "Linea de indigencia oficial del pais"

drop area

*************
**salmm_ci***
*************
gen salmm_ci=180
label var salmm_ci "Salario minimo legal"

*************
***tecnica_ci**
*************
gen tecnica_ci=. /*No se puede identificar educaci�n t�cnica superior*/
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

****************
***formal_ci ***
****************
gen formal_ci=(cotizando_ci==1)

/************************************************************************************************************************/
gen ocupa_ci=.
replace ocupa_ci=1 if v4710==1 & emp_ci==1
replace ocupa_ci=3 if v4710==2 & emp_ci==1
replace ocupa_ci=4 if v4710==5 & emp_ci==1
replace ocupa_ci=5 if v4710==7 & emp_ci==1
replace ocupa_ci=6 if v4710==3 & emp_ci==1
replace ocupa_ci=7 if (v4710==4 | v4710==6) & emp_ci==1 
replace ocupa_ci=9 if v4710==8 & emp_ci==1

gen rama_ci=.
replace rama_ci=1 if v9907>0 & v9907<50
replace rama_ci=2 if v9907>=50 & v9907<=59 
replace rama_ci=3 if v9907>=100 & v9907<=300 
replace rama_ci=4 if v9907>=351 & v9907<=353 
replace rama_ci=5 if v9907==340 
replace rama_ci=6 if (v9907>=410 & v9907<=419) | (v9907>=420 & v9907<=424)|(v9907>=511 & v9907<=512)
replace rama_ci=7 if (v9907>=471 & v9907<=477) | (v9907>=481 & v9907<=482)|v9907==583
replace rama_ci=8 if (v9907>=451 & v9907<=453) | (v9907>=461 & v9907<=464)
replace rama_ci=9 if (v9907>=610 & v9907<=619) | (v9907>=621 & v9907<=624)|(v9907>=631 & v9907<=632) | (v9907>=711 & v9907<=717) | (v9907>=721 & v9907<=727) | (v9907==801)| (v9907>=521 & v9907<=582) | (v9907>=584 & v9907<=610) | v9907==354
replace rama_ci=. if emp_ci==0
label define rama_ci 1 "Agricultura, Caza, Civicultura y Pesca" 2 "Explotaci�n de minas y Canteras" 3 "Industrias Manufactureras" 4 "Electricidad, Gas y Agua" 5 "Construcci�n" 6 "Comercio al por mayor y menor, Restaurantes y Hoteles" 7 "Transporte y Almacenamiento" 8 "Establecimientos Financieros, Seguros y Bienes Inmuebles" 9 "Servicios Sociales, Comunales y personales" 
label values rama_ci rama_ci


*****************
***horaspri_ci***
*****************

gen horaspri_ci=v9058
replace horaspri_ci=. if horaspri_ci==99 |horaspri_ci==-1 | v4714!=1 /*Necesitamos que s�lo se fije en los empleados "adultos"*/
gen horasprik_ci=horaspri_ci
capture replace horasprik_ci=v0713 if edad_ci>=5 & edad_ci<=9
replace horasprik_ci=. if edad_ci>=5 & edad_ci<=9 & (horasprik_ci==99 | horasprik_ci==-1| emp_ci==0)

*2014,01 revision MLO
replace horaspri_ci=. if horaspri_ci<0 | horaspri_ci>150

*****************
***horastot_ci***
*****************
*gen horastot_ci=.
*2014, 01 incorporacio MLO
replace v9058 = . if v9058 == -1 | v9058 == 99
replace v9101 = . if v9101 == -1 | v9101 == 99
replace v9105 = . if v9105 == -1 | v9105 == 99

egen horastot_ci = rsum(v9058 v9101 v9105) 
replace horastot_ci = . if  (horaspri_ci==. & v9101==. & v9105==.) | v4714!=1 /*Necesitamos que s�lo se fije en los empleados "adultos"*/

replace horastot_ci = . if horastot_ci < 0
replace horastot_ci = . if horastot_ci > 150

gen ylmpri_ci=v9532 
replace ylmpri_ci=. if v9532==-1 | v9532>=999999 | v4714!=1 

gen ylmprik_ci=v9532
replace ylmprik_ci=. if v9532==-1 | v9532>=999999 | emp_ci==0 
capture replace ylmprik_ci=v7122 if edad_ci>=5 & edad_ci<=9
capture replace ylmprik_ci=. if  edad_ci>=5 & edad_ci<=9 & (v7122==-1 | v7122>=999999 |emp_ci==0)

gen ylnmpri_ci=v9535 if edad_ci>=10
replace ylnmpri_ci=. if v9535==-1 | v9535>=999999 | v4714!=1

gen ylnmprik_ci=v9535
replace ylnmprik_ci=. if v9535==-1 | v9535>=999999 | emp_ci==0
capture replace ylnmprik_ci=v7125 if edad_ci>=5 & edad_ci<=9
capture replace ylnmprik_ci=. if edad_ci>=5 & edad_ci<=9 & (v7125==-1 | v7125>=999999 | emp_ci==0)

/*TODAS LAS vARIABLES "SECUNDARIAS": ylmsec_ci, ylnmsec_ci, ylmotros_ci, ylnmotros_ci Y durades_ci ESTAN CREADAS S�LO PARA 
LOS MAYORES DE 10 A�OS. POR LO TANTO LAS vARIABLES AGREGADAS CON SUFIJO k EN REALIDAD S�LO SE REFIEREN A LA ACTIvIDAD 
PRINCIPAL DE LOS NI�OS*/

gen ylmsec_ci=v9982 if edad_ci>=10
replace ylmsec_ci=. if v9982==-1 | v9982>=999999 | v4714!=1

gen ylnmsec_ci=v9985 if edad_ci>=10
replace ylnmsec_ci=. if v9985==-1 | v9985>=999999 | v4714!=1

gen ylmotros_ci=v1022 if edad_ci>=10
replace ylmotros_ci=. if v1022==-1 | v1022>=999999 | v4714!=1

gen ylnmotros_ci=v1025 if edad_ci>=10
replace ylnmotros_ci=. if v1025==-1 | v1025>=999999 | v4714!=1

gen nrylmpri_ci=(ylmpri_ci==. & v4714==1)
replace nrylmpri_ci=. if v4714==2

gen nrylmprik_ci=(ylmprik_ci==. & emp_ci==1)
replace nrylmprik_ci=. if emp_ci==0

egen ylm_ci=rsum(ylmpri_ci ylmsec_ci ylmotros_ci)
replace ylm_ci=. if ylmpri_ci==. & ylmsec_ci==. & ylmotros_ci==.

egen ylmk_ci=rsum(ylmprik_ci ylmsec_ci ylmotros_ci)
replace ylmk_ci=. if ylmprik_ci==. & ylmsec_ci==. & ylmotros_ci==.

egen ylnm_ci=rsum(ylnmpri_ci ylnmsec_ci ylnmotros_ci)
replace ylnm_ci=. if ylnmpri_ci==. & ylnmsec_ci==. & ylnmotros_ci==.

egen ylnmk_ci=rsum(ylnmprik_ci ylnmsec_ci ylnmotros_ci)
replace ylnmk_ci=. if ylnmprik_ci==. & ylnmsec_ci==. & ylnmotros_ci==.


foreach var of varlist v1252 v1255 v1258 v1261 v1264 v1267 v1270 v1273{ 
replace `var'=. if `var'>=999999 | `var'==-1
}
egen ynlm_ci=rsum(v1252 v1255 v1258 v1261 v1264 v1267 v1270 v1273) if edad_ci>=10
replace ynlm_ci=. if (v1252==. &  v1255==. &  v1258==. &  v1261==. &  v1264==. &  v1267==. & v1270==. & v1273==.) | ynlm_ci<0

gen ynlnm_ci=.
sort idh_ch 
by idh_ch: egen nrylmpri_ch=max(nrylmpri_ci) if miembros_ci==1
by idh_ch: egen nrylmprik_ch=max(nrylmprik_ci) if miembros_ci==1

by idh_ch: egen ylm_ch=sum(ylm_ci)if miembros_ci==1
by idh_ch: egen ylmk_ch=sum(ylmk_ci) if miembros_ci==1
by idh_ch: egen ylnm_ch=sum(ylnm_ci)if miembros_ci==1
by idh_ch: egen ylnmk_ch=sum(ylnmk_ci) if miembros_ci==1

gen ylmnr_ch=ylm_ch
replace ylmnr_ch=. if nrylmpri_ch==1
gen ylmnrk_ch=ylmk_ch
replace ylmnrk_ch=. if nrylmprik_ch==1

by idh_ch: egen ynlm_ch=sum(ynlm_ci)if miembros_ci==1
gen ynlnm_ch=.
*2015, 03 modificacion MLO
*gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.2)
gen ylmhopri_ci=ylmpri_ci/(horaspri_ci*4.3)
gen ylmhoprik_ci=ylmprik_ci/(horasprik_ci*4.3)
replace ylmhopri_ci=. if ylmhopri_ci<=0
replace ylmhoprik_ci=. if ylmhoprik_ci<=0

gen rentaimp_ch=.
gen autocons_ch=.
gen autocons_ci=.
gen remesas_ci=.
sort idh_ch
gen remesas_ch=.

replace v1091=. if v1091==99 | v1091==-1
replace v1092=. if v1092==99 | v1092==-1

*Yanira Oviedo, Junio 2010: Se estaba multiplicando por 12, pero al ser un valor anual, deber�a dividirse 
/*
gen aux1=v1091/12
egen durades_ci=rsum(aux1 v1092) if  v4714!=1 & edad_ci>=10
replace durades_ci=. if (v1091==. & v1092==.) */
*MLO 03,2014
gen durades_ci=.

replace v9611=. if v9611==99 | v9611==-1
replace v9612=. if v9612==99 | v9612==-1
gen aux2=v9612/12
egen antiguedad_ci=rsum(v9611 aux2) if emp_ci==1
replace antiguedad_ci=. if v9611==. & v9612==. 

drop aux*

drop *k_ci

/******************************************************************************************/
/*					vARIABLES DEL MERCADO LABORAL			  			*/
/******************************************************************************************/
gen desalent_ci=.
gen subemp_ci=.
gen tiempoparc_ci=.

gen categopri_ci=1 if v9029==4 | (v9008>=8 & v9008<=10)
replace categopri_ci=2 if v9029==3 |(v9008>=5 & v9008<=7)
replace categopri_ci=3 if v9029==1 |v9029==2 | (v9008>=1 & v9008<=4)
replace categopri_ci=4 if (v9029>=5 & v9029<=8) | (v9008>=11 & v9008<=13)
replace categopri_ci=. if emp_ci!=1

gen categosec_ci=1 if v9092==4
replace categosec_ci=2 if v9092==3
replace categosec_ci=3 if v9092==1
replace categosec_ci=4 if v9092==5 |v9092==6
replace categosec_ci=. if emp_ci!=1 
gen nempleos_ci=1 if v9005==1
replace nempleos_ci=2 if v9005>1 & v9005!=.
/*
gen firmapeq=1 if v9008==1 & v9040<=4 /*v9008=Empleado permanente en el Agro*/
replace firmapeq=0 if v9008==1 & (v9040==6 | v9040==8) /*v9008=Empleado permanente en el Agro*/
replace firmapeq=1 if (v9008>=2 & v9008<=4) & ((v9013==1 & v9014<=6) | v9013==3) /*v9008= Algun tipo de empleado en el Agro*/
replace firmapeq=0 if (v9008>=2 & v9008<=4) & (v9013==1 & (v9014==8 | v9014==0)) /*v9008= Algun tipo de empleado en el Agro*/
replace firmapeq=1 if v9008==5 & ((v9049==1 & v9050<=6) | v9049==3) /*v9008=Cuenta propia en Servicios Auxiliares*/ 
replace firmapeq=0 if v9008==5 & v9049==1 & v9050==8 /*v9008=Cuenta propia en Servicios Auxiliares*/ 
replace firmapeq=1 if v9008==6 | v9008==7 /*Cuenta Propia en Agro o en otra actividad*/
replace firmapeq=0 if (v9008==8 | v9029==4) & ((v9048==0 | v9048==8) | ((v9048==2 | v9048==4) & v9049==1 & v9050>=6)) /*Empleador en los servicios auxiliares Agricolas o Empleador NO Agro*/
replace firmapeq=1 if (v9008==8 | v9029==4) & ((v9048<=6 & v9049==3) | ((v9048==2 | v9048==4) & v9049==1 & v9050<=4)) /*Empleador en los servicios auxiliares Agricolas o Empleador NO Agro*/
replace firmapeq=1 if (v9008==9 | v9008==10) & ((v9016==2 & v9017<=5 & v9018==4) | (v9016==2 & v9017<=3 & v9018==2 & v9019<=3) | (v9016==4 & v9018==2 & v9019<=5) | (v9016==4 & v9018==4)) /*Empleador en Agro u otras actividades*/
replace firmapeq=0 if (v9008==9 | v9008==10) & ((v9016==2 & (v9017==7 | v9017==8)) | (v9016==4 & v9018==2 & v9019>=5)) /*Empleador en Agro u otras actividades*/
replace firmapeq=1 if (v9008>=11 & v9008<=13) | (v9029>=5 & v9029<=7) /*Trabajador No remunerado*/
replace firmapeq=1 if v9029==1 & (v9032==2 & v9040<=4)  /*Empleado NO Agricola*/
replace firmapeq=0 if v9029==1 & (v9032==2 & (v9040==6 | v9040==8)) /*Empleado NO Agricola*/
/*Los empleados NO Agricolas que trabajan en el sector PUBLICO o que son empleados domesticos no tienen tama�o de firma!*/
replace firmapeq=1 if v9029==3 & (v9049==3 | (v9049==1 | v9050<=6))/*Cuenta Propia NO Agricola*/
replace firmapeq=0 if v9029==3 & (v9049==1 | (v9050==8 | v9050==0))/*Cuenta Propia NO Agricola*/
/*Que pasa con los trabajadores no remunerados? Se incluyen en tama�o de firma?*/

ren firmapeq firmapeq_ci
*cambio introducido el 06/13/05*
*/

gen spublico_ci=(v9032==4)
replace spublico_ci=. if v9032==9





					****************************
					***	vARIABLES EDUCATIvAS ***
					****************************

*------------------------------------------------------------------------------------------------------------------
*YANIRA, Ag 2010: SE HACE UNA CORRECI�N SOBRE LAS vARIABLES DE EDUCACI�N. PUES LA vARIABLE DE INSUMO PARA CONSTRUIR 
*A�OS DE EDUCACI�N NO SE TUvO EN CUENTA UN CAMBIO EN LAS OPCIONES DE LAS vARIABLES INSUMO. LO CUAL GENER� UN ERROR
*------------------------------------------------------------------------------------------------------------------



**************
**asiste_ci***
**************

gen asiste_ci=(v0602==2)
label var asiste_ci "Personas que actualmente asisten a un centro de ense�anza"


*************
***aedu_ci***
*************
*Modificado Mayra S�enz 12/10/2014
*gen aedu_ci=.
* Si se genera con . se generan alrededor de 10% de hogares con jefe de hogar con missing en educaci�n.
gen aedu_ci=0
label var aedu_ci "Anios de educacion"


*PARA LOS QUE NO ASISTEN
*************************

*Pre-escolar, creche o alfabetizaci�n de adultos
replace aedu_ci=0 if (v0607==8| v0607==9 | v0607==10) & asiste_ci==0

	*Sistema antiguo
*Elementar (prim�rio) - se asume que el m�ximo es 4 - Anteriormente se permit�a 6 pero no 5
replace aedu_ci=0  if v0607==1 & v0610==. & v0611!=1 & asiste_ci==0
replace aedu_ci=min(v0610,4) if v0607==1 & v0610>=1 & v0610<=6 & asiste_ci==0
*Medio 1 ciclo (ginasial, etc) - se asume que el m�ximo es 8
replace aedu_ci=min(v0610+4,8) if v0607==2 & v0610>=1 & v0610<=5 & asiste_ci==0
replace aedu_ci=4  if v0607==2 & v0610==. & v0611!=1 & asiste_ci==0
*Medio 2 ciclo (cientifico, clasico, etc, etc) - se asume que el m�ximo es 11, pero
*bajo la l�gica anterior deber�an se 12, ya que se permite hasta 4 a�os adicionales en este nivel
*Aunque solo es necesario tener 11 a�os de educaci�n para completar la secundaria
replace aedu_ci=min(v0610+8,12) if v0607==3 & v0610>=1 & v0610<=4 & asiste_ci==0
replace aedu_ci=8  if v0607==3 & v0610==. & v0611!=1 & asiste_ci==0

	*Sistema nuevo
*Primeiro grau - Bajo este sistema la primaria llega hasta el grado 8
replace aedu_ci=min(v0610,8) if v0607==4 & v0610>=1 & v0610<=8 & asiste_ci==0
replace aedu_ci=0  if v0607==4 & v0610==. & v0611!=1 & asiste_ci==0
*Segundo grau - Secundaria son 4 a�os m�s
replace aedu_ci=min(v0610+8,12) if v0607==5 & v0610>=1 & v0610<=4 & asiste_ci==0
replace aedu_ci=8 if v0607==5 & v0610==. & v0611!=1 & asiste_ci==0

*Superior
replace aedu_ci=min(v0610+11,17) if v0607==6 & v0610>=1 & v0610<=8 & asiste_ci==0
replace aedu_ci=11 if v0607==6 & v0610==. & v0611!=1 & asiste_ci==0

*Maestria o doctorado  
*Para este ciclo no se pregunta el �ltimo a�o aprobado. Por lo tanto se supone que si termin� el ciclo 
*el individuo cuenta con 19 a�os de educaci�n (2 a�os m�s de educaci�n), si el individuo no termin� se le agrega 
*1 a�o m�s de eduaci�n para quedar con 18 ya que si el �ltimo ciclo m�s alto alcanzado es postgrado, el individuo 
*por lo menos tuvo que cursar 1 a�o en ese nivel
replace aedu_ci=18 if v0607==7 & v0611==3 & asiste_ci==0
replace aedu_ci=19 if v0607==7 & v0611==1 & asiste_ci==0


*PARA LOS QUE ASISTEN
**********************

*Pre-escolar, creche o alfabetizaci�n de adultos
replace aedu_ci=0 if (v0603==6| v0603==7 | v0603==8) & asiste_ci==1

*Regular de 1� grau/ Supletivo de 1� grau   (se asume que el m�ximo es 8) 
replace aedu_ci=0  if (v0603==1 | v0603==3) & v0605==. & asiste_ci==1
replace aedu_ci=min(v0605-1,7) if (v0603==1 | v0603==3) & v0605>=1 & v0605<=8 & asiste_ci==1
*Regular de 2� grau/ Supletivo de 2� grau   (se asume que el m�ximo es 4, pero con 3 basta para completar el ciclo)
replace aedu_ci=min(v0605+8-1,11) if (v0603==2 | v0603==4) & v0605>=1 & v0605<=4 & asiste_ci==1
replace aedu_ci=8  if (v0603==2 | v0603==4) & v0605==. & asiste_ci==1

*Pre-vestibular
replace aedu_ci=11  if v0603==9 & asiste_ci==1

*Superior
replace aedu_ci=min(v0605+11-1,17) if v0603==5 & v0605>=1 & v0605<=8 & asiste_ci==1
replace aedu_ci=11 if v0603==5 & v0605==. & asiste_ci==1

*Maestria o doctorado  
*Si el �ltimo ciclo m�s alto alcanzado es postgrado, el individuo por lo menos tuvo que cursar 1 a�o en ese nivel
replace aedu_ci=18 if v0603==10  & asiste_ci==1

*Se deja s�lo la informaci�n de las personas con 5 a�os o m�s
replace aedu_ci=. if edad_ci<5



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
replace edupi_ci=1 if aedu_ci>0 & aedu_ci<8
replace edupi_ci=. if aedu_ci==.
label variable edupi_ci "Primaria incompleta"

**************
***edupc_ci***
**************
gen byte edupc_ci=0
replace edupc_ci=1 if aedu_ci==8
replace edupc_ci=. if aedu_ci==.
label variable edupc_ci "Primaria completa"

**************
***edusi_ci***
**************
gen byte edusi_ci=0
replace edusi_ci=1 if aedu_ci>8 & aedu_ci<11
replace edusi_ci=. if aedu_ci==.
label variable edusi_ci "Secundaria incompleta"

**************
***edusc_ci***
**************
gen byte edusc_ci=0
replace edusc_ci=1 if aedu_ci==11
replace edusc_ci=. if aedu_ci==.
label variable edusc_ci "Secundaria completa"

**************
***eduui_ci***
**************
gen byte eduui_ci=0
replace eduui_ci=1 if aedu_ci>11 & aedu_ci<17
replace eduui_ci=. if aedu_ci==.
label variable eduui_ci "Universitaria incompleta"

**************
***eduuc_ci***
**************
gen byte eduuc_ci=0
replace eduuc_ci=1 if aedu_ci>=17
replace eduuc_ci=. if aedu_ci==.
label variable eduuc_ci "Universitaria completa o mas"

***************
***edus1i_ci***
***************
*La secundaria s�lo dura 4 a�os. No puede divirse en ciclos
gen edus1i_ci=.
label variable edus1i_ci "1er ciclo de la secundaria incompleto" 

***************
***edus2i_ci***
***************
gen byte edus2i_ci=.
label variable edus2i_ci "2do ciclo de la secundaria incompleto" 

***************
***edus2c_ci***
***************
gen edus2c_ci=.
label variable edus2c_ci "2do ciclo de la secundaria completo" 

***************
***edupre_ci***
***************
gen byte edupre_ci=.
label variable edupre_ci "Educacion preescolar"

**************
***eduac_ci***
**************
gen byte eduac_ci=.
label variable eduac_ci "Superior universitario vs superior no universitario"


foreach var of varlist edu* {
replace `var'=. if aedu_ci==.
}

******************
***pqnoasist_ci***
******************
gen pqnoasis_ci=.
label var pqnoasis_ci "Razones para no asistir a la escuela"

**Daniela Zuluaga- Enero 2018: Se agrega la variable pqnoasis1_ci cuya sintaxis fue elaborada por Mayra Saenz**
	
**************
*pqnoasis1_ci*
**************
gen pqnoasis1_ci = .

***************
***repite_ci***
***************
gen repite_ci=.
label var repite_ci "Personas que han repetido al menos un a�o o grado"

***************
***edupub_ci***
***************
gen edupub_ci=(v6002==2)
label var  edupub_ci "Personas que asisten a centros de ense�anza p�blicos"



*******************
*** Brazil 2001 ***
*******************

* variables

 gen v4704=v4754 if v8005>=10 
 gen v4706=v4756 if v8005>=10 
clonevar	nrocont=v0102
clonevar	nroserie=v0103
clonevar	persa=v4724
clonevar	persb=v4725
clonevar	sexo=v0302
clonevar	piel=v0404
clonevar	edad=v8005
clonevar	factor=v4729
clonevar	alfabet=v0601
clonevar	asiste=v0602
clonevar	cursoasi=v0603
clonevar	serieasi=v0605
clonevar	ultcurso=v0607
clonevar	ultserie=v0610
clonevar	terult=v0611
clonevar	situacen=v4105
clonevar	tiposector=v4106
clonevar	areacen=v4107
clonevar	estrato=v4602
clonevar	nromuni=v4604
clonevar	cond10ym=v4704
clonevar	condocup=v4714
clonevar	cat10ym=v4706
clonevar	ramar5ym01=v4709
clonevar	yth=v4726
clonevar	espdom=v0201
clonevar	matpared=v0203
clonevar	matecho=v0204
clonevar	nrocuart=v0205
clonevar	nrodorm=v0206
clonevar	tenenviv=v0207
clonevar	tenenter=v0210
clonevar	aguacan=v0211
clonevar	abasagua=v0212
clonevar	aguared=v0213
clonevar	aguapozo=v0214
clonevar	sanita=v0215
clonevar	usosani=v0216
clonevar	sissan=v0217
clonevar	celular=v0220
clonevar	combcoci=v0223
clonevar	computad=v0231
clonevar	internet=v0232
clonevar	telefono=v2020
clonevar	sectorem=v9032
clonevar	tamest1=v9040
clonevar	tamest2=v9048
clonevar	catsec=v9092
clonevar	sectosec=v9093
clonevar	qqhh=v9121
clonevar	jubila=v9122
clonevar	pensio=v9123
clonevar	ocusec=v9990
clonevar	ocup=v9906
clonevar	ramsec=v9991
clonevar	totpers=v0105
recode sexo (2=1) (4=2)

** AREA

 generate area=.
 replace area=2 if situacen>=4 & situacen<=8
 replace area=1 if situacen>=1 & situacen<=3

 tab area [w=factor]

** Gender classification of the population refering to the head of the household.

 sort nrocont nroserie v0301

* Household ID

 gen x=1 if v0402==1 	/* Condi��o na fam�lia */
 gen id_hogar=sum(x)
 drop x

* Dwelling ID

 gen x=1 if v0401==1	/* Condi��o na unidade domiciliar */
 gen id_viv=sum(x)
 drop x

 gen	 sexo_d_=1 if v0402==1 & sexo==1
 replace sexo_d_=2 if v0402==1 & sexo==2

 egen sexo_d=max(sexo_d_), by(id_hogar)
 tab sexo [w=factor]
 tab sexo_d [w=factor]

 tab sexo sexo_d if v0402==1

** Years of education. 

 gen anoest=.
 replace anoest=0 if v4703==1
  *replace anoest=0 if (ultcurso==1 & terult==3) | (ultcurso==4 & terult==3) | ultcurso==9 | ultcurso==10 | (cursoasi==1 & serieasi==1) | (cursoasi==3 & serieasi==1) | cursoasi==6 | cursoasi==7 | cursoasi==8 | (asiste==4 & ultcurso==.)| (ultcurso==8 & terult==3)
 replace anoest=1 if (ultcurso==1 & ultserie==1) | (ultcurso==4 & ultserie==1) | (cursoasi==1 & serieasi==2) | (cursoasi==3 & serieasi==2)
 replace anoest=2 if (ultcurso==1 & ultserie==2) | (ultcurso==4 & ultserie==2) | (cursoasi==1 & serieasi==3) | (cursoasi==3 & serieasi==3)
 replace anoest=3 if (ultcurso==1 & ultserie==3) | (ultcurso==4 & ultserie==3) | (cursoasi==1 & serieasi==4) | (cursoasi==3 & serieasi==4)
 replace anoest=4 if v4703==5
  *replace anoest=4 if (ultcurso==1 & ultserie==4) | (ultcurso==4 & ultserie==4) | (ultcurso==2 & ultserie==0 & terult~=1) | (cursoasi==1 & serieasi==5) | (cursoasi==3 & serieasi==5)
 replace anoest=5 if (ultcurso==1 & ultserie==5) | (ultcurso==4 & ultserie==5) | (ultcurso==2 & ultserie==1) | (cursoasi==1 & serieasi==6) | (cursoasi==3 & serieasi==6)
 replace anoest=6 if (ultcurso==1 & ultserie==6) | (ultcurso==4 & ultserie==6) | (ultcurso==2 & ultserie==2) | (cursoasi==1 & serieasi==7) | (cursoasi==3 & serieasi==7)
 replace anoest=7 if (ultcurso==2 & ultserie==3) | (ultcurso==4 & ultserie==7) | (cursoasi==1 & serieasi==8) | (cursoasi==3 & serieasi==8)
 replace anoest=8 if v4703==9
  *replace anoest=8 if (ultcurso==2 & ultserie==4) | (ultcurso==4 & ultserie==8) | (ultcurso==3 & ultserie==0 & terult~=1) | (ultcurso==5 & ultserie==0 & terult~=1) | ((cursoasi==2 | cursoasi==4) & serieasi==1) | (cursoasi==4 & (serieasi==0 | serieasi==1))
 replace anoest=9 if (ultcurso==2 & ultserie==5) | (ultcurso==3 & ultserie==1) | (ultcurso==5 & ultserie==1) | ((cursoasi==2 | cursoasi==4) & serieasi==2) | (cursoasi==4 & serieasi==2)
 replace anoest=10 if (ultcurso==3 & ultserie==2) | (ultcurso==5 & ultserie==2) | ((cursoasi==2 | cursoasi==4) & serieasi==3) | (cursoasi==4 & serieasi==3)
 replace anoest=11 if v4703==12
 replace anoest=12 if v4703==13
  *replace anoest=11 if (ultcurso==3 & ultserie==3) | (ultcurso==6 & ultserie==0 & terult~=1) | (ultcurso==5 & ultserie==3) | ((cursoasi==2 | cursoasi==4) & serieasi==4) | (cursoasi==5 & (serieasi==0 | serieasi==1)) | cursoasi==9
  *replace anoest=12 if (ultcurso==3 & ultserie==4) | (ultcurso==6 & ultserie==1) | (cursoasi==5 & serieasi==2) 
 replace anoest=13 if (ultcurso==6 & ultserie==2) | (cursoasi==5 & serieasi==3)
 replace anoest=14 if (ultcurso==6 & ultserie==3) | (cursoasi==5 & serieasi==4)
 replace anoest=15 if (ultcurso==6 & ultserie==4) | (cursoasi==5 & serieasi==5)
 replace anoest=16 if (ultcurso==6 & ultserie==5) | (ultcurso==7 & terult==3) | (cursoasi==5 & serieasi==6) | cursoasi==10
 replace anoest=17 if (ultcurso==6 & ultserie==6) | (ultcurso==7 & terult==1)
 replace anoest=99 if v4703==17
  *replace anoest=99 if ultcurso==0 | ((cursoasi==2 | cursoasi==4) & (serieasi==9 | serieasi==0)) | (cursoasi==3 & (serieasi==9 | serieasi==0)) | (cursoasi==1 & (serieasi==9 | serieasi==0))

 tab anoest
 tab v4703
 tab v4703 anoest,missing

 tab anoest [w=factor]
 tab v4703 [w=factor]


 gen     condact=1 if condocup==1 & cond10ym==1
 replace condact=2 if condocup==2 & cond10ym==1
 replace condact=3 if cond10ym==2
 replace condact=4 if cond10ym==3

 gen     peaa=0
 replace peaa=1 if condact==1
 replace peaa=2 if condact==2
 replace peaa=3 if condact==3

 gen	 tasadeso=0 if peaa==1
 replace tasadeso=1 if peaa==2
 

 gen     categ=1 if cat10ym>=1 & cat10ym<=5
 replace categ=2 if cat10ym>=6 & cat10ym<=8
 replace categ=3 if cat10ym==9
 replace categ=4 if cat10ym==10
 replace categ=5 if cat10ym==11 | cat10ym==12
 replace categ=6 if cat10ym==13



 gen	 ident=1 if areacen==1
 replace ident=2 if areacen==2 | areacen==3
 
 gen double estrat2=uf*100+ident


svyset [pweight=factor], strata(estrat2) psu(nrocont)
svydes


************************
*** MDGs CALCULATION ***
************************

*** GOAL 2. ACHIEvE UNIvERSAL PRIMARY EDUCATION
* ISCED 1

 gen     NERP=0 if (edad>=7 & edad<=10) & (asiste==2 | asiste==4)
 replace NERP=1 if (edad>=7 & edad<=10) & (asiste==2) & ((cursoasi==1|cursoasi==3) & (serieasi>=1 & serieasi<=4))
 label var NERP "Net Enrolment Ratio in Primary"


** Target 3, Additional Indicator: Net Attendance Ratio in Secondary
* ISCED 2 & 3

 gen     NERS=0 if (edad>=11 & edad<=17) & (asiste==2 | asiste==4)
 replace NERS=1 if (edad>=11 & edad<=17) & (asiste==2) & ( ((cursoasi==1|cursoasi==3) & (serieasi>=5 & serieasi<=8)) | ((cursoasi==2 | cursoasi==4) & (serieasi>=1 & serieasi<=3)) )
 label var NERS "Net Enrolment Ratio in Secondary"

* Upper secondary
* Ensino medio ou 2� grau

 gen     NERS2=0 if (edad>=15 & edad<=17) & (asiste==2 | asiste==4) 
 replace NERS2=1 if (edad>=15 & edad<=17) & (asiste==2) & ((cursoasi==2 | cursoasi==4) & (serieasi>=1 & serieasi<=3))
 label var NERS2 "Net Enrolment Ratio in Secondary - upper"

** Target 3, Indicator: Literacy Rate of 15-24 Years Old
* At least 5 years of formal education

 gen     LIT=0 if (edad>=15 & edad<=24) & (anoest>=0 & anoest<99)
 replace LIT=1 if (edad>=15 & edad<=24) & (anoest>=5 & anoest<99)
 label var LIT "Literacy Rate of 15-24 Years Old"


** Target 3, Indicator: Literacy Rate of 15-24 Years Old
* Read & write

 gen     LIT2=0 if  (edad>=15 & edad<=24) & (alfabet==1 | alfabet==3)
 replace LIT2=1 if  (edad>=15 & edad<=24) & (alfabet==1) 
 label var LIT2 "Literacy Rate of 15-24 Years Old"
 
 

*** GOAL 3 PROMOTE GENDER EQUALITY AND EMPOWER WOMEN

 gen prim=1 if asiste==2 & (cursoasi==1 | cursoasi==3) & (serieasi>=1 & serieasi<=4)
 gen sec=1 if  asiste==2 & (((cursoasi==1|cursoasi==3) & (serieasi>=5 & serieasi<=8)) | ((cursoasi==2 | cursoasi==4) & (serieasi>=1 & serieasi<=3)))
 gen ter=1 if  asiste==2 & ((cursoasi==5 & serieasi<=5) | ((cursoasi==2 | cursoasi==4) & (serieasi==4)))

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

 gen RATIOALL=0 if     (prim==1 | sec==1 | ter==1) & sexo==2  
 replace RATIOALL=1 if (prim==1 | sec==1 | ter==1) & sexo==1    

** Target 4, Indicator: Ratio of literate women to men 15-24 year olds*
* Knows how to read & write

 gen MA2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace MA2=0 if MA2==.
 gen HA2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==1)) 
 replace HA2=0 if HA2==.
	
 gen RATIOLIT2=0     if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace RATIOLIT2=1 if ((alfabet==1) & (edad>=15 & edad<=24) & (sexo==1)) 


** Target 4, Indicator: Ratio of literate women to men 15-24 year olds*
* At least 5 years of formal education

 gen MA=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace MA=0 if MA==.
 gen HA=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==1)) 
 replace HA=0 if HA==.
	
 gen RATIOLIT=0 if     ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==2)) 
 replace RATIOLIT=1 if ((anoest>=5 & anoest<99) & (edad>=15 & edad<=24) & (sexo==1)) 


** Target 4, Indicator: Share of women in wage employment in the non-agricultural sector (%)
* Without Domestic Service

 gen ramar=ramar5ym01 if edad>=10

 gen     WENAS=0 if (edad>=15 & edad<=64) & (categ==1) & (ramar>=2 & ramar<=11)
 replace WENAS=1 if (edad>=15 & edad<=64) & (categ==1) & (ramar>=2 & ramar<=11) & sexo==2

 * RURAL AREAS ARE NOT PRESENTED FOR THIS INDICATOR


** Target 4, Indicator: Share of women in wage employment in the non-agricultural sector (%)
*Gender-With domestic servants*

 gen     WENASD=0 if (edad>=15 & edad<=64) & (categ==1 | categ==2) & (ramar>=2 & ramar<=11)
 replace WENASD=1 if (edad>=15 & edad<=64) & (categ==1 | categ==2) & (ramar>=2 & ramar<=11) & sexo==2

 * RURAL AREAS ARE NOT PRESENTED FOR THIS INDICATOR

*** GOAL 7 ENSURE ENvIROMENTAL SUSTAINABILITY


* Gender classification of the population refers to the head of the household.

 gen     ELEC=0 if espdom==1 & (v0219>=1 & v0219<=5)   /* Total population excluding missing information */
 replace ELEC=1 if espdom==1 & (v0219==1)
	

** Target 9, Indicator: Proportion of the population using solidfuels (%)

* Gender classification of the population refers to the head of the household.

 gen     SFUELS=0 if espdom==1 & (combcoci>=1 & combcoci<=6)   /* Total population excluding missing information */
 replace SFUELS=1 if espdom==1 & (combcoci==3 | combcoci==4)


** Target 10, Indicator: Proportion of the population with sustainable access to an improved water source (%)

* Gender classification of the population refers to the head of the household.

 gen     WATER=0 if espdom==1 & (aguacan==1 | aguacan==3 | aguacan==9)   /* Total population excluding missing information */
 replace WATER=1 if espdom==1 & ((aguacan==1 & (abasagua==2 | abasagua==4)) | (aguacan==3 & (aguared==1 |aguapozo==2)))

	
** Target 10, Indicator: Proportion of Population with Access to Improved Sanitation, Urban and Rural*


* Gender classification of the population refers to the head of the household.

 gen     SANITATION=0 if espdom==1 & (sanita==1 | sanita==3 | sanita==9)   /* Total population excluding missing information */
 replace SANITATION=1 if espdom==1 & (sanita==1 & (sissan>=1 & sissan<=3))

	
** Target 11, Indicator: Proportion of the population with access to secure tenure (%)


* PERSONS PER ROOM

 gen a=(totpers/nrocuart) if ((totpers>0 & totpers<99) | (nrocuart>0 & nrocuart<99)) & v0401==1

 egen persroom=max(a), by(id_viv) /* Per dwelling */

* Indicator components

* 1. Non secure tenure or type of dwelling.

 gen     secten_1=0 if (tenenviv>=1 & tenenviv<=6)   /* Total population excluding missing information */
 replace secten_1=1 if (tenenviv>=4 & tenenviv<=6)

* 2. Low quality of the floor or walls materials.

 gen     secten_2=0 if (matpared>=1 & matpared<=6)   /* Total population excluding missing information */
 replace secten_2=1 if (matpared>=3 & matpared<=6)

* 3. Crowding (defined as not more than two people sharing the same room)

 gen secten_3=1     if (persroom>2) 
 
* 4. Lack of basic services

 gen     secten_4=1 if (SANITATION==0 | WATER==0)

* Gender classification of the population refers to the head of the household.

 gen     SECTEN=1 if  espdom==1 & (secten_1>=0 & secten_1<=1) & (secten_2>=0 & secten_2<=1)   /* Total population excluding missing information */
 replace SECTEN=0 if  espdom==1 & (secten_1==1 | secten_2==1 | secten_3==1 | secten_4==1)


* Dirt floors ** Addtional indicator

* NA

** GOAL 8. DEvELOP A GLOBAL PARTNERSHIP FOR DEvELOPMENT

** Target 16, Indicator: Unemployment Rate of 15 year-olds (%)

 gen     UNMPLYMENT15=0 if (edad>=15 & edad<=24) & (tasadeso==0 | tasadeso==1) 
 replace UNMPLYMENT15=1 if (edad>=15 & edad<=24) & (tasadeso==1) 
 	


 gen     TELCEL=0 if espdom==1 & (telefono==2 | telefono==4) & (celular==2 | celular==4)   /* Total population excluding missing information */
 replace TELCEL=1 if espdom==1 & (telefono==2 | celular==2)

	

** FIXED LINES

* Gender classification of the population refers to the head of the household.

 gen     TEL=0 if espdom==1 & (telefono==2 | telefono==4)   /* Total population excluding missing information */
 replace TEL=1 if espdom==1 & (telefono==2)

** CEL LINES

* Gender classification of the population refers to the head of the household.

 gen     CEL=0 if espdom==1 & (celular==2 | celular==4)   /* Total population excluding missing information */
 replace CEL=1 if espdom==1 & (celular==2)


* Gender classification of the population refers to the head of the household.

 gen     COMPUTER=0 if espdom==1 & (computad==1 | computad==3)   /* Total population excluding missing information */
 replace COMPUTER=1 if espdom==1 & (computad==1)

* Target 18, Indicator: "Internet users per 100 population"

* Gender classification of the population refers to the head of the household.

 gen     INTUSERS=0 if espdom==1 & (computad==1 | computad==3)   /* Total population excluding missing information */
 replace INTUSERS=1 if espdom==1 & (internet==2)

*************************************************************************
**** ADDITIONAL SOCIO - ECONOMIC COMMON COUNTRY ASESSMENT INDICATORS ****
*************************************************************************

** CCA 19. Proportion of children under 15 who are working

 gen     CHILDREN=0 if (edad>=12 & edad<=14) 
 replace CHILDREN=1 if (edad>=12 & edad<=14) & peaa==1

** CCA 41 Number of Persons per Room*

 generate PERSROOM2=persroom if espdom==1 & v0401==1  /* Per dwelling */

 gen     popinlessthan2=1 if persroom<=2
 replace popinlessthan2=0 if popinlessthan2==.

* Gender classification of the population refers to the head of the household.

 gen     PLT2=0 if espdom==1 & persroom<.   /* Total population excluding missing information */
 replace PLT2=1 if espdom==1 & (popinlessthan2==1)

** Disconnected Youths

 gen     DISCONN=0 if (edad>=15 & edad<=24)
 replace DISCONN=1 if (edad>=15 & edad<=24) & peaa==3 & qqhh==3 & asiste==4

*** Proportion of population below corresponding grade for age

 gen     rezago=0       if (anoest>=0 & anoest<99)  & edad==7 /* This year of age is not included in the calculations */
	 
 replace rezago=1 	if (anoest>=0 & anoest<1 )  & edad==8
 replace rezago=0 	if (anoest>=1 & anoest<99)  & edad==8

 replace rezago=1 	if (anoest>=0 & anoest<2 )  & edad==9
 replace rezago=0	if (anoest>=2 & anoest<99)  & edad==9

 replace rezago=1 	if (anoest>=0 & anoest<3 )  & edad==10
 replace rezago=0	if (anoest>=3 & anoest<99)  & edad==10

 replace rezago=1 	if (anoest>=0 & anoest<4 )  & edad==11
 replace rezago=0	if (anoest>=4 & anoest<99)  & edad==11

 replace rezago=1 	if (anoest>=0 & anoest<5 )  & edad==12
 replace rezago=0	if (anoest>=5 & anoest<99)  & edad==12

 replace rezago=1	if (anoest>=0 & anoest<6)   & edad==13
 replace rezago=0	if (anoest>=6 & anoest<99)  & edad==13

 replace rezago=1 	if (anoest>=0 & anoest<7)   & edad==14
 replace rezago=0	if (anoest>=7 & anoest<99)  & edad==14

 replace rezago=1 	if (anoest>=0 & anoest<8)   & edad==15
 replace rezago=0	if (anoest>=8 & anoest<99)  & edad==15

 replace rezago=1 	if (anoest>=0 & anoest<9 )  & edad==16
 replace rezago=0	if (anoest>=9 & anoest<99)  & edad==16

 replace rezago=1 	if (anoest>=0  & anoest<10) & edad==17
 replace rezago=0	if (anoest>=10 & anoest<99) & edad==17

* Primary and Secondary [ISCED 1, 2 & 3]

 gen     REZ=0 if  (edad>=8 & edad<=17) & (rezago==1 | rezago==0)
 replace REZ=1 if  (edad>=8 & edad<=17) & (rezago==1)

	
* Primary completion rate [15 - 24 years of age]

 gen     PRIMCOMP=0 if  (edad>=15 & edad<=24) & (anoest>=0  & anoest<99)
 replace PRIMCOMP=1 if  (edad>=15 & edad<=24) & (anoest>=4  & anoest<99)


* Average years of education of the population 15+

 gen     AEDUC_15=anoest if ((edad>=15 & edad<.) & (anoest>=0 & anoest<99))

	
 gen     AEDUC_15_24=anoest if ((edad>=15 & edad<=24) & (anoest>=0 & anoest<99))



 gen     AEDUC_25=anoest if ((edad>=25 & edad<.) & (anoest>=0 & anoest<99))


* Grade for age

 gen GFA=(anoest/(edad-7)) if (edad>=8 & edad<=17) & (anoest>=0 & anoest<99)

	
* Grade for age primary [ISCED 1]

 gen GFAP=(anoest/(edad-7)) if (edad>=8 & edad<=10) & (anoest>=0 & anoest<99)


* Grade for age Secondary [ISCED 2 & 3]

 gen GFAS=(anoest/(edad-7)) if (edad>=11 & edad<=17) & (anoest>=0 & anoest<99)



*******************
***tamemp_ci*******
*******************
gen tamemp_ci=1 if v9019==1 | v9019==3 | v9019==5 |v9017==1 | v9017==3 | v9017==5 | v9040==2 | v9040==4 | v9048==2 | v9048==4 | v9048==6 
replace tamemp_ci=2 if v9019==7 | v9017==7 | v9040==6 | v9048==8
replace tamemp_ci=3 if v9019==8 | v9017==8 | v9040==8 | v9048==0

* rev MLO, 2015, 03
* se incorporan cuenta propia y trabajadores agricolas
recode tamemp_ci . =1 if v9049==3
replace tamemp_ci=1 if v9014==2 |  v9014==4 |  v9014==6
replace tamemp_ci=1 if v9049==3 | v9050==6 | v9050==4 | v9050==2 | v9052==2 | v9052==4 | v9052==6
replace tamemp_ci=2 if v9014==8 | v9052==8
replace tamemp_ci=3 if v9014==0 | v9050==8 | v9052==0 


label var  tamemp_ci "Tama�o de Empresa" 
label define tama�o 1"Peque�a" 2"Mediana" 3"Grande"
label values tamemp_ci tama�o

******************
***categoinac_ci**
******************
gen categoinac_ci=1 if (v9122==2 | v9123==1) & condocup_ci==3
replace categoinac_ci=2 if v0602==2 & condocup_ci==3
replace categoinac_ci=3 if v9121==1 & condocup_ci==3
recode categoinac_ci .=4 if condocup_ci==3
label var  categoinac_ci "Condici�n de Inactividad" 
label define inactivo 1"Pensionado" 2"Estudiante" 3"Hogar" 4"Otros"
label values categoinac_ci inactivo


*variables que faltan generar
gen tcylmpri_ci=.
gen tcylmpri_ch=.
gen edus1c_ci=.
gen repiteult_ci=.
gen vivi1_ch =.
gen vivi2_ch =.
gen tipopen_ci=.
gen ylmho_ci=. 
gen vivitit_ch=.

ren ocup ocup_old

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



