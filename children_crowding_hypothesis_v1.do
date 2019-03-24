

cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<15000

keep if tt!=.

egen rooms_max=max(rooms), by(hhid)

drop rooms
rename rooms_max rooms

keep if a<18

xtset pid

egen max_a=max(a), by(pid)

* absent, check_up, height, weight, repeat, c_resp, c_failed
* c_edu1, c_ill_ser, c_doc

*** now look at child outcomes

egen m=group(gc_mdbdc2011)
egen m1=group(hhmdbdc2011)
replace m=m1 if m==.

replace rooms=. if rooms>6

g inf1r=inf if r==1
egen infr=max(inf1r), by(pid)
g dwell1r=dwell if r==1
egen dwellr=max(dwell1r), by(pid)
g rooms1r=rooms if r==1
egen roomsr=max(rooms1r), by(pid)

g size_r=size/rooms

g children_r=children/rooms

*%*%* only compare rdp to non-rdp
*gen rdpr1=rdp if r==1
*egen rdpr1m=max(rdpr1), by(pid)
*drop if rdpr1m==1

g roomsr1id=rooms if r==1
egen roomsr1=max(roomsr1id), by(pid)

*hist rooms, by(rdp)
*** NOW TRY HEALTH OUTCOMES!!

** CROWDING: does RDP relieve crowding?, especially for small room houses


g small=roomsr1<4
g big=roomsr1>=4

g rdp__small=rdp*small
g rdp__big=rdp*big


xi: xtreg parent rdp i.r*i.prov, fe robust cluster(hh1)
xi: xtreg grandparent rdp i.r*i.prov, fe robust cluster(hh1)

xi: xtreg parent rdp__* i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg parent rdp__* i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg c_ill rdp__* i.r*i.m if u==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp__* i.r*i.m if u==0, fe robust cluster(hh1)
** big houses benefitted: why?

xi: xtreg c_ill rdp i.r*i.prov if u==0, fe robust cluster(hh1)


xi: xtreg c_ill rdp i.r*i.prov if u==0, fe robust cluster(hh1)






xi: xtreg c_health i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)


forvalues z=1/6 {
xi: xtreg c_ill rdp i.r*i.prov if rooms==`z', fe robust cluster(hh1)
}

xi: xtreg c_ill i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_ill i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)


xi: xtreg weight i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg weight i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg weight i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
*** maybe something here!!

xi: xtreg c_resp i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_resp i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_resp i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg c_failed i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_failed i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_failed i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

** failed action is driven by urban areas, doesn't look like a rooms story?

xi: xtreg c_edu1 i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_edu1 i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_edu1 i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
** maybe room 2 does worse?  how to interpret??


foreach var of varlist c_att absent c_doc c_failed c_ill {
xi: xtreg `var' i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
}







foreach var of varlist absent c_failed check_up c_resp height weight  c_edu1 c_ill_ser c_health check_up c_ill {
xi: xtreg `var' i.rdp*i.roomsr inc i.r*i.m if u==1 & r!=3, fe robust cluster(hh1)
}


xi: xtivreg c_ill i.r*i.prov ( size_r = rdp i.r*i.prov) if u==1, fe

xi: xtivreg c_ill i.r*i.prov ( size_r = rdp i.r*i.prov) if u==0, fe


xi: xtivreg c_ill i.r*i.prov ( rooms = rdp i.r*i.prov) if u==1, fe

xi: xtivreg c_ill i.r*i.prov ( rooms = rdp i.r*i.prov) if u==0, fe


xi: xtivreg c_ill i.r*i.prov ( size = rdp i.r*i.prov) if u==1, fe

xi: xtivreg c_ill i.r*i.prov ( size = rdp i.r*i.prov) if u==0, fe


xi: xtivreg weight i.r*i.prov ( size_r = rdp i.r*i.prov) if u==1, fe

xi: xtivreg weight i.r*i.prov ( size_r = rdp i.r*i.prov) if u==0, fe



xi: xtivreg c_ill i.r*i.prov ( inf = rdp i.r*i.prov) if u==1, fe

xi: xtivreg c_ill i.r*i.prov ( inf = rdp i.r*i.prov) if u==0, fe



xi: xtreg c_ill rooms i.r*i.prov if u==1, fe robust cluster(hh1)

xi: xtreg c_ill size i.r*i.prov, fe robust cluster(hh1)

xi: xtreg rooms rdp i.r*i.prov, fe robust cluster(hh1)

xi: xtreg size rdp i.r*i.prov, fe robust cluster(hh1)




foreach var of varlist c_ill {
xi: xtreg `var' rdp i.r*i.prov if u==0 & r!=3 & roomsr>3, fe robust cluster(hh1)
xi: xtreg `var' rdp i.r*i.prov if u==0 & r!=3 & roomsr<=3, fe robust cluster(hh1)
xi: xtreg `var' rdp i.r*i.prov if u==1 & r!=3 & roomsr>3, fe robust cluster(hh1)
xi: xtreg `var' rdp i.r*i.prov if u==1 & r!=3 & roomsr<=3, fe robust cluster(hh1)
}



foreach var of varlist c_ill {
forvalues z=1/6 {
xi: xtreg `var' rdp inc i.r i.prov if u==0 & r!=3 & roomsr==`z', fe robust cluster(hh1)
}
}



foreach var of varlist c_edu1 c_ill_ser c_doc c_health check_up c_ill {
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==0, fe robust cluster(hh1)
}


foreach var of varlist c_edu1 c_ill_ser c_doc c_health check_up c_ill {
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==0, fe robust cluster(hh1)
}



** weight goes up in urban areas!? respiratory illness goes up!!?

**** might be something with failed also
foreach var of varlist absent c_failed check_up c_resp height weight {
xi: xtreg `var' rdp a i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg `var' rdp a i.r*i.prov if u==0, fe robust cluster(hh1)
}





foreach var of varlist c_* {
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg `var' rdp i.dwell i.r*i.prov if u==0, fe robust cluster(hh1)
}

foreach var of varlist c_ill {
xi: xtreg `var' rdp i.dwell piped elec roof_cor walls_b i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg `var' rdp  i.dwell piped elec roof_cor walls_b i.r*i.prov if u==0, fe robust cluster(hh1)
}
* even stronger when controlling for attributes
** illness results get stronger when controlling for dwelling type

** try education outcomes for school age kids:

foreach var of varlist c_att c_failed c_edu1 {
xi: xtreg `var' rdp  i.r*i.prov if u==1 & max_a>7 & max_a<14, fe robust cluster(hh1)
xi: xtreg `var' rdp  i.r*i.prov if u==0 & max_a>7 & max_a<14, fe robust cluster(hh1)
}

** need a bunch more outcomes for this to fly well:
*** or start zooming in on stuff?


** health outcomes improve, can I do more with that?

*** NOW: Zoom in on stuff

** FIRST CONTROL FOR ROOMS
foreach var of varlist weight c_resp c_ill c_failed c_doc  {
xi: xtreg `var' rdp i.dwell i.rooms piped elec roof_cor walls_b i.r*i.prov if u==1 & max_a>5 & max_a<18, fe robust cluster(hh1)
xi: xtreg `var' rdp  i.dwell i.rooms piped elec roof_cor walls_b i.r*i.prov if u==0 & max_a>5 & max_a<18, fe robust cluster(hh1)
}

** NOW CONTROL FOR A TON OF DEMOGRAPHICS
foreach var of varlist weight c_resp c_ill c_failed  {
xi: xtreg `var' rdp a size inc children i.dwell rooms piped elec roof_cor walls_b i.r*i.prov if u==1 & max_a>5 & max_a<18, fe robust cluster(hh1)
xi: xtreg `var' rdp a i.dwell i.rooms piped elec roof_cor walls_b i.r*i.prov if u==1 & max_a>5 & max_a<18, fe robust cluster(hh1)

xi: xtreg `var' rdp a size inc children i.dwell rooms piped elec roof_cor walls_b i.r*i.prov if u==0 & max_a>5 & max_a<18, fe robust cluster(hh1)
xi: xtreg `var' rdp a  i.dwell i.rooms piped elec roof_cor walls_b i.r*i.prov if u==0 & max_a>5 & max_a<18, fe robust cluster(hh1)
}
** Can I get rid of the correlations?
** failed is not worth it
** illness is robust to controls
** respiratory is robust to controls surprisingly..

** weight is also robust to the controls

**** can I find a change in food consumption in urban areas?


*** are parent's more likely to be co-resident?

