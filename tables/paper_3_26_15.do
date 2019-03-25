

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define reduced_form
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	
	* doublecheck including 3 as treatment
	** ROBUST TO INCLUDING LAG AS TREATMENT **
*	sort pid r
*	by pid: g h_chlag=h_ch[_n-1]
*	replace h_ch=1 if h_chlag==1
	** ONLY 3rd WAVE **
*	drop h_ch
*	rename h_chlag h_ch

	g a_r23=a if r>2
	egen min_a23=min(a_r23), by(pid)
	egen min_a=min(a), by(pid)
	
	g nb_id=(min_a23>2 & min_a<75)
	egen size1=sum(nb_id), by(hhid)
	replace size1=. if size1==0
	sort pid r
	by pid: g size1_ch=size1[_n]-size1[_n-1]
	
	g ct_id=(min_a>2 & min_a<16)
	egen ct=sum(ct_id), by(hhid)
	g ad_id=(min_a>22 & min_a<=60)
	egen ad=sum(ad_id), by(hhid)
	g o_id=(min_a>60)
	egen o=sum(o_id), by(hhid)
	foreach var of varlist ct ad o {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	xi: reg zhfa_ch *_small *_large small size_lag a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<14 & zhfa_ch<2 & zhfa_ch>-2 & size_lag>1, robust cluster(hh1)	
	xi: reg zwfa_ch *_small *_large small size_lag a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<14 & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>1, robust cluster(hh1)	
	xi: reg size1_ch *_small *_large small size_lag i.r if  hclust>=5 & im<=$im & a<60 & size_lag<14 & size_lag>1, robust cluster(hh1)	
	xi: reg ad_ch *_small *_large small size_lag i.r if  hclust>=5 & im<=$im & a<60 & size_lag<14 & size_lag>1, robust cluster(hh1)	
	xi: reg o_ch *_small *_large small size_lag i.r if  hclust>=5 & im<=$im & a<60 & size_lag<14 & size_lag>1, robust cluster(hh1)	
	xi: reg ct_ch *_small *_large small size_lag i.r if  hclust>=5 & im<=$im & a<60 & size_lag<14 & size_lag>1, robust cluster(hh1)	
	xi: reg c_health_ch *_small *_large small a sex i.r if  hclust>=5 & im<=$im & a<16 & size_lag<11 & size_lag>2, robust cluster(hh1)	
	xi: reg c_ill_ch *_small *_large small a sex i.r if  hclust>=5 & im<=$im & a<16 & size_lag<11 & size_lag>2, robust cluster(hh1)	
		
			* why do kids in small houses do worse?
	
	xi: reg size1_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/size_ch.pdf, as(pdf) replace

	xi: reg size_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=5, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/size_ch.pdf, as(pdf) replace

	xi: reg size_ch H_* size_lag mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=5, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/size_ch.pdf, as(pdf) replace


	xi: reg ct_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/child_ch.pdf, as(pdf) replace

	xi: reg ad_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/adult_ch.pdf, as(pdf) replace

	xi: reg crowd_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	graph export graphs/crowd_ch.pdf, as(pdf) replace
	
	xi: reg size_ch H_* sl_* mm_* a sex i.r  if  hclust>=0 & im<=3500 & a<10 & size_lag<$s  & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/size_ch_kids.pdf, as(pdf) replace
	
		
			* HEIGHT MEASUREMENTS
	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-2 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/height_ch.pdf, as(pdf) replace

	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if zhfa_lag>0 & hclust>=5 & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-2 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  zhfa_lag<=0 &  hclust>=5 & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-2 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
				* gains are consistent across previously malnourished kids (unfortunately )
	
			* WEIGHT MEASUREMENTS
	xi: reg zwfa_ch H_* sl_*  i.r zwfa_p*  if  hclust>=5 & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/weight_ch.pdf, as(pdf) replace

	xi: reg zwfa_ch H_* sl_*  i.r zwfa_p*  if (zwfa_p25==0 & zwfa_p50==0) & hclust>=5 & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg zwfa_ch H_* sl_*  i.r zwfa_p*  if (zwfa_p25==1 | zwfa_p50==1) & hclust>=5 & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
				* pretty consistent across measures! * not the sickest kids gaining..
				
			* BMI MEASUREMENTS
	xi: reg zbmi_ch H_* sl_*  i.r zbmi_p*  if  hclust>=5 & im<=3500 & a<$a & size_lag<$s & zbmi_ch<2.5 & zbmi_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/bmi_ch.pdf, as(pdf) replace
		* broken up by over and under weight! *
	xi: reg zbmi_ch H_* sl_*  i.r zbmi_p*  if (zbmi_p25==0 & zbmi_p50==0) & hclust>=5 & im<=3500 & a<$a & size_lag<$s & zbmi_ch<2.5 & zbmi_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg zbmi_ch H_* sl_*  i.r zbmi_p*  if (zbmi_p25==1 | zbmi_p50==1) & hclust>=5 & im<=3500 & a<$a & size_lag<$s & zbmi_ch<2.5 & zbmi_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	

			* WEIGHT FOR HEIGHT MEASUREMENTS ( only 82 observations... )
	xi: reg zwfh_ch H_* sl_*  i.r zwfa_p*  if  hclust>=5 & im<=3500 & a<$a & size_lag<$s & zwfh_ch<2.5 & zwfh_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)



	xi: reg c_health_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2 & c_health_ch>-4 & c_health_ch<4, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg c_ill_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	
	xi: reg old_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg child_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	xi: reg adult_ch H_* sl_* mm_* a sex i.r  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
end


program define ROOMS
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	
	forvalues r=1(1)14 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
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

	forvalues r=1(1)4 {
	g C_`r'=0 if rooms_lag!=.
	replace C_`r'=1 if rooms_lag==`r'
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
	g C_5=0 if rooms_lag!=.
	replace C_5=1 if rooms_lag>5 & rooms_lag<=10
	g CH_5=h_ch
	replace CH_5=0 if C_5!=1 & h_ch!=.
	g CM_5=m_ch
	replace CM_5=0 if C_5!=1 & m_ch!=.
	
	g sr=(rooms_lag<=2)
	g uc=(size_lag<=4)
	g sr_uc=sr*uc
	
	g sr_h_ch=sr*h_ch
	g uc_h_ch=uc*h_ch
	g sr_uc_h_ch=sr*uc*h_ch

	xi: reg size_ch sr uc sr_uc sr_h_ch uc_h_ch sr_uc_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical 
	xi: reg crowd_ch sr uc sr_uc sr_h_ch uc_h_ch sr_uc_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical 


	
	xi: reg size_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
*	graph export graphs/room_ch.pdf, as(pdf) replace

	xi: reg rooms_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
	
	xi: reg crowd_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
	
		* DO THE SAME EXERCISE FOR YOUNG KIDS !! *
	xi: reg size_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<10 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)

	xi: reg rooms_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<10 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
	
	xi: reg crowd_ch CH_* C_* CM_* i.r if rooms_lag<=10 & im<=3500 & a<10 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
	
		* not enough of a response! 
	xi: reg zwfa_ch CH_* C_* CM_* a sex  i.r zwfa_p*  if rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	
	xi: reg zhfa_ch CH_* C_* CM_*  a sex i.r zhfa_p*  if  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	
		* UNCROWDED AT BASELINE! *

	xi: reg crowd_ch CH_* C_* CM_* size_lag i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
		
	xi: reg crowd_ch CH_* C_* CM_* i.h_ch*size_lag i.r if crowd_lag>1.55 &  rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)
	xi: reg crowd_ch CH_* C_* CM_*  i.h_ch*size_lag i.r if crowd_lag<=1.55 &  rooms_lag<=10 & im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)

	xi: reg zwfa_ch CH_* C_* CM_* a sex  size_lag  i.r zwfa_p*  if  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	xi: reg zwfa_ch CH_* C_* CM_* a sex i.r zwfa_p*  if  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
		
	xi: reg zwfa_ch CH_* C_* CM_* a sex  i.h_ch*size_lag  i.r zwfa_p*  if  crowd_lag>1.55 &  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	xi: reg zwfa_ch CH_* C_* CM_* a sex  i.h_ch*size_lag  i.r zwfa_p*  if  crowd_lag<=1.55 &  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	
			* changes quite a bit!
	xi: reg zhfa_ch CH_* C_* CM_* a sex  size_lag i.r zhfa_p*  if  rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)		

	xi: reg zhfa_ch CH_* C_* CM_*  a sex  i.h_ch*size_lag i.r zhfa_p*  if  crowd_lag>1.55 &   rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)		
	xi: reg zhfa_ch CH_* C_* CM_*  a sex  i.h_ch*size_lag i.r zhfa_p*  if  crowd_lag<=1.55 &   rooms_lag<=10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)	

end


program define CROWDING
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	
	forvalues r=1(1)14 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
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

	forvalues r=1(1)5 {
	g C_`r'=0 if crowd_lag!=.
	replace C_`r'=1 if crowd_lag>`r'-1 & crowd_lag<=`r'
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
		* selection seems to hold!
	xi: reg h_ch crowd_lag inc_ln i.r if im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	
	xi: reg crowd_ch CH_* C_* CM_* i.r if im<=3500 & a<80 & hclust>=0, robust cluster(hh1)
	coefplot, vertical keep(CH_*)

	xi: reg zwfa_ch CH_* C_* CM_* a sex  i.r zwfa_p*  if hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)
	
	xi: reg zhfa_ch CH_* C_* CM_*  a sex i.r zhfa_p*  if hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)	
	coefplot, vertical keep (CH_*)

	xi: reg c_ill_ch CH_* C_* CM_*  a sex i.r   if hclust>=5 & im<=3500 & a<10 , robust cluster(hh1)	
	coefplot, vertical keep (CH_*)

	xi: reg c_health_ch CH_* C_* CM_*  a sex i.r   if hclust>=5 & im<=3500 & a<10 , robust cluster(hh1)	
	coefplot, vertical keep (CH_*)

end


program define BOTH
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a "10"
	global s "10"
	global im "3500"
	
	forvalues r=1(1)14 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
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

	forvalues r=1(1)4 {
	g C_`r'=0 if rooms_lag!=.
	replace C_`r'=1 if rooms_lag==`r'
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
	g C_5=0 if rooms_lag!=.
	replace C_5=1 if rooms_lag>5 & rooms_lag<=10
	g CH_5=h_ch
	replace CH_5=0 if C_5!=1 & h_ch!=.
	g CM_5=m_ch
	replace CM_5=0 if C_5!=1 & m_ch!=.

	g size_lag_h_ch=size_lag*h_ch
	g rooms_lag_h_ch=rooms_lag*h_ch
	
	reg zwfa crowd inc_ln a sex i.r if a<10, cluster(hh1) robust
	
	reg zhfa crowd inc_ln a sex i.r if a<10, cluster(hh1) robust
	
	xtset pid
	xtreg zwfa crowd inc_ln i.r if a<10, fe robust
	xtreg zhfa crowd inc_ln i.r if a<10, fe robust
	
	
	xi: reg size_ch CH_* C_* CM_* H_* mm_* sl_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* size lag
	xi: reg size_ch H_* mm_* sl_* rooms_lag rooms_lag_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	xi: reg size_ch H_* mm_* sl_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* rooms lag
	xi: reg size_ch CH_* C_* CM_* size_lag size_lag_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	xi: reg size_ch CH_* C_* CM_*  i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

		* only look at smallish families
	xi: reg size_ch CH_* C_* CM_*  i.r if size_lag<=6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg size_ch CH_* C_* CM_*  i.r if size_lag>6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* big families decrease across the board ( which makes sense )

		* only look at smallish families
	xi: reg rooms_ch CH_* C_* CM_*  i.r if size_lag<=6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg rooms_ch CH_* C_* CM_*  i.r if size_lag>6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* pretty much the same but somewhat less of a decline

		* only look at smallish families
	xi: reg crowd_ch CH_* C_* CM_*  i.r if size_lag<=6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg crowd_ch CH_* C_* CM_*  i.r if size_lag>6 & rooms_lag<=10 & im<=3500 & a<80 & hclust>=5 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* big families decrease across the board ( which makes sense )
* new method 
		* only look at smallish families
	xi: reg zwfa_ch CH_* C_* CM_*  a sex  i.r zwfa_p*  if size_lag>2 & size_lag<=6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg zwfa_ch CH_* C_* CM_*  a sex  i.r zwfa_p*  if size_lag>6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

		* only look at smallish families
	xi: reg zhfa_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>2 & size_lag<=6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg zhfa_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* big families decrease across the board ( which makes sense )

	xi: reg zbmi_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>2 & size_lag<=6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 , robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg zbmi_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>6 & size_lag<10 & hclust>=5 & im<=3500 & a<10, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* big families decrease across the board ( which makes sense )
		
			* very few weight for height
	xi: reg zwfh_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>2 & size_lag<=6 & size_lag<10 & hclust>=5 & im<=3500 & a<10 , robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* only look at big families
	xi: reg zwfh_ch  CH_* C_* CM_*  a sex  i.r zhfa_p*  if size_lag>6 & size_lag<10 & hclust>=5 & im<=3500 & a<10, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
			* big families decrease across the board ( which makes sense )
			* very few weight for height



end 



program define BOTH_old_method
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	global a "10"
	global s "10"
	global im "3500"
	
	forvalues r=1(1)14 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
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

	forvalues r=1(1)4 {
	g C_`r'=0 if rooms_lag!=.
	replace C_`r'=1 if rooms_lag==`r'
	g CH_`r'=h_ch
	replace CH_`r'=0 if C_`r'!=1 & h_ch!=.
	g CM_`r'=m_ch
	replace CM_`r'=0 if C_`r'!=1 & m_ch!=.
	}
	g C_5=0 if rooms_lag!=.
	replace C_5=1 if rooms_lag>5 & rooms_lag<=10
	g CH_5=h_ch
	replace CH_5=0 if C_5!=1 & h_ch!=.
	g CM_5=m_ch
	replace CM_5=0 if C_5!=1 & m_ch!=.

	g size_lag_h_ch=size_lag*h_ch
	g rooms_lag_h_ch=rooms_lag*h_ch

* old method

	xi: reg rooms_ch CH_* C_* CM_* H_* mm_* sl_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

	xi: reg crowd_ch CH_* C_* CM_* H_* mm_* sl_* i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0 & size_lag<12, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	
	xi: reg crowd_ch H_* mm_* sl_*  i.r if im<=3500 & a<80 & hclust>=0 & size_lag<11, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	
	
	xi: reg crowd_ch H_* mm_* sl_* rooms_lag rooms_lag_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0 & size_lag<11, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	xi: reg crowd_ch CH_* C_* CM_* size_lag size_lag_h_ch i.r if rooms_lag<=10 & im<=3500 & a<80 & hclust>=0 & size_lag<11, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	
		* NOW DO OUTCOMES
		
		* control for both
	xi: reg zwfa_ch CH_* C_* H_* sl_* a sex  i.r zwfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

	xi: reg zwfa_ch CH_* H_* size_lag rooms_lag  a sex  i.r zwfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

	xi: reg zwfa_ch CH_* C_* size_lag_h_ch size_lag a sex  i.r zwfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	xi: reg zwfa_ch H_* sl_* rooms_lag_h_ch rooms_lag a sex  i.r zwfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)	
		
		* control for both
	xi: reg zhfa_ch CH_* C_* H_* sl_* a sex  i.r zhfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)

	xi: reg zhfa_ch CH_* H_* size_lag rooms_lag a sex  i.r zhfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
		* Still messed up! idk why? ! *
	xi: reg zhfa_ch CH_* C_* size_lag_h_ch size_lag a sex  i.r zhfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	xi: reg zhfa_ch H_* sl_* rooms_lag_h_ch rooms_lag a sex  i.r zhfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)
	
	hist rooms_lag  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zhfa_ch<2 & zhfa_ch>-2, by(size_lag h_ch) 
	
		* holding baseline size constant, getting a program house reduces height?!

	xi: reg zwfa_ch CH_* C_* CM_* H_* mm_* sl_* a sex  i.r zwfa_p*  if size_lag>2 & size_lag<10 & hclust>=5 & im<=3500 & a<10 & zwfa_ch<2.5 & zwfa_ch>-2.5, robust cluster(hh1)
	coefplot, vertical keep(CH_* H_*)


program define FOOD

	use clean/data_analysis/regs_nate_tables_3_6, clear	
	global a "10"
	global s "10"
	global im "3500"
	* calculate no-change again 
	keep if im<=$im
	
	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	forvalues r=5(5)85 {
	forvalues z=0/1 {
	g AA_`r'_`z'_id=(a>`r'-5 & a<=`r' & sex==`z')
	egen AA_`r'_`z'=sum(AA_`r'_`z'_id), by(hhid)
	drop AA_`r'_`z'_id
	}
	}
	
	replace pi_hhremitt=0 if pi_hhremitt==.
	*** General Approach ***
	* health_exp services veggies 
	foreach v in veggies {
	quietly sum `v', detail
	replace `v'=. if `v'>r(p95)
	reg `v' AA_* if hclust<5 & h_ch!=1
	predict `v'hat, residuals
	sort pid r
	by pid: g `v'hat_ch=`v'hat[_n]-`v'hat[_n-1]
	xi: reg `v'hat_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<10 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	}
		* decline in income, decline in wage income ( LARGE! ), slight increase in remittance income
		* increase in per person food expenditure? sort of..
		* food total might increase a bit
	
	** For food
	quietly sum h_fdtot, detail
	replace h_fdtot=. if h_fdtot>r(p90) | h_fdtot<r(p10)
	reg h_fdtot AA_* i.r
	predict fhat, residuals
	sort pid r
	by pid: g fhat_ch=fhat[_n]-fhat[_n-1]
	xi: reg fhat_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	
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

