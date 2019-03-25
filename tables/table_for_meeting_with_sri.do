clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"
	
	
	use clean/data_analysis/house_treat_regs, clear
	
	egen inc_m=max(inc), by(pid)
	drop if inc_m>13000

	twoway lowess size1 size_lag if h_ch==1 & size<12 & size_lag<12 , color(orange) title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size1 size_lag if h_ch==0 & size<12 & size_lag<12, color(black) 

	graph export clean/tables/size_lowess_1.pdf, replace as(pdf)	
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 , color(orange) title("Size t against Size t+1 for RDP and non-RDP (Lfit)") || lfit size size_lag if h_ch==0 & size<12 & size_lag<12, color(black) 
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
	
	
	
	
	
	
	
	
