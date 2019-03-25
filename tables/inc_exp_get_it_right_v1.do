

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>13
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
	
		** PUBLIC GOOD SPENDING **	
			*Services and health!*
	foreach v in trans services health_exp sch_spending h_fdtot h_nfwatspn h_nfelespn {
	xi: reg `v'_ln_ch i.h_ch*size_lag lo i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag lo i.r, robust cluster(hh1)
	xi: reg `v'_e_ch i.h_ch*size_lag lo i.r, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag lo i.r, robust cluster(hh1)
	}
	
	foreach v in services public h_fdtot  h_nfwatspn h_nfelespn ex  {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_e_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	}
		
		** FOOD INTENSIVE MARGIN **
		
	foreach v in meat carbs veggies fats baby eat_out h_fdtot {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_e_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
	
	foreach v in meat carbs veggies fats baby eat_out h_fdtot {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_e_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	}
	
	foreach v in pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor  {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
		** !basically nothing happening! !income per person is not changing! **
	foreach v in pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor  {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg `v'_p_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	}



	foreach v in meat carbs veggies fats baby eat_out h_fdtot {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r if child>1, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r if child>1, robust cluster(hh1)
	}
		* nothing with food ** AT ALL **

	foreach v in hhincome home_prod public_other services ins comm vice exp1 inc_l inc_g inc_r inc {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}


	
		** WHAT IS GOING ON WITH INCOME?!
	foreach v in pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor  {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}

	foreach v in pi_hhincome pi_hhwage pi_hhgovt  pi_hhremitt  non_labor {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r if a<=16, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r if a<=16, robust cluster(hh1)
	}
	
	
		** FOOD AND AGRICULTURE ** ( FOOD EXTENSIVE MARGIN )
	foreach var of varlist h_agiseedspn h_agiinvspn h_agirepspn e_s {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]	
	}
	
	replace h_agrlnd_a=0 if h_agrlnd_a<=0 | h_agrlnd_a==.
	sort pid r
	by pid: g h_agrlnd_a_ch=h_agrlnd_a[_n]-h_agrlnd_a[_n-1]
	
	foreach var of varlist h_agcr h_ag h_agrlnd h_fdchi h_fdrm h_fdrmc h_fdmm h_fdsmp h_fdflr h_fdrice h_fdvegd h_fdpot h_fdsd h_fdout {
	replace `var'=0 if `var'==2
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
		** NUMBER EMPLOYED **
	foreach var of varlist e_s {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `var'_ch i.h_ch*size_lag i.r if a<=16, robust cluster(hh1)
	}
	
		** food! **
	foreach var of varlist  h_fdchi h_fdrm h_fdrmc  h_fdmm h_fdsmp h_fdflr h_fdrice h_fdvegd h_fdpot h_fdsd h_fdout {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
		* not a lot going on on the intensive margin with food
	
	** AGRICULTURE! **
	foreach var of varlist h_agrlnd_a h_agcr h_ag h_agrlnd {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
	
	

		* still have this labor effect, but not much else. , no net effect really!










	
	** WHAT HAPPNES IN THE CROSS SECTION
		* good news! * balance on size works! *
	g size_lag_2=size_lag*size_lag
	g size_lag_3=size_lag*size_lag_2
	xi: reg h_ch size_lag size_lag_2 size_lag_3 i.r if size_lag>1, robust cluster(hh1)
	xi: reg h_ch i.size_lag i.r if size_lag>1, robust cluster(hh1)
	
	
	xi: reg services_lnp i.h_ch*size i.r, robust cluster(hh1)
	* ONLY VERY SLIGHTLY ATTENUATED
	
	foreach v in  water_sp ele_sp mun_sp   {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
		
	foreach v in  fwag_ln fwag_ln_p inc_ln inc_ln_p inc_l_ln inc_l_ln_p inc_r_ln inc_r_ln_p inc_g_ln inc_g_ln_p  {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	

	
	foreach var of varlist young_child child young_adult adult old c_ya c_a c_y  {
	xi: reg `var'_ch i.h_ch*size_lag i.r if a<=16, robust cluster(hh1)
	}	
	**** ***** ****
	foreach v in inc_ln inc_ln_p food_ln food_ln_p public_ln public_ln_p services_ln services_ln_p health_exp_ln health_exp_ln_p sch_spending_ln sch_spending_ln_p exp1_ln exp1_ln_p {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
	foreach v in e_s e_r inc_ln inc_ln_p food_ln food_ln_p public_ln public_ln_p {
	xi: reg `v'_ch i.h_chl6*size_lag i.h_ch6*size_lag s6 i.r, robust cluster(hh1)
	}	
			

		


	
*	foreach var of varlist young_child child young_adult adult old c_ya  {
*	xi: reg `var'_ch i.h_ch*i.size_lag i.r, robust cluster(hh1)
*	}	
	
	
	
	foreach var of varlist young_child child young_adult adult old c_ya e_s e_r {
	xi: reg `var'_ch i.h_chl6*size_lag i.h_ch6*size_lag s6 i.r, robust cluster(hh1)
	}	
	
	
	
		* *	* SPENDING MECHANISMS * * *
	
	use clean/data_analysis/house_treat_regs, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>13
	** Log the expenditures
	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	
	** LOOK AT EXPENDITURE PER CAP
	
	g h_s=health_exp
	replace h_s=health_exp+sch_spending if sch_spending!=.
	replace h_s=sch_spending if h_s==. & sch_spending!=.
	
	
	foreach var of varlist services non_food food public exp1 health_exp sch_spending h_s {
	g `var'_ln=ln(`var')
	g `var'_lnp=ln(`var')/size
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_ln_pch=`var'_lnp[_n]-`var'_lnp[_n-1]
	}
	
	
	foreach var of varlist services non_food food public exp1 health_exp sch_spending h_s {
	xi: reg `var'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `var'_ln_pch i.h_ch*size_lag i.r, robust cluster(hh1)
	}



