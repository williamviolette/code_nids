
cd "/Users/willviolette/Desktop/pstc_work/nids"

**&*&*&*&&*&**

use mech_c_edu_v1, clear

* drop if prov==9 | prov==10 | prov==6

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
replace z_weight=. if z_weight>6 | z_weight<-6

*** WHAT IS HAPPENING TO FAMILIES ?!?!?!

egen opid=max(h_ownpid1), by(hhid)
egen opid2=max(h_ownpid2), by(hhid)
g p_own=(opid==c_mthhh_pid | opid==c_fthhh_pid | opid2==c_mthhh_pid | opid2==c_fthhh_pid )

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


*** LOOK MORE CAREFULLY AT HOW THESE HOUSEHOLDS ARE EXACTLY CHANGING

xi: xtreg multi rdp i.r, robust cluster(hh1) fe
xi: xtreg multi rdp i.r if u==1, robust cluster(hh1) fe
xi: xtreg multi rdp i.r if u==0, robust cluster(hh1) fe
** no relationship with multi-generation

*** HOW MANY MIGRATE TOGETHER?

duplicates tag hh1 r hhid, g(mi)
g i=1
egen hr=sum(i), by(hhid)
g tg=mi/hr

xi: xtreg tg rdp i.r, robust cluster(hh1) fe
xi: xtreg tg rdp i.r if u==1, robust cluster(hh1) fe
xi: xtreg tg rdp i.r if u==0, robust cluster(hh1) fe
** more likely to migrate together in rural areas (less family dynamics)

xi: xtreg child_alt rdp i.r, robust cluster(hh1) fe
xi: xtreg child_alt rdp i.r if u==1, robust cluster(hh1) fe
xi: xtreg child_alt rdp i.r if u==0, robust cluster(hh1) fe
** more children, not concentrated in either area

*** WHY DOES THE AGE OF THE HEAD OF HOUSEHOLD GO UP IN URBAN AREAS?
xi: xtreg hoh_a rdp i.r, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==1, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==0, robust cluster(hh1) fe

xi: xtreg hoh_a rdp i.r if hoh_a>20, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==1 & hoh_a>20, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==0 & hoh_a>20, robust cluster(hh1) fe

xi: xtreg hoh_a rdp i.r if m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==1 & m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_a rdp i.r if u==0 & m_hoh_a_ch>0, robust cluster(hh1) fe

xi: xtreg size rdp i.r if hoh==1, robust cluster(hh1) fe
xi: xtreg size rdp i.r if u==1 & hoh==1, robust cluster(hh1) fe
xi: xtreg size rdp i.r if u==0 & hoh==1, robust cluster(hh1) fe

xi: xtreg hoh_gender rdp i.r if m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_gender rdp i.r if u==1 & m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_gender rdp i.r if u==0 & m_hoh_a_ch>0, robust cluster(hh1) fe
* slightly more male?

sort pid r
by pid: g hoh_change=(relhh[_n]!=relhh[_n-1])

xi: xtreg hoh_change rdp i.r if m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_change rdp i.r if u==1 & m_hoh_a_ch>0, robust cluster(hh1) fe
xi: xtreg hoh_change rdp i.r if u==0 & m_hoh_a_ch>0, robust cluster(hh1) fe
** LESS LIKELY TO CHANGE THEIR HEAD OF HOUSEHOLD

tab hoh_change rdp
* more stability actually

sort pid r
by pid: g hoh_a_ch=hoh_a[_n]-hoh_a[_n-1]

egen m_hoh_a_ch=min(hoh_a_ch), by(pid)

sort pid r
by pid: g p_hoh_ch=p_hoh[_n]-p_hoh[_n-1]

tab p_hoh_ch h_ch if max_age<16
tab p_hoh_ch h_ch if max_age<16 & u==1
tab p_hoh_ch h_ch if max_age<16 & u==0
** this actually works!


hist hoh_a if hoh_a_ch>=0, by(rdp)


tab hoh_a_ch h_ch if u==1
tab hoh_a_ch h_ch if u==0

hist hoh_a_ch if rdp!=., by(h_ch)

****** WOMEN ANALYSIS ******


g part_o=(r_parhpid==opid | r_parhpid==opid2)

g rdp_p=rdp
replace rdp_p=0 if part_o==0
g rdp_n=rdp
replace rdp_n=0 if part_o==1

sort pid r
by pid: g p_ch=rdp_p[_n]-rdp_p[_n-1]
by pid: g n_ch=rdp_n[_n]-rdp_n[_n-1]

replace rdp_p=1 if p_ch==-1
replace rdp_n=1 if n_ch==-1

tab rdp_p if sex==1 & own==0
tab rdp_n if sex==1 & own==0



xi: xtreg e rdp_p rdp_n i.r if own==0 & sex==1, robust cluster(hh1) fe

xi: xtreg e rdp_p rdp_n i.r if own==0 & sex==0, robust cluster(hh1) fe

xi: xtreg ue rdp_p rdp_n i.r if own==0 & sex==0, robust cluster(hh1) fe






















