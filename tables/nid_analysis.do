


clear all
set mem 4g
set maxvar 10000

cd "${rawdata}"





cap program drop omit
program define omit
  local original ${`1'}
  local temp1 `0'
  local temp2 `1'
  local except: list temp1 - temp2
  local modified
  foreach e of local except{
   local modified = " `modified' o.`e'"
  }
  local new: list original - except
  local new " `modified' `new'"
  global `1' `new'
end

cap program drop takefromglobal
program define takefromglobal
  local original ${`1'}
  local temp1 `0'
  local temp2 `1'
  local except: list temp1 - temp2
  local new: list original - except
  global `1' `new'
end




use clean/data_analysis/house_treat_regs_inc_exp, clear


	g mar = a_mar==1
	replace mar = 1 if a_marstt==1
	replace mar=. if a<16

	g mo = a_mar>=1 & a_mar<.
	replace mo = 1 if a_marstt>=1 &  a_marstt<.
	replace mo=. if a<16

	*keep rdp pid r size rooms move prov child  ///
	*adult_men adult_women wath rooms toih mktv  ///
	*zhfa zwfa zbmi zwfh ///

	sort pid r
	by pid: replace rdp=rdp[_n-1] if rdp==.

	sort pid r
	by pid: g hco = rdp[_n]-rdp[_n-1]
	replace hco = 0 if rdp==.

	g crowd = size/rooms
	by pid: g crowd_ch = crowd[_n]-crowd[_n-1]
	
	egen min_hco = min(hco), by(pid)
	drop if min_hco==-1




g rem = hhimprent_inc>0 & hhimprent_inc<.
g own_other = h_ownoth==1


	g hco_m = hco==1 & move==1
	g hco_s = hco==1 & move==0
	g moved = hco==0 & move==1

	** graph set up **
	g H_id = 1 if hco_m==1
	replace H_id = 2 if hco_s==1
	replace H_id = 3 if moved==1
	egen H=min(H_id), by(pid)

	foreach r in hco_s hco_m moved  {
	g r_ch_`r' = r if `r'==1
	egen R_`r' = min(r_ch_`r'), by(pid)
	}
	g T = r-R_hco_m        if H==1
	replace T = r-R_hco_s  if H==2 
	replace T = r-R_moved    if H==3


	sort pid r
	by pid: g a_lag = a[_n-1]
	by pid: g mar_lag = mar[_n-1]
	by pid: g mo_lag = mo[_n-1]


	hist mar_lag if owner==1 & a_lag<=25,  by(hco_s) 

	hist mo_lag if owner==1, by(hco_m hco_s) discrete

	hist a_lag if owner==1 & a_lag<=50 & a_lag>=15, by(hco_m hco_s) discrete




	sort pid r
	by pid: g pN=_N


	global coef ""

	forvalues r=1/3 {
		sum T, detail
		forvalues z=`=r(min)'/`=r(max)' {
		if `z'<0 {
			local z1 "`=abs(`z')'"
			cap drop HH_`r'_MIN_`z1'
			g HH_`r'_MIN_`z1' = H==`r' & T==`z'
			global coef " ${coef} HH_`r'_MIN_`z1' "
		}
		else {
			cap drop HH_`r'_PLUS_`z' 
			g HH_`r'_PLUS_`z' = H==`r' & T==`z'
			global coef " ${coef} HH_`r'_PLUS_`z' "
		}
		}
	}
	
	omit coef HH_1_MIN_1 HH_2_MIN_1 HH_3_MIN_1


	egen prov1=group(prov)
	egen rp=group(prov1 r)



egen min_r = min(r), by(pid)
g S_id = size if min_r==r
egen S1  = min(S_id), by(pid)

g S = 0 if S1<=4
replace S=1 if S1>=5 & S1<=15

	global coefS ""

	forvalues r=1/3 {
		sum T, detail
		forvalues z=`=r(min)'/`=r(max)' {
			forvalues s=0/1 {
				if `z'<0 {
					local z1 "`=abs(`z')'"
					cap drop HH_`r'_MIN_`z1'_`s'
					g HH_`r'_MIN_`z1'_`s' = H==`r' & T==`z' & S==`s'
					global coefS " ${coefS} HH_`r'_MIN_`z1'_`s'"
				}
				else {
					cap drop HH_`r'_PLU_`z'_`s'
					g HH_`r'_PLU_`z'_`s' = H==`r' & T==`z' & S==`s'
					global coefS " ${coefS} HH_`r'_PLU_`z'_`s' "
				}
			}
		}
	}
	
	omit coefS HH_1_MIN_1_0 HH_2_MIN_1_0 HH_3_MIN_1_0  HH_1_MIN_1_1 HH_2_MIN_1_1 HH_3_MIN_1_1



cap prog drop rgraphS
prog define rgraphS
	preserve
		quietly areg `1' $coefS `2' `3' , absorb(pid) cluster(pid) r

	  parmest, fast
	  replace parm=substr(parm,3,.) if estimate==0
	  g T = substr(parm,-3,1)
	  g S = substr(parm,-1,1)
	  g H = substr(parm,4,1)
	  keep if  substr(parm,1,2)=="HH"

	  destring T H S, replace force
	  replace T = T*-1 if substr(parm,6,1)=="M"
	  sort H T

	  tw ///
	    (rcap max95 min95 T if H==1 & S==0, lc(gs7) lw(thin) ) ||  ///
	    (connected estimate T if H==1 & S==0, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(gs0) lp(none) lw(medium)) || ///
	     (rcap max95 min95 T if H==2 & S==0, lc(blue) lw(thin) ) || ///
	    (connected estimate T if H==2 & S==0, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(blue) lp(none) lw(medium)) || ///
	      (rcap max95 min95 T if H==3 & S==0, lc(red) lw(thin) ) || ///
	    (connected estimate T if H==3 & S==0, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(red) lp(none) lw(medium)) || ///
	   	(rcap max95 min95 T if H==1 & S==1, lc(gs7) lw(thin) ) ||  ///
	    (connected estimate T if H==1 & S==1, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(gs0) lp(dash) lw(medium)) || ///
	     (rcap max95 min95 T if H==2 & S==1, lc(blue) lw(thin) ) || ///
	    (connected estimate T if H==2 & S==1, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(blue) lp(dash) lw(medium)) || ///
	      (rcap max95 min95 T if H==3 & S==1, lc(red) lw(thin) ) || ///
	    (connected estimate T if H==3 & S==1, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(red) lp(dash) lw(medium)),  ///
	    legend(order(2 "RDP Movers Small" 4 "RDP NoN-Movers Small" 6 "Movers Small" ///
	    8 "RDP Movers Big" 10 "RDP NoN-Movers Big" 12 "Movers Big" ) symx(6) col(3))
	restore
end





cap prog drop rgraph
prog define rgraph
	preserve
		quietly areg `1' $coef `2' `3' , absorb(pid) cluster(pid) r

	  parmest, fast
	  replace parm=substr(parm,3,.) if estimate==0
	  g T = substr(parm,-1,1)
	  g H = substr(parm,4,1)
	  keep if  substr(parm,1,2)=="HH"

	  destring T H, replace force
	  replace T = T*-1 if substr(parm,6,1)=="M"
	  sort H T

	  tw ///
	    (rcap max95 min95 T if H==1, lc(gs7) lw(thin) ) ||  ///
	    (connected estimate T if H==1, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(gs0) lp(none) lw(medium)) || ///
	     (rcap max95 min95 T if H==2, lc(blue) lw(thin) ) || ///
	    (connected estimate T if H==2, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(blue) lp(none) lw(medium)) || ///
	      (rcap max95 min95 T if H==3, lc(red) lw(thin) ) || ///
	    (connected estimate T if H==3, ms(o) msiz(small) mlc(gs0) mfc(gs0) lc(red) lp(none) lw(medium)),  ///
	    legend(order(2 "RDP Movers" 4 "RDP NoN-Movers" 6 "Movers" ) symx(6) col(1))
	restore
end



g MDB1 = hhmdbdc2011
replace MDB1 = gc_mdbdc2011 if r==2  | r==3
replace MDB1 = mdb  		if r==4  | r==5



* adjusted income
foreach var of varlist  inc_l inc_r inc sch_spending health_exp non_food public food food_imp services water_exp ele_exp {
	quietly reg `var' i.child i.adult_men i.adult_women i.size
	cap drop adj_`var'
	quietly predict adj_`var', residuals
}


*** NOT HAPPY ABOUT IT
rgraph n_stay "i.r"

***** n_trust

*** WAY OFF THE CHARTS! 

* h_nbthmf h_freqdomvio h_freqvio h_freqgang h_freqmdr h_freqdrug


*** HERE IS THE SERIOUSLY DEPRESSING STORY !


rgraph h_freqvio "i.r if h_freqvio>0"

rgraph h_freqdomvio  "i.r if   h_freqdomvio>0"

rgraph h_nbthmf  "i.r if  h_nbthmf>0"

rgraph h_freqgang  "i.r if  h_freqgang>0"

rgraph h_freqmdr  "i.r if  h_freqmdr>0"

rgraph h_freqdrug  "i.r if h_freqdrug>0"

rgraph n_stay "i.r"



*** BASICALLY NOTHING HERE!!

rgraph a_emobth  "i.r if a_emobth>0"
	* good news (no news..)

rgraph a_emomnd  "i.r if a_emomnd>0"
	* no news

rgraph a_emodep " i.r if a_emodep>0 "
	* no news

rgraph a_emoeff " i.r if a_emoeff>0"
	* improvement

rgraph a_emohope " i.r if a_emohope>0 "
	* nothing

rgraph a_emofear " i.r if a_emofear>0"
	* nothing

rgraph a_emoslp " i.r if a_emoslp>0"
	* nothing

rgraph a_emohap " i.r if a_emohap>0"
	* yes.. and less....

rgraph a_emolone "i.r if  a_emolone>0"
	* yes.. and bad...






rgraph h_nbhlp "i.r if h_nbhlp>0"


rgraph veggies "i.r"
rgraph fats "i.r"

rgraph eat_out "i.r"





* g hungry = h_hngrchld>0
* rgraph hungry " i.r "


*** nothing ***
rgraph improve " i.r "
rgraph improve_v "i.r if improve_v<=100000"


rgraph e "i.r"

rgraph toilet_share " i.r "



rgraph own_other " i.r "






rgraphS rem "i.r"



rgraphS size "i.r"

rgraphS child "i.r"

rgraphS adult_women "i.r"


rgraphS zbmi "i.r" " i.a if a<=15 "

rgraphS zhfa "i.r" " i.a if a<=15 "

rgraphS zhfa "i.r" " i.a if a<=15 "


rgraphS c_ill "i.r" " i.a if a<=15 "

rgraph c_ill "i.r" " i.a if a<=15 "

rgraph c_ill_ser "i.r" " i.a if a<=15 "

rgraph c_failed "i.r" " i.a if a<=15 "


rgraph  tb  "i.r" 

*** DEFINITE DROP !! ***
rgraph s_quin "i.r"

rgraph s_att_c "i.r"


rgraph concrete "i.r"

rgraph max_age "i.r"


*** INCOME STUFF !! *** not a lot here unfort...
rgraph adj_inc_l "i.r"
rgraph adj_inc_r "i.r"
rgraph adj_inc "i.r"

rgraph adj_sch_spending "i.r"

rgraph adj_food "i.r"
rgraph adj_public "i.r"

rgraph c_failed "i.r"

*** STARK CONTRAST HERE !!!!
rgraph water_exp "i.r"
rgraph ele_exp "i.r"

rgraph sch_spending "i.r"

**** MASSIVELY STARK CONTRAST HERE !! ****
rgraph child "i.r" 

rgraph old_men "i.r"
rgraph old_women "i.r"


*** wicked sharp
rgraph wath "i.rp"
rgraph toih "i.rp"

*** pre-trend... and REBOUNDS
rgraph size "i.r" "if size<=14" 
*** pre-trend, big REBOUND!
rgraph crowd "i.r"  "if crowd<=4"


*** smooth for rdp, huge jump for movers
rgraph  e "i.r" 


*** nothing for health
rgraph a_health "i.r"


rgraph  ue "i.r" 

rgraph  zbmi "i.r" " i.a if a<=12 "
rgraph  zhfa "i.r" " i.a if a<=12 "
rgraph  zwfa "i.r" " i.a if a<=12 "
* rgraph  zwfh

rgraph rooms "if rooms>1 & rooms<10"

rgraph mktv "if mktv>1000 & mktv<600000"

rgraph child
rgraph adult_men 
rgraph adult_women




/*


cap prog drop Tevent
prog define Tevent
	preserve
		`2'
		sort T H
		cap drop Tn
		by T H: g Tn=_n
		cap drop `1'_t
		egen `1'_t = mean(`1'), by(T H)
		scatter `1'_t T if Tn==1 & H==1, color(blue) || ///
		scatter `1'_t T if Tn==1 & H==2, color(red)  || ///
		scatter `1'_t T if Tn==1 & H==3, color(black) 
	restore
end









cap prog drop Tevent
prog define Tevent
	preserve
		`2'
		sort T H
		cap drop Tn
		by T H: g Tn=_n
		cap drop `1'_t
		egen `1'_t = mean(`1'), by(T H)
		scatter `1'_t T if Tn==1 & H==1, color(blue) || ///
		scatter `1'_t T if Tn==1 & H==2, color(red)  || ///
		scatter `1'_t T if Tn==1 & H==3, color(black) 
	restore
end


Tevent size_trim "keep if pN==5"





	g hco_s = hco==1 & move==0
	g hco_m = hco==1 & move==1
	g moved = hco==0 & move==1


	g rdp_s = rdp==1 & move==0
	g rdp_m = rdp==1 & move==1
	g r_moved = rdp==0 & move==1


	egen prov1=group(prov)
	egen rp = group(r prov1)




	areg rooms r_moved  rdp_m  rdp_s i.r , a(pid) r cluster(pid)
	areg rooms_ch moved  hco_m hco_s , absorb(rp) cluster(rp) r

	areg size r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg size_ch  moved  hco_m hco_s  , absorb(rp) cluster(rp) r
	
	areg crowd r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg crowd_ch moved  hco_m hco_s if crowd_ch>-4 & crowd_ch<4  , absorb(rp) cluster(rp) r



	areg child r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg child_ch moved  hco_m hco_s  , absorb(rp) cluster(rp) r

	areg adult_men r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg adult_men_ch moved  hco_m hco_s  , absorb(rp) cluster(rp) r

	areg adult_women r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg adult_women_ch moved  hco_m hco_s  , absorb(rp) cluster(rp) r


	areg wath r_moved  rdp_m rdp_s  i.r , a(pid) r cluster(pid)
	areg wath_ch moved  hco_m hco_s  , absorb(rp) cluster(rp) r

	

* hist rooms if (hco_m==1 | moved==1) & rooms<=8, by(moved)

cap prog drop int_gen
prog define int_gen
cap drop moved_`1'
	g moved_`1' = moved*`1'
cap drop hco_m_`1'
	g hco_m_`1' = hco_m*`1'
cap drop hco_s_`1'
	g hco_s_`1' = hco_s*`1'
	global int_`1' = " moved_`1' hco_m_`1' hco_s_`1' "
end

g small_house = rooms_lag<3 
g big_house = rooms_lag>=6
g med_house = small_house==0 & big_house==0

int_gen small_house
int_gen big_house
int_gen med_house

g large_l = size_lag>=7 & size_lag<12
g small_l = size_lag<7

int_gen large_l
int_gen small_l



	 

	foreach var of varlist  non_food_ch food_imp_ch ue_ch e_ch {
		areg `var' $int_large_l $int_small_l large_l  if size_lag<12, absorb(rp) cluster(rp) r
	}



	foreach var of varlist child_ch adult_men_ch adult_women_ch { 
		areg `var' $int_large_l $int_small_l large_l  if size_lag<12, absorb(rp) cluster(rp) r	
	}


sort pid r

	*foreach var of varlist  inc_l_ch inc_r_ch inc_ch sch_spending_ch health_exp_ch non_food_ch public_ch food_ch food_imp_ch services_ch water_exp_ch ele_exp_ch {
	
	foreach var of varlist  inc_l inc_r inc sch_spending health_exp non_food public food food_imp services water_exp ele_exp {
		quietly reg `var' i.child i.adult_men i.adult_women 
		cap drop temp_`var'
		quietly predict temp_`var', residuals
		cap drop  `var'_ch_temp
		quietly by pid: g `var'_ch_temp = temp_`var'[_n]-temp_`var'[_n-1]
		*quietly sum `var'_ch_temp
		*quietly replace `var'_ch_temp = . if `var'_ch_temp<`=r(p1)'  | `var'_ch_temp>`=r(p99)'
		areg `var'_ch_temp $int_large_l $int_small_l large_l  if size_lag<12, absorb(rp) cluster(rp) r	
		drop temp_`var' 	`var'_ch_temp
	}


* walls_b_ch inc_l_ch inc_r_ch inc_ch sch_spending_ch health_exp_ch

global lag_set " size_ch  wath_ch toih_ch    "

global lag_set_t ""

foreach v in $lag_set {
	forvalues r=1/2 {
		cap drop `v'_ll`r' 
		by pid: g `v'_ll`r' = `v'[_n-`r']
		global lag_set_t = " ${lag_set_t} `v'_ll`r'  "
	}
}


areg hco size_lag $lag_set_t i.r  , absorb(rp) r

areg hco $lag_set_t i.r  , absorb(rp) cluster(rp) r




	foreach var of varlist wath_ch toih_ch walls_b_ch  {
		areg `var' moved  hco_m hco_s  , absorb(rp) cluster(rp) r
	}
	

	areg rooms_ch $int_large_l $int_small_l large_l small_l  if size_lag<12, absorb(rp) cluster(rp) r
	areg size_ch  $int_large_l $int_small_l large_l small_l  if size_lag<12 , absorb(rp) cluster(rp) r


	areg crowd_ch $int_large_l $int_small_l large_l small_l  if crowd_ch>-4 & crowd_ch<4 & size_lag<12 , absorb(rp) cluster(rp) r


	foreach var of varlist wath_ch toih_ch walls_b_ch  {
		areg `var' $int_large_l $int_small_l large_l  if size_lag<12, absorb(rp) cluster(rp) r
	}
	

	*** !!! NOTHING HERE !!! ***

	foreach v in zwfa zhfa zbmi {
		areg `v'_ch `v'_lag a sex $int_large_l $int_small_l large_l  if a<=12 &  size_lag<12, absorb(rp) cluster(rp) r
	}
	


	areg rooms_ch $int_small_house $int_med_house $int_big_house , absorb(rp) cluster(rp) r
	areg size_ch   $int_small_house $int_med_house $int_big_house  , absorb(rp) cluster(rp) r
	areg crowd_ch $int_small_house $int_med_house $int_big_house , absorb(rp) cluster(rp) r



	areg rooms_ch  hco_m moved  hco_s  , absorb(rp) cluster(rp) r
	areg size_ch   hco_m moved   hco_s  , absorb(rp) cluster(rp) r
	areg crowd_ch  hco_m hco_s  , absorb(rp) cluster(rp) r



	areg rooms_ch moved  hco_m hco_s , absorb(rp) cluster(rp) r
	areg size_ch  moved  hco_m hco_s  , absorb(rp) cluster(rp) r
	areg crowd_ch moved  hco_m hco_s  , absorb(rp) cluster(rp) r


*	areg rooms_ch hco moved hco_moved if hhgeo2011==2, absorb(rp) r
*	areg size_ch hco moved hco_moved  if hhgeo2011==2, absorb(rp) r

