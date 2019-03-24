

cd "/Users/willviolette/Desktop/pstc_work/nids"


*************************************
*** TAKE A LOOK AT KID'S OUTCOMES ***
*************************************

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
g unc_hoh=(relhh==18 | relhh==19)
g unc_hoh_id=unc_hoh if r==1
egen unc_hohr1=max(unc_hoh_id), by(pid)
g care_hoh=(care==8 | care==14)
g care_hoh_id=care_hoh if r==1
egen care_hohr1=max(care_hoh_id), by(pid)

g pg_care_hohr1=pg_hohr1*care_hohr1

egen median_weight=median(weight), by(a)
egen sd_weight=sd(weight), by(a)

g z_weight=(weight-median_weight)/sd_weight

** is it parent as resident or parent as care taker?
** ** biggest jump is away from uncle ( relhh==19 (or 18) )
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







hist child_alt if child_alt<=10 & child_alt>0 & max_age<16, by(u)

hist child_alt if child_alt<=10 & child_alt>0 & max_age<16, by(u pg_hoh)

hist child_alt if child_alt<=10 & child_alt>0 & max_age<16, by(u p_hoh g_hoh)

hist rooms if rdp==0, by(u)


hist size if relhh==1 & a>=20 & a<=30 & size<10, by(u e)
** THIS IS A GOOD HISTOGRAM

hist a if max_age<16

* no income
xi: xtreg inc rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg inc rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg inc i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg inc i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg inc_r i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg inc_r i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust



xi: xtreg c_ill i.rdp*pg_hohr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*pg_hohr1 if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*pg_hohr1 if u==1 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*pg_hohr1 if u==0 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust

xi: xtreg c_health i.rdp*pg_hohr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*pg_hohr1 if u==0 & max_age<16, cluster(hh1) fe robust


*** FIRST STAGE ***
xi: xtreg p_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg g_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg pg_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg pg_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg m_f_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg m_f_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg f_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg f_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* rural areas more likely to have a father present (sort of makes sense)
xi: xtreg m_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* driven by mother resident status! in urban areas
xi: xtreg m_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* nothing going on for women in rural areas



*** FIRST STAGE ***
xi: xtreg p_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg g_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg pg_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg pg_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg m_f_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg m_f_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* only urban
xi: xtreg f_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg f_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* rural areas more likely to have a father present (sort of makes sense)
xi: xtreg m_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* driven by mother resident status! in urban areas
xi: xtreg m_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* nothing going on for women in rural areas





*******************************************
*** TOTAL KIDS ( BIOlOGICALLY RELATED ) ***
*******************************************

*** URBAN ***
xi: xtreg total_kids rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* more kids
xi: xtreg total_kids i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* more total kids concentrated with non_hoh households, but is that totally clear: yes, these hh's have an incentive!
*** RURAL ***
xi: xtreg total_kids rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* more kids
xi: xtreg total_kids i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* no change in the total kids

***********************************************************
*******  TOTAL KIDS ( INCLUDING ALL RESPONDENTS ) *********
***********************************************************

*** URBAN ***
xi: xtreg child_alt rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* nothing on net
xi: xtreg child_alt i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* reduction in children, evidence of household splitting, which is reassuring
*** RURAL ***
xi: xtreg child_alt rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* nothing on net
xi: xtreg child_alt i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* nothing here!

 

************
*** SIZE ***
************
*** URBAN ***
xi: xtreg size i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* no change in total size: substitute adults for kids
*** RURAL ***
xi: xtreg size i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* slight reduction in non-hoh size, slight increase in hoh size ( or zero effect! ) 


** look at all kinds of interactions with kids_share
xi: xtreg kids_share i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg kids_share i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg kids_share i.rdp*g_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg kids_share i.rdp*g_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg kids_share i.rdp*p_hohr1 i.r*i.prov if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust

sum kids_share if p_hohr1==1 & r==1
** way more kids: if parents are head of household
sum kids_share if p_hohr1==0 & r==1
** way less kids: if parents are not head of household

** nothing really moving on the size and child fronts individually

*** DOUBLECHECK MECHANISMS

************************
** HEALTH EXPENDITURE **
************************

xi: xtreg health_exp_per rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg health_exp_per rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg health_exp_per rdp size total_kids size i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg health_exp_per rdp size total_kids size i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

** increase in health expenditure 
xi: xtreg health_exp_per i.rdp*pg_hohr1 size total_kids i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg health_exp_per i.rdp*pg_hohr1 size total_kids i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** works! increase in health expenditure as percentage of total: spend another percentage of income on kids

xi: xtreg public_per rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg public_per rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg public_per rdp  size total_kids i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg public_per rdp  size total_kids i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust


** no change
xi: xtreg public_per i.rdp*pg_hohr1 size child_alt i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg public_per i.rdp*pg_hohr1 size child_alt i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** nothing urban, big decline in rural for those that are reunited

xi: xtreg fd_share i.rdp*pg_hohr1 size child_alt i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg fd_share i.rdp*pg_hohr1 size child_alt i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** no change in food share of budget. 

xi: xtreg fd_share rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg fd_share rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg fd i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg fd i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust






tab relhh rdp if max_age<16
** looks like its coming from uncles

** respiratory illness goes up, what's that about??
* what other illnesses can I disaggregate?

xi: xtreg check_up i.rdp*pg_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg check_up i.rdp*pg_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** check_up is strange, rural area shows pronounced effects

** very strongly correlated across all measures
foreach var of varlist  rdp rdpd rdpt rdpo {
xi: xtreg pg_hoh `var' i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg pg_hoh `var' i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
}


xi: xtreg unc_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg unc_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** increases for rdp in rural areas?!?!

** SEPARATE PARENTS AND GRANDPARENTS

xi: xtreg c_ill i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*** no results with just parents as hoh
xi: xtreg c_ill i.rdp*i.g_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.g_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*** get results for grandparents in urban areas!!! BAD if gparent is hoh!
* does this hold up across other outcomes?
xi: xtreg c_health i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*** kids get LESS healthy when parents are initially hoh
xi: xtreg c_health i.rdp*i.g_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.g_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*** nothing
xi: xtreg z_weight i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.p_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*** results hold for parents!
xi: xtreg z_weight i.rdp*i.g_hohr1 i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.g_hohr1 i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* not for grandparents, and nothing going on for others!

** double-check results for residency
xi: xtreg z_weight i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** health gets worse?
xi: xtreg check_up i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust


*** best results are for kids not living with a parent or grand parent
****** would be great to show expenditure changes.. but probably not...

xi: xtreg fd i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg w_alt i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1 & w_alt>0, cluster(hh1) fe robust
xi: xtreg health_exp i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg size i.rdp*i.p_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg c_ill i.rdp*i.pg_hohr1 i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.pg_hohr1 i.r*i.prov if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** when the are both resident to begin with, being HoH is super helpful ( IN RURAL AREAS )
** ** how to think about this?

* ROBUST TO OWNERSHIP MEASURES?
foreach l in c_ill z_weight c_health {
forvalues r=0/1 {
xi: xtreg `l' i.rdp*i.pg_hohr1 if u==`r' & max_age<16 & ownr1==1, cluster(hh1) fe robust
}
}
** YUP!!

* ROBUST TO ROOMS MEASURES?
foreach l in c_ill z_weight c_health {
forvalues r=0/1 {
xi: xtreg `l' i.rdp*i.pg_hohr1 if u==`r' & max_age<16 & roomsr1>=3 & roomsr1<=5, cluster(hh1) fe robust
}
}
** YUP!!
 * * * * * how to think about 
 tab pg_hohr1 rdp 
* mostly due to father coming into the hh?

**** NOW LOOK AT OUTCOMES

xi: xtreg c_ill i.rdp*i.m_f_resr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.m_f_resr1 if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*i.m_f_resr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.m_f_resr1 if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg c_ill i.rdp*i.p_hohr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 if u==0 & max_age<16, cluster(hh1) fe robust

** resident is actually not super good, its HoH!


xi: xtreg z_weight i.rdp*i.m_f_resr1 if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.m_f_resr1 if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg c_ill i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* across the board improves health.. not specific effects

xi: xtreg z_weight i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* works controlling for mf presence

xi: xtreg c_health i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* works controlling for mf presence

** GRANDPARENTS??

xi: xtreg c_ill i.rdp*i.g_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.g_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*i.g_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.g_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg c_health i.rdp*i.g_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.g_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust


*** CHECK IF ITS ACTUALLY THE PRIMARY CARETAKER ISSUE?
xi: xtreg c_ill i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* across the board improves health.. not specific effects

xi: xtreg z_weight i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* works controlling for mf presence

xi: xtreg c_health i.rdp*i.p_hohr1 if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* works controlling for mf presence




xi: xtreg c_ill i.rdp*i.m_f_resr1 if u==1 & max_age<17, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.m_f_resr1 if u==0 & max_age<17, cluster(hh1) fe robust
** different results

*** now check
xi: xtreg c_ill i.rdp*i.pg_hohr1 i.rdp*i.m_f_resr1 i.rdp*i.pg_m_f_int if u==1 & max_age<17, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.pg_hohr1 i.rdp*i.m_f_resr1 i.rdp*i.pg_m_f_int if u==0 & max_age<17, cluster(hh1) fe robust


xi: xtreg z_weight i.rdp*i.pg_hohr1 if u==1 & max_age<17, fe cluster(hh1) robust
xi: xtreg z_weight i.rdp*i.pg_hohr1 if u==0 & max_age<17, fe cluster(hh1) robust


xi: xtreg c_ill i.rdp*i.care_hohr1 if u==1 & max_age<17, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.care_hohr1 if u==0 & max_age<17, cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*i.care_hohr1 if u==1 & max_age<17, fe cluster(hh1) robust
xi: xtreg z_weight i.rdp*i.care_hohr1 if u==0 & max_age<17, fe cluster(hh1) robust
**** nothing for weight!

* also make sure mother or father are resident

xi: xtreg c_ill i.rdp*i.pg_hohr1 i.rdp*i.care_hohr1 i.rdp*i.pg_care_hohr1 if u==1 & max_age<17 & (c_mthhh==1 | c_fthhh==1), cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.pg_hohr1 i.rdp*i.care_hohr1 i.rdp*i.pg_care_hohr1 if u==0 & max_age<17 & (c_mthhh==1 | c_fthhh==1), cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*i.pg_hohr1 i.rdp*i.care_hohr1 i.rdp*i.pg_care_hohr1 if u==1 & max_age<17, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.pg_hohr1 i.rdp*i.care_hohr1 i.rdp*i.pg_care_hohr1 if u==0 & max_age<17, cluster(hh1) fe robust



**********************
*** DECISION MAKER ***
**********************

use mech_c_edu_v1, clear

xtset pid
egen max_age=max(a), by(pid)

g pg_hoh=(relhh==4 | relhh==13)
g pg_hoh_id=pg_hoh if r==1
egen pg_hohr1=max(pg_hoh_id), by(pid)

g care_hoh=(care==8 | care==14)

xi: xtreg care_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg care_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** works with alternate measure; more likely to have parent as primary caretaker
* not only as head of household... 

** robustness, parent or grandparent as main decision maker

** presence of joint decisionmaker

g m_exp=(a_decd==pid | a_decdpid==pid)
g j_exp=(a_decd2==pid | a_decdpid2==pid)
g m_lrg=(a_declrg==pid | a_declrgpid==pid)
g j_lrg=(a_declrg2==pid | a_declrgpid2==pid)
g m_sch=(a_decsch==pid | a_decschpid==pid)
g j_sch=(a_decsch2==pid | a_decschpid2==pid)
g m_mem=(a_decmem==pid | a_decmempid==pid)
g j_mem=(a_decmem2==pid | a_decmempid2==pid)
g m_liv=(a_declv==pid | a_declvpid==pid)
g j_liv=(a_declv2==pid | a_declvpid2==pid)


* 1.) parent is main decision maker
* 2.) parent is joint decision maker
* 3.) 

***************************
*** HOUSEHOLD STRUCTURE ***
***************************

use mech_c_edu_v1, clear

xtset pid
egen max_age=max(a), by(pid)

forvalues r=1/26 {
g hoh_`r'=r_relhead
replace hoh_`r'=0 if r_relhead!=`r'
replace hoh_`r'=1 if r_relhead==`r'
}

quietly xi: xtreg hoh_1 rdp i.prov*i.r if u==1 & max_age<15, fe cluster(hh1) robust
outreg2 using hoh,  label replace nocons keep(rdp)
forvalues r=2/26 {
forvalues z=0/1 {
quietly xi: xtreg hoh_`r' rdp i.prov*i.r if u==`z' & max_age<15, fe cluster(hh1) robust
outreg2 using hoh,  label append nocons keep(`var')
}
}
*** produces table of every relationship: kids moving in with parents and grandparents more in urban areas
* and that's exactly it !

** ANALYZE BY RESIDENT AND ESTABLISH CONTROL VARAIBLES **

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

g care_hoh=(care==8 | care==14)
g care_hoh_id=care_hoh if r==1
egen care_hohr1=max(care_hoh_id), by(pid)

g pg_care_hohr1=pg_hohr1*care_hohr1

egen median_weight=median(weight), by(a)
egen sd_weight=sd(weight), by(a)

g z_weight=(weight-median_weight)/sd_weight

** is it parent as resident or parent as care taker?

g m_f_res=(c_mthhh==1 | c_fthhh==1)
g m_f_res_id=m_f_res if r==1
egen m_f_resr1=max(m_f_res_id), by(pid)

g pg_m_f_int=m_f_resr1*pg_hohr1
xi: xtreg p_hoh rdp if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg g_hoh rdp if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg p_hoh rdp if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg p_hoh rdp if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg g_hoh rdp if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg g_hoh rdp if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg p_hoh rdp if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg p_hoh rdp if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust

xi: xtreg g_hoh rdp if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg g_hoh rdp if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust


**** URBAN AREAS:
** 1.) PARENTS as HOH increase 6%
** 2.) GRAND PARENTS as HOH decrease 4%

** 3.) PARENTS as HOH don't change if parents are already present
** 4.) GRAND PARENTS as HOH don't change if parents are already present

** 5.) PARENTS as HOH increase 14% if parents are NOT already present ( WOW )
** 6.) GRAND PARENTS as HOH decrease 12% if parents are NOT already present ( WOW )
****

**** RURAL AREAS:
** 1.) PARENTS as HOH increase 5%
** 2.) GRAND PARENTS as HOH decrease 14% ( WOW )

** 3.) PARENTS as HOH slightly increase if parents are already present
** 4.) GRAND PARENTS as HOH decrease 13% ( WOW ) if parents are already present

** 5.) PARENTS as HOH don't change (slightly positive) when parents are NOT already present
** 6.) GRAND PARENTS as HOH decrease 18% ( WOW ) if parents are NOT already present
****

*** NEED TO ADD IN GEOGRAPHIC FIXED EFFECTS!!!

** OVERALL
xi: xtreg p_hoh rdp if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
** both positive
xi: xtreg p_hoh rdp if u==0 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** first positive then nothing

xi: xtreg g_hoh rdp if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
** negative then positive
xi: xtreg g_hoh rdp if u==0 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
** negative then more weakly negative

** PARENTS ALREADY RESIDENT
xi: xtreg p_hoh rdp if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** positive, then more positive!
xi: xtreg p_hoh rdp if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** positive, then nothing * that's good!

xi: xtreg g_hoh rdp if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** nothing, then positive!
xi: xtreg g_hoh rdp if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** very negative then not that negative

** PARENTS NOT ALREADY RESIDENT
xi: xtreg p_hoh rdp if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
** very positive, then still very positive
xi: xtreg p_hoh rdp if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r*i.prov if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
** weakly positive, then absolutely nothing

xi: xtreg g_hoh rdp if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==1 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
** very negative, then nothing at all
xi: xtreg g_hoh rdp if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r*i.prov if u==0 & max_age<16 & m_f_resr1==0, cluster(hh1) fe robust
** very negative, then absolutely nothing

** CONCLUSION: NEED TO USE FIXED EFFECTS, ALSO FOCUS ON PARENTS , not GRAND PARENTS

** WHAT IS THE STORY?

* no aggregate changes for rural area, so no changes in health outcomes?

* focus on changes in urban areas:
*** parent as hoh goes up, even if parent is already resident
** stronger when parent is not already there, but still pretty strong







use mech_c_edu_v1, clear

xtset pid
egen max_age=max(a), by(pid)

** SEX OF HOH **
* hoh_gender

** AGE OF HOH **
* hoh_a

** MULTI-GENERATIONAL **
g gpar_id=(a>60 & a<.)
g par_id=(a<=60 & a>30)
egen gpar=max(gpar_id), by(hhid)
egen par=max(par_id), by(hhid)
g multi=(gpar==1 & par==1)

** RELATIONSHIP TO HOH **
g par_hoh=relhh==4
g gpar_hoh=(relhh==13)
g ggpar_hoh=relhh==22
g unc_hoh=relhh==19
g bro_hoh=relhh==12
g step_hoh=(relhh>=5 & relhh<=7)

g unc_bro_oth_step=(relhh==19 | relhh==12 | relhh==25 | relhh==26 | (relhh>=5 & relhh<=7))

g other_hoh=(relhh==25 | relhh==26)

g np_ng_hoh=(relhh!=4 & relhh!=13 & relhh!=22)

** bottom half
g bottom_half=(relhh<13 & relhh!=4)
g top_half=(relhh>13 & relhh!=22)

g uncle_or_aunt=(relhh==18)
tab relhh rdp if max_age<13

** MULTI GENERATION!!!
sort pid r
by pid: g par_ch=par_hoh[_n]-par_hoh[_n-1]
by pid: g gpar_ch=gpar_hoh[_n]-gpar_hoh[_n-1]
** definitely looks positively correlated
replace par_ch=. if r==3
replace gpar_ch=. if r==3
g h_ch1=h_ch
replace h_ch1=. if r==3
tab par_ch h_ch1
tab gpar_ch h_ch1
** if you gained a parent, who did you live with in the first round?
egen max_par_ch=max(par_ch), by(pid)
egen max_gpar_ch=max(gpar_ch), by(pid)
egen max_h_ch=max(h_ch1), by(pid)

tab relhh max_par_ch if r==1 & max_h_ch==1 & max_age<15
tab relhh max_gpar_ch if r==1 & max_h_ch==1 & max_age<15

** figure out exactly what is happening

** grandparent is slightly negative, great_grandparent is slightly positive

xi: xtreg par_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg par_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** very pos
xi: xtreg gpar_hoh rdp i.prov*i.r if u==1 & max_age<15, fe cluster(hh1) robust
xi: xtreg gpar_hoh rdp i.prov*i.r if u==0 & max_age<15, fe cluster(hh1) robust
** very pos
xi: xtreg np_ng_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg np_ng_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** very negative
xi: xtreg bottom_half rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg bottom_half rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** nothing
xi: xtreg top_half rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg top_half rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** so it's in the top half

xi: xtreg unc_bro_oth_step rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg unc_bro_oth_step rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust

xi: xtreg uncle_or_aunt rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg uncle_or_aunt rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust

xi: xtreg other_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg other_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** nothing
xi: xtreg step_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg step_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust
** nope 
xi: xtreg absent_hoh rdp i.prov*i.r if u==1 & max_age<13, fe cluster(hh1) robust
xi: xtreg absent_hoh rdp i.prov*i.r if u==0 & max_age<13, fe cluster(hh1) robust

*** hard to pinpoint !

** SPLIT: CHILD OUT **
egen max_child_out=max(child_out), by(hhid)
g split=(max_child_out>0 & max_child_out<.)

** children, adults **

** effect on size across these sources of heterogeneity
global structure1 "multi gpar par par_hoh gpar_hoh unc_hoh bro_hoh split"

global structure

foreach l in structure {
quietly xi: xtreg size rdp, fe cluster(hh1) robust
outreg2 using `l',  label replace nocons keep(rdp)
foreach o in $`l' {
foreach var in rdp rdpd rdpt rdpo {
quietly xi: xtreg `o' `var' i.prov*i.r if u==1, fe cluster(hh1) robust
outreg2 using `l',  label append nocons keep(`var')
quietly xi: xtreg `o' `var' i.prov*i.r if u==0, fe cluster(hh1) robust
outreg2 using `l',  label append nocons keep(`var')
}
}
}

** IF PEOPLE ARENT LIVING WITH THEIR FAMILIES WHO ARE THEY LIVING WITH?







