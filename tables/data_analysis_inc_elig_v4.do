
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
 	use clean/data_analysis/house_treat, clear
  	drop if hhgeo2011==1 | hhgeo2011==3
  	sort pid r
	by pid: g h_ch=rdp[_n]-rdp[_n-1]
  	quietly rebalance
	quietly keep_race
	quietly construct_hh1
	quietly change_variables
 	quietly egen max_age=max(a), by(pid)
 	quietly g a_2=a*a
 	quietly groupings_2
 	quietly groupings_3
 	quietly family_structure
 	quietly inc_exp_per_person
 	quietly drop_rdp_leavers
* 	quietly drop_observations
	quietly inc_elig_prep
	quietly change_lead_variables
 	save clean/data_analysis/house_treat_regs_elig, replace
end

program define reg_with_elig_sample
	
	
	use clean/data_analysis/house_treat_regs_elig, clear
	** informal settlement round 1
	g infr1_id=1 if (h_dwltyp==7 | h_dwltyp==8) & r==1
	replace infr1_id=0 if r==1 & infr1_id==.
	egen infr1=max(infr1_id), by(pid)
	g infr2_id=1 if (h_dwltyp==7 | h_dwltyp==8) & r==2
	replace infr2_id=0 if r==2 & infr2_id==.
	replace infr1=infr2 if infr1==. & r>=2
	
	g flu1_id=flush if r==1
	egen flu1=max(flu1_id), by(pid)
	g flu2_id=flush if r==2
	replace flu2_id=0 if r==2 & flu2_id==.
	replace flu1=flu2 if flu1==. & r>=2
	
	g fd=h_fdtot if h_fdtot>0
	
	egen wstd=sd(c_weight), by(sex a)
	egen wm=mean(c_weight), by(sex a)
	g swfa=(c_weight-wm)/wstd
	replace swfa=. if swfa>6 | swfa<-6
	
	egen hstd=sd(c_height), by(sex a)
	egen hm=mean(c_height), by(sex a)
	g shfa=(c_height-hm)/hstd
	replace shfa=. if shfa>6 | shfa<-6
	
	g incr1_id=inc if r==1
	egen incr1=max(incr1_id), by(pid)
	g incr2_id=inc if r==2
	egen incr2=max(incr2_id), by(pid)
	replace incr1=incr2 if incr1==. & r>=2
	
	egen min_a=min(a), by(hh1)
	
	g inf=(type==7 | type==8)
	
*	drop if m_h_ch<.15
*	keep if elig_m>.70
*	drop if mdb_sum<400
** THINK CAREFULLY ABOUT EACH DROP: WHY DROP AND WHAT DOES IT GAIN ME?

	
*	hist h_dwltyp if m_inc_l<=3500, by(rdp)
	reg rdp size adult child old rooms qual flush piped toilet_share inf own i.r if inc_lr1<=6000 & r>1 & zhfa!=., robust cluster(hh1)
	reg rdp size adult child old rooms qual flush piped toilet_share inf own i.r if inc_lr1<=6000 & r>1 & c_ill!=., robust cluster(hh1)
	reg rdp size adult child old rooms qual flush piped toilet_share inf own i.r if inc_lr1<=6000 & r>1 & min_a<12, robust cluster(hh1)
	
		* less old!? or no grandparents to begin with?
		
	foreach var of varlist fd carbs meat veggies fats baby eat_out {
	xtreg `var' rdp i.r if incr1<=6000 & zwfa!=., fe robust cluster(hh1)
	xtreg `var' rdp i.r if incr1<=6000 & zhfa!=., fe robust cluster(hh1)
	}
		
		
	foreach var of varlist carbs meat veggies fats baby eat_out {
	xtreg `var' rdp i.r if incr1<7000, fe robust cluster(hh1)
	}
	* vegetables and baby food! what about produced foods???
		* does own production decline? probably not! they live in the city!
		* still have to verify
	* why does expenditure pattern change?
	foreach var of varlist child adult_men adult_women old hoh_a {
	xtreg `var' rdp i.r if incr1<7000, fe robust cluster(hh1)
	}
	
	xtreg zhfa rdp i.r if s2r1==0 , fe robust cluster(hh1)
	xtreg zwfa rdp i.r if inc_lr1<=6000 & zhfa!=., fe
		

	
	foreach var of varlist size adult child old {
	xtreg `var' rdp i.r if inc_lr1<=6000 & zwfa!=., fe
	xtreg `var' rdp i.r if inc_lr1<=6000 & zhfa!=., fe
	}
	
	* nothing demographic wise
	
	foreach var of varlist rooms qual flush piped toilet_share {
	xtreg `var' rdp i.r if inc_lr1<=6000 & zwfa!=., fe robust cluster(hh1)
	xtreg `var' rdp i.r if inc_lr1<=6000 & zhfa!=., fe robust cluster(hh1)
	}
	
	
	foreach var of varlist rooms qual flush piped toilet_share {
	xtreg `var' rdp i.r if inc_lr1<=3500 & zwfa!=., fe robust cluster(hh1)
	xtreg `var' rdp i.r if inc_lr1<=3500 & zhfa!=., fe robust cluster(hh1)
	}
	
	foreach var of varlist rooms qual flush piped toilet_share {
	xtreg `var' rdp i.r if inc_lr1<=3500 & c_ill!=., fe robust cluster(hh1)
	}
	
	xtreg c_ill rdp i.r if inc_lr1<=3500 & c_ill!=., fe robust cluster(hh1)
	
	
	** only works for m_inc_l

	xi: xtreg zwfa rdp i.r*i.mdb if inc_lr1<=3500, fe robust cluster(hh1)
	
	xi: xtreg zwfa rdp i.r*i.prov if inc_lr1<=6000, fe robust cluster(hh1)
	
	
	xtreg zwfa rdp i.r if inc_lr1<=10000 , fe robust cluster(hh1)
	xtreg zwfa rdp i.r if inc_lr1<=3500 , fe robust cluster(hh1)
	
	xtreg zhfa rdp i.r if inc_lr1<=6000 , fe robust cluster(hh1)
	xtreg zhfa rdp i.r if inc_lr1<=3500 , fe robust cluster(hh1)
	
	xtreg c_ill rdp i.r if inc_lr1<=6000 , fe robust cluster(hh1)



	xtreg zhfa rdp i.r if m_inc_l<3500 & a>7, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if m_inc_l<3500 & a<7, fe robust cluster(hh1)
	
	xtreg zhfa rdp i.r if m_inc_l<3500 & s2r1==1, fe robust cluster(hh1)

	xtreg zwfa rdp i.r if m_inc_l<3500 & s2r1==0, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<3500 & s2r1==1, fe robust cluster(hh1)

	xtreg zhfa rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<5000, fe robust cluster(hh1)

	xtreg zhfa rdp i.r if m_inc_l<5000 & a<=7, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<5000 & a<=7, fe robust cluster(hh1)


	xtreg food rdp i.r if m_inc_l<3500, fe robust cluster(hh1)
	xtreg food_imp rdp i.r if m_inc_l<3500, fe robust cluster(hh1)

	xtreg sch_spending rdp i.r if m_inc_l<3500, fe robust cluster(hh1)
	
	xtreg c_absent rdp i.r if m_inc_l<3500, fe robust cluster(hh1)
	xtreg c_failed rdp i.r if m_inc_l<3500, fe robust cluster(hh1)

	xtreg c_ill rdp i.r if m_inc_l<3500, fe robust cluster(hh1)

	xtreg c_ill rdp i.r if m_inc_l<3500 & a>10, fe robust cluster(hh1)
	xtreg c_ill rdp i.r if m_inc_l<3500 & a<=10, fe robust cluster(hh1)

	xtreg c_health rdp i.r if m_inc_l<3500, fe robust cluster(hh1)
	
	** reported health doesn't change as much

	* adult health
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	xtreg `var' rdp i.r if m_inc_l<3500 & sizer1>1, fe robust cluster(hh1)
	}

** WHY ARE KIDS SO MUCH HEALTHIER?

	xtreg size rdp i.r if m_inc_l<3500 & s2r1==0, fe robust cluster(hh1)

	xtreg size rdp i.r if m_inc_l<3500 & s2r1==1, fe robust cluster(hh1)


	** WHAT IS DRIVING THIS?
	** CONDITION ON INITIAL HOUSE CHARACTERISTICS
	
	
	xtreg piped rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg flush rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg toilet_share rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg qual rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg rooms rdp i.r if m_inc_l<5000, fe robust cluster(hh1)
	xtreg mktv rdp i.r if m_inc_l<5000 & mktv<=60000, fe robust cluster(hh1)
		* definitely increases market value


	forvalues r=2/6 {
	xtreg zhfa rdp i.r if m_inc_l<5000 & roomsr1<`r', fe robust cluster(hh1)
	xtreg zhfa rdp i.r if m_inc_l<5000 & roomsr1>=`r', fe robust cluster(hh1)
	}
	forvalues r=2/6 {
	xtreg zwfa rdp i.r if m_inc_l<5000 & roomsr1<`r', fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<5000 & roomsr1>=`r', fe robust cluster(hh1)
	}
	** weight is driven by bigger initial houses
	
	xtreg zhfa rdp i.r if m_inc_l<5000 & house==1, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<5000 & house==1 & a<10, fe robust cluster(hh1)
	
	** INFORMAL SETTLEMENTS? KIND OF!
	xtreg zhfa rdp i.r if m_inc_l<=3500 & infr1==0, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if m_inc_l<=3500 & infr1==1, fe robust cluster(hh1)
	
	xtreg zwfa rdp i.r if m_inc_l<=3500 & infr1==0, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<=3500 & infr1==1, fe robust cluster(hh1)
	** weight gains are concentrated among informal settlement dwellers
	
	** HOW BOUT FLUSH TOILETS	
	xtreg zhfa rdp i.r if m_inc_l<=6000 & flu1==0, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if m_inc_l<=6000 & flu1==1, fe robust cluster(hh1)
	
	xtreg zwfa rdp i.r if m_inc_l<=6000 & flu1==0, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if m_inc_l<=6000 & flu1==1, fe robust cluster(hh1)
		 * NO INCOME THRESHOLD
	xtreg zhfa rdp i.r if flu1==0, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if flu1==1, fe robust cluster(hh1)
		* much weaker (becuase rich kids are improving anyways)
	xtreg zwfa rdp i.r if flu1==0, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if flu1==1, fe robust cluster(hh1)
	
	xtreg zhfa rdp i.r if (m_inc_l<=6000 | m_inc_l==.) & flu1==0, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if (m_inc_l<=6000 | m_inc_l==.) & flu1==1, fe robust cluster(hh1)
	
	xtreg zwfa rdp i.r if (m_inc_l<=6000 | m_inc_l==.) & flu1==0, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if (m_inc_l<=6000 | m_inc_l==.) & flu1==1, fe robust cluster(hh1)
	** problem that kids that respond are the ones that get better?
	
	xtreg zhfa rdp i.r if inc<6000 & flu1==0 & a<=14, fe robust cluster(hh1)
	xtreg zhfa rdp i.r if inc<6000 & flu1==1 & a<=14, fe robust cluster(hh1)
	
	xtreg zwfa rdp i.r if inc<6000 & flu1==0 & a<10, fe robust cluster(hh1)
	xtreg zwfa rdp i.r if inc<6000 & flu1==1 & a<10, fe robust cluster(hh1)
	

	** weight gains accrue to kids without toilets: consistent with informal settlement story
end

program define inc_elig_prep

	g mdb=hhdc2011 
	replace mdb=gc_dc2011 if mdb==.

	** KEEP MDB'S WITH PLENTY OF OBS		
	egen mdb_sum=sum(i), by(mdb)
*	drop if mdb_sum<400

	** KEEP IF MDB HAS LOTS OF SWITCHERS (PROJECT EVIDENCE)
	egen m_h_ch=mean(h_ch), by(mdb)
*	drop if m_h_ch<.1

	** KEEP IF HIGH SHARE OF ELIGIBILITY
	g elig=(inc_l<3500 & h_chl==1)
	replace elig=. if inc_l==.
	replace elig=. if h_chl==.
	replace elig=. if h_chl==0
	egen elig_m=mean(elig), by(mdb)
*	keep if elig_m>.70
	
	xtset pid
	g inc_lr1id=inc_l if r==1
	egen inc_lr1=max(inc_l), by(pid)
	g inc_lr2id=inc_l if r==2
	egen inc_lr2=max(inc_lr2id), by(pid)
	replace inc_lr1=inc_lr2 if inc_lr1==. & r>=2
	
	g inc_g=pi_hhgovt
	g inc_g1=hhgovt
	g ig=inc_g
	replace ig=0 if ig==.
	g fw_ig=ig+fwag
	
	g weight=a_weight_1 if a_weight_1>0
	replace weight=(a_weight_2+weight)/2 if a_weight_2>0 & a_weight_2<.
	g height=a_height_1 if a_height_1>0
	replace height=(a_height_2+height)/2 if a_height_2>0 & a_height_2<.
	g bmi=weight/(height*height)
	
	g c_weight=c_weight_1 if c_weight_1>0
	replace c_weight=(c_weight_2+c_weight)/2 if c_weight_2>0 & c_weight_2<.
	g c_height=c_height_1 if c_height_1>0
	replace c_height=(c_height_2+c_height)/2 if c_height_2>0 & c_height_2<.
	g c_bmi=c_weight/(c_height*c_height)
	
	egen m_fwag=max(fwag), by(hhid)
	g fwr1_id=m_fwag if r==1
	egen fwr1=max(fwr1_id), by(pid)
	g fwr2_id=m_fwag if r==2
	egen fwr2=max(fwr2_id), by(pid)
	replace fwr1=fwr2 if r>=2 & fwr1==.

	g le=m_fwag<=1500
	g he=m_fwag<3500
	g adult=adult_men+adult_women
	g cr1_id=(child>0 & child<. & r==1)
	egen cr1=max(cr1_id), by(pid)
end

program define change_lead_variables
	sort pid r
	by pid: g ownerl=owner[_n+1]
	by pid: g size_chl=size_ch[_n+1]
	by pid: g rooms_chl=rooms_ch[_n+1]
	foreach var of varlist e ue inc exp child adult_men adult_women {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_chl=`var'_ch[_n+1]
	}
end	

program drop_rdp_leavers
** now go by pid!
	egen min_h_ch=min(h_ch), by(pid)
	egen max_h_ch=max(h_ch), by(pid)
	egen max_rdp=max(rdp), by(pid)
	g rdp_r1=rdp if r==1
	egen rdp_r1m=max(rdp_r1), by(pid)
	drop if rdp_r1m==1
	drop if min_h_ch<0
	drop if max_rdp==1 & max_h_ch<1
end

program drop_rdp_leavers_hh1
	egen min_h_ch=min(h_ch), by(hh1)
	egen max_h_ch=max(h_ch), by(hh1)
	egen max_rdp=max(rdp), by(hh1)
	g rdp_r1=rdp if r==1
	egen rdp_r1m=max(rdp_r1), by(hh1)
	drop if rdp_r1m==1
	drop if min_h_ch<0
	drop if max_rdp==1 & max_h_ch<1
end


program drop_observations
	egen inc_m=max(inc), by(hh1)
	drop if inc_m>10000 & inc_m!=.
end

program define keep_race
	keep if (best_race==1 | best_race==2)
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
	sort pid r
	by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
	by pid: g size_ch=size[_n]-size[_n-1]
	g rooms_r1_id=rooms if r==1
	egen roomsr1=max(rooms_r1_id), by(pid)
	g rooms_r1_2_id=rooms if r==2
	egen rooms_r1_2=max(rooms_r1_2_id), by(pid)
	replace roomsr1=rooms_r1_2 if r>=2 & roomsr1==.
	g size_r1_id=size if r==1
	egen sizer1=max(size_r1_id), by(pid)
	g size_r1_2_id=size if r==2
	egen size_r1_2=max(size_r1_2_id), by(pid)
	replace sizer1=size_r1_2 if r>=2 & sizer1==.
	
	g zhfa_r1_id=zhfa if r==1
	egen zhfar1=max(zhfa_r1_id), by(pid)
	g zhfa_r1_2_id=zhfa if r==2
	egen zhfa_r1_2=max(zhfa_r1_2_id), by(pid)
	replace zhfar1=zhfa_r1_2 if r>=2 & zhfar1==.
	
	g zwfa_r1_id=zwfa if r==1
	egen zwfar1=max(zwfa_r1_id), by(pid)
	g zwfa_r1_2_id=zwfa if r==2
	egen zwfa_r1_2=max(zwfa_r1_2_id), by(pid)
	replace zwfar1=zwfa_r1_2 if r>=2 & zwfar1==.
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
*	keep if r1_idd==1 & r2_idd==1 & r3_idd==1
*	drop *_idd
end

program define groupings_3
	g r3=1 if rooms<3
	replace r3=2 if rooms>=3 & rooms<=5
	replace r3=3 if rooms>5
	g s3=1 if size<=4
	replace s3=2 if size>4 & size<=7
	replace s3=3 if size>7
	g r3r1_id=r3 if r==1
	egen r3r1=max(r3r1_id), by(pid)
	g s3r1_id=s3 if r==1
	egen s3r1=max(s3r1_id), by(pid)
	g s3r2_id=s3 if r==2
	egen s3r2=max(s3r2_id), by(pid)
	replace s3r1=s3r2 if r>=2 & s3r1==.
	
end

program define groupings_2	
	g r2=0 if rooms<=3
	replace r2=1 if rooms>3  & rooms<=13
	g r2r1_id=r2 if r==1
	egen r2r1=max(r2r1_id), by(pid)
	g r2r1_2_id=r2 if r==2
	egen r2r1_2=max(r2r1_2_id), by(pid)
	replace r2r1=r2r1_2 if r>=2 & r2r1==.
	forvalues r=2/11 {
	g s_`r'=0 if size<=`r'
	replace s_`r'=1 if size>`r'
	g s_`r'r1_id=s_`r' if r==1
	egen s_`r'r1=max(s_`r'r1_id), by(pid)
	g s_`r'r1_2_id=s_`r' if r==2
	egen s_`r'r1_2=max(s_`r'r1_2_id), by(pid)
	replace s_`r'r1=s_`r'r1_2 if r>=2 & s_`r'r1==.
	drop s_`r'r1_id s_`r'r1_2_id s_`r'r1_2 s_`r'
	}
	g s2=0 if size<=5
	replace s2=1 if size>5
	g s2r1_id=s2 if r==1
	egen s2r1=max(s2r1_id), by(pid)
	g s2r1_2_id=s2 if r==2
	egen s2r1_2=max(s2r1_2_id), by(pid)
	replace s2r1=s2r1_2 if r>=2 & s2r1==.	
	
	replace own=0 if own==2
	g ownr1_id=own if r==1
	egen ownr1=max(ownr1_id), by(pid)
	g ownr2_id=own if r==2
	egen ownr2=max(ownr2_id), by(pid)
	replace ownr1=ownr2 if r>=2 & ownr1==.
	
end

program define family_structure
	*adult men and women
	g adult_men_id=(a>18 & a<55 & sex==1)
	g adult_women_id=(a>18 & a<55 & sex==0)
	egen adult_men=sum(adult_men_id), by(hhid)
	g adult_menr1_id=adult_men if r==1
	egen adult_menr1=max(adult_menr1_id), by(pid)
	g adult_menr2_id=adult_men if r==2
	egen adult_menr2=max(adult_menr2_id), by(pid)
	replace adult_menr1=adult_menr2 if r>=2 & adult_menr1==.
	egen adult_women=sum(adult_women_id), by(hhid)
	g adult_womenr1_id=adult_women if r==1
	egen adult_womenr1=max(adult_womenr1_id), by(pid)
	g adult_womenr2_id=adult_women if r==2
	egen adult_womenr2=max(adult_womenr2_id), by(pid)
	replace adult_womenr1=adult_womenr2 if r>=2 & adult_womenr1==.
	*grandparents
	g old_men_id=(a>60 & sex==1 & a<.)
	g old_women_id=(a>60 & sex==0 & a<.)
	egen old_men=sum(old_men_id), by(hhid)
	egen old_women=sum(old_women_id), by(hhid)
	g old=old_men+old_women
	g oldr1_id=old if r==1
	egen oldr1=max(oldr1_id), by(pid)
	g oldr2_id=old if r==2
	egen oldr2=max(oldr2_id), by(pid)
	replace oldr1=oldr2 if r>=2 & oldr1==.
	*children
	g child_id=(a<16)
	egen child=sum(child_id), by(hhid)
	g childr1_id=child if r==1
	egen childr1=max(childr1_id), by(pid)
	g childr2_id=child if r==2
	egen childr2=max(childr2_id), by(pid)
	replace childr1=childr2 if r>=2 & childr1==.
	
	** ownership
	g owner=(h_ownpid1==pid | h_ownpid2==pid)
	g hoh=r_relhead==1
	g hoh_pid_id=pid if hoh==1
	egen hoh_pid=max(hoh_pid_id), by(hhid)
	sort pid r
	by pid: g hoh_ch=1 if hoh_pid[_n]==hoh_pid[_n-1] & hoh_pid!=.
	replace hoh_ch=0 if hoh_ch==1
	replace hoh_ch=1 if hoh_ch==. & r>1
	replace hoh_ch=. if hoh_pid==.
	replace hoh_ch=0 if r==1
	g hoh_a_id=a if hoh==1
	egen hoh_a=max(hoh_a_id), by(hhid)
	sort pid r
	by pid: g h_chl=h_ch[_n+1]
	g single_mother=(adult_women==1 & adult_men==0 & child>0)
	g adult_mw=adult_men/adult_women
	replace adult_mw=. if adult_mw==0
	g a_ms=adult_men/size
	g a_ws=adult_women/size
	g aw_d=(adult_women>0 & adult_women<.)
	g a7_id=(a<=7)
	egen a7=max(a7_id), by(hhid)
	egen a7p=max(a7), by(pid)
	g a7_r1_id=a7 if r==1
	egen a7r1=max(a7_r1_id), by(pid)
	g f_hoh=(f_pid1==hoh_pid & f_pid1!=.)
	g m_hoh=(m_pid1==hoh_pid & m_pid1!=.)
	g p_hoh=(m_hoh==1 | f_hoh==1)
	g p_hoh1=(r_relhead==4)
	g g_hoh=(r_relhead==13)
	** quick house variables
	g roof_cor=roof==3
	g walls_b=wall==1
	g house=type==1
	g piped=(water>=1 & water<=2)
	g public_water=water==3
	g flush=(toilet>=1 & toilet<=2)
	replace toilet_share=0 if toilet_share==2
	** wasting and stunting
	egen sd_zhfa=sd(zhfa), by(a sex)
	replace sd_zhfa=sd_zhfa*(-1)*2
	g stunt=(zhfa<sd_zhfa)
	egen sd_zwfa=sd(zwfa), by(a sex)
	replace sd_zwfa=sd_zwfa*(-1)*2
	g waste=(zwfa<sd_zwfa)
	** movers
	egen max_move=max(move), by(pid)
	g i=1
	egen size_a=sum(i), by(hhid)
	** ROUND 2 LEFT OUT **
	sort pid r
	by pid: g rdpl=rdp[_n+1]
	egen m_rdpl=max(rdpl), by(hhid)
	tab rdpl m_rdpl if r==1
	tab rdpl m_rdpl if r==2
	g lo=(m_rdpl==1 & rdpl==0)
	label variable lo "left out in the round before actually left out"
	sort pid r
	by pid: g lol=lo[_n-1]
	by pid: g loll=lol[_n-1]
	replace lol=loll if lol==0 & r==3 & loll==1
	replace lol=0 if lol==.
	label variable lol "treatment variable for being left out (includes period after being left out)"
	egen lom=max(lo), by(hhid)
	by pid: g loml=lom[_n-1]
	g rdplo=(rdp==1 & loml==1)
	by pid: g rdplol=rdplo[_n-1]
	replace rdplo=rdplol if rdplol==1 & r==3 
	** RELATIVELY EVEN SPLIT
	drop rdplol
	rename rdplo rdplol
	label variable rdplol "rdp treatment who left members behind"

	*** generate left_out variables
	egen mrdp_h=max(rdp), by(hh1)
	egen mrdp_i=max(rdp), by(pid)
	
	g lo_alt=(mrdp_h==1 & mrdp_i==0)
	
	tab lol lo_alt if r==2
	tab lol lo_alt if r==3
	** doesn't work??
	
	egen mrdp_h2=max(rdp) if r==2, by(hh1)
	egen mrdp_i2=max(rdp) if r==2, by(pid)
	egen mrdp_h3=max(rdp) if r==3, by(hh1)
	egen mrdp_i3=max(rdp) if r==3, by(pid)
	
	** FIGURE OUT WHAT'S GOING ON **
	** lead rdp over round, just to get a basline
	tab rdpl r
	** rdp's over the whole household over round (how 
	
end

program define inc_exp_per_person
	foreach var of varlist vice ceremony home_prod sch_spending health_exp non_food_other public_other non_food public food food_imp non_food_imp exp_imp exp inc inc_l inc_r {
	g `var'_s=`var'/size
	g `var'_per=`var'/exp_imp
	}
end

main


