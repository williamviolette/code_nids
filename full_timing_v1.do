
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear
** assign people to a household
drop if resident==0

g rdp1=rdp
egen rm=max(rdp), by(pid)

*************
** FIX RDP **
*************
** could do a more careful job of making sure these are rdps!
sort pid r
by pid: g rdp_l1=rdp[_n+1]
by pid: g rdp_l2=rdp[_n+2]
by pid: g rdp_lg1=rdp[_n-1]
by pid: g rdp_lg2=rdp[_n-2]

* 1.) missing in round 1, take the value of round 2, then of round 3
replace rdp=rdp_l1 if r==1 & rdp==.
replace rdp=rdp_l2 if r==1 & rdp==.

* 2.) missing in round 2, take value of round 3
replace rdp=rdp_lg1 if r==2 & rdp==.

* 3.) missing in round 3, take value of round 2, then of round 1
replace rdp=rdp_lg1 if r==3 & rdp==.
replace rdp=rdp_lg2 if r==3 & rdp==.

** only look at housing responses
drop if rdp==.

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** keep only respondents that responded in all 3 waves
g r1=r if r==1
replace r1=r*10 if r==2
replace r1=r*100 if r==3
egen sr=sum(r1), by(pid)
* keep if sum_r==6
** drops 18,000 obs

*************************
** HOUSEHOLD LONG-TERM **
*************************
*** drop if lose rdp or gain rdp in 3rd period
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=min(h_ch), by(pid)
g h_ch_r3=h_ch if r==3
egen h_ch_r3_m=max(h_ch_r3), by(pid)

g lt=rdp
replace lt=. if h_ch_m==-1
replace lt=. if h_ch_r3_m==1
replace lt=. if r==2

*************************
* HOUSEHOLD SHORT-TERM **
*************************
*** if gain rdp in 2nd period drop 3rd period observation 
g h_ch_r2=h_ch if r==2
egen h_ch_r2_m=max(h_ch_r2), by(pid)

g st=rdp
replace st=. if h_ch_m==-1
replace st=. if h_ch_r2_m==1 & r==3

***************************
* HOUSEHOLD DIFF IN DIFF **
***************************
*** if gain rdp in 2nd period drop 3rd period observation 

g dd=rdp
replace dd=. if h_ch_m==-1
replace dd=. if r==2

save hh_v1, replace



