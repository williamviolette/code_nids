
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	quietly sum_rdp_numbers
	quietly clean_data
	quietly label_variables
	quietly figure_1_rooms_distribution
	quietly figure_2_rooms_t
	quietly summary_stats
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear

	
end

program define summary_stats
	use clean/data_analysis/house_treat_regs_anna_tables, clear
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
	replace c_ill=. if a>12
	drop if rdp==.
	replace mktv=. if mktv>60000
	keep rdp zhfa zwfa c_ill c_health size child adult old inc health_exp sch_spending food ex rooms piped flush mktv roof_cor walls_b
	order rdp zhfa zwfa c_ill c_health size child adult old inc health_exp sch_spending food ex rooms piped flush mktv roof_cor walls_b
	rename rdp RDP
	bysort RDP: outreg2 using clean/tables/sum_1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics by RDP Treatment Status") addnote("Child Health ranges from 1 Healthy to 5 Sick")
end


program define figure_1_rooms_distribution
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	label_variables
	duplicates drop hh1, force
	hist rooms if rooms<10, by(rdp)
	graph export clean/tables/figure1.pdf, replace as(pdf)
end
	
program define figure_2_rooms_t
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	label_variables
*	twoway lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(orange) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP and non-RDP") || lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(black)  || line rooms rooms if rooms<10, color(red) legend(label(1 "Control Population") label(2 "RDP Beneficiaries") label(3 "45 Degree Line"))
	twoway lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(orange) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP and non-RDP") || lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(black) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/figure2.pdf, replace as(pdf)	
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




program define working


	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12, color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)")
	graph export clean/tables/size_lowess_1.pdf, replace as(pdf)	
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 , color(orange) || lfit size size_lag if h_ch==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lfit)")
	graph export clean/tables/size_lfit_1.pdf, replace as(pdf)

	*** OVERALL SIZE CHANGE FOR YOUNG CHILDREN
	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & a<=7, color(orange) title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & a<=7, color(black) 
	graph export clean/tables/size_lowess_yc_1.pdf, replace as(pdf)	
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 & a<=7, color(orange) title("Size t against Size t+1 for RDP and non-RDP (Lfit)") || lfit size size_lag if h_ch==0 & size<12 & size_lag<12 & a<=7, color(black) 
	graph export clean/tables/size_lfit_yc_1.pdf, replace as(pdf)

	twoway lowess child size_lag if h_ch==1 & size<12 & size_lag<12 & a<=7, color(orange) title("Size t against Child t+1 for RDP and non-RDP (Lowess)") || lowess child size_lag if h_ch==0 & size<12 & size_lag<12 & a<=7, color(black) 
	graph export clean/tables/child_lowess_yc_1.pdf, replace as(pdf)	
	twoway lfit child size_lag if h_ch==1 & size<12 & size_lag<12 & a<=7, color(orange) title("Size t against Child t+1 for RDP and non-RDP (Lfit)") || lfit child size_lag if h_ch==0 & size<12 & size_lag<12 & a<=7, color(black) 
	graph export clean/tables/child_lfit_yc_1.pdf, replace as(pdf)


	*** overall rooms change
	twoway lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(orange) title("Rooms t against Rooms t+1 for RDP and non-RDP (Lowess)") || lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(black)
	graph export clean/tables/rooms_lowess_1.pdf, replace as(pdf)	
	twoway lfit rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(orange) title("Rooms t against Rooms t+1 for RDP and non-RDP (Lfit)") || lfit rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(black)
	graph export clean/tables/rooms_lfit_1.pdf, replace as(pdf)
	
	*** Z-Score for weight
*	twoway lfit zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2, color(orange) title("Weight t against Weight t+1 for RDP and non-RDP (Lfit)") || scatter zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2, color(orange) || lfit zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2  ||  scatter zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2, color(purple)  
	twoway lfit zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2 & a<=7, color(orange) title("Weight t against Weight t+1 for RDP and non-RDP (Lfit)") || scatter zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2  & a<=7, color(orange) || lfit zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2  & a<=7  ||  scatter zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2  & a<=7, color(purple)  
	graph export clean/tables/weight_lfit_1.pdf, replace as(pdf)


	*** First stage: look at sizes
	xi: reg size_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label replace nocons title("First Stage: Household Size")
	foreach v in adult child old {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons title("First Stage: Household Size")
	}
	
	
	*** Expenditure patterns
	xi: reg size_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label replace nocons title("First Stage: Household Size")
	foreach v in adult child old {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons title("First Stage: Household Size")
	}
	
	
	
	
	*** First stage: look at sizes for young children	
	xi: reg size_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_young_1, nonotes tex(frag) label replace nocons title("First Stage: Household Size: For young children")
	foreach v in adult child old {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_young_1, nonotes tex(frag) label append nocons
	}
	
	
	*** Reduced form: size 	

	xi: reg zwfa_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/health_1, nonotes tex(frag) label replace nocons title("First Stage: Household Size: For young children")	
	xi: reg zhfa_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/health_1, nonotes tex(frag) label append nocons title("First Stage: Household Size: For young children")	
	
	*** Alternative mechanisms
	
	label variable wath "Piped Water"
	label variable toih "Flush Toilet"
	label variable food "Food Expenditure"

	xi: reg wath_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_1, nonotes tex(frag) label replace nocons title("Alternative Mechanisms")		
	foreach v in toih inc own food {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_1, nonotes tex(frag) label append nocons title("Alternative Mechanisms")
	}
	
end	
	


program define clean_data
	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>13
	replace size=. if size>13
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
	foreach var of varlist h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	quietly	g `var'_ln=ln(`var')
	quietly g `var'_lnp=ln(`var')/size
	quietly g `var'_p=`var'/size
	quietly g `var'_e=`var'/ex
	replace `var'_e=. if `var'==0 | ex==0
	quietly sort pid r
	quietly by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	quietly by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	quietly by pid: g `var'_e_ch=`var'_e[_n]-`var'_e[_n-1]
	quietly by pid: g `var'_p_ch=`var'_p[_n]-`var'_p[_n-1]
	}
	save clean/data_analysis/house_treat_regs_anna_tables, replace
end


program define label_variables
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
	
main
	
	

	
	
	
	
	
	
	
