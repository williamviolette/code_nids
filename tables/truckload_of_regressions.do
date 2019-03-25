

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

	use clean/data_analysis/house_treat_regs, clear
	egen inc_m=max(inc), by(pid)
	drop if inc_m>10000

	replace cres=0 if cres==. & cnres>0 & cnres<.
	replace cnres=0 if cnres==. & cres>0 & cres<.
	
	g cper=cres/(cres+cnres)
	
	g fnres_id=f_res==0
	egen fnres=max(fnres_id), by(hhid)
	g mnres_id=m_res==0
	egen mnres=max(mnres_id), by(hhid)
	
	g fres_id=f_res==1
	egen fres=max(fnres_id), by(hhid)
	g mres_id=m_res==1
	egen mres=max(mres_id), by(hhid)
	
	
	g c0_2id=(a<=2 & a>=0)
	g c3_10id=(a<=10 & a>=3)
	g c11_18id=(a<=18 & a>=11)
	egen c0_2=sum(c0_2id), by(hhid)
	egen c3_10=sum(c3_10id), by(hhid)
	egen c11_18=sum(c11_18id), by(hhid)
	
	replace size_lag=. if size_lag>11
	
	replace cr=. if sex==1
	replace cn=. if sex==1
	replace cry=. if sex==1
	replace cny=. if sex==1
	replace crvy=. if sex==1
	replace cnvy=. if sex==1
	
	g tc=cr+cn
	
	
	egen crm=max(cr), by(hhid)
	egen cnm=max(cn), by(hhid)
	
	foreach var of varlist c0_2 c3_10 c11_18 cr cn cry cny crvy cnvy f_res m_res {
	sort pid r
	by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
	}
	
	foreach v in  cr cn cry cny crvy cnvy m_res f_res {
	xi: reg `v'_ch i.h_ch*size_lag i.r, robust cluster(hh1)
	}	
		* part of it is sending biological children away
	
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
	
	
		
	
	
	
	
	
	
	
	
	
