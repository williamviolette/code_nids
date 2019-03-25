
	
	clear all
	set mem 4g
	set maxvar 10000
	set matsize 4000

	cd "/Users/willviolette/Desktop/pstc_work/nids"

	*** SERVICES MECHANISM ***
	
	use clean/data_analysis/regs_nate_tables_3_3, clear	
*	drop if rent_d==1 & h_ch==1
	drop inc_ad im
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	egen hclust=sum(h_chi), by(cluster)

	* move variables		
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	g m_ch_at_7_18=m_ch*at_7_18
	g m_ch_at_60=m_ch*at_60
	g m_ch_sl_at_7_18=m_ch_sl*at_7_18
	g m_ch_sl_at_60=m_ch_sl*at_60
	
	g ele=1 if h_nfelespn>0 & h_nfelespn<.
	replace ele=0 if h_nfelespn==0
	g wat=1 if h_nfwatspn>0 & h_nfwatspn<.
	replace wat=0 if h_nfwatspn==0
	
	sort pid r
	foreach var of varlist ele wat {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
	sort pid r
	foreach var of varlist h_chi h_chn  {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
	replace m_ch=. if r==1
	
		sort pid r
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
	
		* sanity test with interactions ! *
		replace c_absent=. if c_absent==0
		
		sort pid r
		by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
		replace c_waist_1=. if c_waist_1<0
		by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]		
	
	* sanity test ! *
		* these work * * * h_nfwatspn_ln h_nfelespn_ln piped flush rooms
		* unbelievably zero change here : pi_hhincome_ln pi_hhwage_ln pi_hhgovt_ln pi_hhremitt_ln 
		* also nothing: c_absent c_failed
	
	** flexible lag controls **
	sort pid r
	foreach var of varlist zwfa zhfa zbmi {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}
	
	global a1 "100"
	global a "10"
	global s "11"
	global im "5000"
	
	tab h_chi_sl if im<=$im & hclust>=10 & a<$a1 & h_chi_sl>0 & size_lag<18
	tab h_chn_sl if im<=$im & hclust>=10 & a<$a1 & h_chn_sl>0 & size_lag<18
		* trim the top 5% of size to deal with outliers
	
	** SIZE TIME **
	foreach var of varlist size {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if im<=$im & hclust>=5 & a<$a1 & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=$im & hclust>=10 & a<$a1 & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=$im & hclust>=20 & a<$a1 & size_lag<$s, robust cluster(hh1)
	}	
		* relatively stable * relatively even between kids and adults
	
	** WEIGHT AND HEIGHT **
	* most simple
	
		* odd results for zwfa zhfa zbmi
		
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch h_ch a sex i.r `var'_p*  if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch a sex i.r `var'_p*  if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch a sex i.r `var'_p*  if im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}		
	
	* incumbents and size
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	


	* just size
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
		* control for the lags
			* quadratic
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag `var'_lag_2 i.r if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex `var'_lag `var'_lag_2  i.r if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag `var'_lag_2 i.r if im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
	
			* percentile
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_p* i.r if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex `var'_p*   i.r if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_p*  i.r if  im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
			* percentile
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	


			* only below 0 * with lag controls
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag `var'_lag_2 i.r if `var'_lag<0 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex `var'_lag `var'_lag_2 i.r if `var'_lag<0 &  im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag  `var'_lag_2 i.r if `var'_lag<0 &  im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
			* only below 0 * without lag controls
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if `var'_lag<0 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if `var'_lag<0 &  im<=$im & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if `var'_lag<0 &  im<=$im & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	

		* get stuff for height, what about weight?

