
cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v2_d_p_ghs, clear

*** not a super tight income censor
keep if max_inc<15000

** GET RID OF THOSE THAT ARE IN RDP IN THE FIRST ROUND
g rdp_r1=rdp if r==1
egen rdp_r1_max=max(rdp_r1), by(pid)
replace rdp=0 if rdp_r1_max==1

egen min_h_ch=min(h_ch), by(pid)
replace rdp=. if min_h_ch==-1

** FOUR CRITERIA

* 1.) get rid of movers (FOR ALL RDP)

g move_h_ch=h_ch*move
egen move_h_ch_max=max(move_h_ch), by(pid)
replace rdp=. if move_h_ch_max==1

* 2.) value is in range for looking like rdp

g rdpt=rdp
replace rdpt=0 if (mktv<10000 | mktv>60000) & u==1
replace rdpt=0 if (mktv<10000 | mktv>30000) & u==0

sort pid r
by pid: g h_cht=rdpt[_n]-rdpt[_n-1]

egen min_h_cht=min(h_cht), by(pid)
replace rdpt=. if min_h_cht==-1

label variable rdpt "Value Censor"

* 3.) multiple people from the original household are tracked there

duplicates tag hh1 r hhid, g(dup)

*** NEW DEFINITION OF DUPLICATES
g sizer1_id=size if r==1
egen sizer1=max(sizer1_id), by(pid)

g rdpd=rdp
replace rdpd=0 if dup<1 & sizer1>2

sort pid r
by pid: g h_chd=rdpd[_n]-rdpd[_n-1]

egen min_h_chd=min(h_chd), by(pid)
replace rdpd=. if min_h_chd==-1

label variable rdpd "Over 2 Members Co-Move"

g rdpd1=rdp
replace rdpd1=0 if dup<2

label variable rdpd1 "Min 3 Members Co-Move"

sort pid r
by pid: g h_chd1=rdpd1[_n]-rdpd1[_n-1]

egen min_h_chd1=min(h_chd1), by(pid)
replace rdpd1=. if min_h_chd1==-1

* 4.) the HH owns the new dwelling

g rdpo=rdp
replace rdpo=0 if own_d==0

sort pid r
by pid: g h_cho=rdpo[_n]-rdpo[_n-1]

egen min_h_cho=min(h_cho), by(pid)
replace rdpo=. if min_h_cho==-1

label variable rdpo "HH Owns RDP"

**************************************
*** COMPILE THIS VARIABLE TOGETHER ***
**************************************

** FINAL VARIABLE **
g rdpf=.
replace rdpf=0 if rdpo==0 & rdpd==0 & rdpt==0
replace rdpf=1 if  rdpo==1 & rdpd==1 & rdpt==1

sort pid r
by pid: g h_chf=rdpf[_n]-rdpf[_n-1]

label variable rdpf "Final RDP"

** DUPLICATES AND OWNERSHIP VARIABLE  ( NO MARKET VALUE ADJUSTMENT )
g rdpdo=.
replace rdpdo=0 if rdpo==0 & rdpd==0 
replace rdpdo=1 if  rdpo==1 & rdpd==1 

sort pid r
by pid: g h_chdo=rdpdo[_n]-rdpdo[_n-1]

label variable rdpdo "Co-Move and Ownership"

**********************************
**  Deaton and Paxson Variables **
**********************************

g ag=h_agrlnd==1
egen m_ag=max(ag), by(hh1) 

g fd=h_fdtot if h_fdtot>0

drop h_fd*
drop h_ag*
drop rdp_v
drop health_visit

foreach var of varlist *spnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist *spn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen non_food=rowtotal( *spnyr *spn)

g te=fd+non_food

g w=fexp_imp/exp_imp
g w_alt=fd/te

g x_n=exp_imp/size
g x_n_alt=te/size
g ln_x_n=ln(x_n)
g ln_x_n_alt=ln(x_n_alt)

g n=size
g ln_n=ln(n)

egen e_tot=sum(e), by(hhid)
g e_n=e_tot/n

forvalues i=0(10)100 {
forvalues j=0/1 {
g k_`i'_`j'=(sex==`j' & a>=`i' & a<`i'+10)
egen si_`i'_`j'=sum(k_`i'_`j'), by(hhid)
replace si_`i'_`j'=si_`i'_`j'/n
drop k_`i'_`j'
}
}

** cleaning and generating demographic variables

egen m=group(mdb)

g rooms_r1=rooms if r==1
egen roomsr1=max(rooms_r1), by(pid)
replace roomsr1=. if roomsr1>7

g dwell_r1=dwell if r==1
egen dwellr1=max(dwell_r1), by(pid)

g own_r1=own if r==1
egen ownr1=max(own_r1), by(hh1)

replace rooms=. if rooms>8

*replace mktv=. if mktv>70000

egen hh_a_max=max(a), by(hhid)
g ya_a=a if a>17
egen hh_a_mean=mean(ya_a), by(hhid)

egen hh_a_m=mean(a), by(hhid)

egen hh_gender=mean(sex), by(hhid)

g hoh_gender_id=sex if relhh==1
egen hoh_gender=max(hoh_gender_id), by(hhid)

g hoh_a_id=a if relhh==1
egen hoh_a=max(hoh_a_id), by(hhid)

g adults=size-children
replace adults=. if adults<=0

g kids_per_adult=children/adults


foreach var of varlist h_nfalcspn h_nfcigspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen vice=rowtotal(h_nfalcspn h_nfcigspn)
g vice_per=vice/te


foreach var of varlist h_nfcerspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist  h_nfcerspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen ceremony=rowtotal(h_nfcerspnyr  h_nfcerspn )
g ceremony_per=ceremony/te


foreach var of varlist h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist h_nffrnspn h_nfdwlspn h_nfkitspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen h_prod=rowtotal(h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr h_nffrnspn h_nfdwlspn h_nfkitspn)
g h_prod_per=h_prod/te


foreach var of varlist h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen sch_spending=rowtotal( h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn )
g sch_per=sch_spending/te

g y=fexp_imp/n
g y_alt=fd/n

egen health_exp=rowtotal( h_nfhspspnyr h_nfdocspnyr h_nftradspnyr h_nfhomspn h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn )
g health_exp_per=health_exp/te

egen doc=rowtotal (h_nfdocspnyr h_nfdocspn)
rename h_nfmedspn med

** more non-food
foreach var of varlist h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn {
replace `var'=0 if `var'<=0 | `var'==.
}

foreach var of varlist h_nfbedspnyr h_nfmatspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

egen non_food_more=rowtotal ( h_nfbedspnyr h_nfmatspnyr h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn )


** more public
foreach var of varlist  h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen public_more= rowtotal (h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn)

** non-food
g non_fd= health_exp + sch_spending + vice + non_food_more
g public= h_prod + ceremony + public_more



*** DEFINE YOUNG CHILDREN ***
drop child
drop child_out
drop child_d

forvalues r=1/16 {
g c_a_`r'=a_bhdob_y`r'
replace c_a_`r'=2008-c_a_`r' if r==1
replace c_a_`r'=2010-c_a_`r' if r==2
replace c_a_`r'=2012-c_a_`r' if r==3
replace c_a_`r'=. if c_a_`r'<0
g c_res_`r'=(c_a_`r'<=15 & a_bhlive`r'==1 & a_bhali1==1)
g c_nres_`r'=(c_a_`r'<=15 & a_bhlive`r'==2 & a_bhali1==1)
g c_yres_`r'=(c_a_`r'<=5 & a_bhlive`r'==1 & a_bhali1==1)
g c_ynres_`r'=(c_a_`r'<=5 & a_bhlive`r'==2 & a_bhali1==1)
g c_ores_`r'=(c_a_`r'>5 & c_a_`r'<=15 & a_bhlive`r'==1 & a_bhali1==1)
g c_onres_`r'=(c_a_`r'>5 & c_a_`r'<=15 & a_bhlive`r'==2 & a_bhali1==1)
}

egen child=rowtotal(c_res_*)
egen child_out=rowtotal(c_nres_*)
g child_total=child+child_out

egen child_y=rowtotal(c_yres_*)
egen child_out_y=rowtotal(c_ynres_*)
g child_total_y=child_y+child_out_y

egen child_o=rowtotal(c_ores_*)
egen child_out_o=rowtotal(c_onres_*)
g child_total_o=child_o+child_out_o

foreach x in child child_out child_y child_out_y child_o child_out_o {
g `x'_d=(`x'>0 & `x'<.)
}


** CLEAN EDUCATION VARIABLES

replace c_edu=. if c_edu<0
replace fees=. if fees<0
replace lratio=. if lratio<0
label variable c_fees "value of fees"
g absent1=absent
replace absent1=0 if absent1==. & c_att==1
label variable absent1 "includes perfect attendance"

save mech_c_edu_v1, replace
