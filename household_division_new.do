** NEW HH DIVISION

cd "/Users/willviolette/Desktop/pstc_work/nids"

use "reg3_1", clear

sort hhid
merge hhid using child
drop if _merge==2
drop _merge

save "div1.dta", replace

*****
 *****
  *****
use "div1.dta", clear
sort pid r
duplicates drop pid r, force

** ROUND2:
forvalues r=1/15 {
sort hhid pid
by hhid: g pid_`r'=pid[`r']
replace pid_`r'=0 if pid_`r'==.
* variable for each member in period 1

g id_`r'=0
replace id_`r'=pid_`r' if r==2
egen id2_`r'=max(id_`r'), by(pid)
drop id_`r'
* variable for each member in period 2
}

forvalues r=1/15 {
forvalues z=1/15 {
g u_`r'_`z'=(id2_`r'==pid_`z' & id2_`r'!=0 & pid_`z'!=0)
}
}

egen final2=rowtotal(u_*)
replace final2=. if r>1

drop u_* id2_* pid_*

g i=1
egen hs=sum(i), by(hhid)

g fr=final2/hs

xtset hhid
xtreg fr edu if r==1, fe robust

** FINALLY MAKE THE HHIDS!
* forvalues r=1/15 {
* sort hhid pid
* by hhid: g pid`r'=pid[`r']
* replace pid`r'=0 if pid`r'==.
* }

** ROUND 2 SPLITTING
forvalues r=1/15 {
g pid_22_`r'=0
replace pid_22_`r'=pid`r' if r==2
egen pid_2_`r'=max(pid_22_`r'), by(pid)
drop pid_22_`r'
g iz_`r'_1=(pid_2_`r'==pid & r==1)
* egen i2_`r'_1=max(i_`r'_1), by(hhid)
egen it_`r'=max(iz_`r'_1), by(hhid)
}

** ROUND 3 SPLITTING
forvalues r=1/15 {
g pid_33_`r'=0
replace pid_33_`r'=pid`r' if r==3
egen pid_3_`r'=max(pid_33_`r'), by(pid)
drop pid_33_`r'
g iy_`r'_3=(pid_3_`r'==pid & r==2)
* egen i2_`r'_1=max(i_`r'_1), by(hhid)
egen it3_`r'=max(iy_`r'_3), by(hhid)
}

egen s=rowtotal(it_*)
egen s2=rowtotal(it3_*)

g sr1=s/hs
g sr2=s2/hs
tab sr1 if r==1
tab sr2 if r==2
g sr=sr1
replace sr=sr2 if sr1==0
* tab sr r

egen sr_max=max(sr), by(hhid)
egen sr_min=min(sr), by(hhid)

g wn=(sr==sr_max)
g wo=(sr==sr_min)

*** MAKE VARIABLES AND CLEAN ***

* RDP
g rdp=(h==1 | h==-9)

sort pid r
by pid: g h_ch=(rdp[_n-1]==0 & rdp[_n]==1)
egen h_ch_id=max(h_ch), by(pid)
egen h_ch_hh=max(h_ch_id), by(hhid)

* tab sr h_ch_id if r==1
* tab h_ch_hh if r==1
* get a sense for size of households
* hist s if r==1

reg sr h_ch_hh i.r if r!=3, robust cluster(hhid)

* income censor
keep if hh_income<10000

* urban
g u=(urb==2)

g a=2008-age if r==1
replace a=2010-age if r==2
replace a=2012-age if r==3
replace a=. if a<0

g child_d=(child>0 & child<.)
g e=(emp==1)
g m=(marry==1 | marry==2)

* control for log food expenditure
replace fd=. if fd<0
g ln_fd=ln(fd)
* construct budget shares

* variables
* soft drinks
replace fdsdspn=0 if fdsdspn<=0
g sd_s=fdsdspn/hh_income
g sd_s_fd=fdsdspn/fd
replace sd_s=. if sd_s>1
 replace sd_s=0 if sd_s==.
 replace sd_s=. if sd_s>.4

* vegetables
replace fdpotspn=0 if fdpotspn<=0
replace fdvegdspn=0 if fdvegdspn<=0 | fdvegdspn==.
replace fdvegospn=0 if fdvegospn<=0 | fdvegospn==.
g veg=fdvegospn+fdvegdspn+fdpotspn
g veg_s=veg/hh_income
g veg_s_fd=veg/fd
replace veg_s=. if veg_s>1
replace veg_s=0 if veg_s==.
replace veg_s_fd=. if veg_s_fd>1

* chicken
replace fdchispn=0 if fdchispn<=0
g chi_s=fdchispn/fd
replace chi_s=. if chi_s>1
g chi_s_fd=fdchispn/fd
replace chi_s_fd=. if chi_s_fd>1

* ready made meals
replace fdrdyspn=0 if fdrdyspn<=0
g rdy_s=fdrdyspn/hh_income

replace fdoutspn=0 if fdoutspn<=0
g out_s=fdoutspn/hh_income

* decision making power
g dec=(decd==pid)
g dec_j=(decd2==pid)
g rdp_a=rdp*a

egen dec_j_id=max(dec_j), by(hhid)

** EMPLOYMENT
g e=(emp==1)
egen emp_hh=max(e), by(hhid)

* CHILD SUPPORT GRANT
g csg=grcur==1

* WATER SOURCE
g piped=(water==1 | water==2)

* conservative hh_ch esitmate
sort pid r
by pid: g hh_sw=(rdp[_n]==0 & rdp[_n+1]==1)
egen h_ch_sw=max(hh_sw), by(hhid)

*** ANALYSIS

** LOOK FOR DETERMINANTS OF HOUSEHOLD BREAK UP

reg sr piped elec e csg dec_j_id child_d hs u hh_income h_ch_hh  i.r if r!=3, robust cluster(hhid)

* stil works so that's chill
reg sr piped elec e csg dec_j_id child_d hs u hh_income h_ch_sw  i.r if r!=3, robust cluster(hhid)


** 1.) LOOK FOR AGE GRADIENTS WITH CONSUMPTION
** SOFT DRINKS

reg sd_s ln_fd rdp size e m a u child_d i.r , cluster(hhid) robust

xtset pid

xtreg sd_s ln_fd rdp e m u, fe robustj

xtreg sd_s ln_fd rdp size e m u child_d , fe robust

xtreg sd_s ln_fd rdp size e m child_d  if u==1, fe robust
xtreg sd_s ln_fd rdp size e m child_d  if u==0, fe robust

** NOW DO VEGETABLES

reg veg_s_fd hh_income rdp size e m a u child_d i.r, robust


xtreg veg_s_fd hh_income rdp size e m u child_d i.r, fe robust


xtreg veg_s_fd hh_income rdp e m u i.r, fe robust


** CHICKEN

reg chi_s ln_fd rdp e m a u size child_d i.r, cluster(hhid) robust


reg chi_s_fd hh_income rdp e m a u i.r, cluster(hhid) robust


xtreg chi_s ln_fd rdp e m u i.r, fe robust


** READY MADE MEALS

reg rdy_s ln_fd rdp size a u child_d, cluster(hhid) robust

reg out_s ln_fd rdp size a u child_d, cluster(hhid) robust

** 2.) LOOK FOR CHANGES IN DECISIONMAKING POWER WHEN GET RDP

xtreg dec rdp u e, fe robust

xtreg dec rdp u e, fe robust


xtreg dec rdp e i.r if u==1, fe robust

xtreg dec rdp e i.r if u==0, fe robust

xtset pid
xtreg dec_j_id rdp u e m i.r, fe robust




