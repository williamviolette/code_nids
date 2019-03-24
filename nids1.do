* NIDS

cd "/Users/willviolette/Desktop/pstc_work/nids"

* cd "/Users/willviolette/Google Drive/nids"

* FOCUS ON INCOME!

clear all
set mem 1000m
set maxvar 4000

** LOOK AT DEMOGRAPHIC CORRELATES
use Adult_W1_Anon_V5.2.dta, clear
keep pid w1_a_cr w1_a_crpid1 w1_a_crprv1 w1_a_crrel1 w1_a_crt1 w1_a_cryrv1 w1_a_crpid2 w1_a_crprv2 w1_a_crrel2 w1_a_crt2 w1_a_cryrv2 w1_a_brndc w1_hhid w1_a_lv06dc w1_a_marstt w1_a_mary w1_a_movy w1_a_bhlive_n w1_a_em1pay w1_a_dtbnd w1_a_ownbic w1_a_hl30fl w1_a_emohap w1_a_fwbinc5yr w1_a_gen w1_a_dob_y w1_a_marstt w1_a_popgrp w1_a_em1 w1_a_hllfexer w1_a_wblv w1_a_bpsys_1 w1_a_emodep w1_a_com2 w1_a_relnb w1_a_fwbstp2yr w1_a_fwbstptd w1_a_em1pay w1_a_em1occ_c w1_a_em1trncst w1_a_hldes w1_a_hl30d w1_a_com1 w1_a_com2 w1_a_com3 w1_a_com4 w1_a_com5 w1_a_com6 w1_a_com7 w1_a_com8 w1_a_com9 w1_a_com10 w1_a_com11 w1_a_com12 w1_a_com13 w1_a_com14 w1_a_com15 w1_a_com16 w1_a_com17 
g w1_a_em1trntime_h=.
g w1_a_em1trntime_m=.
g w1_a_lvevoth=.
sort pid
save w1_id.dta, replace

use Adult_W2_Anon_V2.2.dta, clear
keep pid w2_a_cr w2_a_crpid1 w2_a_crprv1 w2_a_crrel1 w2_a_crt1 w2_a_cryrv1 w2_a_crpid2 w2_a_crprv2 w2_a_crrel2 w2_a_crt2 w2_a_cryrv2 w2_hhid w2_a_lv08dc w2_a_marstt w2_a_mary w2_a_lvevoth w2_a_mvsuby w2_a_bhlive_n w2_a_em1pay w2_a_dtbnd w2_a_ownbic w2_a_hl30fl w2_a_emohap w2_a_fwbinc5yr w2_a_gen w2_a_dob_y w2_a_marstt w2_a_popgrp w2_a_em1 w2_a_hllfexer w2_a_wblv w2_a_bpsys_1 w2_a_emodep w2_a_com2 w2_a_relnb w2_a_fwbstp2yr w2_a_fwbstptd w2_a_em1pay w2_a_em1occ_c w2_a_em1trncst w2_a_hldes w2_a_hl30d w2_a_em1trntime_h w2_a_em1trntime_m  w2_a_com1 w2_a_com2 w2_a_com3 w2_a_com4 w2_a_com5 w2_a_com6 w2_a_com7 w2_a_com8 w2_a_com9 w2_a_com10 w2_a_com11 w2_a_com12 w2_a_com13 w2_a_com14 w2_a_com15 w2_a_com16 w2_a_com17 
ren w2_a_mvsuby w2_a_movy 
ren w2_a_lv08dc w2_a_lv06dc
g w2_a_brndc=.
sort pid
save w2_id.dta, replace

use Adult_W3_Anon_V1.2.dta, clear
keep pid w3_a_cr w3_a_crpid1 w3_a_crprv1 w3_a_crrel1 w3_a_crt1 w3_a_cryrv1 w3_a_crpid2 w3_a_crprv2 w3_a_crrel2 w3_a_crt2 w3_a_cryrv2 w3_hhid w3_a_em1pay w3_a_mary w3_a_lvevoth w3_a_moveyr w3_a_bhlive_n w3_a_dtbnd w3_a_ownbic w3_a_hl30fl w3_a_emohap w3_a_fwbinc5yr w3_a_gen w3_a_dob_y w3_a_marstt w3_a_popgrp w3_a_em1 w3_a_hllfexer w3_a_wblv w3_a_bpsys_1 w3_a_emodep w3_a_relnb w3_a_fwbstp2yr w3_a_fwbstptd w3_a_em1pay w3_a_em1occ_c w3_a_hldes w3_a_hl30d 
forvalues r=1/17 {
g w3_a_com`r'=.
}
ren w3_a_moveyr w3_a_movy
g w3_a_lv06dc=.
g w3_a_em1trncst=.
g w3_a_em1trntime_h=.
g w3_a_em1trntime_m=.
g w3_a_brndc=.
sort pid
save w3_id.dta, replace

** INDIVIDUAL DERIVED
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



** ORIGINAL HH
use HHQuestionnaire_W1_Anon_V5.2.dta, clear
rename w1_h_sub w1_h_grnthse
rename w1_h_nbthf w1_h_nbthmf
keep w1_hhid w1_h_toi w1_h_toishr w1_h_dwltyp w1_h_dwlrms w1_h_dwlmatroof w1_h_dwlmatrwll w1_h_ownd w1_h_ownpid1 w1_h_ownpaid w1_h_ownrnt w1_h_rntpay w1_h_mrkv w1_h_sub_v w1_h_lndgrn w1_h_lndrst w1_h_ownpid1 w1_h_grnthse w1_h_tinc w1_h_fdtot w1_h_nbthmf w1_h_watsrc w1_h_enrgelec w1_h_nftranspn w1_h_nbhlp
sort w1_hhid
save w1_hh.dta, replace

use HHQuestionnaire_W2_Anon_V2.2.dta, clear
keep w2_hhid w2_h_toi w2_h_toishr w2_h_dwltyp w2_h_dwlrms w2_h_dwlmatroof w2_h_dwlmatrwll w2_h_ownd w2_h_ownpid1 w2_h_ownpaid w2_h_rnt w2_h_rntpay w2_h_mrkv w2_h_lndgrn w2_h_lndrst w2_h_ownpid1 w2_h_grnthse w2_h_tinc w2_h_fdtot w2_h_nbthmf w2_h_watsrc w2_h_enrgelec w2_h_nftranspn
rename w2_h_rnt w2_h_ownrnt
g w2_h_sub_v=.
sort w2_hhid
save w2_hh.dta, replace

use HHQuestionnaire_W3_Anon_V1.2.dta, clear
rename w3_h_sub w3_h_grnthse
keep w3_hhid w3_h_toi w3_h_toishr w3_h_dwltyp w3_h_dwlrms w3_h_dwlmatroof w3_h_dwlmatrwll w3_h_ownd w3_h_ownpid1 w3_h_ownpaid w3_h_rnt w3_h_rntpay w3_h_mrkv w3_h_lndgrn w3_h_lndrst w3_h_ownpid1 w3_h_grnthse w3_h_tinc w3_h_fdtot w3_h_nbthmf w3_h_watsrc w3_h_enrgelec w3_h_nftranspn
rename w3_h_rnt w3_h_ownrnt
g  w3_h_sub_v=.
sort w3_hhid
save w3_hh.dta, replace

** DERIVED HH
use hhderived_W1_Anon_V5.2.dta, clear
keep w1_hhid w1_pi_hhincome w1_pi_hhwage w1_pi_hhgovt w1_pi_hhremitt w1_expf w1_expnf w1_hhagric w1_hhsizer w1_rentexpend w1_hhgeo2011
sort w1_hhid
save hhd_w1.dta, replace

use hhderived_W2_Anon_V2.2.dta, clear
keep w2_hhid w2_pi_hhincome w2_pi_hhwage w2_pi_hhgovt w2_pi_hhremitt w2_expf w2_expnf w2_hhagric w2_hhsizer w2_rentexpend w2_hhgeo2011
sort w2_hhid
save hhd_w2.dta, replace

use hhderived_W3_Anon_V1.2.dta, clear
keep w3_hhid w3_pi_hhincome w3_pi_hhwage w3_pi_hhgovt w3_pi_hhremitt w3_expf w3_expnf w3_hhagric w3_hhsizer w3_rentexpend w3_hhgeo2011
sort w3_hhid
save hhd_w3.dta, replace


use Link_File_W3_Anon_V1.2.dta, clear

** DEMOGRAPHIC MERGE
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

** INDIVIDUAL DERIVED MERGE

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


** ORIGINAL MERGE
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

** DERIVED MERGE
sort w1_hhid
merge w1_hhid using hhd_w1.dta
keep if _merge==3
drop _merge

sort w2_hhid
merge w2_hhid using hhd_w2.dta
keep if _merge==3
drop _merge

sort w3_hhid
merge w3_hhid using hhd_w3.dta
keep if _merge==3
drop _merge

* tab w1_h_nbhlp w1_h_grnthse
* make famsize var
g i=1
egen w1_fam=sum(i), by(w1_hhid)
egen w2_fam=sum(i), by(w2_hhid)
egen w3_fam=sum(i), by(w3_hhid)
drop i


forvalues r=1/3 {
g h`r'=w`r'_h_grnthse
}

save wrk3.dta, replace



forvalues r=1/3 {

use wrk3.dta, clear
* household outcomes
rename w`r'_h_tinc inc
rename w`r'_h_fdtot fd
rename h`r' h
rename w`r'_h_nbthmf crime
rename w`r'_h_watsrc water
rename w`r'_h_enrgelec elec
rename w`r'_h_nftranspn tran
rename w`r'_pi_hhwage wage
rename w`r'_pi_hhgovt govt
rename w`r'_pi_hhremitt remit
rename w`r'_expf food
rename w`r'_expnf nonfood
rename w`r'_hhagric ag
rename w`r'_fam fam
rename w`r'_hhsizer size
rename w`r'_rentexpend rent
rename w`r'_hhgeo2011 urb
rename w`r'_pi_hhincome hh_income

rename w`r'_h_dwltyp dwell
rename w`r'_h_dwlrms rooms
rename w`r'_h_dwlmatroof roof
rename w`r'_h_dwlmatrwll walls
rename w`r'_h_ownd own 
rename w`r'_h_rnt rent_1
* * doublecheck later: rename w`r'_h_rntpay rent_pay
rename w`r'_h_mrkv mktv
rename w`r'_h_lndgrn lndgrn
rename w`r'_h_lndrst lndrst
rename w`r'_h_ownpid1 ownpid

* toilet facility
rename w`r'_h_toi toi
rename w`r'_h_toishr toi_shr

* individual outcomes
rename w`r'_a_gen gender
rename w`r'_a_dob_y age
rename w`r'_a_popgrp pop_grp
rename w`r'_a_em1 emp
rename w`r'_a_em1pay pay 
rename w`r'_a_em1trncst travel
rename w`r'_a_hldes health
rename w`r'_a_hl30d diar
rename w`r'_a_em1trntime_h t_time_h
rename w`r'_a_em1trntime_m t_time_m
rename w`r'_a_lv06dc district
rename w`r'_a_brndc bdc

rename w`r'_fwag main_wage
rename w`r'_cwag cas_wage
rename w`r'_swag self_wage
rename w`r'_remt remit_id
rename w`r'_empl_stat emp_d
rename w`r'_a_marstt marry
rename w`r'_hhid hhid
rename w`r'_a_em1occ_c occ
rename w`r'_a_emodep dep
rename w`r'_a_hllfexer exer
rename w`r'_a_wblv stay
rename w`r'_a_bpsys_1 bp
rename w`r'_a_fwbstp2yr inc_exp
rename w`r'_a_fwbstptd inc_today
rename w`r'_a_relnb religion

rename w`r'_a_mary marry_yrs
rename w`r'_a_movy move_yr 
rename w`r'_a_bhlive_n child
* rename w`r'_a_em1pay emp_1
rename w`r'_a_dtbnd home_loan
rename w`r'_a_ownbic bike
rename w`r'_a_hl30fl flu
rename w`r'_a_emohap emo
rename w`r'_a_fwbinc5yr inc_exp5
rename w`r'_a_lvevoth move_rec

* rename w`r'_h_ownpid1 ownpid
rename w`r'_h_ownpaid ownpaid

** REMITTANCE DETAILS
rename w`r'_a_cr re_yn
rename w`r'_a_crpid1 re_pid1
rename w`r'_a_crprv1 re_loc1
rename w`r'_a_crrel1 re_rel1
rename w`r'_a_crt1 re_no1
rename w`r'_a_cryrv1 re_val1
rename w`r'_a_crpid2 re_pid2
rename w`r'_a_crprv2 re_loc2
rename w`r'_a_crrel2 re_rel2
rename w`r'_a_crt2 re_no2
rename w`r'_a_cryrv2 re_val2


forvalues z=1/17 {
rename w`r'_a_com`z' com`z'
}

g r=`r'
save hhr_`r'_2, replace
}


use hhr_1_2, clear
append using hhr_2_2
append using hhr_3_2


replace elec=. if elec<0
replace elec=0 if elec==2


keep pid hhid bdc re_yn re_pid1 re_loc1 re_rel1 re_no1 re_val1 re_pid2 re_loc2 re_rel2 re_no2 re_val2 toi toi_shr ownpaid ownpid district inc h fd r dwell rooms roof walls own rent_1 mktv lndgrn lndrst ownpid marry_yrs move_yr child home_loan bike flu emo inc_exp5 move_rec com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 crime occ water elec tran wage govt remit food nonfood ag fam size rent urb gender age marry pop_grp emp pay travel health diar t_time_h t_time_m main_wage cas_wage self_wage remit_id emp_d hh_income dep exer stay bp inc_exp inc_today religion

save reg3.dta, replace







*******************
***             ***
*******************

** TRY WORKING WITH THE WAGE DISCONT

use reg3.dta, clear
sort pid r
g h_ch=0
by pid: replace h_ch=1 if h[_n]==0 & h[_n+1]==1
by pid: replace h_ch=. if h[_n]==1 & h[_n+1]==1
g d=(wage>3500)

replace food=. if food<=0
replace emp=. if emp<0
replace emp=0 if emp==2
by pid: g size_ch=size[_n+1]-size[_n]

reg h_ch d if wage>2000 & wage<10000, robust

g tap=(water==1 | water==2)


foreach var of varlist dep wage remit tap crime elec emp food burial religion stay {
replace `var'=. if `var'<0
g `var'_ch=.
by pid: replace `var'_ch=`var'[_n+1]-`var'[_n]
xi: ivregress 2sls `var'_ch i.urb i.pop_grp age i.marry size_ch (h_ch=d) if wage>0 & wage<7000, robust
}


*** NOT SUPER CONVINCING ***


use wrk3.dta, clear

replace w1_fwag=. if w1_fwag<=0 | w1_fwag>20000
replace w2_fwag=. if w2_fwag<=0 | w2_fwag>20000
replace w1_a_em1pay=. if w1_a_em1pay<=0 | w1_a_em1pay>20000
replace w2_a_em1pay=. if w2_a_em1pay<=0 | w2_a_em1pay>20000

g rmt_ch=w2_pi_hhremitt-w1_pi_hhremitt
g wg_ch=w2_fwag-w1_fwag
g pay_ch=w2_a_em1pay-w1_a_em1pay

*twoway scatter rmt_ch w1_fwag
*twoway scatter wg_ch w1_fwag
*twoway lowess wg_ch w1_fwag
*twoway (scatter pay_ch w1_fwag if w1_fwag<7000 | w1_fwag>1500) || (lowess pay_ch w1_fwag if w1_fwag<7000 | w1_fwag>1500) 
** WAY TO FUZZY TO GET ANYTHING GRAPHICALLY




** LOOK FOR WAGE DISCONTINUITY! NOT THAT BAD!!
use reg3.dta, clear

*drop if pay<0
*drop if pay>10000
*hist pay if h==0
*hist pay if h==1

sort pid r

g h_1=0
by pid: replace h_1=1 if h[_n]==0 & h[_n+1]==1

hist wage if h_1==1 & wage<20000

hist wage if h_1==1 & wage<8000

tab wage if h_1==1 & wage<8000 & wage>2000

g w_g=wage+govt

hist w_g if h_1==1 & w_g<20000

hist w_g if h_1==1 & w_g<10000

replace remit=0 if remit==.
replace govt=0 if govt==.
g w_g_r=wage+govt+remit

hist w_g_r if h_1==1 & w_g_r<20000
hist w_g_r if h_1==0 & w_g_r<20000
hist w_g_r if h_1==0 & h==0 & w_g_r<20000

hist w_g_r if h_1==1 & w_g_r<10000





hist hh_income if h_1==1 & hh_income<20000

hist hh_income if h_1==1 & hh_income<8000

tab hh_income if h_1==1 & hh_income<8000 & hh_income>2000


drop if h==1 & h_1==0

egen m_w=mean(h_1), by(pay)

twoway scatter m_w pay

twoway lowess h_1 pay, bwidth(2)

** LOOK FOR ELIGIBILITY


*** HH Head
* look at age of those that got houses
** TOO FEW AT THE RIGHT AGE CUTOFF
use reg3.dta, clear

sort pid r
g h_1=0
by pid: replace h_1=1 if h[_n]==0 & h[_n+1]==1
drop if h==1 & h_1==0

replace age=2008-age if r==1
replace age=2010-age if r==2
replace age=2012-age if r==3
replace age=. if age<=14

egen m_hhh=mean(h_1), by(hhh)

twoway scatter m_hhh hhh if hhh<30

** NOW LOOK AT MARRIED
*************
use reg3.dta, clear

replace age=2008-age if r==1
replace age=2010-age if r==2
replace age=2012-age if r==3
replace age=. if age<=14

twoway (hist age if urb==2 & h==1, color(b)) || (hist age if urb!=2 & h==1)

g u=(urb==2)
g age_u=age*u
g gen=(gender==1)
g gen_u=gen*u
g size_u= size * u


reg h age u gen wage, robust

reg h u gen gen_u wage, robust

reg h u size size_u wage, robust

reg h size wage if u==1, robust

reg h age u age_u gen wage, robust

egen hhh=max(age), by(hhid)
keep if age==hhh

g cpl=.
replace cpl=1 if marry==1 | marry==2
replace cpl=0 if marry==5

g mar=(marry==1)
g rel=(marry==2)

reg h marry, robust
reg h rel, robust

egen h_mar=mean(h) if marry==1, by(hhh)
egen h_nmar=mean(h) if marry==2, by(hhh)
egen h_nr=mean(h) if mar==0 & rel==0, by(hhh)

sort age
twoway (line h_mar age if age<30) || (line h_nmar age if age<30) || (line h_nr age if age<30)


reg h cpl, robust





******************
*** ANALYSIS
*******************
use reg3.dta, clear

*** FIXED EFFECTS ***
xtset pid
*********************

sum h if urb==1
sum h if urb==2
sum h if urb==3


******** KEY DISTINCTION  *****
** TRY ONLY ENTERING HOUSING!!!!!!
 sort pid r
 by pid: g h_ch=h[_n]-h[_n-1]
 drop if h_ch==-1
*********************************
*********************************

*** SIGNIFICANT EFFECTS:

** CORRELATIONS

* younger
* no diff in health or transport
* poorer

** MECHANICAL IMPACTS ** all very significant

* CRIME INCREASE,    urban concentrated
* WATER INCREASE,      urban concentrated
* RENT DECREASE,      definitely urban concentrated
* INCREASE IN ELEC,    urban concentrated

** ACTUAL OUTCOMES **

* WAGE DECLINE,      urban concentrated  * maybe 10%
* REMITTANCE DECLINE  both * %5  * at individual level,
								 * kind of works more for urban
* FAMILY DECLINE,    urban concentrated
* LESS TRANSPORT EXPENDITURE, urban concentrated
* AG INCOME DECLINE, rural 
** but Maybe an increase in Employment at the individual level
foreach var of varlist dep exer stay bp inc_exp inc_today burial religion {
replace `var'=. if `var'<0
tab `var'
}



replace emp=. if emp<0
replace emp=0 if emp==2

replace pay=. if pay<0 | pay>400000

g tap=(water==1 | water==2)

*** FIXED EFFECTS ***
xtset pid
*********************

* new outcomes
foreach var of varlist dep exer stay bp inc_exp inc_today religion burial {
xi: xtreg `var' h i.r, fe robust 

xi: xtreg `var' h i.r if urb==2, fe robust 
xi: xtreg `var' h i.r if urb!=2, fe robust 
}

foreach var of varlist dep exer stay bp inc_exp inc_today religion burial {
xi: xtreg `var' h i.r if wage<20000 | wage==., fe robust 

xi: xtreg `var' h i.r if urb==2 & wage<20000 | wage==., fe robust 
xi: xtreg `var' h i.r if urb!=2 & wage<20000 | wage==., fe robust 
}



* CORRELATIONS
reg age h, robust
reg travel h, robust
reg health h, robust
reg diar h, robust
reg t_time_h h, robust
reg t_time_m h, robust

xi: reg emp h i.r, robust 
xi: reg wage h i.r, robust 


** EMP (INDIVIDUAL) 
xi: xtreg emp h i.r, fe robust

xi: xtreg emp h i.r if urb==2, fe robust 
xi: xtreg emp h i.r if urb!=2, fe robust 


** PAY (INDIVIDUAL) 
xi: xtreg pay h i.r, fe robust 

xi: xtreg pay h i.r if urb==2, fe robust 
xi: xtreg pay h i.r if urb!=2, fe robust 

** INCOME (poor measure?)
xi: xtreg inc h i.r if inc>0, fe robust 

xi: xtreg inc h i.r if urb==2 & inc>0, fe robust 
xi: xtreg inc h i.r if urb!=2 & inc>0, fe robust 

** WAGE
xi: xtreg wage h i.r, fe robust 

xi: xtreg wage h i.r if urb==2, fe robust 
xi: xtreg wage h i.r if urb!=2, fe robust 

xi: xtreg wage h size i.r, fe robust 

xi: xtreg wage h size i.r if urb==2, fe robust 
xi: xtreg wage h size i.r if urb!=2, fe robust 
** PRETTY ROBUST TO CONTROLLING FOR FAMILY SIZE

** GOVT
xi: xtreg govt h i.r, fe robust 

xi: xtreg govt h i.r if urb==2, fe robust 
xi: xtreg govt h i.r if urb!=2, fe robust 

** REMIT
xi: xtreg remit h i.r, fe robust 

xi: xtreg remit h i.r if urb==2, fe robust 
xi: xtreg remit h i.r if urb!=2, fe robust 

** FOOD
xi: xtreg food h i.r, fe robust 

xi: xtreg food h i.r if urb==2, fe robust 
xi: xtreg food h i.r if urb!=2, fe robust 

** NONFOOD
xi: xtreg nonfood h i.r, fe robust 

** FAM
xi: xtreg fam h i.r, fe robust 

xi: xtreg fam h i.r if urb==2, fe robust 
xi: xtreg fam h i.r if urb!=2, fe robust 

** CRIME
xi: xtreg crime h i.r, fe robust 

xi: xtreg crime h i.r if urb==2, fe robust 
xi: xtreg crime h i.r if urb!=2, fe robust 

** TRAN
xi: xtreg tran h i.r if tran!=0, fe robust 

xi: xtreg tran h i.r if urb==2 & tran!=0, fe robust 
xi: xtreg tran h i.r if urb!=2 & tran!=0, fe robust 

** WATER
xi: xtreg tap h i.r, fe robust 

xi: xtreg tap h i.r if urb==2, fe robust 
xi: xtreg tap h i.r if urb!=2, fe robust 

** ELEC
xi: xtreg elec h i.r, fe robust 

xi: xtreg elec h i.r if urb==2, fe robust 
xi: xtreg elec h i.r if urb!=2, fe robust 

** SIZE
xi: xtreg size h i.r, fe robust 

xi: xtreg size h i.r if urb==2, fe robust 
xi: xtreg size h i.r if urb!=2, fe robust 

** AG INCOME
xi: xtreg ag h i.r, fe robust 

xi: xtreg ag h i.r if urb==2, fe robust 
xi: xtreg ag h i.r if urb!=2, fe robust 

** RENT
xi: xtreg rent h i.r, fe robust 

xi: xtreg rent h i.r if urb==2, fe robust 
xi: xtreg rent h i.r if urb!=2, fe robust 

** DEP
xi: xtreg dep h i.r, fe robust 

xi: xtreg dep h i.r if urb==2, fe robust 
xi: xtreg dep h i.r if urb!=2, fe robust 

******************************
** INDIVIDUAL DERIVED ANALYSIS

*** MAIN WAGE
xi: xtreg main_wage h size i.r, fe robust 

xi: xtreg main_wage h size i.r if urb==2, fe robust 
xi: xtreg main_wage h size i.r if urb!=2, fe robust 

** CASUAL WAGE
xi: xtreg cas_wage h i.r, fe robust 

xi: xtreg cas_wage h i.r if urb==2, fe robust 
xi: xtreg cas_wage h i.r if urb!=2, fe robust 

** SELF EMPLOYED WAGE
xi: xtreg self_wage h i.r, fe robust 

xi: xtreg self_wage h i.r if urb==2, fe robust 
xi: xtreg self_wage h i.r if urb!=2, fe robust 

** REMIT
xi: xtreg remit_id h i.r, fe robust 

xi: xtreg remit_id h i.r if urb==2, fe robust 
xi: xtreg remit_id h i.r if urb!=2, fe robust 

* EMPLOYMENT
xi: xtreg emp_d h i.r, fe robust 

xi: xtreg emp_d h i.r if urb==2, fe robust 
xi: xtreg emp_d h i.r if urb!=2, fe robust 
