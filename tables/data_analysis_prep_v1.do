

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	* quietly house_data
	use clean/data_v1.dta, clear
	quietly rdp_variable_cleaned
	quietly move_variable_cleaned
	quietly house_variables
	quietly demographic_variables
	quietly children_variables
	quietly adult_variables
	quietly expenditure_income
	quietly make_food_measures
	quietly prov_fix
	drop if rdp==.
	egen age_m=max(D_a), by(pid)
	replace own=0 if own==2
	save clean/data_analysis/child_count, replace
	quietly child_count
	use clean/data_analysis/child_count_v1, clear
	keep pid hhid r rdp prov move A_* H_* C_* D_* E_* hhgeo2011 hhgeo2001 zhfa zwfa zbmi zwfh r_relhead h_ownpid1 h_ownpid2 f_pid1 m_pid m_pid1 csm r_pres r_absexp best_race fwag cwag swag fwag_flg cwag_flg swag_flg hhmdbdc2011 gc_dc2011 gc_mdbdc2011 hhdc2011 hhdc2001  gc_dc2001 a_weight* a_height* dis chld fost care dis_flg chld_flg fost_flg care_flg cdep cdep_flg hhgovt pi_hhgovt h_dwltyp h_fdtot c_weight_1 c_weight_2 c_weight_3 c_height_1 c_height_2 c_height_3 c_waist_1 c_waist_2 carbs meat veggies fats baby eat_out c_mthhh c_fthhh c_mthhh_pid c_fthhh_pid	
	quietly renpfix H_
	quietly renpfix C_
	quietly renpfix D_
	quietly renpfix E_
	quietly renpfix A_
* *	quietly balanced_panel
	save clean/data_analysis/house_treat, replace
end

program define prov_fix
	rename hhprov2011 prov
	replace prov=gc_prov2011 if prov==.
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
	replace rdp=1 if h_sub==1 & (r==1 | r==3)
	replace rdp=1 if h_grnthse==1 & r==2
	replace rdp=0 if h_sub==2 & (r==1 | r==3)
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
	replace H_own=2 if h_ownd==2
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
end

program define children_variables
	g C_c_ill=c_hlill30 if c_hlill30>0
	replace C_c_ill=0 if C_c_ill==2 
	g C_c_health=c_hlthdes if c_hlthdes>0
	g C_c_absent=c_edmssds if c_edmssds>0
	g C_c_failed=.
	replace C_c_failed=0 if r==1 & (c_ed07res>0 & c_ed07res<=3)
	replace C_c_failed=1 if r==1 & c_ed07res==2
	replace C_c_failed=0 if r==2 & (c_ed08res>0 & c_ed08res<=3)
	replace C_c_failed=1 if r==2 & c_ed08res==2	
	replace C_c_failed=0 if r==2 & (c_ed09res>0 & c_ed09res<=3)
	replace C_c_failed=1 if r==2 & c_ed09res==2
	replace C_c_failed=0 if r==3 & (c_ed10res>0 & c_ed10res<=3)
	replace C_c_failed=1 if r==3 & c_ed10res==2	
	replace C_c_failed=0 if r==3 & (c_ed11res>0 & c_ed11res<=3)
	replace C_c_failed=1 if r==3 & c_ed11res==2
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

program define expenditure_income
	foreach var of varlist  h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn  h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn h_nfalcspn h_nfcigspn h_nfcerspn h_nffrnspn h_nfdwlspn h_nfkitspn {
	replace `var'=0 if `var'<=0 | `var'==.
	}
	foreach var of varlist h_nfbedspnyr h_nfmatspnyr h_nfhspspnyr h_nfdocspnyr h_nftradspnyr h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr h_nfcerspnyr h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr {
	replace `var'=0 if `var'<=0 | `var'==.
	replace `var'=`var'/12
	} 
	egen E_vice=rowtotal(h_nfalcspn h_nfcigspn)
	egen E_ceremony=rowtotal(h_nfcerspnyr  h_nfcerspn )
	egen E_home_prod=rowtotal(h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr h_nffrnspn h_nfdwlspn h_nfkitspn)	
	egen E_sch_spending=rowtotal( h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn )
	egen E_health_exp=rowtotal( h_nfhspspnyr h_nfdocspnyr h_nftradspnyr h_nfhomspn h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn )
	egen E_non_food_other=rowtotal ( h_nfbedspnyr h_nfmatspnyr h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn )
	egen E_public_other=rowtotal (h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn)
	g E_non_food = E_health_exp + E_sch_spending + E_vice + E_non_food_other
	g E_public = E_home_prod + E_ceremony + E_public_other
	g E_food = h_fdtot if h_fdtot>=0
	g E_food_imp = expf 
	g E_non_food_imp = expnf 
	g E_exp_imp = expenditure
	g E_exp = exprough
	g E_inc = pi_hhincome if pi_hhincome>=0
	g E_inc_l = pi_hhwage if pi_hhwage>=0
	g E_inc_r = pi_hhremitt if pi_hhremitt>=0
	egen E_services= rowtotal ( h_nfwatspn h_nfelespn h_nfmunspn h_nflevspn )
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

program define child_count
	use clean/data_analysis/child_count, clear
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
	quietly use clean/data_analysis/p_c_link, clear
	rename pid m_pid`r'
	rename a_bhchild_id`r' pid
	quietly drop if pid==.
	keep pid m_pid`r' r f_pid
	quietly merge 1:1 pid r using c_link
	quietly drop if _merge==1
	quietly drop _merge
	quietly save clean/data_analysis/c_link, replace
	}
	use clean/data_analysis/c_link, clear
	egen m_pid=rowfirst(m_pid*)
	keep pid m_pid r f_pid
	drop if m_pid==.
	save clean/data_analysis/c_link_final, replace
	use clean/data_analysis/child_count, clear
	quietly merge 1:1 pid r using clean/data_analysis/c_link_final
	drop _merge
	egen m_pid1=max(m_pid), by(pid)
	egen f_pid1=max(f_pid) if f_pid>100, by(pid)
	save clean/data_analysis/child_count_v1, replace
end
*program define 

	
main


	
	



