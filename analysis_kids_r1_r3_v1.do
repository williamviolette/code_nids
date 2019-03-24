
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
* drop if resident==0

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

replace c_edu=. if c_edu<0
replace c_edu=0 if c_edu<7
replace c_edu=1 if c_edu==7

duplicates drop pid r, force
xtset pid


xtreg c_edu rdp i.r if a<20, fe robust cluster(hh1)
* nothing

xtreg c_fees rdp i.r if a<20, fe robust cluster(hh1)

xtreg sch_d rdp i.r if a<20, fe robust cluster(hh1)




