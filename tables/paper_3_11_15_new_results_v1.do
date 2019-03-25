

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"




program define first_stage
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
	
	g inc_ind=1 if im<=1500
	replace inc_ind=2 if im>1500 & im<=2500
	replace inc_ind=3 if im>2500 & im<=3500
	replace inc_ind=4 if im>3500 & im<=5000
	replace inc_ind=5 if im>5000
	sort pid r
	by pid: g inc_ind_lag=inc_ind[_n-1]
	
	hist rooms if rooms<10, by(inc_ind_lag h_ch)
	
	
	global a1 "70"
	global s "11"
	global im "5000"	

	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	
	
	tab size_lag h_ch if im<=$im & a<$a1 & size_lag<$s  & hclust>=0
	
	xi: reg size_ch i.h_ch*size_lag  i.r if im<=$im & a<$a1 & size_lag<$s & size_lag>1 & hclust>=0, robust cluster(hh1)
	
	
	foreach r in 8 {
	xi: reg size_ch H_* mm_* sl_*  i.r if im<=$im & a<$a1 & size_lag<$s  & hclust>=5 & prov==`r', robust cluster(hh1)
	coefplot, vertical keep(H_*)
	}

*	collapse (max)  size_ch hi_*  hn_* mm_* sl_* im size_lag, by(hhid r)
*	xi: reg size_ch hi_*  hn_* mm_* sl_*  i.r if im<=$im & size_lag<$s & size_lag>1, robust
*	coefplot, vertical keep(hi_* hn_*)	

	xi: reg child_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
	xi: reg adult_ch h_ch h_ch_sl size_lag  i.r if hclust>=5 & im<=$im & a<$a1 & size_lag<$s, robust cluster(hh1)
	outreg2 using clean/tables/first_stage, nonotes tex(frag) keep(h_ch h_ch_sl size_lag) label append nocons  addtext(Treated Area, Over 5)
end



program define multi_generational

	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "5000"
	keep if im<=$im
	
	g C=a<12
	* households splitting: WHY ARE THESE BIG HOUSEHOLDS ESSENTIALLY SPLITTING??
	g mother=(sex==0 & a<50 & a>20)
	
	egen hh_mother=sum(mother), by(hhid)
	g mom2=(hh_mother>1 & hh_mother<.)
	
*	hist size, by(hh_mother)
	
	g h_ch_mom2=h_ch*mom2
	
	g c_alt_id=(min_a>2 & min_a<17)
	egen c_alt=sum(c_alt_id), by(hhid)
	sort pid r
	by pid: g c_alt_lag=c_alt[_n-1]
	by pid: g c_alt_ch=c_alt[_n]-c_alt[_n-1]

	forvalues r=0(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if c_alt_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  c_alt_lag!=`r' & m_ch!=.	
	g sl_`r'=(c_alt_lag==`r')
	}	
	
		* tend to leave kids behind
	xi: reg c_alt_ch H_* sl_* i.r if c_alt_lag<5 & c_alt_lag>=0 & hclust>=5, cluster(hh1) robust
	coefplot, vertical keep(H_*)
	

	xi: reg zwfa_ch i.h_ch*c_alt_lag i.r if c_alt_lag<5 & c_alt_lag>0, cluster(hh1) robust

	
	xi: reg c_alt_ch i.h_ch*c_alt_lag i.r if c_alt_lag<5 & c_alt_lag>0, cluster(hh1) robust

	
	
	
	xi: reg size_ch h_ch mom2 h_ch_mom2 i.r, cluster(hh1) robust
	xi: reg child_ch i.h_ch*i.child_lag i.r if child_lag<5 & child_lag>0, cluster(hh1) robust
	
	xi: reg adult_ch h_ch mom2 h_ch_mom2 i.r, cluster(hh1) robust
	xi: reg old_ch h_ch mom2 h_ch_mom2 i.r, cluster(hh1) robust
	
	
	hist size, by(mother)
	
	
	



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
	
	g crowd=size/rooms
	replace crowd=. if crowd>5
	sort pid r
	by pid: g crowd_ch=crowd[_n]-crowd[_n-1]

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

	xi: reg size_ch H_* sl_* mm_* i.r if im<=3500 & a<80 & size_lag<12 & size_lag>1 & hclust>=0, robust cluster(hh1)
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
	
	
	
			* HEIGHT MEASUREMENTs
	sum zhfa_ch, detail
	sum zwfa_ch, detail
	
	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=0 & im<=3500 & a<10 & size_lag<$s & zhfa_ch<2 & zhfa_ch>-2 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/height_ch.pdf, as(pdf) replace
	
			* WEIGHT MEASUREMENTS
	xi: reg zwfa_ch H_* sl_*  i.r zwfa_p*  if  hclust>=5 & im<=3500 & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
	graph export graphs/weight_ch.pdf, as(pdf) replace


		* FOR ROUND 2
	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2.5 & zhfa_ch>-2.5 & size_lag>2 & r==2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
		* FOR ROUND 3
	xi: reg zhfa_ch H_* sl_* mm_* a sex i.r zhfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zhfa_ch<2.5 & zhfa_ch>-2.5 & size_lag>2 & r==3, robust cluster(hh1)	
	coefplot, vertical keep (H_*)

		* FOR ROUND 2
	xi: reg zwfa_ch H_* sl_* mm_* a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2 & r==2, robust cluster(hh1)	
	coefplot, vertical keep (H_*)
		* FOR ROUND 3
	xi: reg zwfa_ch H_* sl_* mm_* a sex i.r zwfa_p*  if  hclust>=5 & im<=$im & a<$a & size_lag<$s & zwfa_ch<2.5 & zwfa_ch>-2.5 & size_lag>2 & r==3, robust cluster(hh1)	
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


program define TYPES

	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "5000"
	* calculate no-change again 
	foreach v in h_ch {
	forvalues r=2/3 {
	g `v'_`r'=`v' if r==`r'
	egen `v'_pid_`r'=max(`v'_`r'), by(pid)
	egen `v'_hh_`r'=max(`v'_pid_`r'), by(hhid)
	}
	}
	g l=((h_ch_hh_2==1 & r==1 & h_ch_pid_2!=1) | (h_ch_hh_3==1 & r==2 & h_ch_pid_3==0 & h_ch_hh_2!=1))
	egen xhh=max(h_ch), by(hhid)
	g j=(xhh==1 & h_ch!=1)
	replace j=. if a<=2

	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	g halt1=h1
	replace halt1=h2 if halt1==.
	replace halt1=h3 if halt1==.

	duplicates tag halt1 hhid, g(hd1)
	replace hd1=hd1+1
	g hdr=hd1/size	
	g dif=size-hd1
	sort pid r
	by pid: g hd1_ch=hd1[_n]-hd1[_n-1]
	replace hd1_ch=. if hd1_ch>0
	tab hd1_ch 
	g lose=(hd1_ch<0)
	replace lose=. if r==1
	
			*** LOSING MEMBERS ***
	lowess lose size_lag
		* big families are way more likely to lose an original member
	xi: reg lose i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	xi: reg lose H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg hd1_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	by pid: g dif_ch=dif[_n]-dif[_n-1]
	g gain=(dif>0 & dif<.)
	
			*** GAINING MEMBERS ***	
	lowess gain size_lag
		* big families are way more likely to lose an original member
	xi: reg gain i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	xi: reg gain H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	xi: reg dif_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)			
			* again big baseline households are 
			
			*** NO CHANGE ***
	g no_change=(gain==0 & lose==0)
	xi: reg no_change i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	xi: reg no_change H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
		
			*** HOW ABOUT AVERAGE AGE? ***
	egen mean_a=mean(a), by(hhid)	
	sort pid r
	by pid: g mean_a_ch=mean_a[_n]-mean_a[_n-1]
	xi: reg mean_a_ch i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	xi: reg mean_a_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<50 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	
	tab dif_ch h_ch

end



program define TRADING_ALSO_CROWDING

	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "3500"
	* calculate no-change again 
	foreach v in h_ch {
	forvalues r=2/3 {
	g `v'_`r'=`v' if r==`r'
	egen `v'_pid_`r'=max(`v'_`r'), by(pid)
	egen `v'_hh_`r'=max(`v'_pid_`r'), by(hhid)
	}
	}
	g l=((h_ch_hh_2==1 & r==1 & h_ch_pid_2!=1) | (h_ch_hh_3==1 & r==2 & h_ch_pid_3==0 & h_ch_hh_2!=1))
	egen xhh=max(h_ch), by(hhid)
	g j=(xhh==1 & h_ch!=1)
	replace j=. if a<=2

	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	duplicates tag hh1 hhid, g(hd1)
	replace hd1=hd1+1
	g hdr=hd1/size	
	g dif=size-hd1
	sort pid r
	by pid: g hd1_ch=hd1[_n]-hd1[_n-1]
	by pid: g dif_ch=dif[_n]-dif[_n-1]
	by pid: g hdr_ch=hdr[_n]-hdr[_n-1]
	
		* bundling/mental accounting?? * kid's goods versus adult goods!?
	
		* WHO TRADES FOR WHO? *
		** link join and trade to hh1!: then do fixed effect for hh1!!
		
	g HH1=hhid if r==1
	egen tr_id=max(HH1), by(pid)
	egen trade=max(tr_id), by(hhid)
	g HH2=hhid if r==2
	egen tr_id2=max(HH2), by(pid)
	egen trade1=max(tr_id2), by(hhid)
	replace trade=trade1 if trade==.
	egen tr_rdp=max(h_ch), by(trade)
	
	xtset trade
	
	g young_child=(min_a<=14 & min_a>=3)
	g elderly=a>60
	g young_adult=(a>16 & a<=25)
	g parent=(a>25 & a<=60)
	
		* not super different, when limiting the sample ( Driven by some size outliers )
	xi: xtreg a l j if tr_rdp==1 & size_lag<10 & size_lag>=2 & im<=$im & hclust>=5, fe robust
	xi: xtreg a i.l*size_lag i.j*size_lag if tr_rdp==1 & size_lag<10 & size_lag>=2 & im<=$im & hclust>=5, fe robust
	
	* create age bins, do this non-parametrically: WHO IS BEING LEFT OUT? Doesn't work super well, stick with other regressions
	forvalues r=12(10)72 {
	g aa_`r'=(a>`r'-10 & a<=`r')
	}
	drop aa_12
	xtset hhid
	xi: xtreg l aa_* if tr_rdp==1 & a>2 & a<=72 , fe robust
	coefplot, vertical keep(aa_*)
	xi: xtreg j aa_* if tr_rdp==1 & a>2 & a<=72 , fe robust
	coefplot, vertical keep(aa_*)	

	xi: xtreg sex l j if tr_rdp==1, fe robust

	xi: xtreg young_child l j if tr_rdp==1, fe robust
	xi: xtreg elderly l j if tr_rdp==1, fe robust
	xi: xtreg young_adult l j if tr_rdp==1, fe robust
	xi: xtreg parent l j if tr_rdp==1, fe robust	
	
	xi: xtreg e l j if tr_rdp==1, fe robust
	xi: xtreg ue l j if tr_rdp==1, fe robust
	xi: xtreg sex l if (l==1 | j==1), fe robust
	
	* what about crowding?
	g crowd=size/rooms
	replace crowd=. if crowd>4
	sort pid r
	by pid: g crowd_ch=crowd[_n]-crowd[_n-1]
	
	xi: reg crowd_ch i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>1, robust cluster(hh1)
	xi: reg crowd_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>1, robust cluster(hh1)
	coefplot, vertical keep(H_*)	
	
	xi: reg hdr_ch i.h_ch*i.size_lag i.m_ch*i.size_lag i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
		* there is just greater flux in rdp houses!
		
	xi: reg hdr_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg hd1_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg dif_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

end

program define FOOD

	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
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

program define who_is_left_behind
	
	
	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "5000"
	* calculate no-change again 
	foreach v in h_ch {
	forvalues r=2/3 {
	g `v'_`r'=`v' if r==`r'
	egen `v'_pid_`r'=max(`v'_`r'), by(pid)
	egen `v'_hh_`r'=max(`v'_pid_`r'), by(hhid)
	}
	}
	g l=((h_ch_hh_2==1 & r==1 & h_ch_pid_2!=1) | (h_ch_hh_3==1 & r==2 & h_ch_pid_3==0 & h_ch_hh_2!=1))
	egen xhh=max(h_ch), by(hhid)
	g j=(xhh==1 & h_ch!=1)
	replace j=. if a<=2
	
	egen xsl=max(size_lag), by(hhid)

	egen lid=max(l), by(hhid)
	egen jid=max(j), by(hhid)
		
	egen lid_hh=sum(l), by(hhid)
	egen jid_hh=sum(j), by(hhid)	

	egen l_hh=max(l), by(hh1)
	egen j_hh=max(j), by(hh1)	
	
	tab l_hh j_hh
	
	g left_overs=lid_hh/size
	g join_ratio=jid_hh/size
	
	egen lo_r=max(left_overs), by(hh1)
	egen jr_r=max(join_ratio), by(hh1)
	
	forvalues r=1(1)12 {
	g H_`r'=h_ch
	replace H_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	}
	
	* does the ratio of adults to children change? ya kinda!
	g child_ratio=child/size
	sort pid r
	by pid: g child_ratio_lag=child_ratio[_n-1]
	by pid: g child_ratio_ch=child_ratio[_n]-child_ratio[_n-1]
	by pid: g cres_ch=cres[_n]-cres[_n-1]
	by pid: g cnres_ch=cnres[_n]-cnres[_n-1]
	
	twoway (lowess child_ch size_lag if h_ch==1 & size_lag>1 & size_lag<11, color(pink)) || (lowess child_ch size_lag if h_ch==0 & size_lag>1 & size_lag<11)
	twoway (lowess adult_ch size_lag if h_ch==1 & size_lag>1 & size_lag<11, color(pink)) || (lowess adult_ch size_lag if h_ch==0 & size_lag>1 & size_lag<11, color(orange)) || (lowess child_ch size_lag if h_ch==1 & size_lag>1 & size_lag<11, color(blue)) || (lowess child_ch size_lag if h_ch==0 & size_lag>1 & size_lag<11, color(black))
	twoway (lowess child_ratio_ch size_lag if h_ch==1 & size_lag>1 & size_lag<11, color(pink)) || (lowess child_ratio_ch size_lag if h_ch==0 & size_lag>1 & size_lag<11)
	
	xi: reg child_ratio_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<40 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	
	xi: reg child_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg child_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<$a & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)


	xi: reg h_fdtot_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg pi_hhincome_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg fats_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg veggies_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg meat_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg carbs_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg public_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
	xi: reg non_food_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)


	xi: reg cres_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<35 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)


*	xi: reg cnres_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<35 & size_lag<$s & size_lag>2, robust cluster(hh1)
*	coefplot, vertical keep(H_*)



	xi: reg h_fdtot_ln_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg pi_hhincome_ln_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg pi_hhincome_ln_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)

	xi: reg health_exp_ln_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
		

	xi: reg sch_spending_ln_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)
			
	xi: reg exp1_ln_p_ch H_* sl_* i.r if hclust>=5 & im<=$im & a<60 & size_lag<$s & size_lag>2, robust cluster(hh1)
	coefplot, vertical keep(H_*)


	
	lowess lo_r jr_r if lo_r>0 & jr_r>0
	
	lowess left_overs size if left_overs>0 & size<$s
	lowess lid_hh size if lid_hh>0 & size<$s
	
	lowess join_ratio size_lag if join_ratio>0 & size_lag<$s
	lowess jid_hh size_lag if jid_hh>0 & size_lag<$s

	lowess lid_hh size if lid==1 & size_lag<$s
	lowess jid_hh size_lag if xhh==1 & size_lag<$s
	
	lowess join_ratio size_lag if xhh==1 & size_lag<$s
	lowess jid_hh size_lag if  xhh==1 & size_lag<$s
	
	
	lowess a size if l==1 & a<55 & size<$s & size>2

	lowess a xsl if j==1 & a<55 & xsl<$s & a>0	& xsl>2
	
	hist left_overs if left_overs>0, by(size_lag)
	hist a if l==1
	hist a if lid==1, by(l)

	drop if a>60
	collapse a size, by(l hhid)
	
	lowess a size if l==1 & size<10	
	
	* histogram of age by size and treatment; bimodal? nuclear families?
	hist a if size_lag>2 & size_lag<10, by(size_lag h_ch)
end	

	

	
program define SELECTION_TIME	

	use clean/data_analysis/regs_nate_tables_3_6, clear
*	label_variables		
	global a "10"
	global s "10"
	global im "5000"
	foreach v in h_ch {
	forvalues r=2/3 {
	g `v'_`r'=`v' if r==`r'
	egen `v'_pid_`r'=max(`v'_`r'), by(pid)
	egen `v'_hh_`r'=max(`v'_pid_`r'), by(hhid)
	}
	}
	g l=((h_ch_hh_2==1 & r==1 & h_ch_pid_2!=1) | (h_ch_hh_3==1 & r==2 & h_ch_pid_3==0 & h_ch_hh_2!=1))
	egen xhh=max(h_ch), by(hhid)
	g j=(xhh==1 & h_ch!=1)
	replace j=. if a<=2
	
	egen xsl=max(size_lag), by(hhid)

	egen lid=max(l), by(hhid)
	egen jid=max(j), by(hhid)
	egen lid_hh=sum(l), by(hhid)
	egen jid_hh=sum(j), by(hhid)
	egen l_hh=max(l), by(hh1)
	egen j_hh=max(j), by(hh1)
	g left_overs=lid_hh/size
	g join_ratio=jid_hh/size	
	egen lo_r=max(left_overs), by(hh1)
	egen jr_r=max(join_ratio), by(hh1)
	
	forvalues r=3(1)12 {
	g L_`r'=l
	replace L_`r'=0 if size_lag!=`r' & h_ch!=.
	g mm_`r'=m_ch
	replace mm_`r'=0 if  size_lag!=`r' & m_ch!=.	
	g sl_`r'=(size_lag==`r')
	g s_`r'=size==`r'
	}
	g small=size_lag<=6
	g large=size_lag>6
	foreach v in  h_ch m_ch {
	g `v'_small=`v'
	replace `v'_small=0 if size_lag>6 & `v'!=.
	g `v'_large=`v'
	replace `v'_large=0 if size_lag<=6 & `v'!=.
	}
	g s6=size>=6
	g j_s6=j*s6
	
	** question ** ** is there more non-fertility turnover in RDP houses?!
	**** joiners are more likely to be children! ****
*	hist a if j==1
* 	hist a if h_chn==1
	
	xtset hhid
	* not powered enough for full non-parametric: let's look at selection in subsamples
	
	tab zwfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<20
	tab zwfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size>=6 & a<20
	tab c_ill l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<20
	tab c_ill l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size>=6 & a<20
	tab zhfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<20
	tab zhfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size>=6 & a<20

	xi: xtreg c_health l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<20, fe robust
	xi: xtreg c_health l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size>=6 & a<20 & size<10, fe robust
			
	xi: xtreg c_health j if (xhh==1) & size<6 & a<20 & hclust>=5, fe robust
	xi: xtreg c_health j if (xhh==1) & size>=6 & a<20 & hclust>=5 & size<10, fe robust
	
*	xi: xtreg zwfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<20, fe robust
*	xi: xtreg zwfa l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size>=6 & a<20, fe robust
	xi: xtreg zwfa j if (xhh==1) & size<6 & a<20 & hclust>=5, fe robust
	xi: xtreg zwfa j if (xhh==1) & size>=6 & a<20 & hclust>=5 & size<10, fe robust

	xi: xtreg c_health j j_s6 if (xhh==1) & a<20 & hclust>=5 & size<10, fe robust
	xi: xtreg zhfa j j_s6 if (xhh==1) & a<20 & hclust>=5 & size<10, fe robust
	xi: xtreg zwfa j j_s6 if (xhh==1) & a<20 & hclust>=5 & size<10, fe robust

	xi: xtreg c_ill_ser l if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<6 & a<10, fe robust
		
* 	xi: reg c_ill_ser L_* s_* i.r if (h_ch_hh_2==1 | h_ch_hh_3==1) & size<$s & size>2 & a<10, robust cluster(hh1)
* 	coefplot, keep( L_* s_* ) vertical
end
	
	
	
	
	
	
program define extra_stuff	
	
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
*	g a_r23=a if r>=2
*	egen min_a23=min(a_r23), by(pid)
*	egen min_a=min(a), by(pid)
	
*	g nb_id=(min_a23>2 & min_a<75)
*	egen size1=sum(nb_id), by(hhid)
*	replace size1=. if size1==0
*	by pid: g size_lag1=size1[_n-1]
	
*	rename size size_old
 * 	rename size_lag size_lag_old
 * 	rename size_ch size_ch_old
*	sort pid r
*	
*	by pid: g size_ch=size1[_n]-size1[_n-1]
*	rename size1 size
	
	save clean/data_analysis/regs_nate_tables_3_6, replace
end

