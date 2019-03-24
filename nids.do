* NIDS

cd "/Users/willviolette/Google Drive/nids"

clear all
set mem 1000m
set maxvar 4000

*********************************************
******** PREP HOUSEHOLD GRANT RECIPIENTS ****
*********************************************
use HHQuestionnaire_W1_Anon_V5.2.dta, clear
*drop w1_h_ag*  w1_h_own*   w1_h_neg*
rename w1_h_sub w1_h_grnthse
* w1_h_sub_v
rename w1_h_nbthf w1_h_nbthmf
keep w1_hhid w1_h_grnthse w1_h_tinc w1_h_fdtot w1_h_nbthmf w1_h_watsrc w1_h_nftranspn w1_h_nbhlp
* w1_h_transmini
sort w1_hhid
save w1_hh.dta, replace

use HHQuestionnaire_W2_Anon_V2.2.dta, clear
*drop w2_h_ag*  w2_h_own*  w2_h_neg*
keep w2_hhid w2_h_grnthse w2_h_tinc w2_h_fdtot w2_h_nbthmf w2_h_watsrc w2_h_nftranspn
sort w2_hhid
save w2_hh.dta, replace

use HHQuestionnaire_W3_Anon_V1.2.dta, clear
*drop w3_h_ag*   w3_h_own*   w3_h_neg*
rename w3_h_sub w3_h_grnthse
keep w3_hhid w3_h_grnthse w3_h_tinc w3_h_fdtot w3_h_nbthmf w3_h_watsrc w3_h_nftranspn
sort w3_hhid
save w3_hh.dta, replace


*********************************************
******** PREP INDIVIDUAL GRANT RECIPIENTS ****
*********************************************

use Adult_W1_Anon_V5.2.dta, clear
* employment
*w1_a_em1
* income
*w1_a_em1pay
* spend on transport
*w1_a_em1trncst
* health
*w1_a_hldes
*w1_a_hl30d
keep pid w1_hhid w1_a_gen w1_a_dob_y w1_a_popgrp w1_a_em1 w1_a_em1pay w1_a_em1trncst w1_a_hldes w1_a_hl30d  
sort pid
save w1_id.dta, replace

use Adult_W2_Anon_V2.2.dta, clear
* employment
*w2_a_em1
* income
*w2_a_em1pay
* spend on transport
*w2_a_em1trncst
* travel time
*w2_a_em1trntime_h
*w2_a_em1trntime_m
* health
*w2_a_hldes
*w2_a_hl30d
keep pid w2_hhid w2_a_gen w2_a_dob_y w2_a_popgrp w2_a_em1 w2_a_em1pay w2_a_em1trncst w2_a_hldes w2_a_hl30d w2_a_em1trntime_h w2_a_em1trntime_m  
sort pid
save w2_id.dta, replace

use Adult_W3_Anon_V1.2.dta, clear
* employment
*w3_a_em1
* income
*w3_a_em1pay
* no travel time!!
* health
*w3_a_hldes
*w3_a_hl30d
keep pid w3_hhid w3_a_gen w3_a_dob_y w3_a_popgrp w3_a_em1 w3_a_em1pay w3_a_hldes w3_a_hl30d 
sort pid
save w3_id.dta, replace

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


duplicates drop w1_hhid, force

forvalues r=1/3 {
drop if w`r'_h_grnthse<0
}

forvalues r=1/3 {
g h`r'=(w`r'_h_grnthse==1)
}

***** NOW MERGE INDIVIDUALS
sort pid
merge pid using w1_id.dta
keep if _merge==3
drop _merge

sort pid
merge pid using w2_id.dta
keep if _merge==3
drop _merge

sort pid
merge pid using w3_id.dta
keep if _merge==3
drop _merge

*g h1_2=h2-h1
* 308 switchers
*g h2_3=h3-h2
* 422 switchers

* now do the fixed effects
*keep w1_hhid h1 h2 h3 *tinc *fdtot
*rename w1_hhid hhid
g w3_a_em1trncst=.

save wrk1.dta, replace


forvalues r=1/3 {
use wrk1.dta, clear
* household outcomes
rename w`r'_h_tinc inc
rename w`r'_h_fdtot fd
rename h`r' h
* individual outcomes
rename w`r'_a_gen gender
rename w`r'_a_dob_y age
rename w`r'_a_popgrp pop_grp
rename w`r'_a_em1 emp
rename w`r'_a_em1pay pay 
rename w`r'_a_em1trncst travel
rename w`r'_a_hldes health
rename w`r'_a_hl30d diar

* round variable
g r=`r'
save hhr_`r', replace
}



use hhr_1, clear
append using hhr_2
append using hhr_3
rename w1_hhid hhid
keep pid hhid inc h fd r gender age pop_grp emp pay travel health diar

save reg1, replace
****

use reg1, clear
** DO INDIVIDUAL LEVEL REGS

xtset pid
xi: xtreg health h i.r gender age if health>0, fe robust cluster(hhid)
* pos at 10% !!!
xi: xtreg diar h i.r gender age, fe robust cluster(hhid)
* nothing
xi: xtreg pay h i.r gender age if pay>0 & pay<400000, fe robust cluster(hhid)
* nothing
replace emp=0 if emp==2
replace emp=. if emp<0
xi: xtreg emp h i.r gender age, fe robust cluster(hhid)
* not much
xi: reg emp h i.r gender age, robust cluster(hhid)
xi: reg pay h i.r gender age if pay>0 & pay<400000, robust cluster(hhid)
* not much
xi: xtreg travel h i.r gender age if travel>=0, fe robust cluster(hhid)
* nothing
xi: reg travel h i.r gender age if travel>=0, robust cluster(hhid)
* slightly greater, but not that much

** Just to see
xtset hhid
xi: xtreg pay h i.r gender age if pay>0 & pay<400000, fe robust
xi: xtreg emp h i.r gender age, fe robust



 



** REDO HH PROPERLY


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


duplicates drop w1_hhid, force

forvalues r=1/3 {
drop if w`r'_h_grnthse<0
}

forvalues r=1/3 {
g h`r'=(w`r'_h_grnthse==1)
}
save wrk2.dta, replace


forvalues r=1/3 {
use wrk2.dta, clear
* household outcomes
rename w`r'_h_tinc inc
rename w`r'_h_fdtot fd
rename h`r' h
rename w`r'_h_nbthmf crime
rename w`r'_h_watsrc water
rename w`r'_h_nftranspn tran

g r=`r'
save hhr_`r'_1, replace
}

use hhr_1_1, clear
append using hhr_2_1
append using hhr_3_1
rename w1_hhid hhid

keep pid hhid inc h fd r crime water tran

save reg2.dta, replace




use reg2.dta, clear
** HOUSEHOLD LEVEL REGS
tab inc if inc<0, nolabel

drop if inc<0
drop if fd<0

drop if inc>2000000

sort hhid r


g hid=0
by hhid: replace hid=1 if h[_n-1]==0 & h[_n]==1

egen min_h=min(h), by(hhid)

g tap=(water==1 | water==2)



*twoway scatter h inc if inc<100000 & min_h==0

*hist inc if h==1 & inc<5000

xi: reg inc h i.r, robust
xi: reg fd h i.r, robust

xtset hhid
* manually
egen m_inc=mean(inc), by(hhid)
g inc_adj=inc-m_inc

xi: reg inc_adj h i.r, robust

xi: xtreg inc h i.r, fe robust

xi: xtreg fd h i.r, fe robust

xi: xtreg crime h i.r if crime>0, fe robust

xi: reg crime h i.r if crime>0, robust
* big stuff!

xi: xtreg tap h i.r, fe robust
* also significant

g tran_per=tran/inc

xi: xtreg tran h i.r if tran>0, fe robust
xi: xtreg tran_per h i.r if tran>0, fe robust
* nuthin

g fd_per=fd/inc

xi: xtreg fd_per h i.r, fe robust
