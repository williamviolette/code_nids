

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"




program define first_stage
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables
		* take a1 down to 40! *
	global a1 "10"
	global s "10"
	global im "5000"
	
	egen min_a=min(a), by(pid)
	
	g nb_id=(min_a>=2)
	egen size1=sum(nb_id), by(hhid)
	replace size1=. if size1==0
	
  	rename size_lag size_lag_old
  	rename size_ch size_ch_old
	sort pid r
	by pid: g size_lag=size1[_n-1]
	by pid: g size_ch=size1[_n]-size1[_n-1]
	
	forvalues r=1/11 {
	g hi_`r'=h_chi
	replace hi_`r'=0 if size_lag!=`r' & h_chi!=.
	g hn_`r'=h_chn
	replace hn_`r'=0 if size_lag!=`r' & h_chn!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if size_lag!=`r' & m_ch!=.
	}
	quietly tab size_lag, g(sl_)
	
	xi: reg size_ch hi_*  hn_* mm_* sl_*  i.r if im<=$im & a<$a1 & size_lag<$s & size_lag>1 & hclust>=5, robust cluster(hh1)
	coefplot, vertical keep(hi_*)


	coefplot, vertical keep(hi_* sl_*)
	
	
		
*	collapse (max)  size_ch hi_*  hn_* mm_* sl_* im size_lag, by(hhid r)
*	xi: reg size_ch hi_*  hn_* mm_* sl_*  i.r if im<=$im & size_lag<$s & size_lag>1, robust
*	coefplot, vertical keep(hi_* hn_*)	

	xi: reg child_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg adult_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)

end





program define reduced_form
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "5000"

	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g hi_`r'=h_chi
	replace hi_`r'=0 if size_lag!=`r' & h_chi!=.
	g hn_`r'=h_chn
	replace hn_`r'=0 if size_lag!=`r' & h_chn!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	g small=size_lag<=5
	g large=size_lag>5
	foreach v in  h_ch {
	g `v'_small=`v'
	replace `v'_small=0 if size_lag>5 & `v'!=.
	g `v'_large=`v'
	replace `v'_large=0 if size_lag<=5 & `v'!=.
	}

	xi: reg zhfa_ch *_small *_large small size_lag a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<3 & zhfa_ch>-3 & size_lag>2, robust cluster(hh1)	
	xi: reg zwfa_ch *_small *_large small size_lag a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<3 & zwfa_ch>-3 & size_lag>2, robust cluster(hh1)	

	xi: reg size_ch *_small *_large i.size_lag a sex i.r if  hclust>=5 & im<=$im & a<20 & size_lag<$s & size_lag>2, robust cluster(hh1)	
		
			* why do kids in small houses do worse?
	
	xi: reg size_ch H_* sl_*  i.r if im<=$im & a<50 & size_lag<$s & size_lag>1 & hclust>=5, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2.5 & zhfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)

	xi: reg zwfa_ch H_* sl_* mm_* a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)

	xi: reg c_health_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2 & c_health_ch>-4 & c_health_ch<4, robust cluster(hh1)	
	coefplot, vertical keep (H_*)

	xi: reg c_ill_ch H_* sl_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)


	xi: reg zhfa_ch hi_* hn_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2.5 & zhfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (hi_*)

	xi: reg zhfa_ch hi_* hn_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2.5 & zhfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (hi_*)

	xi: reg zwfa_ch hi_* hn_* sl_* mm_* a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (hi_*)

	xi: reg c_ill_ch hi_* hn_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (hi_*)

	xi: reg c_health_ch hi_* hn_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2 & c_health_ch>-4 & c_health_ch<4, robust cluster(hh1)	
	coefplot, vertical keep (hi_*)
	



program define who_is_left_behind
	
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "11"
	global im "5000"
	* calculate no-change again 
	foreach v in h_chi h_chn {
	forvalues r=2/3 {
	g `v'_`r'=`v' if r==`r'
	egen `v'_pid_`r'=max(`v'_`r'), by(pid)
	egen `v'_hh_`r'=max(`v'_pid_`r'), by(hhid)
	}
	}

	g li=((h_chi_hh_2==1 & r==1 & h_chi_pid_2!=1) | (h_chi_hh_3==1 & r==2 & h_chi_pid_3==0 & h_chi_hh_2!=1))

	g ln=((h_chn_hh_2==1 & r==1 & h_chn_pid_2!=1) | (h_chn_hh_3==1 & r==2 & h_chn_pid_3==0 & h_chn_hh_2!=1))

	hist a if (h_chi_hh_2==1 | h_chi_hh_3==1) & a<70, by(li)
	hist a if (h_chn_hh_2==1 | h_chn_hh_3==1) & a<70, by(li)
	
	
	
	hist a if (h_chi_hh_2==1 | h_chi_hh_3==1) & a<60 & r==1, by(li)
	hist a if (h_chi_hh_2==1 | h_chi_hh_3==1) & a<60 & r==2, by(li)

	hist a if (h_chn_hh_2==1 | h_chn_hh_3==1) & a<60 & r==1, by(ln)
	hist a if (h_chn_hh_2==1 | h_chn_hh_3==1) & a<60 & r==2, by(ln)

	hist a if (h_chn_hh_3==1) & a<60 & r==2, by(li)
	tab a li if (h_chn_hh_3==1) & a<60 & r==2
	
	hist a, by(ln)
	
	tab h_ch_hh_3 if a<4
	
	* also reorganization of the family?
		

	** ** WHO IS LEFT BEHIND? ** **
			* sicker kids? 
	
	
	
end	

	
* I NEED CLEARER MECHANISMS! 	
	
	
	
	
	xi: reg zhfa_ch h_ch a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chn a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_ch a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chn a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)

		* baseline piped water?
	xi: reg zhfa_ch h_ch h_ch_wath wath_lag a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation_wat, nonotes tex(frag) keep(h_ch) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chn a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation_wat, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_ch a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation_wat, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chn a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_motivation_wat, nonotes tex(frag) keep(h_chi h_chn) sortvar(h_ch h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)


*	xi: reg zbmi_ch h_ch a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_ch) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg zbmi_ch h_chi h_chn a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_motivation, nonotes tex(frag) keep(h_chi h_chn) label append nocons  addtext(Treated Area, Over 5)

	xi: reg zhfa_ch h_ch h_ch_sl size_lag a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_ch h_ch_sl size_lag a sex i.r zhfa_p*  if  hclust>=10 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 10)
	xi: reg zwfa_ch h_ch h_ch_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_ch h_ch_sl size_lag  a sex i.r zwfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 10)

*	xi: reg zbmi_ch h_ch h_ch_sl size_lag  a sex i.r zbmi_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
		
	* with and without lags	
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Outcome Lag, YES)
*	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Outcome Lag, NO)
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Outcome Lag, YES)
*	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Outcome Lag, NO)

	* cluster  5 or 10 treated area
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label replace nocons  addtext(Treated Area, Over 5)
	xi: reg zhfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r zhfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 10)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=5 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 5)
	xi: reg zwfa_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zwfa_p*  if hclust>=10 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 10)

	** GENERAL HEALTH INDICATORS DONT MOVE AT ALL **
	
*	xi: reg c_health_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r  if hclust>=1 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl ) label append nocons  addtext(Treated Area, Over 5)
*	xi: reg c_ill_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r   if hclust>=1 &  im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl  ) label append nocons  addtext(Treated Area, Over 10)

*	xi: reg zbmi_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  a sex i.r zbmi_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s, robust cluster(hh1)	
*	outreg2 using clean/tables/reduced_form_oj, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag ) label append nocons  addtext(Treated Area, Over 5)
	
end




program define non_resident_children
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	label_variables
	global a1 "50"
	global s "11"
	global im "5000"
	
	sort pid r
	foreach var of varlist cres cnres cr7 cn7 cr10 cn10 cr18 cn18 p_hoh g_hoh {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	label variable cnres_ch "Non-Res Children Ch"
	label variable cres_ch "Res Children Ch"
	label variable p_hoh_ch "Parent HoH Ch"
	
	g p_mis=(r_relhead==.)
	egen pmid=max(p_mis), by(pid)
*	xi: reg cnres_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s
*	xi: reg cres_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s
	
	xi: reg cres_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s, cluster(hh1) robust
	outreg2 using clean/tables/non_resident_children, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label replace nocons
	
	xi: reg cnres_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<$a1 & size_lag<$s, cluster(hh1) robust
	outreg2 using clean/tables/non_resident_children, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons
	
	xi: reg p_hoh_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<20 & size_lag<$s & pmid==0, cluster(hh1) robust
	outreg2 using clean/tables/non_resident_children, nonotes tex(frag) keep(h_chi h_chi_sl h_chn h_chn_sl size_lag) label append nocons  addtext(Age, Under 20)
		
*	xi: reg g_hoh_ch h_chi h_chi_sl h_chn h_chn_sl size_lag  i.r if im<=$im & a<20 & size_lag<$s & pmid==0, cluster(hh1) robust
	
		
end




program define label_variables
	* Treatment Variables
	label variable h_ch "RDP"
	label variable h_ch_sl "RDPxSize t-1"
	label variable h_chi "RDP Own"
	label variable h_chi_sl "RDP OwnxSize t-1"
	label variable h_chn "RDP Join"
	label variable h_chn_sl "RDP JoinxSize t-1"	
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



program define clean_data1
	use clean/data_analysis/house_treat_regs_inc_exp, clear

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
	* fix rent variable
	replace rent_pay=0 if rent_d==1 & rent_pay==.
	sort pid r
	by pid: g rent_d_lag=rent_d[_n-1]
	replace rent_pay=0 if rent_d_lag==1 & rent_pay==.
	replace health_exp=0 if health_exp==.
	replace sch_spending=0 if sch_spending==.
	foreach var of varlist rent_pay h_nfwatspn h_nfelespn ex expenditure clothing trans kit_dwl_frn h_fdtot meat carbs veggies fats baby eat_out non_labor pi_hhincome pi_hhwage pi_hhgovt pi_hhother pi_hhinvest pi_hhcapital pi_hhremitt pi_hhagric hhincome exp_imp vice comm ins services non_food food public exp1 health_exp sch_spending h_s inc inc_l inc_r inc_g fwag cwag swag home_prod ceremony public_other {
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
	
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	
	* Full residence id
	duplicates tag hhid hh1, g(dup)
	replace dup=dup+1
	g dupr=dup/size
	egen mD=max(dupr), by(hhid)
	
	g h_chi=h_ch
	replace h_chi=0 if (oidhh==0 & mD<.9)
	g h_chn=h_ch
	replace h_chn=0 if (oidhh==1 | (mD>.9 & mD<.))
	* move variables and key h_ch cleaning	
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	sort pid r
	tab h_ch
	foreach var of varlist h_chi h_chn h_ch {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
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
	foreach var of varlist ele wat {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
		* adult illness
	sort pid r
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}		
	sort pid r
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	replace c_waist_1=. if c_waist_1<0
	by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]		
	sort pid r
	foreach var of varlist zwfa zhfa zbmi {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}
	
	* SIZE FIXING
	egen min_a=min(a), by(pid)
	
	g nb_id=(min_a>=2)
	egen size1=sum(nb_id), by(hhid)
	replace size1=. if size1==0
	
  	rename size_lag size_lag_old
  	rename size_ch size_ch_old
	sort pid r
	by pid: g size_lag=size1[_n-1]
	by pid: g size_ch=size1[_n]-size1[_n-1]

	save clean/data_analysis/regs_nate_tables_3_6, replace
end

