
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"


program define main_tables
	quietly clean_data
	quietly first_stage
	quietly identification_test
	quietly main_spec
	quietly robustness
	quietly size_change_drivers
	quietly parent_present
	
end

program define size_change_drivers
	use clean/data_analysis/regs_nate_tables_3_3, clear	

	xi: reg ad_p7_ch h_ch h_ch_sl size_lag  i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n1, nonotes tex(frag) keep(h_ch   h_ch_sl  size_lag  ) label replace nocons title("Parents and Size Changes")
	xi: reg ad_np7_ch h_ch h_ch_sl size_lag  i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n1, nonotes tex(frag) keep(h_ch   h_ch_sl  size_lag  ) label append nocons title("Parents and Size Changes")
	xi: reg ad_p7_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n1, nonotes tex(frag) keep(h_ch   h_ch_sl  size_lag  ) label append nocons title("Parents and Size Changes") addnote("Age","Children under 7")
	xi: reg ad_np7_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n1, nonotes tex(frag) keep(h_ch   h_ch_sl  size_lag  ) label append nocons title("Parents and Size Changes") addnote("Age","Children under 7")
end


program define parent_present
	use clean/data_analysis/regs_nate_tables_3_3, clear	
	
		* parents present?
	xi: reg m_res_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=18, robust cluster(hh1)
	outreg2 using clean/tables/parent_present_n1, nonotes tex(frag)  keep(h_ch   h_ch_sl  size_lag  ) label replace nocons title("Parents Present?")

	xi: reg f_res_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=18, robust cluster(hh1)	
	outreg2 using clean/tables/parent_present_n1, nonotes tex(frag)  keep(h_ch   h_ch_sl  size_lag  ) label append nocons

		* parents present effect?
	xi: reg zw_ch i.h_ch*i.f_res i.f_res*h_ch_sl i.f_res*size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/parent_effect_n1, nonotes tex(frag) label replace nocons title("Effects Weaker with Parents?")


	
end

program define adult_effects
	use clean/data_analysis/regs_nate_tables_3_3, clear	
	
	xi: reg zw_ch i.h_ch*i.parent7 i.parent7*h_ch_sl i.parent7*size_lag a sex i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)

	xi: reg zw_ch i.h_ch*i.parent7 i.parent7*h_ch_sl i.parent7*size_lag a sex i.r if size_lag<=11 & a>18 & a<60 & sex==1, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.parent7 i.parent7*h_ch_sl i.parent7*size_lag a sex i.r if size_lag<=11 & a>18 & a<60 & sex==0, robust cluster(hh1)
	
	
	xi: reg zw_ch i.h_ch*i.parent18 i.parent18*h_ch_sl i.parent18*size_lag a sex i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)

	xi: reg zw_ch i.h_ch*i.parent18 i.parent18*h_ch_sl i.parent18*size_lag a sex i.r if size_lag<=11 & a>18 & a<60 & sex==1, robust cluster(hh1)
	xi: reg zw_ch i.h_ch*i.parent18 i.parent18*h_ch_sl i.parent18*size_lag a sex i.r if size_lag<=11 & a>18 & a<60 & sex==0, robust cluster(hh1)

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
	
	label variable h_ch "RDP"
	label variable size_lag "Size t-1"
	label variable h_ch_sl "RDPxSize t-1"
	label variable size_ch "Size Ch"
	label variable child_ch "Children Ch"
	label variable adult_ch "Adult Ch"
	
	label variable zw_ch "Weight Ch"
	
	label variable h_ch_at_7_18 "RDP 7-18" 
	label variable h_ch_at_60 "RDP over 18"
	label variable h_ch_sl_at_7_18 "RDPxSize t-1 for 7-18"
	label variable h_ch_sl_at_60 "RDPxSize t-1 for over 18"
	label variable at_7_18 "Age 7-18"
	label variable at_sl_7_18 "Size t-1 for 7-18"
	label variable at_60 "Age over 18"
	label variable at_sl_60 "Size t-1 for over 18"
	
end	
	
program define junk
		* * * ARE PARENTS MORE OR LESS LIKELY TO CORRESIDE? * * *

			* father does seem to correside more! (not significant but suggestive)
			
	
		* * * WEAKER EFFECT IF A PARENT IS RESIDENT?

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



		* driven by parents! ( fathers entering? ) 
end		
			
program define main_spec
	use clean/data_analysis/regs_nate_tables_3_3, clear	

	xi: reg zw_ch h_ch h_ch_at_7_18  h_ch_at_60  h_ch_sl h_ch_sl_at_7_18 h_ch_sl_at_60  size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_ch h_ch_at_7_18  h_ch_at_60  h_ch_sl h_ch_sl_at_7_18 h_ch_sl_at_60  size_lag  at_sl_7_18  at_sl_60) label replace nocons title("Main Specification")
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons title("Main Specification") addnote("Age", "Children under 7")
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a>7 & a<=18, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons title("Main Specification") addnote("Age", "Young Adults 7-18")
	xi: reg zw_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons title("Main Specification") addnote("Age", "Adults over 18")
end



program define first_stage
	use clean/data_analysis/regs_nate_tables_3_3, clear
	xi: reg size_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label replace nocons title("First Stage: Household Size")
	xi: reg child_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons title("First Stage: Household Size")
	xi: reg adult_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_n1, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons title("First Stage: Household Size")
end


program define identification_test
	use clean/data_analysis/regs_nate_tables_3_3, clear
	sort pid r
	by pid: g sl_2=size_lag[_n-1]
	by pid: g size_chl=size_ch[_n-1]
	label variable sl_2 "Size t-2"
	label variable size_chl "Size Ch t-1"		
	xi: reg h_ch size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/id_test_n1, nonotes tex(frag) keep(size_lag) label replace nocons title("Robustness")
	xi: reg h_ch sl_2 size_lag a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/id_test_n1, nonotes tex(frag) keep(size_lag sl_2) label append nocons
	xi: reg h_ch size_chl a sex i.r if size_lag<=11, robust cluster(hh1)
	outreg2 using clean/tables/id_test_n1, nonotes tex(frag) keep(size_chl) label append nocons
end




program define clean_data
	
	use clean/data_analysis/house_treat_regs_anna_tables, clear
	
	********************************
	**** NEED TO GENERATE TYPES ****
	********************************
	g oid=((pid==h_ownpid1 | pid==h_ownpid2 | pid==h_ownpid3) & pid!=.)
	g oid1=(pid==h_ownpid1 & pid!=.)
	
	egen oidhh=max(oid), by(hh1 hhid)
	egen oidhh1=max(oid1), by(hh1 hhid)
	
	tab oidhh oidhh1 if h_ch==1
	
	g h_chi=h_ch
	replace h_chi=0 if oidhh==0
	g h_chn=h_ch
	replace h_chn=0 if oidhh==1
	
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

	g at_7_18=(a>7 & a<=18)
	g at_60=(a>18)	
	g at_sl_7_18=at_7_18*size_lag
	g at_sl_60=at_60*size_lag
	foreach v in h_ch h_chi h_chn {
	g `v'_sl=`v'*size_lag
	g `v'_at_7_18=`v'*at_7_18
	g `v'_sl_at_7_18=`v'*at_7_18*size_lag
	g `v'_at_60=h_ch*at_60
	g `v'_sl_at_60=h_ch*at_60*size_lag
	}

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
	

program define working
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
	xi: reg zw_ch h_ch h_ch_at_* h_ch_sl h_ch_sl_at*  at_* size_lag i.a*zw_lag sex  i.r if size_lag<=11 & a<50, robust cluster(hh1)

	* * * super robust!
	
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
	log using results
	
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


	xi: reg exp1_ln_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg exp1_ln_a_ch h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	xi: reg exp1_ln_p_ch  h_ch h_ch_sl size_lag a sex i.r if size_lag<=11 & a<60, robust cluster(hh1)

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
	
	log close
end

main_tables
