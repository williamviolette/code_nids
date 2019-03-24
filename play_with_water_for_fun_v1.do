cd "/Users/willviolette/Desktop/pstc_work/nids"


use hh_v1_ghs, clear


replace h_toi=. if h_toi<0 | h_toi==9

g pit=(h_toi==4 | h_toi==5)
g chem=h_toi==3
g bucket=h_toi==6

g pub_tap=h_watsrc==3
g open_w=(h_watsrc==8 | h_watsrc==9)

keep if sr==321
drop if prov==10
keep if hh_outcome==1 & ind_outcome==1

replace mktv=. if mktv>100000
egen mktv_max=max(mktv), by(pid)
drop if mktv_max==.

replace rooms=. if rooms>10
egen rooms_max=max(rooms), by(pid)
drop if rooms_max==.

keep if max_inc<15000

sort pid r
g piped_ch=piped[_n]-piped[_n-1]
g flush_ch=flush[_n]-flush[_n-1]
g mktv_ch=mktv[_n]-mktv[_n-1]

replace move=0 if r==1

egen max_inf=max(inf), by(pid)

egen max_a=max(a), by(pid)

egen max_move=max(move), by(pid)

xtset pid


**************
** HEDONICS **
**************

*** HARD TO FIGURE OUT

keep if move==0

egen max_piped_ch=max(piped_ch)

egen pc=sum(max_piped_ch), by(cluster)

collapse piped_ch pc, by(r cluster)

keep if pc>282

separate piped_ch, by(pc) g(pc_)

twoway scatter pc_* r





xtreg mktv house bkyd inf piped pub_tap open_w flush pit chem bucket rooms roof_cor walls_b rdp move i.r, robust fe cluster(hh1)

xi: xtreg mktv house bkyd inf piped pub_tap open_w flush pit chem bucket rooms roof_cor walls_b rdp move i.r*i.prov, robust fe cluster(hh1)


xi: xtreg mktv house bkyd inf piped pub_tap open_w flush pit chem bucket rooms roof_cor walls_b rdp move i.r*i.prov if u==1 & tt!=., robust fe cluster(hh1)

xi: xtreg mktv house bkyd inf piped pub_tap open_w flush pit chem bucket rooms roof_cor walls_b rdp move i.r*i.prov if u==0, robust fe cluster(hh1)


g move_rdp=move*rdp

xi: xtreg mktv rdp move move_rdp size inc children e i.r*i.prov if tt!=., fe robust




xtreg mktv house bkyd inf piped flush rooms roof_cor walls_b rdp i.r if move==1, robust fe cluster(hh1)

xtreg mktv house bkyd inf piped flush rooms roof_cor walls_b rdp i.r if move==0, robust fe cluster(hh1)


xi: xtreg mktv piped flush i.rooms rdp move i.r*i.prov, robust fe cluster(hh1)

xi: xtreg mktv piped flush rooms rdp move i.r*i.prov if mktv<50000 & u==1, robust fe cluster(hh1)

xi: xtreg mktv piped flush rooms rdp move i.r*i.prov if mktv<50000 & u==1, robust fe cluster(hh1)




reg mktv_ch piped_ch flush_ch move, robust

tab piped_ch flush_ch


tab h_ch piped_ch 

tab move piped_ch 

tab u piped_ch

tab a piped_ch






** ARE PEOPLE SWITCHING OUT OF INFORMAL SETTLEMENTS DRIVING MY RESULTS?

g rdp_inf=rdp*inf

** maybe the problem is that my sample is pretty seriously restricted
*** which is causing problems with my size results
*** not huge heterogeneity by informal settlements which seems kind of weird

xi: xtreg size rdp i.r*i.prov if max_move==0 & max_inf==1 & tt!=., fe robust cluster(hh1)
xi: xtreg size rdp i.r*i.prov if max_move==0 & max_inf==0 & tt!=., fe robust cluster(hh1)
* why the hell am I getting negative? well, that actually makes kind of more sense

xi: xtreg children rdp i.r*i.prov if max_inf==1 & tt!=. & max_move==0, fe robust cluster(hh1)
xi: xtreg children rdp i.r*i.prov if max_inf==0 & tt!=. & max_move==0, fe robust cluster(hh1)
* nothing for children... : why am I geting this now? because I got rid of outliers?

xi: xtreg e rdp i.r*i.prov if max_inf==1 & tt!=. & max_move==0 & sex==1, fe robust cluster(hh1)
xi: xtreg e rdp i.r*i.prov if max_inf==0 & tt!=. & max_move==0 & sex==1, fe robust cluster(hh1)
* not much for employment

xi: xtreg edu rdp i.r*i.prov if max_inf==1 & max_a>6 & max_a<17 & tt!=. & max_move==0, fe robust cluster(hh1)
** driven by informal settlements **
xi: xtreg edu rdp i.r*i.prov if max_inf==1 & max_a>6 & max_a<17 & tt!=. & max_move==0, fe robust cluster(hh1)

xi: xtreg c_ill rdp i.r*i.prov if max_inf==1 & max_a>6 & max_a<17  & tt!=. & max_move==0, fe robust cluster(hh1)
xi: xtreg c_ill rdp i.r*i.prov if max_inf==0 & max_a>6 & max_a<17 & tt!=. & max_move==0, fe robust cluster(hh1)
** very robust

xi: xtreg c_health rdp i.r*i.prov if max_inf==1 & max_a>6 & max_a<17  & tt!=. & max_move==0, fe robust cluster(hh1)
xi: xtreg c_health rdp i.r*i.prov if max_inf==0 & max_a>6 & max_a<17 & tt!=. & max_move==0, fe robust cluster(hh1)



