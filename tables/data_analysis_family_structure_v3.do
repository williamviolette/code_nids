
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
 	save clean/data_analysis/house_treat_regs, replace
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
	* are there rdp households with multiple races?
*	tab best_race, g(race_)
*	forvalues r=1/4 {
*	egen race`r'_hh=max(race_`r'), by(hhid)
*	replace race`r'_hh=`r' if race`r'_hh==1
*	}
*	replace race1_hh=race1_hh*1000
*	replace race2_hh=race2_hh*100
*	replace race3_hh=race3_hh*10
*	g racehh=race1_hh+race2_hh+race3_hh+race4_hh
	* basically no overlap between races in a household so fine to drop races
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

program define working
	
	g mdb=hhdc2011 
	replace mdb=gc_dc2011 if mdb==.
		
	egen mdb_sum=sum(i), by(mdb)
	drop if mdb_sum<400

	** formal wage does it!
	sort pid r
	by pid: g ownerl=owner[_n+1]
	by pid: g size_chl=size_ch[_n+1]
	by pid: g rooms_chl=rooms_ch[_n+1]
	by pid: g e_ch=e[_n]-e[_n-1]
	by pid: g e_chl=e_ch[_n+1]
	by pid: g ue_ch=ue[_n]-ue[_n-1]
	by pid: g ue_chl=ue_ch[_n+1]
	by pid: g inc_ch=inc[_n]-inc[_n-1]
	by pid: g inc_chl=inc[_n+1]
	by pid: g exp_ch=exp_imp[_n]-exp[_n-1]
	by pid: g exp_chl=exp_ch[_n+1]
	

	tab mdb h_ch
	egen m_h_ch=mean(h_ch), by(mdb)
	tab m_h_ch
	* hist m_h_ch
	drop if m_h_ch<.1
	
	g weight=a_weight_1 if a_weight_1>0
	replace weight=(a_weight_2+weight)/2 if a_weight_2>0 & a_weight_2<.
	g height=a_height_1 if a_height_1>0
	replace height=(a_height_2+height)/2 if a_height_2>0 & a_height_2<.
	g bmi=weight/(height*height)
	
	egen m_fwag=max(fwag), by(hhid)
	g fwr1_id=m_fwag if r==1
	egen fwr1=max(fwr1_id), by(pid)
	g fwr2_id=m_fwag if r==2
	egen fwr2=max(fwr2_id), by(pid)
	replace fwr1=fwr2 if r==2 & fwr1==.

	g le=m_fwag<=1500
	g he=m_fwag<3500
	g adult=adult_men+adult_women
	g cr1_id=(child>0 & child<. & r==1)
	egen cr1=max(cr1_id), by(pid)
	
	** size eligibility?
	hist child if r<3 & rdp==0, by(h_chl)
	hist size if r<3, by(h_chl)
	
	** disability?
	
	** never owned
	xi: reg h_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)

	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)

	xi: reg e_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)
	xi: reg ue_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)

	xi: reg h_chl le i.r*i.mdb if m_fwag<2000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)
	xi: reg size_chl le i.r*i.mdb if m_fwag<2000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)

	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>500 & r<3, robust cluster(hh1)
	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>500 & r<3 & s2r1==0, robust cluster(hh1)
	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>500 & r<3 & s2r1==1, robust cluster(hh1)

	xi: reg inc_chl le i.r*i.mdb if m_fwag<2000 & m_fwag>1000 & r<3, robust cluster(hh1)

	xi: reg exp_chl le i.r*i.mdb if m_fwag<2000 & m_fwag>1000 & r<3, robust cluster(hh1)
		* not much for income and expenditure?

	
	
	xtset pid
	xi: xtreg size rdp i.r if fwr1<3000, robust cluster(hh1) fe
	xi: xtreg ue rdp i.r if fwr1<3000, robust cluster(hh1) fe
	xi: xtreg e rdp i.r if fwr1<3000, robust cluster(hh1) fe

	xi: xtreg size rdp i.r if fwr1<1500, robust cluster(hh1) fe
	xi: xtreg ue rdp i.r if fwr1<1500, robust cluster(hh1) fe
	xi: xtreg e rdp i.r if fwr1<1500, robust cluster(hh1) fe
	

	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & rdp==0, robust cluster(hh1)



	xi: xtreg size rdp i.r if fwr1<1500, robust cluster(hh1) fe	
	
	** not employment, * only employment when look at richer treated
	
	
	xi: xtreg child rdp i.r if fwr1<3000, robust cluster(hh1) fe
	** driven by adult and old
	xi: xtreg adult rdp i.r if fwr1<3000, robust cluster(hh1) fe
	xi: xtreg old rdp i.r if fwr1<3000, robust cluster(hh1) fe

	xi: xtreg child rdp i.r if fwr1<1500, robust cluster(hh1) fe
	xi: xtreg adult rdp i.r if fwr1<1500, robust cluster(hh1) fe
	xi: xtreg old rdp i.r if fwr1<1500, robust cluster(hh1) fe

	* even increase for men and women
	xi: xtreg adult rdp i.r if fwr1<1500 & s2r1==0, robust cluster(hh1) fe
	xi: xtreg adult rdp i.r if fwr1<1500 & s2r1==1, robust cluster(hh1) fe
	* even increase across large and small hh's

	xi: xtreg exp_imp rdp i.r if fwr1<1500, robust cluster(hh1) fe
	xi: xtreg inc rdp i.r if fwr1<1500, robust cluster(hh1) fe

	xi: xtreg exp_imp rdp i.r if fwr1<3500, robust cluster(hh1) fe
	xi: xtreg inc rdp i.r if fwr1<3500, robust cluster(hh1) fe
	* not much here either	

	
	xi: xtreg old rdp i.r if m_fwag<3000, robust cluster(hh1) fe


	xi: xtreg adult rdp i.r if m_fwag<3000 & cr1==0, robust cluster(hh1) fe
	xi: xtreg adult rdp i.r if m_fwag<3000 & cr1==1, robust cluster(hh1) fe
	xi: xtreg old rdp i.r if m_fwag<3000 & cr1==0, robust cluster(hh1) fe	
	xi: xtreg old rdp i.r if m_fwag<3000 & cr1==1, robust cluster(hh1) fe	
				* pretty even, find adult increases in hh's without children, *(makes sense)*
	** battery of outcomes
	** ** ** self employment or gov income?
	xi: xtreg zwfa rdp i.r if m_fwag<3000, robust cluster(hh1) fe

	xtset pid
	** anything going on?
	xi: xtreg bmi rdp i.r if m_fwag<3000, robust cluster(hh1) fe


	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & s2r1==0, robust cluster(hh1)
	xi: reg size_chl le i.r*i.mdb if m_fwag<3000 & m_fwag>1000 & r<3 & s2r1==1, robust cluster(hh1)




	xi: reg size_chl le i.r*i.mdb if fwag<3000 & fwag>500 & r<3 & s2r1==1, robust cluster(hh1)
** driven by large households


	xi: reg rooms_chl le i.r*i.mdb if fwag<2000 & fwag>1000 & r<3, robust cluster(hh1)


	xi: reg h_chl le i.r*i.mdb if fwag<5000 & r<3, robust cluster(hh1)

	xi: reg h_chl le i.r*i.mdb if fwag<3000 & fwag>500 & r<3, robust cluster(hh1)

***
	xi: reg h_chl he i.r*i.mdb if fwag<5000 & fwag>2000 & r<3, robust cluster(hh1)
		** 3500 cut-off doesn't work


	hist fwag if fwag<7000 & r<3, by(h_chl)
	
	hist inc if fwag<10000 & inc<10000 & r<3 & rdp==0, by(h_chl)
	hist fwag if fwag<10000 & inc<10000 & r<3 & rdp==0, by(h_chl)
	
	
	hist inc if inc<10000 & r<3 & rdp==0, by(h_chl)
	
	
	hist fwag if fwag<7000 & r<3, by(mdb h_chl)
	
	hist inc if inc<7000 & r<3, by(mdb h_chl)
	
	

	
	hist fwag if fwag<5000 & r==1 & ownerl==1, by(h_chl)
	hist fwag if fwag<5000 & r==2 & ownerl==1, by(h_chl)
	
	hist fwag if fwag<2000 & fwag>1000 & r<3 & ownerl==1, by(h_chl)
	hist fwag if fwag<4000 & fwag>3000 & r<3 & ownerl==1, by(h_chl)
	hist fwag if fwag<10000 & r<3 & ownerl==1, by(h_chl)

	
	** geographic concentration of the treatment?
	
	
	
		
	tab inc_l
	

	hist inc_l if inc_l<8000 & r==1, by(h_chl)
	* not a huge amount here
	
	hist child if r==1, by (h_chl)
	

	
	hist inc if inc<15000, by(rdp)

	hist inc if inc<10000, by(rdp)


	** TRY ADULT OUTCOMES, AND WEIGHT MORE BROADLY

	
	xi: xtreg bmi rdp i.r if  s2r1==0, fe robust cluster(hh1)
	xi: xtreg bmi rdp i.r if s2r1==1, fe robust cluster(hh1)
		
	xtset pid
	forvalues r=10(10)70 {
	xi: xtreg bmi rdp i.r if  s2r1==0 & a>=`r' & a<`r'+10, fe robust cluster(hh1)
	xi: xtreg bmi rdp i.r if s2r1==1 & a>=`r' & a<`r'+10, fe robust cluster(hh1)
	}
	
	** not much going on
	
	xi: xtreg weight rdp i.r if  s2r1==0 & a>20, fe robust cluster(hh1)
	xi: xtreg weight rdp i.r if s2r1==1 & a>20, fe robust cluster(hh1)
	
	xtset pid
	forvalues r=10(10)70 {
	xi: xtreg weight rdp i.r if  s2r1==0 & a>=`r' & a<`r'+10, fe robust cluster(hh1)
	xi: xtreg weight rdp i.r if s2r1==1 & a>=`r' & a<`r'+10, fe robust cluster(hh1)
	}
	
	** maybe a little bit, but really not much going on
	
	xtset pid
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	xi: xtreg `var' rdp i.r if  s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	
	
	
	
	
	* THIS DOES NOT LOOK GOOD
	sort pid r
	by pid: g zwfa_ch=zwfa[_n]-zwfa[_n-1]
	reg size_ch zwfa_ch if rdp==1
	g zwp=1 if (zwfa_ch>0 & zwfa_ch<.)
	replace zwp=0 if zwfa_ch<0
	tab size_ch zwp if rdp==1
	tab size_ch rdp if zwfa_ch<0
	
	xtset pid
	forvalues r=1/6 {
	xi: xtreg zwfa rdp i.r if a<=7 & roomsr1==`r', fe robust cluster(hh1)
	}
	
	** by ownership! why ? what's interesting about that ?
	
	xtset pid
	foreach var of varlist zwfa zhfa zbmi c_ill {
	xi: xtreg `var' rdp i.r if ownr1==0 & a<=7, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if ownr1==1 & a<=7, fe robust cluster(hh1)
	}
	
	
	
	
	xtset pid
	foreach var of varlist piped flush toilet_share c_sch_d {
	xi: xtreg `var' rdp i.r if s_5r1==0 & a<=10 & zwfa!=., fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s_5r1==1 & a<=10 & zwfa!=., fe robust cluster(hh1)
	}
	
	tab h_ch if a<=10 & zwfa!=.
	
	xi: xtreg health_exp rdp i.r if s_5r1==0 & a<=10 & zwfa!=., fe robust cluster(hh1)
	xi: xtreg health_exp rdp i.r if s_5r1==1 & a<=10 & zwfa!=., fe robust cluster(hh1)
			* other households are changing in size in similar directions, but for different reasons?
	
	** PLACEBO TEST:: oops, the interaction just captures mean reversion
	* be skeptical of interactions
	
	xi: xtreg size i.rdp*i.s_5r1 i.r if a<=10 & zwfa!=., fe robust cluster(hh1)
	
	g v=runiform()
	g r2house=0
	replace r2house=1 if v>.2 & r==2
	
	xi: xtreg size i.r2house*i.s_5r1 i.r if a<=10 & zwfa!=. & r<3, fe robust cluster(hh1)
	
	xi: xtreg size i.*i.s_5r1 i.r if a<=10 & zwfa!=., fe robust cluster(hh1)
	** this interaction helps somewhat.. 
	
	xtset pid
	forvalues r=2/8 {
	xi: xtreg zwfa rdp i.r if a<=7 & sizer1==`r', fe robust cluster(hh1)
	}
	
	xtset pid
	forvalues r=2/8 {
	xi: xtreg food rdp i.r if a<=7 & sizer1==`r' & zwfa!=., fe robust cluster(hh1)
	}
	
	
	forvalues r=2/8 {
	xi: xtreg old rdp i.r if a<=7 & sizer1==`r' & zwfa!=., fe robust cluster(hh1)
	}
	
	
	
	* hist inc if inc>20000 & rdp==1, by(best_race)
	* hist rooms if inc>20000 & rdp==1, by(best_race)
	
	** those left behind account for what share of the size reductions changes

	g discrep=size!=size_a

	sort pid r
	by pid: g size_ach=size_a[_n]-size_a[_n-1]
	
	** even those that split off still gained members * but much less	
	tab size_ach rdplol if s2r1==0
	tab size_ach rdplol if s2r1==1
	** dividing by baseline size confirms the hypothesis
	
	*** CAREFULLY THINK THROUGH WHO IS LEAVING AND WHERE ARE THEY GOING? ***
	tab hh1
	
	sort pid r
	by pid: g size_ach=size_a[_n]-size_a[_n-1]
	by pid: g rdp_lead=rdp[_n+1]
	by pid: g size_achl=size_ach[_n+1]

	
	tab size size_a if r==1
	
	tab size size_a if r==2
	
	xtset pid 
	
	egen max_size=max(size), by(pid)
	
	g yc=a<=16
	g ycr1_id=yc if r==1
	egen ycr1=max(yc), by(pid)
	
	** HAVE PROBLEMS WITH SIZE! **
	
	sort pid r
	by pid: g s_ch_lead=size_ch[_n+1]
	
	** non - linear
	xtset pid
	
	** what is going on!?
	
	
	** GO BY ALL DIFFERENT DEMOGRAPHICS **
	** CHILDREN
	tab childr1 h_ch if a<=10
	forvalues r=0(3)6 {
	xi: xtreg zwfa rdp i.r if childr1>=`r' & childr1<`r'+3 & a<=10, fe robust cluster(hh1)
	xi: xtreg child rdp i.r if childr1>=`r' & childr1<`r'+3 & a<=10, fe robust cluster(hh1)
	}
	** children isn't terrible
	** ADULT MEN
	tab adult_menr1 h_ch if a<=10
	forvalues r=0/3 {
	xi: xtreg zwfa rdp i.r if adult_menr1>=`r' & adult_menr1<`r'+1 & a<=10, fe robust cluster(hh1)
	xi: xtreg adult_men rdp i.r if adult_menr1>=`r' & adult_menr1<`r'+1 & a<=10, fe robust cluster(hh1)
	}
	** ADULT WOMEN
	tab adult_womenr1 h_ch if a<=10
	forvalues r=0/3 {
	xi: xtreg zwfa rdp i.r if adult_womenr1>=`r' & adult_womenr1<`r'+1 & a<=10, fe robust cluster(hh1)
	xi: xtreg adult_women rdp i.r if adult_womenr1>=`r' & adult_womenr1<`r'+1 & a<=10, fe robust cluster(hh1)
	}

	** HOW DO HOUSEHOLDS CHANGE SIZE DIFFERENTLY WHEN THERE IS A YOUNG CHILD PRESENT?
	
	foreach var of varlist size adult_women adult_men child old {
	xi: xtreg `var' rdp i.r if s2r1==0 & childr1>0 & childr1<., fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & childr1>0 & childr1<., fe robust cluster(hh1)
	}
	** increase in other children for small households
	
	foreach var of varlist size adult_women adult_men child old {
	xi: xtreg `var' rdp i.r if s2r1==0 & zwfa!=., fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & zwfa!=., fe robust cluster(hh1)
	}
	
	tab size_ch h_ch if zwfa!=. & s2r1==0
	tab size_ch h_ch if zwfa!=. & s2r1==1
	
	** different demographic changes depending on whether children are initially present
	foreach var of varlist adult_women adult_men child old {
	xi: xtreg `var' rdp i.r if s2r1==0 & childr1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & childr1==0, fe robust cluster(hh1)
	}
	
	
	** still very correlated to size of initial household, what's going on?
	
	
	forvalues r=3/12 {
	foreach var of varlist inc {
	xi: xtreg `var' rdp i.r if sizer1==`r' & a<=7, fe robust cluster(hh1)
	}
	}
	
	
	xtset pid
	foreach var of varlist zwfa zhfa zbmi c_ill {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7, fe robust cluster(hh1)
	}
	
	

	forvalues r=3/12 {
	xi: xtreg size rdp i.r if sizer1==`r' & max_size<13 & a>10, fe robust cluster(hh1)
	xi: xtreg size rdp i.r if sizer1==`r' & max_size<13 & a<=10, fe robust cluster(hh1)
	}
	
	
	xi: xtreg adult_men rdp i.r if s2r1==0 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg adult_men rdp i.r if s2r1==1 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg adult_women rdp i.r if s2r1==0 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg adult_women rdp i.r if s2r1==1 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg old rdp i.r if s2r1==0 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg old rdp i.r if s2r1==1 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg child rdp i.r if s2r1==0 & max_size<13 & a<=10 & zwfa!=., fe
	xi: xtreg child rdp i.r if s2r1==1 & max_size<13 & a<=10 & zwfa!=., fe

		* basically no correlation here.. what should I do?
	
	xi: xtreg size rdp i.r if sizer1<6 & sizer1>2 & max_size<13 & a<=10, fe robust cluster(hh1)
	
	xi: xtreg size rdp i.r if sizer1>=6 & sizer1<12 & a<=10, fe robust cluster(hh1)
	
	
	
	
	forvalues r=1/12 {
	xi: xtreg size rdp i.r if sizer1==`r' & max_size<13 & ycr1==1, fe robust cluster(hh1)
	}

	forvalues r=3/12 {
	xi: xtreg child rdp i.r if sizer1==`r' & max_size<13 & a>10, fe robust cluster(hh1)
	xi: xtreg child rdp i.r if sizer1==`r' & max_size<13 & a<=10, fe robust cluster(hh1)
	}

	xi: xtreg size rdp i.r if sizer1>7 & max_size<13 & ycr1==1, fe robust cluster(hh1)


	xi: xtreg size rdp i.r if sizer1<=5 & sizer1>=3 & ycr1==1, fe robust cluster(hh1)

	
	
	xi: xtreg size rdp i.r if s2r1==0 & max_size<13 & a<=16, fe robust cluster(hh1)

	xi: xtreg size rdp i.r if s2r1==1 & max_size<13 & a<=16, fe robust cluster(hh1)

** size changes are NOT concentrated among households with young children, what the hell do I do now?

	xi: xtreg size rdp i.r if s2r1==0 & max_size<13 & ycr1==1, fe robust cluster(hh1)

	xi: xtreg size rdp i.r if s2r1==1 & max_size<13 & a<=16, fe robust cluster(hh1)

*	xi: xtreg size_a rdp i.r if s2r1==0, fe robust cluster(hh1)
*	xi: xtreg size_a rdp i.r if s2r1==1, fe robust cluster(hh1)
	
	** size change issue!!!
	tab size_ch rdp if s2r1==0
	
	tab size_ch rdp
	
	g rdp2=rdp if r==2
	egen mrdp2=max(rdp2), by(hh1)
	egen prdp2=max(rdp2), by(pid)
	tab mrdp2 prdp2
	
	g rdp3=rdp if r==3
	egen mrdp3=max(rdp3), by(hh1)
	egen prdp3=max(rdp3), by(pid)
	tab mrdp3 prdp3
	*** NO CHANGE
	* what is going on?
	
	g round_id1=10 if r==1
	g round_id2=2 if r==2
	egen round1=max(round_id1), by(pid)
	egen round2=max(round_id2), by(pid)
	g round=round1+round2
	
	egen hhid_size=sum(i), by(hhid)
	duplicates tag hhid r hh1, g(hh1_dup)
	g rat=hh1_dup/hhid_size
	
	tab rat if size_ch<0 & rdp==1
	
	* hist size_ch if s2r1==0, by(rdp)
	* hist size_ch if s2r1==1, by(rdp)
	*** checks out, that's good news
	
	**************************
	*** PRIMARY REGRESSION ***
	**************************
	xtset pid
	foreach var of varlist zwfa zhfa zbmi c_ill {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7, fe robust cluster(hh1)
	}

	********************************
	******* FAMILY STRUCTURE *******
	********************************
	
	xtset pid
	
	foreach var of varlist f_hoh m_hoh g_hoh {
*	xi: xtreg `var' i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	* *	* more likely to have father as head of the household (instead of mother?)
	* * * no movement on other h o h!!
	
	foreach var of varlist size adult_men adult_women child old_men old_women {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7, fe robust cluster(hh1)
	}
	** WAY LESS OLD WOMEN, MORE ADULT MEN, KIDS MOVE AS PREDICTED * aggregate old for easier analysis	
	
	xi: xtreg zwfa rdp i.r if a<=7, fe robust cluster(hh1)
	xi: xtreg zhfa rdp i.r if a<=7, fe robust cluster(hh1)
	* * * on net positive!
	xi: xtreg size rdp i.r, fe robust cluster(hh1)
	** positive effect beats out the negative effect!
	
	***************************
	**** ROBUSTNESS CHECKS ****
	***************************
	xtset pid
	forvalues r=2/8 {
	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r if s_`r'r1==0 & a<=7, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s_`r'r1==1 & a<=7, fe robust cluster(hh1)
	}
	}
	
	xtset pid
	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7 & `var'r1>0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7 & `var'r1>0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7 & `var'r1<0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7 & `var'r1<0, fe robust cluster(hh1)
	}
	*** *** concentrated among the sick kids!
	
	** shows that I've picked the best one, but the other are pretty consistent too
	
	* robust to movers?
	xtset pid
	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7 & max_move==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7 & max_move==0, fe robust cluster(hh1)
	}
	*** all set!
	
	** SOLID TO LOCATION CONTROLS i.prov
	
	** WHICH PROVINCE DRIVES IT?
	xtset pid
	
	forvalues r=1/9 {
	foreach var of varlist zwfa {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=12 & prov==`r', fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=12 & prov==`r', fe robust cluster(hh1)
	}
	}
	** checks out pretty well
	forvalues r=1/9 {
	foreach var of varlist zhfa {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=12 & prov==`r', fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=12 & prov==`r', fe robust cluster(hh1)
	}
	}
	

	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r*i.prov if s2r1==0 & a<=10, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r*i.prov if s2r1==1 & a<=10, fe robust cluster(hh1)
	}
	
	** pretty robust to provinces **
	
	
	tab h_ch prov if a<=12 & s2r1==0
	tab h_ch prov if a<=12 & s2r1==1
	
	** there is just not a whole lot
	xi: xtreg zwfa rdp i.r if s2r1==0 & a<=12 & prov!=1 & prov!=2, fe robust cluster(hh1)
	xi: xtreg zwfa rdp i.r if s2r1==1 & a<=12 & prov!=1 & prov!=2, fe robust cluster(hh1)

	xi: xtreg zwfa rdp i.r if s2r1==0 & a<=12 & (prov==1 | prov==2), fe robust cluster(hh1)
	xi: xtreg zwfa rdp i.r if s2r1==1 & a<=12 & (prov==1 | prov==2), fe robust cluster(hh1)
	
	
	
	
	
	** DRIVEN BY GENDER OF CHILDREN
	xtset pid
	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7 & sex==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==0 & a<=7 & sex==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7 & sex==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1 & a<=7 & sex==0, fe robust cluster(hh1)
	}
	** very comparable
	
	** exposure to other children issue: break out by who is joining the household
	
	** NON-LINEAR VERSIONS **
	xtset pid
	forvalues r=2/10 {
	foreach var of varlist zwfa zhfa {
	xi: xtreg `var' rdp i.r if sizer1==`r' & a<=7, fe robust cluster(hh1)
	}
	}
	
	forvalues r=2/10 {
	foreach var of varlist size {
	xi: xtreg `var' rdp i.r if sizer1==`r', fe robust cluster(hh1)
	}
	}
	
	foreach var of varlist piped roof_cor walls_b toilet_share flush c_sch_d c_check_up {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	** slightly better located: regular check_ups are unaffected

	xi: reg s2r1 c_sch_d move rooms mktv qual roof_cor walls_b toilet_share piped flush i.r  if h_ch==1 & (mktv<100000 | mktv==.), robust cluster(hhid) 	
	xi: reg s2r1 c_sch_d move rooms roof_cor walls_b toilet_share piped flush i.r  if h_ch==1 & (mktv<100000 | mktv==.), robust cluster(hhid) 	
	
	*** nothing measurable for education
	g c_absent_1=c_absent
	replace c_absent_1=0 if c_failed==0 & c_absent==.
	foreach var of varlist c_absent c_absent_1 c_failed {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	
	******************
	*** MECHANISMS ***
	******************
	
	xtset pid
	foreach var of varlist ceremony vice sch_spending health_exp inc home_prod food {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	** a little bit happening with health expenditure
	
	foreach var of varlist ceremony vice sch_spending health_exp inc home_prod food {
	xi: xtreg `var'_s rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var'_s rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	
	foreach var of varlist ceremony vice sch_spending health_exp inc home_prod food {
	xi: xtreg `var'_per rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var'_per rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
		** *** ** food expenditure percentage declined
		
	egen total_employed=sum(e), by(hhid)
	
	foreach var of varlist total_employed {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	
	foreach var of varlist food_imp food_imp_s food_imp_per {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	
	*** RETHINK MY FOOD MEASURES
	foreach var of varlist food food_s food_per {
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
		

	
	**************************************************************
	*** ALL POSSIBLE FAMILY COMBINATIONS AND MORE DEMOGRAPHICS ***
	**************************************************************
	forvalues r=0(5)50 {
	forvalues z=0/1 {
	g ai_`r'_`z'=(a>`r' & a<=`r'+5 & sex==`z')
	egen az_`r'_`z'=sum(ai_`r'_`z'), by(hhid)
	}
	}
	
*program define az
	quietly xi: xtreg az_20_0  rdp i.r, fe robust cluster(hh1)
	outreg2 using clean/data_analysis/reg_outcomes_az1, nonotes excel label replace keep(rdp) nocons ctitle("az_20_0")	
	outreg2 using clean/data_analysis/reg_outcomes_az2, nonotes excel label replace keep(rdp) nocons ctitle("az_20_0")	
	
	foreach var of varlist az_* {
	quietly xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	outreg2 using clean/data_analysis/reg_outcomes_az1, nonotes excel label append keep(rdp) nocons ctitle("`var' small")	
	quietly xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	outreg2 using clean/data_analysis/reg_outcomes_az2, nonotes excel label append keep(rdp) nocons ctitle("`var' big")	
	}
*end

*az


	xtset pid

	xi: xtreg size rdp i.r, fe robust cluster(hh1)
	xi: xtreg size i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg size rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg size rdp i.r if s2r1==1, fe robust cluster(hh1)
	
	forvalues r=1/10 {
	xi: xtreg size rdp i.r if sizer1==`r', fe robust cluster(hh1)
	}
	
	xi: xtreg adult_men rdp i.r, fe robust cluster(hh1)
	xi: xtreg adult_men i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg adult_men rdp i.r if s2r1==0, fe robust cluster(hh1)
	* men increase
	xi: xtreg adult_men rdp i.r if s2r1==1, fe robust cluster(hh1)
	* no change
	
	xi: xtreg adult_women rdp i.r, fe robust cluster(hh1)
	xi: xtreg adult_women i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg adult_women rdp i.r if s2r1==0, fe robust cluster(hh1)
	* women increase
	xi: xtreg adult_women rdp i.r if s2r1==1, fe robust cluster(hh1)
	* no change
	
	xi: xtreg child rdp i.r, fe robust cluster(hh1)
	xi: xtreg child i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg child rdp i.r if s2r1==0, fe robust cluster(hh1)
	* kids increase
	xi: xtreg child rdp i.r if s2r1==1, fe robust cluster(hh1)
	* no change
	
	g child_s=child/size
	
	xi: xtreg child_s rdp i.r, fe robust cluster(hh1)
	xi: xtreg child_s i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg child_s rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg child_s rdp i.r if s2r1==1, fe robust cluster(hh1)
	* nothing
	
	g child_a=child+az_15_1+az_15_0
	
	xi: xtreg child_a rdp i.r, fe robust cluster(hh1)
	xi: xtreg child_a i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg child_a rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg child_a rdp i.r if s2r1==1, fe robust cluster(hh1)
	
	g child_as=child_a/child_s
	
	xi: xtreg child_as rdp i.r, fe robust cluster(hh1)
	xi: xtreg child_as i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg child_as rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg child_as rdp i.r if s2r1==1, fe robust cluster(hh1)
	* not a huge amount
	
	g adult_men_s=adult_men/size
	
	xi: xtreg adult_men_s rdp i.r, fe robust cluster(hh1)
	xi: xtreg adult_men_s i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg adult_men_s rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg adult_men_s rdp i.r if s2r1==1, fe robust cluster(hh1)
	* no change
	
	g adult_women_s=adult_women/size
	
	xi: xtreg adult_women_s rdp i.r, fe robust cluster(hh1)
	xi: xtreg adult_women_s i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg adult_women_s rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg adult_women_s rdp i.r if s2r1==1, fe robust cluster(hh1)
	
*** simply scaling up of households.., even proportions
	foreach var of varlist ceremony vice home_prod food {
	xi: xtreg `var' rdp i.r, fe robust cluster(hh1)
	xi: xtreg `var' i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s2r1==1, fe robust cluster(hh1)
	}
	*straight zero for income, although rich households decline
	*nothing for food or non_food
	
	* less on ceremonies, vice and health goes up for big families
	* nothing for food
	
	foreach var of varlist ceremony vice sch_spending health_exp food {
	xi: xtreg `var' rdp i.r, fe robust cluster(hh1)
	xi: xtreg `var' i.rdp*i.s3r1 i.r, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==2, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==3, fe robust cluster(hh1)
	}
	
	
	foreach var of varlist size adult_men adult_women child old {
	xi: xtreg `var' rdp i.r, fe robust cluster(hh1)
	xi: xtreg `var' i.rdp*i.s3r1 i.r, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==2, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==3, fe robust cluster(hh1)
	}
	
	
	foreach var of varlist c_ill c_health c_absent c_failed {
	xi: xtreg `var' rdp i.r if s3r1==1, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==2, fe robust cluster(hh1)
	xi: xtreg `var' rdp i.r if s3r1==3, fe robust cluster(hh1)
	}

	
	
	xi: xtreg hoh_a rdp i.r, fe robust cluster(hh1)
	xi: xtreg hoh_a rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg hoh_a rdp i.r if s2r1==1, fe robust cluster(hh1)
	* no change

	xi: xtreg hoh_ch rdp i.r, fe robust cluster(hh1)	
	* do young men living with older members become more likely to become hoh?
	xi: xtreg hoh rdp i.r if a>18 & a<50 & sex==0 & s2r1==0, fe robust cluster(hh1)
	xi: xtreg hoh rdp i.r if a>18 & a<50 & sex==0 & s2r1==1, fe robust cluster(hh1)
	* nothing with hoh!

	
	
	*** MEN ***
	* by initial men
	forvalues r=0/4 {
	xi: xtreg adult_men rdp i.r if adult_menr1==`r', fe robust cluster(hh1)
	}
	*** strongest for 2 adult men initially
	* by initial women
	forvalues r=0/4 {
	xi: xtreg adult_men rdp i.r if adult_womenr1==`r', fe robust cluster(hh1)
	}
	*** no effect
	* small houses increase adult_men

	*** WOMEN ***
	* by initial women
	forvalues r=0/4 {
	xi: xtreg adult_women rdp i.r if adult_womenr1==`r', fe robust cluster(hh1)
	}
	*** strongest for no women
	* by initial men
	forvalues r=0/4 {
	xi: xtreg adult_women rdp i.r if adult_menr1==`r', fe robust cluster(hh1)
	}
	* increase for one man present: women joining husbands
	
	
	
	xi: xtreg adult_women rdp i.r if adult_women<3, fe robust cluster(hh1)
	xi: xtreg adult_women i.rdp*i.s2r1 i.r if adult_women<3, fe robust cluster(hh1)
	xi: xtreg adult_women rdp i.r if s2r1==0 & adult_women<3, fe robust cluster(hh1)
	xi: xtreg adult_women rdp i.r if s2r1==1 & adult_women<3, fe robust cluster(hh1)
	* still holds for women
	xi: xtreg adult_men rdp i.r if adult_men<3, fe robust cluster(hh1)
	xi: xtreg adult_men i.rdp*i.s2r1 i.r if adult_men<3, fe robust cluster(hh1)
	xi: xtreg adult_men rdp i.r if s2r1==0 & adult_men<3, fe robust cluster(hh1)
	xi: xtreg adult_men rdp i.r if s2r1==1 & adult_men<3, fe robust cluster(hh1)
	* still holds for men



	xi: xtreg a_ms rdp i.r, fe robust cluster(hh1)
	xi: xtreg a_ms i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg a_ms rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg a_ms rdp i.r if s2r1==1, fe robust cluster(hh1)
	* ratio is constant
	xi: xtreg a_ws rdp i.r, fe robust cluster(hh1)
	xi: xtreg a_ws i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg a_ws rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg a_ws rdp i.r if s2r1==1, fe robust cluster(hh1)
	* women ratio doesn't change!!

	xi: xtreg child rdp i.r, fe robust cluster(hh1)
	xi: xtreg child i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg child rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg child rdp i.r if s2r1==1, fe robust cluster(hh1)
	* not much happening here
		
	xi: xtreg old rdp i.r, fe robust cluster(hh1)
	xi: xtreg old i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg old rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg old rdp i.r if s2r1==1, fe robust cluster(hh1)
	** big houses lose grandparents
	xi: xtreg old_men rdp i.r, fe robust cluster(hh1)
	xi: xtreg old_men i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg old_men rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg old_men rdp i.r if s2r1==1, fe robust cluster(hh1)
	* somewhat of a decline, but less pronounced
	xi: xtreg old_women rdp i.r, fe robust cluster(hh1)
	xi: xtreg old_women i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg old_women rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg old_women rdp i.r if s2r1==1, fe robust cluster(hh1)
	* old women really decline for large households!!
	
	** not much on the gender ratio
	xi: xtreg adult_mw rdp i.r, fe robust cluster(hh1)
	xi: xtreg adult_mw i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg adult_mw rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg adult_mw rdp i.r if s2r1==1, fe robust cluster(hh1)
	
	
	xi: xtreg single_mother rdp i.r, fe robust cluster(hh1)	
	xi: xtreg single_mother i.rdp*i.s2r1 i.r, fe robust cluster(hh1)
	xi: xtreg single_mother rdp i.r if s2r1==0, fe robust cluster(hh1)
	xi: xtreg single_mother rdp i.r if s2r1==1, fe robust cluster(hh1)
	* mabye a little decline in single mother, but nothing really worth looking at
	
	tab adult_men adult_women if h_ch==1
	tab adult_men adult_women if h_chl==1
	tab adult_women old_women if h_ch==1
	tab adult_women old_women if h_chl==1
	
		
	tab hoh_ch h_ch
	hist hoh_a, by(h_ch)
	hist hoh_a, by(h_ch hoh_ch)
	** THIS TELLS A NICE STORY OF YOUNG FAMILIES GETTING STARTED: not really
	
	tab a hoh if h_ch==1 & hoh_ch==1
	
	* age of rdp recipients who change hoh	
	hist a if h_ch==1 & hoh_ch==1, by(hoh)
	
	* we see that hoh's that switch into rdp's are younger
	hist a if hoh_ch==1, by(hoh h_ch)
	** ** also tells a nice story
	
	* when switching doesn't occur the distributions look the same
	hist a if hoh_ch==0, by(hoh h_ch)
	
	tab sex hoh if h_ch==1 & hoh_ch==1
	
	
	* multi-parent households?
	label define h_ch1 0 "No RDP" 1 "Get RDP"
	label values h_ch h_ch1
	hist a if a<16, by(h_ch)
	hist a if a>16, by(h_ch r)
	hist a if a>20, by(prov h_ch)
	hist a if a>25 & a<55, by(h_ch r)

	hist a if a>25 & a<55, by(h_ch)

	hist a if a>25 & a<55, by(h_ch hoh)
	
	* why is this break there???
	
	hist a if a>25 & a<55 & hoh==1, by(h_ch)
	hist a if a>25 & a<55 & hoh==0, by(h_ch)
	
	hist a if a>20 & a<55 & owner==1, by(h_ch)
	hist a if a>20 & a<55 & owner==0, by(h_ch)
		
	hist a if a>20, by(hoh h_ch)	
	hist a if a>20, by(owner h_ch)
	
end

main


