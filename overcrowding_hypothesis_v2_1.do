
cd "/Users/willviolette/Desktop/pstc_work/nids"

use och.dta, clear

** condition on ownership, type of house

g f_per=fexp_imp/size

g dwell_r1_id=dwell if r==1
egen dwellr1=max(dwell_r1_id), by(pid)

g own_r1_id=own if r==1
egen ownr1=max(own_r1_id), by(pid)

g inf_r1_id=inf if r==1
egen infr1=max(inf_r1_id), by(pid)

g size_r1_id=size if r==1
egen sizer1=max(size_r1_id), by(pid)

replace adult=. if adult<=0

*** WHAT HAPPENS TO SIZE
g c_s=children/size

* xtset hh1
* xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
* xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
** WHAT HAPPENS TO EMPLOYMENT FOR THOSE THAT JOIN THE HH?

xtset pid
xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg adult i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)


xi: xtreg c_s i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_s i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg children i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)


** TEST FOOD HYPOTHESIS IN RURAL AND URBAN AREAS!!
xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg f_per i.rdp*i.roomsr1 exp_imp i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg f_per i.rdp*i.roomsr1 exp_imp i.r*i.prov if u==0, fe robust cluster(hh1)



xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1==1, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1!=1, fe robust cluster(hh1)
* holds strongest for house dwellings

reg size i.roomsr1 i.prov if r==1 & u==1, robust cluster(hh1)
reg children i.roomsr1 i.prov if r==1 & u==1, robust cluster(hh1)
reg child_out i.roomsr1 i.prov if r==1 & u==1, robust cluster(hh1)

g inc_2=inc*inc

xi: reg rent i.rooms i.size inc inc_2 i.dwell i.piped i.roof_cor i.walls_b i.prov*i.r i.prov*i.u, robust cluster(hh1)


xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1==1, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1!=1, fe robust cluster(hh1)


xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1==1, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1!=1, fe robust cluster(hh1)


** FOOD SHARE STORY WORKS: HOUSEHOLDS THAT INCREASE KIDS BUY MORE FOOD
*** HOUSEHOLDS THAT INCREASE ADULTS BUY LESS FOOD AND MORE PUBLIC GOODS
xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg f_per i.rdp*i.roomsr1 exp_imp i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg f_per i.rdp*i.roomsr1 exp_imp i.r*i.prov if u==0, fe robust cluster(hh1)



xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1==1, fe robust cluster(hh1)
xi: xtreg food_share i.rdp*i.roomsr1 i.r*i.prov if u==1 & dwellr1!=1, fe robust cluster(hh1)







xi: xtreg size i.rdp*i.sizer1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.sizer1 i.r*i.prov if u==0, fe robust cluster(hh1)
** they all kind of increase but then they decline for large families









