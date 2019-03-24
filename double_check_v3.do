
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

replace z_weight=. if z_weight>6 | z_weight<-6
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

g pid_hoh_id=pid if hoh==1
egen pid_hoh=max(pid_hoh_id), by(hhid)
g f_hoh=c_fthhh_pid==pid_hoh
g m_hoh=c_mthhh_pid==pid_hoh

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
replace rdp_np=1 if np_ch==-1

g non_fd_per=non_fd/te

g dep=a_emodep if a_emodep>0

g stunt=zhfa<-2

g absent_d=(absent>0)

replace rooms=. if rooms==0

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

**********************
*** START ANALYSIS ***


xi: xtreg a g_hoh p_hoh if  max_age<16, cluster(hh1) fe robust

** no difference in age
reg a rdp_op u i.r if (rdp_op==1 | rdp_np==1) & max_age<16, cluster(hh1) robust
* older kids go with parents
reg rdp_op a sex c_att1 absent  u i.r if (rdp_op==1 | rdp_np==1) & max_age<16, cluster(hh1) robust

reg c_att1 rdp_op a u i.r if (rdp_op==1 | rdp_np==1), cluster(hh1) robust



** no differences in house attributes! **

reg rooms rdp_op u i.r if (rdp_op==1 | rdp_np==1), cluster(hh1) robust
reg piped rdp_op u i.r if (rdp_op==1 | rdp_np==1), cluster(hh1) robust
reg mktv rdp_op u i.r if (rdp_op==1 | rdp_np==1), cluster(hh1) robust
reg elec rdp_op u i.r if (rdp_op==1 | rdp_np==1), cluster(hh1) robust

**** **** **** **** ****
*** PARENTS MORE LIKELY TO PAY EXPENSES WHEN OWN THE HOUSE
xi: xtreg p_pay rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg p_pay rdp_np rdp_op i.r if  max_age<16 & m_f_resr1==1, cluster(hh1) fe robust
* robust to parents present
xi: xtreg p_pay rdp_np rdp_op i.r if  max_age<16 & p_hohr1==1, cluster(hh1) fe robust
xi: xtreg p_pay rdp_np rdp_op i.r if  max_age<16 & g_hohr1==1, cluster(hh1) fe robust
* driven by grandparents as hoh

xi: xtreg rooms rdp i.r if  max_age<16, cluster(hh1) fe robust

xi: xtreg rooms rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust

xi: xtreg f_res rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg m_res rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg m_f_res rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust


xi: xtreg p_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg g_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust


xi: xtreg f_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
xi: xtreg m_hoh rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust

*** KEEP ALL OF THE DEMOGRAPHICS CONSTANT ***

* more likely to have hoh care for child?


xi: xtreg inc rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg te rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg sch_per rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg health_exp_per rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
** health spending goes up for parents
xi: xtreg fd_share rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
* replaced for food
xi: xtreg public_per rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg non_fd_per rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
* not much here

xi: xtreg e rdp_np rdp_op i.r, cluster(hh1) fe robust

xi: xtreg size rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg kids_per_adult rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
xi: xtreg child rdp_np rdp_op i.r if max_age<16, cluster(hh1) fe robust
* no change for children, no change in ratio fo kids to adult

*** EDUCATION

** intensive margin
xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>12 & absent>0, cluster(hh1) fe robust
* pretty strong against age restrictions
xi: xtreg absent rdp_np rdp_op i.r if u==1 & max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op i.r if u==0 & max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
** more likely to be absent! almost totally mitigated by parent ownership

** extensive margin
xi: xtreg absent_d rdp_np rdp_op i.r if max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
xi: xtreg absent_d rdp_np rdp_op i.r if u==1 & max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
xi: xtreg absent_d rdp_np rdp_op i.r if u==0 & max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
** increase for non-grandparent

xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & c_att1==1, cluster(hh1) fe robust
** aggregate works too!

xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & own_d==1, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & own_d==0, cluster(hh1) fe robust
* strongest for already owners, which makes sense (more room to rearrange family)

** ROBUST:
* * * intensive * * *
* parents resident
xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & absent>0 & m_f_resr1==1, cluster(hh1) fe robust
* still holds
xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & absent>0 & p_hohr1==1, cluster(hh1) fe robust
xi: xtreg absent rdp_np rdp_op i.r if max_age<16 & max_age>6 & absent>0 & g_hohr1==1, cluster(hh1) fe robust
* holds no matter who is initially head of household
xi: xtreg absent rdp_np rdp_op m_res f_res size child_alt i.r if max_age<16 & max_age>6 & absent>0, cluster(hh1) fe robust
* control directly for residence of mother father and children: Gets even better with more controls!


xi: xtreg c_failed rdp_np rdp_op i.r if max_age<15 & max_age>10, cluster(hh1) fe robust
** ALSO: Increase in grades failed! 

xi: xtreg c_att1 rdp_np rdp_op a a_2 i.r*i.prov if max_age<15 & max_age>10, cluster(hh1) fe robust
** attendance is unchanged

xi: xtreg c_fees rdp_np rdp_op i.r*i.prov if max_age<15 & max_age>10, cluster(hh1) fe robust
** no change in fees

xi: xtreg class_size rdp_np rdp_op i.r*i.prov if max_age<15 & max_age>10, cluster(hh1) fe robust
** no change in class size

xi: xtreg sch_q rdp_np rdp_op i.r*i.prov if max_age<15, cluster(hh1) fe robust
** no change in school quality

xi: xtreg sch_d rdp_np rdp_op i.r*i.prov if max_age<15, cluster(hh1) fe robust
*** distance to school declines for grandparents

xi: xtreg sch_s rdp_np rdp_op i.r if  max_age<16, cluster(hh1) fe robust
** uncorrelated with school spending


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



xi: xtreg zhfa rdp_np rdp_op i.r if max_age<8, cluster(hh1) fe robust
xi: xtreg zhfa rdp_np rdp_op i.r if u==1 & max_age<10, cluster(hh1) fe robust
xi: xtreg zhfa rdp_np rdp_op i.r if u==0 & max_age<10, cluster(hh1) fe robust

xi: xtreg stunt rdp_np rdp_op i.r if max_age<8, cluster(hh1) fe robust
xi: xtreg stunt rdp_np rdp_op i.r if u==1 & max_age<8, cluster(hh1) fe robust
xi: xtreg stunt rdp_np rdp_op i.r if u==0 & max_age<8, cluster(hh1) fe robust
* Grand-Parent RDP stunts children! in rural areas

xi: xtreg zwfa rdp_np rdp_op i.r if u==1 & max_age<10, cluster(hh1) fe robust
xi: xtreg zwfa rdp_np rdp_op i.r if u==0 & max_age<10, cluster(hh1) fe robust


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





