** NEW HH DIVISION
 
cd "/Users/willviolette/Desktop/pstc_work/nids"

use "reg3_1", clear

sort hhid
merge hhid using child
drop if _merge==2
drop _merge

save "div1.dta", replace

*****
 *****
  *****
use "div1.dta", clear
sort pid r
duplicates drop pid r, force

forvalues r=1/15 {
sort hhid pid
by hhid: g pid_`r'=pid[`r']
replace pid_`r'=0 if pid_`r'==.
* variable for each member in period 1

g id_`r'=0
replace id_`r'=pid_`r' if r==2
egen id2_`r'=max(id_`r'), by(pid)
drop id_`r'
* variable for each member in period 2

g idz_`r'=0
replace idz_`r'=pid_`r' if r==3
egen id3_`r'=max(idz_`r'), by(pid)
drop idz_`r'
}

forvalues r=1/15 {
forvalues z=1/15 {
g u_`r'_`z'=(id2_`r'==pid_`z' & id2_`r'!=0 & pid_`z'!=0)
g u3_`r'_`z'=(id3_`r'==id2_`z' & id3_`r'!=0 & id2_`z'!=0)
}
}

egen final2=rowtotal(u_*)
replace final2=. if r>1
egen final3=rowtotal(u3_*)
replace final3=. if r==3 | r==1

drop u_* u3_* id2_* id3_* pid_*

g i=1
egen hs=sum(i), by(hhid)

g fr2=final2/hs
g fr3=final3/hs

egen sr2=max(fr2), by(hhid)
egen sr3=max(fr3), by(hhid)

g sr=sr2 if r==1
replace sr=sr3 if r==2


* RDP
g rdp=(h==1 | h==-9)

sort pid r
by pid: g h_ch=(rdp[_n-1]==0 & rdp[_n]==1)
* * *
* * RDP
* * * 
* for round 2:
g h_ch_2=(h_ch==1 & r==2)
egen m_p_2=max(h_ch_2), by(pid)
egen m_h_2=max(m_p_2), by(hhid)
g left_out2=(m_h_2==1 & m_p_2==0 & r==1)

egen mlo2=max(left_out2), by(pid)
egen left_in2=max(left_out2), by(hhid)
replace left_in2=0 if left_out2==1
egen left_in2m=max(left_in2), by(pid)

g lo2=(mlo2==1 & r==2)

egen left_out2_hh=sum(left_out2), by(hhid)

* for round 3:
g h_ch_3=(h_ch==1 & r==3)
egen m_p_3=max(h_ch_3), by(pid)
egen m_h_3=max(m_p_3), by(hhid)
g left_out3=(m_h_3==1 & m_p_3==0 & r==2)

egen mlo3=max(left_out3), by(pid)
egen left_in3=max(left_out3), by(hhid)
replace left_in3=0 if left_out3==1
egen left_in3m=max(left_in3), by(pid)

g lo3=(mlo3==1 & r==3)

egen left_out2_m=max(left_out2), by(pid)
egen left_out3_m=max(left_out3), by(pid)

** LEFT OUT
g left_out=lo2+lo3

sort pid r
by pid: replace left_out=1 if left_out[_n-1]==1

** LEFT IN
g left_in=left_in2 + left_in3

egen s_lo=sum(left_out), by(hhid)

save "div2.dta", replace

  *****
 *****
*****


use "div2.dta", clear

drop left_in2 left_in3
rename left_in2m left_in2
rename left_in3m left_in3
replace left_in2=0 if r>1
replace left_in3=0 if r==1 | r==3

** work with fr2 fr3 left_out2 left_out3 left_in2m left_out3m

*** MAKE VARIABLES AND CLEAN ***
drop left_in
drop left_out
g left_in=left_in2+left_in3
g left_out=left_out2+left_out3

g fr=fr2
replace fr=fr3 if r==2

tab fr left_in
tab fr left_out

* hist fr if left_in==1
* hist fr if left_out==1

egen h_ch_id=max(h_ch), by(pid)
egen h_ch_hh=max(h_ch_id), by(hhid)

* tab sr h_ch_id if r==1
* tab h_ch_hh if r==1
* get a sense for size of households
* hist s if r==1

reg sr h_ch_hh i.r if r!=3, robust cluster(hhid)

* income censor
replace hh_income=0 if hh_income==.
egen max_i_income=max(hh_income), by(pid)
egen max_hh_income=max(max_i_income), by(hhid)
** drop if max_hh_income>20000

* keep if hh_income<10000

* urban
g u=(urb==2)

g a=2008-age if r==1
replace a=2010-age if r==2
replace a=2012-age if r==3
replace a=. if a<0

g child_d=(child>0 & child<.)
g e=(emp==1)
g m=(marry==1 | marry==2)

* control for log food expenditure
replace fd=. if fd<0
g ln_fd=ln(fd)
* construct budget shares

* variables
* soft drinks
replace fdsdspn=0 if fdsdspn<=0
g sd_s=fdsdspn/hh_income
g sd_s_fd=fdsdspn/fd
replace sd_s=. if sd_s>1
 replace sd_s=0 if sd_s==.
 replace sd_s=. if sd_s>.4

* vegetables
replace fdpotspn=0 if fdpotspn<=0
replace fdvegdspn=0 if fdvegdspn<=0 | fdvegdspn==.
replace fdvegospn=0 if fdvegospn<=0 | fdvegospn==.
g veg=fdvegospn+fdvegdspn+fdpotspn
g veg_s=veg/hh_income
g veg_s_fd=veg/fd
replace veg_s=. if veg_s>1
replace veg_s=0 if veg_s==.
replace veg_s_fd=. if veg_s_fd>1

* chicken
replace fdchispn=0 if fdchispn<=0
g chi_s=fdchispn/fd
replace chi_s=. if chi_s>1
g chi_s_fd=fdchispn/fd
replace chi_s_fd=. if chi_s_fd>1

* ready made meals
replace fdrdyspn=0 if fdrdyspn<=0
g rdy_s=fdrdyspn/hh_income

replace fdoutspn=0 if fdoutspn<=0
g out_s=fdoutspn/hh_income

* decision making power
g dec=(decd==pid)
g dec_j=(decd2==pid)
g rdp_a=rdp*a

egen dec_j_id=max(dec_j), by(hhid)

** EMPLOYMENT
drop e
g e=(emp==1)
egen emp_hh=max(e), by(hhid)

* CHILD SUPPORT GRANT
g csg=grcur==1

* WATER SOURCE
g piped=(water==1 | water==2)

* conservative hh_ch esitmate
sort pid r
by pid: g hh_sw=(rdp[_n]==0 & rdp[_n+1]==1)
egen h_ch_sw=max(hh_sw), by(hhid)


egen in1=max(fr), by(hhid)
g in_h=(in1==fr & fr<1)
egen out1=min(fr), by(hhid)
g out_h=(out1==fr & fr<1)

replace in_h=0 if in1==out1
replace out_h=0 if in1==out1

*** ANALYSIS

* * * WHICH INDIVIDUAL LEAVES THE HOUSEHOLD ? ? ? ?

* * get some extra variables
replace pay=0 if pay==. | pay<0
g r_d=re_yn==1
g sex=(gender==1)
replace flu=0 if flu==2 | flu<1
replace marry_yrs=0 if marry_yrs==. | marry_yrs<0

* dwelling
** informal
g inf=(dwell>=7 & dwell<=8)
replace child=0 if child==-3
replace child=0 if child==.

** LOOK MORE CAREFULLY AT HOUSEHOLD SIZE CHANGES
sort pid r
by pid: g size_ch=(size[_n]-size[_n-1])
by pid: g elec_ch=(elec[_n]-elec[_n-1])
by pid: g piped_ch=(piped[_n]-piped[_n-1])
by pid: g inf_ch=(inf[_n]-inf[_n-1])
by pid: g child_ch=(child[_n]-child[_n-1])
by pid: g dwell_ch=(dwell[_n]!=dwell[_n-1])
by pid: g roof_ch=roof[_n]!=roof[_n-1]
by pid: g walls_ch=roof[_n]!=roof[_n-1]
by pid: g toi_ch=toi[_n]!=toi[_n-1]
by pid: g toi_shr_ch=toi_shr[_n]!=toi_shr[_n-1]
by pid: g rent_ch=rent[_n]-rent[_n-1]
g rent_dum=(rent>0 | rent!=.)
by pid: g rent_dum_ch=rent_dum[_n]-rent_dum[_n-1]
replace rooms=. if rooms<=0
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]


replace dwell=. if dwell<1 | dwell==11
g rdp1=.
replace rdp1=1 if h==1
replace rdp1=0 if h==2
g owner=(ownpid==pid)

sort pid r
by pid: g h_ch1=(rdp1[_n-1]==0 & rdp1[_n]==1)
by pid: g h_cht=(rdp[_n]-rdp[_n-1])
by pid: g owner_ch=(owner[_n]-owner[_n-1])
by pid: g fr1=fr[_n-1]

* getting a house
egen h_ch_s=sum(h_ch), by(hhid)
g h_chs=h_ch_s/hs

* total stuff going on
egen h_ch_l=sum(h_cht), by(hhid)
g h_chl=h_ch_l/hs

drop h_ch
g h_ch=h_cht==1
g h_l=h_cht==-1

replace mktv=. if mktv<=0
replace mktv=. if mktv>100000

save "nids_4.dta", replace



use "nids_4.dta", clear
** NOW TAKE A LOOK AT PRETRENDS TO SEE IF THERE IS SOMETHING PREDICTING
** WHETHER A HOUSEHOLD GETS A HOUSE

sort pid r
by pid: g h_sw=rdp[_n+1]-rdp[_n]
by pid: g inc_ch=hh_income[_n]-hh_income[_n-1]

g h_swg=h_sw==1
g h_swl=h_sw==-1

keep if r==2

** SELECTION RULE?!

reg h_swg inc_ch elec_ch toi_ch toi_shr_ch size_ch child_ch dwell_ch rooms_ch if h_swl==0, robust cluster(hhid)
** DO THIS SAME THING WITH CAPS!!
** ALSO SIZE CHANGE COULD BE A DEATH!
* loss of a pensioner could knock a family into eligible range


reg h_swg inc_ch size_ch elec_ch piped_ch inf_ch child_ch dwell_ch roof_ch walls_ch toi_ch toi_shr_ch rent_ch rent_dum rent_dum_ch rooms_ch, robust cluster(hhid)

reg h_swl inc_ch size_ch elec_ch piped_ch inf_ch child_ch dwell_ch roof_ch walls_ch toi_ch toi_shr_ch rent_ch rent_dum rent_dum_ch rooms_ch, robust cluster(hhid)






* test rooms hypothesis by income
use "nids_4.dta", clear
replace rooms=. if rooms<=0 | rooms>8

* classic income histogram
twoway (hist hh_income if h_ch==1 & hh_income<20000, fcolor(none) lcolor(black)) || hist hh_income if h_ch==0 & hh_income<20000, fcolor(none) lcolor(red)

* rooms by income in rdp and non-rdp
twoway (hist rooms if hh_income<3500 & rdp==1, fcolor(none) lcolor(black)) || hist rooms if hh_income<3500 & rdp==0, fcolor(none) lcolor(red)

twoway (hist rooms if hh_income<=7000 & hh_income>3500 & rdp==1, fcolor(none) lcolor(black)) || hist rooms if hh_income<=7000 & hh_income>3500 & rdp==0, fcolor(none) lcolor(red)

twoway (hist rooms if hh_income<=15000 & hh_income>7000 & rdp==1, fcolor(none) lcolor(black)) || hist rooms if hh_income<=15000 & hh_income>7000 & rdp==0, fcolor(none) lcolor(red)

* no income
twoway (hist rooms if rdp==1, fcolor(none) lcolor(black)) || hist rooms if rdp==0, fcolor(none) lcolor(red)
** definitely see a drop down at 5 rooms

* now look at switchers
twoway (hist rooms if h_ch==1, fcolor(none) lcolor(black)) || hist rooms if h_ch==0, fcolor(none) lcolor(red)
* more pronounced for switchers so that's good
** look for cut-off by individual wage?

twoway (hist rooms if h_ch==1 & rdp==1, fcolor(none) lcolor(black)) || hist rooms if h_ch==0 & rdp==1, fcolor(none) lcolor(red)
* more pronounced for switchers relative to non-rdp, so that's good also!

** look for h_ch, strongest cut-off by income
twoway (hist rooms if  hh_income<3500 & h_ch==1, fcolor(none) lcolor(black)) || hist rooms if  hh_income<3500 & h_ch==0, fcolor(none) lcolor(red)

twoway (hist rooms if  hh_income<=7000 & hh_income>3500 & h_ch==1, fcolor(none) lcolor(black)) || hist rooms if  hh_income<=7000 & hh_income>3500 & h_ch==0, fcolor(none) lcolor(red)

twoway (hist rooms if  hh_income<=15000 & hh_income>7000 & h_ch==1, fcolor(none) lcolor(black)) || hist rooms if  hh_income<=15000 & hh_income>7000 & h_ch==0, fcolor(none) lcolor(red)






** TREAT RDP AS ENDOGENOUS
use "nids_4.dta", clear
sort pid r
merge pid r using dt1
tab _merge
save "nids_4_1.dta", replace

use "nids_4_1.dta", clear
g death=mrt24mnth==1
g p=mrtage1>65
replace p=0 if mrtage1==.

tab death h_ch
tab death h_cht

tab p h_cht

reg h_ch death p
* way less likely to get housing assistance!



use "nids_4.dta", clear

replace i=. if a<20
drop hs
egen hs=sum(i), by(hhid)

g ipc=hh_income/hs
replace ipc=. if ipc>20000
replace ipc=. if ipc==0
replace ipc=. if hs==1
drop h_l
g h_g=h_ch==1
drop if r==1

twoway hist ipc if h_g==0 & rdp==0, || hist ipc if h_g==1, fcolor(none) lcolor(purple)

** NOTHINGGGG
hist hh_income if h_g==1 & hh_income<20000

g hi_2=hh_income/2
hist hi_2 if h_g==1 & hh_income<20000

forvalues r=0(100)20000 {
replace ipc=`r' if ipc>=`r' & ipc<`r'+100
}

collapse h_g, by(ipc)

twoway ( scatter h_g ipc, color(blue))




use "nids_4.dta", clear


***************************
***    ANALYSIS
***************************

drop if r==1

** MAKE SURE HOUSES ARE HOUSES
twoway hist mktv if rdp==0, color(blue) || hist mktv if rdp==1

twoway hist mktv if rdp==1 & h_ch==0, color(blue) || hist mktv if h_ch==1



tab dwell_ch h_cht
reg dwell_ch h_ch h_l i.r, robust
tab roof_ch h_cht
reg roof_ch h_ch h_l i.r, robust
tab walls_ch h_cht
tab toi_ch h_cht
tab toi_shr_ch h_cht

tab rent_ch h_cht
reg rent_ch h_ch h_l, robust
** NOTHIN

tab rent_dum_ch h_cht
reg rent_dum_ch h_ch h_l, robust
** NOTHIN

tab rooms_ch h_cht
reg rooms_ch h_ch h_l
** NOTHIN

tab piped_ch h_cht
reg piped_ch h_ch h_l

tab elec_ch h_cht
reg elec_ch h_ch h_l




tab size_ch h_cht

reg size_ch h_ch
reg size_ch h_l
** PRETTY COOL

reg child_ch h_ch h_l
** big switches in children
reg inf_ch h_ch h_l
tab inf_ch h_cht
** NOT A LOT OF MOVEMENT IN INFORMALITY





reg size_ch


tab h_chl if h_cht==1

tab h_ch1 h_ch

tab owner_ch h_cht
reg owner_ch h_cht, robust

xtset pid
xttrans dwell if h_ch_id==0, t(r)
xttrans dwell if h_ch_id==1, t(r)

tab inf_ch h_ch

xtreg inf rdp

tab water elec
tab dwell dwell_ch

tab dwell_ch h_ch
reg dwell_ch h_ch i.r if fr1==1, robust
reg dwell_ch h_ch i.r if fr1!=1, robust

tab child_ch h_cht
reg child_ch h_ch i.r, robust

reg fr1 h_cht i.r, robust

tab elec_ch piped_ch
tab piped_ch inf_ch

reg piped_ch h_cht

tab fr1 h_cht

tab size_ch elec_ch if h_ch==1
tab size_ch elec_ch if h_ch==0

reg size_ch elec_ch if h_ch==1
reg size_ch elec_ch if h_ch==0


reg inf_ch h_ch i.r, robust

reg size_ch h_ch i.r if size_ch>-4 & size_ch<4, robust


xtset hhid
xtreg out_h hh_sw marry_yrs e child pay flu r_d dec dec_j age edu if r<3, fe robust

reg sr h_ch_sw i.r if r<3

** LOOK FOR DETERMINANTS OF HOUSEHOLD BREAK UP

reg sr piped elec e csg dec_j_id child_d hs u hh_income h_ch_hh  i.r if r!=3, robust cluster(hhid)

* stil works so that's chill
reg sr piped elec e csg dec_j_id child_d hs u hh_income h_ch_sw  i.r if r!=3, robust cluster(hhid)


** 1.) LOOK FOR AGE GRADIENTS WITH CONSUMPTION
** SOFT DRINKS

reg sd_s ln_fd rdp size e m a u child_d i.r , cluster(hhid) robust

xtset pid

xtreg sd_s ln_fd rdp e m u, fe robustj

xtreg sd_s ln_fd rdp size e m u child_d , fe robust

xtreg sd_s ln_fd rdp size e m child_d  if u==1, fe robust
xtreg sd_s ln_fd rdp size e m child_d  if u==0, fe robust

** NOW DO VEGETABLES

reg veg_s_fd hh_income rdp size e m a u child_d i.r, robust


xtreg veg_s_fd hh_income rdp size e m u child_d i.r, fe robust


xtreg veg_s_fd hh_income rdp e m u i.r, fe robust


** CHICKEN

reg chi_s ln_fd rdp e m a u size child_d i.r, cluster(hhid) robust


reg chi_s_fd hh_income rdp e m a u i.r, cluster(hhid) robust


xtreg chi_s ln_fd rdp e m u i.r, fe robust


** READY MADE MEALS

reg rdy_s ln_fd rdp size a u child_d, cluster(hhid) robust

reg out_s ln_fd rdp size a u child_d, cluster(hhid) robust

** 2.) LOOK FOR CHANGES IN DECISIONMAKING POWER WHEN GET RDP

xtreg dec rdp u e, fe robust

xtreg dec rdp u e, fe robust


xtreg dec rdp e i.r if u==1, fe robust

xtreg dec rdp e i.r if u==0, fe robust

xtset pid
xtreg dec_j_id rdp u e m i.r, fe robust




