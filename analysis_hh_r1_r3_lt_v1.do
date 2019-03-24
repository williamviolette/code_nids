

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
g h_ch_r3=h_ch if r==3
egen h_ch_mr3=max(h_ch_r3), by(pid)
drop if h_ch_mr3==1
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


collapse (max) race (mean) e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs old, by(r hh1)

keep if rdp==1 | rdp==0

xtset hh1


* household characteristics


foreach var of varlist size a children e inc inc_l inc_r {
xtreg `var' rdp i.r if u==1, fe robust
est sto e_`var'_u
xtreg `var' rdp i.r if u==0, fe robust
est sto e_`var'_r
}
outreg2 [e_*] using hh_lt, excel replace label drop(i.r) nocons

