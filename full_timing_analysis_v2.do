
cd "/Users/willviolette/Desktop/pstc_work/nids"

** TAKE A STEP BACK ** THINK ABOUT WHERE THIS TREATMENT IS HAPPENING
**********     DO WE SEE A BIG DIFFERENCE BY INCOME GROUPS??
**********     WHAT CAN WE IDENTIFY AS AN RDP HOUSE??

use hh_v1, clear

keep if sr==321

g i10=inc>10000
g i7=(inc>7000)
g i3_5=inc>3500
g h_g=(h_ch==1)

hist rooms if rooms<10, by(i10 h_g)

hist rooms if rooms<10, by(i3_5 h_g)

hist rooms if rooms<10, by(i7 h_g)

hist toi, by(i3_5 h_g)
hist rooms if rooms<10, by(i3_5 h_g)



** AT THE HOUSEHOLD LEVEL

**********************
** INCOME ATTRIBUTES *
**********************

** DIFF in DIFF **
use hh_v1, clear
keep if max_inc<10000
keep if sr==321
keep if dd!=.
collapse (max) race (mean) e_hh tsm size a sex children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f fwag cwag swag sch_d travel tog marry inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)
keep if rdp==1 | rdp==0

xtset hh1

xtreg marry rdp i.r if u==1, fe robust
xtreg marry rdp i.r if u==0, fe robust

foreach var of varlist e_hh tsm size a children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor fwag cwag swag tog inf house inc inc_r inc_l inc_g {
xtreg `var' rdp i.r if u==1, fe robust
* outreg2 using hh_reg_dd, excel label drop(i.r) nocons
xtreg `var' rdp i.r if u==0, fe robust
* outreg2 using hh_reg_dd, excel label drop(i.r) noco``ns
}

* seeout
foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}
outreg2 [e_*] using hh_reg_dd1, excel replace label drop(i.r) nocons



** LONG RUN **
use hh_v1, clear
keep if sr==321
keep if lt!=.
collapse (max) race (mean) e_hh tsm size a sex children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1

foreach var of varlist e_hh tsm size a children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor fwag cwag swag tog inf house inc inc_r inc_l inc_g {
xtreg `var' rdp i.r if u==1, fe robust
outreg2 using hh_reg_st, excel label drop(i.r) nocons
xtreg `var' rdp i.r if u==0, fe robust
outreg2 using hh_reg_st, excel label drop(i.r) nocons
}
seeout


foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}
outreg2 [e_*] using hh_reg_lt, excel replace label drop(i.r) nocons





** SHORT RUN **
use hh_v1, clear
keep if max_inc<10000
* keep if sr==320 | sr==321 | sr==21
keep if sr==321
keep if st!=.

collapse (max) race (mean) e_hh tsm size a sex children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1

foreach var of varlist e_hh tsm size a children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor fwag cwag swag tog inf house inc inc_r inc_l inc_g {
xtreg `var' rdp i.r if u==1, fe robust
* outreg2 using hh_reg_lt, excel label drop(i.r) nocons
xtreg `var' rdp i.r if u==0, fe robust
* outreg2 using hh_reg_lt, excel label drop(i.r) nocons
}
* seeout


foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp i.r if u==1, fe robust
est sto s_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto s_`var'_r
}

outreg2 [s_*] using hh_reg_st, excel replace label drop(i.r) nocons



**********************
** HOUSE ATTRIBUTES **
**********************

foreach var of varlist rooms elec piped flush mktv walls_b roof_cor size own paid_off {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}
outreg2 [e_*] using hh_char, excel replace label drop(i.r) nocons

*****************************
** INDIVIDUAL DIFF IN DIFF **
*****************************
use hh_v1, clear
estimates clear
drop if max_inc>10000
keep if a>18
keep if sr==321
keep if dd!=.
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)

label variable left_out "Left Out of RDP"

xtset pid

foreach var of varlist e ue fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp left_out i.r, fe robust cluster(hh1)
est sto e_`var'_total
xtreg `var' rdp left_out i.r if sex==1, fe robust cluster(hh1)
est sto e_`var'_men
xtreg `var' rdp left_out i.r if sex==0, fe robust cluster(hh1)
est sto e_`var'_women
xtreg `var' rdp left_out i.r if u==1, fe robust cluster(hh1)
est sto e_`var'_urban
xtreg `var' rdp left_out i.r if u==0, fe robust cluster(hh1)
est sto e_`var'_rural
}
drop _est
* * SOME ACTION BUT VERY LITTLE HONESTLY

outreg2 [e_* ] using ind_reg, excel replace label drop(i.r) nocons


*****************************
** INDIVIDUAL SHORT TERM   **
*****************************
use hh_v1, clear
drop if max_inc>10000
keep if a>18
keep if sr==320 | sr==321 | sr==21
* keep if sr==321
keep if st!=.
* * * Focus on the left_out! the poorest segments also!
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1

label variable left_out "Left Out of RDP"

xtset pid

foreach var of varlist e ue cwag swag fwag inf size children rent mktv {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
}


foreach var of varlist e ue cwag swag fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
* est sto e_`var'_total
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
* est sto e_`var'_men
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
* est sto e_`var'_women
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
* est sto e_`var'_urban
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
* est sto e_`var'_rural
}
* drop _est



** different amount of observations
use hh_v1, clear
estimates clear

keep if max_inc<10000

keep if a>18

keep if sr==321

keep if st!=.

* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)

label variable left_out "Left Out of RDP"


xtset pid

foreach var of varlist e ue fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp left_out i.r, fe robust cluster(hh1)
* est sto e_`var'_total
xtreg `var' rdp left_out i.r if sex==1, fe robust cluster(hh1)
* est sto e_`var'_men
xtreg `var' rdp left_out i.r if sex==0, fe robust cluster(hh1)
* est sto e_`var'_women
xtreg `var' rdp left_out i.r if u==1, fe robust cluster(hh1)
* est sto e_`var'_urban
xtreg `var' rdp left_out i.r if u==0, fe robust cluster(hh1)
* est sto e_`var'_rural
}

* * * THERE IS STUFF HAPPENING ON THE LEFT-OUT MARGIN


********* TOTAL OBSERVATIONS ***********************
** Use THE FULL SET OF OBSERVATIONS
use hh_v1, clear

keep if max_inc<10000

keep if a>18

* keep if sr==321

keep if tt!=.

* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
g left_out_m=left_out*move
g left_out_n=left_out
replace left_out_n=0 if move==1

* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1
g left_in_m=left_in*move
g left_in_n=left_in
replace left_in_n=0 if move==1

g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

xtset pid

foreach var of varlist  size {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist  *_per rent own own_d e ue {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
}

foreach var of varlist  *_per rent own e ue {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist cwag swag fwag rent_d own {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf size children rent mktv {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}




xtset pid

foreach var of varlist *_per rent own e ue cwag swag fwag {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
}
* * income per capita goes up for those that are left_out
* income per capita doesn't really change for those that benefit
* interestingly R per capita doesn't change for those left in
* * * does the source of remittance change??


xtset pid

foreach var of varlist e ue cwag swag fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf size children rent mktv {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
}



****************************************************
** ALSO NEED MORE FULL UNDERSTANDING OF SPLITTING **
****************************************************
* just look at splitting in total:
* * * as if to say, when you get a house
* * * is fundamentally different from normal splitting
* * * how to frame as an exogenous shock to family splitting?
* * * control for services ???

* * CHECK RENT! expect to see left_out's paying less rent


****************************************************
** ALSO NEED MORE FULL UNDERSTANDING OF SPLITTING **
****************************************************

*** need to dig into theory
* say ok; household's split, but it doesn't affect welfare?

* include zeros in the wages??

* get into urban / rural differences in RDP housing?
*    look at income censored incomes..



**********************************
** LEFT-IN/LEFT-OUT REGRESSIONS **
**********************************

use hh_v1, clear
drop if max_inc>10000
keep if a>18
keep if sr==320 | sr==321 | sr==21
* keep if sr==321
keep if st!=.
* * * Focus on the left_out! the poorest segments also!
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1





