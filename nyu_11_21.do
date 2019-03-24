

cd "/Users/willviolette/Desktop/pstc_work/nids"

* make the argument:

* * different impacts based on rural and urban:

* we want that income per person doesn't change, can we get at mechanisms of that?

use hh_v1, clear
keep if tt!=.
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

g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

* if you're hh member gets a house far away
* what is your likelihood to also move
keep if left_in==1 | left_out==1
collapse (max) left_in_m left_in_n left_in left_out_m left_out_n left_out u, by(hh1 r)

reg left_out_m left_in_m i.r, robust
reg left_out_m left_in_m i.r if u==1, robust
reg left_out_m left_in_m i.r if u==0, robust
* doesn't depend on urban

* * check balance depending on these two outcomes




*** NOW WE HAVE TWO DIFFERENT TREATMENTS!!
use hh_v1, clear
keep if max_inc<10000
keep if sr==321

hist own_d, by(stayer h_ch)
* not terrible
hist rooms if rooms<9, by(stayer h_ch)
hist mktv if mktv<40000, by(stayer h_ch)

hist rooms if rooms<9, by(stayer h_ch u)



*** 1. SIZE
use hh_v1, clear
keep if max_inc<10000
keep if sr==321


* left out
egen m_rdp=mean(rdp), by(hh1 r)
gen left_out=(m_rdp>0 & m_rdp<1 & rdp==0)
* left in
gen left_in=(m_rdp>0 & m_rdp<1 & rdp==1)
replace rdp=0 if left_in==1

hist rooms if rooms<9, by(left_in left_out stayer)


** can we vary the treatment according to move?!

tab h_ch stayer

tab left_in stayer
tab left_out stayer
* * equivalent?!?!?!

tab inf stayer if left_out==1
tab inf stayer if left_in==1
* * movers way more likely to live in an informal settlement
* * stayers are way less likely to live in an informal settlement

tab h_ch stayer if r<3

g h_g=h_ch==1




collapse (max) h_g stayer (mean) e_hh tsm size theft domvio vio gang murder drug a sex children edu e ue own paid_off rooms rent elec piped flush mktv walls_b roof_cor exp exp_i exp_f fwag cwag swag sch_d travel tog marry inf house inc inc_r inc_l inc_g rdp u hrs, by(r hh1)

tab stayer h_g

g r1=r if r==1
replace r1=r*10 if r==2
replace r1=r*100 if r==3
egen sr=sum(r1), by(hh1)
* full panel
keep if sr==321

g rent_d=(rent>0 & rent<.)

reg size own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc i.r, robust cluster(hh1) 
reg size theft domvio vio gang murder drug own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc i.r, robust cluster(hh1) 

xtset hh1

xtreg size own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
xtreg size theft domvio vio gang murder drug  own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
* services operate as you might expect

sort hh1 r
by hh1: g size_lead=size[_n+1]
by hh1: g size_lag=size[_n-1]

xtreg size_lead own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
xtreg size_lead own elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust

xtreg size_lag own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
xtreg size_lag theft domvio vio gang murder drug  own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
* now dom violence stands out
* ownership current decreases size, but future increases size

reg size own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc i.r, robust cluster(hh1) 
reg size theft domvio vio gang murder drug own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc i.r, robust cluster(hh1) 

xtset hh1

xtreg size own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust
xtreg size theft domvio vio gang murder drug  own rooms elec piped flush walls_b roof_cor house inf u a sex e ue inc rdp i.r, fe robust


* don't have a great measure of employment: can only look at equilibrium outcomes

* neighborhood effects as well as proxy for employment : ownership
 * if you switch out of owning, you're household gets bigger
 * makes sense? dig into this owning thing more!
 * after controlling for everything, RDP doesn't stand out!
 	* WHAT DO WE MAKE OF THAT?

*** 2. CHILDREN controlling for size

*** 3. INTERVIEWED ADULTS MEASURED ADULTS ( don't keep only TSMs )


*** 2.) UNDERSTANDING THE SHOCK AND HOW IT IMPACTS SIZE DIFFERENTLY
***               USING MULTIPLE MEASURES OF SIZE




