* NIDS

cd "/Users/willviolette/Desktop/pstc_work/nids"

* cd "/Users/willviolette/Google Drive/nids"

* FOCUS ON INCOME!

clear all
set mem 1000m
set maxvar 10000

** LOOK AT DEMOGRAPHIC CORRELATES
use Adult_W1_Anon_V5.2.dta, clear
* keep pid w1_a_cr w1_a_crpid1 w1_a_crprv1 w1_a_crrel1 w1_a_crt1 w1_a_cryrv1 w1_a_crpid2 w1_a_crprv2 w1_a_crrel2 w1_a_crt2 w1_a_cryrv2 w1_a_brndc w1_hhid w1_a_lv06dc w1_a_marstt w1_a_mary w1_a_movy w1_a_bhlive_n w1_a_em1pay w1_a_dtbnd w1_a_ownbic w1_a_hl30fl w1_a_emohap w1_a_fwbinc5yr w1_a_gen w1_a_dob_y w1_a_marstt w1_a_popgrp w1_a_em1 w1_a_hllfexer w1_a_wblv w1_a_bpsys_1 w1_a_emodep w1_a_com2 w1_a_relnb w1_a_fwbstp2yr w1_a_fwbstptd w1_a_em1pay w1_a_em1occ_c w1_a_em1trncst w1_a_hldes w1_a_hl30d w1_a_com1 w1_a_com2 w1_a_com3 w1_a_com4 w1_a_com5 w1_a_com6 w1_a_com7 w1_a_com8 w1_a_com9 w1_a_com10 w1_a_com11 w1_a_com12 w1_a_com13 w1_a_com14 w1_a_com15 w1_a_com16 w1_a_com17 

g w1_a_em1trntime_h=.
g w1_a_em1trntime_m=.
g w1_a_lvevoth=.
sort pid
save w1_id.dta, replace

use Adult_W2_Anon_V2.2.dta, clear


rename w2_a_decd w2_a_decdpid
rename w2_a_decd2 w2_a_decdpid2 
rename w2_a_declrg w2_a_declrgpid
rename w2_a_declrg2 w2_a_declrgpid2
rename w2_a_decmem w2_a_decmempid
rename w2_a_decmem2 w2_a_decmempid2
rename w2_a_declv w2_a_declvpid
rename w2_a_declv2 w2_a_declvpid2
rename w2_a_decsch w2_a_decschpid
rename w2_a_decsch2 w2_a_decschpid2
* * keep pid w2_a_cr w2_a_crpid1 w2_a_crprv1 w2_a_crrel1 w2_a_crt1 w2_a_cryrv1 w2_a_crpid2 w2_a_crprv2 w2_a_crrel2 w2_a_crt2 w2_a_cryrv2 w2_hhid w2_a_lv08dc w2_a_marstt w2_a_mary w2_a_lvevoth w2_a_mvsuby w2_a_bhlive_n w2_a_em1pay w2_a_dtbnd w2_a_ownbic w2_a_hl30fl w2_a_emohap w2_a_fwbinc5yr w2_a_gen w2_a_dob_y w2_a_marstt w2_a_popgrp w2_a_em1 w2_a_hllfexer w2_a_wblv w2_a_bpsys_1 w2_a_emodep w2_a_com2 w2_a_relnb w2_a_fwbstp2yr w2_a_fwbstptd w2_a_em1pay w2_a_em1occ_c w2_a_em1trncst w2_a_hldes w2_a_hl30d w2_a_em1trntime_h w2_a_em1trntime_m  w2_a_com1 w2_a_com2 w2_a_com3 w2_a_com4 w2_a_com5 w2_a_com6 w2_a_com7 w2_a_com8 w2_a_com9 w2_a_com10 w2_a_com11 w2_a_com12 w2_a_com13 w2_a_com14 w2_a_com15 w2_a_com16 w2_a_com17 

ren w2_a_mvsuby w2_a_movy 
ren w2_a_lv08dc w2_a_lv06dc
drop w2_a_brndc
g w2_a_brndc=.
sort pid
save w2_id.dta, replace

use Adult_W3_Anon_V1.2.dta, clear
* * keep pid w3_a_cr w3_a_crpid1 w3_a_crprv1 w3_a_crrel1 w3_a_crt1 w3_a_cryrv1 w3_a_crpid2 w3_a_crprv2 w3_a_crrel2 w3_a_crt2 w3_a_cryrv2 w3_hhid w3_a_em1pay w3_a_mary w3_a_lvevoth w3_a_moveyr w3_a_bhlive_n w3_a_dtbnd w3_a_ownbic w3_a_hl30fl w3_a_emohap w3_a_fwbinc5yr w3_a_gen w3_a_dob_y w3_a_marstt w3_a_popgrp w3_a_em1 w3_a_hllfexer w3_a_wblv w3_a_bpsys_1 w3_a_emodep w3_a_relnb w3_a_fwbstp2yr w3_a_fwbstptd w3_a_em1pay w3_a_em1occ_c w3_a_hldes w3_a_hl30d 

forvalues r=1/17 {
g w3_a_com`r'=.
}
drop w3_a_brndc

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
* keep w1_hhid pid w1_fwag w1_cwag w1_swag w1_remt w1_brid_flg w1_empl_stat
sort pid
save w1_id1.dta, replace

use indderived_W2_Anon_V2.2.dta, clear
* keep w2_hhid pid w2_fwag w2_cwag w2_swag w2_remt w2_brid_flg w2_empl_stat 
rename w2_cdep w2_care
rename w2_cdep_flg w2_care_flg
sort pid
save w2_id1.dta, replace

use indderived_W3_Anon_V1.2.dta, clear
rename w3_cdep w3_care
rename w3_cdep_flg w3_care_flg
* keep w3_hhid pid w3_fwag w3_cwag w3_swag w3_remt w3_brid_flg w3_empl_stat
sort pid
save w3_id1.dta, replace



** ORIGINAL HH
use HHQuestionnaire_W1_Anon_V5.2.dta, clear
rename w1_h_sub w1_h_grnthse
rename w1_h_nbthf w1_h_nbthmf
* keep w1_hhid w1_h_toi w1_h_toishr w1_h_dwltyp w1_h_dwlrms w1_h_dwlmatroof w1_h_dwlmatrwll w1_h_ownd w1_h_ownpid1 w1_h_ownpaid w1_h_ownrnt w1_h_rntpay w1_h_mrkv w1_h_sub_v w1_h_lndgrn w1_h_lndrst w1_h_ownpid1 w1_h_grnthse w1_h_tinc w1_h_fdtot w1_h_nbthmf w1_h_watsrc w1_h_enrgelec w1_h_nftranspn w1_h_nbhlp

sort w1_hhid
save w1_hh.dta, replace

use HHQuestionnaire_W2_Anon_V2.2.dta, clear
* keep w2_hhid w2_h_toi w2_h_toishr w2_h_dwltyp w2_h_dwlrms w2_h_dwlmatroof w2_h_dwlmatrwll w2_h_ownd w2_h_ownpid1 w2_h_ownpaid w2_h_rnt w2_h_rntpay w2_h_mrkv w2_h_lndgrn w2_h_lndrst w2_h_ownpid1 w2_h_grnthse w2_h_tinc w2_h_fdtot w2_h_nbthmf w2_h_watsrc w2_h_enrgelec w2_h_nftranspn
rename w2_h_rnt w2_h_ownrnt
g w2_h_sub_v=.
sort w2_hhid
save w2_hh.dta, replace

use HHQuestionnaire_W3_Anon_V1.2.dta, clear
rename w3_h_sub w3_h_grnthse
* keep w3_hhid w3_h_toi w3_h_toishr w3_h_dwltyp w3_h_dwlrms w3_h_dwlmatroof w3_h_dwlmatrwll w3_h_ownd w3_h_ownpid1 w3_h_ownpaid w3_h_rnt w3_h_rntpay w3_h_mrkv w3_h_lndgrn w3_h_lndrst w3_h_ownpid1 w3_h_grnthse w3_h_tinc w3_h_fdtot w3_h_nbthmf w3_h_watsrc w3_h_enrgelec w3_h_nftranspn
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

save wrk3_1.dta, replace



forvalues r=1/3 {

use wrk3_1.dta, clear
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
* rename w`r'_expf food
rename w`r'_expnf nonfood
* rename w`r'_hhagric ag
rename w`r'_fam fam
rename w`r'_hhsizer size
* rename w`r'_rentexpend rent
rename w`r'_hhgeo2011 urb
rename w`r'_pi_hhincome hh_income

rename w`r'_h_dwltyp dwell
rename w`r'_h_dwlrms rooms
rename w`r'_h_dwlmatroof roof
rename w`r'_h_dwlmatrwll walls
rename w`r'_h_ownd own 
*rename w`r'_h_rnt rent_1
* TAKE OUT rent_1 FOR THE TIME BEING
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

* rename w`r'_fwag main_wage
* rename w`r'_cwag cas_wage
* rename w`r'_swag self_wage
* rename w`r'_remt remit_id
rename w`r'_empl_stat emp_d

rename w`r'_fwag fwag
rename w`r'_cwag cwag
rename w`r'_swag swag
rename w`r'_cheq cheq
rename w`r'_prof prof
rename w`r'_extr extr
rename w`r'_bonu bonu
rename w`r'_othe othe
rename w`r'_help help 
rename w`r'_spen spen
rename w`r'_ppen ppen
rename w`r'_uif uif
rename w`r'_comp comp
rename w`r'_dis dis
rename w`r'_chld chld
rename w`r'_fost fost
rename w`r'_care care
rename w`r'_indi indi
rename w`r'_inhe inhe
* rename w`r'_rnt rnt
rename w`r'_retr retr
rename w`r'_brid brid
rename w`r'_gift gift
rename w`r'_loan loan
rename w`r'_sale sale
rename w`r'_remt remt
rename w`r'_fwag_flg fwag_flg
rename w`r'_cwag_flg cwag_flg
rename w`r'_swag_flg swag_flg
rename w`r'_cheq_flg cheq_flg
rename w`r'_prof_flg prof_flg
rename w`r'_extr_flg extr_flg
rename w`r'_bonu_flg bonu_flg
rename w`r'_othe_flg othe_flg
rename w`r'_help_flg help_flg
rename w`r'_spen_flg spen_flg
rename w`r'_ppen_flg ppen_flg
rename w`r'_uif_flg uif_flg
rename w`r'_comp_flg comp_flg
rename w`r'_dis_flg dis_flg
rename w`r'_chld_flg chld_flg
rename w`r'_fost_flg fost_flg
rename w`r'_care_flg care_flg
rename w`r'_indi_flg indi_flg
rename w`r'_inhe_flg inhe_flg
rename w`r'_rnt_flg rnt_flg
rename w`r'_retr_flg retr_flg
rename w`r'_brid_flg brid_flg
rename w`r'_gift_flg gift_flg
rename w`r'_loan_flg loan_flg
rename w`r'_sale_flg sale_flg
rename w`r'_remt_flg remt_flg

rename w`r'_a_decdpid decd
rename w`r'_a_decdpid2 decd2
rename w`r'_a_declrgpid decl
rename w`r'_a_declrgpid2 decl2
rename w`r'_a_decmempid decmemp
rename w`r'_a_decmempid2 decmemp2
rename w`r'_a_declvpid declv
rename w`r'_a_declvpid2 declv2
rename w`r'_a_decschpid decsch
rename w`r'_a_decschpid2 decsch2


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

** FOOD
* rename w`r'_h_fdtot fdtot
rename w`r'_h_fdmm fdmm
rename w`r'_h_fdmmspn fdmmspn
rename w`r'_h_fdsmp fdsmp
rename w`r'_h_fdsmpspn fdsmpspn
rename w`r'_h_fdflr fdflr
rename w`r'_h_fdflrspn fdflrspn
rename w`r'_h_fdrice fdrice
rename w`r'_h_fdricespn fdricespn
rename w`r'_h_fdpas fdpas
rename w`r'_h_fdpasspn fdpasspn
rename w`r'_h_fdbis fdbis
rename w`r'_h_fdbisspn fdbisspn
rename w`r'_h_fdrm fdrm
rename w`r'_h_fdrmspn fdrmspn
rename w`r'_h_fdrmcspn fdrmcspn
rename w`r'_h_fdchi fdchi
rename w`r'_h_fdchispn fdchispn
rename w`r'_h_fdfsh fdfsh
rename w`r'_h_fdfshspn fdfshspn
rename w`r'_h_fdfshc fdfshc
rename w`r'_h_fdfshcspn fdfshcspn
rename w`r'_h_fdvegd fdvegd
rename w`r'_h_fdvegdspn fdvegdspn
rename w`r'_h_fdpot fdpot
rename w`r'_h_fdpotspn fdpotspn
rename w`r'_h_fdvego fdvego
rename w`r'_h_fdvegospn fdvegospn
rename w`r'_h_fdfru fdfru
rename w`r'_h_fdfruspn fdfruspn
rename w`r'_h_fdoil fdoil
rename w`r'_h_fdoilspn fdoilspn
rename w`r'_h_fdmar fdmar
rename w`r'_h_fdmarspn fdmarspn
rename w`r'_h_fdpb fdpb
rename w`r'_h_fdpbspn fdpbspn
rename w`r'_h_fdmlk fdmlk
rename w`r'_h_fdmlkspn fdmlspn
rename w`r'_h_fdegg fdegg
rename w`r'_h_fdeggspn fdeggspn
rename w`r'_h_fdsug fdsug
rename w`r'_h_fdsugspn fdsugspn
rename w`r'_h_fdsd fdsd
rename w`r'_h_fdsdspn fdsdspn
rename w`r'_h_fdfrut fdfrut
rename w`r'_h_fdfrutspn fdfrutspn
rename w`r'_h_fdcer fdcer
rename w`r'_h_fdcerspn fdcerspn
rename w`r'_h_fdbaby fdbaby
rename w`r'_h_fdbabyspn fdbabyspn
rename w`r'_h_fdslt fdslt
rename w`r'_h_fdsltspn fdsltspn
rename w`r'_h_fdsoy fdsoy
rename w`r'_h_fdsoyspn fdsoyspn
rename w`r'_h_fdcof fdcof
rename w`r'_h_fdcofspn fdcofspn
rename w`r'_h_fdhmp fdhmp
rename w`r'_h_fdhmpspn fdhmpspn
rename w`r'_h_fdrdy fdrdy
rename w`r'_h_fdrdyspn fdrdyspn
rename w`r'_h_fdout fdout
rename w`r'_h_fdoutspn fdoutspn
rename w`r'_h_fdo fdo

foreach var of varlist w`r'_h_mrt24mnth w`r'_h_mrtdod_m1 w`r'_h_mrtdod_y1 w`r'_h_mrtdod_m2 w`r'_h_mrtdod_y2 w`r'_h_mrtdod_m3 w`r'_h_mrtdod_y3 w`r'_h_mrtdod_m4 w`r'_h_mrtdod_y4 w`r'_h_mrtdod_m5 w`r'_h_mrtdod_y5 w`r'_h_negdthfmn w`r'_h_negdthfyr w`r'_h_negdthfinc w`r'_h_negdthfrmn w`r'_h_negdthfryr w`r'_h_negdthfrin w`r'_h_negdthomn w`r'_h_negdthoyr w`r'_h_negdthocst {
renpfix w`r'_h_
}


** SCHOOL
rename w`r'_a_edschgrd edu

forvalues z=1/17 {
rename w`r'_a_com`z' com`z'
}

g r=`r'
save hhr_`r'_2, replace
}

w1_h_mrt24mnth w1_h_mrtdod_m1 w1_h_mrtdod_y1 w1_h_mrtdod_m2 w1_h_mrtdod_y2 w1_h_mrtdod_m3 w1_h_mrtdod_y3 w1_h_mrtdod_m4 w1_h_mrtdod_y4 w1_h_mrtdod_m5 w1_h_mrtdod_y5 w1_h_negdthfmn w1_h_negdthfyr w1_h_negdthfinc w1_h_negdthfrmn w1_h_negdthfryr w1_h_negdthfrin w1_h_negdthomn w1_h_negdthoyr w1_h_negdthocst


use hhr_1_2, clear
append using hhr_2_2
append using hhr_3_2


replace elec=. if elec<0
replace elec=0 if elec==2


keep pid hhid edu bdc re_yn re_pid1 re_loc1 re_rel1 re_no1 re_val1 re_pid2 re_loc2 re_rel2 re_no2 re_val2 toi toi_shr ownpaid ownpid district inc h fd r dwell rooms roof walls own mktv lndgrn lndrst ownpid marry_yrs move_yr child home_loan bike flu emo inc_exp5 move_rec com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 crime occ water elec tran wage govt remit food nonfood ag fam size rent urb gender age marry pop_grp emp pay travel health diar t_time_h t_time_m  emp_d hh_income dep exer stay bp inc_exp inc_today religion fwag-remt_flg decd-decsch2 fdmm-fdo

save reg3_1.dta, replace





