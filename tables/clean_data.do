
	use clean/data_analysis/house_treat_regs_inc_exp, clear

	g exp1=food
	replace exp1=food+non_food if non_food!=.
	replace exp1=non_food if exp1==.
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
*	foreach var of varlist  pi_hhincome pi_hhwage pi_hhgovt pi_hhremitt non_labor {
*	replace `var'=0 if `var'==.
*	}
	* fix rent variable
	replace rent_pay=0 if rent_d==1 & rent_pay==.
	sort pid r
	by pid: g rent_d_lag=rent_d[_n-1]
	replace rent_pay=0 if rent_d_lag==1 & rent_pay==.
	replace health_exp=0 if health_exp==.
	replace sch_spending=0 if sch_spending==.
	
	replace  pi_hhwage=0 if  pi_hhwage==.
	replace  pi_hhremitt=0 if pi_hhremitt==.
	replace  pi_hhwage=. if pi_hhincome==.
	replace  pi_hhremitt=. if pi_hhincome==.
	
	g non_food_1=non_food
	replace non_food_1=non_food+public if public!=.
	replace non_food_1=public if non_food_1==. & public!=.
	
	foreach var of varlist non_food_1 food exp1 exp_n pi_hhincome pi_hhwage {
	quietly sum `var', detail
	replace `var'=. if `var'>r(p95)
	}
	replace non_food_1=0 if non_food_1==. & exp1!=.
	replace food=0 if food==. & exp1!=.
	
*	replace rent_pay=0 if rent_pay==.
*	replace kid_exp=0 if kid_exp==. | exp_n!=.
*	replace adult_exp=0 if adult_exp==. | exp_n!=.
*	replace food=0 if food==. | adult_exp==.
	
	foreach var of varlist non_food_1 exp_n kid_exp adult_exp  rent_pay h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
	quietly	g `var'_ln=ln(`var'+1)
	quietly g `var'_lnp=ln((`var'/size)+1)
	quietly g `var'_p=`var'/size
	quietly g `var'_e=`var'/exp1
	replace `var'_e=. if `var'==0 | ex==0
	quietly sort pid r
	quietly by pid: g `var'_ch1=`var'[_n]-`var'[_n-1]
	quietly by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	quietly by pid: g `var'_ln_p_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	quietly by pid: g `var'_e_ch=`var'_e[_n]-`var'_e[_n-1]
	quietly by pid: g `var'_p_ch=`var'_p[_n]-`var'_p[_n-1]
	}
	save clean/data_analysis/house_treat_regs_anna_tables, replace
	
	*^*^*^^*^*^*^**^*^*^*^*^*^*^*^**^*^*^*^*
				*^(^(^(^(^(^(^(^(^(^(^(^((^(^(^(^(^(^(^(^((^(^(^(
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
	egen minimum_a=min(a), by(pid)
	g adult_id_inc=(minimum_a>20)
	egen adult_inc=sum(adult_id_inc), by(hhid)
	g inc_ad=pi_hhincome/adult_inc
	egen im=max(inc_ad), by(pid)
	
	* Full residence id
	duplicates tag hhid hh1, g(dup)
	replace dup=dup+1
	g dupr=dup/size
	egen mD=max(dupr), by(hhid)
	
	egen max_oidhh=max(oid), by(hhid) 
	
	g h_chi=h_ch
	replace h_chi=0 if (oidhh==0 & mD<.9 & max_oidhh==1)
	g h_chn=h_ch
	replace h_chn=0 if (oidhh==1 | (mD>.7 & mD<.))
	* move variables and key h_ch cleaning	
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	sort pid r
	tab h_ch
*	foreach var of varlist h_chi h_chn h_ch {
*	by pid: g `var'r=`var'[_n]-`var'[_n-1]
*	replace `var'=. if `var'r==-1
*	replace `var'=. if r==1
*	}
	* M_CH FIXING
	replace m_ch=. if r==1
	* H_CH FIXING 
*	replace h_ch=. if h_chn==1
	sort pid r
	by pid: g nochl=noch[_n-1]	
	
	replace m_res=1 if c_mthhh_pid>0 & c_mthhh_pid<. & m_res==.
	replace m_res=0 if c_mthhh_pid==77
	replace f_res=1 if c_fthhh_pid>0 & c_fthhh_pid<. & f_res==.
	replace f_res=0 if c_fthhh_pid==77
	
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
	by pid: g rent_pay_ch=rent_pay[_n]-rent_pay[_n-1]
	egen hclust=sum(h_chi), by(cluster)
	
	g ele=1 if h_nfelespn>0 & h_nfelespn<.
	replace ele=0 if h_nfelespn==0
	g wat=1 if h_nfwatspn>0 & h_nfwatspn<.
	replace wat=0 if h_nfwatspn==0
	
	sort pid r
	foreach var of varlist ele wat c_ill c_health {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
		* adult illness
	sort pid r
	foreach var of varlist a_cr* a_cg* a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}		
	sort pid r
	replace c_waist_1=. if c_waist_1<0
	by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]	
	by pid: g zwfh_ch=zwfh[_n]-zwfa[_n-1]	
	by pid: g zwfh_lag=zwfa[_n-1]
	sort pid r
	foreach var of varlist zwfa zhfa zbmi zwfh c_absent c_failed c_health c_ill {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}

	* new variables : 3 / 26 / 15

	forvalues r=1(1)15 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	

	foreach z in adult child {
	forvalues r=1(1)10 {
	g `z'H_`r'=h_ch
	replace `z'H_`r'=0 if `z'_lag!=`r' & h_ch!=.
	g `z'mm_`r'=m_ch
	replace `z'mm_`r'=0 if  `z'_lag!=`r' & m_ch!=.	
	g `z'sl_`r'=(`z'_lag==`r')
	}	
	}
	
	*#####################*
	* KEY THIS IS WHERE LARGE IS GENERATED *
	*#####################*
	g small=size_lag<=6
	g large=size_lag>6
	foreach v in  h_ch m_ch {
	g `v'_small=`v'
	replace `v'_small=0 if size_lag>6 & `v'!=.
	g `v'_large=`v'
	replace `v'_large=0 if size_lag<=6 & `v'!=.
	}
	
	replace rooms=. if rooms>10
	g crowd=size/rooms
	replace crowd=. if crowd>5
	sort pid r
	by pid: g crowd_ch=crowd[_n]-crowd[_n-1]
	by pid: g crowd_lag=crowd[_n-1]
	g h_ch_crowd=crowd_lag*h_ch
	g m_ch_crowd=crowd_lag*m_ch

	g h_ch_sl=h_ch*size_lag

	g C_1=0 if crowd_lag!=.
	replace C_1=1 if crowd_lag>0 & crowd_lag<=1
	g C_2=0 if crowd_lag!=.
	replace C_2=1 if crowd_lag>1 & crowd_lag<=2
	g C_3=0 if crowd_lag!=.
	replace C_3=1 if crowd_lag>2 & crowd_lag<.
	
	forvalues r=1(1)3 {
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
	
	forvalues r=1(1)4 {
	g R_`r'=0 if rooms_lag!=.
	replace R_`r'=1 if rooms_lag==`r'
	g RH_`r'=h_ch
	replace RH_`r'=0 if R_`r'!=1 & h_ch!=.
	g RM_`r'=m_ch
	replace RM_`r'=0 if R_`r'!=1 & m_ch!=.
	}
	g R_5=0 if rooms_lag!=.
	replace R_5=1 if rooms_lag>4 & rooms_lag<.
	g RH_5=h_ch
	replace RH_5=0 if R_5!=1 & h_ch!=.
	g RM_5=m_ch
	replace RM_5=0 if R_5!=1 & m_ch!=.
	
	* extra stuff
	egen min_a=min(a), by(pid)
	g ct_id=(min_a<=16)
	egen ct=sum(ct_id), by(hhid)
	g ad_id=(min_a>16 & min_a<=60)
	egen ad=sum(ad_id), by(hhid)
	g o_id=(min_a>60)
	egen o=sum(o_id), by(hhid)
	foreach var of varlist ct ad o {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}	
	
	* key variable construction	
	
	g HH=0 if h_ch!=.
	forvalues r=10(1)15 {
	replace HH=1 if H_`r'==1
	}	
	g hh_sl=(size_lag>=10 & size_lag<16)
	g hh_mm=m_ch
	replace hh_mm=0 if size_lag>=10 & size_lag<16
	
	g HA=0 if h_ch!=.
	forvalues r=12(1)15 {
	replace HA=1 if H_`r'==1
	}	
	g ha_sl=(size_lag>=12 & size_lag<16)
	g ha_mm=m_ch
	replace ha_mm=0 if size_lag>=12 & size_lag<16

	* neighborhood quality
	g refuse=h_refrem if h_refrem>0
	replace refuse=0 if refuse==2
	g light=h_strlght if h_strlght>0
	replace light=0 if light==3
	
	foreach var of varlist  refuse light n_burial n_trust n_trust_str n_stay  a_weight_1 a_weight_2 a_weight_3 h_nbhlp h_nbtog h_nbagg h_nbthf h_nbthmf h_freqdomvio h_freqvio h_freqgang h_freqmdr h_freqdrug a_emobth a_emomnd a_emodep a_emoeff a_emohope a_emofear a_emoslp a_emohap a_emolone a_emogo {
*	tab `var' r, nolabel
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	egen avg_e=mean(e), by(hhid)
	sort pid r
	by pid: g avg_e_lag=avg_e[_n-1]
	by pid: g avg_e_ch=avg_e[_n]-avg_e[_n-1]	
	
	drop h_chL
	g h_chL=(h_chr==-1)
	
	sort pid r
	by pid: g h_chS=(h_ch[_n-1]==1)

		* KEY LAST CHUNK OF CLEANING
	drop if rdp_r1m==1
	drop if h_chL==1
	
	g rl=r*large
	g rl1=r*10+rl
	
	sort pid r
	by pid: g large_lag=large[_n-1]
	
	* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ THIS IS NEW
	g h_chS_large=h_chS*large_lag
	g h_chML_large=h_chML*large

	foreach var of varlist h_chS h_chML {
	g `var'_LARGE=`var'*large
	}	
	
	* more new stuff 4/23/15
	g inf=(h_dwltyp>=7 & h_dwltyp<=8)
	
	sort pid r
	by pid: g inf_ch=inf[_n]-inf[_n-1]
	by pid: g lo2=(lo[_n-1]==1)	
	replace lo=0 if lo2==1
	g lo_large=lo*large
	g lo2_large=lo2*large
	
	la var h_chS "RDP t-1"
	la var h_chS_large "RDP t-1xLarge"
	la var h_chML "RDP r1"
	la var h_chML_large "RDP r1xLarge"
	la var lo "Left Out"
	la var lo_large "Left OutxLarge"
	la var lo2 "Left Out t-1"
	la var lo2_large "Left Out t-1xLarge"
	
	
	save clean/data_analysis/regs_nate_tables_3_6, replace



cap prog drop label_variables
program define label_variables

	lab var avg_e_lag "Avg Emp t-1"
	lab var avg_e_ch "Avg Emp Ch"

	* labels!
	lab var h_freqdomvio_ch "Domestic Vio Ch"
	lab var h_freqvio_ch "Violence Ch"
	lab var h_freqgang_ch "Gang Ch"
	lab var h_freqmdr_ch "Murder Ch"
	lab var h_freqdrug_ch "Drug Ch"
	
	la var refuse_ch "Refuse Ch"
	
	* extra labels
	foreach v in 1 2 3 4 5 6 7 8 9 10 11 {
	lab var H_`v' "S `v'"
	}
	
	lab var small "Small"
	lab var large "Large"
	lab var h_ch_small "RDPxSmall"
	lab var h_ch_large "RDPxLarge"
	
	lab var ct_ch "Child Ch"
	lab var ad_ch "Adult Ch"
	
	lab var a_cr_ch "Receive"
	lab var a_cg_ch "Send"

	* Crowd Variable
	lab var crowd "Crowd"
	lab var crowd_ch "Crowd Ch"
	lab var crowd_lag "Crowd t-1"
	lab var h_ch_crowd "RDPxCrowd t-1"
	
	* Non-Parametric Labels
*	lab var CH_1 "C 1"
*	lab var CH_2 "C 2"
*	lab var CH_3 "C 3"
*	lab var CH_4 "C 4"
*	lab var CH_5 "C 5"

	* Treatment Variables
	label variable h_ch "RDP"
	label variable h_ch_sl "RDPxSize t-1"
	label variable size_lag "Size t-1"
	label variable m_ch "Move Location"
	label variable m_ch_sl "Move xSize t-1"
	
	* Change Variables
	label variable size_ch "Size Ch"
	label variable child_ch "Children Ch"
	label variable adult_ch "Adult Ch"
	
	label variable zwfa_ch "Weight Ch"
	label variable zhfa_ch "Height Ch"
	label variable zbmi_ch "BMI Ch"
	label variable c_ill_ch "Ill Ch"
	label variable c_health_ch "Health Ch"

	label variable wath_ch "Piped Water Ch"
	label variable toih_ch "Flush Toilet Ch"	
*	label variable flush_ch "Flush Toilet Ch"
*	label variable piped_ch "Piped Water Ch"
	label variable walls_b_ch "Brick Walls Ch"
	
	* Income Variables
*	label variable pi_hhincome_ln "Inc Ln"
*	label variable pi_hhincome_ln_ch "Inc Ch"
*	label variable pi_hhincome_ln_p_ch "Inc Ch Per"
*	label variable pi_hhincome_p_ch "Inc Ch Per"
*	label variable pi_hhwage_ln "Wage Ln"
*	label variable pi_hhwage_ln_ch "Wage Ch"
*	label variable pi_hhwage_ln_p_ch "Wage Ch Per"
*	label variable pi_hhwage_p_ch "Wage Ch Per"
*	label variable pi_hhgovt_ln "Govt Ln"
*	label variable pi_hhgovt_ln_ch "Govt Ch"
*	label variable pi_hhgovt_ln_p_ch "Govt Ch Per"
*	label variable pi_hhgovt_p_ch "Govt Ch Per"
*	label variable pi_hhremitt_ln "Remit Ln"
*	label variable pi_hhremitt_ln_ch "Remit Ch"
*	label variable pi_hhremitt_ln_p_ch "Remit Ch Per"
*	label variable pi_hhremitt_p_ch "Remit Ch Per"

	label variable pi_hhincome_ch1 "Inc"	
	label variable pi_hhincome_ln "Inc Ln"
	label variable pi_hhincome_ln_ch "Inc Ln"
	label variable pi_hhincome_ln_p_ch "Inc Per"
	label variable pi_hhincome_p_ch "Inc Per"
	label variable pi_hhwage_ch1 "Wage"
	label variable pi_hhwage_ln "Wage Ln"
	label variable pi_hhwage_ln_ch "Wage"
	label variable pi_hhwage_ln_p_ch "Wage Per"
	label variable pi_hhwage_p_ch "Wage Per"
	label variable pi_hhgovt_ln "Govt Ln"
	label variable pi_hhgovt_ln_ch "Govt"
	label variable pi_hhgovt_ln_p_ch "Govt Per"
	label variable pi_hhgovt_p_ch "Govt Per"
	
	label variable pi_hhremitt_ch1 "Remit"
	label variable pi_hhremitt_ln "Remit Ln"
	label variable pi_hhremitt_ln_ch "Remit"
	label variable pi_hhremitt_ln_p_ch "Remit Per"
	label variable pi_hhremitt_p_ch "Remit Per"
	
	*Expenditure Variables

	label variable exp1_ch "Exp"
	label variable exp1_ln_ch "Exp"
	label variable exp1_ln_p_ch "Exp Per"	
	label variable exp1_p_ch "Exp Per"
	label variable food_ch "Food"
	label variable food_ln_ch "Food"
	label variable food_ln_p_ch "Food Per"
	label variable food_p_ch "Food Per"
*	label variable h_fdtot_ln_ch "Food"
*	label variable h_fdtot_ln_p_ch "Food Per"
	label variable public_ch "Public"
	label variable public_ln_ch "Public"
	label variable public_ln_p_ch "Public Per"
	label variable public_p_ch "Public Per"
	label variable non_food_ch "Non-Food"
	label variable non_food_ln_ch "Non-Food"
	label variable non_food_ln_p_ch "Non-Food Per"
	label variable non_food_p_ch "Non-Food Per"
	
	* Structure variables
	label variable size "Household Size"
	label variable child "Children"
	label variable adult_men "Adult Men"
	label variable adult_women "Adult Women"
	label variable old "Elderly"
	* HoH
	* Outcomes
	label variable zhfa "Height"
	label variable zwfa "Weight"
	label variable zbmi "BMI"
	label variable c_ill "Child ill for 3 days in last month"
	* Inc/Expenditure
	label variable inc "Income"
	label variable exp_imp "Household Exp (imp)"
	label variable ceremony "Ceremony Exp"
	label variable vice "Vice Exp"
	label variable sch_spending "School Exp"
	label variable health_exp "Health Exp"
	label variable inc "Income"
	label variable home_prod "Home Production Exp"
	label variable food "Food Exp"
	* Housing Variables
	label define rdpp 0 "Unsubsidized Housing" 1 "Subsidized (RDP) Housing"
	label values rdp rdpp
	label variable rdp "RDP"
	label variable rooms "Rooms"
	label variable rooms_lag "Rooms in t-1"
	label variable mktv "Market Value"
	label variable qual "House Quality"
	label variable roof_cor "Corrugated Roof"
	label variable walls_b "Brick Walls"
	label variable toilet_share "Share Toilet"
	label variable toih "Flush Toilet"
	label variable wath "Piped Water"
*	label variable flush "Flush Toilet"
*	label variable piped "Piped Water"
	* School Outcomes
	label variable c_absent "Days Absent"
	label variable c_failed "Failed Grade"
	* Additional Labels
	label variable ex "Total Expenditure"
	label variable adult "Adults"
	label variable c_health "Child Health (1 Sick-5 Healthy)"
end



