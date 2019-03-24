
cd "/Users/willviolette/Desktop/pstc_work/nids"


**********************
** HOUSE ATTRIBUTES **
**********************
use hh_v1, clear

foreach var of varlist rooms elec piped flush mktv walls_b roof_cor size own paid_off {
egen `var'_me=mean(`var'), by(hh1 r)
}

xtset hh1

foreach var of varlist rooms elec piped flush mktv walls_b roof_cor size own paid_off {
xtreg `var'_me rdp i.r if u==1 & lt!=., fe robust
est sto `var'ul_
xtreg `var'_me rdp i.r if u==0 & lt!=., fe robust
est sto `var'rl_
xtreg `var'_me rdp i.r if u==1 & st!=., fe robust
est sto `var'us_
xtreg `var'_me rdp i.r if u==0 & st!=., fe robust
est sto `var'rs_
}

outreg2 [est_*] using hh_char, excel replace label drop(i.r) nocons



**********************
** INCOME ATTRIBUTES **
**********************

use hh_v1, clear

keep if lt!=.

collapse (max) race (mean) e_hh tsm size a sex children edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1


foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}

label variable a "Age"
label variable rdp "RDP"
label variable size "Size"
label variable children "Children"
label variable u "Urban"
label variable e "Employed"
label variable inc_r "Remittances"
label variable inc_l "Labor Income"
label variable inc "Household Income"

outreg2 [e_*] using hh_reg, excel replace label drop(i.r) nocons




foreach var of varlist rooms elec piped flush mktv walls_b roof_cor size own paid_off {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}
outreg2 [e_*] using hh_char, excel replace label drop(i.r) nocons







