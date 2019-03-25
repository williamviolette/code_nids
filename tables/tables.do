
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	quietly figure_1_rooms_distribution
*	quietly sum_rdp_numbers
	use clean/data_analysis/house_treat_regs, clear
	label_variables
	quietly gen_rdp_size_interaction
	** analysis
	quietly core_regressions
	quietly demographic_regressions
	quietly house_quality_regressions
	quietly expenditure_income_regressions
*	quietly exp_inc_per_person
	** summary stats
end

program define summary_stats
	use clean/data_analysis/house_treat_regs, clear
	label_variables
	label variable exp_imp "Total Expenditure (imputed)"
	label variable health_exp "Health Exp."
	label variable sch_spending "School Exp."
	label variable food "Food Exp."
	label variable c_ill "Child Ill (3 days)"
	label variable roof_cor "Iron Roof"
	replace zhfa=. if a>7
	replace zwfa=. if a>7
	replace c_ill=. if a>7
	replace mktv=. if mktv>100000
	label variable s2r1 "Baseline Household Size"
	drop if s2r1==.
	keep rdp s2r1 zhfa zwfa c_ill size child old inc  health_exp sch_spending food rooms piped mktv flush roof_cor walls_b
	order rdp s2r1 zhfa zwfa c_ill size child old inc  health_exp sch_spending food rooms piped mktv flush roof_cor walls_b
	rename s2r1 HHSize
	rename rdp RDP
	bysort HHSize RDP: outreg2 using clean/tables/sum_1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics by RDP and Household Size") addnote("HHSize indicates households greater than 4 members at baseline.")
end


program define exp_inc_per_person
	xtset pid
	quietly xi: xtreg inc_s rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("Income/Expenditure per Person")
	quietly xi: xtreg inc_s rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	quietly xi: xtreg food_s rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg food_s rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	
	quietly xi: xtreg sch_spending_s rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_2, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("Income/Expenditure per Person: Continued")
	quietly xi: xtreg sch_spending_s rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_2, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	quietly xi: xtreg health_exp_s rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_2, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg health_exp_s rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_s_2, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
end

program define expenditure_income_regressions
	xtset pid
	quietly xi: xtreg inc rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("Income/Expenditure")
	quietly xi: xtreg inc rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	quietly xi: xtreg food rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg food rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	
	quietly xi: xtreg sch_spending rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_2, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("Income/Expenditure: Continued")
	quietly xi: xtreg sch_spending rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_2, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	quietly xi: xtreg health_exp rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_2, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg health_exp rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/inc_exp_2, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
end

program define house_quality_regressions
	xtset pid		
	quietly xi: xtreg rooms rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/house_1_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("House Quality")
	quietly xi: xtreg rooms rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/house_1_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	
	quietly xi: xtreg piped rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/house_1_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg piped rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/house_1_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)

	quietly xi: xtreg flush rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/house_2_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Baseline Household Size, Less than 4) title("House Quality: Continued")
	quietly xi: xtreg flush rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/house_2_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)
	
	quietly xi: xtreg mktv rdp i.r if s2r1==0 & (mktv<100000 | mktv==.), cluster(hh1) fe robust
	outreg2 using clean/tables/house_2_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4)
	quietly xi: xtreg mktv rdp i.r if s2r1==1 & (mktv<100000 | mktv==.), cluster(hh1) fe robust
	outreg2 using clean/tables/house_2_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4)

*	replace own=0 if own==2
*	xi: xtreg own rdp i.r if s2r1==0, cluster(hh1) fe robust
*	xi: xtreg own rdp i.r if s2r1==1, cluster(hh1) fe robust
end	



program define demographic_regressions
	xtset pid
	quietly xi: xtreg size rdp i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_size_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Household Size")
	quietly xi: xtreg size rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/core_size_v1, nonotes tex(frag) label append   keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg size rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/core_size_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg size rdp rdp_large i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_size_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
	
	quietly xi: xtreg child rdp i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_child_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Number of Children")
	quietly xi: xtreg child rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/core_child_v1, nonotes tex(frag) label append   keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg child rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/core_child_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg child rdp rdp_large i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_child_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
	
	quietly xi: xtreg old rdp i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_old_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Number of Elderly")
	quietly xi: xtreg old rdp i.r if s2r1==0, cluster(hh1) fe robust
	outreg2 using clean/tables/core_old_v1, nonotes tex(frag) label append   keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg old rdp i.r if s2r1==1, cluster(hh1) fe robust
	outreg2 using clean/tables/core_old_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg old rdp rdp_large i.r , cluster(hh1) fe robust
	outreg2 using clean/tables/core_old_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
end	

program define core_regressions
	xtset pid
	quietly xi: xtreg zhfa rdp i.r if a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Health: Height for Age Z-Score") addnote("Includes Children under 7")
	quietly xi: xtreg zhfa rdp i.r if s2r1==0 & a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append   keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zhfa rdp i.r if s2r1==1 & a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zhfa rdp rdp_large i.r if a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
	
	quietly xi: xtreg zwfa rdp i.r if a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Health: Weight for Age Z-Score") addnote("Includes Children under 7")
	quietly xi: xtreg zwfa rdp i.r if s2r1==0 & a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zwfa rdp i.r if s2r1==1 & a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zwfa rdp rdp_large i.r if a<=7, cluster(hh1) fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
end


program define core_regressions_no_cluster
	xtset pid
	quietly xi: xtreg zhfa rdp i.r if a<=7,  fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Health: Height for Age Z-Score") addnote("Includes Children under 7")
	quietly xi: xtreg zhfa rdp i.r if s2r1==0 & a<=7,  fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append   keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zhfa rdp i.r if s2r1==1 & a<=7,  fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append  keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zhfa rdp rdp_large i.r if a<=7,  fe robust
	outreg2 using clean/tables/core_hfa_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
	
	quietly xi: xtreg zwfa rdp i.r if a<=7,  fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label replace keep(rdp) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Health: Weight for Age Z-Score") addnote("Includes Children under 7")
	quietly xi: xtreg zwfa rdp i.r if s2r1==0 & a<=7,  fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, Less than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zwfa rdp i.r if s2r1==1 & a<=7,  fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp) nocons addtext(Baseline Household Size, More than 4, Time Fixed Effects, YES, Individual Fixed Effects, YES)
	quietly xi: xtreg zwfa rdp rdp_large i.r if a<=7,  fe robust
	outreg2 using clean/tables/core_wfa_v1, nonotes tex(frag) label append keep(rdp rdp_large) nocons addtext( Time Fixed Effects, YES, Individual Fixed Effects, YES)
end


program define gen_rdp_size_interaction
	g rdp_large=rdp*s2r1
	label variable rdp_large "RDP x Large Baseline HH "
end
	

program define figure_1_rooms_distribution
	use clean/data_analysis/house_treat_regs, clear
	label_variables
	duplicates drop hh1, force
	hist rooms if rooms<10, by(rdp)
	graph export clean/tables/figure1.pdf, replace as(pdf)
	hist size if size<10, by(rdp)
	graph export clean/tables/figure2.pdf, replace as(pdf)
end

program define label_variables
	* Structure variables
	label variable size "Household Size"
	label variable child "Children"
	label variable adult_men "Adult Men"
	label variable adult_women "Adult Women"
	label variable old_men "Elderly Men"
	label variable old_women "Elderly Women"
	label variable old "Elderly"
	* HoH
	label variable p_hoh "Parent HoH"
	label variable g_hoh "Grand Parent HoH"
	label variable f_hoh "Father HoH"
	label variable m_hoh "Mother HoH"
	* Outcomes
	label variable zhfa "Height"
	label variable zwfa "Weight"
	label variable zbmi "BMI"
	label variable c_ill "Child ill for 3 days in last month"
	label variable c_check_up "Regular Check Ups"
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
	label variable piped "Piped Water"
	label variable mktv "Market Value"
	label variable qual "House Quality"
	label variable roof_cor "Corrugated Roof"
	label variable walls_b "Brick Walls"
	label variable toilet_share "Share Toilet"
	label variable flush "Flush Toilet"
	label variable c_sch_d "School Distance"
	* School Outcomes
	label variable c_absent "Days Absent"
	label variable c_failed "Failed Grade"
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
	use clean/data_analysis/house_treat_regs, clear
	egen max_rdp=max(rdp), by(pid)
	duplicates drop hh1, force
	tab max_rdp
end


main






*save clean/tables/, replace





