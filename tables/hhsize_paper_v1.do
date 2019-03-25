

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

	use clean/data_analysis/house_treat_regs, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
*	tab size_lag h_ch if a<18
	replace size_lag=. if size_lag>13
		* both adjustments make sense!!
	
	sort pid r
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	
	foreach var of varlist zhfa zwfa  {
	xi: reg `var'_ch i.h_ch*size_lag a sex i.r, robust cluster(hh1)
	}
	foreach var of varlist zhfa zwfa  {
	xi: reg `var'_ch i.h_ch*size_lag a sex i.r if a<=7, robust cluster(hh1)
	}
	
	**
	g a_7=a<=7
	g h_ch7=h_ch*a_7
	g hn=h_ch
	replace hn=0 if a_7==1

	foreach var of varlist zhfa zwfa {
	xi: reg `var'_ch i.h_ch7*size_lag i.hn*size_lag a sex i.r, robust cluster(hh1)
	}
	
	g s6=size_lag>6
	g h_ch6=h_ch*s6
	g h_chl6=h_ch
	replace h_chl6=0 if s6==1
	
	foreach var of varlist zhfa zwfa {
	xi: reg `var'_ch i.h_chl6*size_lag i.h_ch6*size_lag s6 i.r if a<=7, robust cluster(hh1)
	}
	
	
		* * * FIRST STAGE * * *
		
	use clean/data_analysis/house_treat_regs, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>13
	drop child* adult* old*
	g young_child_id=(a>=0 & a<=2)
	egen young_child=sum(young_child_id), by(hhid)
	g child_id=(a>2 & a<=16)
	egen child=sum(child_id), by(hhid)
	g young_adult_id=(a>16 & a<=25)
	egen young_adult=sum(young_adult_id), by(hhid)
	g adult_id=(a>25 & a<=60)
	egen adult=sum(adult_id), by(hhid)
	g old_id=(a>60 & a<.)
	egen old=sum(old_id), by(hhid)
	g c_ya_id=(a>2 & a<=26)
	egen c_ya=sum(c_ya_id), by(hhid)
	egen e_s=sum(e), by(hhid)
	g e_r=e_s/size
	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	g h_s=health_exp
	replace h_s=health_exp+sch_spending if sch_spending!=.
	replace h_s=sch_spending if h_s==. & sch_spending!=.
	g s6=size_lag>6
	g h_ch6=h_ch*s6
	g h_chl6=h_ch
	replace h_chl6=0 if s6==1
	* ratio of children to adults
	g c_a=child/adult
	g c_y=child/(adult+young_adult)
	
	
	
	foreach var of varlist exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	g `var'_ln=ln(`var')
	g `var'_lnp=ln(`var')/size
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	}
	foreach var of varlist young_child child young_adult adult old c_ya e_s e_r c_a c_y {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}

	foreach v in home_prod public_other services ins comm vice exp1 inc_l inc_g inc_r inc {
	xi: reg `v'_ln_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg `v'_ln_p_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}

	
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



