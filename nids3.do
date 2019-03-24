
* NIDS

cd "/Users/willviolette/Google Drive/nids"

clear all
set mem 1000m
set maxvar 4000
use indderived_W1_Anon_V5.2.dta, clear
keep w1_hhid pid w1_fwag w1_cwag w1_swag w1_remt w1_brid_flg w1_empl_stat
sort pid
save w1_id1.dta, replace

use indderived_W2_Anon_V2.2.dta, clear
keep w2_hhid pid w2_fwag w2_cwag w2_swag w2_remt w2_brid_flg w2_empl_stat
sort pid
save w2_id1.dta, replace

use indderived_W3_Anon_V1.2.dta, clear
keep w3_hhid pid w3_fwag w3_cwag w3_swag w3_remt w3_brid_flg w3_empl_stat
sort pid
save w3_id1.dta, replace


use Link_File_W3_Anon_V1.2.dta, clear

sort w1_hhid
merge w1_hhid using w1_hh.dta
keep if _merge==3
drop _merge
sort w2_hhid
merge w2_hhid using w2_hh.dta
keep if _merge==3
drop _merge
sort w3_hhid
merge w3_hhid using w3_hh.dta
keep if _merge==3
drop _merge

forvalues r=1/3 {
g h`r'=.
replace h`r'=1 if w`r'_h_grnthse==1
replace h`r'=0 if w`r'_h_grnthse==2
}



***** NOW MERGE INDIVIDUALS
sort pid
merge pid using w1_id1.dta
keep if _merge==3
drop _merge
*
sort pid
merge pid using w2_id1.dta
keep if _merge==3
drop _merge
*
sort pid
merge pid using w3_id1.dta
keep if _merge==3
drop _merge
****
save wrk4.dta, replace

forvalues r=1/3 {
use wrk4.dta, clear
* household outcomes
rename w`r'_h_tinc inc
rename w`r'_h_fdtot fd
rename h`r' h
* individual outcomes
rename w`r'_fwag main_wage
rename w`r'_cwag cas_wage
rename w`r'_swag self_wage
rename w`r'_remt remit
rename w`r'_brid_flg lobola
rename w`r'_empl_stat emp

* round variable
g r=`r'
save hhr_`r'_5, replace
}

use hhr_1_5, clear
append using hhr_2_5
append using hhr_3_5
rename w1_hhid hhid
keep pid hhid inc h fd r main_wage cas_wage self_wage remit lobola emp

save reg5, replace


use reg5, clear

xtset pid

xi: xtreg main_wage h i.r, fe robust cluster(hhid)

xi: xtreg cas_wage h i.r, fe robust cluster(hhid)

xi: xtreg self_wage h i.r, fe robust cluster(hhid)

xi: xtreg remit h i.r, fe robust cluster(hhid)

xi: xtreg emp h i.r, fe robust cluster(hhid)


* xi: xtreg lobola h i.r, fe robust cluster(hhid)
