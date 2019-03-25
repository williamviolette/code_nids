

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>13000
	replace size_lag=. if size_lag>14
	
	sort pid r
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	
	** fiddle with main specification
	
	tab inc_m h_ch if a<=16
	tab inc_m if a<=16 & h_ch==1
	tab size_lag h_ch if a<=16
*	hist inc_m if a<=16 & h_ch==1
	
	foreach var of varlist zhfa zwfa c_ill c_health {
	xi: reg `var'_ch a i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	}
	
	
	foreach var of varlist zhfa zwfa c_ill c_health {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
	

	g a_7=a<=7
	
	g h_ch7=h_ch*a_7
	
	g hn=h_ch
	replace hn=0 if a_7==1
	
	foreach var of varlist zhfa zwfa c_ill c_health {
	xi: reg `var'_ch i.h_ch7*size_lag i.h_ch*size_lag a i.r, robust cluster(hh1)
	}
	

	foreach var of varlist zhfa zwfa {
	xi: reg `var'_ch i.h_ch7*size_lag i.hn*size_lag a sex i.r, robust cluster(hh1)
	}
	
	
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>13000
	replace size_lag=. if size_lag>14
	
	sort pid r
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	
	* try dob *
	g dob=2008-a if r==1
	replace dob=2010-a if r==2
	replace dob=2012-a if r==3
	
	foreach var of varlist zhfa zwfa {
	xi: reg `var'_ch i.h_ch*size_lag i.r if dob>=2004, robust cluster(hh1)
	}
	
	
	g dob2=dob>=2000
	
	g h_ch2=h_ch*dob2
	
	g h_chn2=h_ch
	replace h_chn2=0 if dob2==1
	
	foreach var of varlist zhfa zwfa {
	xi: reg `var'_ch i.h_ch2*size_lag i.h_chn2*size_lag a i.r, robust cluster(hh1)
	}
	
	
	 
	
	
	



