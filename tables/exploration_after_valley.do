
	
	clear all
	set mem 4g
	set maxvar 10000

	cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main_tables
	quietly clean_data1
	quietly clean_data
*	quietly exploration
end


program define exploration


	use clean/data_analysis/regs_nate_tables_3_3, clear	

	drop if rent_d==1 & h_ch==1

	egen x_h_ch=max(h_ch), by(hhid)
	g join=(x_h_ch==1 & h_ch!=1 & a>=3)
	egen sum_join=sum(join), by(hhid)
	
	g jid=(sum_join>0 & sum_join<.)
	
	g sl2=size_lag*size_lag
	
	sort pid r
	by pid: g hoh_a_lag=hoh_a[_n-1]

	drop inc_ad im
		* cut the income threshold hard *
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	
		* cut change threshold hard
	egen hclust=sum(h_chi), by(cluster)
	
	
	foreach var of varlist h_fdtot meat carbs veggies fats baby eat_out h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn vice comm services health_exp sch_spending  home_prod public_other {
	replace `var'=0 if `var'==.
	g ln_`var'=ln(`var'+1)
	replace ln_`var'=0 if ln_`var'==.
	sort pid r
	by pid: g ln_ch_`var'=ln_`var'[_n]-ln_`var'[_n-1]
	}
	
	g hoh_man_id=(hoh==1 & sex==1)
	egen hoh_man=max(hoh_man_id), by(hhid)
	
	g unc_hoh=(r_relhead==19 | r_relhead==18)
	g step_hoh=(r_relhead==5 | r_relhead==22 | r_relhead==25 | r_relhead==26 | r_relhead==17)
	g mis_hoh=r_relhead==.
	drop p_hoh
	g p_hoh=r_relhead==4
	g gp_hoh=(p_hoh==1 | g_hoh==1)
	
	
	foreach var of varlist c_health c_ill p_hoh hoh_man g_hoh unc_hoh gp_hoh step_hoh mis_hoh {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
		** GENERATE LAGGED VARIABLES
	foreach var of varlist zhfa zwfa zbmi zw c_health c_ill {
	sort pid r
	by pid: g `var'_la=`var'[_n-1]
	g `var'_a_l=`var'_la*a
	}
	sort pid r
	foreach var of varlist gp_hoh unc_hoh g_hoh old hoh_man e ue hoh_a child adult size m_res f_res p_hoh step_hoh piped flush adult_men adult_women mis_hoh {
	by pid: g `var'_la=`var'[_n-1]
	}
	sort pid r
		by pid: g hoh_a_ch=hoh_a[_n]-hoh_a[_n-1]
		by pid: g f_res_lag=f_res[_n-1]
	


	
	* kids live with parents more?
	foreach var of varlist  hoh_man hoh_a child adult adult_men adult_women size p_hoh g_hoh unc_hoh gp_hoh old step_hoh mis_hoh {
	reg `var'_ch h_chi i.r a i.sex `var'_la if hclust>0 & im<=5000 & a<16 & r_relhead!=., cluster(hh1) robust
	reg `var'_ch h_chi i.r a i.sex size_la child_la if hclust>0 & im<=5000 & a<16 & r_relhead!=., cluster(hh1) robust
	reg `var'_ch h_chi h_chn move i.r a i.sex size_la child_la if hclust>0 & im<=5000 & a<16 & r_relhead!=., cluster(hh1) robust
	}
			* hoh becomes a man! and a parent?! which man is it?!

	foreach var of varlist pi_hhincome_ln_ch pi_hhwage_ln_ch pi_hhgovt_ln_ch pi_hhremitt_ln_ch {
	reg `var' h_chi h_chn i.r if im<=3500  & hclust>10, robust cluster(hh1)
	}
	
	foreach var of varlist pi_hhincome_ln_ch pi_hhwage_ln_ch pi_hhgovt_ln_ch pi_hhremitt_ln_ch {
	reg `var' h_chi i.r if im<=5000 & hclust>0, robust cluster(hh1)
	}
	
	xtset cluster
	foreach var of varlist zhfa_ch {
	xi: xtreg `var' i.h_chi*a h_chn i.r i.a*zhfa i.sex*zhfa if im<=3500, robust fe
	}
	xtset cluster
	foreach var of varlist zhfa_ch zwfa_ch {
	xi: reg `var' h_chi h_chn i.r i.a*zhfa i.sex*zhfa if im<=3500 & hclust>1, cluster(hh1) robust
	xi: xtreg `var' h_chi h_chn i.r i.a*zhfa i.sex*zhfa if im<=3500 & hclust>1, robust fe
	}
	

	** LOOK AT HEALTH
	foreach var of varlist zhfa zwfa zw zbmi c_health c_ill {
*	xi:reg `var'_ch h_chi move h_chn `var'_la `var'_a_l i.r a i.sex if im<=5000 & hclust>0, cluster(hh1) robust
	xi:reg `var'_ch i.h_chi*a zhfa_la zhfa_a_l zbmi_la zbmi_a_l i.r a i.sex if im<=5000 & hclust>0, cluster(hh1) robust
	xi:reg `var'_ch i.h_chi*a move h_chn zhfa_la zhfa_a_l zbmi_la zbmi_a_l i.r a i.sex if im<=5000 & hclust>0, cluster(hh1) robust
	}
	
	
		* doesn't hold too badly: strongest for little kids
	
	
		* diversity of diet?
	foreach var of varlist h_fdtot_ln_ch meat_ln_ch carbs_ln_ch veggies_ln_ch fats_ln_ch baby_ln_ch eat_out_ln_ch {
	reg `var' h_chi h_chn i.r if im<=3500, robust cluster(hh1)
	}
	

	foreach var of varlist h_fdtot_ln_ch meat_ln_ch carbs_ln_ch veggies_ln_ch fats_ln_ch baby_ln_ch eat_out_ln_ch {
	reg `var' h_chi i.r if im<=5000 & hclust>0, robust cluster(hh1)
	}

	foreach var of varlist h_fdtot meat carbs veggies fats baby eat_out {
	reg ln_ch_`var' h_chi h_chn i.r if im<=5000 & ln_ch_meat!=. & a<=16, robust cluster(hh1)
	}


			* nothing good here
			g ele_per=h_nfelespn/expenditure
		*	hist ele_per if ele_per<.3 & ele_per>0 & im<=3500, by(h_chi)
			* not a huge change
			
	foreach var of varlist h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn vice comm services health_exp sch_spending  home_prod public_other {
	reg ln_ch_`var' h_chi h_chn i.r a i.sex if im<=3500, cluster(hh1) robust
	}
	* WITHOUT H_CHN
	foreach var of varlist h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn vice comm services health_exp sch_spending  home_prod public_other {
	reg ln_ch_`var' h_chi i.r a i.sex if im<=3500, cluster(hh1) robust
	}	

	foreach var of varlist h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn vice comm services health_exp sch_spending  home_prod public_other {
	reg ln_ch_`var' h_chi i.r a i.sex if im<=5000 & hclust>0, cluster(hh1) robust
	}	
		
	* * * 
	foreach var of varlist  services_ln_ch non_food_ln_ch food_ln_ch public_ln_ch ex_ln_ch trans_ln_ch e_ch ue_ch {
	reg `var' h_chi h_chn i.r a i.sex if im<=3500, cluster(hh1) robust
	}
	
	
	
	foreach var of varlist hoh_a child adult size m_res f_res p_hoh piped flush {
	reg `var'_ch h_chi h_chn move i.r a i.sex `var'_la if im<=5000 & a<16, cluster(hh1) robust
	reg `var'_ch h_chi h_chn move i.r a i.sex size_la if im<=5000 & a<16, cluster(hh1) robust
*	reg `var' h_chi h_chn i.r a i.sex if im<=5000 & size_lag<=4, cluster(hh1) robust
*	reg `var' h_chi h_chn i.r a i.sex if im<=5000 & size_lag>4, cluster(hh1) robust
	}
	* WITHOUT H_CHN
foreach var of varlist hoh_a child adult size m_res f_res p_hoh piped flush {
	reg `var'_ch h_chi i.r a i.sex `var'_la if im<=5000 & a<16, cluster(hh1) robust
	reg `var'_ch h_chi i.r a i.sex size_la if im<=5000 & a<16, cluster(hh1) robust
	}



end


program define clean_data
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
	********************************
	**** NEED TO GENERATE TYPES ****
	********************************

	g h_chi=h_ch
	replace h_chi=0 if oidhh==0
	g h_chn=h_ch
	replace h_chn=0 if oidhh==1

	tab oidhh oidhh1 if h_ch==1
		
	egen mh_chi=sum(h_chi), by(hhid)
	egen mh_chn=sum(h_chn), by(hhid)
	
	g new_size_id=(a>=3 & a<.)
	egen new_size=sum(new_size_id), by(hhid)
	g ir=mh_chi/new_size
	g nr=mh_chn/new_size
	
	g hil=h_chi
	replace hil=0 if ir<.5 & ir<1
	g his=h_chi
	replace his=0 if ir>=.5 & ir<.
	g hio=h_chi
	replace hio=0 if ir!=1	& ir<.
	
	g hnl=h_chn
	replace hnl=0 if ir<.5 & ir<.
	g hns=h_chn
	replace hns=0 if ir>=.5


	
	g at_7_18=(a>7 & a<=18)
	g at_60=(a>18)	
	g at_sl_7_18=at_7_18*size_lag
	g at_sl_60=at_60*size_lag
	foreach v in h_ch h_chi h_chn hil his hnl hns hio {
	g `v'_sl=`v'*size_lag
	g `v'_at_7_18=`v'*at_7_18
	g `v'_sl_at_7_18=`v'*at_7_18*size_lag
	g `v'_at_60=`v'*at_60
	g `v'_sl_at_60=`v'*at_60*size_lag
	}

	
	replace m_res=1 if c_mthhh_pid>0 & c_mthhh_pid<. & m_res==.
	replace m_res=0 if c_mthhh_pid==77
	replace f_res=1 if c_fthhh_pid>0 & c_fthhh_pid<. & f_res==.
	replace f_res=0 if c_fthhh_pid==77
	
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

	replace r_parhpid=. if r_parhpid<100
	g spouse_id=pid+r_parhpid
	
	egen c7=max(cr7), by(spouse_id hhid)
	g parent7=(c7>0 & c7<.)
	egen c18=max(cr18), by(spouse_id hhid)
	g parent18=(c18>0 & c18<.)
			
	g ad_p7_id=(a>=19 & a<=60 & parent7==1)
	egen ad_p7=sum(ad_p7_id), by(hhid)
	sort pid r
	by pid: g ad_p7_ch=ad_p7[_n]-ad_p7[_n-1]
	g ad_np7_id=(a>=19 & a<=60 & parent7==0)
	egen ad_np7=sum(ad_np7_id), by(hhid)
	sort pid r
	by pid: g ad_np7_ch=ad_p7[_n]-ad_np7[_n-1]	

	g ad_p18_id=(a>=19 & a<=60 & parent18==1)
	egen ad_p18=sum(ad_p18_id), by(hhid)
	sort pid r
	by pid: g ad_p18_ch=ad_p18[_n]-ad_p18[_n-1]
	g ad_np18_id=(a>=19 & a<=60 & parent7==0)
	egen ad_np18=sum(ad_np18_id), by(hhid)
	sort pid r
	by pid: g ad_np18_ch=ad_p18[_n]-ad_np18[_n-1]	
	
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
	quietly label_variables

	save clean/data_analysis/regs_nate_tables_3_3, replace

end
	
program define clean_data1
	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
	replace size_lag=. if size_lag>13
	replace size=. if size>13
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
	save clean/data_analysis/house_treat_regs_anna_tables, replace
end


program define label_variables

	label variable m_res_ch "M Res Ch"
	label variable f_res_ch "F Res Ch"

	label variable m_res "Mother Resident"
	label variable f_res "Father Resident"
	
	label variable m_res "Mother Resident"
	label variable f_res "Father Resident"
	label variable ad_p7_ch "Adult Parents Ch"
	label variable ad_np7_ch "Adult Non-Par Ch"
	

	label variable size_lag "Size t-1"

	label variable size_ch "Size Ch"
	label variable child_ch "Children Ch"
	label variable adult_ch "Adult Ch"
	
	label variable zw_ch "Weight Ch"
	
	foreach v in his hil hns hnl h_ch h_chi h_chn {
	label variable `v' "`v'"
	label variable `v'_sl "`v'xSize t-1"	
	label variable `v'_at_7_18 "`v' 7-18" 
	label variable `v'_at_60 "`v' over 18"
	label variable `v'_sl_at_7_18 "`v'xSize t-1 for 7-18"
	label variable `v'_sl_at_60 "`v'xSize t-1 for over 18"
	}
	label variable at_7_18 "Age 7-18"
	label variable at_sl_7_18 "Size t-1 for 7-18"
	label variable at_60 "Age over 18"
	label variable at_sl_60 "Size t-1 for over 18"
end	
	
main_tables
