
cd "/Users/willviolette/Desktop/pstc_work/nids"

**** NOW DROP THOSE THAT MOVE AND GET SUBSIDIES
** BASICALLY THE IMPACT OF IN-SITU UPGRADING
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

keep if a>18

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


* most have atleast 2 people staying together in the move

** just look at what happens with those who are left_out!
* don't need to differentiate too much

xtset pid

keep if tt!=.

*** only keep successful interviews!
* keep if hh_outcome==1
* keep if ind_outcome==1
* pretty robust to this, most of these obs are dropped anyways

foreach var of varlist e ue {
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
*** kids characteristics
foreach var of varlist child  inc_per inc_l_per inc_r_per travel exp_i exp_f  {
xtreg `var' rdp i.r, fe robust cluster(hh1)
}
* child jumps like crazy!

** unemployment among women, more kids? YES! KID's OUTCOMES!
**** ownership graphs
**** rent


******** CHECK THE BALANCE PLEASE && THAT'S THE BIG ONE! *********

use hh_v1, clear
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

xtset pid

sort pid r
by pid: g h_sw_m=rdp_m[_n+1]-rdp_m[_n]
by pid: g h_sw_n=rdp_n[_n+1]-rdp_n[_n]

** focus on second round, people without rdp
keep if r<=2 & rdp==0
drop rdp_m
egen rdp_m=max(h_sw_m), by(hhid)
drop rdp_n
egen rdp_n=max(h_sw_n), by(hhid)

collapse rdp rdp_m rdp_n edu a sex children size af inc e ue rooms piped elec inf, by(hh1 r u)

foreach var of varlist a sex edu children size af inc e ue rooms piped elec inf {
sort hh1 r
by hh1: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}

label variable rdp "RDP"

reg rdp_m a sex edu children size inc e ue rooms piped elec inf if u==1, robust
reg rdp_n a sex edu children size inc e ue rooms piped elec inf if u==1, robust
reg rdp_m a sex edu children size inc e ue rooms piped elec inf if u==0, robust
reg rdp_n a sex edu children size inc e ue rooms piped elec inf if u==0, robust


********* TOTAL OBSERVATIONS ***********************
** Use THE FULL SET OF OBSERVATIONS
use hh_v1, clear

keep if max_inc<10000

keep if a>18

* keep if sr==321

keep if tt!=.

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

foreach var of varlist  size {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist  *_per rent own own_d e ue {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
}

foreach var of varlist  *_per rent own e ue {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist cwag swag fwag rent_d own {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf inc inc_l inc_r rooms piped flush size children {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}

foreach var of varlist e ue cwag swag fwag inf size children rent mktv {
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if sex==0, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==1, fe robust cluster(hh1)
xtreg `var' rdp_m rdp_n left_in_m left_in_n left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
}


