* nids


cd "/Users/willviolette/Desktop/pstc_work/nids"

use reg3.dta, clear
sort hhid
merge hhid using child
drop if _merge==2
drop _merge

replace h=0 if h==2 | h==-3 | h==-8
replace h=1 if h==-9

egen h_max=max(h), by(pid)
sort pid r
replace h=0 if h==. & h[_n-1]==0
replace h=1 if h==. & h[_n-1]==1

sort pid r
by pid: g h_ch=(h[_n-1]==0 & h[_n]==1)
by pid: g h_ch_b=(h[_n]==0 & h[_n+1]==1)

g remit_1=. 
* tab r h_ch
replace h_ch=0 if r==1

egen h_ch_id=max(h_ch), by(pid)

g i=hh_income 
replace i=. if hh_income>20000

replace move_yr=. if move_yr>2012

g move_r=0
replace move_r=1 if r==1 & move_yr>=2006 & move_yr<=2008
replace move_r=1 if r==2 & move_yr>2008 & move_yr<=2010
replace move_r=1 if r==3 & move_yr>=2011 & move_yr<=2012

g inf=(dwell==7 | dwell==8 | dwell==2 | dwell==4)
g house=1 if dwell==1
replace house=0 if inf==1

sort pid r
g d_ch=(house[_n-1]==0 & house[_n]==1)

tab d_ch h_ch

tab d_ch h_ch if hh_income<10000

tab dwell if h_ch_b==1
tab dwell if h_ch==1

** WHO IS SWITCHING INTO HOUSING SUBSIDY???
* hist age if h_ch==1
* hist age if h_ch==0
** NO DIFFERENCE

replace move_yr=0 if move_yr==.
g mv=(move_yr>2007)
g h_ch_mv=h_ch*mv
g h_mv=h*mv

egen inf_id=max(inf), by(pid)
g h_inf_id=h*inf_id

****

foreach var of varlist age gender pop_grp marry marry_yrs move_yr child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 bp t_time_h t_time_m move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam h r {
replace `var'=. if `var'<0
replace `var'=. if `var'==9999
replace `var'=. if `var'==8888
replace `var'=. if `var'>70000
}

foreach var of varlist r age gender pop_grp marry marry_yrs move_yr district child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 bp t_time_h t_time_m move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam h h_ch h_ch_id i move_r inf house d_ch {
replace `var'=. if `var'<0
replace `var'=. if `var'==9999
replace `var'=. if `var'==8888
replace `var'=. if `var'>70000
}

** child variables
foreach var of varlist grade attend grade_max edu_res edu_rep d_sch_hrs d_sch_min ch_health {
replace `var'=. if `var'<0
replace `var'=. if `var'==9999
replace `var'=. if `var'==8888
replace `var'=. if `var'>70000
}


** child constructed variables

g t_sch=d_sch_hrs*60 + d_sch_min
replace t_sch=d_sch_hrs*60 if r==1
replace t_sch=. if t_sch>250

g rep=1 if edu_res==1 & r==1
replace rep=0 if edu_res==0 & r==1
replace rep=1 if edu_res==1 & r==2
replace rep=1 if edu_res==2 & r==2
replace rep=0 if edu_res==3 & r==2
replace rep=1 if edu_res==1 & r==3
replace rep=1 if edu_res==2 & r==3
replace rep=0 if edu_res==3 & r==3

g urb_d=(urb==2)

egen b=group(bdc)

xtset pid

foreach var of varlist remit_1 bike home_loan flu diar com2 move_rec own lndgrn lndrst  {
replace `var'=0 if `var'==2
}


g e_d=(emp_d==3)
g roof_iron=(roof==3)
g walls_brick=(walls==1)
g piped=(water==1 | water==2)
g u=(urb==2)

g occ_serv=(occ==5)
g occ_elem=(occ==9)

g married=(marry==1 | marry==2)


g a=.
replace a=. if age>2007
replace a=2008-age if r==1
replace a=2010-age if r==2
replace a=2012-age if r==3
replace a=. if a<0

save "nids_analysis1_child_edit.dta", replace




use "nids_analysis1_child_edit.dta", clear
*** get at household structure
** MEASURE HOUSEHOLD OVERLAP
** use oldest person in the household

* * * GET PEOPLE THAT MOVE IN!!

** look at pid duplicates?
g pid_r=pid*10+r
duplicates drop pid_r, force

g f=1
egen p_sum=sum(f), by(pid)
tab p_sum

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
 tab h_mv min_a_b_c_ch

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

**** ACCOUNTING!!!! ****
use "nids_analysis1_child_edit1.dta", clear

egen lomax=max(left_out), by(pid)
g lmax=(lomax==1 | left_in==1)

replace emp=0 if emp==2

g lo=left_out
g li=left_in
replace li=0 if h_ch==0
sort pid r
by pid: replace li=1 if li[_n-1]==1 & li[_n]==0

egen h_ch_m=max(h_ch), by(pid)
egen h_m=max(h), by(pid)
egen lo_m=max(lo), by(pid)
egen li_m=max(li), by(pid)

drop if r==1 | r==3
duplicates drop pid, force

tab h_m
tab h_ch_m
tab lo_m
tab li_m



use "nids_analysis1_child_edit1.dta", clear
* drop li

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

*  hist a if lo==1
*  hist a if li==1
* hist child if lo==1
* hist child if li==1

** DEMOGRAPHICS
** FOR URBAN
* foreach var of varlist married age marry_yrs child size fam {
* reg `var' h h_ch left_out i.r if hh_income<15000 & u==1, cluster(hhid) robust
* }
** BIGGER FAMILIES ARE GETTING HOUSING

** FOR RURAL
* foreach var of varlist married age marry_yrs child size fam {
* reg `var' h h_ch left_out i.r if hh_income<15000 & u==0, cluster(hhid) robust
* }
** LESS LIKELY TO BE MARRIED

* foreach var of varlist married age marry_yrs child size fam {
* reg `var' h h_ch left_out i.r if hh_income<15000 & u==0, cluster(hhid) robust
* }


** FIXED
** FOR URBAN

egen m_age=mean(a), by(hhid)

save "nids_analysis1_child_edit2.dta", replace


use "nids_analysis1_child_edit2.dta", clear

** Left in
foreach var of varlist c size fam m_age a gender married {
sum `var' if lo==1
sum `var' if li==1
}


foreach var of varlist c size fam m_age married {
xtreg `var' lo li i.r if u==1, fe robust
}


foreach var of varlist child size fam m_age {
xtreg `var' lo li i.r if urb==0, fe robust
}

foreach var of varlist child size fam m_age {
xtreg `var' h mv h_mv lo li i.r, fe robust
}

foreach var of varlist child size fam m_age {
xtreg `var' h mv h_mv lo li i.r if u==0, fe robust
}

foreach var of varlist child size fam m_age {
xtreg `var' h mv h_mv lo li i.r if u==1, fe robust
}


*** informal settlements!!! ***
foreach var of varlist child size fam {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1 & inf_max==1, fe robust
}

foreach var of varlist child size fam {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1, fe robust
}
foreach var of varlist child size fam {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1, fe robust
}
** LEFT OUT HOUSEHOLDS SHRINK BUT RECEIVING HOUSEHOLD DOESNT CHANGE
** CHILDREN LIKELY TO GO WITH HH IF IT MOVES ** IE: NO NEG FOR CHILDREN

** FOR RURAL
foreach var of varlist child size fam {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==0, fe robust
}
** NO EFFECTS ON FAMILY SIZE REALLY, SIMILAR SHRINKAGE IN LEFT OUT

 * * * * * * * * * * 
  * * * * * * * * * *
 * * * * * * * * * *
**** URBAN ALL AT ONCE

** REMITTANCES **

** LEFT IN
foreach var of varlist remit_1 remit remit_id {
xtreg `var' lo li i.r, fe robust
}

** REMITTANCES DECLINE FOR MOVERS & NON-MOVERS:
***  SOME EVIDENCE THAT INCREASE IN REMITTANCE FOR LEFT_OUT, BUT DECLINING VALUE!
***  AMONG TOTAL INCOME: REMITTANCES FOR LEFT_OUT DECLINE

** CHILDREN **
** LEFT-IN
foreach var of varlist t_sch rep ch_health  {
xtreg `var' lo li i.r, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h li lo i.r if u==1, fe robust
}
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h li lo i.r if u==0, fe robust
}
** CHILD HEALTH DELCLINES AND DISTANCE TO SCHOOL DECLINES ** ACROSS INCOME GROUPS


** wages with li lo
foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' li lo i.r, fe robust
}
foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' li lo i.r, fe robust
}






***** INFORMAL SETTLEMENTS
foreach var of varlist remit_1 remit remit_id {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1 & inf_max==1, fe robust
}

foreach var of varlist remit_1 remit remit_id {
xtreg `var' h mv h_mv lo li i.r if hh_income<10000 & u==1, fe robust
}
foreach var of varlist remit_1 remit remit_id {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1, fe robust
}
foreach var of varlist remit_1 remit remit_id {
xtreg `var' h mv h_mv left_out i.r if u==1, fe robust
}

* sum t_sch if lo==1
* sum t_sch if li==1

****** INFORMAL SETTLEMENTS: *****
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1 & inf_max==1, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv left_out piped elec i.r if hh_income<15000 & u==1, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h li lo i.r if hh_income<15000 & u==1, fe robust
}


* quick remittance check
g r_d=(remit!=.)

foreach var of varlist remit_1 r_d remit {
xtreg `var' h li lo i.r if u==1, fe robust
}
foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1 & inf_max==1, fe robust
}

foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h mv h_mv i.r if hh_income<15000 & u==1, fe robust
}

foreach var of varlist emp occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' lo li i.r, fe robust
}


** INCOMES **
foreach var of varlist emp inf occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1, fe robust
}
foreach var of varlist emp inf occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1, fe robust
}
foreach var of varlist emp inf occ_serv occ_elem e_d main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 hh_income fd tran wage  {
xtreg `var' h mv h_mv left_out i.r if u==1, fe robust
}

** LOOK INTO THE FUTURE WITH GHS TO GET LONG-TERM % $ % $ % $ % $ % $ % $ % $ % $

** POSITIVE HH INCOME, BUT DELCLINES IN SELF WAGE FOR RECIPIENTS (EXCEPT MOVERS)
** ESPECIALLY DECLINES FOR LEFT_OUT,  BUT INCREASES IN CAS_WAGE FOR LEFT_OUT
*** GREATER EMPLOYMENT AMONG LEFT_OUT * GENERALLY POSITIVE EXPECTATIONS, FOR EVERYONE

** HOUSING FACTORS
foreach var of varlist bp roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc govt remit food nonfood rent inf {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1, fe robust
}
** LEFT OUT MOVE INTO WORSE AREAS!! MORE LIKELY TO RENT: LESS SERVICES!
** MORE CRIME IN BOTH CASES!!:: INCOME DOES DECLINE FOR LEFT_OUT
foreach var of varlist bp roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc govt remit food nonfood rent inf {
xtreg `var' lo li i.r if hh_income<15000 & u==1, fe robust
}

foreach var of varlist bp roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc govt remit food nonfood rent inf {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1, fe robust
}
foreach var of varlist bp roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc govt remit food nonfood rent inf {
xtreg `var' h mv h_mv left_out i.r if u==1, fe robust
}
*** MOVE RECENTLY FOR LEFT OUT
xtreg move_r left_out i.r if u==1, fe robust
** SORTA POSITIVE BUT NOT REALLY

** OTHER FACTORS:::
foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv lo li i.r if hh_income<15000 & u==1, fe robust
}


foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv left_out i.r if hh_income<10000 & u==1, fe robust
}
** LEFT OUT ARE LESS LIKELY TO JOIN BURIAL SOCIETIES! BUT BETTER HEALTH, EXERCISE MORE
*** HH THAT MOVE SPEND LESS ON TRAVEL ** REDUCE DEPRESSION ETC.

foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==1, fe robust
}
foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv left_out i.r if u==1, fe robust
}

** DO RESULTS FOR NO LEFT OUT FAMILIES!!!!



** DO RURAL JUST FOR THE HELL OF IT
foreach var of varlist c size fam m_age  {
xtreg `var' h mv h_mv i.r if u==0, fe robust
}

** CHILDREN
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv lo li i.r if hh_income<10000 & u==0, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==0, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv left_out i.r if u==0, fe robust
}

foreach var of varlist t_sch rep ch_health  {
xtreg `var' lo li i.r if u==0, fe robust
}


** REDUCE CHILD HEALTH AND REPEAT GRADES??

foreach var of varlist emp inf occ_serv occ_elem  e_d  main_wage cas_wage self_wage  remit remit_1 pay inc_today inc_exp inc_exp5 ag hh_income fd tran urb size wage  {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==0, fe robust
}
* DECLINES IN INCOME AND EXPECTED *AS WELL AS REMITTANCES
** LEFT BEHIND IS MORE LIKELY TO LIVE IN INFORMAL SETTLEMENT

foreach var of varlist travel bike home_loan health flu diar exer dep emo stay religion com2 {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==0, fe robust
}
* DECLINE IN BURIAL SOCIETY BUT INCREASE IN RELIGION:
** REDUCTION IN DEPRESSION:: LO !!


foreach var of varlist bp roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc govt remit food nonfood rent {
xtreg `var' h mv h_mv left_out i.r if hh_income<15000 & u==0, fe robust
}

**********************************************
** LEFT OUT GROUP GETS WAY LESS REMITTANCES **
**********************************************




*** REDO FOR POOR SUBSIDY RECIPIENTS: ***

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h i.r if hh_income<10000, fe robust
}


foreach var of varlist gender married marry_yrs child emp occ_serv occ_elem pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com2   {
xtreg `var' h i.r if hh_income<10000, fe robust
}

foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id e_d roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam inf {
xtreg `var' h i.r if hh_income<10000, fe robust
}

foreach var of varlist occ_serv occ_elem {
xtreg `var' h i.r if hh_income<10000, fe robust
}

**** **** **** ****

** now look if it matters if households move
foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv i.r if hh_income<10000, fe robust
}


foreach var of varlist gender married marry_yrs child emp occ_serv occ_elem pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com2   {
xtreg `var' h mv h_mv i.r if hh_income<10000, fe robust
}

foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id e_d roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc fd tran u size ag hh_income wage govt remit food nonfood rent fam inf {
xtreg `var' h mv h_mv i.r if hh_income<10000, fe robust
}



*URBAN!!

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv u i.r if hh_income<10000, fe robust
}


foreach var of varlist married marry_yrs child emp occ_serv occ_elem pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com2   {
xtreg `var' h mv h_mv u i.r if hh_income<10000, fe robust
}

foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id e_d roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc fd tran size ag hh_income wage govt remit food nonfood rent fam inf {
xtreg `var' h mv h_mv u i.r if hh_income<10000, fe robust
}

**

** demographics
foreach var of varlist married age marry_yrs child size fam {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==1, fe robust
}

foreach var of varlist remit_1 remit remit_id {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==1, fe robust
}


foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==1, fe robust
}

foreach var of varlist married marry_yrs child emp occ_serv occ_elem pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com2   {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==1, fe robust
}

foreach var of varlist bp main_wage cas_wage self_wage remit_id e_d roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc fd tran size ag hh_income wage govt remit food nonfood rent fam inf {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==1, fe robust
}


** RURAL

foreach var of varlist t_sch rep ch_health  {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==0, fe robust
}


foreach var of varlist married marry_yrs child emp occ_serv occ_elem pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com2   {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==0, fe robust
}



foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id e_d roof_iron walls_brick own rent_1 mktv lndgrn lndrst piped elec crime inc fd tran size ag hh_income wage govt remit food nonfood rent fam inf {
xtreg `var' h mv h_mv i.r if hh_income<10000 & u==0, fe robust
}







use "nids_analysis1_child_edit1.dta", clear

egen inf_max=max(inf), by(pid)

replace emp=0 if emp==2
** look back at hh_income
drop fam_ch
sort pid r
by pid: g h_chb=(h[_n+1]==1 & h[_n]==0)
by pid: g inc_inst=(hh_income[_n-1])
foreach var of varlist child size fam dep emp crime {
by pid: g `var'_ch=`var'[_n-1]-`var'[_n]
}

g inst=(inc_inst<3500)

** keep if inc_inst<6000 & inc_inst>3000

foreach var of varlist fam_ch child_ch size_ch dep_ch crime_ch emp_ch {
ivregress 2sls `var' (h_ch=inst) if r==2, robust
}


* hist hh_income if h_chb==0 & hh_income<20000
* hist hh_income if h_chb==1 & hh_income<20000
* hist govt if h_chb==0 & hh_income<20000
* hist govt if h_chb==1 & hh_income<20000
* hist wage if h_chb==0 & hh_income<20000
* hist wage if h_chb==1 & hh_income<20000
* * * * * * * * * *

sort pid r
replace h=0 if h==. & h[_n-1]==0
replace h=1 if h==. & h[_n-1]==1
by pid: g h_ch1=(h[_n-1]==0 & h[_n]==1)

egen h_id=max(h), by(pid)

* duplicates drop pid, force
tab h_id
tab h_ch_id

*** %25 benefit from housing assistance
*** %15 gained housing!!
***************************************


