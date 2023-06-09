*Yessenia Loayza
*Febrero, 2013

clear all
set more off
cd "${surveysFolder}\survey\PER\ENAHO\2004\a\data_orig"

**************************************************************************************
						/*Identificador de hogar*/
**************************************************************************************


 #delimit ;
*modulo de vivienda;
use "enaho01-2004-612.dta", clear;
cap drop id*;
cap egen idh_ch=concat(conglome vivienda hogar);
keep idh_ch p612 p612n;
reshape wide p612, i(idh_ch) j(p612n); 
sort idh_ch;
save "enaho01-2004-612_reshape.dta", replace;


global BASES "enaho01-2004-100.dta
enaho01-2004-200.dta
enaho01a-2004-300.dta
enaho01a-2004-400.dta
enaho01a-2004-500.dta
enaho01-2004-612.dta
enaho01b-2004-3.dta
sumaria-2004.dta
enaho01-2004-612.dta";

#delimit ;
foreach base in $BASES{;
	use `base';
	cap drop if p203==0;
	cap drop idh_ch;
	sort conglome vivienda hogar;
	cap egen idh_ch=concat(conglome vivienda hogar);
	sort idh_ch;
	save `base', replace;
	};
	
	



	
**************************************************************************************
						/*Identificador de persona*/
**************************************************************************************

 #delimit ;
 
 global BASES2 "enaho01-2004-200.dta
 enaho01a-2004-300.dta
enaho01a-2004-400.dta
enaho01a-2004-500.dta
enaho01b-2004-3.dta";

 #delimit ;
foreach base in $BASES2{;
	use `base', clear ;
	cap drop idp_ci;
	sort conglome vivienda hogar codperso;
	cap egen idp_ci=concat(conglome vivienda hogar codperso);
	sort idp_ci;
	save `base', replace;
	};

**************************************************************************************
						/*MERGE*/
**************************************************************************************


clear
use "enaho01-2004-100.dta", clear
keep if result==1 | result==2
sort idh_ch

merge 1:m idh_ch using "enaho01-2004-200.dta"
drop _merge
sort idp_ci


merge 1:1 idp_ci using "enaho01a-2004-300.dta"
drop _merge
sort idp_ci

merge 1:1 idp_ci using "enaho01a-2004-400.dta"
drop _merge
sort idp_ci

merge 1:1 idp_ci using "enaho01a-2004-500.dta"
drop _merge
sort idp_ci

merge 1:1 idp_ci using "enaho01b-2004-3.dta"
drop _merge p32-p45_2
sort idh_ch



*Modificación Mayra Sáenz - Agosto 2015
*merge m:m idh_ch using "sumaria-2004.dta"
joinby idh_ch using "sumaria-2004.dta", unm(b)

drop _merge
sort idh_ch

*Modificación Mayra Sáenz - Agosto 2015
*merge m:m idh_ch using "enaho01-2004-612_reshape.dta"
joinby idh_ch using "enaho01-2004-612_reshape.dta", unm(b)
drop _merge
sort idh_ch

drop idh* idp*
save "${surveysFolder}\survey\PER\ENAHO\2004\a\data_merge\PER_2004a.dta", replace

 
