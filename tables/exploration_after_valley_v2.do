
	
	clear all
	set mem 4g
	set maxvar 10000
	set matsize 4000

	cd "/Users/willviolette/Desktop/pstc_work/nids"

	*** SERVICES MECHANISM ***
	
	use clean/data_analysis/regs_nate_tables_3_3, clear	
*	drop if rent_d==1 & h_ch==1
	drop inc_ad im
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	egen hclust=sum(h_chi), by(cluster)


	* move variables		
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	g m_ch_at_7_18=m_ch*at_7_18
	g m_ch_at_60=m_ch*at_60
	g m_ch_sl_at_7_18=m_ch_sl*at_7_18
	g m_ch_sl_at_60=m_ch_sl*at_60
	
	g ele=1 if h_nfelespn>0 & h_nfelespn<.
	replace ele=0 if h_nfelespn==0
	g wat=1 if h_nfwatspn>0 & h_nfwatspn<.
	replace wat=0 if h_nfwatspn==0
	
	sort pid r
	foreach var of varlist ele wat {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
	sort pid r
	foreach var of varlist h_chi h_chn  {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
	replace m_ch=. if r==1
	
		sort pid r
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	by pid: g `var'_lag=`var'[_n-1]
	}
	
		* sanity test with interactions ! *
		replace c_absent=. if c_absent==0
		
		sort pid r
		by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
		replace c_waist_1=. if c_waist_1<0
		by pid: g c_waist_1_ch=c_waist_1[_n]-c_waist_1[_n-1]		
	
	* sanity test ! *
		* these work * * * h_nfwatspn_ln h_nfelespn_ln piped flush rooms
		* unbelievably zero change here : pi_hhincome_ln pi_hhwage_ln pi_hhgovt_ln pi_hhremitt_ln 
		* also nothing: c_absent c_failed 

	global a "8"
	global s "11"
	global im "10000"
	
	** flexible lag controls **
	sort pid r
	foreach var of varlist zwfa zhfa {
	g `var'_lag_2=`var'_lag*`var'_lag
	quietly sum `var', detail
	by pid: g `var'_p25=(`var'[_n-1]<=r(p25))
	by pid: g `var'_p50=(`var'[_n-1]>r(p25) & `var'[_n-1]<=r(p50))
	by pid: g `var'_p75=(`var'[_n-1]>r(p50) & `var'[_n-1]<=r(p75))	
	}
	
	
	** SIZE TIME **
	foreach var of varlist size adult child {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & hclust>=20 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
		* relatively stable * relatively even between kids and adults
	
	
	** WEIGHT AND HEIGHT **
	
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	

	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
		* control for the lags
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag `var'_lag_2 i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex `var'_lag `var'_lag_2  i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_lag `var'_lag_2 i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	
	
	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_p* i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex `var'_p*   i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex `var'_p*  i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	

	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=5000 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag a sex `var'_p*  i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	





	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch h_ch h_ch_sl size_lag m_ch m_ch_sl a sex i.r if im<=5000 & hclust>0 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag m_ch m_ch_sl a sex i.r if im<=5000 & hclust>=5 & a<$a & size_lag<$s, robust cluster(hh1)
	xi: reg `var'_ch h_ch h_ch_sl size_lag m_ch m_ch_sl a sex i.r if im<=5000 & hclust>=10 & a<$a & size_lag<$s, robust cluster(hh1)
	}	



	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl  size_lag a sex i.r if im<=5000 & hclust>=5, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl size_lag a sex i.r if im<=5000 & hclust>=10, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl   size_lag a sex i.r if im<=5000 & hclust>=15, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl   size_lag a sex i.r if im<=5000 & hclust>=20, robust cluster(hh1)
	}		
	
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r if im<=5000, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r if im<=5000 & hclust>=5, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r if im<=5000 & hclust>=10, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r if im<=5000 & hclust>=15, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag a sex i.r if im<=5000 & hclust>=20, robust cluster(hh1)
	}	
		
		
		
		
	foreach var of varlist c_failed c_absent c_ill c_waist_1  {
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag i.r if im<=5000, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag i.r if im<=5000 & hclust>5, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chi_sl h_chn h_chn_sl m_ch m_ch_sl size_lag i.r if im<=5000 & hclust>10, robust cluster(hh1)
	}	
	
	foreach var of varlist a_hl30fl a_hl30fev a_hl30pc a_hl30b a_hl30h a_hl30ba a_hl30v a_hl30d a_hl30wl {
	xi: reg `var'_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chn m_ch `var'_lag i.r if im<=5000 & hclust>0, robust cluster(hh1)
	}
	

	xi: reg wat_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg ele_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	
	xi: reg water_exp_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg ele_exp_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)


	xi: reg h_nfwatspn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg h_nfelespn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg h_nfwatspn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>5, robust cluster(hh1)
	xi: reg h_nfelespn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>5, robust cluster(hh1)
	xi: reg h_nfwatspn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>20, robust cluster(hh1)
	xi: reg h_nfelespn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>20, robust cluster(hh1)

	

	xi: reg h_nfwatspn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg h_nfelespn_ln_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)

	xi: reg h_nfwatspn_ln_p_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)
	xi: reg h_nfelespn_ln_p_ch h_chi h_chn m_ch i.r if im<=5000 & hclust>0, robust cluster(hh1)

	
* * * *** *** * * *
	
	use clean/data_analysis/regs_nate_tables_3_3, clear	
*	drop if rent_d==1 & h_ch==1
	drop inc_ad im
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	egen hclust=sum(h_chi), by(cluster r)
	g i=1
	egen clust_count=sum(i), by(cluster r)
	g hcper=hclust/clust_count

	
	replace move=1 if move==2
	g move_size_lag=move*size_lag
	
	* move variables		
	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	g m_ch_at_7_18=m_ch*at_7_18
	g m_ch_at_60=m_ch*at_60
	g m_ch_sl_at_7_18=m_ch_sl*at_7_18
	g m_ch_sl_at_60=m_ch_sl*at_60
	
	g a_2=a*a
	g a_sex=a*sex	
	
	sort pid r
	by pid: g weight_ch=weight[_n]-weight[_n-1]
	by pid: g weight_lag=weight[_n-1]
	by pid: g diar_ch=a_hl30d[_n]-a_hl30d[_n-1]
	
	replace weight_ch=. if weight_ch<-20 | weight_ch>20
	sort pid r
	foreach var of varlist h_chi h_chn  {
	by pid: g `var'r=`var'[_n]-`var'[_n-1]
	replace `var'=. if `var'r==-1
	replace `var'=. if r==1
	}
	replace m_ch=. if r==1	
	
	egen mdbrdp=sum(h_chi), by(mdb)
	
	tab mdb h_chi
	
	g h_chir1=h_chi
	replace h_chir1=2.5 if r==2 & h_chi==1
	replace h_chir1=2 if r==2 & h_chi==0
	replace h_chir1=3.5 if r==3 & h_chi==1
	replace h_chir1=3 if r==3 & h_chi==0
	
	tab mdb h_chir1
	
	sort pid r
	by pid: g zwfa_ch2=zwfa_ch[_n-1]
	by pid: g zwfa1=zwfa[_n-1]
	by pid: g zwfa2=zwfa1[_n-1]
	
	reg h_chi zwfa_ch2 i.r, robust cluster(hh1)
	
	reg h_chn zwfa_ch2 i.r, robust cluster(hh1)
	
	reg h_ch zwfa_ch2 i.r, robust cluster(hh1)
	
	reg h_ch zwfa1  zwfa_ch2 i.r, robust cluster(hh1)
			* not a good sign, there are pretrends! *
	
	** look for family structure first stage **
	
	replace size=. if size>11
	
	g crowd=size/rooms
	replace crowd=. if crowd>4.5
	
*	lowess size rooms if size<15 & rooms<10, by(h_chi)
	
	
	sort pid r
	by pid: g crowd_lag=crowd[_n-1]
	g cl=(crowd_lag>2 & crowd_lag<.)

	twoway lowess crowd crowd_lag if h_chi==0 & h_chn==0, color(orange) || lowess crowd crowd_lag if h_chi==1, color(black)  || lowess crowd crowd_lag if h_chn==1, color(pink)	
	
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch i.h_chi*cl i.h_chn*cl i.m_ch*cl `var'_lag i.r if a<=10, robust cluster(hh1)
	}
	
	
	foreach var of varlist size child adult  {
	xi: reg `var'_ch i.h_chi*`var'_lag i.h_chn*`var'_lag i.m_ch*`var'_lag i.r if hcper>.1 & hcper<. & im<=3500, robust cluster(hh1)
	xi: reg `var'_ch i.h_chi*`var'_lag i.h_chn*`var'_lag i.m_ch*`var'_lag i.r if hcper>0 & hcper<=.1 & im<=3500, robust cluster(hh1)
	}


	foreach var of varlist size child adult old {
	xi: reg `var'_ch i.h_chi*`var'_lag i.h_chn*`var'_lag i.m_ch*`var'_lag i.r if mdb==418, robust cluster(hh1)
	xi: reg `var'_ch i.h_chi*size_lag i.h_chn*size_lag i.m_ch*size_lag i.r if mdb==418, robust cluster(hh1)
	}	
	
			* positive or negative reinforcement?
	foreach var of varlist zwfa zhfa zbmi {
	xi: reg `var'_ch i.h_chi*`var'_lag i.h_chn*`var'_lag i.m_ch*`var'_lag i.r if a<=10, robust cluster(hh1)
	}	

	foreach var of varlist e ue {
	xi: reg `var'_ch h_chi h_chn m_ch `var'_lag i.r if hclust>0, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chn m_ch `var'_lag i.r if hclust>5, robust cluster(hh1)
	xi: reg `var'_ch h_chi h_chn m_ch `var'_lag i.r if hclust>10, robust cluster(hh1)
	}	

	

	foreach var of varlist zwfa zhfa {
	xi: reg `var'_ch i.h_chi*`var'_lag i.h_chn*`var'_lag i.m_ch*`var'_lag i.r if hclust>0, robust cluster(hh1)
	}	




	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if hclust>20, robust cluster(hh1)
	 
	
	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if hclust>20, robust cluster(hh1)
	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if hclust<=20 & hclust>0, robust cluster(hh1)

	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if hcper>.07, robust cluster(hh1)
	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if hcper<=.07 & hcper>0, robust cluster(hh1)

	xi: reg size_ch h_chi h_chn move h_chi_sl h_chn_sl  move_size_lag size_lag i.r if im<=3500 & hcper>.1 & size_lag<=11, robust cluster(hh1)
	xi: reg size_ch h_chi h_chn move h_chi_sl h_chn_sl  move_size_lag size_lag i.r if im<=3500 & hcper<=.1 & hcper>0 & size_lag<=11, robust cluster(hh1)

	xi: reg size_ch h_chi h_chn h_chi_sl h_chn_sl  m_ch m_ch_sl size_lag i.r if im<=3500 & hcper>.1 & size_lag<=11, robust cluster(hh1)
	xi: reg size_ch h_chi h_chn h_chi_sl h_chn_sl  m_ch m_ch_sl size_lag i.r if im<=3500 & hcper<=.1 & hcper>0 & size_lag<=11, robust cluster(hh1)








	xi: reg zhfa_ch h_chi h_chn m_ch i.r if a<=10 & im<=6000 & hcper>.05 & hcper<. & size_lag<=11, robust cluster(hh1)
	xi: reg zhfa_ch h_chi h_chn m_ch    zhfa_lag i.r if a<=10 & im<=6000 & hcper>.05 & hcper<. & size_lag<=11, robust cluster(hh1)

	xi: reg zwfa_ch h_chi h_chn m_ch i.r if a<=10 & im<=6000 & hcper>.05 & hcper<. & size_lag<=11, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn m_ch   zwfa_lag i.r if a<=10 & im<=6000 & hcper>.05 & hcper<. & size_lag<=11, robust cluster(hh1)



	xi: reg zhfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if a<=7 , robust cluster(hh1)
	xi: reg zhfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag  zhfa_lag i.r if a<=7, robust cluster(hh1)

	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if a<=7, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag zwfa_lag i.r if a<=7, robust cluster(hh1)



	xi: reg weight_ch h_chi h_chn m_ch  h_chi_at_7_18 h_chn_at_7_18 m_ch_at_7_18 h_chi_at_60 h_chn_at_60 m_ch_at_60 h_chi_sl h_chn_sl m_ch_sl h_chi_sl_at_7_18 m_ch_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60 m_ch_sl_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 i.a*weight_lag i.a_sex*weight_lag i.r if im<=5000 & hclust>10 & a<60 & size_lag<=11, robust cluster(hh1)




	xi: reg zw_ch h_chi h_chn m_ch  h_chi_at_7_18 h_chn_at_7_18 m_ch_at_7_18 h_chi_at_60 h_chn_at_60 m_ch_at_60 h_chi_sl h_chn_sl m_ch_sl h_chi_sl_at_7_18 m_ch_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60 m_ch_sl_at_60 size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 zw_lag i.r if im<=5000 & hclust>10 & a<60 & size_lag<=11, robust cluster(hh1)







	xi: reg size_ch h_ch h_ch_sl move move_size_lag size_lag i.r if a<60 & im<=3500 & hclust>0 & size_lag<=11, robust cluster(hh1)


	xi: reg size_ch h_ch h_ch_sl m_ch m_ch_sl size_lag i.r if a<60 & im<=5000 & hclust>0 & size_lag<=11, robust cluster(hh1)

	xi: reg size_ch h_chi h_chn m_ch h_chi_sl h_chn_sl  m_ch_sl size_lag i.r if a<60 & im<=5000 & hclust>0 & size_lag<=11, robust cluster(hh1)
	xi: reg size_ch h_chi h_chn m_ch h_chi_sl h_chn_sl  m_ch_sl size_lag i.r if a<60 & im<=3500 & hclust>10, robust cluster(hh1)
	
	xi: reg size_ch h_chi h_chn move h_chi_sl h_chn_sl  move_size_lag size_lag i.r if a<60 & im<=3500 & hclust>5 & size_lag<=11, robust cluster(hh1)
	xi: reg size_ch h_chi h_chn move h_chi_sl h_chn_sl  move_size_lag size_lag i.r if a<60 & im<=5000 & hclust>5 & size_lag<=11, robust cluster(hh1)
	
	
	* restricted sample
	xi: reg size_ch h_ch h_ch_sl m_ch m_ch_sl size_lag i.r if a<60 & im<=3500 & hclust>5 & size_lag<=11, robust cluster(hh1)
	xi: reg size_ch h_chi h_chn m_ch h_chi_sl h_chn_sl  m_ch_sl size_lag i.r if a<60 & im<=3500 & hclust>5, robust cluster(hh1)






	xi: reg zw_ch h_chi h_chn m_ch  h_chi_at_7_18 h_chn_at_7_18 m_ch_at_7_18 h_chi_at_60 h_chn_at_60 m_ch_at_60 h_chi_sl h_chn_sl m_ch_sl h_chi_sl_at_7_18 m_ch_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60 m_ch_sl_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 zw_lag i.r if size_lag<=11 & a<60, robust cluster(hh1)


	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if a<=7 & im<5000, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag zwfa_lag i.r if a<=7 & im<5000, robust cluster(hh1)

		* this stuff works, (with only 200 observations but whatever)
	* makes sense if targeting particular areas!: DOESNT WORK WITH FIXED MOVE VARIABLE NOW
	xi: reg zhfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag  zhfa_lag i.r if a<=10 & im<=3500 & hclust>10, robust cluster(hh1)
	xi: reg zhfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if a<=10 & im<=3500 & hclust>10, robust cluster(hh1)

	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if a<=10 & im<=3500 & hclust>10, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag zwfa_lag i.r if a<=10 & im<=3500 & hclust>10, robust cluster(hh1)

	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag i.r if im<=3500 & hclust>5, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn m_ch h_chi_sl h_chn_sl m_ch_sl size_lag zwfa_lag i.r if im<=3500 & hclust>5, robust cluster(hh1)


		
	xi: reg zhfa_ch h_chi h_chn h_chi_sl h_chn_sl move move_size_lag size_lag  zhfa_lag i.r if a<=10 & im<=3500 & hclust>0, robust cluster(hh1)
	xi: reg zhfa_ch h_chi h_chn h_chi_sl h_chn_sl move move_size_lag size_lag i.r if a<=10 & im<=3500 & hclust>0, robust cluster(hh1)

	xi: reg zwfa_ch h_chi h_chn h_chi_sl h_chn_sl move move_size_lag size_lag i.r if a<=10 & im<=3500 & hclust>0, robust cluster(hh1)
	xi: reg zwfa_ch h_chi h_chn h_chi_sl h_chn_sl move move_size_lag size_lag zwfa_lag i.r if a<=10 & im<=3500 & hclust>0, robust cluster(hh1)

