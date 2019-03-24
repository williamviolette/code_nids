
cd "/Users/willviolette/Desktop/pstc_work/nids"

use mech_c_edu_v1, clear

** DROP PROVINCES
drop if prov==9 | prov==10 | prov==6

xtset pid
egen max_age=max(a), by(pid)

g p_hoh=relhh==4
g p_hoh_id=p_hoh if r==1
egen p_hohr1=max(p_hoh_id), by(pid)
g g_hoh=relhh==13
g g_hoh_id=g_hoh if r==1
egen g_hohr1=max(g_hoh_id), by(pid)
g m_f_res=(c_mthhh==1 | c_fthhh==1)
g m_f_res_id=m_f_res if r==1
egen m_f_resr1=max(m_f_res_id), by(pid)
g f_res=(c_fthhh==1)
g f_res_id=f_res if r==1
egen f_resr1=max(f_res_id), by(pid)
g m_res=(c_mthhh==1)
g m_res_id=m_res if r==1
egen m_resr1=max(m_res_id), by(pid)

g pid_hoh_id=pid if hoh==1
egen pid_hoh=max(pid_hoh_id), by(hhid)
g f_hoh=c_fthhh_pid==pid_hoh
g m_hoh=c_mthhh_pid==pid_hoh

** CLEAN EXPENDITURE DATA
replace fd=. if fd>6000 | fd<10
g fd_size=fd/size
replace public=. if public>6000 | public<10
g public_size=public/size
g public_per=public/te
replace non_food=. if fd>6000 | fd<10
g non_food_size=fd/size
replace health_exp=. if health_exp>6000
g health_exp_size=health_exp/size
g fd_share=fd/te
g non_fd_per=non_fd/te

** CHILD MEASURES
egen total_kids=sum(child), by(hhid)
g kids_share_id=total_kids/size
egen kids_share=max(kids_share_id), by(hhid)

g child_alt_id=(a>=0 & a<=15)
egen child_alt=sum(child_alt_id), by(hhid)

*** KEEP ONLY ALL THREE ROUNDS ***
*g rr=1
*egen rrs=sum(rr), by(pid)
*tab rrs if max_age<16
*keep if rrs==3

egen opid=max(h_ownpid1), by(hhid)
egen opid2=max(h_ownpid2), by(hhid)

egen mf=max(c_mthhh_pid), by(pid)
egen ff=max(c_fthhh_pid), by(pid)
replace c_mthhh_pid=mf
replace c_fthhh_pid=ff

*** IDENTIFY RELATIONSHIP OF OTHER MEMBERS

 g p_own=(opid==c_mthhh_pid | opid==c_fthhh_pid | opid2==c_mthhh_pid | opid2==c_fthhh_pid )
* look at primary owner!
* g p_own=(opid==c_mthhh_pid | opid==c_fthhh_pid)
tab r p_own if max_age<16, r

g np=p_own
g op=1 if np==0
replace op=0 if np==1

** generate measures and alternate measures
foreach v in rdp rdpd rdpo rdpdo {
g `v'_np=`v'
replace `v'_np=0 if p_own==1
g `v'_op=`v'
replace `v'_op=0 if p_own==0
sort pid r
by pid: g `v'np_ch=`v'_np[_n]-`v'_np[_n-1]
by pid: g `v'op_ch=`v'_op[_n]-`v'_op[_n-1]
replace rdp_op=1 if `v'op_ch==-1
replace rdp_np=1 if `v'np_ch==-1
}

** YOUNG CHILD IN HOUSEHOLD
g young_id=a<=5
egen young=max(young_id), by(hhid)
g young_r1_id=young if r==1
egen youngr1=max(young_r1_id), by(pid)

** PARENT'S PAY EXPENSES
g p_pay=(c_ed07paypid1==c_mthhh_pid | c_ed07paypid1==c_fthhh_pid | c_ed09paypid1==c_mthhh_pid | c_ed09paypid1==c_fthhh_pid |c_ed11paypid1==c_mthhh_pid | c_ed11paypid1==c_fthhh_pid) 

** TOTAL SCHOOL EXPENSES
g sch_s=0
foreach c in c_ed07spnfee c_ed07spnuni c_ed07spnbks c_ed07spntrn c_ed07spno c_ed09spnfee c_ed09spnuni c_ed09spnbks c_ed09spntrn c_ed09spno c_ed11spnfee c_ed11spnuni c_ed11spnbks c_ed11spntrn c_ed11spno {
replace `c'=0 if `c'<0 | `c'==.
replace sch_s=sch_s+`c'
}
replace sch_s=. if sch_s==0

g size_2=size*size
g a_2=a*a
replace rooms=. if rooms==0
egen min_age=min(a), by(hhid)

replace absent=. if a<=3
g absent_d=(absent>0)
replace absent_d=. if absent==.
g absent_i=absent if absent>0

* Structure variables
label variable p_hoh "Parent HoH"
label variable g_hoh "Grand Parent HoH"
label variable m_res "Mother Resident"
label variable f_res "Father Resident"
label variable m_f_res "Parent Co-Resident"

* Outcomes
label variable absent "Days Absent from School (last month)"
label variable absent_i "Days Absent (at least 1 day)"
label variable absent_d "Dummy for at least one Absence"
label variable c_failed "Failed Grade"

* Demographics
label variable child_alt "Number of Children"
label variable young "Child Under 5"

* Expenditure
label variable te "Household Expenditure"
label variable inc "Houeshold Income"

* School Quality
label variable c_fees "School Fees"
label variable class_size "Class Size"
label variable sch_q "School Quintile"
label variable sch_d "Distance to School (minutes)"
label variable p_pay "Parents Pay Edu Costs"

* Housing Variables
label define rdpp 0 "Unsubsidized Housing" 1 "Subsidized (RDP) Housing"
label values rdp rdpp
label variable rdp "Subsidized Housing (RDP)"
label variable rooms "Rooms"
label variable piped "Piped Water"
label variable mktv "Market Value"
label variable elec "Electricity"

label variable rdp_op "Parents Own RDP House"
label variable rdp_np "Other Family Member Owns RDP House"

label variable rdp

replace mktv=. if mktv>100000

foreach var of varlist p_hoh g_hoh m_res f_res absent_d{
replace `var'=. if max_age>15
}

drop if rdp==.

** FIX FOR CLUSTERING
rename hh1 hhh
g hh1_id=hhid if r==1
egen hh1=max(hh1_id), by(pid)
g hh2_id=hhid if r==2
egen hh2=max(hh2_id), by(pid)
g hh3_id=hhid if r==3
egen hh3=max(hh3_id), by(pid)

g r2_id=(r==2 & hh1==.)
egen r2_idm=max(r2_id), by(pid)
replace hh1=hh2 if r2_idm==1
replace hh1=hh3 if r==3 & hh1==.

save paper, replace


***********************************
*** FIGURE 1 ROOMS DISTRIBUTION ***
***********************************

use paper, clear

hist rooms, by(rdp)
graph export paper/figure1.pdf, replace as(pdf)


******************************
*** FIGURE 2 SUMMARY STATS ***
******************************
use paper, clear

keep rdp absent absent_d c_failed p_pay p_hoh g_hoh m_f_res a edu size child_alt young inc te rooms piped elec mktv
order absent absent_d c_failed p_pay p_hoh g_hoh m_f_res a edu size child_alt young inc te rooms piped elec mktv
bysort rdp: outreg2 using paper/sum_1, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics") addnote("Note: Education variables apply to children")

*************************
*** RDP SUMMARY STATS ***
*************************
use paper, clear

keep if max_age<16

label variable rdp "RDP House (Gained Over the Sample Period)"
replace rdp=. if rdp_r1_max==1
label variable rdp_op "Parents Own RDP House (Gained Over the Sample Period)"
replace rdp_op=. if rdp_r1_max==1
label variable rdp_np "Other Family Member Owns RDP House (Gained Over the Sample Period)"
replace rdp_np=. if rdp_r1_max==1

tab rdp_fixed r
tab rdp r

egen max_rdp1=max(rdp_fixed), by(hh1)
egen max_rdp=max(rdp), by(hh1)
egen max_rdp_op=max(rdp_op), by(hh1)
egen max_rdp_np=max(rdp_np), by(hh1)

g rdp1=max_rdp1
replace rdp=max_rdp
replace rdp_op=max_rdp_op
replace rdp_np=max_rdp_np
label variable rdp1 "RDP House (At Any Time During the Sample Period)"

duplicates drop hh1, force

keep rdp1 rdp rdp_op rdp_np
order rdp1 rdp rdp_op rdp_np
outreg2 using paper/sum_2, noni sum(log) eqkeep(mean N) label tex(frag) replace title("Summary Statistics: Subsidized Housing (RDP)") addnote("Note: Sample includes households with children respondents")

**********************
*** Count children ***
**********************
use paper, clear

keep if max_age<16

egen max_h_ch=max(h_ch), by(pid)

duplicates drop pid, force

tab max_h_ch


***************************************
*** FIRST STAGE: HOUSEHOLD STRUCTURE***
***************************************
use paper, clear

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"

quietly xi: xtreg p_hoh rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/first_stage_v1, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Head of Household")

foreach c in g_hoh m_f_res {
quietly xi: xtreg `c' rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/first_stage_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)
}

*** DEMOGRAPHICS ***
quietly xi: xtreg size rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/first_stage_v2, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Demographics")

foreach c in  child_alt inc {
quietly xi: xtreg `c' rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/first_stage_v2, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)
}

***************************************
*** REDUCED FORM: EDUCATION IMPACTS ***
***************************************

use paper, clear

label variable absent "Absent (Days/Month)"
label variable absent_i "Absent (Days over 1)"
label variable absent_d "Absent Dummy"
label variable c_failed "Failed Grade"

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"

g p_hoh1=p_hoh
replace p_hoh1=0 if r==1

g g_hoh1=g_hoh
replace g_hoh1=0 if r==1

g p_own1=p_own
replace p_own1=0 if r==1

g g_own1=(p_own==0)
replace g_own1=. if p_own==.
replace g_own1=0 if r==1

*xi: xtreg absent p_own1 g_own1 i.r if max_age<16, fe  robust
*xi: xtreg absent p_hoh1 g_hoh1 i.r if max_age<16, fe  robust
*xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & r!=2, fe  robust

*** reduced form v1
** generate measures and alternate measures
g rdp_ph=rdp
replace rdp_ph=0 if p_hoh!=1
g rdp_gh=rdp
replace rdp_op=0 if g_hoh!=0
sort pid r
by pid: g rdp_phc=rdp_ph[_n]-rdp_ph[_n-1]
by pid: g rdp_ghc=rdp_gh[_n]-rdp_gh[_n-1]
replace rdp_op=1 if rdp_phc==-1
replace rdp_np=1 if rdp_ghc==-1


xi: xtreg absent_i rdp_ph rdp_gh i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent rdp_ph rdp_gh i.r if max_age<16, fe cluster(hh1) robust

g pg_hoh=(p_hoh==1 | g_hoh==1)

xi: xtreg absent i.rdp*i.pg_hoh i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent_i i.rdp*i.pg_hoh i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent_i i.rdp*i.g_hoh i.r if max_age<16, fe cluster(hh1) robust

tab p_hoh r

*** 

xi: xtreg absent rdp_ph rdp_gh i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent rdp_gh i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent i.rdp*i.p_hoh i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent i.rdp*i.g_hoh i.r if max_age<16, fe cluster(hh1) robust


quietly xi: xtreg absent i.rdp*i.p_hoh i.r if max_age<16, fe cluster(hh1) robust
outreg2 using paper/reduced_form_v1, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Education Impacts")

quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/reduced_form_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)

*quietly xi: xtreg absent_d rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
*outreg2 using paper/reduced_form_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) 

*** reduced form v2

*xi: xtreg c_failed rdp_op rdp_np i.r if max_age<16 & max_age>9, cluster(hh1) fe

quietly xi: xtreg c_failed rdp_op rdp_np i.r if max_age<16 & max_age>9, cluster(hh1) fe robust
outreg2 using paper/reduced_form_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) 

*outreg2 using paper/reduced_form_v2, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES, Maximum Age 10 to 15, YES) title("Education Impacts: Continued")

* quietly xi: xtreg p_pay rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
* outreg2 using paper/reduced_form_v2, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)


*******************************
*** MECHANISMS: CHILD CARE  ***
*******************************

use paper, clear

label variable absent "Absent (Days)"
label variable absent_i "Absent"
label variable absent_d "Absent Dum"
label variable c_failed "Failed Grade"

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"

quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & youngr1==1, cluster(hh1) fe robust
outreg2 using paper/mech_v1, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext( Young Child Present, YES, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Care Mechanism") addnote("Note: Absent is measured in days absent greater than one (Intensive Margin)")
quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & youngr1==0, cluster(hh1) fe robust
outreg2 using paper/mech_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext( Young Child Present, NO, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Care Mechanism")

** GENDER DOESN'T HELP THE STORY NOW
*quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & sex==1 & youngr1==1, cluster(hh1) fe robust
*outreg2 using paper/mech_v1, tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Gender, BOYS, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Care Mechanism")

*quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & sex==0 & youngr1==1, cluster(hh1) fe robust
*outreg2 using paper/mech_v1, tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Gender, GIRLS, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Child Care Mechanism")


******************************************
*** ROBUSTNESS: ALTERNATIVE MECHANISMS: HOUSE QUALITY ***
******************************************

use paper, clear

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"

quietly xi: reg rooms rdp_op u i.r if max_age<16 & max_age>3 & (rdp_op==1 | rdp_np==1), cluster(hh1) robust
outreg2 using paper/house_quality_v1, nonotes tex(frag) label replace keep(rdp_op) nocons addtext(Time Fixed Effects, YES, Urban/Rural Control, YES) title("RDP House Quality across Parent and Non-Parent Owners") addnote("Limit Sample to RDP Houses (non-parent owners are the reference group)")
foreach v in piped elec mktv {
quietly xi: reg `v' rdp_op u i.r if max_age<16 & max_age>3 & (rdp_op==1 | rdp_np==1), cluster(hh1) robust
outreg2 using paper/house_quality_v1, nonotes tex(frag) label append keep(rdp_op) nocons addtext(Time Fixed Effects, YES, Urban/Rural Control, YES)
}


**********************************************************
*** ROBUSTNESS: ALTERNATIVE MECHANISMS: SCHOOL QUALITY ***
**********************************************************

use paper, clear

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"
label variable sch_d "School Dist (min)"

quietly xi: xtreg c_fees rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/school_quality_v1, nonotes tex(frag) label replace keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("School Quality")

foreach c in class_size sch_q sch_d {
quietly xi: xtreg `c' rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/school_quality_v1, nonotes tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)
}


*********************************
*** ROBUSTNESS: MORE CONTROLS ***
*********************************

use paper, clear

label variable absent "Absent (Days)"
label variable absent_i "Absent"
label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"
label variable sch_d "School Distance (min)"

sort pid r
by pid: g sch_q_ch=sch_q[_n]!=sch_q[_n-1]
replace sch_q_ch=. if sch_q==.
by pid: g sq_ch=sch_q[_n]-sch_q[_n-1]
* indicator for having a change in quality
g sq_ch_id=(sq_ch!=0 & sq_ch!=.)
replace sq_ch_id=. if sq_ch==.
* indicator for ever having a change
egen sq=max(sq_ch_id), by(pid)

** DIG INTO SCHOOL QUALITY **

*xi: xtreg sch_q rdp i.r if max_age<16, cluster(hh1) fe robust
*xi: xtreg sch_q rdp_op rdp_np i.r if max_age<16, cluster(hh1) fe robust

quietly xi: xtreg absent_i rdp_op rdp_np m_res f_res size child_alt i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label replace keep(rdp_np rdp_op m_res f_res size child_alt) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Alternative Controls") addnote("Note: Absent is measured in days absent greater than one (Intensive Margin)")

quietly xi: xtreg absent_i rdp_op rdp_np m_res f_res size child_alt si_* i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt) nocons addtext(All Demographics, YES, Time Fixed Effects, YES, Individual Fixed Effects, YES)

quietly xi: xtreg absent_i rdp_op rdp_np sch_d i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt sch_d) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES) 

** don't need class_size because it makes the table too big

*quietly xi: xtreg absent_i rdp_op rdp_np class_size i.r if max_age<16, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label append keep(rdp_np rdp_op m_res f_res size class_size child_alt sch_d) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)

quietly xi: xtreg absent_i rdp_op rdp_np sch_q i.r if max_age<16, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt sch_q) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES)

quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & sq==0, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt sch_d) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES, No Change in Sch Quin, YES)

quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & sq==1, cluster(hh1) fe robust
outreg2 using paper/robust_v1, nonotes tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt sch_d) nocons addtext(Time Fixed Effects, YES, Individual Fixed Effects, YES, Some Change in Sch Quin, YES)


** effects are less, point in the same direction, hard to reject a story, but definitely some evidence against one

*quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & max_age>6 & absent>0 & m_f_resr1==1, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label replace keep(rdp_np rdp_op) nocons addtext( Parents Initially Coresident, YES, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Altnerative Controls") addnote("Note: Absent is measured in days absent greater than one (Intensive Margin)")

*quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & max_age>6 & absent>0 & p_hohr1==1, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Parents Initially Coresident, NO, Parent Initially HoH, YES, Grandparent Initially HoH, NO, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Altnerative Controls")

*quietly xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & max_age>6 & absent>0 & g_hohr1==1, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label append keep(rdp_np rdp_op) nocons addtext(Parents Initially Coresident, NO, Parent Initially HoH, NO, Grandparent Initially HoH, YES, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Altnerative Controls")

*quietly xi: xtreg absent_i rdp_op rdp_np m_res f_res size child_alt i.r if max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt) nocons addtext(Parents Initially Coresident, NO, Parent Initially HoH, NO, Grandparent Initially HoH, NO, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Altnerative Controls")

*quietly xi: xtreg absent_i rdp_op rdp_np m_res f_res size child_alt si_* i.r if max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
*outreg2 using paper/robust_v1, tex(frag) label append keep(rdp_np rdp_op m_res f_res size child_alt) nocons addtext(All Combination of Demographics, YES, Parents Initially Coresident, NO, Parent Initially HoH, NO, Grandparent Initially HoH, NO, Time Fixed Effects, YES, Individual Fixed Effects, YES) title("Altnerative Controls")




