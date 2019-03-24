

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


** CLEAN EDUCATION VARIABLES

replace c_edu=. if c_edu<0
replace fees=. if fees<0
replace lratio=. if lratio<0
label variable c_fees "value of fees"
g absent1=absent
replace absent1=0 if absent1==. & c_att==1
label variable absent1 "includes perfect attendance"

save mech_c_edu_v1, replace


***************************
*** HOUSEHOLD STRUCTURE ***
***************************

use mech_c_edu_v1, clear

xtset pid
egen max_age=max(a), by(pid)

** SEX OF HOH **
* hoh_gender

** AGE OF HOH **
* hoh_a

** MULTI-GENERATIONAL **
g gpar_id=(a>60 & a<.)
g par_id=(a<=60 & a>30)
egen gpar=max(gpar_id), by(hhid)
egen par=max(par_id), by(hhid)

g multi=(gpar==1 & par==1)

** RELATIONSHIP TO HOH **
g par_hoh=relhh==4
g gpar_hoh=(relhh==13 | relhh==22)
g unc_hoh=relhh==19
g bro_hoh=relhh==12
g step_hoh=(relhh>=5 & relhh<=7)
g absent_hoh=relhh==2

g other_hoh=(relhh==25 | relhh==26)

tab relhh rdp if max_age<10

** MULTI GENERATION!!!


xi: xtreg par_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg par_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust

xi: xtreg gpar_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg gpar_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust




xi: xtreg other_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg other_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust



** SPLIT: CHILD OUT **
egen max_child_out=max(child_out), by(hhid)
g split=(max_child_out>0 & max_child_out<.)

** children, adults **

** effect on size across these sources of heterogeneity
global structure1 "multi gpar par par_hoh gpar_hoh unc_hoh bro_hoh split"

global structure

foreach l in structure {
quietly xi: xtreg size rdp, fe cluster(hh1) robust
outreg2 using `l',  label replace nocons keep(rdp)
foreach o in $`l' {
foreach var in rdp rdpd rdpt rdpo {
quietly xi: xtreg `o' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `l',  label append nocons keep(`var')
quietly xi: xtreg `o' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `l',  label append nocons keep(`var')
}
}
}

** IF PEOPLE ARENT LIVING WITH THEIR FAMILIES WHO ARE THE LIVING WITH?












use mech_c_edu_v1, clear

*** does the new house change the relationship to head of household?

egen max_age=max(a), by(pid)

g par_hoh=relhh==4
g gpar_hoh=(relhh==13 | relhh==22)
g unc_hoh=relhh==19
g bro_hoh=relhh==12


global rel "par_hoh gpar_hoh unc_hoh bro_hoh"

xtset pid


foreach o in $rel {
xi: xtreg `o' rdp i.prov*i.r if u==1 & max_age<10, fe robust cluster(hh1)
}



foreach o in $rel {
xi: xtreg `o' rdp i.prov*i.r if u==1 & max_age<10, fe robust cluster(hh1)
xi: xtreg `o' rdp i.prov*i.r if u==0 & max_age<10, fe robust cluster(hh1)
}

** WHO WAS THE PREVIOUS HOH??






use mech_c_edu_v1, clear 

global kids_health "c_ill weight c_health c_resp check_up c_ill_ser c_doc"

global kids_edu "c_edu c_edu1 c_failed c_repeat c_att absent absent1 fees c_fees lratio sch_d"

g kids_rooms=children/rooms
g adults_rooms=adults/rooms
g a_2=a*a
egen max_age=max(a), by(pid)

*** w = ln(x_n) + ln(n) + sum(n_k/n) + controls + error

xtset pid

** a.) Cross Sectional and Panel
quietly xi: reg c_edu kids_rooms adults_rooms children adults a a_2 sex u e_n i.prov si_* if max_age<18 & max_age>6, cluster(hhid) robust
outreg2 using kids_edu_ols_fe, excel label replace nocons
foreach o in $kids_edu {
quietly xi: reg `o' kids_rooms adults_rooms children adults i.a a_2 sex u e_n i.prov i.r si_* if max_age<18 & max_age>6, cluster(hhid) robust
outreg2 using kids_edu_ols_fe, excel label append nocons ctitle("`o'")
quietly xi: xtreg `o' kids_rooms adults_rooms children adults i.a a_2 sex e_n i.prov*i.r si_* if max_age<18 & max_age>6, fe cluster(hh1) robust
outreg2 using kids_edu_ols_fe, excel label append nocons ctitle("`o' fe")
}



** b.) Explore RDP: Reduced Form

** Instead create Crowded definitions


quietly xi: xtreg c_edu rdp, fe cluster(hh1) robust
outreg2 using kids_edu_red_form, excel label replace nocons keep(rdp)
outreg2 using kids_edu_red_form_rooms, excel label replace nocons keep(rdp)

foreach o in $kids_edu {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `o' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using kids_edu_red_form, excel label append nocons ctitle("`o' `var'") keep(`var')
g rr=`var'
quietly xi: xtreg `o' i.rr*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using kids_edu_red_form_rooms, excel label replace nocons ctitle("`o' `var'")
drop rr
}
}

foreach o in c_att1 absent {
xi: xtreg `o' i.rdp*i.roomsr1 i.prov*i.r if u==1 & max_age<15 & max_age>=1, fe cluster(hh1) robust
}


foreach o in $kids_edu {
xi: xtreg `o' i.rdpdo*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
}


foreach o in $kids_edu {
xi: xtreg `o' i.rdpf*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
}

** basically nothing

*******************************
*** ISOLATE CROWDING EFFECT ***
*******************************

use mech_c_edu_v1, clear 

global kids_health "c_ill weight c_health c_resp check_up c_ill_ser c_doc"

global kids_edu "c_att1 absent"

g kids_rooms=children/rooms
g adults_rooms=adults/rooms
g a_2=a*a
egen max_age=max(a), by(pid)
drop if roomsr1>5

** try this **
g adult_roomsr1_id=adults_rooms if r==1
egen adult_roomsr1=max(adult_roomsr1_id), by(pid)

g size_roomsr1_id=size/rooms if r==1
egen size_roomsr1=max(size_roomsr1_id), by(pid)

g children_id=children if r==1
egen childrenr1=max(children_id), by(pid)

g adults_id=adults if r==1
egen adultsr1=max(adults_id), by(pid)

drop ownr1
g own_id=own_d if r==1
egen ownr1=max(own_id), by(pid)

g ownr1_roomsr1=ownr1*roomsr1

** change to adult rooms **
sum size_roomsr1
g crowd_kids=(childrenr1>2 & childrenr1<.)
g crowded=(adult_roomsr1>1 & adult_roomsr1!=.)
g empty=size_roomsr1<=1.7
g small=(roomsr1<=2)
g large=(roomsr1>2 & roomsr1<=5)

foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
g `var'__s=`var'*small
g `var'__c=`var'*crowded
g `var'__s_c=`var'*small*crowded
g `var'__c_k=`var'*crowd_kids
}
g ownr1_small=ownr1*small


xtset pid

*** NOW TRY MAKING HETEROGENEITY BY HOUSEHOLD SIZE OR NUMBER OF KIDS?
foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.childrenr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
*** uncorrelated with the number of children..
foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.adultsr1 i.prov*i.r if max_age<15 & max_age>1 & sizer1<10, fe cluster(hh1)  robust
}
** medium adults
foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.sizer1 i.prov*i.r if max_age<15 & max_age>1 & sizer1<10, fe cluster(hh1)  robust
}
** independent of size
foreach o in c_failed c_ill {
 xi: xtreg `o' rdp rdp__c_k i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
}
** number of kids crowd doesn't matter, its really by room size!

*** DO ROOMS HETEROGENEITY QUICK ! AND ADD OWNERSHIP
foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.roomsr1 i.rdp*i.ownr1 i.rdp*i.ownr1_roomsr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
** LOOK AT OWNERSHIP
foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.ownr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}

*** SHOWS INCOME STORY: LARGE RENTERS GET THE BIGGEST BOOST TO INCOME.. ANYTHING FRESH THOUGH?
foreach o in c_failed absent c_ill c_health c_att1 {
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1 & u==1, fe cluster(hh1)  robust
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1 & u==0, fe cluster(hh1)  robust
}

foreach o in check_up c_doc c_ill_ser c_resp {
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1 & u==1, fe cluster(hh1)  robust
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1 & u==0, fe cluster(hh1)  robust
}
** yes



foreach o in size children adults kids_per_adult hh_a_mean hoh_gender hoh_a {
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r, fe cluster(hh1)  robust
}

foreach o in  {
 xi: xtreg `o' i.rdp*i.ownr1 i.rdp*i.small i.rdp*i.ownr1_small i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}




*** NOW TRY INCOME
g inc_cat=.
forvalues r=1000(1000)15000 {
replace inc_cat=`r' if inc>`r'-1000 & inc<=`r'
}
g inc_cat1=inc_cat if r==1
egen inc_r1=max(inc_cat1), by(pid)

foreach o in c_failed c_ill {
 xi: xtreg `o' i.rdp*i.inc_r1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}

** slightly greater incomes are benefitting from the housing more, why is that?
** ** not super clear

** ** fixed costs to housing? furnishing new housing? getting better housing?

foreach o in sch_spending sch_per health_exp health_exp_per vice vice_per {
 xi: xtreg `o' i.rdp*i.inc_r1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
** wealthier households spend more on good things, poorer households spend more on bad things
 ** ** why is that??? why do households respond differently by income?
 
 *** CAN WE RULE OUT MECHANICAL EXPLANATIONS?
 ** School quality and check_up
foreach o in c_fees lratio check_up {
 xi: xtreg `o' i.rdp*i.inc_r1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}

foreach o in c_fees lratio check_up {
 xi: xtreg `o' i.rdp*i.roomsr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
** all spend less on school fees except for super poor households, does that mean better schools?

foreach o in sch_spending sch_per health_exp health_exp_per vice vice_per {
 xi: xtreg `o' i.rdp*i.adultsr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}

** double-check rooms
foreach o in sch_spending sch_per health_exp health_exp_per vice vice_per {
 xi: xtreg `o' i.rdp*i.roomsr1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
**** spend less on schools for some reason??

** home expenditures??

foreach o in h_prod h_prod_per ceremony ceremony_per {
 xi: xtreg `o' i.rdp*i.inc_r1 i.prov*i.r if max_age<15 & max_age>1 & children<10, fe cluster(hh1)  robust
}
** less on ceremonies, no change for household production




**** CREATE MEASURE OF HIGH VALUE RDP
g rdp_h_v=rdp
replace rdp_h_v=0 if (mktv<50000) 
sort pid r
by pid: g h_ch_h_v=rdp_h_v[_n]-rdp_h_v[_n-1]
egen min_h_cht_h_v=min(h_ch_h_v), by(pid)
replace rdp_h_v=. if min_h_cht_h_v==-1
g rdp_h_v__s=rdp_h_v*small
* and low value rdp
g rdp_l_v=rdp
replace rdp_l_v=0 if (mktv>50000) 
sort pid r
by pid: g h_ch_l_v=rdp_l_v[_n]-rdp_l_v[_n-1]
egen min_h_cht_l_v=min(h_ch_l_v), by(pid)
replace rdp_l_v=. if min_h_cht_l_v==-1
g rdp_l_v__s=rdp_l_v*small

foreach o in c_failed c_ill {
 xi: xtreg `o' rdp_h_v rdp_h_v__s rdp_l_v rdp_l_v__s i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
}
*** some heterogeneity but it's totally fine




foreach var in rdp rdpd rdpt rdpo rdpdo rdpf {
 xi: xtreg c_failed `var' i.prov*i.r if max_age<15 & max_age>4, fe cluster(hh1)  robust
}


xtset pid

global red_title "big_small"
** also control for income
quietly xi: xtreg c_ill rdp rdp__c rdp__s rdp__s_c, fe cluster(hh1) robust
outreg2 using $red_title, label replace nocons

foreach o in $kids_edu {
foreach var in rdp rdpd rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `o' `var' `var'__c `var'__s `var'__s_c a a_2 i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
outreg2 using $red_title, label append nocons ctitle("`o' `var'")
}
}



 xi: xtreg c_failed rdp rdp__s i.prov*i.r if max_age<15 & max_age>4, fe cluster(hh1)  robust

 xi: xtreg c_failed i.rdp*i.roomsr1 i.prov*i.r if max_age<15 & max_age>4, fe cluster(hh1)  robust

 xi: xtreg c_failed rdp i.prov*i.r if max_age<15 & max_age>4 & u==0, fe cluster(hh1)  robust
 xi: xtreg c_failed rdp i.prov*i.r if max_age<15 & max_age>4 & u==1, fe cluster(hh1)  robust


quietly xi: xtreg c_failed rdp a a_2 i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust


** C_FAILED AND C_ILL RESULTS ARE DRIVEN BY VERY HIGH VALUE RDP'S

** MAKE RDP VARIABLES UP TO 100,000 BY 10's

forvalues r=20000(20000)80000 {
g rdp_r`r'=rdp
replace rdp_r`r'=0 if (mktv<`r'-20000 | mktv>`r') 
*sort pid r
*by pid: g h_cht_`r'=rdp_r`r'[_n]-rdp_r`r'[_n-1]
*egen min_h_cht_`r'=min(h_cht_`r'), by(pid)
*replace rdpt=. if min_h_cht==-1
*drop h_cht_`r'
*drop min_h_cht_`r'
}

 xi: xtreg c_ill rdp_r20000 rdp_r40000 rdp_r60000 rdp_r80000 i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
 xi: xtreg c_failed rdp_r20000 rdp_r40000 rdp_r60000 rdp_r80000 i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust

foreach o in c_failed c_ill {
 xi: xtreg `o' rdp_r20000 rdp_r40000 rdp_r60000 rdp_r8000 i.prov*i.r if max_age<15 & max_age>1, fe cluster(hh1)  robust
}

*** NOT MUCH HERE!

*******************************
*** ISOLATE GUARDIAN EFFECT ***
*******************************

use mech_c_edu_v1, clear 

global kids_health "c_ill weight c_health c_resp check_up c_ill_ser c_doc"

*global kids_edu "c_edu c_edu1 c_att absent absent1 fees c_fees lratio sch_d"

g kids_rooms=children/rooms
g adults_rooms=adults/rooms
g a_2=a*a
egen max_age=max(a), by(pid)

global rdp "rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf"

xtset pid
* foreach var of varlist $rdp {
* xi: xtreg parent `var' i.prov*i.r if u==1 & max_age<8, fe cluster(hh1)  robust
* }
** ** ** works very well !

g parent_r1_id=parent if r==1
egen parentr1=max(parent_r1_id), by(pid)
g noparentr1=0 if parentr1==1
replace noparentr1=1 if parentr1==0

foreach v in $rdp {
g `v'__noparent=`v'*noparentr1
}


global red_title "no_parent"
** also control for income
quietly xi: xtreg c_ill rdp rdp__noparent if u==1 & max_age<8, fe cluster(hh1) robust
outreg2 using $red_title, excel label replace nocons

foreach o in absent c_att1 {
foreach v in $rdp {
quietly xi: xtreg `o' `v' `v'__noparent a a_2 i.prov*i.r if u==1 & max_age<8, fe cluster(hh1)  robust
outreg2 using $red_title, label append nocons ctitle("`o' `v'")
}
}

** ESSENTIALLY NOTHING HERE!!

***************************************
*** COMPETITION BETWEEN KIDS EFFECT ***
***************************************

use mech_c_edu_v1, clear 

** not super clear what's happening!

** are families changing in dramatically different ways conditional on what houses they start out in???


global kids_health "c_ill weight c_health c_resp check_up c_ill_ser c_doc"

global kids_edu "c_edu c_edu1 c_att absent absent1 fees c_fees lratio sch_d"

g kids_rooms=children/rooms
g adults_rooms=adults/rooms
g a_2=a*a
egen max_age=max(a), by(pid)

global rdp "rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf"

xtset pid

replace child_out=0 if child_out==.
replace child_out=. if children==.

g child_total=child_out+children
foreach var of varlist $rdp {
xi: xtreg child_out `var' i.prov*i.r if u==1, fe cluster(hh1)  robust
xi: xtreg children `var' i.prov*i.r if u==1, fe cluster(hh1)  robust
}
* where is this child_out coming from???

foreach var of varlist $rdp {
xi: xtreg child_out i.`var'*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1)  robust
}

g kids_ratio=children/size

* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)

tab roomsr1 left_out
** not clearly associated with one room



foreach var of varlist rdp {
forvalues r=1/4 {
xi: xtreg size `var' i.prov*i.r if u==1 & roomsr1==`r', fe cluster(hh1)  robust
xi: xtreg children `var' i.prov*i.r if u==1 & roomsr1==`r', fe cluster(hh1)  robust
xi: xtreg kids_ratio `var' i.prov*i.r if u==1 & roomsr1==`r', fe cluster(hh1)  robust
xi: xtreg child_out `var' i.prov*i.r if u==1 & roomsr1==`r', fe cluster(hh1) robust
}
}

** *** WHAT IS GOING ON WITH 1 ROOM HOUSES?! WHY ARE THE RESULTS SO DIFFERENT?!

hist a if roomsr1<=3, by(roomsr1)
hist mktv if roomsr1<=3 & roomsr1>0 & mktv<100000, by(roomsr1)

sort pid r
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
by pid: g size_ch=size[_n]-size[_n-1]
by pid: g children_ch=children[_n]-children[_n-1]

hist rooms_ch if roomsr1<=4 & roomsr1>0, by(roomsr1)


hist size if roomsr1<=4 & roomsr1>0 & size<15, by(roomsr1)
hist mktv if roomsr1<=4 & roomsr1>0 & size<15 & mktv<100000, by(roomsr1)
hist rooms_ch if roomsr1<=4 & roomsr1>0 & h_ch>=0, by(roomsr1 h_ch)

hist size_ch if roomsr1<=4 & roomsr1>0 & h_ch>=0 & size_ch>-5 & size_ch<5, by(roomsr1 h_ch)

hist children_ch if roomsr1<=4 & roomsr1>0 & h_ch>=0 & children_ch>-5 & children_ch<5, by(roomsr1 h_ch)



hist rooms if roomsr1<=2 & roomsr1>0 & h_ch>=0, by(h_ch roomsr1)



** ** ** works very well !
*** fix this
g parent_r1_id=parent if r==1
egen parentr1=max(parent_r1_id), by(pid)
g noparentr1=0 if parentr1==1
replace noparentr1=1 if parentr1==0

foreach v in $rdp {
g `v'__noparent=`v'*noparentr1
}

global red_title "competition"
** also control for income
quietly xi: xtreg c_ill rdp rdp__noparent if u==1, fe cluster(hh1) robust
outreg2 using $red_title, excel label replace nocons

foreach o in $kids_edu {
foreach v in $rdp {
quietly xi: xtreg `o' `v' `v'__noparent a a_2 i.prov*i.r if u==1, fe cluster(hh1)  robust
outreg2 using $red_title, excel label append nocons ctitle("`o' `v'")
}
}









**************
*** HEALTH ***
**************

use mech_c_edu_v1, clear 

global kids_health "c_ill weight c_health c_resp check_up c_ill_ser c_doc"

g kids_rooms=children/rooms
g adults_rooms=adults/rooms
g a_2=a*a

xtset pid

global cross_title_ols "kids_health_ols_fe"

** a.) Cross Sectional and Panel: HEALTH
quietly xi: reg c_ill kids_rooms adults_rooms children adults a a_2 sex u e_n i.prov si_*, cluster(hhid) robust
outreg2 using $cross_title_ols, excel label replace nocons
foreach o in $kids_health {
quietly xi: reg `o' kids_rooms adults_rooms children adults i.a a_2 sex u e_n i.prov i.r si_*, cluster(hhid) robust
outreg2 using $cross_title_ols, excel label append nocons ctitle("`o'")
quietly xi: xtreg `o' kids_rooms adults_rooms children adults i.a a_2 sex e_n i.prov*i.r si_*, fe cluster(hh1) robust
outreg2 using $cross_title_ols, excel label append nocons ctitle("`o' fe")
}

global red_title "kids_health_red_form"
** b.) Explore RDP: Reduced Form: HEALTH

quietly xi: xtreg c_ill rdp, fe cluster(hh1) robust
outreg2 using $red_title, excel label replace nocons keep(rdp)

foreach o in $kids_health {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `o' `var' a a_2 i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using $red_title, excel label append nocons ctitle("`o' `var'") keep(`var')
}
}



foreach o in $kids_health {
xi: xtreg `o' a a_2 i.rdp*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
}


foreach o in $kids_health {
xi: xtreg `o' a a_2 i.rdpdo*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
}


foreach o in $kids_health {
xi: xtreg `o' a a_2 i.rdpf*i.roomsr1 i.prov*i.r if u==1, fe cluster(hh1) robust
}




foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons







global house "rooms mktv piped elec walls_b roof_cor toi own_d"
global demo "size children adults kids_per_adult hh_a_max hh_a_mean hh_gender hoh_a hoh_gender"
global neighborhood "theft domvio vio gang murder drug"
global food_expenditures "exp_imp te fexp_imp fd w w_alt y y_alt"
global non_food_expenditures "h_prod h_prod_per sch_spending sch_per vice vice_per ceremony ceremony_per" 
global income_emp "inc e ue"
global health "c_health c_ill"


xtset pid

foreach c in house demo neighborhood food_expenditures non_food_expenditures income_emp health {
est clear
outreg2 using `c', excel label replace

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
quietly xi: xtreg `k' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}



foreach c in  food_expenditures {
est clear
quietly xi: xtreg te rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1 & `k'>0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}


global weight_kids "weight"

foreach c in  weight_kids {
est clear
quietly xi: xtreg te rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' a i.prov*i.r if u==1 & `k'>0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}


*** NOW TRY OTHER OUTCOMES:: Wages???


*** WAGE INCOME DECLINES ***

use hh_v3_d_p_ghs, clear 
xtset pid

g fw=fwag if fwag_flg==0
g cw=cwag if cwag_flg==0
g sw=swag if swag_flg==0

global wages "fwag fw cwag cw swag sw"

foreach c in wages {

quietly xi: xtreg fwag rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
quietly xi: xtreg `k' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}



*** COMMUTE ***

use hh_v3_d_p_ghs, clear 
xtset pid

global commute "travel inc_r inc_l inc_g"

foreach c in commute {

quietly xi: xtreg travel rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
quietly xi: xtreg `k' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}
*** NOT MUCH HERE AT ALL


*** Intensive margin? *** work less or paid less? probably work less..


*** EDUCATION ***

use hh_v3_d_p_ghs, clear 
xtset pid

global education "c_edu c_att c_fees sch_travel absent c_resp"

foreach c in education {

quietly xi: xtreg c_edu rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
quietly xi: xtreg `k' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons
}
}
}

replace c_resp=. if a>18
 xi: xtreg c_resp rdp i.prov*i.r if u==1, fe cluster(hh1) robust
 ** more likely to get respiratory illness
 
 xi: xtreg c_ill_ser rdp i.prov*i.r if u==1, fe cluster(hh1) robust



*** HEALTH EXPENDITURE ** AND OTHER EXPENDITURE??


use hh_v3_d_p_ghs, clear 
xtset pid


foreach var of varlist h_nfhspspnyr h_nfdocspnyr h_nftradspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist h_nffrnspn h_nfhomspn h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn {
replace `var'=0 if `var'<=0 | `var'==.
}


global health "health_exp health_exp_per"

global health1 "doc med"

foreach c in health1 {

quietly xi: xtreg c_edu rdp i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `c', excel label replace keep(rdp) nocons

foreach k of varlist $`c' {
foreach var of varlist rdp rdpd rdpd1 rdpt rdpo rdpdo rdpf {
quietly xi: xtreg `k' `var' i.prov*i.r if u==1 & `k'>0, fe cluster(hh1) robust
outreg2 using `c', excel label append  keep(`var') nocons

}
}
}
** HEALTH EXPENDITURES GO UP, WHY?! ( EVEN AS A FRACTION OF TOTAL EXPENDITURES !! )

** BREAK IT DOWN INTO DIFFERENT PIECES?!?!



