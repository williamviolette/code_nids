
* presentation


cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear
** LOOK AT UPGRADES IN ROUND 3
* SAVINGS = INCOME - EXPENDITURES
** look at geographic variation
** do the CAPS

** only look at adults
keep if a>18

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


** child per person
g kids_r=children/size

** piped cleaning
replace piped=1 if piped==2

** clean wages
replace fwag=. if fwag_flg>1
replace cwag=. if cwag_flg>1
replace swag=. if swag_flg>1

* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)

label variable left_out "Left Out of RDP"


xtset pid

foreach var of varlist e fwag inf {
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

outreg2 [e_*] using ind_reg, excel replace label drop(i.r) nocons







