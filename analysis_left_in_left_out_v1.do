
cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

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
by pid: g size_ch=size[_n]-size[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace h_ch_m=1 if h_ch_m==-1
replace rdp=1 if h_ch_m==1 & r==3


* hist size_ch if size_ch>-8 & size_ch<8, by(rdp u)
** household statistics
g rdp_u=rdp*u

reg size_ch rdp u rdp_u i.r, robust

* average size_ch is larger! than when households get RDP assistance

egen m_rdp=mean(rdp), by(hh1 r)

g sw=(m_rdp>0 & m_rdp<1)

replace sw=. if r==1

xtset hh1

sort pid r
foreach var of varlist inc inc_r inc_l fwag cwag swag e ue {
by pid: g `var'_lag=`var'[_n-1]
}

foreach var of varlist a sex children edu fwag cwag swag e ue fwag_lag cwag_lag swag_lag e_lag ue_lag {
xtreg `var' rdp i.r if sw==1, fe robust
}



** fix this regression????

foreach var of varlist a sex children edu fwag cwag swag fwag_lag cwag_lag swag_lag {
xtreg `var' rdp i.r if sw==1 & u==1, fe robust
xtreg `var' rdp i.r if sw==1 & u==0, fe robust
}








