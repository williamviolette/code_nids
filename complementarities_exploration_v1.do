
* child health

cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

g rdpr=rdp

*** get rid of rdp_movers (endogenous)
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<10000
* keep if sr==321

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
** total
keep if tt!=.
** CHILDREN
* keep if a<=18

g inf1=(inf==1 & r==1)
egen inf_max1=max(inf1), by(pid)

replace mktv=. if mktv>100000
egen mktv_max=max(mktv), by(pid)
*keep if mktv==.

g own_r1=(own==0 & r==1)
egen om1=max(own_r1), by(pid)

egen sumr=sum(r), by(pid)
keep if sumr==6
* keep if sumr==4

** look at mktv variables
g mktv_rdp=mktv*rdp
g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

g rdp_mktv=rdp*mktv

*** DEFINE NEW TREATMENT
*** DEFINE DIFFERENT TREATMENTS

** LIMIT SAMPLE TO PEOPLE WHO LIVE IN HOUSES
egen max_dwell=max(house), by(pid)
keep if max_dwell==1

** now try heterogeneity
replace rdp=0 if house==0 & rdp==1

g r_nfye=(rdp==1 & flush==0 & elec==1)
g r_nfne=(rdp==1 & flush==0 & elec==0)
g r_yfye=(rdp==1 & flush==1 & elec==1)
g r_yfne=(rdp==1 & flush==1 & elec==0)


foreach var of varlist r_* {
sort pid r
by pid: g h_ch`var'=`var'[_n]-`var'[_n-1]
drop if h_ch`var'==-1
tab h_ch`var'
}


xi: xtreg e r_* left_in  left_out i.r*i.mdb1, fe robust cluster(hh1)


xi: xtreg e r_* i.r*i.mdb1, fe robust cluster(hh1)
xi: xtreg e r_* i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e r_*  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e r_*  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e r_*  i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg children r_* i.r*i.mdb1, fe robust cluster(hh1)
xi: xtreg children r_* i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg children r_*  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg children r_*  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children r_*  i.r*i.prov if u==0, fe robust cluster(hh1)


xi: xtreg children r_* rooms i.r*i.mdb1, fe robust cluster(hh1)
xi: xtreg children r_* rooms i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg children r_*  rooms i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg children r_*  rooms i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children r_*  rooms i.r*i.prov if u==0, fe robust cluster(hh1)
* kids are only allocated when there's electricity

xi: xtreg c_ill r_* i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_ill r_* i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg c_ill r_*  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg c_ill r_*  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_ill r_*  i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg c_health r_* rooms i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_health r_* rooms i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg c_health r_*  rooms i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg c_health r_*  rooms i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_health r_*  rooms i.r*i.prov if u==0, fe robust cluster(hh1)








g rn=rdp
replace rn=0 if house!=1 & rdp==1


hist rdp_v if rdp_v<80000 & rdp_v>0, by(h_dwltyp)

tab h_dwltyp rdp_v


hist mktv if u==1, by(h_dwltyp h_ch)

*hist mktv if u==0, by(h_dwltyp h_ch)



tab mktv h_ch if h_dwltyp==3

*hist mktv if h_dwltyp==3 | h_dwltyp==4, by(h_dwltyp h_ch)


*hist mktv if u==0, by(h_dwltyp h_ch)
tab h_ch flush if house==1









*** STILL HOLDS FOR ONLY DWELLINGS


g apt=h_dwltyp==3
egen max_apt=max(apt), by(pid)
keep if max_apt==1

xi: xtreg e rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)


xi: xtreg children rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg children rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg send_r rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg send_r rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)

xi: xtreg inc_r rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg inc_r rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)




egen max_dwell=max(house), by(pid)
keep if max_dwell==1

xi: xtreg e rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg e rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)




*** INVESTIGATE COMPLEMENTARITIES




hist h_dwltyp, by( h_ch u)

tab h_dwltyp h_ch

tab h_dwltyp h_ch if u==1
tab h_dwltyp h_ch if u==0


g inf_h_ch_id=(inf==1 & h_ch==1)
egen inf_h_ch=max(inf_h_ch_id), by(pid)

tab inf_h_ch

sort hh1 pid r
browse if inf_h_ch==1

tab prov inf_h_ch




xi: xtreg c_ill rdp left_in  left_out i.r*i.prov, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out i.r*i.prov if sex==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out  i.r*i.prov if sex==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out  i.r*i.prov if u==1, fe robust cluster(hh1)
xi: xtreg c_ill rdp left_in  left_out i.r*i.prov if u==0, fe robust cluster(hh1)







