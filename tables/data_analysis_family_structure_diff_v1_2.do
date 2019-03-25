
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main_2
 	use clean/data_analysis/house_treat, clear
  	drop if hhgeo2011==1 | hhgeo2011==3 | hhgeo2011==-3 | hhgeo2011==.
*  	drop if hhgeo2011==1 | hhgeo2011==-3 | hhgeo2011==.
  	keep if (best_race==1 | best_race==2)
*  	keep if (best_race==1 | best_race==2 | best_race==4)
  	quietly hsub9
	quietly change_variables
	quietly drop_rdp_leavers
	quietly rebalance
 	quietly construct_hh1
	g mdb=hhdc2011
	replace mdb=gc_dc2011 if mdb==.
 	save clean/data_analysis/house_treat_regs, replace
end

*****
program define hsub9
  	g h_sub9=h_sub==-9
  	egen h_sub9m=max(h_sub9), by(pid)
  	drop if h_sub9m==1
end

program define drop_rdp_leavers
	egen min_h_ch=min(h_ch), by(pid)
	egen max_h_ch=max(h_ch), by(pid)
	egen max_rdp=max(rdp), by(pid)
	g rdp_r1=rdp if r==1
	egen rdp_r1m=max(rdp_r1), by(pid)
	drop if rdp_r1m==1
	drop if min_h_ch<0
	drop if max_rdp==1 & max_h_ch<1
end

program define construct_hh1
	g hhid1=hhid if r==1
	g hhid2=hhid if r==2
	g hhid3=hhid if r==3
	egen h1=max(hhid1), by(pid)
	egen h2=max(hhid2), by(pid)
	egen h3=max(hhid3), by(pid)
	g hh1=h1
	replace hh1=h2 if hh1==.
	replace hh1=h3 if hh1==.
end
	
program define change_variables
	g wath=water==1
	g toih=toilet==1
	g concrete=floor==2
	sort pid r
	by pid: g h_ch=rdp[_n]-rdp[_n-1]
	g adult=adult_men+adult_women
	replace c_absent=0 if c_absent==. & c_failed==0 
	foreach v in h_empl h_rent h_grn h_prvpen h_tinc e ue c_failed c_absent zwfa zhfa zbmi rooms size own flush piped adult_men adult_women adult old child inc_l inc_r inc fwag owner walls_b roof_cor wath toih concrete  sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	by pid: g `v'_ch=`v'[_n]-`v'[_n-1]
	by pid: g `v'_lag=`v'[_n-1]
	g `v'_r1_id=`v' if r==1
	egen `v'r1=max(`v'_r1_id), by(pid)
	g `v'_r2_id=`v' if r==2
	egen `v'r2=max(`v'_r2_id), by(pid)
	replace `v'r1=`v'r2 if `v'r1==. & r>=2	
	drop `v'_r1_id `v'_r2_id `v'r2
	}
	foreach v in inc inc_l inc_r fwag sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	g `v'p=`v'/size
	sort pid r
	by pid: g `v'_pch=`v'p[_n]-`v'p[_n-1]
	}
end

program define rebalance
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd
*	keep if rid==123
end


program define size_graphs

	
	** WHY ARE ROUNDS SO DIFFERENT * rooms distribution is different (could just be measurement, but size changes?)
	
	use clean/data_analysis/house_treat_regs, clear
	
	egen inc_m=max(inc), by(pid)
	drop if inc_m>13000
	egen max_size=max(size), by(pid)	
*	drop if max_size>=11
	egen min_size=min(size), by(pid)
*	drop if min_size<=1
	replace rooms_ch=. if rooms_ch<-5 & rooms_ch>5
*  	drop if prov==9 | prov==-3 | prov==10 | prov==6 | prov==8
*  	drop if prov==9 | prov==-3 | prov==10
*	egen m_h_ch=mean(h_ch), by(mdb)
*	drop if m_h_ch<.10
	g ordpr2_id=(h_ch==1 & own==1 & r==2)
	egen ordpr2=sum(ordpr2_id), by(cluster)
	g ordpr3_id=(h_ch==1 & own==1 & r==3)
	egen ordpr3=sum(ordpr3_id), by(cluster)
*	drop if ordpr2==0 | ordpr3==0	
*	drop if own==0 & h_ch==1
	g r3id=r==3


	*** EMOTIONAL WELL BEING IS KINDA COOL: SOME PREDICTED DIRECTIONS
	foreach var of varlist a_em* {
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach var of varlist a_em* {
	xi: reg `var'_ch i.h_ch*size_lag i.r if size_lag<15, robust cluster(hh1)
	}
	
	foreach var of varlist h_empl h_rent h_grn h_prvpen h_tinc {
	xi: reg `var'_ch i.h_ch*size_lag i.r if size_lag<15, robust cluster(hh1)
	}
	
	
	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & size>1 & size_lag>1, color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & size>1 & size_lag>1
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 & size>1 & size_lag>1, color(orange) || lfit size size_lag if h_ch==0 & size<12 & size_lag<12 & size>1 & size_lag>1


	** actually interested in when children are present
	* size size_lag
	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & size>1 & size_lag>1 & a<=10 & (zwfa!=. | zhfa!=.), color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & size>1 & size_lag>1 & a<=10 & (zwfa!=. | zhfa!=.)
*	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & size>1 & size_lag>1 & a<=10, color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & size>1 & size_lag>1 & a<=10

	* child child_lag
	twoway lowess child child_lag if h_ch==1 & child<6 & child_lag<6 & a<=7, color(orange) || lowess child child_lag if h_ch==0 & child<6 & child_lag<6 & a<=7
	* child size_lag
	twoway lowess child size_lag if h_ch==1 & child<6 & size_lag<12 & a<=7, color(orange) || lowess child size_lag if h_ch==0 & child<6 & size_lag<12 & a<=7



	twoway lfit size size_lag if h_ch==1 &  size<12 & size_lag<12 & size>2 & size_lag>2 , color(orange) || lfit size size_lag if h_ch==0 & size<12 & size_lag<12 & size>2 & size_lag>2

	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & r==2, color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & r==2
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 & r==2, color(orange) || lfit size size_lag if h_ch==0 & size<12 & size_lag<12 & r==2

	twoway lowess size size_lag if h_ch==1 & size<12 & size_lag<12 & r==3, color(orange) || lowess size size_lag if h_ch==0 & size<12 & size_lag<12 & r==3
	twoway lfit size size_lag if h_ch==1 & size<12 & size_lag<12 & r==3, color(orange) || lfit size size_lag if h_ch==0 & size<12 & size_lag<12 & r==3



*** here we go	

	twoway lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(orange) || lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10
	twoway lfit rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10, color(orange) || lfit rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10
	
	twoway lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10 & r==2, color(orange) || lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10 & r==2
	twoway lfit rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10 & r==2, color(orange) || lfit rooms rooms_lag if h_ch==0 & rooms<10 & & rooms_lag<10 & r==2

	twoway lowess rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10 & r==3, color(orange) || lowess rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10 & r==3	
	twoway lfit rooms rooms_lag if h_ch==1 & rooms<10 & rooms_lag<10 & r==3, color(orange) || lfit rooms rooms_lag if h_ch==0 & rooms<10 & rooms_lag<10 & r==3


	twoway lowess zwfa_ch size_lag if h_ch==1 & size_lag<10 & size_lag>2, color(orange) || lowess zwfa_ch size_lag if h_ch==0 & size_lag<10  & size_lag>2

	twoway lfit zwfa_ch size_lag if h_ch==1 & size_lag<10 & size_lag>2, color(orange) || scatter zwfa_ch size_lag if h_ch==1 & size_lag<10 & size_lag>2, color(orange) || lfit zwfa_ch size_lag if h_ch==0 & size_lag<10  & size_lag>2  ||  scatter zwfa_ch size_lag if h_ch==0 & size_lag<10  & size_lag>2, color(purple)  


	twoway lowess zwfa zwfa_lag if h_ch==1 & zwfa<4 & zwfa_lag<4, color(orange) || lowess zwfa_lag zwfa if h_ch==0 & zwfa<4 & zwfa_lag<4
	twoway lfit zwfa zwfa_lag if h_ch==1 & zwfa<4 & zwfa_lag<4, color(orange) || lfit zwfa_lag zwfa if h_ch==0 & zwfa<4 & zwfa_lag<4

	
	** Driven by children! **
	
	xi: reg c_failed_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	xi: reg c_absent_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	
	
	foreach v in wath toih inc concrete own food food_imp {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7 & (zwfa_ch!=. | zhfa_ch!=.), robust cluster(hh1)
	}
	** opposite directions
	
	
	foreach v in size adult child old {
	xi: reg `v'_ch i.h_ch*`v'_lag i.r if a<=7 & (zwfa_ch!=. | zhfa_ch!=.), robust cluster(hh1)
	}
	
	*** MECHANISMS ***
	foreach v in  sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}
	
	
	foreach v in  sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	}
	
	** *** ** *** ** *** ** *** **	
	
	foreach v in non_food public food food_imp services water_exp ele_exp {
	xi: reg `v'_pch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	foreach v in non_food public food food_imp services water_exp ele_exp {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
	foreach v in inc inc_l inc_r fwag e ue {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	** work subsitution?
	foreach v in inc inc_l inc_r fwag e ue {
	xi: reg `v'_pch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
	
	foreach v in size adult child old {
	xi: reg `v'_ch i.h_ch*`v'_lag i.r if a<=7, robust cluster(hh1)
	}
	
	foreach v in size adult_men adult_women adult child old {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=10, robust cluster(hh1)
	}	
	
	tab size_lag h_ch if zwfa_ch!=.
	tab size_lag h_ch if zhfa_ch!=.

	tab a h_ch if zwfa_ch!=.
	tab a h_ch if zhfa_ch!=.
		
	tab child_lag h_ch if zwfa_ch!=.
	
	
		
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*size_lag i.size_lag i.r if a<=7 & size_lag<14 & size_lag>2, robust cluster(hh1)
	}
	

	xi: reg zwfa_ch i.h_ch*size_lag i.r if a<=7 & a>1, robust cluster(hh1)
	xi: reg zwfa_ch i.h_ch*size_lag i.r if size_lag<12 & a<=7 & a>1, robust cluster(hh1)

	xi: reg zhfa_ch i.h_ch*size_lag i.r if a<=7 & a>1, robust cluster(hh1)
	xi: reg zhfa_ch i.h_ch*size_lag i.r if size_lag<12 & a<=7 & a>1, robust cluster(hh1)

	
	
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	}
	
	** pretty robust to different income thresholds
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7 & inc_m<8000, robust cluster(hh1)
	}
	
	*** WORRIED THAT IT IS ONLY DRIVEN BY THE TOP END!
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*i.size_lag i.r if a<=7 & size_lag>1, robust cluster(hh1)
	}
	*** how to think about this!?
	
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7 & size_lag>1 & size_lag<10, robust cluster(hh1)
	}
	
	

	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*child_lag i.r if a<=7 & child_lag<6, robust cluster(hh1)
	}
	
	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*child_lag i.r if a<=7, robust cluster(hh1)
	}

	foreach v in zwfa zhfa {
	xi: reg `v'_ch i.h_ch*size_lag i.r if a<=7, robust cluster(hh1)
	}
	

		* driven by round 3
	

	foreach v in size adult_men adult_women child old {
	reg `v' `v'_lag if h_ch==1 & r==2, robust
	reg `v' `v'_lag if h_ch==1 & r==3, robust
	reg `v' `v'_lag if h_ch==0 & r==2, robust
	reg `v' `v'_lag if h_ch==0 & r==3, robust
	}
	
	
	foreach v in adult {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 , color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15
	}
	foreach v in adult {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==2, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==2
	}
	foreach v in adult {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 , color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==3
	}

	foreach v in child {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 , color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15
	}
	foreach v in child {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==2, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==2
	}
	foreach v in child {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==3, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==3
	}
	** child lowess! **
	foreach v in child {
	twoway lowess `v' `v'_lag if h_ch==1 & `v'<7 & `v'_lag<7 , color(orange) || lowess `v'_lag `v' if h_ch==0 & `v'<7 & `v'_lag<7
	}
	
	foreach v in child {
	twoway lowess `v' `v'_lag if h_ch==1 & `v'<7 & `v'_lag<7 & r==2, color(orange) || lowess `v'_lag `v' if h_ch==0 & `v'<7 & `v'_lag<7 & r==2
	}
	foreach v in child {
	twoway lowess `v' `v'_lag if h_ch==1 & `v'<7 & `v'_lag<7 & r==3, color(orange) || lowess `v'_lag `v' if h_ch==0 & `v'<7 & `v'_lag<7 & r==3
	}

	foreach v in old {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 , color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15
	}
	foreach v in old {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==2, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==2
	}
	foreach v in old {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==3, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==3
	}


	foreach v in own {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 , color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15
	}
	foreach v in own {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==2, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==2
	}
	foreach v in own {
	twoway lfit `v' `v'_lag if h_ch==1 & `v'<15 & `v'_lag<15 & r==3, color(orange) || lfit `v'_lag `v' if h_ch==0 & `v'<15 & `v'_lag<15 & r==3
	}

	
*	duplicates drop hhid, force

	
	reg r3id size child old inc e a sex wath toih rooms own roof_cor walls_b concrete improve if h_ch==1 & rooms<6, robust
	* URBAN
	reg r3id size childr1 old incr1 e a sex wath toih rooms own roof_cor walls_b concrete improve if h_ch==1 & hhgeo2011==2, robust
	* RURAL
	reg r3id size child old inc e a sex wath toih rooms own roof_cor walls_b concrete improve if h_ch==1 & hhgeo2011!=2, robust

	
	tab mdb h_ch

	tab mdb h_ch if r==2, mis 
	tab mdb h_ch if r==3, mis
	
	hist floor, by(h_ch r)
	
	hist incr1 if incr1<10000 & hhgeo2011!=3, by(h_ch)

	hist inc_lr1 if inc_lr1<6000 & hhgeo2011!=3, by(hhgeo2011 h_ch)
	hist inc_l if inc_l<6000 & hhgeo2011!=3, by(hhgeo2011 h_ch)

	hist inc_lr1 if inc_lr1<8000 & hhgeo2011==2, by(r h_ch)
	hist inc_l if inc_l<8000 & hhgeo2011!=3, by(hhgeo2011 h_ch)
	** only 320: not worth it
	
	hist wath, by(h_ch r)


	
	reg r3id size wath toih rooms inc ue own roof_cor walls_b if h_ch==1, robust

	reg r3id a sex size child wath toih rooms own roof_cor walls_b if h_ch==0, cluster(hh1) robust
	
	reg r3id a sex size child wath toih rooms own roof_cor walls_b if (h_ch==0 | h_ch==.) & rid==123, cluster(hh1) robust


	reg r3id a sex size child wath toih rooms own roof_cor walls_b if h_ch==1 & own==1, cluster(hh1) robust

	foreach var of varlist a sex size child wath toih rooms own roof_cor walls_b {
	reg `var' r3id i.mdb if h_ch==1, cluster(hh1) robust
	}

	

	forvalues r=1/5 {
	reg r3id a sex size child wath toih rooms own roof_cor walls_b if h_ch==1 & prov==`r', cluster(hh1) robust
	}
	reg r3id a sex size child wath toih rooms own roof_cor walls_b if h_ch==1 & prov==7, cluster(hh1) robust

	
	foreach var of varlist own_ch rooms_ch piped_ch flush_ch walls_b_ch roof_cor_ch wath_ch toih_ch concrete_ch {
*	reg `var' h_ch i.r, robust cluster(hh1)
	reg `var' h_ch i.r if r==2, robust cluster(hh1)
	reg `var' h_ch i.r if r==3, robust cluster(hh1)
	}

*   these material results are very consistent

	foreach var of varlist size_ch child_ch adult_men_ch adult_women_ch old_ch {
	reg `var' h_ch i.r, robust cluster(hh1)
	reg `var' h_ch i.r if r==2, robust cluster(hh1)
	reg `var' h_ch i.r if r==3, robust cluster(hh1)
	}

	foreach var of varlist size_ch child_ch adult_men_ch adult_women_ch old_ch {
*	xi: reg `var' h_ch i.size_lag i.mdb, robust cluster(hh1)
	xi: reg `var' h_ch i.size_lag if r==2 & own==1, robust cluster(hh1)
	xi: reg `var' h_ch i.size_lag if r==3 & own==1, robust cluster(hh1)
	}
	
	** what do i trust? what is driving large differences across rounds?
	
	tab cluster own if h_ch==1 & r==2
	
	tab cluster own if h_ch==1 & r==3
	
	hist mktv if mktv<100000, by(r own h_ch)
	


	reg r3id a sex size child rooms wath own flush roof_cor walls_b if h_ch==1, cluster(hh1) robust

	hist own if rdp==0 & rid==123, by(r)

	reg r3id a sex size child inc rooms piped own flush roof_cor walls_b rent_d improve if h_ch==1, cluster(hh1) robust
	
	** WHAT IF PROJECT IS BUILT THEN PEOPLE MOVE IN TO RENT IN THE LATER WAVES? **
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b rent_d improve if h_ch==1 & ((h_chr2>20 & h_chr3<10) | (h_chr3>20 & h_chr2<10)), cluster(hh1) robust
	** ** not really ** **

	reg r3id a sex size child  rooms piped own flush roof_cor walls_b i.mdb if h_ch==1, cluster(hh1) robust

	reg r3id a sex size child  rooms piped own flush roof_cor walls_b i.mdb if h_ch==0 & rid==123, cluster(hh1) robust

	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & h_chr2>5 & h_chr3>5, cluster(hh1) robust
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & h_chr2>20 & h_chr3>20, cluster(hh1) robust
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & h_chr2>30 & h_chr3<5, cluster(hh1) robust


	** remarkably consistent: the houses truly are different
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & h_chr2>50 & h_chr2<100 & h_chr3>50 & h_chr3<100, cluster(hh1) robust
	
	tab own rent_d if h_ch==1
		* a lot of households own but don't pay rent..
	tab own rent_d if h_ch==1 & r==2
	tab own rent_d if h_ch==1 & r==3
		* round 3 has a lot of households paying rent
	
	tab mdb own if h_ch==1
	tab mdb own if h_ch==1 & r==2
	tab mdb own if h_ch==1 & r==3

	tab mdb own if h_ch==1 & inc_m<5000
	tab mdb own if h_ch==1 & r==2 & inc_m<5000
	tab mdb own if h_ch==1 & r==3 & inc_m<5000
	
	tab move own if h_ch==1 & r==2
	tab move own if h_ch==1 & r==3
	
	hist mktv if h_ch==1 & mktv<100000, by(own r)

	reg own piped flush roof_cor walls_b if h_ch==1 & rid==123, robust cluster(hh1)
	

	
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & own==1, cluster(hh1) robust

		* market value restriction, still large differences
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b i.prov if h_ch==1 & house==1 & mktv>=10000 & mktv<=60000, cluster(hh1) robust
		* the biggest issue is the ownership
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b i.prov if own==1 & h_ch==1 & house==1 & mktv>=10000 & mktv<=60000, cluster(hh1) robust
		* and the materials are different..
	


	
	reg r3id a sex size child  rooms piped own flush roof_cor walls_b i.mdb if h_ch==1 & own==1, cluster(hh1) robust

	reg r3id a sex size child  rooms piped own flush roof_cor walls_b if h_ch==1 & h_dwltyp==1 & rid==123, cluster(hh1) robust

	hist h_dwltyp, by(h_ch r own)
	
	hist own, by(h_ch r)
	hist toilet, by(h_ch r)
	

	* OWN IS CONSISTENTLY NEGATIVE

	reg r3 a sex size child  rooms_ch piped_ch own_ch flush_ch roof_cor walls_b i.mdb if h_ch==1, cluster(hh1) robust
	reg r3 a sex size child  rooms_ch piped_ch own_ch flush_ch roof_cor walls_b i.mdb if h_ch==1 & rid==123, cluster(hh1) robust

	* the houses are just way worse in the third round!
			* THE OWNERSHIP VARIABLE IS THE BIG KICKER!
	
	
** these are less consistent: what is going on?


	foreach var of varlist own_ch rooms_ch piped_ch flush_ch {
	reg `var' h_chm i.r, robust cluster(hh1)
	}


	
	hist mktv if mktv<60000, by(r h_ch)
	
	* why are the results different?




	global l_b "1000"
	global u_b "8000"

	foreach v in h own flush rooms piped {
	xi: reg `v'_ch i.il*inc_lr1 inc i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=., cluster(hh1) robust
	}
	
	foreach v in h own flush rooms piped {
	xi: reg `v'_ch i.il*inc_lr1 if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=. & r==2, cluster(hh1) robust
	xi: reg `v'_ch i.il*inc_lr1 if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=. & r==3, cluster(hh1) robust
	}
	
	foreach v in h own flush rooms piped {
	xi: reg `v'_ch i.il*inc_lr1 i.il*inc_lr1_2 i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=., cluster(hh1) robust
	}
	
	foreach v in own flush rooms piped {
	xi: reg `v'_ch h_ch i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=., cluster(hh1) robust
	}

	foreach v in size adult_men adult_women child old {
	xi: reg `v'_ch i.h_ch*i.size_lag i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=., cluster(hh1) robust
	}

	foreach v in size adult_men adult_women child old {
	xi: reg `v'_ch h_ch i.size_lag i.r if h_ch!=., cluster(hh1) robust
	}
	
	foreach v in size adult_men adult_women child old {
	xi: reg `v'_ch h_ch i.size_lag i.r*i.prov if h_ch!=., cluster(hh1) robust
	}
	
			
	foreach v in size adult_men adult_women child old {
	xi: reg `v'_ch h_ch i.size_lag i.r*i.prov if h_ch!=. & r==2, cluster(hh1) robust
	xi: reg `v'_ch h_ch i.size_lag i.r*i.prov if h_ch!=. & r==3, cluster(hh1) robust
	}
	
	
	forvalues r=1/8 {
	foreach v in child {
	xi: reg `v'_ch h_ch i.size_lag i.r if h_ch!=. & r==2 & prov==`r', cluster(hh1) robust
	xi: reg `v'_ch h_ch i.size_lag i.r if h_ch!=. & r==3 & prov==`r', cluster(hh1) robust
	}
	}
	** problem is in prov1
	
	xi: reg child_ch h_ch i.size_lag i.r if h_ch!=. & r==2 & prov!=1, cluster(hh1) robust
	xi: reg child_ch h_ch i.size_lag i.r if h_ch!=. & r==3 & prov!=1, cluster(hh1) robust
	
	
	foreach v in own flush rooms piped {
	xi: reg `v'_ch h_ch i.r if  r==2, cluster(hh1) robust
	xi: reg `v'_ch h_ch i.r if  r==3, cluster(hh1) robust
	}	
		
	foreach v in own flush rooms piped {
	xi: reg `v'_ch h_ch i.r if inc_lr1<$u_b & inc_lr1>$l_b & r==2, cluster(hh1) robust
	xi: reg `v'_ch h_ch i.r if inc_lr1<$u_b & inc_lr1>$l_b & r==3, cluster(hh1) robust
	}
	
	** income lag
	foreach v in h own flush rooms piped {
	xi: reg `v'_ch i.ill*inc_ll  i.r if inc_ll<$u_b & inc_ll>$l_b & h_ch!=., cluster(hh1) robust
	}
	foreach v in own flush rooms piped {
	xi: reg `v'_ch h_ch i.r if inc_ll<$u_b & inc_ll>$l_b, cluster(hh1) robust
	}
	
	xi: reg zwfa_ch i.h_ch*i.size_lag4 zwfa_lag i.r, robust cluster(hh1)

	xi: reg zwfa_ch i.h_ch*i.size_lag4  i.r, robust cluster(hh1)


	xi: reg zhfa_ch i.h_ch*i.size_lag4 i.r if a<=7, robust cluster(hh1)


		
	duplicates drop hhid, force
	
		

	twoway  (lfit size size_lag if size_lag<11 & size<11 & h_ch==1 & r==2, color(orange))  || (lfit size size_lag if size_lag<11 & size<11 & h_ch==0 & r==2, color(green))
	
	twoway  (lfit size size_lag if size_lag<11 & size<11 & h_ch==1 & r==2) || (lfit size size_lag if size_lag<11 & size<11 & h_ch==0 & r==2)



	twoway  (lfit size_lag size if size_lag<11 & size<11 & h_ch==1 & min_a<14) || (lfit size_lag size if size_lag<11 & size<11 & h_ch==0 & min_a<14)
	twoway  (lfit size_lag size if size_lag<11 & size<11 & h_ch==1 & min_a<7) || (lfit size_lag size if size_lag<11 & size<11 & h_ch==0 & min_a<7)

	twoway  (lfit size_la size if size_lag<11 & size<11 & h_ch==1 & min_a<7) || (lfit size_lag size if size_lag<11 & size<11 & h_ch==0 & min_a<7)

	twoway  (lfit size_lag size if size_lag<11 & size<11 & h_ch==1 & r==2) || (lfit size_lag size if size_lag<11 & size<11 & h_ch==0 & r==2)

	twoway  (lfit size_lag size if size_lag<11 & size<11 & h_ch==1 & r==3) || (lfit size_lag size if size_lag<10 & size<10 & h_ch==0 & r==3)

end 

main

