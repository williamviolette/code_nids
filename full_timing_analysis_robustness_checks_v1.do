
cd "/Users/willviolette/Desktop/pstc_work/nids"


*************************
** DISTANCE CHECKS **
*************************

use hh_v1, clear

keep if max_inc<10000
keep if tt!=.

g mdb=hhmdbdc2011
replace mdb=gc_mdbdc2011 if r>=2

g prov=hhprov2011
replace prov=gc_prov2011 if r>=2

tab prov h_ch

tab mdb h_ch if r==2
tab mdb h_ch if r==3

tab mdb rdp



sort pid r
by pid: g mdb_ch=(mdb[_n]!=mdb[_n-1])
replace mdb_ch=0 if r==1

tab mdb_ch r

tab mdb_ch h_ch

tab mdb_ch move

* urban definition does look pretty loose
tab mdb u if prov==5



**************************************************
***** GENERATE HOUSING PROXY CHANGE MEASURES *****
**************************************************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
keep if tt!=.

replace rooms=. if rooms>10
replace rooms=. if rooms==0

sort pid r
by pid: g house_ch=house[_n]-house[_n-1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g flush_ch=flush[_n]-flush[_n-1]
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
by pid: g bkyd_ch=bkyd[_n]-bkyd[_n-1]
by pid: g roof_cor_ch=roof_cor[_n]-roof_cor[_n-1]
by pid: g walls_b_ch=walls_b[_n]-walls_b[_n-1]

tab walls_b_ch roof_cor_ch if rdp==0 & u==1

tab walls_b_ch roof_cor_ch if rdp==0 & u==0
* rural areas very correlated


tab house_ch move if rdp==0
tab piped_ch move if rdp==0
tab flush_ch move if rdp==0
tab rooms_ch move if rdp==0
tab bkyd_ch move if rdp==0

tab house_ch piped_ch if rdp==0
tab house_ch flush_ch if rdp==0
tab rooms_ch house_ch if rdp==0

tab bkyd_ch piped_ch if rdp==0
tab bkyd_ch flush_ch if rdp==0
tab rooms_ch bkyd_ch if rdp==0

tab rooms_ch roof_cor_ch if rdp==0


xtset pid

xttrans h_dwltyp, t(r)
tab h_dwlmatroof
xttrans h_dwlmatroof, t(r)
xttrans h_dwlmatrwll, t(r)

*foreach var of varlist bkyd piped flush {
*replace `var'_ch=0 if `var'_ch==-1
*}


******************************
***** RDP PROXY DEFINITION *****
******************************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
keep if tt!=.

replace rooms=. if rooms>10
replace rooms=. if rooms==0

hist rooms, by(u rdp)

hist own_d, by(u h_ch)

hist rooms, by(u h_ch rdp)

hist mktv if mktv<50000, by(u h_ch)

hist h_dwltyp if mktv<50000, by(u h_ch)
** DO THIS BY PROVINCE




*** MAKE A PROXY THAT LOOKS LIKE AN RDP HOUSE IN DISGUISE

tab piped h_ch if u==1
* urban rdps have water
tab h_watsrc h_ch if u==0
* rural rdps have water including public tap

*** so h_watsrc equals 1 or 2, and h_watsrc between 1 and 3

tab h_dwltyp h_ch if u==1
* also for sure house==1
tab h_dwltyp h_ch if u==0
* for sure house==1

tab h_dwlmatrwll h_ch if u==1
* three types, 1 2 or 3
tab h_dwlmatrwll h_ch if u==0
* two types, 1 or 2

tab h_dwlmatroof h_ch if u==1
* five types of roof 1 2 3 9 12
tab h_dwlmatroof h_ch if u==0
* one type roof 3

tab rooms h_ch if u==1
tab rooms h_ch if u==0 & move==0
* four or less rooms

******************************
***** RDP PROXY ANALYSIS *****
******************************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
keep if tt!=.

replace rooms=. if rooms>10
replace rooms=. if rooms==0

*** RDPproxy ID variable ***
g rdpp_id=0
* URBAN
replace rdpp_id=1 if u==1 & piped==1 & house==1 & h_dwlmatrwll>=1 & h_dwlmatrwll<=3 & rooms<=7 & h_dwlmatroof>=1 & h_dwlmatroof<=3 
replace rdpp_id=1 if u==1 & piped==1 & house==1 & h_dwlmatrwll>=1 & h_dwlmatrwll<=3 & rooms<=7 & h_dwlmatroof==9
replace rdpp_id=1 if u==1 & piped==1 & house==1 & h_dwlmatrwll>=1 & h_dwlmatrwll<=3 & rooms<=7 & h_dwlmatroof==12
* RURAL
replace rdpp_id=1 if u==0 & water>=1 & water<=3 & house==1 & h_dwlmatrwll==1 & h_dwlmatroof==3 & rooms<=7
replace rdpp_id=1 if u==0 & water>=1 & water<=3 & h_dwltyp==6 & h_dwlmatrwll==1 & h_dwlmatroof==3 & rooms<=7


tab rdpp_id h_ch
tab h_ch u

replace rooms=. if rooms>10
replace rooms=. if rooms==0

tab rdpp
sort pid r
by pid: replace rdpp=1 if rdpp[_n-1]==1 & rdpp[_n]==0

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

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

egen max_a=max(a), by(pid)

xtset pid

** run kid's outcomes
xtreg edu rdp rdpp i.r if a<16 & a>10, fe robust cluster(hh1)

xtreg edu rdp rdpp i.r if max_a<16, fe robust cluster(hh1)

* very positive kids outcomes
reg c_att rdp rdpp i.r if a<18, robust cluster(hh1)

xtreg c_fees rdp rdpp i.r if a<18, fe robust cluster(hh1)

foreach var of varlist class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp rdpp left_in left_out_m left_out_n i.r if max_a<16 & max_a>8, fe robust cluster(hh1)
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
foreach var of varlist edu class_size absent c_health check_up c_ill {
xtset pid
xtreg `var' rdp rdpp i.r if max_a<17 & max_a>6, fe robust cluster(hh1)
xtreg `var' rdp rdpp i.r if max_a<17 & max_a>6 & u==1, fe robust cluster(hh1)
xtreg `var' rdp rdpp i.r if max_a<17 & max_a>6 & u==0, fe robust cluster(hh1)
}

****************************************
** INDIVIDUAL ANALYSIS WITH RDP PROXY **
****************************************

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
*** vast majority are moving together *** WHICH SUGGESTS BENEFITTING

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
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

replace rooms=. if rooms>10
replace rooms=. if rooms==0

sort pid r
by pid: g house_ch=house[_n]-house[_n-1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g flush_ch=flush[_n]-flush[_n-1]
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
by pid: g bkyd_ch=bkyd[_n]-bkyd[_n-1]
by pid: g roof_cor_ch=roof_cor[_n]-roof_cor[_n-1]
by pid: g walls_b_ch=walls_b[_n]-walls_b[_n-1]

g rdpp=(bkyd_ch!=0 & piped_ch!=0 & flush_ch!=0 & rooms_ch!=0 & move==0 & rdp==0)
*** Good RDP proxy?
tab rdpp
sort pid r
by pid: replace rdpp=1 if rdpp[_n-1]==1 & rdpp[_n]==0

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



