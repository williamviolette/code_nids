
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

g rdp1=rdp
sort pid r
by pid: g rdp_ch=rdp[_n]-rdp[_n-1]
replace rdp1=2 if rdp_ch==1
drop rdp_ch

label variable rdp1 "RDP"

label define rdpp 0 "No RDP" 1 "RDP" 2 "Move into RDP"
label values rdp1 rdpp

keep rdp1 a size af children edu inc piped elec rooms u

bys rdp1: outreg2 using sum_1, sum(log) eqkeep(mean N)  label excel replace 



use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

g rdp1=rdp
sort pid r
by pid: g rdp_sw=rdp[_n+1]-rdp[_n]
drop if rdp_sw==-1
drop if rdp_sw==.

keep rdp_sw rdp a size af children edu inc piped elec rooms u

bys rdp_sw u: outreg2 using sum_2_final, sum(log) eqkeep(mean N) label excel replace 




