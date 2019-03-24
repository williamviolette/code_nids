
** AGAIN LOOK AT LEFTOVERS A BETTER WAY!!!!!!!!!!
use "nids_4.dta", clear
drop w1_h_* fd*
rename h_ch h_g

replace dep=1 if dep<0
replace emp=0 if emp==2 | emp<0
replace hh_income=. if hh_income<0 | hh_income>40000

g a1=a if a>=20
egen m_a=mean(a1), by(hhid)
replace rooms=. if rooms>10

egen children=sum(child), by(hhid)

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

egen m_rdp=mean(rdp), by(hh1 r)
g sp=(m_rdp>0 & m_rdp<1)

hist size if sp==1, by(rdp)
hist m_a if sp==1, by(rdp)
hist children if sp==1, by(rdp)
hist hh_income if sp==1 & hh_income<20000, by(rdp)

xtset hh1

foreach var of varlist hh_income m_a size children rooms veg veg_s chi_s { 
xtreg `var' rdp i.r if r==3, fe robust
}


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




