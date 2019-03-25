
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	quietly sum_rdp_numbers
	quietly clean_data
	quietly clean_data1
	quietly label_variables
	quietly figure_1_rooms_distribution
	quietly figure_2_rooms_t
	quietly summary_stats
	quietly first_stage
	quietly house_quality
	quietly reduced_form
	quietly income
	quietly exp
	quietly robustness
	use clean/data_analysis/regs_nate_tables_3_6, clear
end


program define summary_stats
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	label variable ex "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health"
	label variable health_exp "Health Exp."
	label variable sch_spending "School Exp."
	label variable food "Food Exp."
	label variable c_ill "Child Ill (3 days)"
	label variable roof_cor "Iron Roof"
	replace zhfa=. if a>12
	replace zwfa=. if a>12
	replace zbmi=.
	replace c_ill=. if a>12
	drop if rdp==.
	replace mktv=. if mktv>60000
	keep rdp zhfa zwfa zbmi c_ill c_health size child adult old inc health_exp sch_spending food ex rooms piped flush mktv roof_cor walls_b
	order rdp zhfa zwfa zbmi c_ill c_health size child adult old inc health_exp sch_spending food ex rooms piped flush mktv roof_cor walls_b
	rename rdp RDP
	bysort RDP: outreg2 using clean/tables/sum_1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics by RDP Treatment Status") addnote("Child Health ranges from 1 Healthy to 5 Sick")
end


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

	twoway lowess rooms rooms_lag if h_chi==0 & h_chn==0 & rooms<10 & rooms_lag<10, color(black) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP Owners and Joiners") || lowess rooms rooms_lag if h_chi==1 & rooms<10 & rooms_lag<10, color(blue) || lowess rooms rooms_lag if h_chn==1 & rooms<10 & rooms_lag<10, color(orange) legend(label(1 "Control Population") label(2 "RDP Owners") label(3 "RDP Joiners"))
	graph export clean/tables/figure2_1.pdf, replace as(pdf)	
end


program define figure_3_size_t
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	keep if im<=5000
	global s "11"
	twoway lowess size size_lag if h_ch==0 & size<$s & size_lag<$s, color(black) xtitle("Size in t-1") ytitle("Size in t") title("Size t-1 against Size t for RDP and non-RDP") || lowess size size_lag if h_ch==1 & size<$s & size_lag<$s, color(orange) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/figure3.pdf, replace as(pdf)	

	twoway lowess size size_lag if h_chi==0 & h_chn==0 & size<$s & size_lag<$s, color(black) xtitle("Size in t-1") ytitle("Size in t") title("Size t-1 against Size t for RDP Owners and Joiners") || lowess size size_lag if h_chi==1 & size<$s & size_lag<$s, color(blue)  || lowess size size_lag if h_chn==1 & size<$s & size_lag<$s, color(orange) legend(label(1 "Control Population") label(2 "RDP Owners") label(3 "RDP Joiners"))
	graph export clean/tables/figure3_1.pdf, replace as(pdf)	
end


program define first_stage
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	global a1 "100"
	global s "11"
	global im "5000"
	
	xi: reg size_ch h_ch h_ch_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label replace nocons title("First Stage: Household Size") addtext(Treated Area, All Areas)
	xi: reg size_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label replace nocons title("First Stage: Household Size by Ownership")  addtext(Treated Area, All Areas)

	xi: reg size_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg size_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag  i.r if im<=$im & hclust>=5 & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons addtext(Treated Area, Over 5)

	xi: reg size_ch h_ch h_ch_sl size_lag  i.r if hclust>=10 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 10)
	xi: reg size_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & hclust>=10 & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons  addtext(Treated Area, Over 10)

	xi: reg child_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg adult_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)

end

program define house_quality
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a1 "100"
	global s "11"
	global im "5000"
	
	xi: reg piped_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label replace nocons  addtext(Treated Area, Over 5)
*	xi: reg piped_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag  i.r if im<=$im & hclust>=5 & a<$a1 & size_lag<$s, robust cluster(hh1)
*	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons addtext(Treated Area, Over 5)
	xi: reg flush_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg flush_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag  i.r if im<=$im & hclust>=5 & a<$a1 & size_lag<$s, robust cluster(hh1)
*	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons addtext(Treated Area, Over 5)
	xi: reg walls_b_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg walls_b_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag  i.r if im<=$im & hclust>=5 & a<$a1 & size_lag<$s, robust cluster(hh1)
*	outreg2 using clean/tables/house_quality, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons addtext(Treated Area, Over 5)

end



program define reduced_form
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "11"
	global im "5000"

	xi: reg zhfa_ch h_ch a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chn a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_ch a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chn a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)

*	xi: reg zbmi_ch h_ch a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg zbmi_ch h_chi h_chn a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)

	xi: reg zhfa_ch h_ch h_ch_sl size_lag a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_ch h_ch_sl size_lag a sex i.r zhfa_p*  if  hclust>=10 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 10)
	xi: reg zwfa_ch h_ch h_ch_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_ch h_ch_sl size_lag  a sex i.r zwfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 10)

*	xi: reg zbmi_ch h_ch h_ch_sl size_lag  a sex i.r zbmi_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
		
	* with and without lags	
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Outcome Lag, YES)
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Outcome Lag, NO)
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Outcome Lag, YES)
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Outcome Lag, NO)

	* cluster  5 or 10 treated area
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 10)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 10)

	** GENERAL HEALTH INDICATORS DONT MOVE AT ALL **
	
*	xi: reg c_health_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r  if hclust>=1 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg c_ill_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r   if hclust>=1 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 10)

*	xi: reg zbmi_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag ) label append nocons  addtext(Treated Area, Over 5)
	
end

program define income 

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "11"
	global im "5000"	
	global clust "5"
		
	xi: reg pi_hhincome_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhincome_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhwage_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	
*	xi: reg pi_hhgovt_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/inc1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over $clust)
*	xi: reg pi_hhgovt_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/inc1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhremitt_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg pi_hhremitt_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/inc, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

end
	


program define expenditure
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "11"
	global im "5000"
	global clust "5"	

	xi: reg exp1_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg exp1_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg food_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg food_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

*	xi: reg h_fdtot_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over $clust)
*	xi: reg h_fdtot_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg non_food_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over $clust)
	xi: reg non_food_ln_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

	xi: reg public_ln_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
	xi: reg public_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

	* rent expenditure
		* not paying much for rent to begin with
	xi: reg rent_pay_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg rent_pay_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg rent_pay_ln_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
		* no change in rent exp
	xi: reg h_nfelespn_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_nfelespn_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_nfelespn_ln_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	

	xi: reg h_nfwatspn_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_nfwatspn_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_nfwatspn_ln_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	


	xi: reg food_e_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg non_food_e_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg public_e_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	

	xi: reg exp1_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg food_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg non_food_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg public_p_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	

	xi: reg h_fdtot_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_fdtot_e_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg h_fdtot_e_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	

		* * health and school spending * *
	xi: reg health_exp_ln_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg health_exp_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg sch_spending_ln_ch  h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	xi: reg sch_spending_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	
*	xi: reg services_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)
*	xi: reg services_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=$clust &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/exp1, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over $clust)

end


program define food_expenditure
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "100"
	global s "11"
	global im "5000"	
	foreach var of varlist veggies meat carbs  fats {
	xi: reg `var'_ln_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/food_exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg `var'_ln_p_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/food_exp, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 5)
	}

end
	
program define robustness

	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables		
	global a "10"
	global s "11"
	global im "5000"
	
	sort pid r
	by pid: g inc_ln_lag=pi_hhincome_ln[_n]	

		* move  and income control : essentially results are unaffected
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p* inc_ln_lag if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Income Lag, YES, Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r zhfa_p* if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl ) label append nocons  addtext(Income Lag, NO, Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p* inc_ln_lag if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Income Lag, YES, Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag  a sex i.r zwfa_p* if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/robustness, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl ) label append nocons  addtext(Income Lag, NO, Treated Area, Over 5)

*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p* inc_ln_lag if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r zhfa_p* if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p* inc_ln_lag if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag  a sex i.r zwfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
			* include earlier
		* no lags : brings back the weight results : which hold for non-movers, consistent with more selection there
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag  a sex i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag  a sex i.r  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	

end





program define label_variables
	* Treatment Variables
	label variable h_ch "RDP"
	label variable h_ch_sl "RDPxSize t-1"
	label variable h_chi "RDP Own"
	label variable h_chi_sl "RDP OwnxSize t-1"
	label variable h_chn "RDP Join"
	label variable h_chn_sl "RDP JoinxSize t-1"	
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
	
	label variable flush_ch "Flush Toilet Ch"
	label variable piped_ch "Piped Water Ch"
	label variable walls_b_ch "Brick Walls Ch"
	
	* Income Variables
	label variable pi_hhincome_ln "Inc Ln"
	label variable pi_hhincome_ln_ch "Inc Ch"
	label variable pi_hhincome_ln_p_ch "Inc Ch Per"
	label variable pi_hhincome_p_ch "Inc Ch Per"
	label variable pi_hhwage_ln "Wage Ln"
	label variable pi_hhwage_ln_ch "Wage Ch"
	label variable pi_hhwage_ln_p_ch "Wage Ch Per"
	label variable pi_hhwage_p_ch "Wage Ch Per"
	label variable pi_hhgovt_ln "Govt Ln"
	label variable pi_hhgovt_ln_ch "Govt Ch"
	label variable pi_hhgovt_ln_p_ch "Govt Ch Per"
	label variable pi_hhgovt_p_ch "Govt Ch Per"
	label variable pi_hhremitt_ln "Remit Ln"
	label variable pi_hhremitt_ln_ch "Remit Ch"
	label variable pi_hhremitt_ln_p_ch "Remit Ch Per"
	label variable pi_hhremitt_p_ch "Remit Ch Per"
	
	*Expenditure Variables

	label variable exp1_ln_ch "Exp"
	label variable exp1_ln_p_ch "Exp Per"	
	label variable exp1_p_ch "Exp Per"
	label variable food_ln_ch "Food"
	label variable food_ln_p_ch "Food Per"
	label variable food_p_ch "Food Per"
*	label variable h_fdtot_ln_ch "Food"
*	label variable h_fdtot_ln_p_ch "Food Per"
	label variable public_ln_ch "Public"
	label variable public_ln_p_ch "Public Per"
	label variable public_p_ch "Public Per"
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
	label variable piped "Piped Water"
	label variable mktv "Market Value"
	label variable qual "House Quality"
	label variable roof_cor "Corrugated Roof"
	label variable walls_b "Brick Walls"
	label variable toilet_share "Share Toilet"
	label variable flush "Flush Toilet"
	* School Outcomes
	label variable c_absent "Days Absent"
	label variable c_failed "Failed Grade"
	* Additional Labels
	label variable ex "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health (1 Sick-5 Healthy)"
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
	sort pid r
	by pid: g h_ch=rdp[_n]-rdp[_n-1]
	egen max_h_ch=max(h_ch), by(pid)
	replace max_h_ch=0 if max_h_ch<0
	replace max_h_ch=0 if max_h_ch==.
	egen rdp_max=max(rdp), by(pid)
	duplicates drop pid, force
	keep max_h_ch rdp_max
	label variable rdp_max "RDP House (At Any Time During the Sample)"
	label variable max_h_ch "RDP House (Gained Over the Sample)"
	outreg2 using clean/tables/sum_rdp, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics: Subsidized Housing (RDP)")
end

program define rdp_tally
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	egen ma_rdp=max(rdp), by(pid)
	duplicates drop hh1, force
	tab ma_rdp
end
	
			
program define clean_data
end
	
program define clean_data1
	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
*	quietly sum inc_m, detail
*	drop if inc_m>r(p95)
*	replace size_lag=. if size_lag>13
*	replace size=. if size>13
	egen esum=sum(e), by(hhid)
	g e_s=esum/size
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
	foreach var of varlist  pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor {
	replace `var'=0 if `var'==.
	}
	replace rent_pay=0 if rent_pay==.
	replace health_exp=0 if health_exp==.
	replace sch_spending=0 if sch_spending==.
	foreach var of varlist rent_pay h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	quietly	g `var'_ln=ln(`var'+1)
	quietly g `var'_lnp=ln(`var'/size)
	quietly g `var'_p=`var'/size
	quietly g `var'_e=`var'/exp1
	replace `var'_e=. if `var'==0 | ex==0
	quietly sort pid r
	quietly by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	quietly by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	quietly by pid: g `var'_e_ch=`var'_e[_n]-`var'_e[_n-1]
	quietly by pid: g `var'_p_ch=`var'_p[_n]-`var'_p[_n-1]
	}
	save clean/data_analysis/house_treat_regs_anna_tables, replace
	
	*^*^*^^*^*^*^**^*^*^*^*^*^*^*^**^*^*^*^*
				*^(^(^(^(^(^(^(^(^(^(^(^((^(^(^(^(^(^(^(^((^(^(^(
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	g h_chi=h_ch
	replace h_chi=0 if oidhh==0
	g h_chn=h_ch
	replace h_chn=0 if oidhh==1

	sort pid r
	by pid: g nochl=noch[_n-1]	
	egen h_chimdb=sum(h_chi), by(mdb)
	egen mh_chi=sum(h_chi), by(hhid)
	egen mh_chn=sum(h_chn), by(hhid)
	g new_size_id=(a>=3 & a<.)
	egen new_size=sum(new_size_id), by(hhid)
	g ir=mh_chi/new_size
	g nr=mh_chn/new_size
	g hil=h_chi
	replace hil=0 if ir<.5 & ir<1
	g his=h_chi
	replace his=0 if ir>=.5 & ir<.
	g hio=h_chi
	replace hio=0 if ir!=1	& ir<.
	g hnl=h_chn
	replace hnl=0 if ir<.5 & ir<.
	g hns=h_chn
	replace hns=0 if ir>=.5
	
	g at_7_18=(a>7 & a<=18)
	g at_60=(a>18)	
	g at_sl_7_18=at_7_18*size_lag
	g at_sl_60=at_60*size_lag
	foreach v in h_ch h_chi h_chn hil his hnl hns hio {
	g `v'_sl=`v'*size_lag
	g `v'_at_7_18=`v'*at_7_18
	g `v'_sl_at_7_18=`v'*at_7_18*size_lag
	g `v'_at_60=`v'*at_60
	g `v'_sl_at_60=`v'*at_60*size_lag
	}
	replace m_res=1 if c_mthhh_pid>0 & c_mthhh_pid<. & m_res==.
	replace m_res=0 if c_mthhh_pid==77
	replace f_res=1 if c_fthhh_pid>0 & c_fthhh_pid<. & f_res==.
	replace f_res=0 if c_fthhh_pid==77
	forvalues r=1/3 {
	replace a_weight_`r'=. if a_weight_`r'<0
	g weight_`r'=a_weight_`r'
	replace weight_`r'=c_weight_`r' if a_weight_`r'==.
	}
	g weight = (weight_1+weight_2+weight_3)/3
	replace weight=(weight_1+weight_2)/2 if weight==.
	replace weight=weight_1 if weight==.
	replace weight=weight_2 if weight==.
	replace weight=weight_3 if weight==.
	
	egen med_w=median(weight), by(a sex)
	egen sd_w=sd(weight), by(a sex)
	g zw=(weight-med_w)/sd_w	
	replace zw=. if zw>3 | zw<-3
	sort pid r
	by pid: g zw_ch=zw[_n]-zw[_n-1]

	replace r_parhpid=. if r_parhpid<100
	g spouse_id=pid+r_parhpid
	
	egen c7=max(cr7), by(spouse_id hhid)
	g parent7=(c7>0 & c7<.)
	egen c18=max(cr18), by(spouse_id hhid)
	g parent18=(c18>0 & c18<.)
			
	g ad_p7_id=(a>=19 & a<=60 & parent7==1)
	egen ad_p7=sum(ad_p7_id), by(hhid)
	sort pid r
	by pid: g ad_p7_ch=ad_p7[_n]-ad_p7[_n-1]
	g ad_np7_id=(a>=19 & a<=60 & parent7==0)
	egen ad_np7=sum(ad_np7_id), by(hhid)
	sort pid r
	by pid: g ad_np7_ch=ad_p7[_n]-ad_np7[_n-1]	

	g ad_p18_id=(a>=19 & a<=60 & parent18==1)
	egen ad_p18=sum(ad_p18_id), by(hhid)
	sort pid r
	by pid: g ad_p18_ch=ad_p18[_n]-ad_p18[_n-1]
	g ad_np18_id=(a>=19 & a<=60 & parent7==0)
	egen ad_np18=sum(ad_np18_id), by(hhid)
	sort pid r
	by pid: g ad_np18_ch=ad_p18[_n]-ad_np18[_n-1]	
	
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
	by pid: g zw_lag=zw[_n-1]
	sort pid r
	by pid: g rent_pay_ch=rent_pay[_n]-rent_pay[_n-1]
	egen hclust=sum(h_chi), by(cluster)

	* move variables and key h_ch cleaning	
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	g m_ch_at_7_18=m_ch*at_7_18
	g m_ch_at_60=m_ch*at_60
	g m_ch_sl_at_7_18=m_ch_sl*at_7_18
	g m_ch_sl_at_60=m_ch_sl*at_60
	sort pid r
	tab h_ch
	foreach var of varlist h_chi h_chn h_ch {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
	replace m_ch=. if r==1
	tab h_ch
	
	g ele=1 if h_nfelespn>0 & h_nfelespn<.
	replace ele=0 if h_nfelespn==0
	g wat=1 if h_nfwatspn>0 & h_nfwatspn<.
	replace wat=0 if h_nfwatspn==0
	
	sort pid r
	foreach var of varlist ele wat {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
		* adult illness
	sort pid r
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}		
	sort pid r
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	replace c_waist_1=. if c_waist_1<0
	by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]		
	sort pid r
	foreach var of varlist zwfa zhfa zbmi {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}
	save clean/data_analysis/regs_nate_tables_3_6, replace
end


	
main
	
	

	
	
	
	
	
	
	
