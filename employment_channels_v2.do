
* employment channels

cd "/Users/willviolette/Desktop/pstc_work/nids"

use hh_v1_ghs, clear

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

egen sumr=sum(r), by(pid)
keep if sumr==6

egen max_move=max(move), by(pid)

** look at mktv variables
g mktv_rdp=mktv*rdp
g rdp_high=rdp
replace rdp_high=0 if mktv<=30000
g rdp_low=rdp
replace rdp_low=0 if mktv>30000

g rdp_mktv=rdp*mktv



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
