* p trends


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

sort pid r
by pid: g h_sw=h_ch[_n+1]

** focus on second round, people without rdp
keep if r<=2 & rdp==0
drop rdp
egen rdp=max(h_sw), by(hhid)

collapse rdp edu a sex children size af inc e ue rooms piped elec inf, by(hh1 r u)

foreach var of varlist a sex edu children size af inc e ue rooms piped elec inf {
sort hh1 r
by hh1: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}

label variable rdp "RDP"

reg rdp a sex edu children size inc e ue rooms piped elec inf if u==1, robust
est sto Urban
reg rdp a sex edu children size inc e ue rooms piped elec inf if u==0, robust
est sto Rural

outreg2 [Urban Rural] using parallel_trends, excel replace nocons label 


