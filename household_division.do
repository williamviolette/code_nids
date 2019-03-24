* nids


cd "/Users/willviolette/Desktop/pstc_work/nids"

use "nids_analysis1_child_edit.dta", clear
foreach var of varlist re_* {
rename `var' `var'_r
}
sort pid
save "nids_analysis1_child_edit_r.dta", replace

use "nids_analysis1_child_edit.dta", clear
keep re_* pid hhid r
drop pid
rename re_pid1 pid
sort pid
save "remit_m1.dta", replace

use "nids_analysis1_child_edit_r.dta", clear

merge pid using remit_m1
tab _merge
* DOESNT WORK MERGING REMITS



** GET RID OF RICH PEOPLE
drop if hh_income>20000

g owner=(pid==ownpid)
sort pid r
by pid: g h_ch2=h_ch[_n-1]
by pid: g owner1=owner[_n-1]

** LOOK AT THE OWNER **


* get a sense for age hist a if owner==1 & h_ch==1
* hist a if owner==0 & h_ch==1

* egen m_a_s=mean(a) if h_ch==1, by(size)
* twoway scatter m_a_s size if size<11

tab owner h_ch

tab h ownpaid
tab h_ch ownpaid


** INCOME ELIGIBILITY BY OWNER ** GET AN RD!?


*  hist pay if h_ch1==1 & owner1==1 & pay<20000
*  ONLY 151! 

tab pay if h_ch2==1 & owner1==1 & pay<20000

*  hist a if owner==1
* hist a if owner==0

*** get at household structure
** MEASURE HOUSEHOLD OVERLAP
** use oldest person in the household

* * * GET PEOPLE THAT MOVE IN!!
replace child=0 if child==.

** look at pid duplicates?
g pid_r=pid*10+r
duplicates drop pid_r, force

g f=1
egen p_sum=sum(f), by(pid)
tab p_sum


* * * NEED AN ID FOR HOUSEHOLD THAT BREAKS UP, THAT IS SOLID OVER TIME

* * *
* * PEOPLE LEAVING THE HOUSEHOLD
* * * 
* for round 2:
g h_ch_2=(h_ch==1 & r==2)
egen m_p_2=max(h_ch_2), by(pid)
egen m_h_2=max(m_p_2), by(hhid)
g left_out2=(m_h_2==1 & m_p_2==0 & r==1)

egen mlo2=max(left_out2), by(pid)
egen left_in2=max(left_out2), by(hhid)
replace left_in2=0 if left_out2==1
egen left_in2m=max(left_in2), by(pid)

g lo2=(mlo2==1 & r==2)


egen left_out2_hh=sum(left_out2), by(hhid)


* for round 3:
g h_ch_3=(h_ch==1 & r==3)
egen m_p_3=max(h_ch_3), by(pid)
egen m_h_3=max(m_p_3), by(hhid)
g left_out3=(m_h_3==1 & m_p_3==0 & r==2)

egen mlo3=max(left_out3), by(pid)
egen left_in3=max(left_out3), by(hhid)
replace left_in3=0 if left_out3==1
egen left_in3m=max(left_in3), by(pid)

g lo3=(mlo3==1 & r==3)

egen left_out2_m=max(left_out2), by(pid)
egen left_out3_m=max(left_out3), by(pid)

** LEFT OUT
g left_out=lo2+lo3

sort pid r
by pid: replace left_out=1 if left_out[_n-1]==1

** LEFT IN
g left_in=(left_in2m==1 | left_in3m==1)

egen s_lo=sum(left_out), by(hhid)

** HOUSEHOLD BREAK UP INDICATOR
* sort pid r
* by pid: g b_id_lo=(left_out[_n]==0 & left_out[_n+1]==1)
* egen b_id=max(b_id_lo), by(hhid)

g li2=left_in2m if r==2
replace li2=0 if li2==.
g li3=left_in3m if r==3
replace li3=0 if li3==.

egen li2m=max(li2), by(hhid)
egen li3m=max(li3), by(hhid)

g li=li2m+li3m

sort pid r
g li1=(li[_n+1]==1)
g h_ch1=(h_ch[_n+1]==1)

g t_sch_child=t_sch*child
g crime_a=crime*a
g crime_child=crime*child

** li are those that got the housing and left some people out
* * * the following regressions compare people that got housing and left some people behind
* * to people that got housing but didn't leave people behind

*** GREATER TIME TO SCHOOL MEANS GREATER LIKELIHOOD OF BREAKING UP (BREAK UP FOR NEW FAMILIES)
reg li t_sch i.r if h_ch==1, robust cluster(hhid)
* * t_sch is likely exogenous: measure of location within community

** look at change in number of kids and change in t_sch
sort pid r
by pid: g t_sch_ch=t_sch[_n]-t_sch[_n-1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g elec_ch=elec[_n]-elec[_n-1]

by pid: g size_ch=size[_n]-size[_n-1]

by pid: g kids_ch=child[_n]-child[_n-1]
by pid: g kids_per=child[_n]/child[_n-1]

tab kids_per li if h_ch==1

reg kids_per t_sch_ch if h_ch==1, cluster(hhid) robust

* doesn't work when looking at percentage, but that's a weird measure anyways

reg kids_ch t_sch_ch if h_ch==1, cluster(hhid) robust
reg kids_ch t_sch_ch if h_ch==1 & kids_ch>-4 & kids_ch<4, cluster(hhid) robust

** reg child t_sch if h==1, cluster(hhid) robust
** DOESN'T WORK

* NOW TRY FOR WATER
** NOT MUCH GOING ON IN WATER, TRY INTRODUCING A LITTLE MORE VARIATION
g w=0
replace w=3 if water==1
replace w=2 if water==2
replace w=1 if water==3

reg kids_ch w if h_ch==1, cluster(hhid) robust
* also: nothing!

*** NEED TO SHOW NO CORRELATION BETWEEN EARLY FACTORS AND HOUSE ATTRIBUTES
reg a w elec t_sch u if h_ch==1, cluster(hhid) robust
reg u w elec t_sch if h_ch==1, cluster(hhid) robust

* * NEED TO DO URBAN AND RURAL SEPARATELY
* EXOGENOUS ATTRIBUTES
reg li w elec t_sch u if h_ch==1, cluster(hhid) robust
* URBAN RURAL SEPARATELY
reg li w elec t_sch if u==1 & h_ch==1, cluster(hhid) robust
reg li w elec t_sch if u==0 & h_ch==1, cluster(hhid) robust
*** HUGE: SCHOOL DISTANCE IS RELEVANT IN RURAL & HOUSE SIZE
*** SERVICES: RELEVANT IN URBAN AREAS

** NOW LOOK AT CHILD CHANGES
reg kids_ch w elec t_sch if u==1 & h_ch==1, cluster(hhid) robust
reg kids_ch w elec t_sch if u==0 & h_ch==1, cluster(hhid) robust

reg child w elec t_sch if u==1 & h_ch==1, cluster(hhid) robust
reg child w elec t_sch if u==0 & h_ch==1, cluster(hhid) robust
** NOTHING GOING ON

** SAMPLE SIZE DROPS SO MUCH IN RURAL AREAS THAT IT MIGHT NOT MAKE SENSE
** ANYWAYS


** SIZE:
reg size w elec t_sch if u==1 & h_ch==1, cluster(hhid) robust
reg size w elec t_sch if u==0 & h_ch==1, cluster(hhid) robust

reg size_ch w elec t_sch u if h_ch==1, cluster(hhid) robust
reg size_ch w elec t_sch if u==1 & h_ch==1, cluster(hhid) robust
reg size_ch w elec t_sch if u==0 & h_ch==1, cluster(hhid) robust
** GREATER PLACES WITH ELECTRICITY: IN URBAN AREAS

reg li w a child t_sch i.r if h_ch==1, cluster(hhid) robust

reg li t_sch u i.r if h_ch==1, cluster(hhid) robust
reg li size u i.r if h_ch==1, cluster(hhid) robust

** ** reg size w if h_ch==1, cluster(hhid) robust
reg size w u i.r if h_ch==1, cluster(hhid) robust

reg w u if h_ch==1, cluster(hhid) robust


reg size t_sch if h_ch==1 & u==1, cluster(hhid) robust
reg size elec if h_ch==1, cluster(hhid) robust


reg li elec if h_ch==1, cluster(hhid) robust
* * * *
reg kids_ch w if h_ch==1, cluster(hhid) robust

* * * *

reg li child if h_ch==1, cluster(hhid) robust

reg li size if h_ch==1, cluster(hhid) robust

reg li kids_ch if h_ch==1, cluster(hhid) robust


reg li t_sch if h_ch==1, cluster(hhid) robust
reg size_ch t_sch if h_ch==1, cluster(hhid) robust


**** **** **** **** **** **** ****
* still robust

reg li t_sch_ch if h_ch==1, cluster(hhid) robust
reg kids_ch li if h_ch==1, cluster(hhid) robust

** these regressions are pretty endogenous FYI, but the changes help
reg kids_ch piped_ch if h_ch==1, cluster(hhid) robust
** WATER and T_SCH IS DRIVING WHERE KIDS GO
*** *** *** *** *** *** *** *** *** ***

reg kids_ch elec_ch if h_ch==1, cluster(hhid) robust
reg li piped_ch if h_ch==1, cluster(hhid) robust


* reg li child i.r if h_ch==1, robust cluster(hhid)
* reg li a i.r if h_ch==1, robust cluster(hhid)
* reg li size i.r if h_ch==1, robust cluster(hhid)

reg li elec i.r if h_ch==1, robust cluster(hhid)
reg li water i.r if h_ch==1, robust cluster(hhid)

** ROOMS IS UNCORRELATED
replace rooms=. if rooms>8

reg li rooms i.r if h_ch==1, robust cluster(hhid)

** MARKET VALUE

reg li mktv i.r if h_ch==1, robust cluster(hhid)

** CRIME

reg li crime a crime_a i.r if h_ch==1, robust cluster(hhid)
reg li crime child crime_child i.r if h_ch==1, robust cluster(hhid)

**************** * * * * * * * * * *
****************  * * * * * * * * * *
*** NOW LOOK AT EXISTING CONDITIONS OF THE FAMILY::
** IN THE TIME BEFORE

reg li1 child i.r if h_ch1==1, robust cluster(hhid)
*** GREATER TIME TO SCHOOL MEANS GREATER LIKELIHOOD OF BREAKING UP
reg li1 t_sch child t_sch_child i.r if h_ch1==1, robust cluster(hhid)
reg li1 elec i.r if h_ch1==1, robust cluster(hhid)
reg li1 water i.r if h_ch1==1, robust cluster(hhid)
reg li1 rooms i.r if h_ch1==1, robust cluster(hhid)
** MARKET VALUE
reg li1 mktv i.r if h_ch1==1, robust cluster(hhid)
** CRIME
reg li1 crime i.r if h_ch1==1, robust cluster(hhid)

reg li1 hh_income crime mktv rooms elec water t_sch child a i.r if h_ch1==1, robust cluster(hhid)
**************** * * * * * * * * * *
****************  * * * * * * * * * *


egen min_a=min(age), by(hhid)

g age1=age
replace age1=. if age1==min_a
egen min_b=min(age1), by(hhid)
g min_a_b=min_a+min_b

g age2=age1
replace age2=. if age1==min_b
egen min_c=min(age2), by(hhid)
g min_a_b_c=min_a+min_b+min_c

egen max_a=max(age), by(hhid)

sort pid r
by pid: g min_a_ch=(min_a[_n]!=min_a[_n-1])
replace min_a_ch=0 if r==1
by pid: g min_b_ch=(min_b[_n]!=min_b[_n-1])
replace min_b_ch=0 if r==1
by pid: g min_a_b_ch=(min_a_b[_n]!=min_a_b[_n-1])
replace min_a_b_ch=0 if r==1
by pid: g min_a_b_c_ch=(min_a_b_c[_n]!=min_a_b_c[_n-1])
replace min_a_b_c_ch=0 if r==1
by pid: g max_a_ch=(max_a[_n]!=max_a[_n-1])
replace max_a_ch=0 if r==1

* tab h_ch min_a_ch
* tab h_ch min_b_ch
* tab h_ch min_a_b_ch
* tab h_ch min_a_b_c_ch
* tab h_ch max_a_ch
* tab h_mv min_a_b_c_ch

* tab h_mv min_a_ch

sort pid r
by pid: g fam_ch=(fam[_n]!=fam[_n-1])
replace fam_ch=0 if r==1

tab h_ch fam_ch

* xtset pid
* xtreg fam h i.r, fe robust

* use "nids_analysis1_child_edit.dta", clear

** URBAN TO RURAL?



sort pid r
g u_ch=(u[_n]!=u[_n-1])
replace u_ch=0 if r==1

replace age=. if age>2012

save "nids_analysis1_child_edit1.dta", replace

****************  * * * * * * * * * * 
**************** * * * * * * * * * * 
*** ANALYSIS ***  * * * * * * * * * *
**************** * * * * * * * * * *
****************  * * * * * * * * * *

use "nids_analysis1_child_edit1.dta", clear

egen c = max(child), by(hhid r)

egen inf_max=max(inf), by(pid)

egen lomax=max(left_out), by(pid)
g lmax=(lomax==1 | left_in==1)

replace emp=0 if emp==2

g lo=left_out
g li=left_in
replace li=0 if h_ch==0
sort pid r
by pid: replace li=1 if li[_n-1]==1 & li[_n]==0

 hist a if lo==1
 hist a if li==1
