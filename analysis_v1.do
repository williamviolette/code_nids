
* analysis time


cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at adults
keep if a>18

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>10000

*** get rid of those already with houses
g rdp_r1=(r==1 & rdp==1)
egen rdp_r1_max=max(rdp_r1), by(pid)
drop if rdp_r1_max==1

g rdp_r2=(r==2 & rdp==1)
egen rdp_r2_max=max(rdp_r2), by(pid)

** include third round house as treatment
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace h_ch_m=1 if h_ch_m==-1
replace rdp=1 if h_ch_m==1 & r==3


** child per person
g kids_r=children/size

** piped cleaning
replace piped=1 if piped==2

** clean wages
replace fwag=. if fwag_flg>1
replace cwag=. if cwag_flg>1
replace swag=. if swag_flg>1


g r4_5=(rooms==4 | rooms==5)
replace r4_5=. if rooms==.
g mk20=(mktv>14000 & mktv<25000)
replace mk20=. if mktv==.

g rdp_r4_5=rdp*r4_5
g rdp_mk20=rdp*mk20

g r4_5mk20=r4_5*mk20
g rdp_r4_5mk20=rdp*r4_5*mk20


xtset pid

** FIRST LOOK AT EMPLOYMENT
xtset pid

xtreg e rdp i.r, fe robust cluster(hh1)
xtreg e rdp i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp i.r if u==1, fe robust cluster(hh1)
xtreg e rdp i.r if u==0, fe robust cluster(hh1)

xtreg e rdp piped elec i.r, fe robust cluster(hh1)
xtreg e rdp piped elec i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp piped elec i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp piped elec i.r if u==1, fe robust cluster(hh1)
xtreg e rdp piped elec i.r if u==0, fe robust cluster(hh1)

xtreg e rdp r4_5mk20 rdp_r4_5mk20 i.r, fe robust cluster(hh1)
xtreg e rdp r4_5mk20 rdp_r4_5mk20 i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp r4_5mk20 rdp_r4_5mk20 i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp r4_5mk20 rdp_r4_5mk20 i.r if u==1, fe robust cluster(hh1)
xtreg e rdp r4_5mk20 rdp_r4_5mk20 i.r if u==0, fe robust cluster(hh1)

xtset pid

xtreg ue rdp i.r, fe robust cluster(hh1)
xtreg ue rdp i.r if sex==1, fe robust cluster(hh1)
xtreg ue rdp i.r if sex==0, fe robust cluster(hh1)
xtreg ue rdp i.r if u==1, fe robust cluster(hh1)
xtreg ue rdp i.r if u==0, fe robust cluster(hh1)

xtreg size rdp i.r, fe robust cluster(hh1)
xtreg size rdp i.r if sex==1, fe robust cluster(hh1)
xtreg size rdp i.r if sex==0, fe robust cluster(hh1)
xtreg size rdp i.r if u==1, fe robust cluster(hh1)
xtreg size rdp i.r if u==0, fe robust cluster(hh1)

foreach var of varlist inc inc_r inc_l inc_g rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}

** TRY NEW RDP DEFINITIONS
foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp r4_5 rdp_r4_5 i.r, fe robust cluster(hh1)
xtreg `var' rdp r4_5 rdp_r4_5 i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp r4_5 rdp_r4_5 i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp r4_5 rdp_r4_5 i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp r4_5 rdp_r4_5 i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp r4_5mk20 rdp_r4_5mk20 i.r, fe robust cluster(hh1)
xtreg `var' rdp r4_5mk20 rdp_r4_5mk20 i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp r4_5mk20 rdp_r4_5mk20 i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp r4_5mk20 rdp_r4_5mk20 i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp r4_5mk20 rdp_r4_5mk20 i.r if u==0, fe robust cluster(hh1)
}



foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if u==0, fe robust cluster(hh1)
}


foreach var of varlist hrs hrs_s hrs_c {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}


g rdp_size=rdp*size

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag swag exp_i exp_f {
xtreg `var' rdp size rdp_size piped elec rooms i.r, fe robust cluster(hh1)
xtreg `var' rdp size rdp_size piped elec rooms i.r if u==1, fe robust cluster(hh1)
}

** EXPENDITURE
* increase in urban

** WAGES
* reduction in cas wage for women, not much else..

** REMITTANCES
* Drop a lot

** INCOME
* unchanged: remittances drop though? how to think about this?

** how to think about adjustment period?
