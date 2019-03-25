
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	quietly neighborhood_psychological
	quietly adult_health
	quietly alt_measures
	quietly left_out
	quietly crowding
end


program define crowding
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a "10"
	global s "16"
	global im "3500"
	
	sum size_lag if  hclust>=5 & im<=$im & a<$a & zhfa_ch<2 & zhfa_ch>-2 & h_ch==1, detail
	
	tab  size_lag if  hclust>=5 & im<=$im & a<$a & zhfa_ch<2 & zhfa_ch>-2 & h_ch==1


	xi: reg zhfa_ch h_ch h_ch_large  m_ch m_ch_large large a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-2 & size_lag>1, robust cluster(hh1)	
	
	xi: reg zwfa_ch h_ch h_ch_large  m_ch m_ch_large large  a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>1, robust cluster(hh1)	

	xi: reg zbmi_ch h_ch h_ch_large  m_ch m_ch_large large  a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>1, robust cluster(hh1)	


	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label replace nocons  addtext(Treated Area, Over 5)		
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	

end
		


program define left_out
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a1 "10"
	global s "12"
	global im "3500"
	
	hist size_lag if size_lag<12 & (h_ch==1 | lo==1), by(lo)
	
	hist a if size_lag<12 & (h_ch==1 | lo==1), by(large lo)
		* not an even split of the family! *
				* what kind of split? *
end 

program define neighborhood_psychological

	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a1 "10"
	global s "12"
	global im "3500"
	
	foreach var of varlist a_weight_1 a_weight_2 a_weight_3 h_nbhlp h_nbtog h_nbagg h_nbthf h_nbthmf h_freqdomvio h_freqvio h_freqgang h_freqmdr h_freqdrug a_emobth a_emomnd a_emodep a_emoeff a_emohope a_emofear a_emoslp a_emohap a_emolone a_emogo {
*	tab `var' r, nolabel
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach v in h_freqdomvio h_freqvio h_freqgang h_freqmdr h_freqdrug {
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large i.r if im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	}
	
	foreach v in a_emobth a_emomnd a_emodep a_emoeff a_emohope a_emofear a_emoslp a_emohap a_emolone a_emogo {
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large i.r if im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	}
	
	xi: reg h_freqdomvio_ch H_* sl_* mm_* i.r if im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(H_*)		
	xi: reg h_freqvio_ch H_* sl_* mm_* i.r if im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg h_freqgang H_* sl_* mm_* i.r if im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
end	


program define adult_health

	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a1 "10"
	global s "12"
	global im "3500"
		
	* look at adult weight! 
	
	g weight=a_weight_1
	replace weight=(a_weight_1+a_weight_2)/2 if a_weight_2!=.
	replace weight=a_weight_2 if a_weight_1==.
	sort pid r
	by pid: g weight_ch=weight[_n]-weight[_n-1]	
	by pid: g weight_lag=weight[_n-1]
	g weight_lag_2=weight_lag*weight_lag
	
	g height=a_height_1
	replace height=(a_height_1+a_height_2)/2 if a_height_2!=.
	replace height=a_height_2 if a_height_1==.
	sort pid r
	by pid: g height_ch=height[_n]-height[_n-1]	
	by pid: g height_lag=weight[_n-1]
	g height_lag_2=height_lag*height_lag
	
	foreach var of varlist height weight {
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}	
				
	foreach v in weight {
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large `v'_p* i.r i.sex*a if a>16 & a<30 & im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large `v'_p* i.r i.sex*a if a>16 & a<30 & im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large `v'_p* i.r i.sex*a if a>=30 & a<50 & im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	xi: reg `v'_ch h_ch h_ch_large large m_ch m_ch_large `v'_p* i.r i.sex*a if a>=50 & a<70 & im<=$im & hclust>=5 & size_lag<12, robust cluster(hh1) 	
	}

end	

			
* also explore left out


* also explore more deeply family patterns
	
	
	
	
program define alt_measures
	
	use clean/data_analysis/regs_nate_tables_3_6, clear

	global a1 "10"
	global s "12"
	global im "3500"
		
	foreach var of varlist c_weight_1 c_weight_2 c_height_1 c_height_2 {
	replace `var'=. if `var'<0
	}

	g c_weight=c_weight_1
	replace c_weight=(c_weight_1+c_weight_2)/2 if c_weight_2!=.
	replace c_weight=c_weight_2 if c_weight_1==.
	sort pid r
	by pid: g c_weight_ch=c_weight[_n]-c_weight[_n-1]	
	by pid: g c_weight_lag=c_weight[_n-1]
	g c_weight_lag_2=c_weight_lag*c_weight_lag
	
	g c_height=c_height_1
	replace c_height=(c_height_1+c_height_2)/2 if c_height_2!=.
	replace c_height=c_height_2 if c_height_1==.
	sort pid r
	by pid: g c_height_ch=c_height[_n]-c_height[_n-1]	
	by pid: g c_height_lag=c_height[_n-1]
	g c_height_lag_2=c_height_lag*c_height_lag	
	
	
	foreach var of varlist c_height c_weight {
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}

	xi: reg c_weight_ch h_ch h_ch_large large m_ch m_ch_large c_weight_p* i.r i.sex*a if c_weight_ch>-40 & c_weight_ch<40 & a<10 & im<=$im & hclust>=5 & size_lag<10 & size_lag>2, robust cluster(hh1) 	
	xi: reg c_height_ch h_ch h_ch_large large m_ch m_ch_large c_height_p* i.r i.sex*a if c_height_ch>-20 & c_height_ch<20 & a<10 & im<=$im & hclust>=5 & size_lag<10 & size_lag>2, robust cluster(hh1) 	
	
end					
			
		
