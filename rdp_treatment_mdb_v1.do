cd "/Users/willviolette/Desktop/pstc_work/nids"

**********************************
*** what is the RDP treatment? ***
**********************************

use hh_v1_ghs, clear

egen h_ch_max=max(h_ch), by(pid)
replace h_ch_max=. if h_ch_max==-1
** ONLY LOOK AT SWITCHING HOUSEHOLDS

replace rooms=. if rooms>10

** DATA PREP **
g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(pid)
drop if move_rdp_max==1
keep if max_inc<10000
* keep if a>17
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

keep if tt!=.

egen max_a=max(a), by(pid)
replace toi=. if toi<0

egen h_chs=sum(h_ch), by(mdb1)

* do we see a systematic change in number of rooms?
hist rooms if h_chs>65, by(mdb1 h_ch)
* kind of but not super clear

* is there more variation in valuation when more top structures are given?
hist rdp_v if rdp_v>=0 & rdp_v<70000, by(t_per)
hist rdp_v if rdp_v>=0 & rdp_v<70000, by(prov)
*** GREATER DISTRIBUTION WHERE THERE'S less top structures
*** indication that we might be picking up top structures

* what happens when we use spikes in value distribution as proxy for rdp?
g rdp_15=(rdp_v==15000)
replace rdp_15=. if rdp_v==.
g rdp_0=(rdp_v==0)
replace rdp_0=. if rdp_v==.
g rdp_015=(rdp_15==1 | rdp_0==1)
replace rdp_015=. if rdp_v==.

* how about interacting this valuation with rooms?
hist rooms if rooms<10, by(rdp_015)
* huge spike at 4 and 5 rooms
hist rooms if rooms<10, by(t_per rdp_015)
* nothing really obvious here
hist rooms if rooms<10 & prov==5, by(rdp_015)

* now try other attributes: walls, roof, flush, piped
hist roof, by(t_per rdp_015)
hist roof, by(rdp_15)
hist roof if prov==5, by(rdp_015)
hist roof, by(prov rdp_015)
* very clear: especially for KZN ( look at roof==3 )
hist walls, by(rdp_15)
hist walls, by(t_per rdp_015)
hist walls if prov==5, by(rdp_015)
* less clear
hist flush, by(t_per rdp_015)
hist flush if prov==5
hist toi, by(t_per rdp_015)
* in kzn its very clear: toi==4
* what is toi==4?
hist water, by(t_per rdp_015)
* extremely rigid for kzn: water==3
* what is water==3?

********************************
*** LOOK AT KZN SPECIFICALLY ***
********************************


hist rooms if h_ch>=0 & h_ch_max==1 & rooms<10, by(prov h_ch)
** ROOMS ARE NOT CLEAR
hist roof if h_ch>=0 & h_ch_max==1, by(prov h_ch)
** ROOF IS ALSO NOT FANTASTIC
hist toi if h_ch>=0 & h_ch_max==1, by(prov h_ch)
** TOILET EVEN GETS WORSE
hist water if h_ch>=0 & h_ch_max==1, by(prov h_ch)
* not super clear either
*** HMMM: how to do this?

