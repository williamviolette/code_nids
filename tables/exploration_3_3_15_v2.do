
clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"


program define main_tables
	quietly clean_data1
	quietly clean_data
	quietly first_stage
	quietly identification_test
	quietly main_spec
	quietly robustness
	quietly size_change_drivers
	quietly parent_present
	
end


program define main_spec

	use clean/data_analysis/regs_nate_tables_3_3, clear	
	quietly label_variables
	

	** robust to this rent_d	
	drop if rent_d==1 & h_ch==1

*	drop if move>0 & move<. & h_ch==1

	g hind=0
	replace hind=1 if h_chi==1
	replace hind=2 if h_chn==1	
*	tab cluster hind 

	egen hic=sum(h_chi), by(mdb)
	egen hin=sum(h_chn), by(mdb)	
	
	keep if hic>10 & hin>10
	
	* or keep clusters with atleast one of each!

	g m_ch=(move>=1 & move<.)
	replace m_ch=0 if h_ch==1
	g m_ch_sl=m_ch*size_lag
	
	g m_ch_at_7_18=m_ch*at_7_18
	g m_ch_at_60=m_ch*at_60
	
	g m_ch_sl_at_7_18=m_ch_sl*at_7_18
	g m_ch_sl_at_60=m_ch_sl*at_60
	
	* with movers
*	twoway lowess size size_lag if h_chn==1 & size<12 & size_lag<12, color(orange) || lowess size size_lag if h_chi==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_chi==1 & size<12 & size_lag<12, color(pink) || lowess size size_lag if m_ch==1 & size<12 & size_lag<12, color(red)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)")
*	twoway lowess size size_lag if h_chn==1 & size<12 & size_lag<12, color(orange) || lowess size size_lag if h_chi==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_chi==1 & size<12 & size_lag<12, color(pink)
	* 
*	twoway lowess rooms rooms_lag if h_chn==1 & rooms<10 & rooms_lag<10, color(orange) || lowess rooms rooms_lag if h_chi==0 & rooms<10 & rooms_lag<10, color(black)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)") || lowess rooms rooms_lag if h_chi==1 & rooms<10 & rooms_lag<10, color(pink) || lowess rooms rooms_lag if m_ch==1 & rooms<10 & rooms_lag<10, color(red)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)")
*	twoway lowess rooms rooms_lag if h_chn==1 & rooms<10 & rooms_lag<10, color(orange) || lowess rooms rooms_lag if h_chi==0 & rooms<10 & rooms_lag<10, color(black)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)") || lowess rooms rooms_lag if h_chi==1 & rooms<10 & rooms_lag<10, color(pink)

		* why would the decision to move be endogenous?!	
	
		* with move
	xi: reg size_ch h_chi h_chn m_ch h_chi_sl h_chn_sl  m_ch_sl size_lag i.r if size_lag<=11 & a<60 & im<=5000, robust cluster(hh1)
	outreg2 using clean/tables/size_change_move, nonotes tex(frag) keep(h_chi* h_chn* m_*) label replace nocons title("Main Specification")

	xi: reg size_ch h_chi h_chn h_chi_sl h_chn_sl size_lag  i.r if size_lag<=11 & a<60 & im<=5000, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n2, nonotes tex(frag) keep(h_chi* h_chn*) label replace nocons title("Main Specification")


	xi: reg size_ch h_ch  h_ch_sl size_lag  i.r if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n2, nonotes tex(frag) keep(h_ch  h_ch_sl) label append nocons title("Main Specification")

	xi: reg size_ch h_chi h_chn i.size_lag  i.r if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n2, nonotes tex(frag) keep(h_chi* h_chn*) label append nocons title("Main Specification")

	xi: reg size_ch h_chi h_chn i.size_lag  i.r if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/size_change_n2, nonotes tex(frag) keep(h_chi* h_chn*) label append nocons title("Main Specification")

		**** **** ****
			g a_zw_lag=a*zw_lag
			
	xi: reg zw_ch h_chi h_chn m_ch  h_chi_at_7_18 h_chn_at_7_18 m_ch_at_7_18 h_chi_at_60 h_chn_at_60 m_ch_at_60 h_chi_sl h_chn_sl m_ch_sl h_chi_sl_at_7_18 m_ch_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60 m_ch_sl_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 i.a*zw_lag i.sex*zw_lag i.r*zw_lag if size_lag<=11 & a<60 & im<=5000, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_move, nonotes tex(frag) keep(h_chi* h_chn* m_*) label replace nocons title("Main Specification")

	xi: reg zw_ch h_chi h_chn h_chi_at_7_18 h_chn_at_7_18  h_chi_at_60 h_chn_at_60  h_chi_sl h_chn_sl h_chi_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60  i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 i.a*zw_lag i.sex*zw_lag i.r*zw_lag if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_chi* h_chn*) label replace nocons title("Main Specification")

	xi: reg zw_ch h_chi h_chn h_chi_at_7_18 h_chn_at_7_18  h_chi_at_60 h_chn_at_60  h_chi_sl h_chn_sl h_chi_sl_at_7_18 h_chn_sl_at_7_18 h_chi_sl_at_60 h_chn_sl_at_60  size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 i.a*zw_lag i.a zw_lag sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_chi* h_chn*) label append nocons title("Main Specification")


	xi: reg zw_ch h_chi  h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=5 & a<=7, robust cluster(hh1)

	xi: reg zw_ch h_chi  h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag>5 & a<=7, robust cluster(hh1)


	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Children under 7")
	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=11 & a>7 & a<=18, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Young Adults 7-18")
	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Adults over 18")

			* don't gain a heck of a lot
	* split small medium and large

	xi: reg zw_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=5 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label replace nocons title("small large")addnote("Age", "Children under 7")
	xi: reg zw_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag>5 & size_lag<=7 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons  addnote("Age", "Children under 7")
	xi: reg zw_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag>8 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons  addnote("Age", "Children under 7")

	xi: reg size_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/main_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label replace nocons title("small large")addnote("Age", "Children under 7")
	xi: reg size_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag>5 & size_lag<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons  addnote("Age", "Children under 7")
	xi: reg size_ch h_chi h_chn size_lag a sex  i.a*zw_lag i.sex*zw_lag i.r*zw_lag  i.r if size_lag>8, robust cluster(hh1)
	outreg2 using clean/tables/main_sz_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons  addnote("Age", "Children under 7")
	
	tab move h_chi
	tab move h_chn
	
end



			
program define main_spec1
	use clean/data_analysis/regs_nate_tables_3_3, clear	
	quietly label_variables
	
	xi: reg zw_ch hil* his* hnl* hns*  size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.r if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_n1, nonotes tex(frag) keep( hil* his* hnl* hns* ) label replace nocons

	xi: reg zw_ch hil* his* hnl* hns*  size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 i.a*zw_lag i.sex*zw_lag i.r*zw_lag i.r if size_lag<=11 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_n1, nonotes tex(frag) keep( hil* his* hnl* hns* ) label append nocons

	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Children under 7")
	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex i.r if size_lag<=11 & a>7 & a<=18, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Young Adults 7-18")
	xi: reg zw_ch h_chi h_chi_sl  h_chn h_chn_sl size_lag a sex i.r if size_lag<=11 & a>18 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_n1, nonotes tex(frag) keep(h_chi h_chi_sl  h_chn h_chn_sl size_lag ) label append nocons title("Main Specification") addnote("Age", "Adults over 18")
	
	* * * hard to interpret * * *
end

	*********************************************************************
	****** IT IS TIME FOR EXPLORATION ***********************************
	*********************************************************************
	
program define exploration

	use clean/data_analysis/regs_nate_tables_3_3, clear	
	
		* do breakers rent in owned houses? *
	tab rent_d hns if own==1 & h_ch==1
			* there are 22 cases of renting and owning
	drop if (rent_d==1 | own==0) & h_ch==1
	
	tab own oid if h_ch==1
	tab own h_chn if h_ch==1
	
	g i=1
	egen size_hh1=sum(i), by(hh1 hhid)
	sort pid r
	by pid: g size_hh1_lag=size_hh1[_n-1]
	by pid: g size_hh1_ch=size_hh1[_n]-size_hh1[_n-1]

	twoway lowess size_hh1 size_hh1_lag if h_chn==1 & size<12 & size_lag<12, color(orange) || lowess size_hh1 size_hh1_lag if h_chi==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size_hh1 size_hh1_lag if h_chi==1 & size<12 & size_lag<12, color(pink)

	
*	twoway lowess size size_lag if h_chn==1 & size<12 & size_lag<12, color(orange) || lowess size size_lag if h_chi==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_chi==1 & size<12 & size_lag<12, color(pink) || lowess size size_lag if m_ch==1 & size<12 & size_lag<12, color(red)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)")
	twoway lowess size size_lag if h_chn==1 & size<12 & size_lag<12, color(orange) || lowess size size_lag if h_chi==0 & size<12 & size_lag<12, color(black)  title("Size t against Size t+1 for RDP and non-RDP (Lowess)") || lowess size size_lag if h_chi==1 & size<12 & size_lag<12, color(pink)
	graph export clean/tables/damning_1.pdf, replace as(pdf)
	* 
*	twoway lowess rooms rooms_lag if h_chn==1 & rooms<10 & rooms_lag<10, color(orange) || lowess rooms rooms_lag if h_chi==0 & rooms<10 & rooms_lag<10, color(black)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)") || lowess rooms rooms_lag if h_chi==1 & rooms<10 & rooms_lag<10, color(pink) || lowess rooms rooms_lag if m_ch==1 & rooms<10 & rooms_lag<10, color(red)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)")
	twoway lowess rooms rooms_lag if h_chn==1 & rooms<10 & rooms_lag<10, color(orange) || lowess rooms rooms_lag if h_chi==0 & rooms<10 & rooms_lag<10, color(black)  title("rooms t against rooms t+1 for RDP and non-RDP (Lowess)") || lowess rooms rooms_lag if h_chi==1 & rooms<10 & rooms_lag<10, color(pink)
	graph export clean/tables/damning_2.pdf, replace as(pdf)
*	hist size_lag, by(h_chi)
	
	egen x_h_ch=max(h_ch), by(hhid)
	g join=(x_h_ch==1 & h_ch!=1 & a>=3)
	egen sum_join=sum(join), by(hhid)
	
	g jid=(sum_join>0 & sum_join<.)
	
	tab jid h_chi if h_ch==1
	
	
	lowess jid size_lag if h_chi==1
	lowess sum_join size_lag if h_chi==1
	
	lowess sum_join child_lag if h_chi==1

	
	lowess sum_join size_lag if h_chi==1 & sum_join<8 & sum_join>0
	lowess sum_join rooms_lag if h_chi==1 & sum_join<8 & sum_join>0
	
			* 	
	lowess size_ch sum_join if h_chi==1
	lowess size_ch size_lag, by(h_chi)
	lowess size_ch rooms_lag, by(h_chi)
	
*	twoway lowess jid size_lag if h_chi==1 & size_lag<12 & sum_join<10
	
	g sl2=size_lag*size_lag
	
	sort pid r
	by pid: g hoh_a_lag=hoh_a[_n-1]
	by pid: g hoh_a_lag=hoh_a[_n-1]


	reg jid  child_lag i.r if h_chi==1, robust cluster(hh1)
	

	reg jid hoh_a_lag size_lag child_lag i.r if h_chi==1, robust cluster(hh1)

	reg size_ch hoh_a_lag size_lag child_lag i.r if h_chi==1, robust cluster(hh1)
		
	
	reg jid hoh_a_lag size_lag child_lag i.r if h_chi==1, robust cluster(hh1)
		

*	hist size_lag if h_chi==1, by (jid)	
	
	
	
	
	drop hio hil
		
	egen h_chnm=max(h_chn), by(hhid)
	egen h_chim=max(h_chi), by(hhid)
	
	* * * HOUSEHOLDS WITH BOTH SHIFTS * * *
	tab h_chnm h_chim
	tab a if h_chnm==1 & h_chim==1
			* way too few observations to get anywhere with health *
					* use this to back up size observations *
	
	g hio=h_chi
	replace hio=0 if ir<1
	g hil=h_chi
	replace hil=0 if ir>=1 & ir<.
		* more often than not, flux happens! * what does this say about size constraints?
	
	sort pid r
	by pid: g rent_lag=rent_d[_n-1]
	
	* why might families choose to break apart versus invite more people? *
	tab rent_lag hio
		* more likely to be a previous owner
	tab rent_lag hil
		* much more likely to be a previous owner
	tab rent_lag hns
				* actually: pretty even results across categories
	 
	* which type is more likely to leave people behind? *
	foreach v in hio hil hns {
	egen `v'_p=max(`v'), by(pid)
	egen `v'_h=max(`v'), by(hh1)
	}
	
	tab hio_h noch
	tab hil_h noch
	tab hns_h noch	
		* (fixed) hio leaves the most behind, then hns (as we would think) then hil: this is a story
			* of space constraints
		* other big one is hns


	* who are the others that are invited in? *	
	g hcode=0
	replace hcode=1 if hio==1
	replace hcode=2 if hil==1
	replace hcode=3 if hns==1
	replace hcode=4 if join==1
	
*	hist r_relhead, by(hcode)

	tab r_relhead if hio==1
	tab r_relhead if hil==1	
	tab r_relhead if hns==1
	tab r_relhead if join==1
	* more core family when stay together
	* more distant family when join later
	* join is very tangential
	
	* does the head of household always own the house? *
	* when doesn't the hoh own the house? *
	tab r_relhead oid if hio==1
	tab r_relhead oid if hil==1
	tab r_relhead oid if hns==1
	
	reg size_lag hio hil hns if size_lag<=11

	* within households that change, which ones break apart?
	sort pid r
	by pid: g adult_lag=adult[_n-1]
	
	reg hil size_lag child_lag adult_lag inc i.r if (hio==1 | hil==1), robust cluster(hh1)
	
	
	tab r_relhead oid if h_ch==1	
		* there are a good 30% of times where hoh doesn't own the house! *
				* can I predict who ultimately owns the house using the assignment rules? *
		
		
		*** JUNK AT THE BOTTOM ***
		* need to get rid of renters! *
	hist a if h_ch==1 & a<30, by(oid)	
	tab a h_ch if oid==1 & a<30	
	
	sort pid r
	by pid: g nochl=noch[_n-1]
	
	
	reg zwfa_ch h_chi h_chn nochl i.r size_lag if a<=7 , robust cluster(hh1)
	
	
	reg zw_ch h_chi h_chn nochl i.r if a<=7, robust cluster(hh1)
	reg zwfa_ch nochl i.r if a<=7, robust cluster(hh1)
	
	
	tab mh_chi
	tab mh_chn
		
	egen mh_chi=sum(h_chi), by(hhid)
	egen mh_chn=sum(h_chn), by(hhid)
	
	g new_size_id=(a>=3 & a<.)
	egen new_size=sum(new_size_id), by(hhid)
	g ir=mh_chi/new_size
	g nr=mh_chn/new_size
		
	
	egen oidhh=max(oid), by(hh1 hhid)
	egen oidhh1=max(oid1), by(hh1 hhid)
	

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



program define small_and_large_v1
	use clean/data_analysis/regs_nate_tables_3_3, clear	

	g a_zw_lag=a*zw_lag
	replace hil=1 if hil==0 & his==1
	replace hns=1 if hns==0 & hnl==1
	
	twoway lowess hil size_lag if size_lag<=11 || lowess hio size_lag if size_lag<=11 || lowess hns size_lag if size_lag<=11
	
	xi: reg size_ch hil hil_sl hio hio_sl hns hns_sl i.size_lag a sex i.r if size_lag<=11, robust cluster(hh1)

	xi: reg zw_ch hil hil_sl hio hio_sl hns hns_sl size_lag a sex i.r if size_lag<=11 & a<=7, robust cluster(hh1)


	xi: reg size_ch hil hio hns i.size_lag a sex i.r if size_lag<=11, robust cluster(hh1)


	xi: reg size_ch hil hio hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	xi: reg size_ch hil hio hns i.size_lag a sex i.r if size_lag>5 & size_lag<=11, robust cluster(hh1)


	* FIRST STAGE
	xi: reg size_ch hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label replace nocons title("First Stage: Small HH")
	xi: reg child_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg size_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons title("First Stage: Small HH")
	xi: reg child_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 	
	* REDUCED FORM
	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.r if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label replace nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a zw_lag i.r if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 a i.sex*zw_lag a_zw_lag i.r i.prov if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a*zw_lag i.sex*zw_lag i.r*zw_lag i.r i.prov if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

		* NOW LARGE *
	xi: reg size_ch hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label replace nocons title("First Stage: Small HH")
	xi: reg child_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg size_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons title("First Stage: Small HH")
	xi: reg child_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 	
	* REDUCED FORM
	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.r if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label replace nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a zw_lag i.r if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 a i.sex*zw_lag a_zw_lag i.r i.prov if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a*zw_lag i.sex*zw_lag i.r*zw_lag i.r i.prov if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

end
		* HIL IS HIS
	* SPLIT INTO SMALL AND LARGE *
	
program define small_and_large
		* FIRST SMALL*
	g a_zw_lag=a*zw_lag
	
	xi: reg size_ch hil his hio hnl hns i.size_lag a sex i.r if size_lag<=11, robust cluster(hh1)


	* FIRST STAGE
	xi: reg size_ch hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label replace nocons title("First Stage: Small HH")
	xi: reg child_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg size_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons title("First Stage: Small HH")
	xi: reg child_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag<=5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_s1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 	
	* REDUCED FORM
	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.r if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label replace nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a zw_lag i.r if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 a i.sex*zw_lag a_zw_lag i.r i.prov if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a*zw_lag i.sex*zw_lag i.r*zw_lag i.r i.prov if size_lag<=5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_sm1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

		* NOW LARGE *
	xi: reg size_ch hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label replace nocons title("First Stage: Small HH")
	xi: reg child_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch  hil his hio hnl hns i.size_lag a sex i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg size_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons title("First Stage: Small HH")
	xi: reg child_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 
	xi: reg adult_ch hil his hio hnl hns i.size_lag i.a*sex i.prov i.r if size_lag>5, robust cluster(hh1)
	outreg2 using clean/tables/first_stage_l1, nonotes tex(frag) keep(hil his hio hnl hns) label append nocons 	
	* REDUCED FORM
	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.r if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label replace nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a zw_lag i.r if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 a i.sex*zw_lag a_zw_lag i.r i.prov if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

	xi: reg zw_ch hil hil_at_7_18 hil_at_60 his his_at_7_18 his_at_60 hio hio_at_7_18 hio_at_60 hnl hnl_at_7_18 hnl_at_60 hns hns_at_7_18 hns_at_60 i.size_lag  at_sl_7_18  at_sl_60 at_7_18 at_60 sex i.a*zw_lag i.sex*zw_lag i.r*zw_lag i.r i.prov if size_lag>5 & a<60, robust cluster(hh1)
	outreg2 using clean/tables/main_spec1_l1, nonotes tex(frag) keep( hil* his* hio* hnl* hns* ) label append nocons

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


	*** look for housing treatment by mdb ***
	
	g inc_ad=pi_hhincome/adult	
	egen im=max(inc_ad), by(pid)
	
	g h_chi=h_ch
	replace h_chi=0 if oidhh==0
	g h_chn=h_ch
	replace h_chn=0 if oidhh==1
	
	tab noch
	sort pid r
	by pid: g nochl=noch[_n-1]
	
	tab size_ch h_chn
		* ok good: it does add up
	
	
	egen h_chimdb=sum(h_chi), by(mdb)

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
