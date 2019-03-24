

cd "/Users/willviolette/Desktop/pstc_work/nids"



use hh_v1_ghs, clear

*** get rid of rdp_movers (endogenous)
*g move_rdp=rdp*move
*egen move_rdp_max=max(move_rdp), by(hh1)
*drop if move_rdp_max==1
keep if max_inc<20000
* keep if sr==321

g inc_per=inc/size
g inc_l_per=inc_l/size
g inc_r_per=inc_r/size
g remit_per=inc_r/inc
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

replace fees=. if fees==-9
replace fees=0 if fees==1
replace fees=1 if fees==2

replace lratio=. if lratio==-9

foreach var of varlist fees sch_q lratio class_size {
egen `var'_yr=mean(`var') if rdp==1, by(cluster)
egen `var'_nr=mean(`var') if rdp==0, by(cluster)
egen `var'_y=mean(`var'_yr), by(cluster)
egen `var'_n=mean(`var'_nr), by(cluster)
g `var'_dev=`var'_y-`var'_n
}

drop if rdp==.
sort pid r
by pid: g hc=rdp[_n]-rdp[_n-1]
egen hc_min=min(hc), by(pid)
keep if hc_min==-1

*keep if a>18

g rdp_sch_q_dev=rdp*sch_q_dev

g rdp_lratio_dev=rdp*lratio

g rdp_class_size_dev=rdp*class_size

* children ratio
g children_ratio=children/size

xtset pid

xi: xtreg children rdp rdp_sch_q_dev i.r*i.prov, fe robust cluster(hh1)
** not enough observations, but some correlation, which is good

xi: xtreg children_ratio rdp rdp_sch_q_dev i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp rdp_lratio_dev i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children_ratio rdp rdp_lratio_dev i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children rdp rdp_class_size_dev i.r*i.prov, fe robust cluster(hh1)

xi: xtreg children_ratio rdp rdp_class_size_dev i.r*i.prov, fe robust cluster(hh1)





xi: xtreg children rdp i.r*i.prov, fe robust cluster(hh1)




xi: xtreg children rdp class_size rdp_class_size i.r*i.prov, fe robust cluster(hh1)

xi: reg children rdp class_size rdp_class_size i.r*i.prov, robust cluster(hh1)


