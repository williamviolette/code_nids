

cd "/Users/willviolette/Desktop/pstc_work/nids"


*********************
** PARALLEL TRENDS **
*********************

use hh_v1, clear

g move_rdp=rdp*move
egen move_rdp_max=max(move_rdp), by(hh1)
drop if move_rdp_max==1
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1


sort pid r
by pid: g house_ch=house[_n]-house[_n-1]
by pid: g piped_ch=piped[_n]-piped[_n-1]
by pid: g flush_ch=flush[_n]-flush[_n-1]
by pid: g rooms_ch=rooms[_n]-rooms[_n-1]
by pid: g bkyd_ch=bkyd[_n]-bkyd[_n-1]
by pid: g roof_cor_ch=roof_cor[_n]-roof_cor[_n-1]
by pid: g walls_b_ch=walls_b[_n]-walls_b[_n-1]

g rdpp=(bkyd_ch!=0 & piped_ch!=0 & flush_ch!=0 & rooms_ch!=0 & move==0 & rdp==0)
sort pid r
by pid: replace rdpp=1 if rdpp[_n-1]==1 & rdpp[_n]==0
drop *_ch

* drop rdp_ch
sort pid r
by pid: g rdp_ch=rdp[_n+1]-rdp[_n]
sort pid r
by pid: g rdpp_ch=rdpp[_n+1]-rdpp[_n]

sort pid r
foreach var of varlist  a size af children edu inc piped elec rooms {
by pid: g `var'_ch=`var'[_n]-`var'[_n-1]
drop `var'
rename `var'_ch `var'
}
replace inc=ln(inc+1)

keep rdpp_ch rdp_ch a size children edu inc piped elec rooms u r hh1
collapse a size children edu inc piped elec rooms, by(u r hh1 rdp_ch rdpp_ch)
keep if r==2

reg rdp_ch a size children edu inc piped elec u, robust cluster(hh1)

reg rdp_ch a size children edu inc piped elec if u==1, robust cluster(hh1)

reg rdp_ch a size children edu inc piped elec if u==0, robust cluster(hh1)

* ln(income) solves my balance issues


reg rdpp_ch a size children edu inc piped elec if u==1, robust cluster(hh1)

reg rdpp_ch a size children edu inc piped elec if u==0, robust cluster(hh1)


*outreg2 using ptrends, label excel replace 


