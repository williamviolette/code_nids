


cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

**** DATA PREP ****

* treatment type censor
keep if tt!=.
* recorded outcomes
keep if hh_outcome==1 & ind_outcome==1
* drop if marketvalue is missing
replace mktv=. if mktv>100000
egen mktv_max=max(mktv), by(pid)
drop if mktv_max==.
* income censor
keep if max_inc<10000
* get rid of rdp movers
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
* make sure individual is present in all rounds
egen sr1=sum(r), by(pid)
keep if sr1==6

** create a measure of large RDP settlement construction
g h_lost=(h_ch==-1)
g h_gain=(h_ch==1)
egen htl=sum(h_lost), by(cluster)
egen htg=sum(h_gain), by(cluster)
g hid=(htl<15 & htg>15)

** create maximum variables
egen max_move=max(move), by(pid)
egen max_a=max(a), by(pid)
egen inf_max=max(inf), by(pid)
g inf1=(inf==1 & r==1)
egen inf_max1=max(inf1), by(pid)

** look at mktv variables
g mktv_rdp=mktv*rdp
g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

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

xtset pid
save inf_analysis1, replace

**************************
** INFORMAL SETTLEMENTS **
**************************

use inf_analysis1, clear

g own_r1=(own==0 & r==1)
egen om1=max(own_r1), by(pid)

xtset pid


* robust to province time fixed effects
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if a>18, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if sex==1 & a>18, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if sex==0 & a>18, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n  i.r*i.prov if u==1 & a>18, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if u==0 & a>18, fe robust cluster(hh1)


xi: xtreg e rdp left_in left_out i.r*i.prov if  inf_max1==1 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out i.r*i.prov if  inf_max1==0 & a>18 & u==1, fe robust cluster(hh1)


xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==1 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==0 & a>18 & u==1, fe robust cluster(hh1)

* are effects stronger if you were renting in period 1?
** first for informal settlements: yes! those that were renting before have the strongest effects
xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==1 & a>18 & u==1 & om1==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==1 & a>18 & u==1 & om1==0, fe robust cluster(hh1)
** now for non informal settlements
xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==0 & a>18 & u==1 & om1==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out i.r*i.prov if  inf_max1==0 & a>18 & u==1 & om1==0, fe robust cluster(hh1)


xi: xtreg ue rdp left_in left_out  flush piped house roof_cor walls_b rooms i.r*i.prov if  inf_max1==1 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out  flush piped house roof_cor walls_b rooms i.r*i.prov if  inf_max1==0 & a>18 & u==1, fe robust cluster(hh1)

xi: xtreg e rdp left_in left_out  flush piped house roof_cor walls_b rooms i.r*i.prov if  inf_max1==1 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out  flush piped house roof_cor walls_b rooms i.r*i.prov if  inf_max1==0 & a>18 & u==1, fe robust cluster(hh1)



xi: xtreg paid_off rdp left_in left_out i.r*i.prov if  inf_max1==1 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg paid_off rdp left_in left_out i.r*i.prov if  inf_max1==0 & a>18 & u==1, fe robust cluster(hh1)



xi: xtreg e rdp left_in left_out i.r*i.prov if inf_max1==0 & a>18 & u==0, fe robust cluster(hh1)



xtreg ue rdp left_in left_out_m left_out_n i.r i.prov if move_rdp_max==0 & a>18, fe robust cluster(hh1)

xi: xtreg ue rdp left_in left_out_m left_out_n i.r*i.prov if move_rdp_max==0 & a>18, fe robust cluster(hh1)

xi: xtreg ue rdp left_in left_out i.r if move_rdp_max==0 & a>18 & u==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out i.r if move_rdp_max==0 & a>18 & u==0, fe robust cluster(hh1)

xi: xtreg ue rdp left_in left_out i.r i.prov if move_rdp_max==0 & a>18 & sex==1, fe robust cluster(hh1)
xi: xtreg ue rdp left_in left_out i.r i.prov if move_rdp_max==0 & a>18 & sex==0, fe robust cluster(hh1)



xi: xtreg ue rdp left_in left_out_m left_out_n i.r*i.prov if move_rdp_max==0 & a>18 & sex==0, fe robust cluster(hh1)


xi: xtreg ue rdp left_in left_out_m left_out_n i.r*i.prov if move_rdp_max==0 & a>18 & inf_max1==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in left_out_m left_out_n i.r*i.prov if move_rdp_max==0 & a>18 & inf_max1==1, fe robust cluster(hh1)


xtreg ue rdp left_in left_out_m left_out_n i.r if max_move==0 & a>18 & inf_max1==1, fe robust cluster(hh1)

xtreg e rdp left_in left_out_m left_out_n i.r if max_move==0 & a>18 & inf_max1==1, fe robust cluster(hh1)


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

