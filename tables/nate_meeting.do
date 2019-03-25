clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"
	
	
	use clean/data_analysis/house_treat_regs, clear
	
	egen inc_m=max(inc), by(pid)
	drop if inc_m>13000
	
	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	
	g h_s=health_exp
	replace h_s=health_exp+sch_spending if sch_spending!=.
	replace h_s=sch_spending if h_s==. & sch_spending!=.
		
	foreach var of varlist non_food food public exp1 services health_exp sch_spending h_s {
	g `var'_ln=ln(`var')
	g `var'_lnp=`var'_ln/size
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_lnp_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	}
	replace size_lag=. if size_lag>11
	
	
	xi: reg food_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_1", nonotes tex(frag) label replace nocons title("Change in Log Expenditure")
	foreach var of varlist non_food public exp1 services h_s  {
	xi: reg `var'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_1", nonotes tex(frag) label append nocons title("Change in Log Expenditure")
	}
	
	xi: reg food_lnp_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_2", nonotes tex(frag) label replace nocons title("Change in Log Expenditure Per Person")
	foreach var of varlist non_food public exp1 services  {
	xi: reg `var'_lnp_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_2", nonotes tex(frag) label append nocons title("Change in Log Expenditure Per Person")
	}
	
	
		** ** now look at those left out:
	g h_chr2=h_ch if r==2
	g h_chr3=h_ch if r==3
	
	egen rdp_hh1r2=max(h_chr2), by(hh1)
	egen rdp_hh1r3=max(h_chr3), by(hh1)
	
	egen rdp_pidr2=max(h_chr2), by(pid)
	egen rdp_pidr3=max(h_chr3), by(pid)
	
	g lor2=(rdp_hh1r2==1 & rdp_pidr2==0 & r==2)
	g lor3=(rdp_hh1r3==1 & rdp_pidr3==0 & rdp_pidr2==0 & r==3)
	
	g lo=1 if lor2==1 | lor3==1
	replace lo=0 if lo!=1 & r>=2
	g lo1=lo
	sort pid r
	by pid: replace lo1=1 if lo1[_n-1]==1
	replace lo1=0 if r==1 
	
	g inf=(h_dwltyp==7 | h_dwltyp==8)

	xtset pid
	xi: xtreg inf lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) label replace nocons title("Left-Out of Housing")
	xi: xtreg size lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) append nocons title("Left-Out of Housing")
	xi: xtreg e lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) label append nocons title("Left-Out of Housing")
	xi: xtreg ue lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) label append nocons title("Left-Out of Housing")
	xi: xtreg inc lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) label append nocons title("Left-Out of Housing")
	xi: xtreg food lo1 i.r, fe robust cluster(hh1)
	outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/nate_3", nonotes tex(frag) label append nocons title("Left-Out of Housing")




	*** overall size change
	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 , color(orange) title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_ch==0 & size<12 & size_lag<12, color(black) 
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
	
	
	
	
	
	
	
	
