
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
* drop if resident==0

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
egen h_ch_m=max(h_ch), by(pid)
replace h_ch_m=1 if h_ch_m==-1
replace rdp=1 if h_ch_m==1 & r==3


replace c_edu=. if c_edu<0
replace c_edu=0 if c_edu<7
replace c_edu=1 if c_edu==7

xtset pid


xtreg c_edu rdp i.r if a<10, fe robust cluster(hh1)

* strongly increases likelihood of absence?
xtreg c_fees rdp i.r if a<20, robust cluster(hh1)
xtreg c_fees rdp i.r if a<20, fe robust cluster(hh1)

xtreg sch_d rdp i.r if a<20, robust cluster(hh1)
xtreg sch_d rdp i.r if a<20, fe robust cluster(hh1)

** unaffected




