
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** get rid of those already with houses
g rdp_r1=(r==1 & rdp==1)
egen rdp_r1_max=max(rdp_r1), by(pid)
drop if rdp_r1_max==1

g rdp_r2=(r==2 & rdp==1)
egen rdp_r2_max=max(rdp_r2), by(pid)

** include third round house as treatment
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
by pid: g size_ch=size[_n]-size[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace h_ch_m=1 if h_ch_m==-1
replace rdp=1 if h_ch_m==1 & r==3

* hist size_ch if size_ch>-8 & size_ch<8, by(rdp u)
** household statistics
g rdp_u=rdp*u

reg size_ch rdp u rdp_u i.r, robust

replace sex=. if sex==-9

g hoh_sex=hoh*sex

g hoh_edu=hoh*edu

* men's share of income
g m_shr=fwag*sex
replace m_shr=m_shr/inc

collapse (max) race (mean) e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1

foreach var of varlist size a sex children edu e ue own paid_off fwag cwag swag inc inc_r inc_l inc_g tsm e_hh {
xtreg `var' rdp i.r, fe robust
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}


** HOUSEHOLD EMPLOYMENT
* nothing
** TSM 
* urban increase
** GOVERNMENT INCOME
* nothing
** LABOR INCOME
* nothing
** REMITTANCE
* nothing
** INCOME / WAGES
* nothing
** PAID OFF
* higher in rural areas, lower in urban areas, pretty interesting..
* ownership, increases
** UNEMPLOYMENT
* higher in urban areas, as people look for jobs
* doesn't show up in wages yet
** EMPLOYMENT 
* nothing
** EDUCATION (average)
* higher in urban areas
** CHILDREN
* more children
** rural young men
** SIZE
* increases in urban areas

foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp piped elec flush i.r if u==1, fe robust
est sto ee_`var'_u
xtreg `var' rdp piped elec flush i.r if u==0, fe robust
est sto ee_`var'_r
}

outreg2 [ee_*] using hh_reg_ee, excel replace label drop(i.r) nocons


foreach var of varlist race size a sex children hoh_edu edu e ue own paid_off rooms piped fwag cwag swag m_shr inc inc_r inc_l inc_g tsm e_hh {
xtreg `var' rdp i.r, fe robust
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}
* greater tsm so that's a good sign..

foreach var of varlist race size a sex children hoh_edu edu e ue own paid_off fwag cwag swag m_shr inc inc_r inc_l inc_g tsm {
xtreg `var' rdp rooms elec piped inf house i.r, fe robust
xtreg `var' rdp rooms elec piped inf house i.r if u==1, fe robust
xtreg `var' rdp rooms elec piped inf house i.r if u==0, fe robust
}
* not much goin on, hard to get at the interesting stuff



