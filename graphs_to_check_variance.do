

cd "/Users/willviolette/Desktop/pstc_work/nids"

**** LOOK AT HOUSING CHANGES BY MUNICIPALITY BETWEEN NIDS AND GHS ****
use hh_v1_ghs, clear

drop if r==.
collapse rdp wl rdp_s rdp_h rdp_s_new rdp_h_new, by(r mdb)
sort mdb r
by mdb: g h_ch=rdp[_n]-rdp[_n-1]
by mdb: g h_ch1=rdp_s[_n]-rdp_s[_n-1]
by mdb: g h_ch2=rdp_h[_n]-rdp_h[_n-1]
by mdb: g h_ch1n=rdp_s_new[_n]-rdp_s_new[_n-1]
by mdb: g h_ch2n=rdp_h_new[_n]-rdp_h_new[_n-1]
by mdb: g h_sw=rdp[_n+1]-rdp[_n]
by mdb: g wl_ch=wl[_n]-wl[_n-1]
by mdb: g h_sw1n=rdp_s_new[_n+1]-rdp_s_new[_n]
by mdb: g h_sw1=rdp_s[_n+1]-rdp_s[_n]

** HOW IS WAITLIST RELATED TO CHANGES IN HOUSING?
reg h_sw wl_ch i.r, robust
** ** ** Does this make sense? How would I run the regression?

** nothing
reg h_ch1n wl_ch i.r, robust

reg h_sw1n wl_ch i.r, robust
reg h_sw1 wl_ch i.r, robust

drop if mdb==""
egen mdb1=group(mdb)
xtset mdb1

reg rdp rdp_s i.u i.r, robust
reg rdp rdp_h i.u i.r, robust

xtreg rdp rdp_s i.r i.u, fe robust
xtreg rdp rdp_h i.r i.u, fe robust

xtreg rdp rdp_s i.r i.u, fe robust
xtreg rdp rdp_h i.r i.u, fe robust

g mdbu=mdb1*10+u
xtset mdbu

xtreg rdp rdp_s i.r, fe robust
xtreg rdp rdp_h i.r, fe robust

xtset mdb1
reg rdp rdp_s i.u i.r, robust
reg rdp rdp_h i.u i.r, robust

reg h_ch h_ch1



*******************************************************************
** GET A BETTER SENSE OF ROOM DISTRIBUTIONS FROM RDP'S OVER TIME **
*******************************************************************

use hh_v1, clear

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

g metros=(mdb=="ETH" | mdb=="CPT" | mdb=="JHB" | mdb=="TSH")

tab prov, gen(p_)

tab mdb1, gen(mdb_)

*foreach var of varlist p_* {
*g `var'_t=`var'*r
*}


foreach var of varlist mdb_* {
g `var'_t=`var'*r
}


xtset pid
xtreg e rdp i.r *_t, fe robust cluster(hh1)

xtreg edu rdp i.r *_t if max_a<17 & max_a>6, fe robust cluster(hh1)

xtreg c_ill rdp i.r *_t if max_a<17 & max_a>6, fe robust cluster(hh1)

xtreg size rdp i.r *_t, fe robust cluster(hh1)

xtreg children rdp i.r *_t, fe robust cluster(hh1)

xtreg children rdp i.r *_t, fe robust cluster(hh1)



** is it even possible to zoom in on important munic's?
xtset pid
xtreg e rdp i.r if mdb=="ETH", fe robust cluster(hh1)

xtreg edu rdp i.r if mdb=="ETH" & max_a<17 & max_a>10, fe robust cluster(hh1)
* decrease

xtreg c_ill rdp i.r if mdb=="ETH" & max_a<17 & max_a>6, fe robust cluster(hh1)
* decrease

xtreg size rdp i.r if mdb=="ETH", fe robust cluster(hh1)
* not a lot of movement

xtreg children rdp i.r if mdb=="ETH", fe robust cluster(hh1)
* increase

xtreg ue rdp i.r if mdb=="ETH", fe robust cluster(hh1)
* nothing really

xtreg inc rdp i.r if mdb=="ETH", fe robust cluster(hh1)
* maybe negative but not a lot of movement

****** LOOK AT METROS ******

xtreg e rdp i.r if metros==1, fe robust cluster(hh1)

xtreg edu rdp i.r if metros==1 & max_a<17 & max_a>10, fe robust cluster(hh1)

xtreg c_ill rdp i.r if metros==1 & max_a<17 & max_a>6, fe robust cluster(hh1)

xtreg size rdp i.r if metros==1, fe robust cluster(hh1)

xtreg children rdp i.r if metros==1, fe robust cluster(hh1)

xtreg ue rdp i.r if metros==1, fe robust cluster(hh1)

xtreg inc rdp i.r if metros==1, fe robust cluster(hh1)

****** LOOK AT NON-METRO URBAN AREAS ******

xtreg e rdp i.r if metros==0 & u==1, fe robust cluster(hh1)

xtreg edu rdp i.r if  metros==0 & u==1 & max_a<17 & max_a>10, fe robust cluster(hh1)

xtreg c_ill rdp i.r if  metros==0 & u==1 & max_a<17 & max_a>6, fe robust cluster(hh1)

xtreg size rdp i.r if  metros==0 & u==1, fe robust cluster(hh1)

xtreg children rdp i.r if  metros==0 & u==1, fe robust cluster(hh1)

xtreg ue rdp i.r if  metros==0 & u==1, fe robust cluster(hh1)

xtreg inc rdp i.r if  metros==0 & u==1, fe robust cluster(hh1)




xtreg e rdp i.r if mdb=="CPT", fe robust cluster(hh1)



tab mdb1 h_ch
egen h_ch_mdb=sum(h_ch), by(mdb1)

replace h_dwlmatrwll=. if h_dwlmatrwll<0
replace h_dwlmatroof=. if h_dwlmatroof<0
tab hhgeo2011, gen(geo)

** ONLY COMPARE DWELLINGS TO EARLIER DWELLINGS: CAN WE FIND SOMETHING SYSTEMATIC?
* egen max_h_ch=max(h_ch), by(pid)
* keep if max_h_ch==1


duplicates drop hhid, force

***********

hist rooms if rooms<10, by(prov u h_ch)


hist rooms if rooms<10, by(hhgeo2011 h_ch)

hist rooms if rooms<10, by(hhgeo2011 rdp h_ch)

hist rooms if rooms<10 & move==0, by(hhgeo2011 rdp h_ch)
*** doesn't look bad but actually the
*** more recent rdp constructions look less
*** like cookie cutter 4 room houses

**** NOW CHECK NiDS TO SEE IF WE GET RELATIVELY UNIFORM HOUSES
**** IN MUNICIPALITIES


tab rooms if rooms<10 & h_ch==1 & mdb1==1


hist rooms if rooms<10 & h_ch==1 & h_ch_mdb>100 & move==0, by(mdb1 r)

hist rooms if rooms<10 & h_ch==1 & h_ch_mdb>100 & move==0 & r==2, by(mdb1 u)

hist rooms if rooms<10 & h_ch==1 & h_ch_mdb>100 & move==0, by(mdb1)

hist rooms if rooms<10 & h_ch==1 & h_ch_mdb>100 & move==0, by(mdb1 hhgeo2011)

hist rooms if rooms<10 & h_ch==1 & h_ch_mdb<=100 & h_ch_mdb>70 & move==0, by(mdb1 u)

** just look at KZN
hist rooms if rooms<10 & h_ch==1 & move==0 & prov==5, by(mdb1 u)

** now go by provinces
hist rooms if rooms<10 & h_ch==1 & move==0, by(prov u r)

hist rooms if rooms<10 & h_ch==1 & move==0, by(prov hhgeo2011)

* hist rooms if rooms<10 & rdp==1 & move==0, by(prov u)



** it could be that rooms just don't really work
**** need something that works, and is measured well!
**** can I think of other ways to test the rooms measure?

******************
** MARKET VALUE **
******************
hist mktv if mktv<100000 & h_ch==1 & move==0, by(prov u)
** super noisy as we would kind of expect **
** basically flat distribution

*******************
** WALL MATERIAL **
*******************

hist h_dwlmatrwll if h_ch==1 & move==0, by(prov u)

hist h_dwlmatroof if h_ch==1 & move==0, by(prov u)
** variation in these is actually happening more between provinces
** which is nice to see, it looks like RDP construction is 
** relatively uniform within province

hist h_dwlmatrwll if h_ch==1 & move==0 & h_ch_mdb>100, by(mdb1 u)

hist h_dwlmatroof if h_ch==1 & move==0 & h_ch_mdb>100, by(mdb1 u)


** add geotype?


use 09_13_analysis_t.dta, clear

egen geotype=max(GeoType), by(psu)

g year1=.
forvalues r=2009/2013 {
replace year1=`r' if h_age==1 & year==`r'
replace year1=`r'-4 if h_age==2 & year==`r'
replace year1=`r'-8 if h_age==3 & year==`r'
}

*hist rooms if rooms<10 & rooms>0 & rdp_s==1 & year1>2004 & year1<2013 & GeoType!=2 & GeoType!=5, by(year1 GeoType)     
*hist rooms if rooms<10 & rooms>0 & rdp_s==1 & year1>2004 & year1<2013 & geotype!=2 & geotype!=5, by(year1 geotype)     

****************************************
** CAN WE FIND A TIME TREND IN ROOMS? **
****************************************

hist rooms if rooms<10 & rooms>0 & rdp_s==1 & geotype!=2 & geotype!=5 & h_age<3, by(year geotype)
** histogram of relatively young houses over time, between rural and urban areas

hist rooms if rooms<10 & rooms>0 & rdp_s==1 & geotype!=2 & geotype!=5 & h_age<3 & ben==1, by(year geotype)
** now limit to just original beneficiaries

hist rooms if rooms<10 & rooms>0 & rdp_s==1 & geotype!=1 & geotype!=4 & h_age<3 & ben==1, by(year geotype)
** now look at informal and non-tribal **
** find similar story

***** CONCLUSION: greater spillage to the right in rural areas
*****             is this because houses built were different or people modified them differently?
*****             No hugely obvious time trends

hist rooms if rooms<10 & rooms>0 & rdp_s==0, by(year1)

hist rooms if rooms<10 & rooms>0 & rdp_h==1, by(year1)


hist value, by(h_age rdp_s)


use ghs_link_r, clear


egen mdb1=group(mdb)

separate rdp_s, by(mdb1)
separate rdp_h, by(mdb1)


twoway scatter rdp_s1* r
twoway scatter rdp_h1* r

twoway scatter rdp_s2* r


*********************** GET A SENSE OF WHAT'S GOING ON OVER TIME

use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

collapse rdp_s rdp_h, by(mdb year)


egen mdb1=group(mdb)

separate rdp_s, by(mdb1)

separate rdp_h, by(mdb1)

twoway scatter rdp_s1 rdp_s2 rdp_s47-rdp_s52 year

twoway scatter rdp_s3 rdp_s4 rdp_s30-rdp_s39 year

twoway scatter rdp_h1 rdp_h2 rdp_h47-rdp_h52 year

twoway scatter rdp_h3 rdp_h4 rdp_h30-rdp_h39 year


use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

g rdp_s_new=(rdp_s==1 & h_age==1)

g rdp_h_new=(rdp_h==1 & h_age==1)

collapse rdp_s rdp_h rdp_s_new rdp_h_new, by(mdb year)

egen mdb1=group(mdb)

separate rdp_s_new, by(mdb1)

separate rdp_h_new, by(mdb1)

twoway scatter rdp_s_new1 rdp_s_new2 rdp_s_new47-rdp_s_new52 year

twoway scatter rdp_s_new3 rdp_s_new4 rdp_s_new30-rdp_s_new39 year


twoway scatter rdp_h_new1 rdp_h_new2 rdp_h_new47-rdp_h_new52 year

twoway scatter rdp_h_new3 rdp_h_new4 rdp_h_new30-rdp_h_new39 year

twoway scatter rdp_h_new5 rdp_h_new6 rdp_h_new20-rdp_h_new29 year



********* PROVINCE LEVEL

use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

collapse rdp_s rdp_h, by(Prov year)

separate rdp_s, by(Prov)

separate rdp_h, by(Prov)


twoway scatter rdp_s* year

twoway scatter rdp_h* year








