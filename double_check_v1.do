
cd "/Users/willviolette/Desktop/pstc_work/nids"

**&*&*&*&&*&**

use mech_c_edu_v1, clear

drop if prov==9 | prov==10 | prov==6

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
g step_hoh=(relhh>=5 & relhh<=7)
g step_hoh_id=step_hoh if r==1
egen step_hohr1=max(step_hoh_id), by(pid)
g bro_hoh=(relhh==12)
g bro_hoh_id=bro_hoh if r==1
egen bro_hohr1=max(bro_hoh_id), by(pid)

g pg_care_hohr1=pg_hohr1*care_hohr1

*** STUNTING MEASURES

egen median_weight=median(weight), by(a sex)
egen sd_weight=sd(weight), by(a sex)
g z_weight=(weight-median_weight)/sd_weight

g c_w=c_weight_1 if c_weight_1>0
replace c_w=(c_w+c_weight_2)/2 if c_weight_2>0 & c_weight_2<.
egen median_c_w=median(c_w), by(a sex)
egen sd_c_w=sd(c_w), by(a sex)
g zc_w=(c_w-median_c_w)/sd_c_w

g waste_z=(z_weight<-2)
g waste_c=(zc_w<-2)


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

g gpar_id=(a>60 & a<.)
g par_id=(a<=60 & a>30)
egen gpar=max(gpar_id), by(hhid)
egen par=max(par_id), by(hhid)

g multi=(gpar==1 & par==1)


g a_2=a*a

*** KEEP ONLY ALL THREE ROUNDS! ***
g rr=1
egen rrs=sum(rr), by(pid)
tab rrs if max_age<16
keep if rrs==3

egen opid=max(h_ownpid1), by(hhid)
egen opid2=max(h_ownpid2), by(hhid)
g p_own=(opid==c_mthhh_pid | opid==c_fthhh_pid | opid2==c_mthhh_pid | opid2==c_fthhh_pid )

tab p_own if max_age<16

replace z_weight=. if z_weight>6 | z_weight<-6

g rdp_np=rdp
replace rdp_np=0 if p_own==1
g rdp_op=rdp
replace rdp_op=0 if p_own==0

sort pid r
by pid: g np_ch=rdp_np[_n]-rdp_np[_n-1]
by pid: g op_ch=rdp_op[_n]-rdp_op[_n-1]
tab np_ch
tab op_ch
replace rdp_op=1 if op_ch==-1

g non_fd_per=non_fd/te

g dep=a_emodep if a_emodep>0

g stunt=zhfa<-2

g absent_d=(absent>0)



xi: xtreg zc_w rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg zc_w rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg waste_z rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg waste_z rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg waste_c rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg waste_c rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg zhfa rdp_np rdp_op i.r if max_age<8, cluster(hh1) fe robust

xi: xtreg zhfa rdp_np rdp_op i.r if u==1 & max_age<10, cluster(hh1) fe robust
xi: xtreg zhfa rdp_np rdp_op i.r if u==0 & max_age<10, cluster(hh1) fe robust

xi: xtreg stunt rdp_np rdp_op i.r if max_age<8, cluster(hh1) fe robust
xi: xtreg stunt rdp_np rdp_op i.r if u==1 & max_age<8, cluster(hh1) fe robust
xi: xtreg stunt rdp_np rdp_op i.r if u==0 & max_age<8, cluster(hh1) fe robust
* Grand-Parent RDP stunts children!

xi: xtreg zwfa rdp_np rdp_op i.r if u==1 & max_age<10, cluster(hh1) fe robust
xi: xtreg zwfa rdp_np rdp_op i.r if u==0 & max_age<10, cluster(hh1) fe robust

**** **** **** ****

xi: xtreg p_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust

xi: xtreg p_hoh rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg p_hoh rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg g_hoh rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg m_f_res rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg m_f_res rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust


*** KEEP ALL OF THE DEMOGRAPHICS CONSTANT ***
xi: xtreg size rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg size rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
** no change in total size, but a change in composition

xi: xtreg kids_per_adult rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg kids_per_adult rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg child rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg child rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
* no change for children, no change in ratio fo kids to adult

*** EXPLORE REDUCED FORM ***
xi: xtreg te rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg te rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg inc rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg inc rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg fd_share rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg fd_share rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg y_alt rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg y_alt rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg public_per rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg public_per rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg non_fd_per rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg non_fd_per rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg health_exp_per rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg health_exp_per rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg sch_per rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg sch_per rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg vice_per rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg vice_per rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

* expenditure patterns are very clear here; what is going on???


*** EDUCATION

** intensive margin
xi: xtreg absent rdp_np rdp_op a a_2 i.r if max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op a a_2 i.r if u==1 & max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op a a_2  i.r if u==0 & max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
** more likely to be absent! almost totally mitigated by parent ownership

** extensive margin
xi: xtreg absent_d rdp_np rdp_op i.r if max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
xi: xtreg absent_d rdp_np rdp_op i.r if u==1 & max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
xi: xtreg absent_d rdp_np rdp_op i.r if u==0 & max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
** increase for non-grandparent

xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op i.r if u==1 & max_age<16 & max_age>6, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op i.r if u==0 & max_age<16 & max_age>6, cluster(hh1) fe robust
** not much on aggregate..


xi: xtreg c_failed rdp_np rdp_op i.r if max_age<16 & max_age>11, cluster(hh1) fe robust

xi: xtreg c_failed rdp_np rdp_op i.r if u==1 & max_age<16 & max_age>6, cluster(hh1) fe robust
* fail more when grandparent owns the house for urban areas
xi: xtreg c_failed rdp_np rdp_op i.r if u==0 & max_age<16 & max_age>6, cluster(hh1) fe robust
* fail less when grandparent owns the house for rural areas

xi: xtreg lratio rdp_np rdp_op a a_2 i.r*i.prov if u==1 & max_age<15 & max_age>10, cluster(hh1) fe robust
xi: xtreg lratio rdp_np rdp_op a a_2 i.r*i.prov if u==0 & max_age<15 & max_age>10, cluster(hh1) fe robust



xi: xtreg c_att1 rdp_np rdp_op a a_2 i.r*i.prov if u==1 & max_age<15 & max_age>10, cluster(hh1) fe robust
xi: xtreg c_att1 rdp_np rdp_op a a_2 i.r*i.prov if u==0 & max_age<15 & max_age>10, cluster(hh1) fe robust
** attendance is unchanged

xi: xtreg c_fees rdp_np rdp_op a a_2 i.r*i.prov if u==1 & max_age<15 & max_age>10, cluster(hh1) fe robust
xi: xtreg c_fees rdp_np rdp_op a a_2 i.r*i.prov if u==0 & max_age<15 & max_age>10, cluster(hh1) fe robust
** fees are reduced, there is some change in quality..

*** HEALTH

xi: xtreg check_up rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg check_up rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
* non parent reduces check-ups in rural areas..

xi: xtreg c_ill rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
* non parent kids get healthier in rural areas..

xi: xtreg c_ill i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg c_health rdp_np rdp_op i.r if u==1 & max_age<16 & r!=2, cluster(hh1) fe robust
xi: xtreg c_health rdp_np rdp_op i.r if u==0 & max_age<16 & r!=2, cluster(hh1) fe robust
** HEALTH DETERIORATES!!!  less spending on food, more on vices


xi: xtreg c_health i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_health i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg c_w rdp_np rdp_op a a_2 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op a a_2 i.r if u==0 & max_age<16, cluster(hh1) fe robust
** WEIGHT IS NOT ROBUST TO QUADRATIC IN AGE
xi: xtreg c_w rdp_np rdp_op i.r if u==1 & max_age<10 & max_age>6, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op i.r if u==0 & max_age<10 & max_age>6, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op i.r if u==1 & max_age<6, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op i.r if u==0 & max_age<6, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op i.r if u==1 & max_age>=10 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_w rdp_np rdp_op i.r if u==0 & max_age>=10 & max_age<16, cluster(hh1) fe robust
** WEIGHT GOES AWAY!

xi: xtreg zc_w rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg zc_w rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg weight rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg weight rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg zwfa rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg zwfa rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
** nothing
xi: xtreg zwfh rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg zwfh rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
** nothing

xi: xtreg z_weight i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp_np*i.p_hohr1 i.rdp_op*i.p_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust





xi: xtreg dep rdp i.r if u==1, cluster(hh1) fe robust
xi: xtreg dep rdp i.r if u==0, cluster(hh1) fe robust

xi: xtreg dep rdp_np rdp_op i.r if u==1, cluster(hh1) fe robust
xi: xtreg dep rdp_np rdp_op i.r if u==0, cluster(hh1) fe robust


foreach v in theft domvio vio gang murder drug {
xi: xtreg `v' rdp_np rdp_op i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg `v' rdp_np rdp_op i.r if u==0 & max_age<16, cluster(hh1) fe robust
}
*** nothing! that's good

*** ARE CHILDREN IN ALL THREE ROUNDS?!
g rr=1
egen rrs=sum(rr), by(pid)
tab rrs if max_age<16

*** OWNERSHIP AND HOH CORRELATION
tab r_relhead own if rdp==1
tab r_relhead own if rdp==0

*** IF PARENT GAINS OWNERSHIP OF RDP, INCREASE PROBABILITY THAT PARENT IS HOH?



*** STEP BACK! NEED TO MORE CLEARLY UNDERSTAND THE FIRST STAGE


*** CRUCIAL FOR PROVINCE DROP

tab prov h_ch if max_age<16

drop if prov==9 | prov==10 | prov==6

tab multi rdp

xi: xtreg multi rdp i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg multi rdp i.r if u==0 & max_age<16, cluster(hh1) fe robust
** more likely to have multi with rural?


xi: xtreg g_hoh rdp i.r if u==0 & max_age<16, cluster(hh1) fe robust


** FIRST STAGE:

tab p_hoh rdp if max_age<16
replace size=. if size==1 & max_age<16
tab size rdp if max_age<16

* UNDERSTAND WHAT TYPE OF HHs ARE DRIVING P_HOH AND G_HOH

* WHAT IF WE LOOK AT KIDS PRESENT IN ALL THREE ROUNDS!
xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & rrs==3, cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r if u==0 & max_age<16 & rrs==3, cluster(hh1) fe robust
** robust to this control


*** NOW CONDITION ON DIFFERENT THINGS
sort pid r
by pid: g p_hoh_ch=p_hoh[_n]-p_hoh[_n-1]
by pid: g g_hoh_ch=g_hoh[_n]-g_hoh[_n-1]

tab p_hoh_ch h_ch if u==1 & max_age<16
tab g_hoh_ch h_ch if u==1 & max_age<16

egen p_m_ch=max(p_hoh_ch), by(pid)
egen g_m_ch=max(g_hoh_ch), by(pid)
egen max_h_ch=max(h_ch), by(pid)

tab r_relhead max_h_ch if p_m_ch==1 & r==1 & max_age<16

tab r_relhead max_h_ch if p_m_ch==1 & r==1 & max_age<16


* if grandparent is already hoh
xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 & g_hohr1==1 , cluster(hh1) fe robust
* nothing when gparent is hoh
xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 & unc_hohr1==1 , cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 & unc_hohr1==0 , cluster(hh1) fe robust



xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 & g_hohr1==1 , cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 & g_hohr1==1 , cluster(hh1) fe robust



xi: xtreg p_hoh rdp i.r if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust



xi: xtreg p_hoh i.rdp*i.sizer1 i.r if u==1 & max_age<16 & m_f_resr1==1 & size>2, cluster(hh1) fe robust
xi: xtreg g_hoh i.rdp*i.sizer1 i.r if u==1 & max_age<16 & m_f_resr1==1 & size>2, cluster(hh1) fe robust
* both coming from small size households?



xi: xtreg p_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1 , cluster(hh1) fe robust
xi: xtreg p_hoh rdp i.r if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
** way more for parents in urban areas, nothing for rural

xi: xtreg g_hoh rdp i.r if u==1 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg g_hoh rdp i.r if u==0 & max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* positive grandparents in urban

xi: xtreg unc_hoh rdp i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg unc_hoh rdp i.r if u==0 & max_age<16, cluster(hh1) fe robust
** no uncle effect anywhere

* very positive in urban
xi: xtreg pg_hoh rdp i.r if u==1 & max_age<16, cluster(hh1) fe robust
* nothing in rural
xi: xtreg pg_hoh rdp i.r if u==0 & max_age<16, cluster(hh1) fe robust

tab pg_hohr1 rdp if max_age<16

tab p_hohr1 rdp if max_age<16

tab g_hohr1 rdp if max_age<16

 tab p_hoh rdp if max_age<16
 
  tab g_hoh rdp if max_age<16




** WEIGHT IS POSITIVELY CORRELATED WITH TIME (is that really clear?) < WHEN DROP THE OUTLIER IT DIES! >
xi: xtreg z_weight i.rdp*i.pg_hohr1 i.r if u==1 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.pg_hohr1 i.r if u==0 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust

* no cluster
xi: xtreg z_weight i.rdp*i.pg_hohr1 i.r if max_age<16 & z_weight>-5 & z_weight<5, fe robust
xi: xtreg z_weight i.rdp*i.pg_hohr1 i.r if max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust


xi: xtreg z_weight i.rdp*i.p_hohr1 i.r if max_age<16 & z_weight>-5 & z_weight<5 & m_f_resr1==1, cluster(hh1) fe robust

xi: xtreg z_weight i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & z_weight>-5 & z_weight<5 & m_f_resr1==1 & u==1, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & z_weight>-5 & z_weight<5 & m_f_resr1==1 & u==0, cluster(hh1) fe robust

xi: xtreg fd_share i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & m_f_resr1==1 & u==1, cluster(hh1) fe robust
xi: xtreg fd_share i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & m_f_resr1==1 & u==0, cluster(hh1) fe robust

xi: xtreg fd_share i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & m_f_resr1==1 & u==1, cluster(hh1) fe robust
xi: xtreg fd_share i.rdp*i.p_hohr1 i.r*i.prov if max_age<16 & m_f_resr1==1 & u==0, cluster(hh1) fe robust




xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if max_age<16 & m_f_resr1==1 & u==1, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if max_age<16 & m_f_resr1==1 & u==0, cluster(hh1) fe robust

xi: xtreg c_health i.rdp*i.p_hohr1 i.r if max_age<16 & z_weight>-5 & z_weight<5 & m_f_resr1==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 i.r if max_age<16 & m_f_resr1==1 & u==1, cluster(hh1) fe robust
xi: xtreg c_health i.rdp*i.p_hohr1 i.r if max_age<16 & m_f_resr1==1 & u==0, cluster(hh1) fe robust



xi: xtreg z_weight i.rdp*i.g_hohr1 i.r if max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust



xi: xtreg z_weight i.rdp*i.p_hohr1 i.r if u==1 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust
xi: xtreg z_weight i.rdp*i.p_hohr1 i.r if u==0 & max_age<16 & z_weight>-5 & z_weight<5, cluster(hh1) fe robust

xi: xtreg c_ill i.rdp*i.pg_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.pg_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust


xi: xtreg absent i.rdp*i.pg_hohr1 i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg c_failed i.rdp*i.pg_hohr1 i.r if  max_age<16, cluster(hh1) fe robust


xi: xtreg absent i.rdp*i.pg_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg absent i.rdp*i.pg_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust



xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if u==0 & max_age<16, cluster(hh1) fe robust

xi: xtreg c_ill i.rdp*i.p_hohr1 i.r if max_age<16, cluster(hh1) fe robust
** Also improving over time


xi: xtreg m_f_res rdp if u==1 & max_age<16, cluster(hh1) fe robust
xi: xtreg m_f_res rdp if u==0 & max_age<16, cluster(hh1) fe robust
* only urban

xi: xtreg f_res rdp i.r if u==1 & max_age<16, cluster(hh1) fe robust
* super negative
xi: xtreg f_res rdp i.r if u==0 & max_age<16, cluster(hh1) fe robust
* very positive

xi: xtreg m_res rdp i.r if u==1 & max_age<16, cluster(hh1) fe robust
*nothing
xi: xtreg f_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
*positive



* rural areas more likely to have a father present (sort of makes sense)
xi: xtreg m_res rdp i.r*i.prov if u==1 & max_age<16, cluster(hh1) fe robust
* driven by mother resident status! in urban areas
xi: xtreg m_res rdp i.r*i.prov if u==0 & max_age<16, cluster(hh1) fe robust
* nothing going on for women in rural areas



*************************************
*** TAKE A LOOK AT KID'S OUTCOMES ***
*************************************

use mech_c_edu_v1, clear


*** LOOK ONLY AT FIRST TWO ROUNDS ***
drop if r==1
drop if prov==9 | prov==10 | prov==6

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
g step_hoh=(relhh>=5 & relhh<=7)
g step_hoh_id=step_hoh if r==1
egen step_hohr1=max(step_hoh_id), by(pid)
g bro_hoh=(relhh==12)
g bro_hoh_id=bro_hoh if r==1
egen bro_hohr1=max(bro_hoh_id), by(pid)

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

g gpar_id=(a>60 & a<.)
g par_id=(a<=60 & a>30)
egen gpar=max(gpar_id), by(hhid)
egen par=max(par_id), by(hhid)

g multi=(gpar==1 & par==1)

*** ARE CHILDREN IN ALL THREE ROUNDS?!
g rr=1
egen rrs=sum(rr), by(pid)
tab rrs if max_age<16

drop if rdp==.

*** NOW CONDITION ON DIFFERENT THINGS
sort pid r
by pid: g p_hoh_ch=p_hoh[_n]-p_hoh[_n-1]
by pid: g g_hoh_ch=g_hoh[_n]-g_hoh[_n-1]

tab p_hoh_ch h_ch if u==1 & max_age<16
tab g_hoh_ch h_ch if u==1 & max_age<16

egen p_m_ch=max(p_hoh_ch), by(pid)
egen g_m_ch=max(g_hoh_ch), by(pid)
egen max_h_ch=max(h_ch), by(pid)

** initial relationship given that you switch
tab r_relhead max_h_ch if p_m_ch==1 & r==2 & max_age<16
tab r_relhead max_h_ch if p_m_ch==1 & r==2 & max_age<16 & u==1
tab r_relhead max_h_ch if p_m_ch==1 & r==2 & max_age<16 & u==0

tab r_relhead max_h_ch if g_m_ch==1 & r==2 & max_age<16
tab r_relhead max_h_ch if g_m_ch==1 & r==2 & max_age<16 & u==1
tab r_relhead max_h_ch if g_m_ch==1 & r==2 & max_age<16 & u==0


tab r_relhead max_h_ch if g_m_ch==1 & r==2 & max_age<16





