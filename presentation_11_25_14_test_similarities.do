
cd "/Users/willviolette/Desktop/pstc_work/nids"

**************************************************************
** ROOMS DISTRIBUTION TO SHOW THAT THE TREATMENT IS WORKING **
**************************************************************

*******************
** SUMMARY STATS **
*******************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

keep rdp a size af children edu inc piped elec rooms u

bys u rdp: outreg2 using sum_1_m_n, sum(log) eqkeep(mean)  label excel replace 

*********************
** PARALLEL TRENDS **
*********************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

* drop rdp_ch
sort pid r
by pid: g rdp_ch=rdp[_n+1]-rdp[_n]

sort pid r
foreach var of varlist  a size af children edu inc piped elec rooms {
by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}

keep rdp_ch a size children edu inc piped elec rooms u r hh1
collapse a size children edu inc piped elec rooms, by(u r hh1 rdp_ch)
keep if r==2

reg rdp_ch a size children edu inc piped elec rooms u, robust cluster(hh1)

outreg2 using ptrends, label excel replace 


************************
** HOUSEHOLD ANALYSIS **
************************

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

xtset hh1
keep if tt!=.

g hoh_sex=hoh*sex
g hoh_edu=hoh*edu
g hoh_age=hoh*a
* men's share of income
g m_shr=fwag*sex
replace m_shr=m_shr/inc

g oldd=a>65
egen old=sum(oldd), by(hhid)

collapse (sum) child (mean) e_hh tsm hoh_age child_out size a hoh_sex sex children hoh_edu edu e ue own own_d paid_off rooms elec piped flush mktv walls_b roof_cor exp exp_i exp_f m_shr fwag cwag swag sch_d travel marry tog inf house inc inc_r inc_l inc_g rdp u hrs old rent, by(r hh1)

g kid_ratio=children/size
xtreg kid_ratio rdp i.r, fe robust

** DEMOGRAPHICS

label variable kid_ratio "Ratio of Children to Adults"
label variable children "Children"
label variable child_out "Child Living Outside the HH"
label variable tog "Percentage of HH in Relationships"
label variable hoh_age "Age of HoH"
label variable hoh_sex "Sex of HoH"
label variable size "Size of HH"
label variable rdp "RDP"

xtreg size rdp i.r, fe robust cluster(hh1)
outreg2 using demo_hh, excel label replace  drop(i.r) nocons
foreach var of varlist children kid_ratio child_out hoh_age hoh_sex {
xtreg `var' rdp i.r, fe robust cluster(hh1)
outreg2 using demo_hh, excel label append  drop(i.r) nocons
}


** HOUSE CHARACTERISTICS **

label variable rooms "Rooms"
label variable elec "Electricity"
label variable flush "Flush Toilet"
label variable walls_b "Brick Walls"
label variable roof_cor "Corrugated Metal Roof"
label variable own_d "Dwelling Ownership"
label variable paid_off "Loans Paid Fully"
label variable piped "Piped Water"

xtreg rooms rdp i.r, fe robust cluster(hh1)
outreg2 using house_hh, excel label replace  drop(i.r) nocons
xtreg rooms rdp i.r if u==1, fe robust cluster(hh1)
outreg2 using house_hh, excel label append  drop(i.r) nocons
xtreg rooms rdp i.r if u==0, fe robust cluster(hh1)
outreg2 using house_hh, excel label append  drop(i.r) nocons
foreach var of varlist elec piped flush walls_b roof_cor own_d paid_off {
xtreg `var' rdp i.r, fe robust cluster(hh1)
outreg2 using house_hh, excel label append  drop(i.r) nocons
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
outreg2 using house_hh, excel label append  drop(i.r) nocons
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
outreg2 using house_hh, excel label append  drop(i.r) nocons
}

** INCOME AND EMPLOYMENT **

g remit_percent=inc_r/inc
g labor_percent=inc_l/inc
g exp_f_p=exp_f/size
g exp_i_p=exp_i/size

label variable inc "Total Income"
label variable labor_percent "Inc % from Labor"
label variable remit_percent "Inc % from Remit"
label variable exp_i_p "Expenditure per Person"
label variable exp_f_p "Food Exp. per Person"

xtreg inc rdp i.r, fe robust cluster(hh1)
outreg2 using inc_hh, excel label replace  drop(i.r) nocons
xtreg inc rdp i.r if u==1, fe robust cluster(hh1)
outreg2 using inc_hh, excel label append  drop(i.r) nocons
xtreg inc rdp i.r if u==0, fe robust cluster(hh1)
outreg2 using inc_hh, excel label append  drop(i.r) nocons
foreach var of varlist labor_percent remit_percent exp_i_p exp_f_p {
xtreg `var' rdp i.r, fe robust cluster(hh1)
outreg2 using inc_hh, excel label append  drop(i.r) nocons
xtreg `var' rdp i.r if u==1, fe robust cluster(hh1)
outreg2 using inc_hh, excel label append  drop(i.r) nocons
xtreg `var' rdp i.r if u==0, fe robust cluster(hh1)
outreg2 using inc_hh, excel label append  drop(i.r) nocons
}

************************
** CHILDREN  ANALYSIS **
************************

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
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1
xtset pid
keep if tt!=.
* replace zeroes
replace left_out_m=0 if r==1
replace left_out_n=0 if r==1
replace left_in_m=0 if r==1
replace left_in_n=0 if r==1
egen max_a=max(a), by(pid)

label variable rdp "RDP"
label variable edu "Years of Education"
label variable c_fees "School Fees"
label variable class_size "Class Size"
*label variable absent "Days Absent (last month)"
label variable check_up "Doctor Visit (last month)"
label variable c_ill "Sick for 3 Days (last month)"

xtset pid
xtreg edu rdp i.r if max_a<16 & max_a>6, fe robust cluster(hh1)
outreg2 using child, excel label replace  drop(i.r) nocons

foreach var of varlist c_fees class_size check_up c_ill {
xtreg `var' rdp i.r if max_a<16 & max_a>6, fe robust cluster(hh1)
outreg2 using child, excel label append  drop(i.r) nocons
* xtreg `var' rdp i.r if max_a<16 & max_a>10 & u==1, fe robust cluster(hh1)
* xtreg `var' rdp i.r if max_a<16 & max_a>10 & u==0, fe robust cluster(hh1)
}


************************
** INDIVIDUAL ANALYSIS **
************************

use hh_v1_ghs, clear

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
keep if tt!=.
keep if a>18

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
keep if mktv==.

g own_r1=(own==0 & r==1)
egen om1=max(own_r1), by(pid)



xtreg ue rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==1, fe robust cluster(hh1)
xtreg ue rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==0, fe robust cluster(hh1)
** RESULTS ARE CONSISTENT FINALLY!

xtreg size rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==1, fe robust cluster(hh1)
xtreg size rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==0, fe robust cluster(hh1)
** RESULTS ARE CONSISTENT FINALLY!


xtreg ue rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==1, fe robust cluster(hh1)
xtreg ue rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==0, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==1, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n i.r if u==1 & inf_max1==0, fe robust cluster(hh1)
* not much here

xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==1 & mktv!=., fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==0 & mktv!=., fe robust cluster(hh1)

xtreg paid_off rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==1 & mktv!=., fe robust cluster(hh1)
xtreg paid_off rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==0 & mktv!=., fe robust cluster(hh1)


xtreg e rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
outreg2 using ind, excel label replace  drop(i.r) nocons
xtreg e rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg e rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg e rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg e rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons

* robust to province time fixed effects
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if u==0, fe robust cluster(hh1)


egen sumr=sum(r), by(pid)
* robust to sumr
xtreg e rdp left_in left_out_m left_out_n i.r if sumr==6, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n i.r if sex==1 & sumr==6, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n  i.r if sex==0 & sumr==6, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n  i.r if u==1 & sumr==6, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n i.r if u==0 & sumr==6, fe robust cluster(hh1)


** Now check out inf! **

xtreg e rdp left_in left_out_m left_out_n i.r if inf_max1==1, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==1, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==0, fe robust cluster(hh1)

xtreg ue rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==1, fe robust cluster(hh1)
xtreg ue rdp left_in left_out_m left_out_n i.r if sex==1 & inf_max1==0, fe robust cluster(hh1)


** Now check out hh_outcome ind_outcome

xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==1 & ind_outcome==1 & hh_outcome==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==0 & ind_outcome==1 & hh_outcome==1, fe robust cluster(hh1)
** robust to that as well as province and time fixed effects

** now check out mrkt censor

xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==1 & ind_outcome==1 & hh_outcome==1 & mktv_max!=. , fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & inf_max1==0 & ind_outcome==1 & hh_outcome==1 & mktv_max!=. , fe robust cluster(hh1)




foreach var of varlist house inf {
xtreg `var' rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg `var' rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg `var' rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg `var' rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
xtreg `var' rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)
outreg2 using ind, excel label append  drop(i.r) nocons
}


* foreach var of varlist e inf house {
* xtreg `var' rdp left_in left_out i.r, fe robust cluster(hh1)
* xtreg `var' rdp left_in left_out i.r if sex==1, fe robust cluster(hh1)
* xtreg `var' rdp left_in left_out  i.r if sex==0, fe robust cluster(hh1)
* xtreg `var' rdp left_in left_out  i.r if u==1, fe robust cluster(hh1)
* xtreg `var' rdp left_in left_out i.r if u==0, fe robust cluster(hh1)
* }






