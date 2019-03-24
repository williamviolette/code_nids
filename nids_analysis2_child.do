cd "/Users/willviolette/Desktop/pstc_work/nids"


use "nids_analysis1_child_edit2.dta", clear

tab lo u

foreach var of varlist child size fam m_age {
xtreg `var' h lo li i.r, fe robust
}
* left in are younger, size increases (splitting aren't affected differently)
* children increases, but allocates to left_out, counterintuitively

foreach var of varlist child size fam m_age {
xtreg `var' h lo li i.r if u==1, fe robust
}
* age differences don't exist! increase in hh size goes to h
* * * sharing of services!

foreach var of varlist child size fam m_age {
xtreg `var' h lo li i.r if u==0, fe robust
}
* * * younger, big families, more kids

* REMIT
foreach var of varlist remit remit_id {
xtreg `var' h lo li i.r, fe robust
}
foreach var of varlist remit remit_id {
xtreg `var' h lo li i.r if u==1, fe robust
}
foreach var of varlist remit remit_id {
xtreg `var' h lo li i.r if u==0, fe robust
}
** ** DECENT DECREASE IN REMITTANCES


** CHILDREN **
** LEFT-IN
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h lo li i.r, fe robust
}
* * on average child health improves and distance to school improves * GOOD SIGNS

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h lo li i.r if u==1, fe robust
}
* urban areas, the time to school drops a lot
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h lo li i.r if u==0, fe robust
}
* rural areas, less repeat grades for kids
** left in kids health could get worse because young parents without cash

*** WAGES TIME

foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h li lo i.r, fe robust
}
** ** ** wage reduction *(greater for those left out?!)
* left-out: less expenditure on food; household income drops, more for those left-out

* lower main_wage, lower occ_elem

foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h li lo i.r if u==1, fe robust
}
*** left_in are having much more employment: left_out are having great expectations
** ** ** basically nothing but bad for h

foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h li lo i.r if u==0, fe robust
}

* way worse expectations for employment, and employment options

** HOUSE CHARACTERISTICS
foreach var of varlist bp roof_iron walls_brick own rent_1 mktv piped elec crime rent inf {
xtreg `var' h li lo i.r, fe robust
}

foreach var of varlist bp roof_iron walls_brick own rent_1 mktv piped elec crime rent inf {
xtreg `var' h li lo i.r if u==1, fe robust
}

foreach var of varlist bp roof_iron walls_brick own rent_1 mktv piped elec crime rent inf {
xtreg `var' h li lo i.r if u==0, fe robust
}

foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv lo li i.r if hh_income<15000 & u==1, fe robust
}





