
cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

replace rooms=. if rooms>10

** DATA PREP **
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
* keep if a>17
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

keep if tt!=.

egen max_a=max(a), by(pid)

*** CORE REGRESSIONS

* child: education , illness
* hh: size , children , income , hoh_sex
* adult: employment , unemployment , inc_r , inc

* stuff with left_out

xtset pid

foreach var of varlist rooms piped flush roof_cor walls_b own paid_off {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5 & u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5 & u==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if mdb=="ETH", fe robust cluster(hh1)
}
** not a lot changing except for flush toilets

foreach var of varlist edu c_ill {
xtreg `var' rdp i.r if max_a<17 & max_a>6, fe robust cluster(hh1)
xtreg `var' rdp i.r if max_a<17 & max_a>6 & prov==5, fe robust cluster(hh1)
xtreg `var' rdp i.r if max_a<17 & max_a>6 & prov==5 & u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if max_a<17 & max_a>6 & prov==5 & u==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if max_a<17 & max_a>6 & mdb=="ETH", fe robust cluster(hh1)
}


foreach var of varlist size children e ue inc_r inc {
xtreg `var' rdp i.r, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5 & u==1, fe robust cluster(hh1)
xtreg `var' rdp i.r if prov==5 & u==0, fe robust cluster(hh1)
xtreg `var' rdp i.r if mdb=="ETH", fe robust cluster(hh1)
}

** INCLUDE LEFT OUT & LEFT IN

foreach var of varlist edu c_ill {
xtreg `var' rdp left_out left_in i.r if max_a<17 & max_a>6, fe robust cluster(hh1)
xtreg `var' rdp left_out left_in i.r if max_a<17 & max_a>6 & prov==5, fe robust cluster(hh1)
xtreg `var' rdp left_out left_in  i.r if max_a<17 & max_a>6 & prov==5 & u==1, fe robust cluster(hh1)
xtreg `var' rdp left_out left_in  i.r if max_a<17 & max_a>6 & prov==5 & u==0, fe robust cluster(hh1)
xtreg `var' rdp left_out left_in  i.r if max_a<17 & max_a>6 & mdb=="ETH", fe robust cluster(hh1)
}

foreach var of varlist size children e ue inc_r inc {
xtreg `var' rdp left_out left_in  i.r, fe robust cluster(hh1)
xtreg `var' rdp  left_out left_in i.r if prov==5, fe robust cluster(hh1)
xtreg `var' rdp  left_out left_in i.r if prov==5 & u==1, fe robust cluster(hh1)
xtreg `var' rdp  left_out left_in i.r if prov==5 & u==0, fe robust cluster(hh1)
xtreg `var' rdp left_out left_in  i.r if mdb=="ETH", fe robust cluster(hh1)
}










use hh_v1_ghs, clear

replace rooms=. if rooms>10

** DATA PREP **
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
* keep if a>17
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

keep if tt!=.

egen max_a=max(a), by(pid)

xtset pid

** DWELLING CHARACTERISTICS

quietly xtreg rooms rdp left_out left_in i.r if prov==1 & u==1, fe robust cluster(hh1)
outreg2 using prov, excel replace drop(i.r) nocons 
quietly xtreg rooms rdp left_out left_in i.r if prov==1 & u==0, fe robust cluster(hh1)
outreg2 using prov, excel append drop(i.r) nocons

foreach var of varlist piped flush roof_cor walls_b own paid_off size children e ue inc_r inc  {
quietly xtreg `var' rdp left_out left_in i.r if prov==1 & u==1, fe robust cluster(hh1)
outreg2 using prov, excel append drop(i.r) nocons ctitle(`var' urban)
quietly xtreg `var' rdp left_out left_in i.r if prov==1 & u==0, fe robust cluster(hh1)
outreg2 using prov, excel append drop(i.r) nocons ctitle(`var' rural)
}

forvalues r=2/9 {
foreach var of varlist rooms piped flush roof_cor walls_b own paid_off size children e ue inc_r inc  {
quietly xtreg `var' rdp left_out left_in i.r if prov==`r' & u==1, fe robust cluster(hh1)
outreg2 using prov, excel append drop(i.r) nocons ctitle(`r' `var' urban)
quietly xtreg `var' rdp left_out left_in i.r if prov==`r' & u==0, fe robust cluster(hh1)
outreg2 using prov, excel append drop(i.r) nocons ctitle(`r' `var' urban)
}
}



