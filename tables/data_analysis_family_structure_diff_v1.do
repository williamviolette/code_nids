
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
 	use clean/data_analysis/house_treat, clear
  	drop if hhgeo2011==1 | hhgeo2011==3
	quietly change_variables
	*** *** ***
	*** difference is with drop_obs and drop_rdp_leavers
*	quietly drop_observations
	quietly keep_race
	quietly drop_rdp_leavers
	*** *** ***
	quietly rebalance
 	quietly egen max_age=max(a), by(pid)
 	quietly construct_hh1
 	quietly g a_2=a*a
 	quietly groupings_2
 	quietly groupings_3
 	quietly family_structure
 	quietly inc_exp_per_person
 	save clean/data_analysis/house_treat_regs, replace
end

*****
program drop_rdp_leavers
	egen min_h_ch=min(h_ch), by(pid)
	egen max_h_ch=max(h_ch), by(pid)
	egen max_rdp=max(rdp), by(pid)
	g rdp_r1=rdp if r==1
	egen rdp_r1m=max(rdp_r1), by(pid)
	drop if rdp_r1m==1
	drop if min_h_ch<0
	drop if max_rdp==1 & max_h_ch<1
end

program drop_observations_1
	egen inc_m=max(inc), by(hh1)
	drop if inc_m>10000 & inc_m!=.
end

program define keep_race
	keep if (best_race==1 | best_race==2)
end
*****

program drop_observations
*	drop if rooms>10
	drop if size>13
	drop if min_h_ch<0
*	drop if h_ch==-1   This alternative reduces the significance of the negative results
	egen inc_m=max(inc), by(pid)
	drop if inc_m>20000
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
	by pid: g h_ch=rdp[_n]-rdp[_n-1]
	by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
	by pid: g size_ch=size[_n]-size[_n-1]
	g rooms_r1_id=rooms if r==1
	egen roomsr1=max(rooms_r1_id), by(pid)
	g size_r1_id=size if r==1
	egen sizer1=max(size_r1_id), by(pid)
	g size_r1_2_id=size if r==2
	egen size_r1_2=max(size_r1_2_id), by(pid)
	replace sizer1=size_r1_2 if r>=2 & sizer1==.
*	egen min_h_ch=min(h_ch), by(pid)
	
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
	replace s3=2 if size>4 & size<=8
	replace s3=3 if size>8
	g r3r1_id=r3 if r==1
	egen r3r1=max(r3r1_id), by(pid)
	g s3r1_id=s3 if r==1
	egen s3r1=max(s3r1_id), by(pid)
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
	g s2=0 if size<=4
	replace s2=1 if size>4
	g s2r1_id=s2 if r==1
	egen s2r1=max(s2r1_id), by(pid)
	g s2r1_2_id=s2 if r==2
	egen s2r1_2=max(s2r1_2_id), by(pid)
	replace s2r1=s2r1_2 if r>=2 & s2r1==.	
end

program define family_structure
	g adult_men_id=(a>18 & a<55 & sex==1)
	g adult_women_id=(a>18 & a<55 & sex==0)
	egen adult_men=sum(adult_men_id), by(hhid)
	g adult_menr1_id=adult_men if r==1
	egen adult_menr1=max(adult_menr1_id), by(pid)
	egen adult_women=sum(adult_women_id), by(hhid)
	g adult_womenr1_id=adult_women if r==1
	egen adult_womenr1=max(adult_womenr1_id), by(pid)
	g old_men_id=(a>60 & sex==1 & a<.)
	g old_women_id=(a>60 & sex==0 & a<.)
	egen old_men=sum(old_men_id), by(hhid)
	egen old_women=sum(old_women_id), by(hhid)
	g old=old_men+old_women
	g child_id=(a<16)
	egen child=sum(child_id), by(hhid)
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
	** left behind * do separately for rounds
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
	*** NOW DO ALTERNATE LEFT OUT
	egen mrdp_h=max(rdp), by(hh1)
	egen mrdp_i=max(rdp), by(pid)
	** father and mother resident
	g m_res=1 if c_mthhh==1
	replace m_res=0 if c_mthhh==2
	g f_res=1 if c_fthhh==1
	replace f_res=0 if c_fthhh==2
	** meatfat
	g meat_fat=meat+fat if meat!=. & fat!=.
	replace meat_fat=meat if meat_fat==. & meat!=.
	replace meat_fat=fat if meat_fat==. & fat!=.
end

program define inc_exp_per_person
	foreach var of varlist vice ceremony home_prod sch_spending health_exp non_food_other public_other non_food public food food_imp non_food_imp exp_imp exp inc inc_l inc_r {
	g `var'_s=`var'/size
	g `var'_per=`var'/exp_imp
	}
end


program define size_graphs

	use clean/data_analysis/house_treat_regs, clear
	
	egen inc_m=max(inc), by(pid)
*	drop if inc_m>5000
	egen max_size=max(size), by(pid)	
	drop if max_size>=11
	egen min_size=min(size), by(pid)
	drop if min_size<=1
	
	g mdb=hhdc2011 
	replace mdb=gc_dc2011 if mdb==.
	egen m_h_ch=mean(h_ch), by(mdb)
	drop if m_h_ch<.10
	
	g inc_lr1id=inc_l if r==1
	egen inc_lr1=max(inc_l), by(pid)
	g inc_lr2id=inc_l if r==2
	egen inc_lr2=max(inc_lr2id), by(pid)
	replace inc_lr1=inc_lr2 if inc_lr1==. & r>=2
	g inc_lr1_2=inc_lr1*inc_lr1
	
	replace own=0 if own==2
	
	g il=1 if inc_lr1<=3500
	replace il=0 if inc_lr1>3500 & inc_lr1<.

	sort pid r
	by pid: g size_lag=size[_n-1]
	by pid: g zwfa_lag=zwfa[_n-1]
	by pid: g zwfa_ch=zwfa[_n-1]-zwfa-[_n]
	by pid: g zhfa_ch=zhfa[_n-1]-zhfa[_n]
	by pid: g zhfa_lag=zhfa[_n-1]
	by pid: g rooms_lag=rooms[_n-1]
	foreach var of varlist own flush piped adult_men adult_women old child {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	by pid: g inc_ll=inc_l[_n-1]
	g ill=inc_ll<=3500
	
	egen min_a=min(a), by(hh1)
	
	replace h_ch=. if rdp==1 & h_ch==0
	
	** WHY ARE ROUNDS SO DIFFERENT
	
*	reg rooms_ch h_ch i.r, robust cluster(hh1)
	
	g size_lag4=size_lag>=4

	global l_b "1500"
	global u_b "5500"

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
	xi: reg `v'_ch h_ch i.size_lag i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=., cluster(hh1) robust
	}
	
			
	foreach v in size adult_men adult_women child old {
	xi: reg `v'_ch h_ch i.size_lag i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=. & r==2, cluster(hh1) robust
	xi: reg `v'_ch h_ch i.size_lag i.r if inc_lr1<$u_b & inc_lr1>$l_b & h_ch!=. & r==3, cluster(hh1) robust
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


main

