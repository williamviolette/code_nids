
* employment channels

cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<15000
* keep if sr==321

egen kids_health=mean(c_health), by(hhid)

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
*keep if mktv==.

g own_r1=(own==0 & r==1)
egen om1=max(own_r1), by(pid)

*egen sumr=sum(r), by(pid)
*keep if sumr==6

sort pid r
by pid: g rdp3=rdp[_n]-rdp[_n-1]
egen minrdp3=min(rdp3), by(pid)
drop if minrdp3==-1

egen max_move=max(move), by(pid)

** look at mktv variables
g mktv_rdp=mktv*rdp
g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

g rdp_mktv=rdp*mktv

replace rooms=. if rooms>20
replace rooms=. if rooms==0
replace rooms=. if rooms<0

g size_r=size/rooms
g children_r=children/rooms

save och.dta, replace


*** WORK HARD ON FIRST STAGE ***

use och.dta, clear

*%*%* only compare rdp to non-rdp
gen rdpr1=rdp if r==1
egen rdpr1m=max(rdpr1), by(pid)
drop if rdpr1m==1
*tab rdp r

g child_out_d=(child_out>0 & child_out!=.)

*%*%* define initial number of rooms 

replace rooms=. if rooms>6

g roomsr1id=rooms if r==1
egen roomsr1=max(roomsr1id), by(pid)

replace children_r=.  if children_r>3

g children_per=size/children
replace children_per=. if children_per>8


xi: xtreg child_out_d i.rdp i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg child_out_d i.rdp i.r*i.prov if u==0, fe robust cluster(hh1)
xi: xtreg child_out_d i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
** kinda strange results

xi: xtreg child_out i.rdp i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg child_out i.rdp i.r*i.prov if u==0, fe robust cluster(hh1)
xi: xtreg child_out i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

forvalues z=1/6 {
xi: xtreg rooms rdp i.r*i.prov if roomsr1==`z', fe robust cluster(hh1)
}

xi: xtreg rooms i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
** this looks good, rooms have a big effect for small houses, then increasingly less effect
** until actually negative for large houses

hist rooms, by(rdp)
* does this relationship change when go from urban to rural?
xi: xtreg rooms i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg rooms i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
* holds in both urban and rural settings


*%*%* NOW TRY A REDUCED FORM: HOUSEHOLD SIZE

forvalues z=1/6 {
xi: xtreg size rdp i.r*i.prov if roomsr1==`z', fe robust cluster(hh1)
}

xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
*** every household increased in size, not super clear what this captures anyways

** how does this vary between urban and rural
xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
** these are good! size is initially significant, then dies out in size and significance


*%*%* NOW TRY A REDUCED FORM: NUMBER OF CHILDREN

forvalues z=1/6 {
xi: xtreg children rdp i.r*i.prov if roomsr1==`z', fe robust cluster(hh1)
}

xi: xtreg children i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
*** smallest household increased in children, greater rooms don't matter much

** how does this vary between urban and rural
xi: xtreg children i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
** these are pretty good, size is initially significant, then dies out in size and significance


xi: xtreg children_r i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children_r i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)
** these guys save money and are able to spend it on their kids?!
** ** ** saving on rent??

xi: xtreg children_per i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children_per i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)


*** DOES RDP REDUCE CROWDING?


forvalues z=1/6 {
xi: xtreg size_r rdp i.r*i.prov if roomsr1==`z', fe robust cluster(hh1)
}

xi: xtreg size_r i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

xi: xtreg size_r i.rdp*i.roomsr1 i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size_r i.rdp*i.roomsr1 i.r*i.prov if u==0, fe robust cluster(hh1)

** crowding effects are driven by urban areas


** NOW PLAY AROUND WITH A COUPLE OUTCOMES

** ECONOMIC OUTCOMES
 
 *** EMPLOYMENT ***
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
*** YES SMALL ROOMS WORK LESS: MIGRANTS?
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg e i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)

 *** UNEMPLOYMENT ***
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
*** YES SMALL ROOMS WORK LESS: MIGRANTS?
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg ue i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)

 *** INCOME ***
xi: xtreg inc i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg inc i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg inc i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg inc i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg inc i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)
*** large size gain corresponds to less income, especially for urban men

drop inc_per
g inc_per=inc/size

 *** INC PER ***
xi: xtreg inc_per i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)
xi: xtreg inc_per i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg inc_per i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)
xi: xtreg inc_per i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg inc_per i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)
*** not much going on, target income hypothesis thing?




** HEALTH OUTCOMES

 *** HEALTH ***
xi: xtreg health i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

xi: xtreg health i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg health i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)

xi: xtreg health i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
*** YES WAY HEALTHIER
xi: xtreg health i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)

 *** HEALTH VISIT ***
xi: xtreg health_visit i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

xi: xtreg health_visit i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg health_visit i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)

xi: xtreg health_visit i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg health_visit i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)
*** nothing

 *** HEALTH INS ***
xi: xtreg health_ins i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

xi: xtreg health_ins i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg health_ins i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)

xi: xtreg health_ins i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg health_ins i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)
*** nothing

 *** KIDS HEALTH ***
xi: xtreg kids_health i.rdp*i.roomsr1 i.r*i.prov, fe robust cluster(hh1)

xi: xtreg kids_health i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==1, fe robust cluster(hh1)
xi: xtreg kids_health i.rdp*i.roomsr1 i.r*i.prov if u==1 & sex==0, fe robust cluster(hh1)

xi: xtreg kids_health i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==1, fe robust cluster(hh1)
xi: xtreg kids_health i.rdp*i.roomsr1 i.r*i.prov if u==0 & sex==0, fe robust cluster(hh1)
** Pronounced in rural areas! LESS CROWDING IS GOOD. IS THAT BECAUSE OF SORTING?


** HEALTH OUTCOMES
foreach var of varlist health health_visit health_ins {
xi: xtreg `var' i.rdp*i.roomsr1 i.r if u==1, fe robust cluster(hh1)
xi: xtreg `var' i.rdp*i.roomsr1 i.r if u==0, fe robust cluster(hh1)
}

** MAYBE SOMETHING GOING ON WITH HEALTH but the other ones are too noisy




use och, clear


foreach var of varlist health health_visit health_ins kids_health {
   xi: xtreg `var' rdp i.r*i.prov if u==1, fe robust cluster(hh1)
   xi: xtreg `var' rdp i.r*i.prov if u==0, fe robust cluster(hh1)
}

** in rural areas, more likely to buy health insurance



* xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==1 & rooms<10, fe robust cluster(hh1)
* xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==0 & rooms<10, fe robust cluster(hh1)

* xi: xtreg rooms rdp  i.r*i.prov if u==1, fe robust cluster(hh1)
* xi: xtreg rooms rdp  i.r*i.prov if u==0, fe robust cluster(hh1)

*hist size, by(h_ch u)
*hist size_r if size_r<5, by(h_ch u)
*replace size_r=. if size_r>2

*** CRUCIAL CONSTRAINT IS HERE
egen max_size_r=max(size_r), by(pid)
drop if max_size_r>4

replace children_r=. if children_r>2
g c_dum=(children>0)
g children_ratio=children/size
replace children_ratio=. if children_ratio>2
g size_r1_1=size if r==1
egen size_r1=max(size_r1_1), by(pid)
g hha_1=a if relhh==1 & r==1
egen hha=max(hha_1), by(pid)
g space_constrained_1=size/rooms if r==1
egen space_constrained=max(space_constrained_1), by(pid)

g size_r_1=size if r==1
egen max_size_r1=max(size_r_1), by(pid)

g inc_2=inc*inc

** how is size ratio correlated to income? is S a normal good? test with pensions?
xi: reg size_r inc inf house piped elec a edu  i.r*i.prov i.r*i.u, robust cluster(cluster)
xi: reg rooms inc inc_2 inf house piped elec roof_cor walls_b a edu size children e i.r*i.prov i.r*i.u, robust cluster(cluster)
** looks pretty damn normal to me!

*** OVERALL : SIZE
xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==1, fe robust cluster(hh1)
* rooms increase
xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==0, fe robust cluster(hh1)
* rooms kind of increase

xi: xtreg size rdp inf house piped elec i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size rdp inf house piped elec i.r*i.prov if u==0, fe robust cluster(hh1)
** size increases though

xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==1, fe robust cluster(hh1)
* increase in rooms are filled so nothing really
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==0, fe robust cluster(hh1)
* similar pattern here but weaker
** not much going on: overall size ratio's dont change

*** OVERALL : CHILDREN COMPOSITION

xi: xtreg children rdp i.dwell piped elec i.r*i.prov if u==1, fe robust cluster(hh1)
** positive
xi: xtreg children rdp i.dwell piped elec i.r*i.prov if u==0, fe robust cluster(hh1)
** pisitive and bigger

xi: xtreg children_ratio rdp i.dwell piped elec i.r*i.prov if u==1, fe robust cluster(hh1)
* children ratio doesn't change much
xi: xtreg children_ratio rdp i.dwell piped elec i.r*i.prov if u==0, fe robust cluster(hh1)
* children ratio increases

** what is happening in rural areas, better access to services or pure family structure thing?
** ** ** FIND WHAT IS DRIVING CHILDREN'S IMPACTS  !!!

** can we show that children are going to live with migrants in urban areas?
*** FIRST: define a migrant: one with small initial household size is one way

xi: xtreg children rdp inf house piped elec i.r*i.prov if u==1 & size_r1<=3, fe robust cluster(hh1)
xi: xtreg children rdp inf house piped elec i.r*i.prov if u==1 & size_r1>3, fe robust cluster(hh1)
xi: xtreg children_ratio rdp inf house piped elec i.r*i.prov if u==1 & size_r1<=3, fe robust cluster(hh1)
xi: xtreg children_ratio rdp inf house piped elec i.r*i.prov if u==1 & size_r1>3, fe robust cluster(hh1)
** nothing! migrant story is out

xi: xtreg children rdp inf house piped elec i.r*i.prov if u==0 & size_r1<=3, fe robust cluster(hh1)
xi: xtreg children rdp inf house piped elec i.r*i.prov if u==0 & size_r1>3, fe robust cluster(hh1)
xi: xtreg children_ratio rdp inf house piped elec i.r*i.prov if u==0 & size_r1<=3, fe robust cluster(hh1)
xi: xtreg children_ratio rdp inf house piped elec i.r*i.prov if u==0 & size_r1>3, fe robust cluster(hh1)
** even in rural areas, its a story of big household's getting bigger

xi: xtreg children i.rdp*i.size_r1 inf house piped elec i.r*i.prov if u==1 & size<=8, fe robust cluster(hh1)
xi: xtreg children i.rdp*i.size_r1 inf house piped elec i.r*i.prov if u==0 & size<=8, fe robust cluster(hh1)

xi: xtreg children_ratio i.rdp*i.size_r1 inf house piped elec i.r*i.prov if u==1 & size<=8, fe robust cluster(hh1)
xi: xtreg children_ratio i.rdp*i.size_r1 inf house piped elec i.r*i.prov if u==0 & size<=8, fe robust cluster(hh1)
** big households get bigger in rural areas while small households seem to work well in urban areas






** INITIALLY LESS CROWDED:
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1<2, fe robust cluster(hh1)
* nothing, maybe negative
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1<2, fe robust cluster(hh1)
***  big reduction in size ratio when get RDP which makes sense
***  not a lot of new people move in (because opportunities are worse?)

xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1<2, fe robust cluster(hh1)
* not a huge change in rooms
xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1<2, fe robust cluster(hh1)
* pretty decent increase in rooms (kinda consistent)

xi: xtreg size rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1<2, fe robust cluster(hh1)
* nothing
xi: xtreg size rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1<2, fe robust cluster(hh1)
* nothing (maybe negative, but not)
*** basically in unconstrained places, we don't see a lot of response

** INITIALLY MORE CROWDED
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1>=2, fe robust cluster(hh1)
* no change, initially more crowded don't get worse
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1>=2, fe robust cluster(hh1)
* rural areas don't get larger size ratios

xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1>=2, fe robust cluster(hh1)
* big boost to rooms!
xi: xtreg rooms rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1>=2, fe robust cluster(hh1)
* no change to rooms ( why is that? )

xi: xtreg size rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1>=2, fe robust cluster(hh1)
* big boost to size! crowded places get way more crowded!!
xi: xtreg size rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1>=2, fe robust cluster(hh1)
* also a big boost to size, why is that?

** ** ** REPATE THIS ANALYSIS FOR CHILDREN

** OVERALL : CHILDREN???


** INITIALLY LESS CROWDED:
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1<2, fe robust cluster(hh1)
* nothing, maybe negative
xi: xtreg size_r rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1<2, fe robust cluster(hh1)
***  big reduction in size ratio when get RDP which makes sense
***  not a lot of new people move in (because opportunities are worse?)

xi: xtreg size rdp inf house piped elec i.r*i.prov if u==1 & max_size_r1<2, fe robust cluster(hh1)
* nothing
xi: xtreg size rdp inf house piped elec i.r*i.prov if u==0 & max_size_r1<2, fe robust cluster(hh1)
* nothing (maybe negative, but not)
*** basically in unconstrained places, we don't see a lot of response




xi: xtreg size_r rdp i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg size_r rdp i.r*i.prov if u==0, fe robust cluster(hh1)
** AMOUNT OF PEOPLE PER ROOMS INCREASES IN URBAN AREAS



xi: xtreg c_dum rdp inf house piped  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_dum rdp inf house piped  i.r*i.prov if u==0, fe robust cluster(hh1)
* strong in both areas, more likely to have any kid present, that's pretty convincing
** OOOO, child ratio doesn't change because mothers migrate with kids!

xi: xtreg children_r rdp inf house piped  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children_r rdp inf house piped  i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg children_ratio rdp inf house piped  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children_ratio rdp inf house piped  i.r*i.prov if u==0, fe robust cluster(hh1)
* in rural areas, children ratio goes up a lot!: some change in urban areas
* but not too much

*&*  






** they pile in more in urban areas, that's good news!

g children_ratio=children/size

g rdp_rooms=rdp*rooms

replace rooms=. if rooms>5

xtset pid

xi: xtivreg children i.r*i.prov (rooms = rdp i.r*i.prov) if u==1, fe

xi: xtivreg children i.r*i.prov (rooms = rdp i.r*i.prov) if u==0, fe

xi: xtivreg size i.r*i.prov (rooms = rdp i.r*i.prov), fe


xi: xtivreg size i.r*i.prov inf house piped (rooms = rdp i.r*i.prov inf house piped ), fe

xi: xtivreg children i.r*i.prov inf house piped u (rooms = rdp i.r*i.prov inf house piped u ), fe

xi: xtivreg children_ratio i.r*i.prov inf house piped u (rooms = rdp i.r*i.prov inf house piped u ), fe

xi: xtivreg children_ratio i.r*i.prov inf house piped (rooms = rdp i.r*i.prov inf house piped) if u==0, fe


xi: xtivreg size_r i.r*i.prov inf house piped (room = rdp i.r*i.prov inf house piped) if u==0, fe

xi: xtivreg children_ratio i.r*i.prov (rooms = rdp i.r*i.prov), fe

xi: xtreg children rdp rooms rdp_rooms i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp rooms rdp_rooms i.r*i.prov, fe robust cluster(hh1)


****

use och, clear

g children_ratio=children/size
drop if children_ratio==.

egen sumr1=sum(r), by(pid)
keep if sumr1==6
sort pid r
by pid: g rdp2=rdp[_n]-rdp[_n-1]
egen minrdp2=min(rdp2), by (pid)
drop if minrdp2==-1

replace rooms=. if rooms>5

g size_r1_1=size if r==1
egen size_r1=max(size_r1_1), by(pid)

g hha_1=a if relhh==1 & r==1
egen hha=max(hha_1), by(pid)


xi: xtreg children rdp i.r*i.prov if size_r1<4 & u==1, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if size_r1<4 & u==0, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if size_r1>=4 & u==1, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if size_r1>=4 & u==0, fe robust cluster(hh1)


xi: xtreg children_ratio rdp i.r*i.prov if size_r1<4 & u==1, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.r*i.prov if size_r1<4 & u==0, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.r*i.prov if size_r1>=4 & u==1, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.r*i.prov if size_r1>=4 & u==0, fe robust cluster(hh1)
** big families in rural areas, otherwise nothin

** to what extent is family structure strategic?  We've given households an
* opportunity to move to a new place, gotten rid of any transaction costs
* when do they move family members and which ones do they move?



xi: xtreg children rdp i.r*i.prov if hha<40 & u==1 , fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if hha<40 & u==0, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if hha>=40 & u==1, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if hha>=40 & u==0, fe robust cluster(hh1)
* again, biggest effects in rural areas

****

use och, clear

g children_ratio=children/size

replace rooms=. if rooms>5

g size_r1_1=size if r==1
egen size_r1=max(size_r1_1), by(pid)
g hha_1=a if relhh==1 & r==1
egen hha=max(hha_1), by(pid)

g space_constrained_1=size/rooms if r==1

egen space_constrained=max(space_constrained_1), by(pid)




xi: xtreg children rdp size i.r*i.prov if space_constrained<1, fe robust cluster(hh1)

xi: xtreg children rdp size i.r*i.prov if space_constrained>=1, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.r*i.prov if space_constrained<1, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.r*i.prov if space_constrained>1, fe robust cluster(hh1)




xi: xtreg size rdp i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp i.rooms i.r*i.prov, fe robust cluster(hh1)

xi: xtreg size rdp i.rooms i.r*i.prov, fe robust cluster(hh1)


xi: xtreg size_r rdp i.rooms i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children_r rdp i.rooms i.r*i.prov, fe robust cluster(hh1)


** Where is this demographic shift more pronounced?
xi: xtreg children_ratio rdp i.rooms i.r*i.prov if u==1, fe robust cluster(hh1)

xi: xtreg children_ratio rdp i.rooms i.r*i.prov if u==0, fe robust cluster(hh1)



xi: xtreg children_ratio rdp i.r house inf flush piped house roof_cor walls_b i.r*i.prov if a<30, fe robust



xi: xtreg size_r rdp i.r house inf flush piped house roof_cor walls_b i.r*i.prov, fe robust
** increases household density!!
xi: xtreg size_r rdp rooms i.r house inf flush piped house roof_cor walls_b i.r*i.prov, fe robust

xi: xtreg size_r rdp rooms i.r house inf flush piped house roof_cor walls_b i.r*i.prov if rooms<10, fe robust








xi: reg size_r rdp pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b inf  u i.r*i.prov, cluster(hh1) robust


use och, clear

keep if house==1 | inf==1
keep if rooms<10

collapse size_r children_r, by(u rooms inf)

twoway scatter size_r rooms if inf==1 & u==1 || scatter size_r rooms if inf==0 & u==1

twoway scatter children_r rooms if inf==1 & u==1 || scatter children_r rooms if inf==0 & u==1


* what the heck is my rooms measure capturing, if anything at all?

use och, clear

keep if rooms<10

collapse size_r children_r, by(u rooms rdp)

twoway scatter size_r rooms if rdp==1 & u==1 || scatter size_r rooms if rdp==0 & u==1 || scatter size_r rooms if rdp==1 & u==0 || scatter size_r rooms if rdp==0 & u==0





use och, clear

replace h_ch=0 if rdp==0

hist mktv, by(rdp)
hist mktv, by(rdp h_ch)

keep if house==1 | inf==1
keep if rooms<10

egen c_mktv=count(mktv), by(mktv)
keep if c_mktv>100

collapse size_r children_r, by(u mktv)

twoway scatter size_r mktv if u==1 || scatter size_r mktv if  u==0

* not obvious that urban areas are more dense?
twoway scatter children_r mktv if u==1 || scatter children_r mktv if  u==0






** LOOK BY COMMUTING TIMES
g long_commute=(rdp_commute>2.07)

**** COMMUTE DEVIATIONS ****
g commute_dev_id=rdp_commute-commute

g commute_dev=(commute_dev_id>.1)

tab prov commute_dev

** COMMUTING HETEROGENEITY **

xi: xtreg children rdp left_in  left_out i.r*i.prov if long_commute==1 & u==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if long_commute==0 & u==1, fe robust cluster(hh1)

xi: xtreg children rdp left_in  left_out i.r*i.prov if commute_dev==1 & u==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if commute_dev==0 & u==1, fe robust cluster(hh1)

** not consistent with a story about commuting costs



xi: xtreg children rdp left_in  left_out travel i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp left_in  left_out mktv own paid_off i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp left_in  left_out i.r*i.prov if max_move==0, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if max_move==1, fe robust cluster(hh1)

xi: xtreg children rdp left_in  left_out i.r*i.prov if max_move==1, fe robust cluster(hh1)


xi: xtreg children rdp left_in left_out own pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms  i.r*i.prov, fe robust cluster(hh1)


xi: xtreg children rdp left_in left_out move own pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms  i.r*i.prov, fe robust cluster(hh1)

** works pretty well **
xi: xtreg children rdp left_in left_out own pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms  i.r*i.prov if max_move==0, fe robust cluster(hh1)

** CHILDREN IS SERIOUSLY ROBUST **


xi: xtreg children rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg size rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg size rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg size rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)



** MAIN SPECIFICATION TO EXPLORE

xi: xtreg e rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg ue rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg ue rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg ue rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)



** 1b.) travel
xi: xtreg travel rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg travel rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg travel rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg travel rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg travel rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)
* nice patterns for travel, even though they are tiny

** 1a.) KIDS?

xi: xtreg e rdp children size left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp children size left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp children size left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp children size left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp children size left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)
* robust to size

egen max_kids=max(children), by(pid)

xi: xtreg e rdp left_in  left_out i.r*i.prov if children<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  children<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  children<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 &  children<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  children<2, fe robust cluster(hh1)
* not too much

xi: xtreg e rdp left_in  left_out i.r*i.prov if children>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  children>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  children>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 &  children>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  children>=2, fe robust cluster(hh1)
* its for sure families! with kids!!

xi: xtreg e rdp left_in  left_out i.r*i.prov if max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  max_kids<2, fe robust cluster(hh1)

xi: xtreg e rdp left_in  left_out i.r*i.prov if max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  max_kids>=2, fe robust cluster(hh1)
** ** ** AGAIN CONFIRMED: EMPLOYMENT EFFECTS ARE CONCENTRATED ON FAMILIES WITH KIDS

xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if max_kids<2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if u==0 &  max_kids<2, fe robust cluster(hh1)

xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if max_kids>=2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if u==0 &  max_kids>=2, fe robust cluster(hh1)


xi: xtreg send_r rdp left_in  left_out i.r*i.prov if max_kids<2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if u==0 &  max_kids<2, fe robust cluster(hh1)

xi: xtreg send_r rdp left_in  left_out i.r*i.prov if max_kids>=2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if sex==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if sex==0 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if u==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if u==0 &  max_kids>=2, fe robust cluster(hh1)



** ROBUST TO SERVICES?
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if sex==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if sex==0 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if u==1 &  max_kids<2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if u==0 &  max_kids<2, fe robust cluster(hh1)

xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if sex==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if sex==0 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if u==1 &  max_kids>=2, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w  inf flush piped house roof_cor walls_b rooms i.r*i.prov if u==0 &  max_kids>=2, fe robust cluster(hh1)





* 1.) RENTING VERSUS OWNING
* renters
xi: xtreg e rdp left_in  left_out i.r*i.prov if om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & om1==1 , fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  om1==1, fe robust cluster(hh1)
* owners
xi: xtreg e rdp left_in  left_out i.r*i.prov if om1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  om1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  om1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & om1==0 , fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  om1==0, fe robust cluster(hh1)
*** less clear for the owners, so probably driven by renters..

xi: xtreg e rdp left_in  left_out rent i.r*i.prov, fe robust cluster(hh1)
* rent gets rid of everything as we might think

* 2.) SETTLEMENT ATTRIBUTES 
xi: xtreg e rdp left_in left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms i.r*i.prov if om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out  pit chem bucket pub_tap open_w flush piped house roof_cor walls_b rooms i.r*i.prov if sex==1 &  om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out pit chem bucket pub_tap open_w flush piped house roof_cor walls_b rooms  i.r*i.prov if sex==0 &  om1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms i.r*i.prov if u==1 & om1==1 , fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  pit chem bucket pub_tap open_w flush piped house roof_cor walls_b rooms i.r*i.prov if u==0 &  om1==1, fe robust cluster(hh1)
*** still works


* 3.) INFORMAL SETTLEMENT UPGRADING
xi: xtreg e rdp left_in  left_out i.r*i.prov if inf_max1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  inf_max1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  inf_max1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & inf_max1==1 , fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  inf_max1==1, fe robust cluster(hh1)

xi: xtreg e rdp left_in  left_out i.r*i.prov if inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1 &  inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 &  inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & inf_max1==0 , fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 &  inf_max1==0, fe robust cluster(hh1)

* this variable just screws everything up
xi: xtreg e rdp rdp_mktv  i.r*i.prov if inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp rdp_mktv i.r*i.prov if sex==1 &  inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp rdp_mktv i.r*i.prov if sex==0 &  inf_max1==0, fe robust cluster(hh1)
xi: xtreg e rdp rdp_mktv i.r*i.prov if u==1 & inf_max1==0 , fe robust cluster(hh1)
xi: xtreg e rdp rdp_mktv i.r*i.prov if u==0 &  inf_max1==0, fe robust cluster(hh1)


*** not really different according to informal settlement upgrading

* 4.) VALUE OF THE RDP HOUSE (MEASURE OF ITS QUALITY) 

xi: xtreg e rdp_high rdp_low left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

** pretty strong across measures

xi: xtreg e rdp_high rdp_low left_in  left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms inf  i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms inf  i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms inf  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms inf  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low left_in  left_out pit chem bucket pub_tap open_w  flush piped house roof_cor walls_b rooms inf i.r*i.prov if u==0, fe robust cluster(hh1)

* compute deviation in value between getting house
sort pid r
by pid: g mktv_ch=mktv[_n]-mktv[_n-1]
tab mktv_ch h_ch
g mkg_id=(mktv_ch>5000 & h_ch==1)
g rdp_mkg=mkg_id*rdp
g mkl_id=(mktv_ch<=5000 & h_ch==1)
g rdp_mkl=mkl_id*rdp

xi: xtreg e rdp_mkg rdp_mkl left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp_mkg rdp_mkl left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp_mkg rdp_mkl left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp_mkg rdp_mkl left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp_mkg rdp_mkl left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg inc_r rdp_mkg rdp_mkl left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg inc_r rdp_mkg rdp_mkl left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg inc_r rdp_mkg rdp_mkl left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg inc_r rdp_mkg rdp_mkl left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg inc_r rdp_mkg rdp_mkl left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)


** it's an income effect, those that work more reduce employment more?

*** doesn't matter if quality is controlled for

* 5.) different access to jobs?

xi: xtreg e rdp left_in  left_out i.r*i.prov if long_commute==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1  & long_commute==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 & long_commute==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & long_commute==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 & long_commute==1, fe robust cluster(hh1)
** doesn't work

xi: xtreg e rdp left_in  left_out i.r*i.prov if long_commute==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1  & long_commute==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 & long_commute==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & long_commute==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 & long_commute==0, fe robust cluster(hh1)
** driven by places with a short commute!


xi: xtreg e rdp left_in  left_out i.r*i.prov if commute_dev==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1  & commute_dev==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 & commute_dev==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & commute_dev==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 & commute_dev==1, fe robust cluster(hh1)
** commuting times are greater than average

xi: xtreg e rdp left_in  left_out i.r*i.prov if commute_dev==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1  & commute_dev==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0 & commute_dev==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1 & commute_dev==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0 & commute_dev==0, fe robust cluster(hh1)
** commuting times are less than average

** ** Effects occur where commuting times are less than average





xtreg e rdp left_in left_out_m left_out_n i.r, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n i.r if sex==1, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n  i.r if sex==0, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n  i.r if u==1, fe robust cluster(hh1)
xtreg e rdp left_in left_out_m left_out_n i.r if u==0, fe robust cluster(hh1)

* robust to province time fixed effects
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if u==0, fe robust cluster(hh1)
