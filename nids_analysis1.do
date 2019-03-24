
cd "/Users/willviolette/Desktop/pstc_work/nids"

****

* use reg3.dta, clear

* sort pid hhid r
* order pid hhid r

* g h1=hhid if r==1
* egen hh1=max(h1), by(pid)
* g h2=hhid if r==2
* egen hh2=max(h2), by(pid)
* g h3=hhid if r==3
* egen hh3=max(h3), by(pid)

* order hh1 hh2 hh3

* replace age=. if age>2007
* replace h=0 if h==.


* g subs_1=(r==1 & h==1)
* egen subs_1m=max(subs_1), by(hh2)
* order subs_1 subs_1m
***
* g subs_2=(r==2 & h==1)
* egen subs_2m=max(subs_2), by(hh3)
* order subs_2 subs_2m


use reg3.dta, clear


sort pid r
g h_ch=(h[_n-1]==0 & h[_n]==1)
* tab r h_ch
replace h_ch=0 if r==1


*** this is the key:::
egen h_no_ch=min(h_ch), by(hhid)
tab h_no_ch
tab h_ch
*********
** looks like very few people are moving to subs beneficiaries
*********
egen h_ch_id=max(h_ch), by(pid)

g i=hh_income 
replace i=. if hh_income>20000

hist i if h_ch_id==1
hist i if h_ch==1
hist i if h_ch==0

replace move_yr=. if move_yr>2012

hist i if h_ch==1 & move_yr>2010

g move_r=0
replace move_r=1 if r==1 & move_yr>=2007 & move_yr<=2008
replace move_r=1 if r==2 & move_yr>=2008 & move_yr<=2011
replace move_r=1 if r==3 & move_yr>=2010 & move_yr<=2012

* hist i if h_ch==1 & move_r==1
* hist i if h_ch==0 & move_r==1

tab inc h_ch if move_r==1

** real household change: nobody in that household
** had access to a subsidy in the previous period



g inf=(dwell==7 | dwell==8 | dwell==2 | dwell==4)
g house=1 if dwell==1
replace house=0 if inf==1

sort pid r
g d_ch=(house[_n-1]==0 & house[_n]==1)

tab d_ch h_ch


** WHO IS SWITCHING INTO HOUSING SUBSIDY???

hist age if h_ch==1
hist age if h_ch==0
** NO DIFFERENCE

** CHANGE IN DWELLING TYPE???

g mv=(move_yr>2007)

g h_ch_mv=h_ch*mv

g h_mv=h*mv

****


foreach var of varlist pid hhid age gender pop_grp marry marry_yrs move_yr child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 bp t_time_h t_time_m move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own ownpid rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam h r {
replace `var'=. if `var'<0
}

g urb_d=(urb==2)


foreach var of varlist subs_2 subs_2m subs_1 subs_1m hh1 hh2 hh3 pid hhid r age gender pop_grp marry marry_yrs move_yr district child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17 bp t_time_h t_time_m move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own ownpid rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam h h1 h2 h3 h_ch h_ch1 h_ch_id i move_r inf house d_ch {
replace `var'=. if `var'<0
}

xtset pid

* xtreg size h age i.r, fe robust

foreach var of varlist age gender pop_grp marry marry_yrs move_yr child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17  {
xtreg `var' h age i.r, fe robust
}

foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own ownpid rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam  inf {
xtreg `var' h age i.r, fe robust
}

foreach var of varlist age gender pop_grp marry marry_yrs move_yr child emp occ pay travel remit_1 bike home_loan health flu diar exer dep emo stay inc_today inc_exp inc_exp5 religion com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 com11 com12 com13 com14 com15 com16 com17  {
xtreg `var' h mv h_mv age i.r, fe robust
}

foreach var of varlist bp move_rec main_wage cas_wage self_wage remit_id emp_d dwell rooms roof walls own ownpid rent_1 mktv lndgrn lndrst water elec crime inc fd tran urb size ag hh_income wage govt remit food nonfood rent fam  inf {
xtreg `var' h mv h_mv age i.r, fe robust
}




***
**
foreach var of varlist ag fd inc tran hh_income wage govt remit food nonfood {
xtreg `var' h age i.r, fe robust
}

foreach var of varlist travel urb_d main_wage cas_wage self_wage pay emp exer dep emo stay health flu diar {
xtreg `var' h age i.r, fe robust
}

g l=(lndrst==1)

foreach var of varlist travel urb_d main_wage cas_wage self_wage pay emp exer dep emo stay health flu diar {
xtreg `var' l age i.r, fe robust
}




** control: urb


tab size h

** first things first: who's getting the houses?

tab h, mis


* 1.) 2008
* 2.) 2010-2011
* 3.) 2012



tab move_rec h_ch

reg move_rec h_ch, robust

tab move_rec r

tab move_yr
tab move_yr h_ch

tab move_yr h

* now make a movement variable
** what can we do with it?

g move_r=0
replace move_r=1 if r==1 & move_yr>=2007 & move_yr<=2008
replace move_r=1 if r==2 & move_yr>=2008 & move_yr<=2011
replace move_r=1 if r==3 & move_yr>=2010 & move_yr<=2012

tab move_r h_ch

***
* marriage eligibility doesn't really work
***
tab marry h_ch

** What else can I do with this data?

*** LOOK AT THE VALUE OF THE SUBSIDY TO GET AT PEOPLE ACTUALLY GETTING IT
** As it turns out I don't think people actually even move out of their 
** suburb counter to popular logic

tab mktv if h==1

tab dwell h
tab own h

tab lndrst lndgrn

replace hh_income=. if hh_income>20000

* * * * * * *** *** * * * * * * *** * * * * 
**** nothing remotely income threshold wise
****************************************
twoway hist hh_income if h==1, color(blue) || hist hh_income if h==0








