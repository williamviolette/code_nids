clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"
	
	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>17
		
	
	g a0_3_id=(a>=0 & a<=3)
	egen a0_3=sum(a0_3_id), by(hhid)
	
*	g a4_16_id=(a>=4 & a<=16)
*	egen a4_16=sum(a4_16_id), by(hhid)

	g a4_18_id=(a>=4 & a<=18)
	egen a4_18=sum(a4_18_id), by(hhid)
	
*	g a17_25_id=(a>=18 & a<=25)
*	egen a17_25=sum(a17_25_id), by(hhid)
	
	g a19_60_id=(a>=19 & a<=60)
	egen a19_60=sum(a19_60_id), by(hhid)

		
*	g a26_60_id=(a>=26 & a<=60)
*	egen a26_60=sum(a26_60_id), by(hhid)

	g a61_id=(a>=61)
	egen a61=sum(a61_id), by(hhid)
	
	foreach var of varlist a0_3 a4_18 a19_60 a61 {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}	
	
	
	*** First stage: look at sizes
	xi: reg size_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label replace nocons title("Household Size")
	foreach v in a0_3 a4_18 a19_60 a61  {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons 
	}
	
	
	*** First stage: look at sizes for young children	
	xi: reg size_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_young_1, nonotes tex(frag) label replace nocons title("Household Size: Children under 16")
	foreach v in a0_3 a4_18 a19_60 a61{
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_young_1, nonotes tex(frag) label append nocons
	}
		
		
		
	use clean/data_analysis/house_treat_regs_anna_tables, clear

	
	
	
*	twoway lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(orange) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP and non-RDP") || lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(black)  || line rooms rooms if rooms<10, color(red) legend(label(1 "Control Population") label(2 "RDP Beneficiaries") label(3 "45 Degree Line"))
	twoway lowess size size_lag if h_ch==0 & size<12 & size_lag<12 , color(orange) xtitle("Size in t-1") ytitle("Size in t") title("Size t-1 against Size t for RDP and non-RDP") || lowess size size_lag if h_ch==1 & size<12 & size_lag<12, color(black) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/size_lowess_1.pdf, replace as(pdf)	

	*** overall rooms change
	twoway lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10, color(orange) xtitle("Rooms in t-1") ytitle("Rooms in t") title("Rooms t-1 against Rooms t for RDP and non-RDP") || lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(black) legend(label(1 "Control Population") label(2 "RDP Beneficiaries"))
	graph export clean/tables/rooms_lowess_1.pdf, replace as(pdf)	

	
	*** Z-Score for weight
*	twoway lfit zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2, color(orange) title("Weight t against Weight t+1 for RDP and non-RDP (Lfit)") || scatter zwfa_ch size_lag if h_ch==1 & size_lag<14 & size_lag>2, color(orange) || lfit zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2  ||  scatter zwfa_ch size_lag if h_ch==0 & size_lag<14  & size_lag>2, color(purple)  
	twoway lfit zwfa_ch size_lag if h_ch==0 & size_lag<14 & size_lag>1 & a<=7 & zwfa_ch>-1 & zwfa_ch<1, color(orange) xtitle("Household Size in t-1") ytitle("Change in Weight Z-score from t-1 to t") title("Change in Weight Z-Score across Household Size in t-1") || scatter zwfa_ch size_lag if h_ch==0 & size_lag<14 & size_lag>1 & zwfa_ch>-1 & zwfa_ch<1 & a<=7, color(orange) || lfit zwfa_ch size_lag if h_ch==1 & size_lag<14  & size_lag>1  & a<=7 & zwfa_ch>-1 & zwfa_ch<1 ||  scatter zwfa_ch size_lag if h_ch==1 & size_lag<14  & size_lag>1  & a<=7 & zwfa_ch>-1 & zwfa_ch<1, color(purple) legend(label(1 "Control Population (lfit)") label(2 "Control Population (points)") label(3 "RDP Beneficiaries (lfit)") label(4 "RDP Beneficiaries (points)"))  
	graph export clean/tables/weight_lfit_1.pdf, replace as(pdf)

	
		
	*** Reduced form: size 	

	xi: reg zwfa_ch i.h_ch*size_lag a sex i.r if a<=7 & zwfa_ch<1 & zwfa_ch>-1, robust cluster(hh1)
	outreg2 using clean/tables/health_1, nonotes tex(frag) label replace nocons title("Weight for Age for Children under 7")	
	xi: reg zhfa_ch i.h_ch*size_lag a sex i.r if a<=7 & zhfa_ch<1 & zwfa_ch>-1, robust cluster(hh1)
	outreg2 using clean/tables/health_1, nonotes tex(frag) label append nocons
	

	label variable wath "Piped Water"
	label variable toih "Flush Toilet"
	label variable food "Food Expenditure"

	xi: reg wath_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_1, nonotes tex(frag) label replace nocons title("Mechanisms")		
	foreach v in toih inc_ln_p inc_l_ln_p public_ln_p h_fdtot_ln_p {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_1, nonotes tex(frag) label append nocons
	}
	
	xi: reg h_nfwatspn_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_2, nonotes tex(frag) label replace nocons title("Mechanisms Continued")		
	foreach v in expenditure_ln_p veggies_ln_p fats_ln_p pi_hhgovt_ln_p pi_hhremitt_p {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/alt_mech_2, nonotes tex(frag) label append nocons
	}	
	

	
	
	
	
