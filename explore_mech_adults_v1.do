

cd "/Users/willviolette/Desktop/pstc_work/nids"

***********************************
*** EXPENDITURES WITH CHILD OUT ***
***********************************

use mech_c_edu_v1, clear

xtset pid

egen max_child_out=max(child_out), by(hhid)
g split=(max_child_out>0 & max_child_out<.)

replace child_out=0 if child_out==.
replace child=0 if child==.

g child_total=child+child_out

g child_still=a_bhdth_n if a_bhdth_n>=0

*** DEFINE YOUNG CHILDREN ***





xi: xtreg child rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child rdp i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg child_out rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out rdp i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg child_total rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_total rdp i.prov*i.r if u==0, fe cluster(hh1) robust



xi: xtreg child_still rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_still rdp i.prov*i.r if u==0, fe cluster(hh1) robust
** much fewer in rural areas?!

xi: xtreg children rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg size rdp i.prov*i.r if u==0, fe cluster(hh1) robust



tab split if a>18
tab split if a<18
** slightly more likely to be split

xi: xtreg size rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg size rdp i.prov*i.r if u==0, fe cluster(hh1) robust


xi: xtreg split rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg split rdp i.prov*i.r if u==0, fe cluster(hh1) robust

** more likely to see split!

xi: xtreg split rdp i.prov*i.r if u==1 & a<16, fe cluster(hh1) robust
xi: xtreg split rdp i.prov*i.r if u==0 & a<16, fe cluster(hh1) robust


hist size if size<18, by(u)

* limit to small initial household size



xi: xtreg child_out i.rdp*i.sizer1 i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out i.rdp*i.sizer1 i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg children i.rdp*i.sizer1 i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg children i.rdp*i.sizer1 i.prov*i.r if u==0, fe cluster(hh1) robust


xi: xtreg children rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg children rdp i.prov*i.r if u==0, fe cluster(hh1) robust
** children increases!

** child_out increases... why / how?!


