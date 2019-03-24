
*****************************************
** NOW LOOK OVER A LONGER TIME HORIZON **
*****************************************

cd "/Users/willviolette/Desktop/pstc_work/nids"

use clean_v1.dta, clear
** LOOK AT UPGRADES IN ROUND 3
* SAVINGS = INCOME - EXPENDITURES
** look at geographic variation
** do the CAPS

** only look at adults
keep if a>18

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0


*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** treat them as still treated
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=max(h_ch), by(pid)
replace rdp=1 if h_ch_m==-1

*** GET RID OF ROUND 2
drop if r==2


** child per person
g kids_r=children/size

** piped cleaning
replace piped=1 if piped==2

** clean wages
replace fwag=. if fwag_flg>1
replace cwag=. if cwag_flg>1
replace swag=. if swag_flg>1

xtset pid




foreach var of varlist piped elec rooms size inf house {
xtreg `var' rdp i.r, fe robust
xtreg `var' rdp i.r if sex==1, fe robust
xtreg `var' rdp i.r if sex==0, fe robust
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}

** INFORMAL SETTLEMENTS
* huge reduction in urban areas

** ROOMS
* rural areas reduction in rooms
* urban areas gain in rooms * * * INTERESTING IMPLICATIONS FOR SPLITTING

** ELEC
** actually reduces access to electricity! not pay for it? poor quality?
* in rural areas, maybe poorly constructed houses?

** PIPED
** gain in access to piped water in urban areas
*  nothing going on in rural areas

** HOW DO HOUSE ATTRIBUTES AFFECT SIZE CHANGES?
xtreg size piped elec rooms inf house i.r, fe robust
* more rooms means increase in size, but:
xtreg size rdp rooms i.r, fe robust
xtreg rooms rdp i.r if u==1, fe robust
xtreg rooms rdp i.r if u==0, fe robust
* RDP leads to a reduction in HHsize!?
* are other room changes additions to existing houses?
** or moving??

** FIRST LOOK AT EMPLOYMENT
xtset pid

xtreg e rdp i.r, fe robust cluster(hh1)
xtreg e rdp i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp i.r if u==1, fe robust cluster(hh1)
xtreg e rdp i.r if u==0, fe robust cluster(hh1)

xtreg e rdp piped elec rooms size i.r, fe robust cluster(hh1)
xtreg e rdp piped elec rooms size i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp piped elec rooms size i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp piped elec rooms size i.r if u==1, fe robust cluster(hh1)
xtreg e rdp piped elec rooms size i.r if u==0, fe robust cluster(hh1)
*  RURAL MEN HAVE REDUCTION IN EMPLOYMENT of 5% with 10% significance
* no movement for women

** CHECK UNEMPLOYMENT

xtreg ue rdp i.r, fe robust cluster(hh1)
xtreg ue rdp i.r if sex==1, fe robust cluster(hh1)
xtreg ue rdp i.r if sex==0, fe robust cluster(hh1)
xtreg ue rdp i.r if u==1, fe robust cluster(hh1)
xtreg ue rdp i.r if u==0, fe robust cluster(hh1)

xtreg ue rdp piped elec rooms size i.r, fe robust
xtreg ue rdp piped elec rooms size i.r if sex==1, fe robust
xtreg ue rdp piped elec rooms size i.r if sex==0, fe robust
xtreg ue rdp piped elec rooms size i.r if u==1, fe robust
xtreg ue rdp piped elec rooms size i.r if u==0, fe robust
*  ABSOLUTELY NOTHING

** NOW LOOK AT INCOME AND EXPENDITURE

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms size i.r, fe robust
}


foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms size inf house i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size inf house i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size inf house i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size inf house i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size inf house i.r if u==0, fe robust cluster(hh1)
}

*** EXPENDITURE
* expenditure increases in urban areas (increases dominate overall) 
* and decreases in rural areas (increases for women)

*** WAGE INCOME
* casual wage drops for rural women 
* (very cool result, women sort of losing informal employment? network story?)
* formal wage drops for urban women !!
* driven by women
*** KIDS DROP OUT OF SCHOOL?

*** RENT VALUE 
* both decrease

*** GOVERNMENT INCOME
* drops for rural areas (makes sense)
* labor income drops for urban women! further corroborating the story
* income drops, but not really from remittances, instead from women

*****************
** ROBUSTNESS: **
*****************

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}

** women results go away! except for formal wage results
** actually results are pretty consistent
*** think of good bias story

** CONTROL FOR EMPLOYMENT **

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms size e i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size e i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size e i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size e i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size e i.r if u==0, fe robust cluster(hh1)
}

** casual wage still decreases for women! in rural areas
* formal wage decreses for women in urban areas!

** CONTROL FOR CHILDREN
foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms size children i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if u==0, fe robust cluster(hh1)
}
* * SAME

foreach var of varlist inc inc_r inc_l inc_g fwag cwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms size children i.r if sex==1 & children>0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if sex==1 & children==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if sex==0 & children>0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size children i.r if sex==0 & children==0, fe robust cluster(hh1)
}
** nothing super interesting, but it does look like earnings are dropping for
* both men and women
g rdp_children=rdp*children

foreach var of varlist inc inc_r inc_l inc_g fwag cwag swag exp_i exp_f {
xtreg `var' rdp children rdp_children piped elec rooms i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp children rdp_children piped elec rooms i.r if sex==0, fe robust cluster(hh1)
}
* nothing fantastic here either

** LOOK AT HOURS
foreach var of varlist hrs hrs_s hrs_c {
xtreg `var' rdp piped elec rooms size i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms size i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist hrs hrs_s hrs_c {
replace `var'=. if `var'>80
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
** Really just no effect on hours, so people working the same, 
*    just getting paid less?

** NOW CHECK OUT OUTCOMES RELATIVE TO SIZE
foreach var of varlist  inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
g `var'_per=`var'/size
}

foreach var of varlist  inc inc_r inc_l inc_g mktv rent fwag cwag swag exp_i exp_f {
xtreg `var'_per rdp piped elec rooms i.r, fe robust cluster(hh1)
xtreg `var'_per rdp piped elec rooms i.r if sex==1, fe robust cluster(hh1)
xtreg `var'_per rdp piped elec rooms i.r if sex==0, fe robust cluster(hh1)
xtreg `var'_per rdp piped elec rooms i.r if u==1, fe robust cluster(hh1)
xtreg `var'_per rdp piped elec rooms i.r if u==0, fe robust cluster(hh1)
}
* self wage holds up, all holds up: DRIVEN BY WOMEN WORKING LESS
* * * wages for women versus men?!


*** NEED EVIDENCE OF COOL BEHAVIORAL STORY !!!


** still works: changing types of jobs?

*** BIG RESULT: WOMEN LABOR INCOME DECLINES SUBSTANTIALLY
* WHY?
 * 1.) 
* MORE KIDS, LESS PEOPLE TO TAKE CARE OF THEM?
* NUMBER OF KIDS, ratio of kids to adults?

foreach var of varlist size children kids_r {
xtreg `var' rdp piped elec i.r, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec i.r if u==0, fe robust cluster(hh1)
}
*** for rural and women! increase in kids per adult ***
* insignificant reduction in children
* large decline in size in urban areas, not in rural areas!
* likely to swap households?

* take out infrastructure controls (bigger effects?)
foreach var of varlist size children kids_r {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
* Same rural and women result, size effects less pronounced, as we might expect

** consistent with larger crowding issues in urban areas

sort pid r
by pid: g size_ch=size[_n]-size[_n-1]
egen m_size_ch=max(size_ch), by(pid)

hist size_ch if size_ch>-10 & size_ch<10, by(rdp)

** LOOK AT WHAT HAPPENS WHEN WE CONTROL FOR SIZE CHANGES DIFFERENTLY
foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag swag exp_i exp_f {
xtreg `var' rdp piped elec rooms i.r if m_size_ch>0, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms i.r if m_size_ch<0, fe robust cluster(hh1)
xtreg `var' rdp piped elec room=s i.r if m_size_ch>0 & u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec rooms i.r if m_size_ch<0 & u==1, fe robust cluster(hh1)
}

** INCREASES IN SIZE MEAN LESS WAGES AND MORE EXPENDITURES?
* those that had an increase in size; what is the counterfactual here?
** ** unclear
g rdp_size=rdp*size

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag swag exp_i exp_f {
xtreg `var' rdp size rdp_size piped elec rooms i.r, fe robust cluster(hh1)
xtreg `var' rdp size rdp_size piped elec rooms i.r if u==1, fe robust cluster(hh1)
}

foreach var of varlist inc inc_r inc_l inc_g mktv rent fwag swag exp_i exp_f {
xtreg `var' rdp size rdp_size piped elec rooms i.r if u==1 & sex==0, fe robust cluster(hh1)
}




 * 2.)
* worse labor market opportunities
* further from work, new/poor social networks
** look at travel to work, look at 
** ** ** if labor market opportunities are worse, then how does family react?


use clean_v1.dta, clear

** only look at adults
keep if a>18

** only look at housing responses
drop if rdp==.

** assign people to a household
drop if resident==0

*** GET RID OF ROUND 3
drop if r==3

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** get rid of those already with houses
g rdp_r1=(r==1 & rdp==1)
egen rdp_r1_max=max(rdp_r1), by(pid)
drop if rdp_r1_max==1

g kids_r=children/size

xtset pid

foreach var of varlist travel {
xtreg `var' rdp i.r, fe robust
xtreg `var' rdp i.r if sex==1, fe robust
xtreg `var' rdp i.r if sex==0, fe robust
xtreg `var' rdp i.r if u==1, fe robust
xtreg `var' rdp i.r if u==0, fe robust
}

* not much going on with travel cost



 
 * 3.) large gains for kids??




* look at determinants of splitting, also look at who's contributing to hh_size
** are more people comin in to the hh?
 


