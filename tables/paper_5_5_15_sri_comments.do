


clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"


program define main
	quietly sum_rdp_numbers
*	quietly clean_data1
*	quietly label_variables
*	quietly figure_1_rooms_distribution
*	quietly figure_2_rooms_t
	quietly summary_stats
	quietly first_stage
	quietly house_quality
*	quietly analysis
	income
	expenditure
	remit
	parallel_trends
*	quietly non_resident_children
	first_stage
	reduced_form
	reduced_form_small_big
	health_overall
*	use clean/data_analysis/regs_nate_tables_3_6, clear
end

program define rent_per_person
	use clean/data_analysis/regs_nate_tables_3_6, clear
	keep if im<=3500
	keep if (size_lag<12 & r>=2) | (size<12 & r==1)
	label_variables
	drop if h_ch==1 | h_chS==1
	
	g rent_per=rent_pay/size
	replace rent_per=. if rent_per==0
	replace rent_per=. if rent_per>800
	
	label variable rent_per "Rent Per Person"
	
	lowess rent_per size
	graph export clean/tables/rent_per.pdf, as(pdf) replace	
	
end


program define check_size_ch
	use clean/data_analysis/regs_nate_tables_3_6, clear
	keep if im<=3500
	keep if (size_lag<12 & r>=2) | (size<12 & r==1)
	label_variables
	sort pid r
	by pid: g size_chl=size_ch[_n+1]
	egen msc=mode(size_chl), by(hhid)
	duplicates drop hhid, force
	drop if r==3
	g big=size>7	
	label var msc "Size Change"
	label var big "HH Size"
	lab define RDP 1 "RDP" 0 "Control"
	lab define SIZE 1 "8-11 Members" 0 "6-7 Members"
	lab values h_ch RDP
	lab values big SIZE
	
	hist msc if  size>5, by(big h_ch)
	graph export clean/tables/size_hist.pdf, as(pdf) replace
	
	
	* key graph
	* very useful
end


program define housing_cost

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "12"
	global im "3500"
	global clust "5"
	replace mktv=. if mktv>60000
	
	replace rent_pay=. if rent_pay<=0
	replace mktv=. if mktv<=0
	sort pid r
	by pid: g rent_pay_lag=rent_pay[_n-1]
	by pid: g mktv_lag=mktv[_n-1]
	g mktv_lag_m=mktv_lag/24
	keep if hclust>=5
	keep if size_lag<12
	
	la var own_lag "Percent Owners"
	la var rent_pay_lag "Monthly Rent"
	la var mktv_lag "Market Value"
	la var mktv_lag_m "Market Value Per Month (2 yrs)"
	rename h_ch RDP
	drop if RDP==.
	
	keep if RDP==1
	keep own_lag rent_pay_lag mktv_lag 
	order own_lag rent_pay_lag mktv_lag
	outreg2 using clean/tables/house_cost, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Housing Cost in t-1 for RDP Beneficiaries") addnote("Market value per month is market value divided by 24")
	
*	keep RDP own_lag rent_pay_lag mktv_lag mktv_lag_m
*	order RDP own_lag rent_pay_lag mktv_lag mktv_lag_m
*	bysort RDP: outreg2 using clean/tables/house_cost, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Value of Housing in t-1") addnote("Market value per month is market value divided by 24")
	
end


program define summary_stats
	use clean/data_analysis/regs_nate_tables_3_6, clear
	keep if im<=3500
	keep if (size_lag<12 & r>=2) | (size<12 & r==1)
	label_variables
	
	replace h_ch=1 if h_chS==1	
	g RDP=0
	sort pid r
	by pid: g h_ch_lead=h_ch[_n+1]
	replace RDP=1 if h_ch_lead==1
	replace RDP=2 if h_ch==1
	
	label variable exp1 "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health"
	label variable health_exp "Health Exp."
	label variable sch_spending "School Exp."
	label variable food "Food Exp."
	label variable c_ill "Child Ill (3 days)"
	label variable roof_cor "Iron Roof"
	label variable rent_pay "Rent"
	label variable own "Ownership"

	replace zhfa=. if a>10
	replace zwfa=. if a>10
	replace zbmi=. if a>10
	replace c_ill=. if a>10
	drop if rdp==.
	replace mktv=. if mktv>60000
*	keep if hclust>=5
	g RDP1=1 if RDP==1
	replace RDP1=0 if RDP==0
	replace RDP1=. if RDP==2
	
	g rrr=1 if RDP1==0
	replace rrr=0 if RDP1==1

	estpost ttest zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b own inc  ex food, by(rrr)
	est sto t1
*	estpost ttest zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b own inc  ex food, by(RDP2)
*	est sto t2
	esttab t1 using clean/tables/ttest1, wide label replace tex noobs
	
	keep RDP zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b own inc  ex food
	order RDP zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b own inc ex food 
*	rename rdp RDP

	ttable2 zhfa zwfa  c_ill c_health size child adult rooms wath toih mktv  walls_b own inc  ex food, by(RDP)
	
	bysort RDP: outreg2 using clean/tables/sum_1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics by RDP Treatment Status") addnote("Child Health ranges from 1 Healthy to 5 Sick.")
end


program define figure_1_rooms_distribution
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	label define RDP1 1 "RDP Housing" 0 "Non-RDP (Control) Housing"
	label values rdp RDP1
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
	la var avg_e_lag "Avg Emp"
	
	la var inc_ln_lag "Ln Inc t-1"
	la var inc_ln_ch_2 "Ln Inc Ch t-1"
	
	xi: reg h_ch zhfa_ch_2 zhfa_lag inc_ln_lag inc_ln_ch_2 h_chS h_chML    i.r*i.prov  if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(cluster) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zhfa_ch_2 zhfa_lag inc_ln_lag inc_ln_ch_2 ) label replace 

	xi: reg h_ch zwfa_ch_2 zwfa_lag  inc_ln_lag inc_ln_ch_2 h_chS h_chML    i.r*i.prov  if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(cluster) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(zwfa_ch_2 zwfa_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch c_health_ch_2 c_health_lag  inc_ln_lag inc_ln_ch_2 h_chS h_chML    i.r*i.prov  if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(cluster) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) keep(c_health_ch_2 c_health_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch c_ill_ch_2 c_ill_lag  inc_ln_lag inc_ln_ch_2 h_chS h_chML    i.r*i.prov  if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(cluster) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) sortvar(zhfa_ch_2 zhfa_lag zwfa_ch_2 zwfa_lag c_health_ch_2 c_health_lag c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2) keep(c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	xi: reg h_ch inc_ln_lag inc_ln_ch_2 h_chS h_chML    i.r*i.prov  if im<=$im & a<$a1 & size_lag<$s  & hclust>=$clust, cluster(cluster) robust
	outreg2 using clean/tables/height_weight_lag, nonotes tex(frag) sortvar(zhfa_ch_2 zhfa_lag zwfa_ch_2 zwfa_lag c_health_ch_2 c_health_lag c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2) keep(c_ill_ch_2 c_ill_lag inc_ln_lag inc_ln_ch_2 ) label append nocons

	la var inc_ln_lag "Ln Inc"
	la var own_lag "Home Ownership"
	replace mktv=. if mktv>60000
	sort pid r
	by pid: g mktv_lag=mktv[_n-1]
	la var mktv_lag "Market Value"
		* what kind of selection do we find? ( currently turned off size disaggregation )
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<100 & size_lag<$s  & hclust>=0, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label replace  nocons addtext(Treated Area, Full Sample, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<100 & size_lag<$s  & hclust>=5, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<100 & size_lag<$s  & hclust>=10, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 10, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<100 & size_lag<$s  & hclust>=5 & size_lag>1, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")	
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag mktv_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<100 & size_lag<$s  & hclust>=5, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag mktv_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	* KIDS
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<10 & size_lag<10 & size_lag>2  & hclust>=0, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag_kids, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label replace  nocons addtext(Treated Area, Full Sample, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<10 & size_lag<10 & size_lag>2  & hclust>=5, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag_kids, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<10 & size_lag<10 & size_lag>2  & hclust>=10, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag_kids, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 10, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<10 & size_lag<10 & size_lag>2  & hclust>=5 & size_lag>1, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag_kids, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")	
	xi: reg h_ch size_lag inc_ln_lag avg_e_lag rooms_lag wath_lag toih_lag walls_b_lag own_lag mktv_lag h_chS h_chML    i.r*i.prov  if im<=$im & a<10 & size_lag<10 & size_lag>2  & hclust>=5, cluster(cluster) robust 
	outreg2 using clean/tables/size_lag_kids, nonotes tex(frag) sortvar( size_lag ) keep( size_lag  inc_ln_lag avg_e_lag wath_lag toih_lag rooms_lag walls_b_lag own_lag mktv_lag) label append nocons addtext(Treated Area, Over 5, One Person HH, YES) addnote("All explanatory variables reflect levels in t-1")


end



program define house_quality
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a1 "1000"
	global ak "10"
	global s "12"
	global im "3500"
	global clust "5"
	
	la var rooms_ch "Rooms Ch"
	la var toih_ch "Flush Ch"
	la var wath_ch "Piped Ch"
	la var walls_b_ch "Brick Ch"
	replace mktv=. if mktv>60000
	
	sort pid r
	by pid: g mktv_ch=mktv[_n]-mktv[_n-1]
	by pid: g h_ch_t1=h_ch[_n+1]
	la var mktv_ch "Mktv Ch"
	lab var h_freqdomvio_ch "Domestic Vio Ch"
	lab var h_freqvio_ch "Violence Ch"
	lab var h_freqgang_ch "Gang Ch"
	lab var h_freqmdr_ch "Murder Ch"
	lab var h_freqdrug_ch "Drug Ch"
	lab var n_trust_ch "Trust Ch"
	lab var n_stay_ch "Stay Ch"
	
	xi: reg wath_ch h_ch h_ch_large h_chS h_chS_large  large h_chML  h_chML_large  m_ch  m_ch_large lo lo_large lo2 lo2_large  i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large h_chS h_chS_large large ) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg toih_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg walls_b_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg refuse_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg mktv_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg rooms_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	** KIDS
	xi: reg wath_ch h_ch h_ch_large h_chS h_chS_large  large h_chML  h_chML_large  m_ch  m_ch_large lo lo_large lo2 lo2_large  i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large h_chS h_chS_large large ) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg toih_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg walls_b_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg refuse_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg mktv_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg rooms_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/house_quality_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)

** WITHOUT INTERACTIONS
	xi: reg h_freqdomvio_ch h_ch m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch h_chS) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_trust_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_stay_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	
	* KIDS
	xi: reg h_freqdomvio_ch h_ch m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_kids, nonotes tex(frag) keep(h_ch h_chS) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_kids, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_kids, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_trust_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_kids, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_stay_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_kids, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over 5)

***** INCLUDES INTERACTIONS
	xi: reg h_freqdomvio_ch h_ch h_ch_large h_chS  h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large h_chS  h_chS_large large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_trust_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_stay_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$a1 & size_lag<$s, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	* KIDS
	xi: reg h_freqdomvio_ch h_ch h_ch_large h_chS  h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i_kids, nonotes tex(frag) keep(h_ch h_ch_large h_chS  h_chS_large large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqvio_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg h_freqdrug_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_trust_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)
	xi: reg n_stay_ch h_ch h_ch_large  h_chS_large h_chML_large  large m_ch lo lo_large lo2 lo2_large m_ch_large h_chS h_chML    i.r*i.prov  if hclust>=$clust & im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)
	outreg2 using clean/tables/n_quality_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)

end


program define health_overall 

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global ak "10"
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
	
	
	global clust "0"
	xi: reg zhfa_ch h_ch m_ch lo lo_large a sex h_chS h_chML    i.r*i.prov zhfa_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(cluster)		
	quietly sum zhfa if hclust>=$clust & im<=3500 & a<$s & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Full Sample)	addstat(Mean, mean1)

	global clust "5"
	xi: reg zhfa_ch h_ch m_ch lo lo_large a sex h_chS h_chML    i.r*i.prov zhfa_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa if hclust>=$clust & im<=3500 & a<$s & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2 , detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label append sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over $clust)	addstat(Mean, mean1)

	global clust "0"
	xi: reg zwfa_ch  h_ch m_ch lo lo_large h_chS h_chML    i.r*i.prov zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)		
	quietly sum zwfa if hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2 , detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Full Sample)	 addstat(Mean, mean1)

	global clust "5"
	xi: reg zwfa_ch  h_ch m_ch lo lo_large h_chS h_chML    i.r*i.prov zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)		
	quietly sum zwfa if hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2 , detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over $clust) addstat(Mean, mean1)	

	xi: reg c_ill_ch h_ch m_ch lo lo_large a sex h_chS h_chML    i.r*i.prov c_ill_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_ill if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over $clust)		addstat(Mean, mean1)

	xi: reg c_health_ch h_ch m_ch lo lo_large a sex h_chS h_chML    i.r*i.prov c_health_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_health if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s & size_lag>2, detail
	scalar define mean1=r(mean)
	outreg2 using clean/tables/health_overall, nonotes tex(frag) keep(h_ch h_chS) label append nocons  addtext(Treated Area, Over $clust)		addstat(Mean, mean1)

	xi: reg zhfa_ch h_ch__* m_ch__* wath_lag toih_lag h_ch a sex h_chS h_chML    i.r*i.prov zhfa_p*  if  hclust>=$clust & im<=3500 & a<$s & size_lag<$s &  zhfa_ch<2 & zhfa_ch>-1.3 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) keep(h_ch__* h_ch wath_lag toih_lag ) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Over $clust)	
	xi: reg zwfa_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch h_chS h_chML    i.r*i.prov zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66  & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
	xi: reg c_ill_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch h_chS h_chML    i.r*i.prov zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s  & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
	xi: reg c_health_ch  h_ch__* m_ch__* wath_lag toih_lag  h_ch h_chS h_chML    i.r*i.prov zwfa_p*  if  hclust>=$clust & im<=3500 & a<$a & size_lag<$s  & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/health_overall_w_t, nonotes tex(frag) sortvar(h_ch) keep(h_ch__* h_ch wath_lag toih_lag ) label append nocons  addtext(Treated Area, Over $clust)	
end


program define first_stage

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "12"
	global im "3500"
	global clust "5"
	
	* FIRST STAGE *
	xi: reg size_ch H_* sl_* mm_* h_chS h_chML lo lo_large lo2 lo2_large  h_chS_large h_chML_large    i.r*i.prov  if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(cluster)
	coefplot, vertical keep(H_*) ytitle("Household Size Change Interacted with RDP") xtitle("Baseline Household Size")
	graph export clean/tables/size_ch.pdf, as(pdf) replace

	xi: reg crowd_ch H_* sl_* mm_* h_chS h_chML    i.r*i.prov  if im<=3500 & size_lag<$s  & hclust>=$clust, robust cluster(cluster)
	coefplot, vertical keep(H_*) ytitle("People per Room Interacted with RDP") xtitle("Baseline Household Size")
	graph export clean/tables/crowd_ch.pdf, as(pdf) replace
	

	xi: reg size_ch H_* sl_* mm_* h_chS h_chML lo lo_large lo2 lo2_large  h_chS_large h_chML_large    i.r*i.prov  if im<=3500 &  size_lag<10 & size_lag>2  & hclust>=$clust & a<10, robust cluster(cluster)
	coefplot, vertical keep(H_*) ytitle("Household Size Change Interacted with RDP") xtitle("Baseline Household Size")
	graph export clean/tables/size_ch_kids.pdf, as(pdf) replace

	xi: reg crowd_ch H_* sl_* mm_* h_chS h_chML    i.r*i.prov  if im<=3500 & size_lag<10 & size_lag>2  & hclust>=$clust & a<10, robust cluster(cluster)
	coefplot, vertical keep(H_*) ytitle("People per Room Interacted with RDP") xtitle("Baseline Household Size")
	graph export clean/tables/crowd_ch_kids.pdf, as(pdf) replace
	

	xi: reg size_ch h_ch h_ch_large h_chS h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large    i.r*i.prov  if  hclust>=0 & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Full Sample)	
	xi: reg size_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg size_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=10 & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 10)
	xi: reg crowd_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ad_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ct_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<100 & size_lag<12, robust cluster(cluster)	
	outreg2 using clean/tables/size, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	**KIDS
	xi: reg size_ch h_ch h_ch_large h_chS h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large    i.r*i.prov  if  hclust>=0 & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Treated Area, Full Sample)	
	xi: reg size_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg size_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=10 & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 10)
	xi: reg crowd_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ad_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	
	xi: reg ct_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large large h_chS h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/size_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addtext(Treated Area, Over 5)	

end


program define reduced_form_small_big
	* REDUCED FORM *
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	global clust "5"
	global controls "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH sl_1 sl_2 sl_3 sl_4 sl_5 sl_6 sl_7 sl_8 sl_9 hh_sl mm_1 mm_2 mm_3 mm_4 mm_5 mm_6 mm_7 mm_8 mm_9 hh_mm"
	global graphs "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH"	
	
	g small_house=rooms_lag<=2
	g h_ch_small_house=small_house*h_ch
	g h_ch_small_house_large=h_ch_small_house*large

	g big_house=rooms_lag>4
	g h_ch_big_house=big_house*h_ch
	g h_ch_big_house_large=h_ch_big_house*large
	
	lab var small_house "Small House t-1 (Rooms \leq 2)"
	lab var h_ch_small_house "RDPxSmall House t-1"
	lab var h_ch_small_house_large "RDPxLarge HH t-1 x Small House t-1"

	lab var big_house "Big House t-1 (Rooms \geq 5)"
	lab var h_ch_big_house "RDPxBig House t-1"
	lab var h_ch_big_house_large "RDPxLarge HH t-1 x Big House t-1"
		
*	xi: reg zhfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large h_chS h_chS_large  lo lo_large h_chML_large  m_ch lo2 lo2_large m_ch_large large a sex  h_chML i.r*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
*	xi: reg zwfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large large  a sex  h_chS h_chML  i.r*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	

*	xi: reg zhfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large  h_chS h_chS_large  lo lo_large h_chML_large  m_ch lo2 lo2_large m_ch_large a sex  h_chML i.rl1*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
*	outreg2 using clean/tables/big_small, nonotes tex(frag) sortvar(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) keep(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) label replace  nocons  addtext(Large Controls, YES, Treated Area, Over 5) 	addnote("All regressions control for lagged quartiles in outcomes")	
	
*	xi: reg zwfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
*	outreg2 using clean/tables/big_small, nonotes tex(frag) sortvar(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) keep(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) label append  nocons  addtext(Large Controls, YES, Treated Area, Over 5) 	addnote("All regressions control for lagged quartiles in outcomes")	

	xi: reg zhfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large h_chS h_chS_large  lo lo_large h_chML_large  m_ch lo2 lo2_large m_ch_large a sex  h_chML i.rl1*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/big_small, nonotes tex(frag) sortvar(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) keep(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) label replace  nocons  addtext(Time x Prov x Large FE, YES, Treated Area, Over 5) 	addnote("All regressions control for lagged quartiles in outcomes")	
	
	xi: reg zwfa_ch h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/big_small, nonotes tex(frag) sortvar(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) keep(h_ch h_ch_large small_house h_ch_small_house h_ch_small_house_large big_house h_ch_big_house h_ch_big_house_large) label append  nocons  addtext(Time x Prov x Large FE, YES, Treated Area, Over 5) 	addnote("All regressions control for lagged quartiles in outcomes")	


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
			* HEIGHT MEASUREMENTS *
	xi: reg zhfa_ch $controls a sex  h_chS h_chML  h_chS_large h_chML_large   i.rl1*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5  & size_lag>2, robust cluster(cluster)	
	coefplot, vertical keep ($graphs) ytitle("Height Change Interacted with RDP (z-score)") xtitle("Baseline Household Size")
	graph export clean/tables/height_ch.pdf, as(pdf) replace
			* WEIGHT MEASUREMENTS *
	xi: reg zwfa_ch $controls a sex  h_chS h_chML  h_chS_large h_chML_large   i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	coefplot, vertical keep ($graphs) ytitle("Weight Change Interacted with RDP (z-score)") xtitle("Baseline Household Size")
	graph export clean/tables/weight_ch.pdf, as(pdf) replace

*  lo lo_large lo2 lo2_large

*egen max_ml=max(h_chML), by(pid)
*drop if max_ml==1
	
	sort pid r
	by pid: g im_lag=im[_n-1]
	

	global clust "0"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS h_chS_large h_chML_large  m_ch  m_ch_large large a sex  h_chML im_lag zhfa_p*  i.r*i.prov if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0
	outreg2 using clean/tables/health, nonotes tex(frag) sortvar(h_ch h_ch_large h_chS h_chS_large large lo lo_large) keep(h_ch h_ch_large h_chS h_chS_large large lo lo_large) label replace  nocons  addtext(Time x Prov FE, YES, Time x Prov x Large FE, NO, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS h_chS_large im_lag h_chML_large  m_ch  m_ch_large a sex  h_chML  i.rl1*i.prov zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0
	outreg2 using clean/tables/health, nonotes tex(frag) sortvar(h_ch h_ch_large h_chS h_chS_large large lo lo_large) keep(h_ch h_ch_large h_chS h_chS_large large lo lo_large) label append  nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "5"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large a sex h_chS h_chML i.rl1*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large ) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Over 5) addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch  m_ch_large large  a sex  h_chS h_chML  zwfa_p* i.r*i.prov if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large lo lo_large) label append nocons   addtext(Time x Prov FE, YES, Time x Prov x Large FE, NO, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) )	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large lo lo_large) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "5"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large h_chS h_chS_large lo lo_large ) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Over 5)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	



	xi: reg c_health_ch h_ch h_ch_large  h_chS  h_chS_large large h_chML_large  m_ch  m_ch_large    h_chML    i.r*i.prov  a sex c_health_p* if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_health, detail
	outreg2 using clean/tables/health1, nonotes tex(frag) keep(h_ch h_ch_large  h_chS_large h_chS  large ) sortvar(h_ch h_ch_large h_chS h_chS_large large) label replace nocons  addtext(Time x Prov FE, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
*	xi: reg c_health_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large    h_chS h_chML    i.rl1*i.prov  a sex c_health_p* if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
*	quietly sum c_health, detail
*	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large) label append nocons  addtext(Large Controls, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	

	xi: reg c_ill_ch h_ch h_ch_large h_chS h_chS_large large h_chML_large  m_ch  m_ch_large  a sex c_ill_p*    h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_ill, detail
	outreg2 using clean/tables/health1, nonotes tex(frag) keep(h_ch h_ch_large h_chS  h_chS_large  large ) label append nocons  addtext(Time x Prov FE, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
*	xi: reg c_ill_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large a sex c_ill_p*   h_chS h_chML    i.rl1*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
*	quietly sum c_ill, detail
*	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large) label append nocons  addtext(Large Controls, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
end		


program define income 

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global ak "10"
	global s "12"
	global im "3500"	
	global clust "5"
	la var e_ch "Emp Ch"
	la var ue_ch "UnEmp Ch"

	xi: reg pi_hhincome_ch h_ch  m_ch lo lo2  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhincome, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch   m_ch lo lo2   h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhincome_p, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhwage, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch  m_ch lo lo2   h_chS h_chML    i.r*i.prov  if   hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhwage_p, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg e_ch h_ch  m_ch lo lo2  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum e, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg ue_ch h_ch   m_ch lo lo2   h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum ue, detail
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	** kids
	xi: reg pi_hhincome_ch h_ch  m_ch lo lo2  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhincome, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch   m_ch lo lo2   h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhincome_p, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch  m_ch lo lo_large h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhwage, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch  m_ch lo lo2   h_chS h_chML    i.r*i.prov  if   hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhwage_p, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg e_ch h_ch  m_ch lo lo2  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum e, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg ue_ch h_ch   m_ch lo lo2   h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum ue, detail
	outreg2 using clean/tables/inc_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)


	*** WITH INTERACTION
	xi: reg pi_hhincome_ch h_ch h_ch_large h_chS h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large    h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhincome, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch h_ch_large h_chS h_chS_large large  h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhincome_p, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhwage, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum pi_hhwage_p, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg e_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum e, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg ue_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum ue, detail
	outreg2 using clean/tables/inc_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	** kids
	xi: reg pi_hhincome_ch h_ch h_ch_large h_chS h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large    h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhincome, detail
	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_ch h_ch_large h_chS h_chS_large large  h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhincome_p, detail
	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhwage, detail
	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum pi_hhwage_p, detail
	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
*	xi: reg e_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
*	quietly sum e, detail
*	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
*	xi: reg ue_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
*	quietly sum ue, detail
*	outreg2 using clean/tables/inc_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)


end
	

program define remit

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global ak "10"
	global s "12"
	global im "3500"
	global clust "5"

	xi: reg a_cr_ch h_ch h_ch_large  h_chS h_chS_large lo lo_large large h_chML_large   m_ch  lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label replace sortvar(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) nocons  addtext(Treated Area, Over $clust)
	xi: reg a_cg_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg pi_hhremitt_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if pi_hhremitt_ch<12000 & pi_hhremitt_ch>-12000 &  hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhremitt_p_ch  h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if pi_hhremitt_p_ch<7000 & pi_hhremitt_p_ch>-7000 & hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	outreg2 using clean/tables/remit, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label append nocons  addtext(Treated Area, Over $clust)

	* kids
*	xi: reg a_cr_ch h_ch h_ch_large  h_chS h_chS_large lo lo_large large h_chML_large   m_ch  lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
*	outreg2 using clean/tables/remit_kids, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label replace sortvar(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) nocons  addtext(Treated Area, Over $clust)
*	xi: reg a_cg_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
*	outreg2 using clean/tables/remit_kids, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg pi_hhremitt_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if pi_hhremitt_ch<12000 & pi_hhremitt_ch>-12000 &  hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/remit_kids, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhremitt_p_ch  h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if pi_hhremitt_p_ch<7000 & pi_hhremitt_p_ch>-7000 & hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	outreg2 using clean/tables/remit_kids, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large large) label append nocons  addtext(Treated Area, Over $clust)

end



**** NEW ONE ****
program define expenditure
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global ak "10"
	global s "12"
	global im "3500"
	global clust "5"	
	
	lab var food_ch1 "Food"
	lab var non_food_1_ch1 "Non-Food"
	lab var non_food_1_p_ch "Non-Food Per"
	lab var public_ch1 "Public Ch"
	lab var rent_pay_ch "Rent Ch"

** WITHOUT INTERACTION 
	xi: reg exp1_ch1 h_ch   m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum exp1, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg exp1_p_ch h_ch   m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum exp1_p, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

	xi: reg food_ch1 h_ch  m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum food, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg food_p_ch h_ch  m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum food_p, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

	xi: reg non_food_1_ch1 h_ch  m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum non_food_1, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg non_food_1_p_ch  h_ch   m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum non_food_1_p, detail
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

** WITH INTERACTION
	xi: reg exp1_ch1 h_ch h_ch_large h_chS  h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum exp1, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg exp1_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum exp1_p, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	xi: reg food_ch1 h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum food, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg food_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum food_p, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	xi: reg non_food_1_ch1 h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum non_food_1, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg non_food_1_p_ch  h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(cluster)	
	quietly sum non_food_1_p, detail
	outreg2 using clean/tables/exp_i, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	* KIDS
	

** WITHOUT INTERACTION 
	xi: reg exp1_ch1 h_ch   m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum exp1, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg exp1_p_ch h_ch   m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum exp1_p, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

	xi: reg food_ch1 h_ch  m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum food, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg food_p_ch h_ch  m_ch lo lo_large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum food_p, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

	xi: reg non_food_1_ch1 h_ch  m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum non_food_1, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)
	xi: reg non_food_1_p_ch  h_ch   m_ch lo lo_large   h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum non_food_1_p, detail
	outreg2 using clean/tables/exp_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons addstat(Mean, r(mean)) addtext(Treated Area, Over $clust)

	** WITH INTERACTION
	xi: reg exp1_ch1 h_ch h_ch_large h_chS  h_chS_large large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large   h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum exp1, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large large) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg exp1_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum exp1_p, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	xi: reg food_ch1 h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum food, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg food_p_ch h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum food_p, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

	xi: reg non_food_1_ch1 h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum non_food_1, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)
	xi: reg non_food_1_p_ch  h_ch h_ch_large  h_chS_large h_chML_large   m_ch lo lo_large lo2 lo2_large m_ch_large large  h_chS h_chML    i.r*i.prov  if hclust>=$clust &  im<=$im & a<$ak & size_lag<10 & size_lag>2, robust cluster(cluster)	
	quietly sum non_food_1_p, detail
	outreg2 using clean/tables/exp_i_kids, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large) label append nocons  addstat(Mean, r(mean))  addtext(Treated Area, Over $clust)

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

	xi: reg c_absent_ch H_* sl_* mm_* c_absent_p* sex a h_chS h_chML    i.r*i.prov  if im<=3500 & size_lag<10 & size_lag>2  & hclust>=$clust, robust cluster(cluster)
	coefplot, vertical keep(H_*)
	xi: reg c_failed_ch H_* sl_* mm_* c_failed_p* sex a  h_chS h_chML    i.r*i.prov  if im<=3500 & size_lag<10 & size_lag>2  & hclust>=$clust, robust cluster(cluster)
	coefplot, vertical keep(H_*)

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
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace sortvar(h_ch h_ch_large h_chS h_chS_large large) nocons  addtext(Income Lag, YES, Treated Area, Over 5)

end

program define new_sum_rdp_numbers
	use clean/data_analysis/regs_nate_tables_3_6, clear
	keep if hclust>=5 & im<=3500 & size_lag<12
	drop if r==1
	keep r h_ch h_ch_large h_chS h_chS_large lo lo_large 
	order  r h_ch h_ch_large h_chS h_chS_large lo lo_large
	label var h_ch "RDP"
	label var h_ch_large "RDPxLarge"
	rename r Round
	bysort Round: outreg2 using clean/tables/sum_rdp_new, noni sum(log) eqkeep(N mean) label tex(frag) replace title("RDP Treatment Variables") addnote("Fully Trimmed Sample; Only PSUs with over 5 treatments")
end


program define sum_rdp_numbers2
	use clean/data_analysis/regs_nate_tables_3_6, clear
	g h_ch5=h_ch if hclust>=5
	g h_ch10=h_ch if hclust>=10	
	drop if h_ch==.
	duplicates drop pid r, force
	drop if r==1
	keep r h_ch h_ch5 h_ch10
	order r h_ch h_ch5 h_ch10
	label variable h_ch "RDP House Gained: Full Sample"
	label variable h_ch5 "RDP House Gained: 5 RDP PSU"
	label variable h_ch10 "RDP House Gained: 10 RDP PSU"
	rename r Round
	bysort Round: outreg2 using clean/tables/sum_rdp1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Subsidized Housing (RDP) in Final Sample")
end

*program define sum_rdp_numbers1
*	use clean/data_analysis/regs_nate_tables_3_6, clear
*	egen mx_h_ch=max(h_ch), by(pid)
*	g h_ch5=h_ch if hclust>=5
*	egen mx_h_chi=max(h_ch5), by(pid)
*	g h_ch10=h_ch if hclust>=10	
*	egen mx_h_chn=max(h_ch10), by(pid)
*	drop if mx_h_ch==. 
*	duplicates drop pid, force
*	keep mx_*
*	label variable mx_h_ch "RDP House Gained: Full Sample"
*	label variable mx_h_chi "RDP House Gained: 5 RDP PSU"
*	label variable mx_h_chn "RDP House Gained: 10 RDP PSU"
*	outreg2 using clean/tables/sum_rdp1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Subsidized Housing (RDP) in Final Sample")
*end

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




program define reduced_form_appendix
	* REDUCED FORM *
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	global clust "5"
	global controls "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH sl_1 sl_2 sl_3 sl_4 sl_5 sl_6 sl_7 sl_8 sl_9 hh_sl mm_1 mm_2 mm_3 mm_4 mm_5 mm_6 mm_7 mm_8 mm_9 hh_mm"
	global graphs "H_1 H_2 H_3 H_4 H_5 H_6 H_7 H_8 H_9 HH"	

*  lo lo_large lo2 lo2_large

*egen max_ml=max(h_chML), by(pid)
*drop if max_ml==1
	
	sort pid r
	by pid: g im_lag=im[_n-1]
	

	global clust "0"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS h_chS_large h_chML_large  m_ch  m_ch_large large a sex  h_chML im_lag zhfa_p*  i.r*i.prov if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0
	outreg2 using clean/tables/health, nonotes tex(frag) sortvar(h_ch h_ch_large h_chS h_chS_large large lo lo_large) keep(h_ch h_ch_large h_chS h_chS_large large lo lo_large) label replace  nocons  addtext(Time x Prov FE, YES, Time x Prov x Large FE, NO, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS h_chS_large im_lag h_chML_large  m_ch  m_ch_large a sex  h_chML  i.rl1*i.prov zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0
	outreg2 using clean/tables/health, nonotes tex(frag) sortvar(h_ch h_ch_large h_chS h_chS_large large lo lo_large) keep(h_ch h_ch_large h_chS h_chS_large large lo lo_large) label append  nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "5"
	xi: reg zhfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large a sex h_chS h_chML i.rl1*i.prov  zhfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zhfa_ch<2 & zhfa_ch>-1.5 & size_lag>2, robust cluster(cluster)	
	quietly sum zhfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large  h_chS h_chS_large lo lo_large ) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Over 5) addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch  m_ch_large large  a sex  h_chS h_chML  zwfa_p* i.r*i.prov if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large lo lo_large) label append nocons   addtext(Time x Prov FE, YES, Time x Prov x Large FE, NO, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) )	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "0"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large large h_chS h_chS_large lo lo_large) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Full Sample)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	

	scalar drop mean1
	global clust "5"
	xi: reg zwfa_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch m_ch_large  a sex  h_chS h_chML  i.rl1*i.prov  zwfa_p*  if  hclust>=$clust & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.66 & size_lag>2, robust cluster(cluster)	
	quietly sum zwfa, detail
	scalar define mean1=r(mean)
	quietly	test _b[h_ch]+_b[h_ch_large]=0	
	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large h_chS h_chS_large lo lo_large ) label append nocons  addtext(Time x Prov FE, NO, Time x Prov x Large FE, YES, Treated Area, Over 5)  addstat(Mean, mean1, F-Stat: RDP+RDPxLarge=0, r(F) ) 	addnote("All regressions control for lagged quartiles in outcomes")	



	xi: reg c_health_ch h_ch h_ch_large  h_chS  h_chS_large large h_chML_large  m_ch  m_ch_large    h_chML    i.r*i.prov  a sex c_health_p* if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_health, detail
	outreg2 using clean/tables/health1, nonotes tex(frag) keep(h_ch h_ch_large  h_chS_large h_chS  large ) sortvar(h_ch h_ch_large h_chS h_chS_large large) label replace nocons  addtext(Time x Prov FE, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
*	xi: reg c_health_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large    h_chS h_chML    i.rl1*i.prov  a sex c_health_p* if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
*	quietly sum c_health, detail
*	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large) label append nocons  addtext(Large Controls, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	

	xi: reg c_ill_ch h_ch h_ch_large h_chS h_chS_large large h_chML_large  m_ch  m_ch_large  a sex c_ill_p*    h_chML    i.r*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
	quietly sum c_ill, detail
	outreg2 using clean/tables/health1, nonotes tex(frag) keep(h_ch h_ch_large h_chS  h_chS_large  large ) label append nocons  addtext(Time x Prov FE, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
*	xi: reg c_ill_ch h_ch h_ch_large  h_chS_large h_chML_large  m_ch lo lo_large lo2 lo2_large m_ch_large a sex c_ill_p*   h_chS h_chML    i.rl1*i.prov  if  hclust>=$clust & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(cluster)	
*	quietly sum c_ill, detail
*	outreg2 using clean/tables/health, nonotes tex(frag) keep(h_ch h_ch_large) label append nocons  addtext(Large Controls, YES, Treated Area, Over 5)  addstat(Mean, r(mean)) 	addnote("All regressions control for lagged quartiles in outcomes")	
end		



program define label_variables

	lab var avg_e_lag "Avg Emp t-1"
	lab var avg_e_ch "Avg Emp Ch"
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
	lab var h_ch_large  "RDPxLarge"
	lab var ct_ch "Child Ch"
	lab var ad_ch "Adult Ch"
	lab var a_cr_ch "Receive"
	lab var a_cg_ch "Send"
	* Crowd Variable
	lab var crowd "Crowd"
	lab var crowd_ch "Crowd Ch"
	lab var crowd_lag "Crowd t-1"
	lab var h_ch_crowd "RDPxCrowd t-1"
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




*do clean/tables/clean_data


main
	
	
	
	
	
	
	
	
	

