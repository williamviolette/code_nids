cd "/Users/willviolette/Desktop/pstc_work/nids"


***************
** DATA PREP **
***************
use "nids_4.dta", clear
drop w1_h_* fd*
rename h_ch h_g
renpfix w1_

replace dep=1 if dep<0
replace emp=0 if emp==2 | emp<0
replace hh_income=. if hh_income<0 | hh_income>40000

g a1=a if a>=20
egen m_a=mean(a1), by(hhid)
replace rooms=. if rooms>10

egen children=sum(child), by(hhid)

g ed=edu
replace ed=. if ed<0
replace ed=0 if ed==25
replace ed=. if ed>12 & ed<25

* schooling outcomes
replace d_sch_hrs=. if d_sch_hrs<0
replace d_sch_hrs=d_sch_hrs*60
replace d_sch_min=. if d_sch_min<0
replace d_sch_hrs=0 if d_sch_min!=. & d_sch_hrs==.
replace d_sch_min=0 if d_sch_hrs!=. & d_sch_min==.
g schd=d_sch_hrs+d_sch_min
replace schd=. if schd>100
replace spnfee=. if spnfee<0
replace spntrn=. if spntrn<0
replace spnfee=spnfee/children
replace spntrn=spntrn/children

* time to work
replace t_time_h=. if t_time_h<0
replace t_time_h=t_time_h*60
replace t_time_m=. if t_time_m<0
replace t_time_h=0 if t_time_m!=. & t_time_h==.
replace t_time_m=0 if t_time_h!=. & t_time_m==.
g wrkd=t_time_h+t_time_m

replace travel=. if travel<0
g mar=marry==1
g tog=(marry==1 | marry==2)

** try a whole assortment of outcomes
sort pid r
by pid: g hh_income_ch=hh_income[_n]-hh_income[_n-1]
by pid: g food_ch=food[_n]-food[_n-1]
by pid: g emp_ch=emp[_n]-emp[_n-1]
by pid: g dep_ch=dep[_n]-dep[_n-1]
drop toi_shr_ch
replace toi_shr=0 if toi_shr==2 | toi_shr<0
by pid: g toi_shr_ch=toi_shr[_n]-toi_shr[_n-1]
by pid: g m_a_ch=m_a[_n]-m_a[_n-1]
by pid: g children_ch=children[_n]-children[_n-1]
by pid: g schd_ch=schd[_n]-schd[_n-1]
by pid: g spnfee_ch=spnfee[_n]-spnfee[_n-1]
by pid: g spntrn_ch=spntrn[_n]-spntrn[_n-1]

** SEE IF WE CAN LOOK AT LEFTOVER HOUSEHOLD! AGAIN...
g hhid1=hhid if r==1
replace hhid1=-1 if hhid1==.
egen hh1=max(hhid1), by(pid)

egen m_h_g=mean(h_g), by(hh1 r)
g sp=(m_h_g>0 & m_h_g<1)

egen dj=max(dec_j), by(hhid)

drop if hh_income>20000

g rdp_u=rdp*u

sort pid r
by pid: g emp_l=emp[_n-1]

g lo=(sp==1 & rdp==0)
g li=(sp==1 & rdp==1)

g rem_p=remit/hh_income

** add schooling
sort pid r
merge pid r using school
tab _merge
drop if _merge==2
drop _merge

** add dropped members
 sort hhid
 merge hhid using tsm
 tab _merge
 drop if _merge==2
 
 *** FIX RACE VARIABLE ***
replace pop_grp=. if pop_grp<0 | pop_grp==5
replace pop_grp=0 if pop_grp==.

egen pop_hh=max(pop_grp), by(hh1)
replace pop_grp=pop_hh if pop_grp==0
replace pop_grp=5 if pop_grp==0

*** ADD IN HOH VARIABLES ***
drop _merge
sort pid r
merge pid r using hoh
tab _merge
keep if _merge==3
drop _merge


save "leftovers1.dta", replace




*****************
**** BALANCE ****
*****************

**************
*** LEVELS ***
**************
use "leftovers1.dta", clear

drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)

* * * * * * * * * * * * * 
** NEED TO LOOK AT RACE *
* * * * * * * * * * * * * 

g af=pop_grp==1

tab pop_grp h_g
tab pop_grp rdp
tab pop_grp u

sort pid r
by pid: g h_sw=h_g[_n+1]

* first round
drop if rdp==1 & r==1
drop if rdp==1 & r==2

egen loc1=group(bdc)
replace loc1=-1 if loc1==.
egen loc=max(bdc), by(hhid)
egen loci=max(loc), by(pid)
replace loci=. if loci<=0

** look more carefully at balance issues, break up by province too

egen m_h_sw=max(h_sw), by(hhid)

g u_emp=u*e
g ue_emp=ue*u

collapse (max) pop_grp (mean) loci m_h_sw edu a gender children hh_income e ue u rooms piped elec u_emp ue_emp inf , by(hhid r)

reg m_h_sw edu a gender children hh_income u e ue rooms piped elec inf i.pop_grp i.r, robust

reg m_h_sw edu a gender children hh_income e ue rooms piped elec inf i.pop_grp i.r if u==1, robust
reg m_h_sw edu a gender children hh_income e ue rooms piped elec inf i.pop_grp i.r if u==0, robust
** BETTER IN RURAL AREAS, STUFF GOING ON IN URBAN AREAS

reg m_h_sw edu a gender children hh_income e u ue rooms piped elec inf i.r i.loci, robust

reg m_h_sw edu a gender children hh_income e ue rooms piped elec i.r if u==1, robust
reg m_h_sw edu a gender children hh_income e ue rooms piped elec i.r if u==0, robust

reg m_h_sw edu a gender children hh_income e ue if r==1, robust
reg m_h_sw edu a gender children hh_income e ue if r==2, robust

** PROBLEMS
reg m_h_sw edu a gender children hh_income e ue i.r if hh_income<3500, robust cluster(hhid)
** still there

*** CHANGES/PRETRENDS ***
***********************************
*** 1.) First For Households!!! ***
***********************************
use "leftovers1.dta", clear
drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)
g af=pop_grp==1

sort pid r
by pid: g e_ch=e[_n]-e[_n-1]
by pid: g ue_ch=ue[_n]-ue[_n-1]
by pid: g u_ch=u[_n]-u[_n-1]

reg u_ch h_g i.r, robust
* here is the discovery of urban movement! which is significant but only 140 people

sort pid r
by pid: g h_sw=h_g[_n+1]

egen loc1=group(bdc)
replace loc1=-1 if loc1==.
egen loc=max(bdc), by(hhid)
egen loci=max(loc), by(pid)
replace loci=. if loci<=0

** focus on second round, people without rdp
keep if r<=2 & rdp==0
egen m_h_sw=max(h_sw), by(hhid)

collapse loci af m_h_sw ed a sex children size hh_income e ue u rooms piped inf, by(hh1 r)

foreach var of varlist af ed a sex children size hh_income e ue u rooms piped inf {
sort hh1 r
by hh1: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}

reg m_h_sw ed a sex size children hh_income u e ue rooms piped inf, robust
reg m_h_sw a sex size children hh_income u e ue piped inf i.r, robust

reg m_h_sw ed a sex size children hh_income u e ue rooms piped inf i.r i.loci, robust
* older households are less likely to get the housing

reg m_h_sw ed a sex size children hh_income e ue rooms piped inf i.r if u==1, robust
reg m_h_sw ed a sex size children hh_income e ue rooms piped inf i.r if u==0, robust
*** looks good, the only issue might be take-up of houses

***********************************
*** 2.) Now For Individuals!!!  ***
***********************************

use "leftovers1.dta", clear
drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)

sort pid r
g e_ch=e[_n]-e[_n-1]
g ue_ch=ue[_n]-ue[_n-1]

sort pid r
by pid: g h_sw=h_g[_n+1]

egen loc1=group(bdc)
replace loc1=-1 if loc1==.
egen loc=max(bdc), by(hhid)
egen loci=max(loc), by(pid)
replace loci=. if loci<=0

** focus on second round, people without rdp
keep if r<=2 & rdp==0
egen m_h_sw=max(h_sw), by(hhid)

collapse hh1 m_h_sw fwag cwag swag children size hh_income e ue u rooms piped inf, by(pid r)

foreach var of varlist  fwag cwag swag children size hh_income e ue rooms piped inf {
sort pid r
by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}

reg m_h_sw size children hh_income e ue, robust cluster(hh1)
** little size effect, but it doesn't mean much
reg m_h_sw size children hh_income e ue rooms piped inf, robust cluster(hh1)
* gaining access to services also reduces likelihood of take-up *(which is probably ok)

reg m_h_sw size children hh_income e ue if u==1, robust cluster(hh1)
reg m_h_sw size children hh_income e ue if u==0, robust cluster(hh1)

reg m_h_sw size children hh_income e ue rooms piped inf if u==1, robust cluster(hh1)
reg m_h_sw size children hh_income e ue rooms piped inf if u==0, robust cluster(hh1)

* gaining access to services also reduces likelihood of take-up
** places that got access to services  ( by switching locations? )

reg m_h_sw size children hh_income fwag, robust cluster(hh1)
* wage measures are also very insignificant



*************************************
*** WE ARE GETTING THE STORY HERE ***
*************************************

*** LOOK AT HOUSEHOLD SIZE

** HOW DO I WANT TO THINK ABOUT HOUSEHOLD SIZE? AS RESIDENTS OR AS TOTAL HH??
*** DEFINE A NEW HH_SIZE MEASURE BASED ON RESIDENTS !!

*** CAN WE TRACK CHANGES IN HOUSEHOLD HEAD !?!?!?!?!?!?!

*** ASSETS !!!!

use "leftovers1.dta", clear

* clean
drop if emp_d==. | emp_d==-8

egen m_g_l=max(h_l), by(pid)
g rdpl=rdp
replace rdpl=0 if m_g_l==1

drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)

sort pid r
g e_ch=e[_n]-e[_n-1]
g ue_ch=ue[_n]-ue[_n-1]
xtset pid

* * * now look at hh size changes, etc.

g hoh=relhead==1

sort pid r
by pid: g h_sw=h_g[_n+1]
by pid: g hoh_ch=hoh[_n]-hoh[_n-1]
by pid: g remit_ch=remit[_n]-remit[_n-1]

g sex_h_g=sex*h_g
g h_g_p_ch=h_g*piped_ch

g rdpl_sex=rdpl*sex

tab hoh_ch h_g
reg hoh_ch h_g i.r, robust 

xtreg hoh rdpl i.r, fe robust

** GENDER MATTERS A LOT!!! **
xtreg e rdpl i.r, fe robust
xtreg e rdpl i.r if sex==1, fe robust
xtreg e rdpl elec piped i.r if sex==0, fe robust

xtreg e rdpl elec piped i.r, fe robust
** ONLY THROUGH PIPED WATER
xtreg e elec piped i.r if rdpl==0, fe robust

** IS IT THE PIPED WATER?  OR IS IT THE CHANGE OF DWELLING LOCATION
*** LIKE THROUGH SLUM UPGRADING
reg e_ch piped_ch h_g i.r, robust
reg e_ch inf_ch h_g i.r, robust

tab piped_ch inf_ch
* makes sense

replace rooms_ch=. if rooms_ch>10 | rooms_ch<-10
* effect is driven by women: there's slum upgrading theme!
tab  rooms_ch piped_ch
* * hist rooms_ch, by(piped_ch)
** way more likely to change locations
* drop piped_ch
sort pid r
by pid: g piped_ch1=piped[_n]-piped[_n-1]
tab piped piped_ch1
tab water piped_ch1


** IS THE EFFECT DRIVEN BY CHANGING LOCATION, TEST ROOM CHANGES!
reg e_ch h_g inf_ch piped_ch rooms_ch size_ch hoh_ch a i.r if sex==1, robust
reg e_ch h_g inf_ch piped_ch rooms_ch a i.r if sex==0, robust

reg e_ch inf_ch h_g i.r if sex==1, robust
reg e_ch inf_ch h_g i.r if sex==0, robust

* same, only through piped water
** TEST PIPED WATER IMPLICATION

reg e_ch h_g i.r if piped_ch==0, robust
* nothing

g 

reg hh_income_ch h_g i.r if piped_ch==0, robust

foreach var of varlist spnfee_ch spntrn_ch schd_ch ue_ch e_ch remit_ch hh_income_ch dep_ch food_ch children_ch {
reg `var' h_g sex sex_h_g piped_ch i.r, robust
}

foreach var of varlist spnfee spntrn schd ue e remit hh_income dep food children {
xtreg `var' rdpl piped i.r, fe robust
}

tab rooms piped


tab rooms piped_ch if h_g==1

tab water piped_ch if h_g==1

** remittances are for sure declining, other stuff is less clear

reg e_ch h_g i.r if hoh==0, robust

reg e_ch h_g i.r if sex==1, robust
reg e_ch h_g i.r if sex==0, robust

reg e_ch h_g sex sex_h_g i.r, robust




** WAY MORE LIKELY TO BECOME HOH
*** ARE THESE THE PEOPLE GENERATING THE EMPLOYMENT GAINS?

tab size_ch h_g

tab hoh_ch

** FOR INDIVIDUALS
reg size_ch h_g i.r, robust cluster(hh1)
reg size_ch h_g i.r if size_ch>-5 & size_ch<5, robust cluster(hh1)

** FOR HOUSEHOLDS



egen loc1=group(bdc)
replace loc1=-1 if loc1==.
egen loc=max(bdc), by(hhid)
egen loci=max(loc), by(pid)
replace loci=. if loci<=0



********************************
*** SWITCHING DETERMINANTS   ***
********************************

****************************
*** SCHOOLING OUTCOMES   ***
****************************

use "leftovers1.dta", clear

sort pid r
by pid: g h_sw=h_g[_n+1]
tab tsm_tot h_sw if r>1
reg tsm_tot h_sw if r>1

** uncorrelated, but is this a good measure of household division?
*** more to look at size changes

drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)

drop if edlstm_schcd==.

drop if edlstm_nofee==. | edlstm_nofee==-9
g fee=edlstm_nofee==1


sort pid r
by pid: g e_ch=e[_n]-e[_n-1]
by pid: g ue_ch=ue[_n]-ue[_n-1]
by pid: g quin_ch=edlstm_quin[_n]-edlstm_quin[_n-1]
by pid: g sch_ch=edlstm_schcd[_n]!=edlstm_schcd[_n-1]
by pid: g fee_ch=fee[_n]-fee[_n-1]

tab fee_ch h_g if r>1

reg quin_ch h_g if r>1
* no change in school quality
** schooling variables don't work great



****************************
*** HOUSEHOLD BARGAINING ***
****************************

use "leftovers1.dta", clear



* hist rooms if sp==1, by(rdp u)
* rural areas, very obvious
* hist size if sp==1, by(rdp)
* hist m_a if sp==1, by(rdp)
* hist children if sp==1, by(rdp)
* hist hh_income if sp==1 & hh_income<20000, by(rdp)

xtset hh1

foreach var of varlist remit rem_p {
xtreg `var' rdp u rdp_u i.r if sp==1, fe robust
reg `var' rdp u rdp_u i.r if sp==1, robust cluster(hh1)
}

foreach var of varlist hh_income m_a size children rooms food veg_s chi_s sd_s travel mar tog ed emp emp_l emp_ch { 
xtreg `var' rdp u rdp_u i.r if sp==1, fe robust
reg `var' rdp u rdp_u i.r if sp==1, robust cluster(hh1)
}


foreach var of varlist emp emp_l emp_ch inf_ch a wrkd {
xtreg `var' rdp u rdp_u i.r if sp==1, fe robust
reg `var' rdp u rdp_u i.r if sp==1, robust cluster(hh1)
}
** can't identify anything..


xtreg ed rdp i.r if sp==1 & u==1, fe robust
xtreg ed rdp i.r if sp==1 & u==0, fe robust
** DID CHILDREN CHANGE THE REALLOCATION OF SIZE BETWEEN THE TWO HOUSEHOLDS

** DID PEOPLE WHO WERE LEFT BEHIND GET MORE LIKELY TO BE EMPLOYED
** ** COMPARED TO OTHER PEOPLE UNAFFECTED BY RDP


* * * * ** ** * * *  * *
*** TESTING RESULTS ****
* * * * ** ** * * *  * *

use "leftovers1.dta", clear

drop e
g e=emp_d==3
g ue=(emp_d==1 | emp_d==2)

sort pid r
g e_ch=e[_n]-e[_n-1]
g ue_ch=ue[_n]-ue[_n-1]

egen m_g_l=max(h_l), by(pid)
g rdpl=rdp
replace rdpl=0 if m_g_l==1

reg e_ch h_g i.r, robust cluster(hh1)
reg e_ch h_g i.r, robust cluster(hh1)
reg ue_ch h_g i.r, robust cluster(hh1)
reg ue_ch h_g i.r if e_ch!=-1, robust cluster(hh1)
** PEOPLE LOOKING FOR JOBS

g rdpl_u=rdpl*u
* time for lo li
xtset pid

xtreg e rdpl i.r, robust fe

xtreg e rdpl i.r if pop_grp==1, robust fe


 foreach var of varlist e ue fwag swag cwag inf travel veg_s chi_s out_s rdy_s {
 xtreg `var' rdpl i.r, robust fe
 xtreg `var' rdpl i.r if u==1, robust fe
 xtreg `var' rdpl i.r if u==0, robust fe
 }

 foreach var of varlist food size hs remit {
 xtreg `var' rdpl i.r, robust fe
 xtreg `var' rdpl u rdpl_u i.r, robust fe
 }


 


foreach var of varlist e ue fwag swag cwag inf remit {
xtreg `var' lo li i.r, robust fe
xtreg `var' lo li i.r if u==1, robust fe
xtreg `var' lo li i.r if u==0, robust fe
}

xtreg emp size i.r, robust fe


xtreg emp lo rdp i.r, robust fe
xtreg emp lo i.r if u==1, robust fe
xtreg emp lo i.r if u==0, robust fe


* driven by urban areas, where the jobs are

xtreg emp lo li i.r if rdp==0 & , robust fe


* just look at one period
tab r_gs1
tab h_g

** MAKE GRAPHS
** SCHOOLING
hist schd, by(h_g)

** AGE
** look at age by gain and loss
hist a, by(h_g)
* looks kinda like young people leave
ksmirnov a, by(h_g)
* no differences in age, observably, but they are different?

** ROOMS
hist rooms, by(h_g)
*** consistent with poor people getting the biggest impact !
hist rooms, by(rdp)
ksmirnov rooms, by(h_g)
* very different!
ksmirnov rooms, by(h_l)
* also different!

** SIZE
replace size=. if size>14
hist size, by(h_g)

** ROUGHLY EVEN SPLIT!!!!

** leavers have smaller sizes
hist size if size<10, by(rdp)
ksmirnov size, by(h_g)
* no differences in size of household

** CHILDREN
hist children, by(h_g h_l)
ksmirnov children, by(h_g)
ksmirnov children, by(h_l)
** very different: both have less children



foreach var of varlist hh_income_ch food_ch emp_ch dep_ch size_ch elec_ch piped_ch inf_ch child_ch dwell_ch roof_ch walls_ch toi_ch toi_shr_ch rent_ch rooms_ch owner_ch children_ch schd_ch spntrn_ch spnfee_ch m_a {
reg `var' h_g i.r if r>1, robust
}




