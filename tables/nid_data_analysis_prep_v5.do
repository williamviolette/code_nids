

clear all
set mem 4g
set maxvar 10000

cd "${rawdata}"

* cd "/Users/willviolette/Desktop/pstc_work/nids"

* input: data_v1
* output: clean/data_analysis/ child_count, child_count_v1, 
			* house_treat_inc_exp, house_treat_regs_inc_exp, house_treat_regs_anna_tables


program define main
	* quietly house_data
	use clean/data_v1.dta, clear
	rdp_variable_cleaned 
	move_variable_cleaned  	
	house_variables			
	demographic_variables	
	children_variables	
	adult_variables 	
	expenditure_income 		
	make_food_measures	
	prov_fix 				
	remit  					
	school  				
	health  				
	neighborhood  			
*	drop if rdp==.
	drop if r_pres==2
	egen age_m=max(D_a), by(pid)
	child_count_res /* check */
	save "clean/data_analysis/child_count", replace
	child_count
	use "clean/data_analysis/child_count_v1", clear
	global exp "a_decd a_decdpid a_decd2 a_decdpid2 h_fdtot h_fdo h_fdospn h_fdogft h_fdopay h_fdtot_brac1 h_fdtot_brac2 h_fdtot_brac3 h_fdtot_brac4 h_fdtot_brac5 h_fdtot_brac6 h_fdtot_cat expf expnf expenditure exprough"
	global inc "a_em1inc a_em1pay a_em1inc_s a_em1pcrt a_em1pcrt_a a_em2inc a_em2pay a_em2inc_sh a_emstax a_eminc a_eminc_sh a_empsll a_empser a_empsll_v a_empser_v a_emhearn a_unemavaexp a_incrnt a_incrnt_v a_incsale a_inco a_inco_v a_inco_o a_fwbrelinc a_fwbstp15 a_fwbstptd a_fwbstp2yr a_fwbstp5yr a_fwbinc5yr a_em1inc_cat a_em2inc_cat a_emsinc_cat a_emcinc a_emcinc_cat a_em1pcrtlm a_em1pcrtlm_a a_emsincifr_cat a_emsincfr_cat swag cheq prof extr bonu othe help spen ppen uif comp dis chld fost care indi inhe rnt retr brid gift loan sale remt fwag_flg othe_flg uif_flg comp_flg rnt_flg loan_flg remt_flg plot cdep plot_flg E_h_empl E_h_rent E_h_prvpen E_h_tinc h_tinc_show h_nfinctax h_nfinctaxspn h_negdthfinc h_negdthfrin h_negwrkinc h_negjobinc h_negreminc h_neggrninc h_negoinc h_posjobinc h_posreminc h_posgrninc h_poso1inc h_poso2inc h_tinc_brac1 h_tinc_brac2 h_tinc_brac3 h_tinc_brac4 h_tinc_brac5 h_tinc_cat h_nfinctaxspnyr h_tinc_brac6 hhquint hhq_inc hhq_incb hhq_incb_flg hhincome hhincome_flg hhwage hhgovt hhother hhinvest hhcapital hhremitt hhimprent_inc hhimprent_flg hhagric pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhimprent"
	keep pid hhid r rdp prov move r_parhpid A_* H_* C_* D_* E_* S_* HE_* N_* $exp $inc h_* cluster hhgeo2011 hhgeo2001 zhfa zwfa zbmi zwfh r_relhead h_ownpid1 h_ownpid2 f_pid1 m_pid m_pid1 csm r_pres r_absexp best_race fwag cwag swag fwag_flg cwag_flg swag_flg hhmdbdc2011 gc_dc2011 gc_mdbdc2011 hhdc2011 hhdc2001  gc_dc2001 a_weight* a_height* dis chld fost care dis_flg chld_flg fost_flg care_flg cdep cdep_flg hhgovt pi_hhgovt h_dwltyp h_fdtot c_weight_1 c_weight_2 c_weight_3 c_height_1 c_height_2 c_height_3 c_waist_1 c_waist_2 carbs meat veggies fats baby eat_out c_mthhh c_fthhh c_mthhh_pid c_fthhh_pid h_grnthse h_sub a_emobth a_emomnd a_emodep a_emoeff a_emohope a_emofear a_emoslp a_emohap a_emolone a_emogo	
	renpfix H_
	renpfix C_
	renpfix D_
	renpfix E_
	renpfix A_
	renpfix S_
	renpfix HE_
	renpfix N_
	family_structure
	inc_exp_per_person
*	quietly balanced_panel
	save clean/data_analysis/house_treat_inc_exp, replace
end

program define main_2
 	use clean/data_analysis/house_treat_inc_exp, clear
*	g urbanid=hhgeo2011==2
*	egen urbanmin=min(urbanid), by(pid)
*	keep if urbanmin==1
  	drop if hhgeo2011==1 | hhgeo2011==3 | hhgeo2011==-3 | hhgeo2011==.
*  	drop if hhgeo2011==1 | hhgeo2011==-3 | hhgeo2011==.
  	keep if (best_race==1 | best_race==2)
*  	keep if (best_race==1 | best_race==2 | best_race==4)
  	hsub9
	change_variables
 	construct_hh1
 	oid /* check */
	drop_rdp_leavers
	g mdb=hhdc2011
	replace mdb=gc_dc2011 if mdb==.
 	save clean/data_analysis/house_treat_regs_inc_exp, replace
 	clean_data
end

**** **** **** **** **** **** ****

program define remit
	foreach var of varlist a_cr a_cg {
	replace `var'=. if `var'<0 
	replace `var'=0 if `var'==2
	rename `var' A_`var'
	}
	foreach var of varlist a_crt1 a_cgt1  {
	replace `var'=. if `var'<0
	replace `var'=12 if `var'>12 & `var'<.
	rename `var' A_`var'
	}
	foreach var of varlist 	a_cryrv1 a_cgyrv1  {
	replace `var'=. if `var'<0
	rename `var' A_`var'
	}
end

program define school

	foreach var of varlist edlstm_ltrr07 edlstm_ltrr08 edlstm_ltrr09 edlstm_ltrr10 edlstm_quin edlstm_nofee c_ed08curgrd c_ed10curgrd c_ed12curgrd c_edcurgrd a_ed08att a_ed10att a_ed11att  a_ed14att a_ed16att {
	replace `var'=. if `var'<0
	}
	foreach var of varlist a_ed08att a_ed10att a_ed11att a_ed14att a_ed16att {
	replace `var'=0 if `var'==2
	}
	
	* learner to teacher ratio *	
	g S_s_ltr=edlstm_ltrr07 if r==1
	replace S_s_ltr=edlstm_ltrr08 if r==1 & S_s_ltr==.
	replace S_s_ltr=edlstm_ltrr09 if r==2 & S_s_ltr==.
	replace S_s_ltr=edlstm_ltrr10 if r==2 & S_s_ltr==.
	replace S_s_ltr=. if D_a >20
	egen S_s_ltr_hh=max(S_s_ltr), by(hhid r)
	
	* school quintile *
	replace edlstm_quin=. if D_a > 20
	g S_s_quin= edlstm_quin
	egen S_s_quin_hh=max(edlstm_quin) , by(hhid r)

	* school fees *
	replace edlstm_nofee=. if D_a > 20
	replace edlstm_nofee=0 if edlstm_nofee==2
	g S_s_fee= edlstm_nofee
	egen S_s_fee_hh=max(edlstm_nofee) , by(hhid r)	
	
	* school attendance *
		* child	
	g S_s_att_c=1 if c_ed08curgrd>0 & c_ed08curgrd<7 & r==1
	replace S_s_att_c=0 if c_ed08curgrd==7 & r==1
	replace S_s_att_c=1 if c_ed10curgrd>0 & c_ed10curgrd<7 & r==2
	replace S_s_att_c=0 if c_ed10curgrd==7 & r==2
	replace S_s_att_c=1 if c_ed12curgrd>0 & c_ed12curgrd<7 & r==3
	replace S_s_att_c=0 if c_ed12curgrd==7 & r==3
	replace S_s_att_c=1 if c_edcurgrd>0 & c_edcurgrd<7 & r==4
	replace S_s_att_c=0 if c_edcurgrd==7 & r==4
	replace S_s_att_c=1 if c_edcurgrd>0 & c_edcurgrd<7 & r==5
	replace S_s_att_c=0 if c_edcurgrd==7 & r==5


		* adult
	g S_s_att_a=a_ed08att if r==1
	replace S_s_att_a=a_ed10att if r==2
	replace S_s_att_a=a_ed11att if r==3
	replace S_s_att_a=a_ed14att if r==4
	replace S_s_att_a=a_ed16att if r==5

		* total
	g S_att=S_s_att_c
	replace S_att=S_s_att_a if S_att==.
	
end	

program define health
	
	* health_consults
	g HE_check_up=c_hlchckup if c_hlchckup>0
	replace HE_check_up=0 if HE_check_up==3
	g HE_eye_test=c_hlvistst if c_hlvistst>0
	replace HE_eye_test=0 if HE_eye_test==2
	g HE_med_aid=c_hlmedaid if c_hlmedaid>0
	replace HE_med_aid=0 if c_hlmedaid==2
	
	* adult health
	g HE_a_health=a_hldes if a_hldes>0
	
	* consult
	rename a_hlcon HE_a_consult
	replace HE_a_consult=. if HE_a_consult<0
	* location
	rename a_hlcontyp HE_a_concult_loc
	g HE_a_public=0 if HE_a_concult_loc!=. & HE_a_concult_loc>0
	replace HE_a_public=1 if HE_a_concult_loc==1 | HE_a_concult_loc==3

end

program define neighborhood
	* burial society
	rename a_com2 N_n_burial
	replace N_n_burial=0 if N_n_burial==2
	replace N_n_burial=. if N_n_burial<0
	
	* trust
	rename a_trstcls N_n_trust
	rename a_trststrn N_n_trust_str
	replace N_n_trust=. if N_n_trust<0
	replace N_n_trust_str=. if N_n_trust_str<0	
	
	* preference to stay in the area
	rename a_wblv N_n_stay
	replace N_n_stay=. if N_n_stay<0
	
end
		
	
program define oid
	g oid=((pid==h_ownpid1 | pid==h_ownpid2 | pid==h_ownpid3) & pid!=.)
	g oid1=(pid==h_ownpid1 & pid!=.)
	egen oidhh=max(oid), by(hh1 hhid)
	egen oidhh1=max(oid1), by(hh1 hhid)
end

program define clean_data
	use clean/data_analysis/house_treat_regs_inc_exp, clear
	g inc_pc=inc/size
	egen inc_m=max(inc_pc), by(pid)
	quietly sum inc_m, detail
	drop if inc_m>r(p95)
*	replace size_lag=. if size_lag>13
*	replace size=. if size>13
	egen esum=sum(e), by(hhid)
	g e_s=esum/size
	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	replace rent_pay=0 if rent_d==0
	replace exp1=exp1+rent_pay if rent_pay!=.
	replace exp1=rent_pay if exp1==.
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
	foreach var of varlist rent_pay h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	g `var'_ln=ln(`var'+1)
	g `var'_lnp=ln(`var'+1)/size
	g `var'_lna=ln(`var'+1)/adult
	g `var'_p=`var'/size
	g `var'_a=`var'/adult
	g `var'_e=`var'/exp1
	replace `var'_e=. if `var'==0 | ex==0
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	by pid: g `var'_ln_a_ch=`var'_lna[_n]-`var'_lna[_n-1]
	by pid: g `var'_e_ch=`var'_e[_n]-`var'_e[_n-1]
	by pid: g `var'_p_ch=`var'_p[_n]-`var'_p[_n-1]
	by pid: g `var'_a_ch=`var'_a[_n]-`var'_a[_n-1]
	}
	save clean/data_analysis/house_treat_regs_anna_tables, replace
end


program define expenditure_income
	foreach v in h_empl h_rent h_grn h_prvpen h_tinc {
	replace `v'=. if `v'<0
	replace `v'=0 if `v'==2
	}
	rename h_empl E_h_empl
	rename h_rent E_h_rent
	rename h_grn E_h_grn
	rename h_prvpen E_h_prvpen
	rename h_tinc E_h_tinc
	
	foreach var of varlist  *spn {
	replace `var'=0 if `var'<=0 | `var'==.
	}
	foreach var of varlist *spnyr {
	replace `var'=0 if `var'<=0 | `var'==.
	replace `var'=`var'/12
	replace `var'=0 if `var'<=0 | `var'==.
	} 
	egen E_adult_exp=rowtotal(h_nfalcspn h_nfcigspn h_nfentspn h_nfsprspn  h_nftrpspn h_nfcerspn h_nftrpspnyr h_nfcerspnyr)
	egen E_vice=rowtotal(h_nfalcspn h_nfcigspn)
	egen E_ceremony=rowtotal(h_nfcerspnyr  h_nfcerspn )
	egen E_home_prod=rowtotal(h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr h_nffrnspn h_nfdwlspn h_nfkitspn h_nfwsh)	
	egen E_sch_spending=rowtotal( h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn )
	egen E_health_exp=rowtotal( h_nfhspspnyr h_nfdocspnyr h_nftradspnyr h_nfhomspn h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn )
	egen E_non_food_other=rowtotal ( h_nfbedspnyr h_nfmatspnyr h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn )
	egen E_public_other=rowtotal (h_nffrn h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn)
	egen E_ins= rowtotal ( h_nfinslspn h_nfinsfspn h_nfinsshspn )
	egen E_comm= rowtotal ( h_nfcelspn h_nftelspn h_nfnetspn  )
	g E_non_food = E_health_exp + E_sch_spending + E_vice + E_non_food_other
	g E_public = E_home_prod + E_ceremony + E_public_other
	g E_food = h_fdtot if h_fdtot>=0
	g fff=E_food
	replace fff=0 if fff==.
	egen E_kid_exp=rowtotal(E_food h_nfmedaidspn h_nfdocspn h_nfhspspn h_nfmedspn h_nftradspn h_nfhomspn h_nfdocspnyr h_nfhspspnyr h_nftradspnyr h_nfhomspnyr)
	g E_food_imp = expf 
	g E_non_food_imp = expnf 
	g E_exp_imp = expenditure
	g E_exp = exprough
	g E_inc = pi_hhincome if pi_hhincome>=0
	g E_inc_l = pi_hhwage if pi_hhwage>=0
	g E_inc_r = pi_hhremitt if pi_hhremitt>=0
	g E_inc_g = pi_hhgovt if pi_hhgovt>=0
	egen E_exp_n = rowtotal ( *spn *spnyr )
	egen E_services= rowtotal ( h_nfwatspn h_nfelespn h_nfmunspn h_nflevspn h_nfenespn )
	foreach var of varlist E_* {
	replace `var'=. if `var'<=0
	}
	g E_water_exp=h_nfwatspn
	g E_ele_exp=h_nfelespn
	g E_water_sp=h_nfwat if h_nfwat >0
	replace E_water_sp=0 if E_water_sp==2
	g E_ele_sp=h_nfele if h_nfele >0
	replace E_ele_sp=0 if E_ele_sp==2
	g E_mun_sp=h_nfmun if h_nfmun >0
	replace E_mun_sp=0 if E_mun_sp==2
	g E_lev_sp=h_nflev if h_nflev >0
	replace E_lev_sp=0 if E_lev_sp==2
	replace E_services=. if E_services==0
	replace E_services=0 if E_water_sp==0 & E_ele_sp==0 & E_mun_sp==0 & E_lev_sp==0
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

program define inc_exp_per_person
	foreach var of varlist vice ceremony home_prod sch_spending health_exp non_food_other public_other non_food public food food_imp non_food_imp exp_imp exp inc inc_l inc_r {
	g `var'_s=`var'/size
	g `var'_per=`var'/exp_imp
	}
end

**** **** **** **** **** **** ****

program define prov_fix
	rename hhprov2011 prov
	replace prov=gc_prov2011 if prov==.
	replace prov=prov2011 if prov==.
	g mdb=hhdc2011 
	replace mdb=gc_dc2011 if mdb==.
	replace mdb=dc2011 if mdb==.
end

program define demographic_variables
	rename hhsizer D_size
	g D_a=best_age_yrs if best_age_yrs>=0
	g D_sex=best_gen if best_gen>0
	replace D_sex=0 if D_sex==2
end

program define make_food_measures
	foreach var of varlist  h_fdmm h_fdsmp h_fdflr h_fdrice h_fdpas h_fdbis h_fdrm h_fdrmc h_fdchi h_fdfsh h_fdfshc h_fdvegd h_fdpot h_fdvego h_fdfru h_fdoil h_fdmar h_fdpb h_fdmlk h_fdegg h_fdsug h_fdsd h_fdfrut h_fdcer {
	replace `var'spn=0 if `var'<0 | `var'spn==.
	}
	egen carbs = rowtotal(h_fdmmspn h_fdsmpspn h_fdflrspn h_fdricespn h_fdpasspn h_fdbisspn)
	egen meat = rowtotal(h_fdrmspn h_fdrmcspn h_fdchispn h_fdfshspn h_fdfshcspn)
	egen veggies = rowtotal(h_fdvegdspn h_fdpotspn h_fdvegospn h_fdfruspn)
	egen fats = rowtotal(h_fdoilspn h_fdmarspn h_fdpbspn h_fdmlkspn h_fdeggspn h_fdsugspn h_fdsdspn h_fdfrutspn h_fdcerspn)
	g baby = h_fdbabyspn
	replace baby=. if baby<0
	egen eat_out = rowtotal( h_fdrdyspn h_fdoutspn )
	foreach var of varlist carbs meat veggies fats baby eat_out {
	replace `var'=. if `var'==0
	}
	replace carbs=0 if h_fdmm==2 & h_fdsmp==2 & h_fdflr==2 &  h_fdrice==2 & h_fdpas==2 & h_fdbis==2
	replace meat=0 if h_fdrm==2 & h_fdrmc==2 &  h_fdchi==2 &  h_fdfsh==2 & h_fdfshc==2
	replace veggies=0 if h_fdvegd==2 & h_fdpot==2 & h_fdvego==2 &  h_fdfru==2
	replace fats=0 if h_fdoil==2 & h_fdmar==2 & h_fdpb==2 &  h_fdmlk==2 &  h_fdegg==2 &  h_fdsug==2 & h_fdsd==2 & h_fdfrut==2 & h_fdcer==2
	replace baby=0 if h_fdbaby==2
	replace eat_out=0 if h_fdrdy==2 & h_fdout==2
end	

program define house_data
	quietly use clean/l_v1, clear
	quietly merge 1:1 pid r using clean/i_v1
	drop _merge
	quietly merge m:1 hhid r using clean/h_v1
	drop _merge
	quietly merge m:1 hhid r using clean/hd_v1
	drop _merge
	quietly merge m:1 pid r using clean/c_v1
	drop _merge
	quietly merge 1:1 pid r using clean/a_v1
	drop _merge
end

program define balanced_panel
	quietly tab r, g(r_id)
	egen r1_id=max(r_id1), by(pid)
	egen r2_id=max(r_id2), by(pid)
	egen r3_id=max(r_id3), by(pid)
	keep if r1_id==1 & r2_id==1 & r3_id==1
end

program define rdp_variable_cleaned
	g rdp=.
	replace rdp=1 if h_sub==1 & (r==1 | r==3 | r==4 | r==5)
	replace rdp=1 if h_grnthse==1 & r==2
	replace rdp=0 if h_sub==2 & (r==1 | r==3 | r==4 | r==5)
	replace rdp=0 if h_grnthse==2 & r==2
end

program define move_variable_cleaned
	g move=stayer
	replace move=1 if stayer==0
	replace move=0 if stayer==1
	replace move=0 if stayer==.
end

program define house_variables
	g H_rooms=.
	replace H_rooms=h_dwlrms if h_dwlrms>0
	g H_own=.
	replace H_own=1 if h_ownd==1
	replace H_own=0 if h_ownd==2
	rename h_ownd H_ownd
	g H_qual=.
	replace H_qual=h_dwlrate if h_dwlrate>0
	g H_mktv=.
	replace H_mktv=h_mrkv if h_mrkv>0
	g H_type=.
	replace H_type=h_dwltyp if h_dwltyp>0
	g H_roof=.
	replace H_roof=h_dwlmatroof if h_dwlmatroof>0
	g H_wall=.
	replace H_wall=h_dwlmatrwll if h_dwlmatrwll>0
	rename h_watsrc H_water
	replace H_water=. if H_water<0
	rename h_toi H_toilet
	replace H_toilet=. if H_toilet<0
	rename h_toishr H_toilet_share
	replace H_toilet_share=. if  H_toilet_share<0
	rename h_ownpaid H_paid 
	replace H_paid=. if H_paid<0
	replace H_paid=0 if H_paid==2
	rename h_ownowd H_bondv
	replace H_bondv=. if H_bondv<0
	rename h_ownmn H_bond_pay
	replace H_bond_pay=. if H_bond_pay<0
	rename h_ownrnt H_rent_v
	replace H_rent_v=. if H_rent_v<0
	rename h_rnt H_rent_d
	replace H_rent_d=. if H_rent_d<0
	replace H_rent_d=0 if H_rent_d==2
	rename h_rntpay H_rent_pay
	replace H_rent_pay=. if H_rent_pay<0
	rename h_rntpot H_rent_will
	replace H_rent_will=. if H_rent_will<0 
	rename h_dwlmatflr H_floor
	replace H_floor=. if H_floor<0
	rename h_dwlrepr H_improve
	replace H_improve=. if H_improve<0
	replace H_improve=0 if H_improve==2
	rename h_dwlrepr_v H_improve_v
	replace H_improve_v=. if H_improve_v<0
*	h_ownoth h_ownoth_o h_ownoth1 h_ownoth2 h_ownoth3 h_ownoth4 h_mrkvoth h_ownothpaid h_ownowdtot
end

program define children_variables
	g C_c_ill=c_hlill30 if c_hlill30>0
	replace C_c_ill=0 if C_c_ill==2 
	g C_c_health=c_hlthdes if c_hlthdes>0
	g C_c_absent=c_edmssds if c_edmssds>0
	g C_c_failed=.
	rename c_hlser C_c_ill_ser
	replace C_c_ill_ser=. if C_c_ill_ser<0
	replace C_c_ill_ser=0 if C_c_ill_ser==2
	replace C_c_failed=0 if r==1 & (c_ed07res>0 & c_ed07res<=3)
	replace C_c_failed=1 if r==1 & c_ed07res==2
	replace C_c_failed=0 if r==2 & ((c_ed08res>0 & c_ed08res<=3) | (c_ed09res>0 & c_ed09res<=3))
	replace C_c_failed=1 if r==2 & (c_ed08res==2	 | c_ed09res==2)
	replace C_c_failed=0 if r==3 & ((c_ed10res>0 & c_ed10res<=3) | (c_ed11res>0 & c_ed11res<=3))
	replace C_c_failed=1 if r==3 & (c_ed10res==2	|  c_ed11res==2)
	replace C_c_failed=0 if r==4 & ((c_ed12res>0 & c_ed12res<=3) | (c_ed13res>0 & c_ed13res<=3) | (c_ed14res>0 & c_ed14res<=3))
	replace C_c_failed=1 if r==4 & (c_ed12res==2	|  c_ed13res==2 |  c_ed14res==2)
	replace C_c_failed=0 if r==5 & ((c_ed15res>0 & c_ed15res<=3) | (c_ed16res>0 & c_ed16res<=3) )
	replace C_c_failed=1 if r==5 & (c_ed15res==2	|  c_ed16res==2)


	rename a_bhlive_n A_cres
	rename a_bhali_n A_cnres
	replace A_cres=. if A_cres<=0
	replace A_cnres=. if A_cnres<=0
end

program define adult_variables
	g A_e=empl_stat
	replace A_e=0 if A_e==1 | A_e==2
	replace A_e=1 if A_e==3
	replace A_e=. if A_e<0
	g A_ue=empl_stat
	replace A_ue=1 if A_ue==1 | A_ue==2
	replace A_ue=0 if A_ue==3
	replace A_ue=. if A_ue<0
	g A_tb=a_hltb
	replace A_tb=. if A_tb<0
	replace A_tb=0 if A_tb==2
	foreach var in a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	replace `var'=0 if `var'==2
	replace `var'=. if `var'<0
	rename `var' A_`var'
	}
end

program define child_count_res
	forvalues r=1/16 {	
	g c`r'_resss=(a_bhali`r'==1 & a_bhlive`r'==1 & a_bhdob_y`r'>=1990 & a_bhdob_y`r'<2018)
	g c`r'_nresss=(a_bhali`r'==1 & a_bhlive`r'!=1 & a_bhdob_y`r'>=1990 & a_bhdob_y`r'<2018)
	g c`r'_ressy=(a_bhali`r'==1 & a_bhlive`r'==1 & a_bhdob_y`r'>=1998 & a_bhdob_y`r'<2018)
	g c`r'_nressy=(a_bhali`r'==1 & a_bhlive`r'!=1 & a_bhdob_y`r'>=1998 & a_bhdob_y`r'<2018)
	g c`r'_ressvy=(a_bhali`r'==1 & a_bhlive`r'==1 & a_bhdob_y`r'>=2001 & a_bhdob_y`r'<2018)
	g c`r'_nressvy=(a_bhali`r'==1 & a_bhlive`r'!=1 & a_bhdob_y`r'>=2001 & a_bhdob_y`r'<2018)
	}
	egen C_cr18=rowtotal(*_resss)
	egen C_cn18=rowtotal(*_nresss)
	egen C_cr10=rowtotal(*_ressy)
	egen C_cn10=rowtotal(*_nressy)
	egen C_cr7=rowtotal(*_ressvy)
	egen C_cn7=rowtotal(*_nressvy)
end

program define child_count
	use "clean/data_analysis/child_count", clear
	replace r_parhpid=. if r_parhpid<0 
	rename r_parhpid f_pid
	keep pid r a_bhchild_id* age_m f_pid
	forvalues r=1/16 {
	quietly replace a_bhchild_id`r'=. if a_bhchild_id`r'<100
	}
	save clean/data_analysis/p_c_link, replace
	use clean/data_analysis/p_c_link, clear
	keep if age_m<16
	keep pid r
	save clean/data_analysis/c_link, replace
	forvalues r=1/16 {
	quietly use "clean/data_analysis/p_c_link", clear
	rename pid m_pid`r'
	rename a_bhchild_id`r' pid
	quietly drop if pid==.
	keep pid m_pid`r' r f_pid
	quietly merge 1:1 pid r using c_link
	quietly drop if _merge==1
	quietly drop _merge
	quietly save "clean/data_analysis/c_link", replace
	}
	use clean/data_analysis/c_link, clear
	egen m_pid=rowfirst(m_pid*)
	keep pid m_pid r f_pid
	drop if m_pid==.
	save clean/data_analysis/c_link_final, replace
	use clean/data_analysis/child_count, clear
	merge 1:1 pid r using "clean/data_analysis/c_link_final"
	drop _merge
	egen m_pid1=max(m_pid), by(pid)
	egen f_pid1=max(f_pid) if f_pid>100, by(pid)
	save "clean/data_analysis/child_count_v1", replace
end

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
	egen max_h_ch_hhid=max(h_ch), by(hhid)
	egen max_h_ch_hhid_pid=max(max_h_ch_hhid), by(pid)
	drop if max_rdp==1 & max_h_ch<1 & max_h_ch_hhid_pid<1
end

program define construct_hh1
	g hhid1=hhid if r==1
	egen h1=max(hhid1), by(pid)
	* switch in round 2
	g Hch2=h_ch if r==2
	* household switches in round 2
	egen hchid2=max(Hch2), by(hhid)
	* hhid1 for household in round 2
	egen hhid2alt=max(h1), by(hhid)
	g hhid2=hhid if r==2
	g hhid3=hhid if r==3
	egen h2=max(hhid2), by(pid)
	* alternate hhid for pid
	egen h2alt=max(hhid2alt), by(pid)
	egen h3=max(hhid3), by(pid)
	* define hh1
	g hh1=h1
	replace hh1=h2alt if hh1==. & hchid2!=1 & r>=2
	replace hh1=h2 if hh1==.
	replace hh1=h3 if hh1==.
	* fix hh1
end


program define family_structure
	g adult_men_id=(a>18 & a<=60 & sex==1)
	g adult_women_id=(a>18 & a<=60 & sex==0)
	egen adult_men=sum(adult_men_id), by(hhid)
	egen adult_women=sum(adult_women_id), by(hhid)
	g old_men_id=(a>60 & sex==1 & a<.)
	g old_women_id=(a>60 & sex==0 & a<.)
	egen old_men=sum(old_men_id), by(hhid)
	egen old_women=sum(old_women_id), by(hhid)
	g old=old_men+old_women
	g child_id=(a<=18)
	egen child=sum(child_id), by(hhid)
	** ownership
	g owner=(h_ownpid1==pid | h_ownpid2==pid)
	replace own=0 if own==2
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
	g single_mother=(adult_women==1 & adult_men==0 & child>0)
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
	** movers
	egen max_move=max(move), by(pid)
	** father and mother resident
	g m_res=1 if c_mthhh==1
	replace m_res=0 if c_mthhh==2
	g f_res=1 if c_fthhh==1
	replace f_res=0 if c_fthhh==2
	** meatfat
	g meat_fat=meat+fat if meat!=. & fat!=.
	replace meat_fat=meat if meat_fat==. & meat!=.
	replace meat_fat=fat if meat_fat==. & fat!=.
	egen max_age=max(a), by(pid)
end


* main


* main_2
	



