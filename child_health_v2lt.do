
* child health

cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

g rdpr=rdp

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
** LOOK LONG-TERM!
keep if lt!=.
** CHILDREN
keep if a<=18

label variable rdp "RDP"
label variable e "Employment"
label variable house "Township/Brick House"
label variable inf "Informal Settlement"
label variable left_in "RDP: Division"
label variable left_out_m "Left-Out of RDP: Moved"
label variable left_out_n "Left-Out of RDP: Stayed"

g inf1=(inf==1 & r==1)
egen inf_max1=max(inf1), by(pid)

replace mktv=. if mktv>100000
egen mktv_max=max(mktv), by(pid)
*keep if mktv==.

g own_r1=(own==0 & r==1)
egen om1=max(own_r1), by(pid)

egen sumr=sum(r), by(pid)
*keep if sumr==6
keep if sumr==4

** look at mktv variables
g mktv_rdp=mktv*rdp
g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

g rdp_mktv=rdp*mktv

drop c_absent
drop c_sch_d
drop c_repeat

drop c_moth*
drop c_fath*

*drop c_father_sup c_father_see c_moth* c_weig* c_heig* c_chec* c_ill_ser c_health c_absent c_class_size c_sch_d c_sch_travel c_fees c_att c_edu
**
g a_2=a*a

foreach var of varlist c_* {
xi: xtreg `var' rdpr left_out a i.r*i.prov, fe robust cluster(hh1)
}
*** ONLY THREE RESULTS FOR KIDS!


** ILL
xi: xtreg c_ill rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)
** results

** GENERAL HEALTH
xi: xtreg c_health rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_health rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg c_health rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg c_health rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_health rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)
** nothing

** CHECK UPS
xi: xtreg check_up rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg check_up rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg check_up rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg check_up rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg check_up rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)
** nothing






