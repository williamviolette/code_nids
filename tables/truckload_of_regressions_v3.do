

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

	***********************************
	*** WHICH KIDS ARE LEFT BEHIND! ***
	***********************************

	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
	
	g i=1
	egen size_a=sum(i), by(hhid)
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd

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
	
	tab rid noch
	tab noch r
	
	replace r_relhead=. if r_relhead<0
	
	tab noch r
*	hist a, by(noch)
	
	tab a noch
	tab a size_lag if noch==1
	
	g son_id=(r_relhead==4 & a<=16)
	g foster_id=(r_relhead>4 & r_relhead<=7 & a<=16)
	g nep_oth_id=((r_relhead==19 | r_relhead==25 | r_relhead==26) & a<=16)
	g granchild_id=(r_relhead==13 & a<=16)
	
	sort pid r
	by pid: g lo=noch[_n-1]
	replace lo=0 if lo==.
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_ch*size_lag i.lo*size_lag size_lag i.r if a<=10, robust cluster(hh1)
	}
	
	xtset hhid
	
	g oth=(foster_id==1 | nep_oth_id==1)

	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a<=16 & r<3, fe robust
	}
	
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a>2 & a<=18 & r<3, fe robust
	}
	** infants
	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res son_id granchild_id oth {
	xtreg `var' noch a sex if a<=7 & r<3, fe robust
	}



	*** HEALTHIER KIDS ARE LESS LIKELY TO GO!
		* relationship to hoh is helpful too!

	xtreg noch c_health c_ill c_ill_ser a sex m_res f_res i.r if hch==1 & a<=18 & r<3, robust cluster(hhid)
	xtreg noch c_health c_ill c_ill_ser a sex m_res f_res i.r if a<=18 & r<3, robust cluster(hhid)

		* key: here we see how selection works across hh's (father resident helps your chances)



	********************************
	*** WHICH KIDS ARE ADDED ON! ***
	********************************
	
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000
	replace size_lag=. if size_lag>11
	
	duplicates tag hh1 hhid, g(hh1d)
	replace hh1d=hh1d+1
	
	g i=1
	egen size_a=sum(i), by(hhid)
	quietly tab r, g(r_idd)
	egen r1_idd=max(r_idd1), by(pid)
	egen r2_idd=max(r_idd2), by(pid)
	egen r3_idd=max(r_idd3), by(pid)
	replace r1_idd=100 if r1_idd==1
	replace r2_idd=20 if r2_idd==1
	replace r3_idd=3 if r3_idd==1
	g rid=r1_idd+r2_idd+r3_idd
	
	egen h_ch_hh=max(h_ch), by(hhid)
	g join=(h_ch_hh==1 & (h_ch==0 | h_ch==.))
	
	tab rid join
	egen sj=sum(join), by(hhid)
	g j_size=sj/size
	tab j_size if j_size>0
	
*	hist a if h_ch_hh==1, by(join)
	tab a join if h_ch_hh==1
	
	g h_chnj=h_ch
	replace h_chnj=0 if j_size>0 & j_size<.
	g h_chjo=h_ch
	replace h_chjo=0 if j_size==0 | (j_size>.3 & j_size<.)
	g h_chji=h_ch
	replace h_chji=0 if j_size<.3
	
	sort pid r
	by pid: g c_health_ch=c_health[_n]-c_health[_n-1]
	by pid: g c_ill_ch=c_ill[_n]-c_ill[_n-1]
	
	g s4=size_lag<=4
	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch h_chnj h_chjo h_chji size_lag i.r if a<=10, robust cluster(hh1)
	}

		* are the gains concentrated among the sick kids that join the household ???
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_chnj*i.c_ill_ser i.h_chjo*i.c_ill_ser i.h_chji*i.c_ill_ser size_lag i.r if a<=10, robust cluster(hh1)
	}

	
	foreach var of varlist c_health c_ill zwfa zhfa {
	xi: reg `var'_ch i.h_chnj*i.s4 i.h_chjo*i.s4 i.h_chji*i.s4 i.r if a<=10, robust cluster(hh1)
	}
	


	xtset hhid
	foreach var of varlist a sex  zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xi: xtreg `var' i.join*j_size if a>2 & a<=16 & r>1 & h_ch_hh==1, fe robust
	}
	** marginal child is sicker..
	
	*** use the panel data!
		
	

	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xtreg `var' join a sex if a>2 & a<=18 & r>1, fe robust
	}

	foreach var of varlist zwfa zhfa c_health c_ill c_ill_ser m_res f_res {
	xtreg `var' join if a>2 & a<=18 & r>1, fe robust
	}
	
	
	
	
	*** BIG ANALYSIS ***
	
	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000

	replace cres=0 if cres==. & cnres>0 & cnres<.
	replace cnres=0 if cnres==. & cres>0 & cres<.
	
	g cper=cres/(cres+cnres)
	
	g tot=cres+cnres

	egen fres=max(f_res), by(hhid)
	egen mres=max(m_res), by(hhid)
	
	g c0_2id=(a<=2 & a>=0)
	g c3_10id=(a<=10 & a>=3)
	g c11_18id=(a<=18 & a>=11)
	egen c0_2=sum(c0_2id), by(hhid)
	egen c3_10=sum(c3_10id), by(hhid)
	egen c11_18=sum(c11_18id), by(hhid)
	
	replace size_lag=. if size_lag>11
	
	foreach var of varlist cr cn cry cny crvy cnvy {
	replace `var'=. if sex==1
	}
	g tc=cr+cn
	egen crm=max(cr), by(hhid)
	egen cnm=max(cn), by(hhid)
	
	g son_id=(r_relhead>=4 & r_relhead<=7 & a<=16)
	g nep_oth_id=((r_relhead==19 | r_relhead==25 | r_relhead==26) & a<=16)
	g granchild_id=(r_relhead==13 & a<=16)
	
	egen son=sum(son_id), by(hhid)
	egen nep_oth=sum(nep_oth_id), by(hhid)
	egen granchild=sum(granchild_id), by(hhid)
	
	g gsid=(a>=55 & a<.)
	egen gs=sum(gsid), by(hhid)
	
	foreach var of varlist gs c0_2 c3_10 c11_18 cr cn cry cny crvy cnvy f_res m_res fres mres son nep_oth granchild hoh_a son_id granchild_id tc tot {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach v in  cr cn cry cny crvy cnvy m_res f_res fres mres {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
		* part of it is sending biological children away
	
	** how is kid's relationship to parents changing??
	xi: reg son_id_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg granchild_id_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
		
		** change in hoh!
	xi: reg old_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)
	xi: reg gs_ch i.h_ch*size_lag i.r if a<=18, robust cluster(hh1)

	

	
	foreach v in  c0_2 c3_10 c11_18 {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
	
	** ** now look at those left out:
	g h_chr2=h_ch if r==2
	g h_chr3=h_ch if r==3
	
	egen rdp_hh1r2=max(h_chr2), by(hh1)
	egen rdp_hh1r3=max(h_chr3), by(hh1)
	
	egen rdp_pidr2=max(h_chr2), by(pid)
	egen rdp_pidr3=max(h_chr3), by(pid)
	
	g lor2=(rdp_hh1r2==1 & rdp_pidr2==0 & r==2)
	g lor3=(rdp_hh1r3==1 & rdp_pidr3==0 & rdp_pidr2==0 & r==3)
	
	g lo=1 if lor2==1 | lor3==1
	replace lo=0 if lo!=1 & r>=2
	g lo1=lo
	sort pid r
	by pid: replace lo1=1 if lo1[_n-1]==1
	replace lo1=0 if r==1 
	
	g inf=(h_dwltyp==7 | h_dwltyp==8)

	xtset pid
	xi: xtreg e lo1 i.r, fe robust cluster(hh1)
	xi: xtreg inf lo1 i.r, fe robust cluster(hh1)
	xi: xtreg size lo1 i.r, fe robust cluster(hh1)
	xi: xtreg ue lo1 i.r, fe robust cluster(hh1)
	xi: xtreg inc lo1 i.r, fe robust cluster(hh1)
	xi: xtreg food lo1 i.r, fe robust cluster(hh1)

	
		
	** Log the expenditures
	g exp1=non_food if non_food!=.
	replace exp1=exp1+food if food!=.
	replace exp1=food if food!=. & exp1==.
	replace exp1=exp1+public if public!=.
	replace exp1=public if public!=. & exp1==.
	
	** LOOK AT EXPENDITURE PER CAP
	
	g h_s=health_exp
	replace h_s=health_exp+sch_spending if sch_spending!=.
	replace h_s=sch_spending if h_s==. & sch_spending!=.
	
	foreach var of varlist services non_food food public exp1 health_exp sch_spending h_s {
	g `var'_ln=ln(`var')
	g `var'_lnp=`var'_ln/size
	sort pid r
	by pid: g `var'_ln_ch=`var'_ln[_n]-`var'_ln[_n-1]
	by pid: g `var'_lnp_ch=`var'_lnp[_n]-`var'_lnp[_n-1]
	}
	g ac=adult/child
	sort pid r
	by pid: g ac_ch=ac[_n]-ac[_n-1]
	g size4=size_lag>4
	g size_lag4=size_lag*size4
	replace size_lag=. if size_lag>11	

	
		* EXPENDITURE MECHANISMS *
	foreach var of varlist *_ln {
	xi: reg `var'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	* expenditure itself doesnt seem to change much (except for food)
	 * so 
	
	

	*** now figure out size
	
	xi: reg size_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag>=3 & size_lag<=6, robust cluster(hh1)
	** even some weak evidence of adjustment
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag<=6, robust cluster(hh1)
	xi: reg size_ch i.h_ch*size_lag i.r if size_lag>=4, robust cluster(hh1)
		* gradient isn't really there below, but there is a size increase, which is nice
	
	xi: reg size_ch i.h_ch*i.size_lag i.r, robust cluster(hh1)

	xi: reg size_ch i.h_ch*size_lag size4 i.h_ch*size_lag4 i.r, robust cluster(hh1)
	*** pretty consistent across groups (small getting larger?)
	
	foreach v in size adult_men adult_women adult child old ac {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
	
		* KEY REGRESSION TO LOOK AT *
	foreach v in size adult_men adult_women adult child old ac {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	

	xi: reg fs_ch i.h_ch*size_lag i.r if fs_ch>-.5 & fs_ch<.5, robust cluster(hh1)
	
	
	
	
	*** EMOTIONAL WELL BEING IS KINDA COOL: SOME PREDICTED DIRECTIONS
	foreach var of varlist a_em* {
	replace `var'=. if `var'<0
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach var of varlist a_em* {
	xi: reg `var'_ch i.h_ch*size_lag i.r if size_lag<15, robust cluster(hh1)
	}
	
	
	
	
	** make change variables
	
	foreach v in h_empl h_rent h_grn h_prvpen h_tinc e ue c_failed c_absent zwfa zhfa zbmi rooms size own flush piped adult_men adult_women adult old child inc_l inc_r inc fwag owner walls_b roof_cor wath toih concrete  sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	by pid: g `v'_ch=`v'[_n]-`v'[_n-1]
	by pid: g `v'_lag=`v'[_n-1]
	}
	foreach v in inc inc_l inc_r fwag sch_spending health_exp non_food public food food_imp services water_exp ele_exp water_sp ele_sp mun_sp lev_sp carbs meat veggies fats baby eat_out {
	g `v'p=`v'/size
	sort pid r
	by pid: g `v'_pch=`v'p[_n]-`v'p[_n-1]
	}
	
	
		
	
	
	
	
	
	
	
	
	
