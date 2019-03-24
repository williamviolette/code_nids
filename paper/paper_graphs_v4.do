
cd "/Users/willviolette/Desktop/pstc_work/nids"

use mech_c_edu_v1, clear
*(*(*(*(*(*(*(*(*( GET PARENT IDS )*)*)*)*)*)*)*)*)*)*)*

egen max_age=max(a), by(pid)
replace r_parhpid=. if r_parhpid<0
rename r_parhpid f_pid

keep pid r a_bhchild_id* max_age f_pid
forvalues r=1/16 {
quietly replace a_bhchild_id`r'=. if a_bhchild_id`r'<100
}

save p_c_link, replace

use p_c_link, clear
keep if max_age<16
keep pid r 
save c_link, replace

forvalues r=1/16 {
quietly use p_c_link, clear
rename pid m_pid`r'
rename a_bhchild_id`r' pid
quietly drop if pid==.
keep pid m_pid`r' r f_pid
quietly merge 1:1 pid r using c_link
*tab _merge
quietly drop if _merge==1
quietly drop _merge
quietly save c_link, replace
}

use c_link, clear
egen m_pid=rowfirst(m_pid*)
keep pid m_pid r f_pid
drop if m_pid==.
save c_link_final, replace

use mech_c_edu_v1, clear
quietly merge 1:1 pid r using c_link_final
drop _merge

egen m_pid1=max(m_pid), by(pid)
egen f_pid1=max(f_pid) if f_pid>100, by(pid)
save mech_c_edu_v2, replace
*(*(*(*( NOW WE HAVE ACCURATE RELATIONSHIPS FOR PARENTS )*)*)*)*


****** NOW PROCEED WITH ANALYSIS ******

use mech_c_edu_v2, clear

xtset pid
egen max_age=max(a), by(pid)

** DROP PROVINCES
drop if prov==9 | prov==10 | prov==6

*(*(*(*(*(*(*(*(*(*( CLEAN THE RESIDENT VARIABLES )*)*)*)*)*)*)*)*)*)*)*)*

g c_f3=1 if c_fthhh_pid==77
replace c_f3=0 if c_fthhh_pid>100 & c_fthhh_pid<.
g c_m3=1 if c_mthhh_pid==77
replace c_m3=0 if c_mthhh_pid>100 & c_mthhh_pid<.

g f_res=1 if c_fthhh==1 | c_f3==0
replace f_res=0 if  c_fthhh==2 | c_f3==1
g m_res=1 if c_mthhh==1 | c_m3==0
replace m_res=0 if  c_mthhh==2 | c_m3==1

g f_res_id=f_res if r==1
egen f_resr1=max(f_res_id), by(pid)
g m_res_id=m_res if r==1
egen m_resr1=max(m_res_id), by(pid)
g m_f_res=(f_res==1 | m_res==1)
g m_f_res_id=m_f_res if r==1
egen m_f_resr1=max(m_f_res_id), by(pid)

*(*(*(*( CLEAN OWNERSHIP VARIABLES *)*)*)*)*)*)*)
replace h_ownpid1=. if h_ownpid1<100
replace h_ownpid2=. if h_ownpid2<100
egen opid=max(h_ownpid1), by(hhid)
egen opid2=max(h_ownpid2), by(hhid)

g f_own=opid==f_pid1
replace f_own=. if opid==.
g m_own=opid==m_pid1
replace m_own=. if opid==.
g p_own=(f_own==1 | m_own==1)
replace p_own=. if opid==.

tab f_res f_own if max_age<16, mis
tab m_res m_own if max_age<16, mis
tab m_f_res p_own if max_age<16, mis
** THESE FINALLY MAKE SENSE

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

*(*(*(*( HOH VARIABLES )*)*)*)*

g p_hoh=relhh==4
g p_hoh_id=p_hoh if r==1
egen p_hohr1=max(p_hoh_id), by(pid)
g g_hoh=relhh==13
g g_hoh_id=g_hoh if r==1
egen g_hohr1=max(g_hoh_id), by(pid)

g pid_hoh_id=pid if hoh==1
egen pid_hoh=max(pid_hoh_id), by(hhid)
g f_hoh=(f_pid1==pid_hoh_id)
replace f_hoh=. if f_pid1==.
g m_hoh=(m_pid1==pid_hoh_id)
replace m_hoh=. if m_pid1==.

*^*^**^*^^**^*^*^^*^*^*^**^*^*^*^*^*^*^*^*^*^*^*^*^**^*

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

foreach var of varlist p_hoh g_hoh m_res f_res absent_d {
replace `var'=. if max_age>15
}

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

*** INCOME CENSOR
egen max_inc=max(inc), by(pid)
drop if max_inc>20000
* drop if rdp==.

save paper, replace



***************************************
*** WORK TO FIND NEW TRENDS!!!!!!!!!!!!*****!!*!*!*!*!*!**!*!
***************************************

use paper, clear

sort pid r
by pid: g h_chu=rdp_u[_n]-rdp_u[_n-1]

** REMOVE ALREADY RDP'S! DON'T CONSIDER THEM TO BE CONTROLS!

g rfr1=rdp_fixed if r==1
egen rfid=max(rfr1), by(pid)
* drop if rfid==1

egen max_move=max(move), by(pid)
egen max_move1=max(move), by(hh1)



g prim_own=(opid==pid)
replace prim_own=. if pid==.
tab own prim_own, mis

replace own=prim_own

egen inf_max=max(inf), by(pid)

*** does the owner matter for who gets the house?
tab own

sort pid r
by pid: g own_ch=own[_n]-own[_n-1]
by pid: g still_own=(own[_n-1]==1 & own[_n]==1)
by pid: g new_own=(own[_n-1]==0 & own[_n]==1)


g rdp_owner_id=(h_ch==1 & own==1)
egen rdp_owner=max(rdp_owner_id), by(pid)

tab own_ch rdp_owner

tab new_own rdp_owner

tab new_own rdp_owner if inf_max==0 & u==1
tab still_own rdp_owner

** do newly owned rdp's have better rooms distribution?
hist rooms if rdp==1 & u==1 & rdp_owner==1, by(own_ch)
** no they don't

*** BASICALLY RDP'S SHOULD IMPACT SPACE OF 5 ROOMS OR GREATER!
** but not impact space of lesser households

g small=roomsr1<=5
replace small=. if roomsr1==.


* plot room changes for RDP's based on initial number of rooms

sort pid r
by pid: g room_ch=rooms[_n]-rooms[_n-1]
by pid: g room_chl=room_ch[_n+1]
by pid: g h_ch_lead=h_ch[_n+1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g piped_chl=piped_ch[_n+1]

by pid: g walls_b_ch=walls_b[_n]-walls_b[_n-1]
by pid: g walls_b_chl=walls_b_ch[_n+1]

by pid: g roof_cor_ch=roof_cor[_n]-roof_cor[_n-1]
by pid: g roof_cor_chl=roof_cor_ch[_n+1]

egen max_h_ch=max(h_ch), by(pid)

by pid: g rooms_lead=rooms[_n+1]




** just hist the next period's rooms based on first period rooms
hist rooms_lead if u==1 & h_ch>=0, by(rooms h_ch)						
hist rooms_lead if u==0 & h_ch>=0, by(rooms h_ch)						
										****		****						<<<<< MOST DAMNING GRAPH OF ALL!!!!

hist rooms_lead if u==1 & h_ch>=0 & inf_max==1, by(rooms h_ch)		
* absolutely no change in rooms				
hist piped_chl if u==1 & h_ch>=0 & inf_max==1, by(rooms h_ch)						
** decline in piped water?!

hist piped_chl if u==1 & h_ch>=0, by(rooms h_ch)						
hist piped_chl if u==0 & h_ch>=0, by(rooms h_ch)						
** nothing here, a little bit for informal upgrading

hist walls_b_chl if u==1 & h_ch>=0, by(rooms h_ch)						

hist roof_cor_chl if u==1 & h_ch>=0, by(rooms h_ch)						



** room change by initial rooms when you get an rdp
tab room_chl rooms if max_h_ch==1 & u==1

* what about if you don't get an RDP
tab room_chl rooms if max_h_ch==0 & u==1


tab roomsr1 rdp

hist room_chl if u==1 & max_h_ch>=0 & rfid!=1 & max_move==0, by(rooms max_h_ch) 
* this graph says it all

* hist room_chl if max_h_ch==0 & u==1, by(rooms)


hist rooms, by(r)


xi: xtreg rooms rdp i.r if max_age<16 & small==1 & u==1, fe robust cluster(hh1)
xi: xtreg rooms rdp i.r if max_age<16 & small==0 & u==1, fe robust cluster(hh1)



xi: xtreg rooms i.rdp*i.small i.r if max_age<16, fe robust cluster(hh1)





g move1=move
egen min_move=min(move), by(pid)
replace move1=0 if min_move!=. & r==1

tab move1 r

tab size if max_age<16

*hist size if size<16 & max_age<16, by (rdp)

replace size=. if size>16

sort pid r
by pid: g size_ch=size[_n]-size[_n-1]
by pid: g size_chl=size_ch[_n+1]
by pid: g h_chl=h_ch[_n+1]
by pid: g h_ch_new=rdp[_n]-rdp[_n-1]


tab size_chl size if max_age<16

tab size_chl size if h_chl==1 & max_age<16 & u==1
tab size_chl size if h_chl==0 & max_age<16 & u==1

hist size_chl if h_chl>=0 & u==1 & size<10, by(size h_chl)
*** CRUCIAL HISTOGRAM												<<<< HERE IS A CRUCIAL HISTOGRAM
** not a clear trend for RDP's..

replace sizer1=. if sizer1>=12

g s=1 if sizer1<=4
replace s=2 if sizer1>4 & sizer1<=8
replace s=3 if sizer1>8
replace s=. if sizer1>12
replace s=. if sizer1==.



tab sizer1 h_ch
tab sizer1 h_ch if max_age<16, r

g gpar=(a>65 & a<.)
g par=(a>25 & a<60)
egen gpari=max(gpar), by(hhid)
egen pari=max(par), by(hhid)

g multi=(gpari==1 & pari==1)
tab multi r

duplicates tag hh1 r hhid, g(mt)
g i=1
egen hi=sum(i), by(hhid)

g metric=hi/i



tab multi r if max_age<16

tab multi h_ch if max_age<16

xi: xtreg multi i.rdp_t*i.move i.r if max_age<16, fe robust cluster(hh1)

xi: xtreg multi rdp i.r if max_age<16, fe robust cluster(hh1)

** ** RDP'S KEEP HOUSEHOLDS TOGETHER?


hist rooms, by(u rdp)

hist rooms if rfr1!=1, by(u rdp)

twoway (scatter size rooms if u==1 & rdp==0) || (lfit size rooms if u==1 & rdp==0)

forvalues r=1/3 {
xi: xtreg rooms rdp i.r if s==`r' & u==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg rooms rdp i.r if s==`r' & u==1, fe robust cluster(hh1)
}


forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==1, fe robust cluster(hh1)
}

** by ownership
forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1 & ownr1==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==1 & ownr1==0, fe robust cluster(hh1)
}


** by age
forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1 & ownr1==1 & max_age<16, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==1 & ownr1==0 & max_age<16, fe robust cluster(hh1)
}
** ** Ownership looks important!


** purchase a house?
xi: reg own rooms inc mktv size a edu sex i.r*i.prov if u==1, robust cluster(hh1)

** less likely to own a big house! more people, less likely to own,, why is that?
*** *** how do people decide whether to own or rent?

g infr1id=inf if r==1
egen infr1=max(infr1id), by(pid)
** not exactly driven by informal settlements

* * * Ownership matters a lot! why?
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==1 & a<16, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==2 & a<16, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==3 & a<16, fe robust cluster(hh1)

** WHAT DOES THIS MEAN?
forvalues r=3/8 {
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & sizer1==`r', fe robust cluster(hh1)
}


xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==1 & a<16, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==2 & a<16, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & s==3 & a<16, fe robust cluster(hh1)



* xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & max_age<16, fe robust cluster(hh1)

xi: xtreg sch_per i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg sch_spending i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)

xi: xtreg health_exp i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg public i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg w_alt i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg y_alt i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg non_food i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)



xi: xtreg c_ill i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)

xi: xtreg c_ill i.rdp*i.ownr1 i.r if u==1 & s==1, fe robust cluster(hh1)

xi: xtreg c_health i.rdp*i.ownr1 i.r if u==1 & s==1, fe robust cluster(hh1)


xi: xtreg c_ill i.rdp*i.ownr1 i.r if u==1 & s==2, fe robust cluster(hh1)

xi: xtreg c_ill i.rdp*i.ownr1 i.r if u==1 & s==3, fe robust cluster(hh1)


xi: xtreg c_resp i.rdp*i.ownr1 i.r if u==1 & s==1, fe robust cluster(hh1)


** ** ** **

xi: xtreg absent i.rdp*i.ownr1 i.r if u==1 & s==1, fe robust cluster(hh1)
xi: xtreg absent i.rdp*i.ownr1 i.r if u==1 & s==2, fe robust cluster(hh1)
xi: xtreg absent i.rdp*i.ownr1 i.r if u==1 & s==3, fe robust cluster(hh1)
** no inference!
**** INFORMAL SETTLEMENTS?!?!


xi: xtreg absent i.rdp*i.ownr1 i.r if u==1 & max_age<16, fe robust cluster(hh1)

xi: xtreg c_failed i.rdp*i.ownr1 i.r if u==1 & max_age<16, fe robust cluster(hh1)


xi: xtreg size i.rdp*i.ownr1 i.r if u==1 & max_age<16 & roomsr1==5, fe robust cluster(hh1)
** still holds when controlling for initial rooms

xi: xtreg rooms i.rdp*i.ownr1 i.r if u==1 & max_age<16, fe robust cluster(hh1)

** more housing constrained when renting?? is this the shock for size? build an economic argument?


xi: xtreg inc i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)

xi: xtreg te i.rdp*i.ownr1 i.r if u==1, fe robust cluster(hh1)



** by age and rooms
forvalues r=2/10 {
xi: xtreg size rdp i.r if sizer1==`r' & u==1 & max_age<16, fe robust cluster(hh1)
}




** LOOK AT MOVEMENT!
forvalues r=1/3 {
xi: xtreg move1 rdp_t i.r if s==`r' & u==1, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if s==`r' & u==0, fe robust cluster(hh1)
}


xi: xtreg move1 rdp_t i.r if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if u==0 & sex==0, fe robust cluster(hh1)
** urban men are less likely to move (or is that because ones who want to stay stick around?)
** does the program operate differently between urban and rural areas??
xi: xtreg f_res rdp i.r if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg f_res rdp i.r if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg f_res rdp i.r if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg f_res rdp i.r if u==0 & sex==0, fe robust cluster(hh1)
** very uncorrelated

xi: xtreg m_res rdp i.r if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg m_res rdp i.r if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg m_res rdp i.r if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg m_res rdp i.r if u==0 & sex==0, fe robust cluster(hh1)


forvalues r=1/3 {
xi: xtreg move1 rdp_t i.r if s==`r' & u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if s==`r' & u==1 & sex==0, fe robust cluster(hh1)

xi: xtreg move1 rdp_t i.r if s==`r' & u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg move1 rdp_t i.r if s==`r' & u==0 & sex==0, fe robust cluster(hh1)
}








forvalues r=1/3 {
xi: xtreg metric rdp i.r if s==`r' & u==1 & max_move==0 & max_age<16, fe robust cluster(hh1)
xi: xtreg metric rdp i.r if s==`r' & u==0 & max_move==0 & max_age<16, fe robust cluster(hh1)
}




forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & max_move==0 & u==0, fe robust cluster(hh1)
}

forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & max_move1==0 & u==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & max_move1==0 & u==0, fe robust cluster(hh1)
}





forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & ownr1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & ownr1==0 & max_move==0, fe robust cluster(hh1)
}
** ONLY big RURAL households BREAK up! other household's stay together


forvalues r=1/3 {
xi: xtreg multi rdp i.r if s==`r' & u==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg multi rdp i.r if s==`r' & u==0 & max_move==0, fe robust cluster(hh1)
}
** no correlation with multi: what's the margin?

forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1 & max_age<16 & max_move==0, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==0 & max_age<16 & max_move==0, fe robust cluster(hh1)
}
** no results here for children, which is a decent bummer


* get rid of movers from household size

egen sum_move=sum(move), by(hhid)


forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==0, fe robust cluster(hh1)
}

forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==0, fe robust cluster(hh1)
}
* sort of robust to non-movers



hist size if size<=12 & max_move==0, by(u rdp)



forvalues r=2/10 {
xi: xtreg size rdp i.r if sizer1==`r' & u==1, fe robust cluster(hh1)
xi: xtreg size rdp i.r if sizer1==`r' & u==0, fe robust cluster(hh1)
}

forvalues r=2/10 {
xi: xtreg size i.rdp_t*i.move1 i.r if sizer1==`r' & u==1, fe robust cluster(hh1)
xi: xtreg size i.rdp_t*i.move1 i.r if sizer1==`r' & u==0, fe robust cluster(hh1)
}

forvalues r=2/16 {
xi: xtreg size i.rdp_t*i.move1 i.r if sizer1==`r' & u==1 & max_move==0, fe robust cluster(hh1)

forvalues r=1/3 {
xi: xtreg size i.move*i.rdp_t i.r if s==`r', fe robust cluster(hh1)
}


forvalues r=1/3 {
xi: xtreg size rdp i.r if s==`r' & u==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg size rdp i.r if s==`r' & u==0 & max_move==0, fe robust cluster(hh1)
}
** unaffected by movers or not, then look at splitting  ??? ??? ??? ??? ???


forvalues r=1/3 {
xi: xtreg child_alt rdp i.r*i.prov if s==`r' & u==1, fe robust cluster(hh1)
xi: xtreg child_alt rdp i.r*i.prov if s==`r' & u==0, fe robust cluster(hh1)
}




forvalues r=2/10 {
xi: xtreg size rdpdo i.r if sizer1==`r', fe robust cluster(hh1)
}


tab rdp rdp_t, mis


forvalues r=2/10 {
xi: xtreg size rdpd i.r if sizer1==`r', fe robust cluster(hh1)
}


forvalues r=2/10 {
xi: xtreg rooms rdp i.r if sizer1==`r', fe robust cluster(hh1)
}

forvalues r=2/10 {
xi: xtreg mktv rdp i.r if sizer1==`r', fe robust cluster(hh1)
}



** shared members or no?







g rdp_f_own=rdp*f_own
g rdp_m_own=rdp*m_own

xi: xtreg f_res rdp_f_own rdp_m_own i.r if max_age<16 & opid!=. & mdb=="ETH", fe cluster(hh1) robust

xi: xtreg absent rdp_f_own rdp_m_own i.r if max_age<16 & opid!=. & mdb=="ETH", fe cluster(hh1) robust

xi: xtreg m_res rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust

** What is the difference here?? **

xi: xtreg absent rdp f_own m_own rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg absent_i rdp f_own m_own  rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust

xi: xtreg absent rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg absent_i rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust

xi: xtreg sch_q rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg sch_d rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust

xi: xtreg mktv rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust
* men get greater value and bigger rooms! but decline in attendance?
xi: xtreg piped rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg rooms rdp_f_own rdp_m_own i.r if max_age<16 & opid!=., fe cluster(hh1) robust


g rdp_ownfom=(rdp==1 & (ownf==1 | ownm==1))


** ALSO: LOOK AT WHERE CHANGES IN DECISIONS ABOUT WHERE KID GOES TO SCHOOL
replace a_decschpid=. if a_decschpid<100
egen dec=max(a_decschpid), by(hhid)


g f_sch=dec==c_fthhh_pid
replace f_sch=. if c_fthhh_pid==. 

g m_sch=dec==c_mthhh_pid
replace m_sch=. if c_mthhh_pid==.


tab f_sch if max_age<16
tab m_sch if max_age<16




tab rdp_op if max_age<16
tab rdp_np if max_age<16




 xi: xtreg absent rdp_op rdp_np i.r if max_age<16, fe cluster(hh1) robust
 xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16, fe cluster(hh1) robust

 xi: xtreg absent_d rdp_op rdp_np i.r if max_age<16, fe cluster(hh1) robust
 xi: xtreg c_failed rdp_op rdp_np i.r if max_age<16, fe cluster(hh1) robust

* xi: xtreg absent rdp_op rdp_np i.r if max_age<16 & opid!=., fe cluster(hh1) robust
* xi: xtreg absent_i rdp_op rdp_np i.r if max_age<16 & opid!=., fe cluster(hh1) robust
* xi: xtreg c_failed rdp_op rdp_np i.r if max_age<16 & opid!=., fe cluster(hh1) robust


* TO WHAT EXTENT ARE HEAD OF HOUSEHOLD STATUS AND OWNERSHIP PERFECTLY CORRELATED
** HOH AND OWNERSHIP **




g hoh_own=(own==1 & relhh==1)

tab own hoh_own if max_age>16, r

** NOT A PERFECT CORRELATION, ABOUT 75%!

** who own's a house but is not hoh?
tab r_relhead own if max_age>16
* mostly husband/wife/partner
*** what if it's a husband wife thing???

** EXPLORE HUSBAND WIFE THING

g ownf=(opid==c_fthhh_pid)
g ownm=(opid==c_mthhh_pid)
** FIX THIS
replace ownf=. if opid==.
replace ownm=. if opid==.

tab ownf rdp if max_age<16 , mis
tab ownm rdp if max_age<16 , mis

tab ownf ownm if rdp==1 & max_age<16 & opid!=.

** pretty small variation when looking at primary owners


xi: xtreg f_sch rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust

xi: xtreg f_sch rdp  i.r if max_age<16 & opid!=., fe cluster(hh1) robust

xi: xtreg m_sch rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust



*  xi: xtreg absent_i rdp rdp_ownfom i.r if max_age<16, fe cluster(hh1) robust
*  xi: xtreg absent rdp rdp_ownfom i.r if max_age<16, fe cluster(hh1) robust


xi: xtreg absent_i rdp rdp_ownf rdp_ownm i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent rdp rdp_ownf rdp_ownm i.r if max_age<16, fe cluster(hh1) robust


xi: xtreg absent_i rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg absent rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust


xi: xtreg absent_i rdp rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg absent rdp rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust
xi: xtreg absent_d rdp rdp_ownf rdp_ownm i.r if max_age<16 & opid!=., fe cluster(hh1) robust


** ** **

xi: xtreg absent rdp rdp_ownf i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent_i rdp rdp_ownf i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent rdp rdp_ownm i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent_i rdp rdp_ownm i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent rdp rdp_ownfm i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent_i rdp rdp_ownfm i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent rdp rdp_ownfom i.r if max_age<16, fe cluster(hh1) robust
xi: xtreg absent_i rdp rdp_ownfom i.r if max_age<16, fe cluster(hh1) robust

** ** ** interact with initial hoh_status ?

** why doesn't this work?
xi: xtreg absent_i i.rdp*i.ownf i.rdp*i.ownm i.r if max_age<16, fe cluster(hh1) robust

xi: xtreg absent rdp_ph rdp_gh i.r if max_age<16, fe cluster(hh1) robust



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

tab p_hoh rdp if max_age<16
tab relhh rdp if max_age<16
* no clear pattern here unfortunately: in fact, it looks like there's less movement for RDP's

g sp_dec=(c_mthhh_pid

sort pid r
by pid: g p_hoh_ch=p_hoh[_n]-p_hoh[_n-1]
by pid: g g_hoh_ch=g_hoh[_n]-g_hoh[_n-1]

tab rdp p_hoh_ch, r
tab rdp g_hoh_ch, r

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


quietly xi: xtreg absent rdp_op rdp_np i.r if max_age<16, fe cluster(hh1) robust
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

label variable absent "Absent (Days/Month)"
label variable absent_i "Absent (Days over 1)"
label variable absent_d "Absent Dummy"
label variable c_failed "Failed Grade"

label variable rdp_op "Parent Owns RDP"
label variable rdp_np "Other Family Owns RDP"


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




