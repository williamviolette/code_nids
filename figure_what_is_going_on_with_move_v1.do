


cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

* test assumptions of how the program works
*** initial level of rdp graphed against gain in rdp's by cluster

* g h_lost=(h_ch==-1)
* g h_gain=(h_ch==1)
* egen htl=sum(h_lost), by(cluster r)
* egen htg=sum(h_gain), by(cluster r)
* egen rdpid=sum(rdp), by(cluster r)
* sort cluster r
* by cluster: g rdpidl=rdpid[_n-1]
* twoway scatter htg rdpidl if r==3

g h_lost=(h_ch==-1)
g h_gain=(h_ch==1)
egen htl=sum(h_lost), by(cluster)
egen htg=sum(h_gain), by(cluster)
egen rdpid=sum(rdp), by(cluster)
replace h_toi=. if h_toi<0 | h_toi==9
g pit=(h_toi==4 | h_toi==5)
g chem=h_toi==3
g bucket=h_toi==6
g pub_tap=h_watsrc==3
g open_w=(h_watsrc==8 | h_watsrc==9)

* treatment type censor
keep if tt!=.

*keep if sr==321
drop if prov==10
keep if hh_outcome==1 & ind_outcome==1

* drop if marketvalue is missing
replace mktv=. if mktv>100000
egen mktv_max=max(mktv), by(pid)
drop if mktv_max==.

* drop if room missing
*replace rooms=. if rooms>10
*egen rooms_max=max(rooms), by(pid)
*drop if rooms_max==.

* income censor
keep if max_inc<15000

* province censor
drop if prov==.
* mdb censor
drop if mdb==""

* make sure individual is present in all rounds
egen sr1=sum(r), by(pid)
keep if sr1==6
** works, includes only people that gain rdp



***************************
****** ALL DATA PREP ******
***************************
g hid=(htl<15 & htg>15)

sort pid r
order pid r prov mdb

sort pid r
by pid: g mktv_ch=mktv[_n]-mktv[_n-1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g flush_ch=flush[_n]-flush[_n-1]
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
by pid: g house_ch=house[_n]-house[_n-1]
by pid: g inf_ch=inf[_n]-inf[_n-1]
by pid: g mdb1_ch=mdb1[_n]!=mdb1[_n-1]
by pid: g mdb_ch=mdb[_n]!=mdb[_n-1]
by pid: g prov_ch=prov[_n]!=prov[_n-1]

egen max_move=max(move), by(pid)
replace mdb_ch=0 if r==1
egen max_mdb_ch=max(mdb_ch), by(pid)

g id=(mdb_ch==0 & prov_ch==1)
egen max_id=max(id), by(pid)

egen max_a=max(a), by(pid)

egen inf_max=max(inf), by(pid)

g inf1=(inf==1 & r==1)
egen inf_max1=max(inf1), by(pid)

replace move=0 if r==1
tab mdb_ch move
tab prov_ch move

g hoh_fem=(sex==0 & hoh==1)
egen hoh_sex=max(hoh_fem), by(hhid)

g mktv_rdp=mktv*rdp

g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

g inc_r_per=inc_r/inc

****** INFORMAL SETTLEMENT HOUSES PROXY ******

*tab cluster h_ch if inf_max1==1 & max_move==0
* flows don't look too bad, on average most places either have lots of entry or exit

*tab cluster h_ch if max_move==0
*keep if inf_max1==1 & max_move==0 & h_ch==1
*collapse rooms flush walls_b roof_cor house, by(hhid cluster inf_max1 max_move h_ch)

*tab cluster rooms if inf_max1==1 & max_move==0 & h_ch==1
*tab cluster flush if inf_max1==1 & max_move==0 & h_ch==1
*tab cluster walls_b if inf_max1==1 & max_move==0 & h_ch==1
*tab cluster roof_cor if inf_max1==1 & max_move==0 & h_ch==1
*tab cluster house if inf_max1==1 & max_move==0 & h_ch==1

**** CHECK THE BALANCE FOR THE 

tab h_ch if inf_max1==1 & max_move==0
tab prov if inf_max1==1 & max_move==0 & h_ch==1 

tab cluster if inf_max1==1 & max_move==0 & h_ch==1
tab hh1 if inf_max1==1 & max_move==0 & h_ch==1


**************************
** INFORMAL SETTLEMENTS **
**************************


xtset pid

* xi: xtreg hoh_sex rdp i.r*i.prov if inf_max1==1, fe robust cluster(hh1)
xi: xtreg ue rdp i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg ue rdp i.r*i.prov if inf_max1==0 & max_move==0, fe robust cluster(hh1)
xi: xtreg ue rdp i.r*i.prov, fe robust cluster(hh1)
xi: xtreg ue rdp flush piped house roof_cor walls_b rooms i.r*i.prov, fe robust cluster(hh1)
xi: xtreg ue rdp flush piped house roof_cor walls_b rooms i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg ue rdp flush piped house roof_cor walls_b rooms i.r*i.prov if inf_max1==0 & max_move==0, fe robust cluster(hh1)

*** very much driven by people leaving informal settlements


** INTERACT WITH MARKET VALUE?
xi: xtreg ue rdp mktv mktv_rdp flush piped house roof_cor walls_b rooms i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg ue rdp mktv flush piped house roof_cor walls_b rooms i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)

xi: xtreg ue rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)

xi: xtreg mktv rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)

** WAY MORE LIKELY TO BE UNEMPLOYED
xi: xtreg ue rdp_high rdp_low flush piped house roof_cor walls_b rooms elec i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
** Controlling for attributes, men still are way more likely to be unemployed
xi: xtreg inc rdp_high rdp_low flush piped house roof_cor walls_b rooms elec i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
** Controlling for attributes, incomes drop substantially
xi: xtreg inc_r rdp_high rdp_low i.r*i.prov if inf_max1==1, fe robust cluster(hh1)
** we see income drop and remittances really drop!!


xi: xtreg ue rdp_high rdp_low flush piped house roof_cor walls_b rooms elec i.r*i.prov if max_move==0, fe robust cluster(hh1)
xi: xtreg ue rdp_high rdp_low i.r*i.prov if max_move==0 & inf_max1==0 & inf_max==0, fe robust cluster(hh1)
** concentrated in people upgraded from informal settlements

xi: xtreg c_ill rdp_high rdp_low flush piped house roof_cor walls_b rooms elec i.r*i.prov if max_move==0 & inf_max1==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp_high rdp_low i.r*i.prov if max_move==0 & inf_max1==0, fe robust cluster(hh1)

xi: xtreg c_ill rdp_high rdp_low i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)



xi: xtreg ue rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0 & sex==1, fe robust cluster(hh1)
xi: xtreg ue rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0 & sex==0, fe robust cluster(hh1)

xi: xtreg e rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0 & sex==1, fe robust cluster(hh1)
xi: xtreg e rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0 & sex==0, fe robust cluster(hh1)

xi: xtreg inc rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg inc_r rdp_high rdp_low i.r*i.prov if  max_move==0, fe robust cluster(hh1)

xi: xtreg inc_r_per rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)

**** is it behavior? or is it physical house?
xi: xtreg c_ill rdp_high rdp_low  i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp_high rdp_low  flush piped house roof_cor walls_b rooms i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
* holds controlling for attributes: so there is something else going on, healthier kids?

xi: xtreg travel rdp i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)


** both **
xi: xtreg absent rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
** not enough obs
xi: xtreg sch_d rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
* distance to school drops for low value
xi: xtreg edu rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0 & max_a>6 & max_a<16, fe robust cluster(hh1)
* improvements for high value

*** formal wage increases for hightype
xi: xtreg fwag rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg swag rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)
xi: xtreg cwag rdp_high rdp_low i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)



*** urban areas all informal, rural areas not informal
xi: xtreg ue rdp_high rdp_low i.r*i.prov if inf_max1==0 & max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg ue rdp_high rdp_low i.r*i.prov if inf_max1==0 & max_move==0 & u==0, fe robust cluster(hh1)



xi: xtreg e rdp i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)


xi: xtreg ue rdp i.r*i.prov if inf_max1==0 & max_move==0, fe robust cluster(hh1)

xi: xtreg inc rdp i.r*i.prov if inf_max1==1 & max_move==0, fe robust cluster(hh1)


xi: xtreg ue rdp i.r*i.prov if inf_max1==1 & hid==1, fe robust cluster(hh1)


xi: xtreg ue rdp i.r*i.prov if max_move==0 & u==1 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg ue rdp flush piped house roof_cor walls_b rooms i.r*i.prov if max_move==0 & u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg ue rdp i.r*i.prov if max_move==0 & u==1 & inf_max1==0, fe robust cluster(hh1)


xi: xtreg c_ill rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp i.r*i.prov if inf_max1==1, fe robust cluster(hh1)

xi: xtreg c_ill rdp i.r*i.prov if  inf_max1==1 & hid==1, fe robust cluster(hh1)


xi: xtreg c_ill rdp i.r*i.prov if max_move==0 & inf_max1==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp i.r*i.mdb1 if max_move==0 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp flush piped house roof_cor walls_b rooms i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg absent rdp i.r*i.mdb1 if max_move==0 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg absent rdp i.r*i.mdb1 if inf_max1==1, fe robust cluster(hh1)

xi: xtreg absent rdp flush piped house roof_cor walls_b rooms i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg edu rdp i.r*i.mdb1 if max_move==0 & inf_max1==1 &  max_a>6 & max_a<16, fe robust cluster(hh1)


xi: xtreg edu rdp i.r*i.mdb1 if inf_max1==1 &  max_a>6 & max_a<16, fe robust cluster(hh1)
* pretty robust

* * * hard to data mine the education relationship

xi: xtreg own rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)
** ** not strongly correlated with ownership! interesting..

xi: xtreg fwag rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg swag rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)
** less likely to be self-employed


*********** MARKET VALUE BOOST IS DRIVEN BY INFORMAL SETTLEMENTS *************
xi: xtreg mktv rdp flush piped house roof_cor walls_b rooms i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg mktv rdp flush piped house roof_cor walls_b rooms theft domvio vio gang murder drug i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg mktv rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg mktv rdp flush piped house roof_cor walls_b rooms i.r*i.prov if max_move==0 & inf_max1==0 & u==1, fe robust cluster(hh1)
xi: xtreg mktv rdp i.r*i.prov if max_move==0 & inf_max1==0 & u==1, fe robust cluster(hh1)




**************************
***** START ANALYSIS *****
**************************

* g h_ch_stay=h_ch if max_move==0
* g h_ch_move=h_ch if max_move==1

* drop if r==1
* collapse h_ch h_ch_stay h_ch_move, by(hhid cluster)
** geographic concentration of h_ch
* collapse h_ch h_ch_stay h_ch_move, by(cluster)

* hist h_ch_stay
* hist h_ch_move

xtset pid

xi: xtreg size rdp i.r*i.prov if max_move==0, fe robust cluster(hh1)

xi: xtreg size rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)

xi: xtreg size rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)


xi: xtreg e rdp i.r*i.prov if max_move==0, fe robust cluster(hh1)

xi: xtreg e rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)

xi: xtreg e rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg ue rdp i.r*i.prov if max_move==0, fe robust cluster(hh1)


xi: xtreg piped rdp i.r*i.prov if max_move==0, fe robust cluster(hh1)

xi: xtreg inf rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg inf rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg flush rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg flush rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg walls_b rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg walls_b rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg roof_cor rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg roof_cor rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg elec rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg elec rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg rooms rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)
xi: xtreg rooms rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg rooms rdp i.r*i.prov if max_move==0, fe robust cluster(hh1)


xi: xtreg inf rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg sch_d rdp i.r*i.mdb1 if u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg inc_r rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg send_r rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg travel rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)


** nothing with size and children, weird..
xi: xtreg size rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg children rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)




xi: xtreg ue rdp i.r*i.prov if max_move==0 & u==1 & inf_max1==0, fe robust cluster(hh1)

xi: xtreg sch_d rdp i.r*i.prov if max_move==0  & u==1 & inf_max1==1, fe robust cluster(hh1)


xi: xtreg theft rdp i.r*i.prov if max_move==0 & inf_max1==1, fe robust cluster(hh1)


* demographic shifts in rural areas? not really either...
xi: xtreg size rdp i.r*i.prov if u==0 & max_move==0, fe robust cluster(hh1)
xi: xtreg children rdp i.r*i.prov if u==0 & max_move==0, fe robust cluster(hh1)



xi: xtreg rent rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)

xi: xtreg children rdp i.r*i.prov if u==1 & inf_max1==1, fe robust cluster(hh1)




xi: xtreg c_ill rdp i.r*i.prov if max_move==0 & u==1, fe robust cluster(hh1)

xi: xtreg c_ill rdp i.r*i.prov if max_move==0 & u==0, fe robust cluster(hh1)

xi: xtreg edu rdp i.r*i.prov if max_move==0 & u==1 &  max_a>6 & max_a<16, fe robust cluster(hh1)

xi: xtreg edu rdp i.r*i.prov if max_move==0 & u==0 &  max_a>6 & max_a<16, fe robust cluster(hh1)

xi: xtreg c_health rdp i.r*i.prov if max_move==0 & u==1 &  max_a>6 & max_a<16, fe robust cluster(hh1)
xi: xtreg c_health rdp i.r*i.prov if max_move==0 & u==0 &  max_a>6 & max_a<16, fe robust cluster(hh1)






xi: xtreg c_ill rdp i.r*i.prov if max_move==0 & max_mdb_ch==0, fe robust cluster(hh1)

xi: xtreg e rdp i.r*i.prov if max_move==0 & max_mdb_ch==0, fe robust cluster(hh1)

xi: xtreg ue rdp i.r*i.prov if max_move==0 & max_mdb_ch==0, fe robust cluster(hh1)



xi: xtreg size rdp i.r*i.prov if max_move==0 & max_inf==0 & tt!=., fe robust cluster(hh1)


** WTF IS GOING ON!?!?!

egen max_inf=max(inf), by(pid)

egen max_a=max(a), by(pid)

egen max_move=max(move), by(pid)

drop if rooms_ch==.
drop if piped_ch==.
drop if flush_ch==.
drop if house_ch==.
drop if inf_ch==.
g n_d=(rooms_ch!=0 & piped_ch!=0 & flush_ch!=0 & house_ch!=0 & inf_ch!=0)

tab n_d move

** THE MOVE VARIABLE IS WAY NOISIER THAN ADVERTIZED!!


***************************
*** CHANGE DESCRIPTIVES ***
***************************

tab prov_ch mdb_ch
tab mdb_ch rdp
tab move rdp
tab move mdb_ch

tab move h_ch
tab mdb_ch h_ch
tab prov_ch h_ch

tab mdb_ch move if h_ch==1


