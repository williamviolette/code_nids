
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	quietly sum_rdp_numbers
	quietly clean_data1
	quietly label_variables
	quietly figure_1_rooms_distribution
	quietly figure_2_rooms_t
	quietly summary_stats
*	quietly first_stage
	quietly house_quality
	quietly analysis
	quietly income
	quietly exp
	quietly robustness
	quietly parallel_trends
	quietly non_resident_children
	use clean/data_analysis/regs_nate_tables_3_6, clear
end


program define summary_stats
	use clean/data_analysis/regs_nate_tables_3_6, clear
	keep if im<=3500
	keep if size_lag<12
	label_variables
	label variable ex "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health"
	label variable health_exp "Health Exp."
	label variable sch_spending "School Exp."
	label variable food "Food Exp."
	label variable c_ill "Child Ill (3 days)"
	label variable roof_cor "Iron Roof"
	label variable rent_pay "Rent"
	replace zhfa=. if a>=10
	replace zwfa=. if a>=10
	replace zbmi=. if a>=10
	replace c_ill=. if a>=10
	drop if rdp==.
	replace mktv=. if mktv>60000
	keep if hclust>=5
	keep rdp zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b inc  ex food
	order rdp zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b inc ex food 
	rename rdp RDP
	bysort RDP: outreg2 using clean/tables/sum_1, noni sum(log) eqkeep(mean N sd) label tex(frag) replace title("Summary Statistics by RDP Treatment Status") addnote("Child Health ranges from 1 Healthy to 5 Sick.")
end

program define housing_cost
	


program define figure_1_rooms_distribution
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	duplicates drop hh1, force
	hist rooms if rooms<10, by(rdp)
	graph export clean/tables/figure1.pdf, replace as(pdf)
end
	
program define figure_2_rooms_t
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	keep if im<=5000
	twoway lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(black) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP and non-RDP") || lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(orange) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/figure2.pdf, replace as(pdf)	
end


program define figure_3_size_t
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	keep if im<=5000
	global s "12"
	twoway lowess size size_lag if h_ch==0 & size<$s & size_lag<$s, color(black) xtitle("Size in t-1") ytitle("Size in t") title("Size t-1 against Size t for RDP and non-RDP") || lowess size size_lag if h_ch==1 & size<$s & size_lag<$s, color(orange) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/figure3.pdf, replace as(pdf)
end


program define parallel_trends

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	global a1 "10"
	global s "12"
	global im "3500"
	global clust "5"
	
	* height_lag weight_lag size_lag
	
	sort pid r
	foreach v in zhfa zwfa size c_ill c_health inc_ln {
	by pid: g `v'_ch_2=`v'_ch[_n-1]
	}
	by pid: g inc_ln_lag=pi_hhincome_ln[_n-1]
	by pid: g ex_ln_lag=ex_ln[_n-1]
	
	la var zhfa_ch_2 "Height Ch t-1"
	la var zwfa_ch_2 "Weight Ch t-1"
	la var c_ill_ch_2 "Illness Ch t-1"
	la var c_health_ch_2 "Health Ch t-1"
	
	
	la var zhfa_lag "Height t-1"
	la var zwfa_lag "Weight t-1"
	la var c_ill_lag "Illness t-1"
	la var c_health_lag "Health t-1"
	
	la var size_lag "Size"
	la var adult_men_lag "Adult Men"
	la var adult_women_lag "Adult Women"
	la var child_lag "Children"

	la var ex_ln_lag "Ln Exp"
	la var wath_lag "Piped Water"
	la var toih_lag "Flush Toilet"
	la var rooms_lag "Rooms"
	la var walls_b_lag "Brick Walls"
	la var crowd_lag "Crowd"
	
	la var inc_ln_lag "Ln Inc t-1"
	la var inc_ln_ch_2 "Ln Inc Ch t-1"
		* do previous changes predict treatment?
*	xi: reg h_ch zhfa_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s & hclust>=$clust, cluster(hh1) robust
*	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zhfa_ch_2) label replace nocons
	xi: reg h_ch zhfa_ch_2 zhfa_lag inc_ln_lag inc_ln_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zhfa_ch_2 zhfa_lag inc_ln_lag inc_ln_ch_2 ) label replace nocons

*	xi: reg h_ch zwfa_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
*	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zwfa_ch_2) label append nocons
	xi: reg h_ch zwfa_ch_2 zwfa_lag  inc_ln_lag inc_ln_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zwfa_ch_2 zwfa_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch c_health_ch_2 c_health_lag  inc_ln_lag inc_ln_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(c_health_ch_2 c_health_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch c_ill_ch_2 c_ill_lag  inc_ln_lag inc_ln_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) sortvar(zhfa_ch_2 zhfa_lag zwfa_ch_2 zwfa_lag c_health_ch_2 c_health_lag c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2) keep(c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch inc_ln_lag inc_ln_ch_2 i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(hh1) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) sortvar(zhfa_ch_2 zhfa_lag zwfa_ch_2 zwfa_lag c_health_ch_2 c_health_lag c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2) keep(c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

		* do previous changes predict treatment conditional on lags? 
				*   ( nope, consistent with choosing sicker kids )
	la var inc_ln_lag "Ln Inc"
		* what kind of selection do we find? ( currently turned off size disaggregation )
	xi: reg h_ch size_lag inc_ln_lag rooms_lag wath_lag toih_lag i.r if im<=$im & a<100 & size_lag<$s  & hclust>=0, cluster(hh1) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag wath_lag toih_lag rooms_lag) label replace nocons addtext(Treated Area, Full Sample) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag rooms_lag wath_lag toih_lag i.r if im<=$im & a<100 & size_lag<$s  & hclust>=5, cluster(hh1) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag wath_lag toih_lag rooms_lag) label append nocons addtext(Treated Area, Over 5) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag rooms_lag wath_lag toih_lag i.r if im<=$im & a<100 & size_lag<$s  & hclust>=10, cluster(hh1) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag wath_lag toih_lag rooms_lag) label append nocons addtext(Treated Area, Over 10) addnote("All explanatory variables reflect levels in t-1")

	xi: reg h_ch i.size_lag rooms_lag  inc_ln_lag wath_lag toih_lag i.r if im<=$im & a<100 & size_lag<$s & h_chn!=1 & hclust>=$clust, cluster(hh1) robust 
*	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar(size_lag rooms_lag) keep(size_lag  inc_ln_lag wath_lag toih_lag rooms_lag) label append nocons addnote("All explanatory variables reflect levels in t-1")
		* holds up non-parametrically!
	
	xi: reg h_ch size_lag size_ch_2 inc_ln_lag wath_lag toih_lag i.r if im<=$im & a<100 & size_lag<$s & hclust>=$clust, cluster(hh1) robust 
		* robust to testing selection non-parametrically and to lagged size changes

	*** CONFRONT THIS ISSUE LATER ***
*	xi: reg rooms size_lag i.r if im<=$im & a<100 & size_lag<$s & rooms<10 & h_ch==1 & hclust>5, cluster(hh1) robust 
*	xi: reg size_lag rooms wath toih i.r if im<=$im & a<100 & size_lag<$s & rooms<10 & h_ch==1 & hclust>5, cluster(hh1) robust 
*	xi: reg size_lag rooms_ch wath_ch toih_ch i.r if im<=$im & a<100 & size_lag<$s & rooms<10 & h_ch==1, cluster(hh1) robust 
*	xi: reg size_lag rooms wath toih i.r if im<=$im & a<100 & size_lag<$s & rooms<10 & h_ch==1, cluster(hh1) robust 
*	xi: reg size_lag rooms_ch wath_ch toih_ch i.r if im<=$im & a<100 & size_lag<$s & rooms<10 & h_ch==1, cluster(hh1) robust 
		
end



program define house_quality
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a1 "1000"
	global s "12"
	global im "3500"
	
	la var rooms_ch "Rooms Ch"
	la var toih_ch "Flush Ch"
	la var wath_ch "Piped Ch"
	la var walls_b_ch "Brick Ch"
	replace mktv=. if mktv>60000
	
	sort pid r
	by pid: g mktv_ch=mktv[_n]-mktv[_n-1]
	
	la var mktv_ch "Mktv Ch"
		lab var h_freqdomvio_ch "Domestic Vio Ch"
	lab var h_freqvio_ch "Violence Ch"
	lab var h_freqgang_ch "Gang Ch"
	lab var h_freqmdr_ch "Murder Ch"
	lab var h_freqdrug_ch "Drug Ch"
	
	lab var n_trust_ch "Trust Ch"
	lab var n_stay_ch "Stay Ch"

	xi: reg wath_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg toih_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg walls_b_ch h_ch h_ch_large large m_ch m_ch_large  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg refuse_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg mktv_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg rooms_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)


** WITHOUT INTERACTIONS
	xi: reg h_freqdomvio_ch h_ch m_ch i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch m_ch  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg h_freqmdr_ch h_ch  m_ch i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
*	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch  m_ch i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_trust_ch h_ch  m_ch i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_stay_ch h_ch  m_ch i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch ) label append nocons  addtext(Treated Area, Over 5)

***** INCLUDES INTERACTIONS
	xi: reg h_freqdomvio_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqgang_ch h_ch h_ch_large large m_ch m_ch_large  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqmdr_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch h_ch_large large m_ch m_ch_large i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over 5)

	tab size_lag h_ch if h_freqdomvio_ch!=.

	xi: reg h_freqdomvio_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg h_freqvio_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg h_freqgang_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg h_freqmdr_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg h_freqdrug_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	


	xi: reg wath_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg toih_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg walls_b_ch h_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg rooms_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)	

	xi: reg size_ch H_* sl_* mm_* i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	
		** LEVELS
	xi: reg wath h_ch h_ch_crowd crowd_lag m_ch m_ch_crowd  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality_levels, nonotes tex(frag) keep(h_ch h_ch_crowd crowd_lag ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg toih h_ch h_ch_crowd crowd_lag m_ch m_ch_crowd  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality_levels, nonotes tex(frag) keep(h_ch h_ch_crowd crowd_lag ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg walls_b h_ch h_ch_crowd crowd_lag m_ch m_ch_crowd  i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality_levels, nonotes tex(frag) keep(h_ch h_ch_crowd crowd_lag ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg rooms h_ch h_ch_crowd crowd_lag  m_ch m_ch_crowd i.r if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality_levels, nonotes tex(frag) keep(h_ch h_ch_crowd crowd_lag ) label append nocons  addtext(Treated Area, Over 5)
end


program define health_overall 

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	global clust "5"
	
	foreach v in wath toih  {
	g h_ch__`v'_lag=h_ch*`v'_lag
	g m_ch__`v'_lag=m_ch*`v'_lag
	}
	lab var h_ch__wath_lag "RDPxPiped t-1"
	lab var h_ch__toih_lag "RDPxFlush t-1"


	lab var wath_lag "Piped t-1"
	lab var toih_lag "Flush t-1"
	
	xi: reg zhfa_ch h_ch m_ch a sex i.r zhfa_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label replace nocons  addtext(Treated Area, Over $clust)	
	xi: reg zwfa_ch  h_ch m_ch i.r zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	

	xi: reg c_ill_ch h_ch m_ch a sex i.r c_ill_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	
	xi: reg c_health_ch h_ch m_ch a sex i.r c_health_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	

*	xi: reg c_absent_ch h_ch m_ch a sex i.r c_absent_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(hh1)	
*	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	
*	xi: reg c_failed_ch h_ch m_ch a sex i.r c_failed_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(hh1)	
*	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	

	xi: reg zhfa_ch h_ch__* m_ch__* wath_lag toih_lag h_ch a sex i.r zhfa_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s &  zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) keep(h_ch__* h_ch wath_lag toih_lag ) label replace nocons  addtext(Treated Area, Over $clust)	
	xi: reg zwfa_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch i.r zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66  & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
	xi: reg c_ill_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch i.r zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s  & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
	xi: reg c_health_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch i.r zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s  & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	



*	xi: reg zbmi_ch  h_ch m_ch i.r zbmi_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zbmi_ch<3.4 & zbmi_ch>-2.4 & size_lag>2, robust cluster(hh1)	
*	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over $clust)	
*	xi: reg zbmi_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch i.r zbmi_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zbmi_ch<3.4 & zbmi_ch>-2.4 & size_lag>2, robust cluster(hh1)	
*	outreg2 using clean/tables/health_overall, nonotes tex(frag) sortvar(h_ch h_ch__* wath_lag toih_lag) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
	
end


program define education_outcomes

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "12"
	global im "3500"
	global clust "5"
	global controls "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH sl_1 sl_2 sl_3 sl_4 sl_5 sl_6 sl_7 sl_8 sl_9 hh_sl mm_1 mm_2 mm_3 mm_4 mm_5 mm_6 mm_7 mm_8 mm_9 hh_mm"
	global graphs "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH"

	* FIRST STAGE *
	tab size_lag h_ch if c_absent_ch!=. & im<=3500 & hclust>=5
	
	xi: reg c_absent_ch H_* sl_* mm_* c_absent_p* sex a i.r if im<=3500 & size_lag<10 & size_lag>2  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	
	xi: reg c_failed_ch H_* sl_* mm_* c_failed_p* sex a  i.r if im<=3500 & size_lag<10 & size_lag>2  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	
	

end


program define first_stage

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "12"
	global im "3500"
	global clust "5"
	global controls "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH sl_1 sl_2 sl_3 sl_4 sl_5 sl_6 sl_7 sl_8 sl_9 hh_sl mm_1 mm_2 mm_3 mm_4 mm_5 mm_6 mm_7 mm_8 mm_9 hh_mm"
	global graphs "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH"

	* FIRST STAGE *

	xi: reg size_ch H_* sl_* mm_* i.r if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export clean/tables/size_ch.pdf, as(pdf) replace

	xi: reg ct_ch H_* sl_* mm_* i.r if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/child_ch.pdf, as(pdf) replace

	xi: reg ad_ch H_* sl_* mm_* i.r if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/adult_ch.pdf, as(pdf) replace

	xi: reg crowd_ch H_* sl_* mm_* i.r if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export clean/tables/crowd_ch.pdf, as(pdf) replace
	
*	xi: reg size_ch *_small *_large small i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
*	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch_small h_ch_large small) label replace nocons  addtext(Treated Area, Over 5)	
*	xi: reg ad_ch *_small *_large small i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
*	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch_small h_ch_large small) label append nocons  addtext(Treated Area, Over 5)	
*	xi: reg ct_ch *_small *_large small i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
*	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch_small h_ch_large small) label append nocons  addtext(Treated Area, Over 5)	

	xi: reg size_ch h_ch h_ch_large  m_ch m_ch_large large i.r if  hclust>=0 & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label replace nocons  addtext(Treated Area, Full Sample)	
	xi: reg size_ch h_ch h_ch_large  m_ch m_ch_large large i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg size_ch h_ch h_ch_large  m_ch m_ch_large large i.r if  hclust>=10 & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 10)
	xi: reg crowd_ch h_ch h_ch_large  m_ch m_ch_large large i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ad_ch h_ch h_ch_large  m_ch m_ch_large large i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ct_ch h_ch h_ch_large m_ch m_ch_large large i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	

	xi: reg o_ch *_small *_large small size_lag i.r if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(hh1)	
end

program define reduced_form
	* REDUCED FORM *
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	global clust "5"
	global controls "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH sl_1 sl_2 sl_3 sl_4 sl_5 sl_6 sl_7 sl_8 sl_9 hh_sl mm_1 mm_2 mm_3 mm_4 mm_5 mm_6 mm_7 mm_8 mm_9 hh_mm"
	global graphs "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH"

			* HEIGHT MEASUREMENTS
	xi: reg zhfa_ch $controls a sex i.r zhfa_p*  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3  & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep ($graphs) ytitle("Height Change Z-Score")
	graph export clean/tables/height_ch.pdf, as(pdf) replace
		
			* WEIGHT MEASUREMENTS
	xi: reg zwfa_ch $controls a sex  i.r zwfa_p*  if  hclust>=$clust & im<=$im & a<13 & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2.32, robust cluster(hh1)	
	coefplot, vertical keep ($graphs) ytitle("Weight Change Z-Score")
	graph export clean/tables/weight_ch.pdf, as(pdf) replace
	
			* BMI MEASUREMENTS
*	xi: reg zbmi_ch $controls a sex  i.r zbmi_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s &  zbmi_ch<3.4 & zbmi_ch>-2.4 & size_lag>2, robust cluster(hh1)	
*	coefplot, vertical keep ($graphs)
*	graph export clean/tables/bmi_ch.pdf, as(pdf) replace
		* broken up by over and under weight! *

	tab size_lag h_ch if hclust>=$clust & im<=$im & a<$a & size_lag>2 & zhfa_ch<2 & zhfa_ch>-1.3
	
	sum zhfa_ch if hclust>=$clust & im<=$im & a<$a & size_lag<$s & size_lag>2, detail
	sum zwfa_ch if hclust>=$clust & im<=$im & a<$a & size_lag<$s & size_lag>2, detail
*	sum zbmi_ch if hclust>=$clust & im<=$im & a<$a & size_lag<$s & size_lag>2, detail
			
	xi: reg zhfa_ch h_ch h_ch_large m_ch m_ch_large large a sex i.r zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label replace nocons  addtext(Treated Area, Over 5)	addnote("All regressions control for lagged quartiles in outcomes")	
	xi: reg zwfa_ch h_ch h_ch_large m_ch m_ch_large large  a sex i.r zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
*	xi: reg zbmi_ch h_ch h_ch_large  m_ch m_ch_large large  a sex i.r zbmi_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s &  zbmi_ch<3.4 & zbmi_ch>-2.4  & size_lag>1, robust cluster(hh1)	
*	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg c_health_ch h_ch h_ch_large m_ch m_ch_large large  a sex c_health_p* i.r if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg c_ill_ch h_ch h_ch_large m_ch m_ch_large large a sex c_ill_p* i.r if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(hh1)	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large) label append nocons  addtext(Treated Area, Over 5) 
	
		** APPENDIX ** 
	xi: reg zhfa_ch $controls a sex i.r zhfa_p*  if  (zhfa_p25==0 & zhfa_p50==0) & hclust>=$clust & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.2  & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep ($graphs)
	xi: reg zhfa_ch $controls  a sex i.r zhfa_p*  if  (zhfa_p25==1 | zhfa_p50==1) &  hclust>=$clust & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.2  & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep ($graphs)
				* gains are consistent across previously malnourished kids (unfortunately )
	xi: reg zwfa_ch  $controls i.r zwfa_p*  if (zwfa_p25==0 & zwfa_p50==0) & hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<1.4 & zwfa_ch>-1.6 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep ($graphs)
	xi: reg zwfa_ch  $controls i.r zwfa_p*  if (zwfa_p25==1 | zwfa_p50==1) & hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<1.4 & zwfa_ch>-1.6 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep ($graphs)
				* pretty consistent across measures! * not the sickest kids gaining..
*	xi: reg zbmi_ch $controls  i.r zbmi_p*  if (zbmi_p25==0 & zbmi_p50==0) & hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zbmi_ch<1.6 & zbmi_ch>-1.44 & size_lag>2, robust cluster(hh1)	
*	coefplot, vertical keep ($graphs)
*	xi: reg zbmi_ch $controls  i.r zbmi_p*  if (zbmi_p25==1 | zbmi_p50==1) & hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zbmi_ch<1.6 & zbmi_ch>-1.44 & size_lag>2, robust cluster(hh1)	
*	coefplot, vertical keep ($graphs)
	
end		

program define rent_exploration

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "12"
	global im "3500"	
	global clust "5"
		
end


program define income 

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "12"
	global im "3500"	
	global clust "5"
	
	la var e_ch "Emp Ch"
	la var ue_ch "UnEmp Ch"


	xi: reg pi_hhincome_ch h_ch  m_ch   i.r  if pi_hhincome_ch<15000 & pi_hhincome_ch>-15000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch   m_ch   i.r  if pi_hhincome_p_ch<5000 & pi_hhincome_p_ch>-5000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch  m_ch i.r if  pi_hhwage_ch<12000 & pi_hhwage_ch>-12000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch  m_ch   i.r  if  pi_hhwage_p_ch<7000 & pi_hhwage_p_ch>-7000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg e_ch h_ch  m_ch  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg ue_ch h_ch   m_ch   i.r  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)

	*** WITH INTERACTION
	xi: reg pi_hhincome_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if pi_hhincome_ch<15000 & pi_hhincome_ch>-15000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if pi_hhincome_p_ch<5000 & pi_hhincome_p_ch>-5000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch h_ch_large  m_ch m_ch_large large  i.r if  pi_hhwage_ch<12000 & pi_hhwage_ch>-12000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if  pi_hhwage_p_ch<7000 & pi_hhwage_p_ch>-7000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg e_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg ue_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)


end
	

program define remit

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "12"
	global im "3500"
	global clust "5"

	xi: reg a_cr_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large large ) label replace nocons  addtext(Treated Area, Over $clust)

	xi: reg a_cg_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg pi_hhremitt_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if pi_hhremitt_ch<12000 & pi_hhremitt_ch>-12000 &  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep( h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhremitt_p_ch  h_ch h_ch_large  m_ch m_ch_large large  i.r  if pi_hhremitt_p_ch<7000 & pi_hhremitt_p_ch>-7000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep( h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)

end
	

program define expenditure
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "12"
	global im "3500"
	global clust "5"	
	
	lab var food_ch1 "Food Ch"
	lab var non_food_ch1 "Non-Food Ch"
	lab var public_ch1 "Public Ch"
	lab var rent_pay_ch "Rent Ch"

	xi: reg exp1_ch1 h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & exp1_ch<2500 & exp1_ch>-2500, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large  ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg exp1_p_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s &  exp1_p_ch<1000 & exp1_p_ch>-1000, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg food_ch1 h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & food_ch<1500 & food_ch>-1500, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg food_p_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & food_p_ch<800 & food_p_ch>-800, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg non_food_ch1 h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & non_food_ch<1500 & non_food_ch >-1500, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_ch h_ch_large large  ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg non_food_p_ch  h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & non_food_p_ch<800 & non_food_p_ch>-800, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg public_ch1  h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & public_ch<1000 & public_ch >-1000, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg public_p_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s & public_ch<700 & public_ch >-700, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg rent_pay_ch h_ch h_ch_large  m_ch m_ch_large large  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_ch h_ch_large large ) label append nocons  addtext(Treated Area, Over $clust)
end


	
program define robustness

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "12"
	global im "3500"
	
	sort pid r
	by pid: g inc_ln_lag=pi_hhincome_ln[_n]	
		* move  and income control : essentially results are unaffected
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Income Lag, YES, Treated Area, Over 5)

end



program define sum_rdp_numbers1
	use clean/data_analysis/regs_nate_tables_3_6, clear
	egen mx_h_ch=max(h_ch), by(pid)
	g h_ch5=h_ch if hclust>=$clust
	egen mx_h_chi=max(h_ch5), by(pid)
	g h_ch10=h_ch if hclust>=10	
	egen mx_h_chn=max(h_ch10), by(pid)
	drop if mx_h_ch==. 
	duplicates drop pid, force
	keep mx_*
	label variable mx_h_ch "RDP House Gained: Full Sample"
	label variable mx_h_chi "RDP House Gained: 5 RDP PSU"
	label variable mx_h_chn "RDP House Gained: 10 RDP PSU"
	outreg2 using clean/tables/sum_rdp1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Subsidized Housing (RDP) in Final Sample")
end

program define sum_rdp_numbers
	use clean/data_v1.dta, clear
	g rdp=.
	replace rdp=1 if h_sub==-3
	replace rdp=1 if h_sub==1 & (r==1 | r==3)
	replace rdp=1 if h_grnthse==1 & r==2
	replace rdp=0 if h_sub==2 & (r==1 | r==3)
	replace rdp=0 if h_grnthse==2 & r==2
	drop if rdp==.
	* income eligibility
		* adult income
	g adult_id=(best_age_yrs>=18)
	egen adult=sum(adult_id), by(hhid)
	g ih=pi_hhincome/adult
	g ihd=(ih<=3500 & hhsizer>=2 & h_ownpid1!=pid)
	tab ihd
	* over 70% of the population
	
	sort pid r
	by pid: g h_ch=rdp[_n]-rdp[_n-1]
	egen max_h_ch=max(h_ch), by(pid)
	replace max_h_ch=0 if max_h_ch<0
	replace max_h_ch=0 if max_h_ch==.
	egen rdp_max=max(rdp), by(pid)
	duplicates drop pid, force
	keep max_h_ch rdp_max
	label variable rdp_max "RDP House: At Any Time During the Sample"
	label variable max_h_ch "RDP House: Gained Over the Sample"
	outreg2 using clean/tables/sum_rdp, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Subsidized Housing (RDP) in the Full Dataset")
end

program define rdp_tally
	use clean/data_analysis/regs_nate_tables_3_6, clear
	global s "12"
	global im "3500"
	drop if size_lag>=$s
	drop if im>=$im
	egen ma_rdp=max(h_ch), by(pid)
	duplicates drop hh1, force
	tab ma_rdp
	tab size
end



program define clean_data1

	use clean/data_analysis/house_treat_regs_inc_exp, clear

	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	g h_s=health_exp
	replace h_s=health_exp+sch_spending if sch_spending!=.
	replace h_s=sch_spending if h_s==. & sch_spending!=.
	
	egen ch=max(h_ch), by(pid)
	egen hch=max(ch), by(hhid)
	replace hch=0 if hch==.
	g chr1=h_ch if r==2
	egen ch1=max(chr1), by(pid)
	egen hch1=max(ch1), by(hhid) 
	g noch1=(ch1!=1 & hch1==1 & r==1)
	g chr2=h_ch if r==3
	egen ch2=max(chr2), by(pid)
	egen hch2=max(ch2), by(hhid) 
	g noch2=(ch2!=1 & hch2==1 & r==2)
	g noch=1 if noch1==1 | noch2==1
	replace noch=0 if noch==.
	sort pid r
	by pid: g lo=noch[_n-1]
	g non_labor=pi_hhincome-pi_hhwage
	replace h_fdtot=. if h_fdtot<0
	g trans=h_nftranspn
	egen clothing=rowtotal (h_nfbedspn h_nfmatspn h_nfclthmspn)
	egen kit_dwl_frn=rowtotal (h_nfkitspn h_nfdwlspn h_nffrnspn)
	egen ex=rowtotal(*spn *spnyr)
*	foreach var of varlist  pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor {
*	replace `var'=0 if `var'==.
*	}
	* fix rent variable
	replace rent_pay=0 if rent_d==1 & rent_pay==.
	sort pid r
	by pid: g rent_d_lag=rent_d[_n-1]
	replace rent_pay=0 if rent_d_lag==1 & rent_pay==.
	replace health_exp=0 if health_exp==.
	replace sch_spending=0 if sch_spending==.
	
	replace  pi_hhwage=0 if  pi_hhwage==.
	replace  pi_hhremitt=0 if pi_hhremitt==.
	replace  pi_hhwage=. if pi_hhincome==.
	replace  pi_hhremitt=. if pi_hhincome==.
	
	replace rent_pay=0 if rent_pay==.
	replace kid_exp=0 if kid_exp==. | exp!=.
	replace adult_exp=0 if adult_exp==. | exp!=.
	replace food=0 if food==. | adult_exp==.
	
	
	foreach var of varlist exp kid_exp adult_exp  rent_pay h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	quietly	g `var'_ln=ln(`var'+1)
	quietly g `var'_lnp=ln((`var'/size)+1)
	quietly g `var'_p=`var'/size
	quietly g `var'_e=`var'/exp1
	replace `var'_e=. if `var'==0 | ex==0
	quietly sort pid r
	quietly by pid: g `var'_ch1=`var'[_n]-`var'[_n-1]
	quietly by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	quietly by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	quietly by pid: g `var'_e_ch=`var'_e[_n]-`var'_e[_n-1]
	quietly by pid: g `var'_p_ch=`var'_p[_n]-`var'_p[_n-1]
	}
	save clean/data_analysis/house_treat_regs_anna_tables, replace
	
	*^*^*^^*^*^*^**^*^*^*^*^*^*^*^**^*^*^*^*
				*^(^(^(^(^(^(^(^(^(^(^(^((^(^(^(^(^(^(^(^((^(^(^(
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
	egen minimum_a=min(a), by(pid)
	g adult_id_inc=(minimum_a>20)
	egen adult_inc=sum(adult_id_inc), by(hhid)
	g inc_ad=pi_hhincome/adult_inc
	egen im=max(inc_ad), by(pid)
	
	* Full residence id
	duplicates tag hhid hh1, g(dup)
	replace dup=dup+1
	g dupr=dup/size
	egen mD=max(dupr), by(hhid)
	
	egen max_oidhh=max(oid), by(hhid) 
	
	g h_chi=h_ch
	replace h_chi=0 if (oidhh==0 & mD<.9 & max_oidhh==1)
	g h_chn=h_ch
	replace h_chn=0 if (oidhh==1 | (mD>.7 & mD<.))
	* move variables and key h_ch cleaning	
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	sort pid r
	tab h_ch
	foreach var of varlist h_chi h_chn h_ch {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
	* M_CH FIXING
	replace m_ch=. if r==1
	* H_CH FIXING 
*	replace h_ch=. if h_chn==1
	sort pid r
	by pid: g nochl=noch[_n-1]	
	
	replace m_res=1 if c_mthhh_pid>0 & c_mthhh_pid<. & m_res==.
	replace m_res=0 if c_mthhh_pid==77
	replace f_res=1 if c_fthhh_pid>0 & c_fthhh_pid<. & f_res==.
	replace f_res=0 if c_fthhh_pid==77
	
	g mr=m_res==1
	replace mr=. if a>20
	g fr=f_res==1
	replace fr=. if a>20
	sort pid r
	by pid: g mr_ch=mr[_n]-mr[_n-1]
	by pid: g fr_ch=fr[_n]-fr[_n-1]
	by pid: g m_res_ch=m_res[_n]-m_res[_n-1]
	by pid: g f_res_ch=f_res[_n]-f_res[_n-1]	
	g son=(r_relhead==4)
	g gs=(r_relhead==4 | r_relhead==13)
	sort pid r
	by pid: g rent_pay_ch=rent_pay[_n]-rent_pay[_n-1]
	egen hclust=sum(h_chi), by(cluster)
	
	g ele=1 if h_nfelespn>0 & h_nfelespn<.
	replace ele=0 if h_nfelespn==0
	g wat=1 if h_nfwatspn>0 & h_nfwatspn<.
	replace wat=0 if h_nfwatspn==0
	
	sort pid r
	foreach var of varlist ele wat c_ill c_health {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
		* adult illness
	sort pid r
	foreach var of varlist a_cr* a_cg* a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}		
	sort pid r
	replace c_waist_1=. if c_waist_1<0
	by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]	
	by pid: g zwfh_ch=zwfh[_n]-zwfa[_n-1]	
	by pid: g zwfh_lag=zwfa[_n-1]
	sort pid r
	foreach var of varlist zwfa zhfa zbmi zwfh c_absent c_failed c_health c_ill {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}

	* new variables : 3 / 26 / 15
	forvalues r=1(1)15 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	g small=size_lag<=6
	g large=size_lag>6
	foreach v in  h_ch m_ch {
	g `v'_small=`v'
	replace `v'_small=0 if size_lag>6 & `v'!=.
	g `v'_large=`v'
	replace `v'_large=0 if size_lag<=6 & `v'!=.
	}
	
	replace rooms=. if rooms>10
	g crowd=size/rooms
	replace crowd=. if crowd>5
	sort pid r
	by pid: g crowd_ch=crowd[_n]-crowd[_n-1]
	by pid: g crowd_lag=crowd[_n-1]
	g h_ch_crowd=crowd_lag*h_ch
	g m_ch_crowd=crowd_lag*m_ch

	g h_ch_sl=h_ch*size_lag

	g C_1=0 if crowd_lag!=.
	replace C_1=1 if crowd_lag>0 & crowd_lag<=1
	g C_2=0 if crowd_lag!=.
	replace C_2=1 if crowd_lag>1 & crowd_lag<=2
	g C_3=0 if crowd_lag!=.
	replace C_3=1 if crowd_lag>2 & crowd_lag<.
	
	forvalues r=1(1)3 {
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
	
	forvalues r=1(1)4 {
	g R_`r'=0 if rooms_lag!=.
	replace R_`r'=1 if rooms_lag==`r'
	g RH_`r'=h_ch
	replace RH_`r'=0 if R_`r'!=1 & h_ch!=.
	g RM_`r'=m_ch
	replace RM_`r'=0 if R_`r'!=1 & m_ch!=.
	}
	g R_5=0 if rooms_lag!=.
	replace R_5=1 if rooms_lag>4 & rooms_lag<.
	g RH_5=h_ch
	replace RH_5=0 if R_5!=1 & h_ch!=.
	g RM_5=m_ch
	replace RM_5=0 if R_5!=1 & m_ch!=.
	
	* extra stuff
	egen min_a=min(a), by(pid)
	g ct_id=(min_a<=16)
	egen ct=sum(ct_id), by(hhid)
	g ad_id=(min_a>16 & min_a<=60)
	egen ad=sum(ad_id), by(hhid)
	g o_id=(min_a>60)
	egen o=sum(o_id), by(hhid)
	foreach var of varlist ct ad o {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}	
	
	* key variable construction	
	
	g HH=0 if h_ch!=.
	forvalues r=10(1)15 {
	replace HH=1 if H_`r'==1
	}	
	g hh_sl=(size_lag>=10 & size_lag<16)
	g hh_mm=m_ch
	replace hh_mm=0 if size_lag>=10 & size_lag<16
	
	g HA=0 if h_ch!=.
	forvalues r=12(1)15 {
	replace HA=1 if H_`r'==1
	}	
	g ha_sl=(size_lag>=12 & size_lag<16)
	g ha_mm=m_ch
	replace ha_mm=0 if size_lag>=12 & size_lag<16

	* neighborhood quality
	g refuse=h_refrem if h_refrem>0
	replace refuse=0 if refuse==2
	g light=h_strlght if h_strlght>0
	replace light=0 if light==3
	
	foreach var of varlist  refuse light n_burial n_trust n_trust_str n_stay  a_weight_1 a_weight_2 a_weight_3 h_nbhlp h_nbtog h_nbagg h_nbthf h_nbthmf h_freqdomvio h_freqvio h_freqgang h_freqmdr h_freqdrug a_emobth a_emomnd a_emodep a_emoeff a_emohope a_emofear a_emoslp a_emohap a_emolone a_emogo {
*	tab `var' r, nolabel
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	

	save clean/data_analysis/regs_nate_tables_3_6, replace

end




program define label_variables

	* labels!
	lab var h_freqdomvio_ch "Domestic Vio Ch"
	lab var h_freqvio_ch "Violence Ch"
	lab var h_freqgang_ch "Gang Ch"
	lab var h_freqmdr_ch "Murder Ch"
	lab var h_freqdrug_ch "Drug Ch"
	
	la var refuse_ch "Refuse Ch"
	
	* extra labels
	foreach v in 1 2 3 4 5 6 7 8 9 10 11 {
	lab var H_`v' "S `v'"
	}
	
	lab var small "Small"
	lab var large "Large"
	lab var h_ch_small "RDPxSmall"
	lab var h_ch_large "RDPxLarge"
	
	lab var ct_ch "Child Ch"
	lab var ad_ch "Adult Ch"
	
	lab var a_cr_ch "Receive"
	lab var a_cg_ch "Send"

	* Crowd Variable
	lab var crowd "Crowd"
	lab var crowd_ch "Crowd Ch"
	lab var crowd_lag "Crowd t-1"
	lab var h_ch_crowd "RDPxCrowd t-1"
	
	* Non-Parametric Labels
*	lab var CH_1 "C 1"
*	lab var CH_2 "C 2"
*	lab var CH_3 "C 3"
*	lab var CH_4 "C 4"
*	lab var CH_5 "C 5"

	* Treatment Variables
	label variable h_ch "RDP"
	label variable h_ch_sl "RDPxSize t-1"
	label variable size_lag "Size t-1"
	label variable m_ch "Move Location"
	label variable m_ch_sl "Move xSize t-1"
	
	* Change Variables
	label variable size_ch "Size Ch"
	label variable child_ch "Children Ch"
	label variable adult_ch "Adult Ch"
	
	label variable zwfa_ch "Weight Ch"
	label variable zhfa_ch "Height Ch"
	label variable zbmi_ch "BMI Ch"
	label variable c_ill_ch "Ill Ch"
	label variable c_health_ch "Health Ch"

	label variable wath_ch "Piped Water Ch"
	label variable toih_ch "Flush Toilet Ch"	
*	label variable flush_ch "Flush Toilet Ch"
*	label variable piped_ch "Piped Water Ch"
	label variable walls_b_ch "Brick Walls Ch"
	
	* Income Variables
*	label variable pi_hhincome_ln "Inc Ln"
*	label variable pi_hhincome_ln_ch "Inc Ch"
*	label variable pi_hhincome_ln_p_ch "Inc Ch Per"
*	label variable pi_hhincome_p_ch "Inc Ch Per"
*	label variable pi_hhwage_ln "Wage Ln"
*	label variable pi_hhwage_ln_ch "Wage Ch"
*	label variable pi_hhwage_ln_p_ch "Wage Ch Per"
*	label variable pi_hhwage_p_ch "Wage Ch Per"
*	label variable pi_hhgovt_ln "Govt Ln"
*	label variable pi_hhgovt_ln_ch "Govt Ch"
*	label variable pi_hhgovt_ln_p_ch "Govt Ch Per"
*	label variable pi_hhgovt_p_ch "Govt Ch Per"
*	label variable pi_hhremitt_ln "Remit Ln"
*	label variable pi_hhremitt_ln_ch "Remit Ch"
*	label variable pi_hhremitt_ln_p_ch "Remit Ch Per"
*	label variable pi_hhremitt_p_ch "Remit Ch Per"

	label variable pi_hhincome_ch1 "Inc"	
	label variable pi_hhincome_ln "Inc Ln"
	label variable pi_hhincome_ln_ch "Inc Ln"
	label variable pi_hhincome_ln_p_ch "Inc Per"
	label variable pi_hhincome_p_ch "Inc Per"
	label variable pi_hhwage_ch1 "Wage"
	label variable pi_hhwage_ln "Wage Ln"
	label variable pi_hhwage_ln_ch "Wage"
	label variable pi_hhwage_ln_p_ch "Wage Per"
	label variable pi_hhwage_p_ch "Wage Per"
	label variable pi_hhgovt_ln "Govt Ln"
	label variable pi_hhgovt_ln_ch "Govt"
	label variable pi_hhgovt_ln_p_ch "Govt Per"
	label variable pi_hhgovt_p_ch "Govt Per"
	
	label variable pi_hhremitt_ch1 "Remit"
	label variable pi_hhremitt_ln "Remit Ln"
	label variable pi_hhremitt_ln_ch "Remit"
	label variable pi_hhremitt_ln_p_ch "Remit Per"
	label variable pi_hhremitt_p_ch "Remit Per"
	
	*Expenditure Variables

	label variable exp1_ch "Exp"
	label variable exp1_ln_ch "Exp"
	label variable exp1_ln_p_ch "Exp Per"	
	label variable exp1_p_ch "Exp Per"
	label variable food_ch "Food"
	label variable food_ln_ch "Food"
	label variable food_ln_p_ch "Food Per"
	label variable food_p_ch "Food Per"
*	label variable h_fdtot_ln_ch "Food"
*	label variable h_fdtot_ln_p_ch "Food Per"
	label variable public_ch "Public"
	label variable public_ln_ch "Public"
	label variable public_ln_p_ch "Public Per"
	label variable public_p_ch "Public Per"
	label variable non_food_ch "Non-Food"
	label variable non_food_ln_ch "Non-Food"
	label variable non_food_ln_p_ch "Non-Food Per"
	label variable non_food_p_ch "Non-Food Per"
	
	* Structure variables
	label variable size "Household Size"
	label variable child "Children"
	label variable adult_men "Adult Men"
	label variable adult_women "Adult Women"
	label variable old "Elderly"
	* HoH
	* Outcomes
	label variable zhfa "Height"
	label variable zwfa "Weight"
	label variable zbmi "BMI"
	label variable c_ill "Child ill for 3 days in last month"
	* Inc/Expenditure
	label variable inc "Income"
	label variable exp_imp "Household Exp (imp)"
	label variable ceremony "Ceremony Exp"
	label variable vice "Vice Exp"
	label variable sch_spending "School Exp"
	label variable health_exp "Health Exp"
	label variable inc "Income"
	label variable home_prod "Home Production Exp"
	label variable food "Food Exp"
	* Housing Variables
	label define rdpp 0 "Unsubsidized Housing" 1 "Subsidized (RDP) Housing"
	label values rdp rdpp
	label variable rdp "RDP"
	label variable rooms "Rooms"
	label variable rooms_lag "Rooms in t-1"
	label variable mktv "Market Value"
	label variable qual "House Quality"
	label variable roof_cor "Corrugated Roof"
	label variable walls_b "Brick Walls"
	label variable toilet_share "Share Toilet"
	label variable toih "Flush Toilet"
	label variable wath "Piped Water"
*	label variable flush "Flush Toilet"
*	label variable piped "Piped Water"
	* School Outcomes
	label variable c_absent "Days Absent"
	label variable c_failed "Failed Grade"
	* Additional Labels
	label variable ex "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health (1 Sick-5 Healthy)"
end


	
main
	
	

	
	
	
	
	
	
	
