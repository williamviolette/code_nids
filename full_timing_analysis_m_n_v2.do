
cd "/Users/willviolette/Desktop/pstc_work/nids"

*************************
*** DISTANCE MEASURES ***
*************************
use hh_v1, clear

keep if tt!=.

xtset pid
xtreg sch_d rdp i.r if sch_d<50, fe robust
xtreg sch_d rdp i.r if sch_d<50 & u==1, fe robust
xtreg sch_d rdp i.r if sch_d<50 & u==0, fe robust

replace travel=. if travel==0
replace travel=. if travel>300

xtreg travel rdp i.r, fe robust
xtreg travel rdp i.r if u==1, fe robust
xtreg travel rdp i.r if u==0, fe robust
** nothing for travel/commuting times


*******************************
** LEFT-IN LEFT-OUT ANALYSIS **
*******************************
use hh_v1, clear

******* MOVE TOGETHER GROUPS *********
duplicates tag hh1 hhid, g(dup)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<10000
* keep if sr==321
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
g left_out_m=left_out*move
g left_out_n=left_out
replace left_out_n=0 if move==1
* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1
g left_in_m=left_in*move
g left_in_n=left_in
replace left_in_n=0 if move==1
g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

xtset hh1

keep if tt!=.
* replace zeroes
replace left_out_m=0 if r==1
replace left_out_n=0 if r==1
replace left_in_m=0 if r==1
replace left_in_n=0 if r==1

** DEMOGRAPHICS **
foreach var of varlist marry tog size a sex children child edu child_out {
xtreg `var' rdp i.r if m_rdp>0 & m_rdp<1, fe robust
xtreg `var' rdp i.r if u==1 & m_rdp>0 & m_rdp<1 , fe robust
xtreg `var' rdp i.r if u==0 &  m_rdp>0 & m_rdp<1, fe robust
}
** nothing on relationships, which is kind of interesting!

** HOUSE CHARACTERISTICS **
foreach var of varlist own own_d paid_off rooms elec piped flush mktv walls_b roof_cor house inf rent {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
 
** EMPLOYMENT **
g remit_percent=inc_r/inc

foreach var of varlist e_hh e ue exp_i exp_f m_shr fwag cwag swag inc inc_r inc_l inc_g remit_percent hrs {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
*** not a lot of movement on household level employment measures
* averaged: why not? are other people joining?
g size_2=size*size
reg exp_f size size_2 i.r, robust cluster(hh1)

** children
g children_2=children*children
reg exp_f children children_2 i.r, robust cluster(hh1)





*************************
** KIDS ANALYSIS **
*************************

use hh_v1, clear

******* MOVE TOGETHER GROUPS *********
duplicates tag hh1 hhid, g(dup)

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1

keep if max_inc<10000

* keep if sr==321
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
g left_out_m=left_out*move
g left_out_n=left_out
replace left_out_n=0 if move==1

* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1
g left_in_m=left_in*move
g left_in_n=left_in
replace left_in_n=0 if move==1

g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

xtset pid

keep if tt!=.

* replace zeroes
replace left_out_m=0 if r==1
replace left_out_n=0 if r==1
replace left_in_m=0 if r==1
replace left_in_n=0 if r==1

g a_2=a*a
egen max_a=max(a), by(pid)

** expenditures on food?
g exp_f_per=exp_f/children
xtreg exp_f_per rdp i.r, fe robust cluster(hh1)
* not expenditures on food
*** lower rent?


** run kid's outcomes
xtreg edu rdp i.r if a<16 & a>10, fe robust cluster(hh1)

xtreg edu rdp i.r if max_a<16, fe robust cluster(hh1)

* very positive kids outcomes
reg c_att rdp i.r if a<18, robust cluster(hh1)

xtreg c_fees rdp i.r if a<18, fe robust cluster(hh1)

foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp left_in left_out_m left_out_n i.r if max_a<16 & max_a>8, fe robust cluster(hh1)
xtset hh1
xtreg `var' rdp left_in left_out_m left_out_n i.r if max_a<16 & max_a>8, fe robust cluster(hh1)
}

foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp i.r if max_a<16 & max_a>8, fe robust cluster(hh1)
xtset hh1
xtreg `var' rdp i.r if max_a<16 & max_a>8, fe robust cluster(hh1)
}



foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp left_in left_out_m left_out_n piped elec flush i.r if max_a<16 & max_a>10, fe robust cluster(hh1)
}
** robust to controlling for services

foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp size left_in left_out_m left_out_n piped elec flush i.r if max_a<16 & max_a>10, fe robust cluster(hh1)
}
** robust to controlling for household size changes

foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp inf size left_in left_out_m left_out_n piped elec flush i.r if max_a<16 & max_a>10, fe robust cluster(hh1)
}

* cut by urban and rural
foreach var of varlist class_size absent c_health check_up c_ill heigh weight {
xtset pid
xtreg `var' rdp i.r if a<16 & a>8, fe robust cluster(hh1)
xtreg `var' rdp i.r if a<16 & a>8 & u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if a<16 & a>8 & u==0, fe robust cluster(hh1)
}

foreach var of varlist class_size absent c_health check_up c_ill heigh weight {
xtset pid
xtreg `var' rdp piped elec flush i.r if a<16 & a>8, fe robust cluster(hh1)
xtreg `var' rdp piped elec flush i.r if a<16 & a>8 & u==1, fe robust cluster(hh1)
xtreg `var' rdp piped elec flush i.r if a<16 & a>8 & u==0, fe robust cluster(hh1)
}


*************************
** INDIVIDUAL ANALYSIS **
*************************

use hh_v1, clear

******* MOVE TOGETHER GROUPS *********
duplicates tag hh1 hhid, g(dup)

tab h_ch move
tab dup move if h_ch==0 & r==2
tab dup move if h_ch==1 & r==2
* we see drop off of duplicates
* but we find that about half of movers
* are moving alone: this is probably very endogenous
*** probably ok under the non-movers
*** vast majority are moving together

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1

keep if max_inc<10000

* keep if sr==321
* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
g left_out_m=left_out*move
g left_out_n=left_out
replace left_out_n=0 if move==1

* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1
g left_in_m=left_in*move
g left_in_n=left_in
replace left_in_n=0 if move==1

* replace zeroes
replace left_out_m=0 if r==1
replace left_out_n=0 if r==1
replace left_in_m=0 if r==1
replace left_in_n=0 if r==1

g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size
g remit_per=inc_r/inc

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1


xtset pid

keep if tt!=.

keep if a>18

g adults=size-children

*** only keep successful interviews!
* keep if hh_outcome==1
* keep if ind_outcome==1
* pretty robust to this, most of these obs are dropped anyways
foreach var of varlist e ue send_r rec_d_r inc_r_per remit_per inf {
xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
}


foreach var of varlist e ue send_r rec_d_r inc_r_per remit_per inf {
xtreg `var' rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

*** neighborhood characteristics
foreach var of varlist  theft domvio vio gang murder drug own own_d rent {
xtreg `var' rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

** 	
*** other characteristics
foreach var of varlist child  inc_per inc_l_per inc_r_per exp_i exp_f hrs tog marry {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
}
** nothing for travel and hrs: hard to get much more than extensive margin on employment
* child jumps like crazy!

** unemployment among women, more kids? YES! KID's OUTCOMES!
**** ownership graphs
**** rent

*************************
** HOUSEHOLD ANALYSIS **
*************************

use hh_v1, clear

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1

keep if max_inc<10000

keep if a>18

* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
g left_out_m=left_out*move
g left_out_n=left_out
replace left_out_n=0 if move==1

* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1
g left_in_m=left_in*move
g left_in_n=left_in
replace left_in_n=0 if move==1

g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

xtset hh1

keep if tt!=.

g hoh_sex=hoh*sex
g hoh_edu=hoh*edu
* men's share of income
g m_shr=fwag*sex
replace m_shr=m_shr/inc

g oldd=a>65
egen old=sum(oldd), by(hhid)

collapse (sum) child (mean) e_hh tsm child_out size a hoh_sex sex children hoh_edu edu e ue own own_d paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f m_shr fwag cwag swag sch_d travel marry tog inf house inc inc_r inc_l inc_g rdp u hrs old rent, by(r hh1)

g kid_ratio=children/size
xtreg kid_ratio rdp i.r, fe robust

xtreg children rdp child i.r, fe robust
*** non-biological children live with the family!!!!!

** DEMOGRAPHICS **
foreach var of varlist marry tog size a hoh_sex sex children hoh_edu edu old child_out {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
** nothing on relationships, which is kind of interesting!

** HOUSE CHARACTERISTICS **
foreach var of varlist own own_d paid_off rooms elec piped flush mktv walls_b roof_cor house inf rent {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
 
** EMPLOYMENT **
g remit_percent=inc_r/inc

foreach var of varlist e_hh e ue exp_i exp_f m_shr fwag cwag swag inc inc_r inc_l inc_g remit_percent hrs {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
}
*** not a lot of movement on household level employment measures
* averaged: why not? are other people joining?
g size_2=size*size
reg exp_f size size_2 i.r, robust cluster(hh1)

** children
g children_2=children*children
reg exp_f children children_2 i.r, robust cluster(hh1)



