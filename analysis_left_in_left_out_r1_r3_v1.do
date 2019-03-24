
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

sort pid r
by pid: g size_ch=size[_n]-size[_n-1]

* hist size_ch if size_ch>-8 & size_ch<8, by(rdp u)
** household statistics
g rdp_u=rdp*u

reg size_ch rdp u inc rooms piped  i.r, robust cluster(hh1)
** Look at size changes: better to do this at the household level

egen m_rdp=mean(rdp), by(hh1 r)

g sw=(m_rdp>0 & m_rdp<1)

replace sw=. if r==1

xtset hh1

sort pid r
foreach var of varlist inc inc_r inc_l fwag cwag swag e ue {
by pid: g `var'_lag=`var'[_n-1]
}


xtreg size rdp if sw==1, fe robust
xtreg size rdp if sw==1 & u==1, fe robust
xtreg size rdp if sw==1 & u==0, fe robust

foreach var of varlist a sex children edu size fwag fwag_lag cwag cwag_lag swag swag_lag e e_lag ue ue_lag inc inc_r inc_g {
xtreg `var' rdp if sw==1, fe robust
}

foreach var of varlist a sex children edu size e e_lag ue ue_lag inc inc_r inc_g exp_f exp_i {
xtreg `var' rdp if sw==1 & u==1, fe robust
xtreg `var' rdp if sw==1 & u==0, fe robust
}

foreach var of varlist a sex children edu size e e_lag ue ue_lag inc inc_r inc_g exp_f exp_i {
xtreg `var' rdp if  u==1, fe robust
xtreg `var' rdp if  u==0, fe robust
}



foreach var of varlist a sex children edu e e_lag ue ue_lag inc inc_r inc_g exp_f exp_i {
xtreg `var' rdp piped elec if sw==1 & u==1, fe robust
xtreg `var' rdp piped elec if sw==1 & u==0, fe robust
}


* the remittance pattern is exceptional!!!

** DETERMINANTS OF SPLITTING: 

use clean_v1.dta, clear

drop if rdp==.
drop if resident==0
egen max_inc=max(inc), by(pid)
drop if max_inc>20000
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace rdp=1 if h_ch_m==-1
drop if r==2
sort pid r
by pid: g size_ch=size[_n]-size[_n-1]
replace piped=1 if piped==2
egen m_rdp=mean(rdp), by(hh1 r)
g sw=(m_rdp>0 & m_rdp<1)
replace sw=. if r==1
replace sex=. if sex==-9
g hoh_sex=hoh*sex
g hoh_edu=hoh*edu
g m_shr=fwag*sex
replace m_shr=m_shr/inc
g oldd=a>65
egen old=sum(oldd), by(hhid)

collapse (max) race (mean) sw m_rdp e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs old , by(r hh1)

sort hh1 r
foreach var of varlist e_hh tsm size a hoh_sex sex children hoh_edu edu e ue own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs old {
by hh1: g `var'_lag=`var'[_n-1]
drop `var'
rename `var'_lag `var'
}

drop if r==1

** LONG-TERM INDIVIDUAL OUTCOMES:
g u_size=u*size

reg sw size u a old children edu piped elec if m_rdp>0, robust



reg sw e_hh old size a hoh_sex sex children hoh_edu edu e ue u inc inc_r if m_rdp>0, robust

own paid_off rooms elec piped exp exp_i exp_f m_shr fwag cwag swag sch_d travel tog inf house inc inc_r inc_l inc_g rdp u hrs old u





