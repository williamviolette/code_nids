
cd "/Users/willviolette/Desktop/pstc_work/nids"

use mech_c_edu_v1, clear

xtset pid
egen max_age=max(a), by(pid)

g p_hoh=relhh==4
g p_hoh_id=p_hoh if r==1
egen p_hohr1=max(p_hoh_id), by(pid)
g g_hoh=relhh==13
g g_hoh_id=g_hoh if r==1
egen g_hohr1=max(g_hoh_id), by(pid)
g pg_hoh=(relhh==4 | relhh==13)
g pg_hoh_id=pg_hoh if r==1
egen pg_hohr1=max(pg_hoh_id), by(pid)

egen median_weight=median(weight), by(a)
egen sd_weight=sd(weight), by(a)
g z_weight=(weight-median_weight)/sd_weight

g m_f_res=(c_mthhh==1 | c_fthhh==1)
g m_f_res_id=m_f_res if r==1
egen m_f_resr1=max(m_f_res_id), by(pid)
g f_res=(c_fthhh==1)
g f_res_id=f_res if r==1
egen f_resr1=max(f_res_id), by(pid)
g m_res=(c_mthhh==1)
g m_res_id=m_res if r==1
egen m_resr1=max(m_res_id), by(pid)

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

egen total_kids=sum(child), by(hhid)
g kids_share_id=total_kids/size
egen kids_share=max(kids_share_id), by(hhid)

g child_alt_id=(a>=0 & a<=15)
egen child_alt=sum(child_alt_id), by(hhid)

save paper, replace


*********************************************************
*** FIGURE 1 MIGRANT WORKERS IN RURAL AND URBAN AREAS ***
*********************************************************
use paper, clear

label define urb 0 "Rural" 1 "Urban"
label values u urb

label define emp 0 "Unemployed" 1 "Employed"
label values e emp

label variable size "Household Size"

hist size if relhh==1 & a>=20 & a<=30 & size<10, by(u e)
graph export paper/figure1.pdf, replace as(pdf)


***********************************
*** FIGURE 2 ROOMS DISTRIBUTION ***
***********************************
use paper, clear

label variable rooms "Rooms"
hist rooms if rdp==0, by(u)
graph export paper/figure2.pdf, replace as(pdf)

*** NEED NUMBER OF CHILDREN TREATED


*************************************
*** SUMMARY STATISTICS: FULL DATA ***
*************************************

use paper, clear

* Structure Variables
foreach var of varlist p_hoh g_hoh pg_hoh m_res f_res m_f_res {
replace `var'=. if max_age>15
}
label variable p_hoh "Parent HoH"
label variable g_hoh "Grand Parent HoH"
label variable pg_hoh "Parent or Grand Parent HoH"
label variable m_res "Mother Resident"
label variable f_res "Father Resident"
label variable m_f_res "Mother or Father Resident"

* Outcomes
label variable z_weight "Weight for Age Z-Score"
label variable c_ill "Child Ill for 3 Days in Month"
label variable c_health "Child Self-Reported Health"

* Demographics
label variable child_alt "Number of Children"
label variable te "Total Expenditure"

* hist z_weight, by(rdp)

xtset pid

xi: xtreg pg_hoh rdp i.r*i.prov if u==0, fe robust cluster(hh1)



xi: xtreg weight i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, fe robust cluster(hh1)

xi: xtreg z_weight i.rdp*pg_hohr1 i.r*i.prov if z_weight<10 & z_weight>-10 & u==1 & max_age<16, fe robust cluster(hh1)


xi: xtreg z_weight i.rdp*pg_hohr1 i.r*i.prov if z_weight<10 & z_weight>-10 & u==0, fe robust cluster(hh1)



xi: xtreg z_weight rdp i.r*i.prov if z_weight<10 & z_weight>-10 & u==1, fe robust cluster(hh1)



xi: xtreg c_ill i.rdp*pg_hohr1 i.r*i.prov if z_weight<6 & z_weight>-6 & u==1 & max_age<16, fe robust cluster(hh1)

xi: xtreg c_ill i.rdp*pg_hohr1 i.r*i.prov if  u==1 & max_age<16, fe robust cluster(hh1)

xi: xtreg c_ill i.rdpf*pg_hohr1 i.r*i.prov if  u==1 & max_age<16, fe robust cluster(hh1)



xi: xtreg c_health i.rdp*pg_hohr1 i.r*i.prov  if u==1, fe robust cluster(hh1)


xi: xtreg c_ill i.rdp*pg_hohr1  if  u==1, fe robust cluster(hh1)

xi: xtreg c_ill i.rdp*pg_hohr1 i.r*i.prov if  u==0, fe robust cluster(hh1)




xi: xtreg z_weight i.rdp*pg_hohr1 i.r*i.prov if z_weight<6 & z_weight>-6 & u==0, fe robust cluster(hh1)


xi: xtreg z_weight i.rdp*pg_hohr1 if z_weight<6 & z_weight>-6, fe robust cluster(hh1)

xi: xtreg p i.rdp*pg_hohr1 if z_weight<6 & z_weight>-6, fe robust cluster(hh1)


drop if rdp==.
drop if u==.
keep u rdp p_hoh g_hoh pg_hoh m_res f_res m_f_res z_weight c_ill c_health a edu size child_alt inc te piped elec rooms
order  u rdp p_hoh g_hoh pg_hoh m_res f_res m_f_res z_weight c_ill c_health a edu size child_alt inc te piped elec rooms
bysort u rdp: outreg2 using paper/sum_1, sum(log) label tex(frag) replace eqkeep(mean N) keep(p_hoh g_hoh pg_hoh m_res f_res m_f_res z_weight c_ill c_health a edu size child_alt inc te piped elec rooms)


***************************************
*** SUMMARY STATISTICS TEST BALANCE ***
***************************************






