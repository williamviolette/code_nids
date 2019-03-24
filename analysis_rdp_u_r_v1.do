
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

sort pid r
by pid: g rdp_ch=rdp[_n]-rdp[_n-1]
replace rdp_ch=0 if rdp_ch==-1
replace rdp=1 if rdp_ch==-1

xtset pid
foreach var of varlist theft domvio vio gang murder drug {
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}
** worse neighborhoods..

** COMPARE RDP HOUSES IN URBAN AND RURAL AREAS

** FIRST: JUST OVERALL RDP HOUSES
* keep if rdp==1

keep rdp rdp_ch roof_cor walls_b flush piped elec rooms rent rentv mktv bond train wdist bus mini theft domvio vio gang murder drug u

bys u rdp: outreg2 using rdp_u_r, sum(log) eqkeep(mean N)  label excel replace 

drop if rdp_ch==.
bys u rdp_ch: outreg2 using rdp_ch_u_r, sum(log) eqkeep(mean N)  label excel replace 
