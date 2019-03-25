

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"


use clean/data_analysis/house_treat_regs_anna_tables, clear

program define main
end


program define adult_weight_1
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
* 	Check if results are robust to excluding renters
*	replace h_ch=. if rent_d==1 & h_ch==1
	
	forvalues r=1/3 {
	replace a_weight_`r'=. if a_weight_`r'<0
	g weight_`r'=a_weight_`r'
	replace weight_`r'=c_weight_`r' if a_weight_`r'==.
	}
	g weight = (weight_1+weight_2+weight_3)/3
	replace weight=(weight_1+weight_2)/2 if weight==.
	replace weight=weight_1 if weight==.
	replace weight=weight_2 if weight==.
	replace weight=weight_3 if weight==.
	
	egen med_w=median(weight), by(a sex)
	egen sd_w=sd(weight), by(a sex)
	g zw=(weight-med_w)/sd_w	
	replace zw=. if zw>3 | zw<-3
	sort pid r
	by pid: g zw_ch=zw[_n]-zw[_n-1]

	g h_ch_sl=h_ch*size_lag
	
	g at_7_18=(a>7 & a<=18)
	g h_ch_at_7_18=h_ch*at_7_18
	g at_sl_7_18=at_7_18*size_lag
	g h_ch_sl_at_7_18=h_ch*at_7_18*size_lag

	g at_60=(a>18)
	g h_ch_at_60=h_ch*at_60
	g at_sl_60=at_60*size_lag
	g h_ch_sl_at_60=h_ch*at_60*size_lag

	replace r_parhpid=. if r_parhpid<100
	g spouse_id=pid+r_parhpid
	
	egen cres1=max(cres), by(spouse_id hhid)
	g child_res=(cres1>0 & cres1<.)
		
	g ad_p_id=(a>=19 & a<=45 & child_res==1)
	egen ad_p=sum(ad_p_id), by(hhid)
	sort pid r
	by pid: g ad_p_ch=ad_p[_n]-ad_p[_n-1]
	g ad_np_id=(a>=19 & a<=45 & child_res==0)
	egen ad_np=sum(ad_np_id), by(hhid)
	sort pid r
	by pid: g ad_np_ch=ad_p[_n]-ad_np[_n-1]	

	g mr=m_res==1
	replace mr=. if a>20
	g fr=f_res==1
	replace fr=. if a>20
	sort pid r
	by pid: g mr_ch=mr[_n]-mr[_n-1]
	by pid: g fr_ch=fr[_n]-fr[_n-1]
	by pid: g m_res_ch=m_res[_n]-m_res[_n-1]
	by pid: g f_res_ch=f_res[_n]-f_res[_n-1]	
	
	g son=(r_relhead==4)
	g gs=(r_relhead==4 | r_relhead==13)
	
	sort pid r
	by pid: g zw_lag=zw[_n-1]
	
	sort pid r
	by pid: g rent_pay_ch=rent_pay[_n]-rent_pay[_n-1]
	
	* * * limit to size_lag <= 11 because of the coverage of RDP: How to test this limitation?

				****************************
				**** MAIN SPECIFICATION ****
				****************************

	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a i.r if size_lag<=11 & a<70 & sex==1, robust cluster(hh1)
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a i.r if size_lag<=11 & a<70 & sex==0, robust cluster(hh1)
	
		* * * check each age bin separately * * *
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a>7 & a<=18, robust cluster(hh1)
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)
	
		* * * ARE SIZE CHANGES DRIVEN BY PARENTS WITH KIDS OR PEOPLE WITHOUT KIDS * * *
	xi: reg ad_p_ch h_ch h_ch_sl size_lag  i.r if size_lag<=11, robust cluster(hh1)
	xi: reg ad_np_ch h_ch h_ch_sl size_lag  i.r if size_lag<=11, robust cluster(hh1)
	xi: reg ad_p_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=15, robust cluster(hh1)
	xi: reg ad_np_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=15, robust cluster(hh1)
		* driven by parents! ( fathers entering? ) 

		* * * ARE PARENTS MORE OR LESS LIKELY TO CORRESIDE? * * *
	xi: reg m_res_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg f_res_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg mr_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg fr_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
			* father does seem to correside more! (not significant but suggestive)
	
		* * * WEAKER EFFECT IF A PARENT IS RESIDENT?
	xi: reg zw_ch i.h_ch*i.m_res i.m_res*h_ch_sl i.m_res*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.f_res i.f_res*h_ch_sl i.f_res*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
		* mother has a protective effect
	xi: reg zw_ch i.h_ch*i.mr i.mr*h_ch_sl i.mr*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.fr i.fr*h_ch_sl i.fr*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
		* nothing with this measure
	
		* * * DO ADULTS WITHOUT KIDS GET FATTER WHILE PARENTS DON'T? * * *
	xi: reg zw_ch i.h_ch*i.child_res i.child_res*h_ch_sl i.child_res*size_lag a sex i.r if size_lag<=11 & a>18 & a<50, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.child_res i.child_res*h_ch_sl i.child_res*size_lag a sex i.r if size_lag<=11 & a>18 & a<50 & sex==0, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.child_res i.child_res*h_ch_sl i.child_res*size_lag a sex i.r if size_lag<=11 & a>18 & a<50 & sex==1, robust cluster(hh1)
			* ACTION IS REALLY AMONG WOMEN! * * * WOMEN WITHOUT KIDS EAT MORE, WOMEN WITH KIDS DON'T!? * also because the men is not a great match

		* * * DO SONS OF HoH DO BETTER OR NOT? * * *
	xi: reg zw_ch i.son*h_ch i.son*h_ch_sl i.son*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	xi: reg zw_ch i.gs*h_ch i.gs*h_ch_sl i.gs*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)

	xi: reg zw_ch i.son*h_ch i.son*h_ch_sl i.son*size_lag a sex i.r if size_lag<=11 & a<=10, robust cluster(hh1)
	xi: reg zw_ch i.gs*h_ch i.gs*h_ch_sl i.gs*size_lag a sex i.r if size_lag<=11 & a<=10, robust cluster(hh1)

		* * * CONTROLLING FOR LAGGED ZWEIGHT GIVES A SENSE OF SELECTION: ARE FAMILIES TAKING SICK KIDS? YA! * * *
				* * * OR: ARE THERE NATURAL PROCESSES OF HEALTH ETC.?
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex zw_lag i.r if size_lag<=11 & a<50, robust cluster(hh1)
			* results hold but they weaken a little bit
	

		* * * FIRST STAGE RESULTS * * *
	xi: reg size_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg child_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg adult_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg size_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg child_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg adult_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
			** COMMON SUPPORT IS THAT A PROBLEM? **
	
		* * * TEST IDENTIFICATION ASSUMPTION ! * * *
		sort pid r
		by pid: g sl_2=size_lag[_n-1]
		by pid: g size_chl=size_ch[_n-1]		
	xi: reg h_ch size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg h_ch sl_2 size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	xi: reg h_ch size_chl a sex i.r if size_lag<=11, robust cluster(hh1)
		* pretty decent support of assumptions *
		
		* * * LOOK AT RENTING AND OWNERSHIP * * *
	tab rent_d h_ch
	tab rent_d own if h_ch==1
			* lots of families that rent also own, could be within household transfer ?	or payment to gov?


		* * * MECHANISMS * * *

	
	xi: reg pi_hhremitt_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhremitt_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhremitt_ln_p_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg pi_hhgovt_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhgovt_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhgovt_ln_p_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg pi_hhwage_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhwage_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhwage_ln_p_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg pi_hhincome_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhincome_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg pi_hhincome_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg ex_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg ex_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg ex_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg exp1_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60 & h_fdtot_ln_ch!=., robust cluster(hh1)
	xi: reg exp1_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60 & h_fdtot_ln_ch!=., robust cluster(hh1)
	xi: reg exp1_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60 & h_fdtot_ln_ch!=., robust cluster(hh1)

	xi: reg h_fdtot_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg h_fdtot_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg h_fdtot_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg h_fdtot_e_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg public_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg public_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg public_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg public_e_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg non_food_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg non_food_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg non_food_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg non_food_e_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg sch_spending_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg sch_spending_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg sch_spending_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg sch_spending_e_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

	xi: reg health_exp_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg health_exp_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg health_exp_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg health_exp_e_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)


	xi: reg rent_pay_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg rent_pay_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg rent_pay_ln_p_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	

	xi: reg inc_ln_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)

	xi: reg inc_ln_p_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)





		** this is good stuff

	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11 & a<=20, robust cluster(hh1)

	xi: reg size_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if a<60 & (zw_ch>-1.5 & zw_ch<1.5), robust cluster(hh1)
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if a<60 & (zw_ch>-2 & zw_ch<2), robust cluster(hh1)
	
	xi: reg zw_ch h_ch size_lag h_ch_sl  a sex i.r if a<=7 & size_lag<14, robust cluster(hh1)
	xi: reg zw_ch h_ch size_lag h_ch_sl  a sex i.r if a>20 & a<50 & size_lag<14, robust cluster(hh1)
	
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag a sex i.r if a<60 & (zw_ch>-1.5 & zw_ch<1.5), robust cluster(hh1)
	xi: reg zw_ch h_ch size_lag h_ch_sl h_ch_at_60 at_sl_60 h_ch_sl_at_60 at_60  a sex i.r if ((a<=50 & a>20) &  & size_lag<14, robust cluster(hh1)
	
	xi: reg zw_ch h_ch size_lag h_ch_sl h_ch_at_60 at_sl_60 h_ch_sl_at_60 at_60  a sex i.r if a<=50 & size_lag<14, robust cluster(hh1)	
	xi: reg zwfa_ch h_ch size_lag h_ch_sl  a sex i.r if a<=7 & size_lag<14, robust cluster(hh1)

end	

program define modal_cases
	use clean/data_analysis/house_treat_regs_anna_tables, clear
 	g a_2=a*a
 	
 	
 	** predict who is added on by the household's characteristics!
 	
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd
	
 	* who is left behind?
 	tab noch r
 	

	* who is added on? 	
	egen h_ch_hh=max(h_ch), by(hhid)
	g join=(h_ch_hh==1 & (h_ch==0 | h_ch==.))
	** GET RID OF FERTILITY **
	replace join=0 if a<=3
	
	tab rid join
	egen sj=sum(join), by(hhid)
	tab sj if sj>0
	
	*** HOW IS THIS SELECTION WORKING? ***
	g join_child=join
	replace join_child=0 if a>18 & join==1
	g join_25=join
	replace join_25=0 if a>25 & join==1
		
	reg join_child size adult_men adult_women child inc i.r if h_ch_hh==1 & sj<=2, cluster(hh1) robust
	
	reg join_child size adult child inc i.r if h_ch_hh==1 & sj<=3, cluster(hh1) robust
	
*	hist a if join==1 & sj<=3 & sj>0 & a<50, by(sj)
	
	tab r_relhead sj if join==1 & sj<=3 & sj>0
	
	reg join_child size adult_men adult_women child inc i.r if h_ch_hh==1 & sj<=2, cluster(hh1) robust
	
	tab r_relhead join_child if join==1

	tab r_relhead join_child if join==1 & sj<=3
	
	tab r_relhead join_child if join==1 & sj<=3
	
	tab r_relhead join_child if join==1 & sj>3
	
	** kids are more likely to join together
	tab join_child sj if sj>0
	
	tab e if join==1
	tab join e if h_ch_hh==1 & sj>0, r
	tab join ue if h_ch_hh==1 & sj>0, r
	
	hist fwag if h_ch_hh==1 & sj>0, by(join)
	
	tab join remt if h_ch_hh==1 & sj>0
	
	tab a sj if join==1
	tab a sj if join==1 & sj>0
	
	egen msl=max(size_lag), by(hhid)
	g s6ml=msl>=6
	
	tab sj msl if sj>0 & join==1

	tab sj size if sj>0 & join==1
		
*	hist a if join==1 & sj>0, by(sj s6)
	
	g j_size=sj/size
	
*	duplicates drop hhid, force
	tab j_size size if j_size>0
	hist j_size if j_size>0, by(size)
	hist j_size if j_size>0 & size>4
		
*	hist a if h_ch_hh==1, by(join)
	tab a join if h_ch_hh==1
	
		* number of duplicates of hh1's
	duplicates tag hh1 hhid, gen(dd)
 	tab dd h_ch
 	tab dd size if h_ch==1
 	
 	** number of distinct hh1 id's
 	egen tag=tag(hh1 hhid)
 	egen st=sum(tag), by(hhid)
 	
 	tab st h_ch
 	
 	** make sure all household members are in every round
 	egen min_rid=min(rid), by(hhid)
 	
 	tab dd st if h_ch==1
 *	duplicates drop hhid, force
 	tab sj st if sj>0
 	
 	tab min_rid st if h_ch==1
	 * * *                  * * *
	* * * LOOK AT NOCH A BIT * * *
	 * * *                  * * *
	egen nc=sum(noch), by(hhid)
	
	egen phc=max(h_ch), by(pid)
	egen hhc=max(phc), by(hhid)

	tab noch  r_relhead if hhc==1 & nc>0, r
		* likely to be less related to the household head * 
end


*** WHAT IS GENERATING SIZE CHANGES
program define size_changes_how
	use clean/data_analysis/house_treat_regs_anna_tables, clear	
	forvalues r=5(5)80 {
	g a`r'_id=(a>=`r'-5 & a<`r')
	egen a`r'=sum(a`r'_id), by(hhid)
	sort pid r
	by pid: g ach`r'=a`r'[_n]-a`r'[_n-1]
	}
	
	xi: reg ach5 i.h_ch*size_lag i.r if size_lag<14, robust cluster(hh1)	
	outreg2 using clean/data_analysis/size_look, replace nocons tex(frag)
	foreach var of varlist ach* {
	xi: reg `var' i.h_ch*size_lag i.r if size_lag<14, robust cluster(hh1)	
	outreg2 using clean/data_analysis/size_look, append nocons tex(frag)
	xi: reg `var' h_ch size_lag i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/data_analysis/size_look, append nocons tex(frag)
	xi: reg `var' h_ch size_lag i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/data_analysis/size_look, append nocons tex(frag)
	}
end
 
program define size_changes_how10
 	use clean/data_analysis/house_treat_regs_anna_tables, clear
 	
 	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)		
 	
	forvalues r=10(10)80 {
	g a`r'_id=(a>=`r'-10 & a<`r')
	egen a`r'=sum(a`r'_id), by(hhid)
	sort pid r
	by pid: g ach`r'=a`r'[_n]-a`r'[_n-1]
	}
	
	xi: reg ach10 i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)	
	outreg2 using clean/data_analysis/size_look1, replace nocons tex(frag)
	foreach var of varlist ach* {
	xi: reg `var' i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)	
	outreg2 using clean/data_analysis/size_look1, append nocons tex(frag)
	xi: reg `var' h_ch size_lag i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/data_analysis/size_look1, append nocons tex(frag)
	xi: reg `var' h_ch size_lag i.r if size_lag>5 & size_lag<11, robust cluster(hh1)
	outreg2 using clean/data_analysis/size_look1, append nocons tex(frag)
	}
	seeout using clean/data_analysis/size_look1
end

program define adult_ratio
	use clean/data_analysis/house_treat_regs_anna_tables, clear	
	g adult_ratio=adult/child
	sort pid r
	by pid: g a_r_ch=adult_ratio[_n]-adult_ratio[_n-1]
	
	xi: reg a_r_ch i.h_ch*size_lag i.r if size_lag<14, robust cluster(hh1)
	
	xi: reg a_r_ch i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)
	
	
			* nothing with adult to child ratio!
	g a0_3_id=(a>=0 & a<=3)
	egen a0_3=sum(a0_3_id), by(hhid)
	g a4_18_id=(a>=4 & a<=18)
	egen a4_18=sum(a4_18_id), by(hhid)
	g a19_30_id=(a>=19 & a<=30)
	egen a19_30=sum(a19_30_id), by(hhid)
	g a31_60_id=(a>=31 & a<=60)
	egen a31_60=sum(a31_60_id), by(hhid)
	g a61_id=(a>=61)
	egen a61=sum(a61_id), by(hhid)
	
	foreach var of varlist a0_3 a4_18 a19_30 a31_60 a61 {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}	
	
	*** First stage: look at sizes
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label replace nocons title("Household Size")
	foreach v in  a0_3 a4_18 a19_30 a31_60 a61  {
	xi: reg `v'_ch i.h_ch*size_lag i.r if size_lag<11, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons 
	}

	foreach v in  a0_3 a4_18 a19_30 a31_60 a61  {
	xi: reg `v'_ch i.h_ch*size_lag i.r if size_lag<14, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons 
	}

	foreach v in  a0_3 a4_18 a19_30 a31_60 a61  {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	outreg2 using clean/tables/size_full_1, nonotes tex(frag) label append nocons 
	}
	
end
	

program define robustness_zwfa_zhfa
	use clean/data_analysis/house_treat_regs_anna_tables, clear
 	g a_2=a*a

	xi: reg size_ch h_ch size_lag i.r if size_lag<=5, robust cluster(hh1)

	xi: reg size_ch h_ch size_lag i.r if size_lag>=8 & size_lag<14, robust cluster(hh1)
		
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<=5, robust cluster(hh1)

	xi: reg size_ch i.h_ch*size_lag i.r if size_lag>=8 & size_lag<14, robust cluster(hh1)

	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<12, robust cluster(hh1)
	
		

	* * * * *

 	
	xi: reg zwfa_ch i.h_ch*size_lag sex a a_2 i.r, robust cluster(hh1)
	
	xi: reg zhfa_ch i.h_ch*size_lag sex a a_2 i.r, robust cluster(hh1)
	

	xi: reg size_ch i.h_ch*size_lag sex a a_2 i.r if size_lag<14 & a<=7 & zwfa_ch!=., robust cluster(hh1)
		* descriptively similar
	xi: reg size_ch i.h_ch*size_lag sex a a_2 i.r if size_lag<14 & zwfa_ch!=., robust cluster(hh1)

	xi: reg size_ch i.h_ch size_lag sex a i.r if size_lag<=6 & zwfa_ch!=., robust cluster(hh1)
	xi: reg size_ch i.h_ch size_lag sex a i.r if size_lag>6 & zwfa_ch!=., robust cluster(hh1)

		* * * tough to make this argument..?
	
	xi: reg zwfa_ch i.h_ch*size_lag sex a a_2 i.r if size_lag<14 & a<=7, robust cluster(hh1)
	
	xi: reg zhfa_ch i.h_ch*size_lag sex a a_2 i.r if size_lag<14 & a<=7, robust cluster(hh1)
	
	
	xi: reg zwfa_ch i.h_ch size_lag sex a a_2 i.r if size_lag<6, robust cluster(hh1)
	
	xi: reg zwfa_ch i.h_ch size_lag sex a a_2 i.r if size_lag>=8, robust cluster(hh1)


end	


program define alternative_weight_measures
	use clean/data_analysis/house_treat_regs_anna_tables, clear
 	g a_2=a*a

	forvalues r=1/3 {
	replace c_weight_`r'=. if c_weight_`r'<=0
	sort pid r
	by pid: g w_ch`r'=c_weight_`r'[_n]-c_weight_`r'[_n-1] 
	}
	g c_w12=(c_weight_1+c_weight_2)/2
	sort pid r
	by pid: g w_ch12=c_w12[_n]-c_w12[_n-1]
	
	xi: reg w_ch1 i.h_ch*size_lag sex i.a a_2 i.r, robust cluster(hh1)
	xi: reg w_ch2 i.h_ch*size_lag sex i.a a_2 i.r, robust cluster(hh1)
	xi: reg w_ch12 i.h_ch*size_lag sex i.a a_2 i.r, robust cluster(hh1)
	
	xi: reg w_ch1 i.h_ch*size_lag sex i.a a_2 i.r if a<=7, robust cluster(hh1)
	xi: reg w_ch12 i.h_ch*size_lag sex i.a a_2 i.r if a<=7, robust cluster(hh1)
end
	
	



program define old_stuff

	***********************
	*** LOWESS ADDED ON ***
	***********************
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
	egen h_ch_hh=max(h_ch), by(hhid)
	g join=(h_ch_hh==1 & (h_ch==0 | h_ch==.))
	replace join=0 if a<=2
	egen sj=sum(join), by(hhid)
	g ja=a if join==1
	egen mja=min(ja), by(hhid)
	* nice pattern! 
	tab mja sj
	g j_size=sj/size
	tab sj if h_ch_hh==1
	duplicates drop hhid, force
	
	lowess sj size_lag if h_ch_hh==1
	
	lowess sj size_lag if sj>0
	lowess j_size size_lag if sj>0	
	* that makes sense
	
	**************************
	*** LOWESS LEFT BEHIND ***
	**************************
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
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
	egen ns=sum(noch), by(hhid)
	g nss=ns/size
	
	lowess ns size if hch==1 & size<11
	lowess nss size if hch==1 & size<11 & nss>0

	***********************************
	*** WHICH KIDS ARE LEFT BEHIND! ***
	***********************************

	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
	
	g i=1
	egen size_a=sum(i), by(hhid)
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd

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
	
	tab rid noch
	tab noch r
	
	replace r_relhead=. if r_relhead<0
	
	tab noch r
	
	egen ns=sum(noch), by(hhid)
	
	*** COMIGRATION ***
	duplicates tag hh1 hhid, gen(dd1)
	
	
*	lowess ns size if hch==1
*	hist a, by(noch)
	
	tab a noch
	tab a size_lag if noch==1
	
	g son_id=(r_relhead==4 & a<=16)
	g foster_id=(r_relhead>4 & r_relhead<=7 & a<=16)
	g nep_oth_id=((r_relhead==19 | r_relhead==25 | r_relhead==26) & a<=16)
	g granchild_id=(r_relhead==13 & a<=16)
	
	sort pid r
	by pid: g lo=noch[_n-1]
	replace lo=0 if lo==.
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	
	
	** what really matters is the relationship to hoh
	g h_chp=h_ch
	replace h_chp=0 if son_id==0
	g h_chnp=h_ch
	replace h_ch=0 if son_id==1
	
	sort pid
	by pid: g c_ill_ser_lag=c_ill_ser[_n-1]
	reg h_ch c_ill_ser_lag i.r, robust cluster(hh1)
		* ya I don't think that's true!
	
	g md=size>size_lag*2
	
	tab md h_ch if a<=16
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_chp*size_lag i.h_chnp*size_lag i.r if a<=10, robust cluster(hh1)
	}	
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_ch*size_lag i.lo*size_lag size_lag i.r if a<=10, robust cluster(hh1)
	}
	
	xtset hhid
	
	g oth=(foster_id==1 | nep_oth_id==1)

	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a<=16 & r<3, fe robust
	}
	
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a>2 & a<=18 & r<3, fe robust
	}
	** infants
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a<=7 & r<3, fe robust
	}
	
	
	



	*** HEALTHIER KIDS ARE LESS LIKELY TO GO!
		* relationship to hoh is helpful too!

	xtreg noch c_health c_ill c_ill_ser a sex m_res f_res i.r if hch==1 & a<=18 & r<3, robust cluster(hhid)
	xtreg noch c_health c_ill c_ill_ser a sex m_res f_res i.r if a<=18 & r<3, robust cluster(hhid)

		* key: here we see how selection works across hh's (father resident helps your chances)

	

	********************************
	*** WHICH KIDS ARE ADDED ON! ***
	********************************
	
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
	
	g i=1
	egen size_a=sum(i), by(hhid)
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd
	
	egen h_ch_hh=max(h_ch), by(hhid)
	g join=(h_ch_hh==1 & (h_ch==0 | h_ch==.))
	
	tab rid join
	egen sj=sum(join), by(hhid)
	g j_size=sj/size
	tab j_size if j_size>0	
*	hist a if h_ch_hh==1, by(join)
	tab a join if h_ch_hh==1
	
	tab a sj if join==1
*	hist sj if join==1
	tab sj size_lag

		** mostly add one person, rarely more	
*	hist a if join==1 & a>2, by(sj)
*	hist sj if sj>0
*	duplicates drop hhid, force
*	lowess sj size_lag if sj>0
	tab sj if sj>0
	tab own h_ch if h_ch_hh==1, mis
		* works, lots of owners are people that join!
	
	g h_chnj=h_ch
	replace h_chnj=0 if j_size>0 & j_size<.
	g h_chj=h_ch
	replace h_chj=0 if j_size==0
	g h_chjo=h_ch
	replace h_chjo=0 if j_size==0 | (j_size>.3 & j_size<.)
	g h_chji=h_ch
	replace h_chji=0 if j_size<.3
	
	sort pid r
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	g s4=size_lag<=4
*	tab r_relhead join if h_ch_hh==1 &  a<=10
*	hist r_relhead if h_ch_hh==1 &  a<=10, by(join)

	*** HOW TO IDENTIFY KIDS THAT JOIN NEW HOUSEHOLD?
	**** NO COMIGRANTS!
	duplicates tag hh1 hhid, gen(dd)
	
*	hist a if h_ch==1, by(dd)
*	tab a dd if h_ch==1
	tab dd if a>2 & a<10 & h_ch_hh==1
	
*	hist size if a<10 & h_ch==1, by(dd)
	
	g alone=(dd==0 | dd==1)
	g h_ch_tog=h_ch
	replace h_ch_tog=0 if alone==1
	g h_ch_alone=h_ch
	replace h_ch_alone=0 if alone==0
	
	sort pid r
	by pid: g h_ch_tog_le=h_ch_tog[_n+1]
	by pid: g h_ch_alone_le=h_ch_alone[_n+1]

	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch h_ch_tog h_ch_alone size_lag i.r if a<=10 & size_lag<=4, robust cluster(hh1)
	}	
	
	foreach var of varlist toih wath rooms roof_cor walls_b  {
	xi: reg `var'_ch h_ch_tog h_ch_alone size_lag i.r if a<=10 & size_lag<=4, robust cluster(hh1)
	}	
	
	** OK SO WE KNOW HOW SICK KIDS ARE RELATIVE TO NEW HOUSES: WHAT ABOUT HOW SICK KIDS ARE RELATIVE TO OLD HOUSES???
	xtset hhid
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xtreg `var' h_ch_tog_le h_ch_alone_le a sex i.r if a<=10 & r<3, fe robust
	}
	
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_ch_tog*size_lag i.h_ch_alone*size_lag i.r if a<=10, robust cluster(hh1)
	}	
	
	
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch h_chnj i.h_chj*j_size size_lag i.r if a<=10, robust cluster(hh1)
	}	
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch h_chnj h_chjo h_chji size_lag i.r if a<=10, robust cluster(hh1)
	}

		* are the gains concentrated among the sick kids that join the household ???
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_chnj*i.c_ill_ser i.h_chjo*i.c_ill_ser i.h_chji*i.c_ill_ser size_lag i.r if a<=10, robust cluster(hh1)
	}

	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_chnj*i.s4 i.h_chjo*i.s4 i.h_chji*i.s4 i.r if a<=10, robust cluster(hh1)
	}
	


	xtset hhid
	foreach var of varlist a sex  zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xi: xtreg `var' i.join*j_size if a>2 & a<=16 & r>1 & h_ch_hh==1, fe robust
	}
	** marginal child is sicker..
	
	*** use the panel data!
		
	
	xtset hhid
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xtreg `var' join a sex if a>2 & a<=18 & r>1, fe robust
	}

	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xtreg `var' join if a>2 & a<=18 & r>1, fe robust
	}
	
	
	** ARE THERE MORE BABIES?!?  NO **
	g dob=2008-a if r==1
	replace dob=2010-a if r==2
	replace dob=2012-a if r==3
	
	g b1_id=(dob>=2008)
	egen b1=sum(b1_id), by(hhid)
	
	g baby_id=(a>=0 & a<=2)
	egen baby=sum(baby_id), by(hhid)
	sort pid r
	by pid: g baby_ch=baby[_n]-baby[_n-1]
	by pid: g b1_ch=b1[_n]-b1[_n-1]
	
	xi: reg baby i.h_ch*size_lag a sex inc i.r if r>1, robust cluster(hh1)
	xi: reg b1_ch i.h_ch*size_lag a sex inc i.r if r>1, robust cluster(hh1)
	
	egen m_size_ch=max(size_ch) , by (hhid)
	tab m_size_ch join
	
	
	
	*** BIG ANALYSIS ***
	
	use clean/data_analysis/house_treat_regs, clear
	
	replace rooms=. if rooms>10
	replace size=. if size>11
	replace size_lag=. if size_lag>11
	
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000

	replace cres=0 if cres==. & cnres>0 & cnres<.
	replace cnres=0 if cnres==. & cres>0 & cres<.
	
	g cper=cres/(cres+cnres)
	g tot=cres+cnres

	egen fres=max(f_res), by(hhid)
	egen mres=max(m_res), by(hhid)
	
	g c0_2id=(a<=2 & a>=0)
	g c3_10id=(a<=10 & a>=3)
	g c11_18id=(a<=18 & a>=11)
	egen c0_2=sum(c0_2id), by(hhid)
	egen c3_10=sum(c3_10id), by(hhid)
	egen c11_18=sum(c11_18id), by(hhid)

	foreach var of varlist cr cn cry cny crvy cnvy {
	replace `var'=. if sex==1
	}
	g tc=cr+cn
	egen crm=max(cr), by(hhid)
	egen cnm=max(cn), by(hhid)
	
	g son_id=(r_relhead>=4 & r_relhead<=7 & a<=16)
	g nep_oth_id=((r_relhead==19 | r_relhead==25 | r_relhead==26) & a<=16)
	g granchild_id=(r_relhead==13 & a<=16)
	
	egen son=sum(son_id), by(hhid)
	egen nep_oth=sum(nep_oth_id), by(hhid)
	egen granchild=sum(granchild_id), by(hhid)
	
	g gsid=(a>=55 & a<.)
	egen gs=sum(gsid), by(hhid)
	
	** WHAT DOES ROOMS PER PERSON RATIO LOOK LIKE?
	g r_s=rooms/size
	replace r_s=. if r_s>2
	
	sort pid r
	by pid: g r_s_ch=r_s[_n]-r_s[_n-1]
	xi: reg r_s_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	
*	hist r_s, by(h_ch)
*	hist r_s if r_s<3, by(h_ch)
	
	
	foreach var of varlist gs c0_2 c3_10 c11_18 cr cn cry cny crvy cnvy f_res m_res fres mres son nep_oth granchild hoh_a son_id granchild_id tc tot {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach v in  cr cn cry cny crvy cnvy m_res f_res fres mres {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
		* part of it is sending biological children away
	
	** how is kid's relationship to parents changing??
	xi: reg son_id_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg granchild_id_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
		
		** change in hoh!
	xi: reg old_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg gs_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)

	

	
	foreach v in  c0_2 c3_10 c11_18 {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
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
	xi: xtreg e lo1 i.r, fe robust cluster(hh1)
	xi: xtreg inf lo1 i.r, fe robust cluster(hh1)
	xi: xtreg size lo1 i.r, fe robust cluster(hh1)
	xi: xtreg ue lo1 i.r, fe robust cluster(hh1)
	xi: xtreg inc lo1 i.r, fe robust cluster(hh1)
	xi: xtreg food lo1 i.r, fe robust cluster(hh1)

	
		
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
	g `var'_lnp=`var'_ln/size
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_lnp_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	}
	g ac=adult/child
	sort pid r
	by pid: g ac_ch=ac[_n]-ac[_n-1]
	g size4=size_lag>4
	g size_lag4=size_lag*size4
	replace size_lag=. if size_lag>11	

	
		* EXPENDITURE MECHANISMS *
	foreach var of varlist *_ln {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	* expenditure itself doesnt seem to change much (except for food)
	 * so 
	
	

	*** now figure out size
	
	xi: reg size_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag>=3 & size_lag<=6, robust cluster(hh1)
	** even some weak evidence of adjustment
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<=6, robust cluster(hh1)
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag>=4, robust cluster(hh1)
		* gradient isn't really there below, but there is a size increase, which is nice
	
	xi: reg size_ch i.h_ch*i.size_lag i.r, robust cluster(hh1)

	xi: reg size_ch i.h_ch*size_lag size4 i.h_ch*size_lag4 i.r, robust cluster(hh1)
	*** pretty consistent across groups (small getting larger?)
	
	foreach v in size adult_men adult_women adult child old ac {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
		* KEY REGRESSION TO LOOK AT *
	foreach v in size adult_men adult_women adult child old ac {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	

	xi: reg fs_ch i.h_ch*size_lag i.r if fs_ch>-.5 & fs_ch<.5, robust cluster(hh1)
	
	
	
	
	*** EMOTIONAL WELL BEING IS KINDA COOL: SOME PREDICTED DIRECTIONS
	foreach var of varlist a_em* {
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach var of varlist a_em* {
	xi: reg `var'_ch i.h_ch*size_lag i.r if size_lag<15, robust cluster(hh1)
	}
	
	
	
	
	** make change variables
	
	foreach v in h_empl h_rent h_grn h_prvpen h_tinc e ue c_failed c_absent zwfa zhfa zbmi rooms size own flush piped adult_men adult_women adult old child inc_l inc_r inc fwag owner walls_b roof_cor wath toih concrete  sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	by pid: g `v'_ch=`v'[_n]-`v'[_n-1]
	by pid: g `v'_lag=`v'[_n-1]
	}
	foreach v in inc inc_l inc_r fwag sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	g `v'p=`v'/size
	sort pid r
	by pid: g `v'_pch=`v'p[_n]-`v'p[_n-1]
	}
	
end
		
	
	
	
	
	
	
	
	
	
