

cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** treat them as still treated
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=max(h_ch), by(pid)
* replace rdp=1 if h_ch_m==-1
drop if h_ch_m==-1


*** GET RID OF ROUND 2
drop if r==2

** piped cleaning
replace piped=1 if piped==2

** clean wages
replace fwag=. if fwag_flg>1
replace cwag=. if cwag_flg>1
replace swag=. if swag_flg>1

replace sex=. if sex==-9

g hoh_sex=hoh*sex

g hoh_edu=hoh*edu

* men's share of income
g m_shr=fwag*sex
replace m_shr=m_shr/inc

g oldd=a>65
egen old=sum(oldd), by(hhid)


collapse (max) race (mean) e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs old, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1

* foreach var of varlist size a sex children edu e ue own paid_off fwag cwag swag inc inc_r inc_l inc_g tsm e_hh old {
* xtreg `var' rdp i.r, fe robust
* xtreg `var' rdp i.r if u==1, fe robust
* xtreg `var' rdp i.r if u==0, fe robust
* }

** HOUSEHOLD EMMPLOYMENT
* nothing
** TSM
* increase rural
** GOV INCOME
* nothing

** LABOR INCOME
* rural labor income rises
* urban labor income drops
* labor income overall drops

** REMITTANCES
* rural remittances drop

** TOTAL INCOME
* urban and overall drop
** SELF AND FORMAL LABOR INCOME
* drop for urban areas especially 
** UNEMPLOYMENT AND EMPLOYMENT
* nothing
** EDUCATION
* nothing
** CHILDREN
* increase in rural areas and overall
** SEX
* more men in rural areas
** AGE
* nothin really
** SIZE
* rural areas increase
* urban areas don't

* xtreg `var' rdp i.r, fe robust
* est sto `var'_t

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



** DO THESE RESULTS CHANGE WHEN WE INCLUDE SPLIT HHs?



cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0


*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** treat them as still treated
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace rdp=1 if h_ch_m==-1

*** GET RID OF ROUND 2
drop if r==2

** piped cleaning
replace piped=1 if piped==2

** clean wages
replace fwag=. if fwag_flg>1
replace cwag=. if cwag_flg>1
replace swag=. if swag_flg>1

replace sex=. if sex==-9

g hoh_sex=hoh*sex

g hoh_edu=hoh*edu

* men's share of income
g m_shr=fwag*sex
replace m_shr=m_shr/inc

collapse (max) race (mean) e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)

* keep if rdp==1 | rdp==0

xtset hh1

foreach var of varlist size a sex children edu e ue own paid_off fwag cwag swag inc inc_r inc_l inc_g tsm e_hh {
xtreg `var' rdp i.r, fe robust
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}











