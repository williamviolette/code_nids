
cd "/Users/willviolette/Desktop/pstc_work/ghs"


use psu, clear

format psu_no_m %18.0g

** PSU MERGE
rename psu_no_m psu
replace psu=psu*1000
** SUB-PLACE MERGE
*rename sp_code2011 sp_code

rename sp_name2011 sp_name
replace sp_name="Amahwaqa" if sp_name=="Amahwaqa SP"	
replace sp_name="Glencoe NU" if sp_name=="Glencoe SP"

sort sp_name

save sp_merge, replace

** NEW MERGE
****** SWAP IT TO THE OTHER
 use subplace, clear
*  use joined_data, clear
  destring near_dist, replace
  format near_dist %16.0g
sort sp_name
merge sp_name using sp_merge
tab _merge
keep if _merge==3
drop _merge
sort psu
save psu_merge, replace

use "09_13_analysis_t.dta", clear

sort psu

merge psu using psu_merge
drop if _merge==2
tab _merge
drop _merge

rename chld5yr_hh c5
rename chld17yr_hh c17
g u=(GeoType<2)

* * START DISTANCE ANALYSIS


** ARE FULL FAMILIES MOVING INTO THESE HOUSES OR NOT?!
g s=.
replace s=sal*4 if sal_p==1
replace s=sal if sal_p==2
replace s=sal/12 if sal_p==3

g inf=(dwell==8 | dwell==9)
g wl_c1=0
g wl_c2=0
g wl_c3=0

forvalues r=2009(1)2013 {
replace wl_c1=1 if wl_yr>`r'-9 & wl_yr<=`r'-3 & year==`r'
replace wl_c2=1 if wl_yr>`r'-14 & wl_yr<=`r'-9 & year==`r'
replace wl_c3=1 if wl_yr>`r'-19 & wl_yr<=`r'-14 & year==`r'
}

forvalues r=1/3 {
g t`r'=.
replace t`r'=1 if h_a==`r' & rdp_s==1
replace t`r'=0 if wl_c`r'==1 & rdp_s==0
}

g e12=edu if edu<=12
replace edu=. if edu==99

tab Race t1 if u==1
tab Race t1 if u==0

tab Race t2 if u==1
tab Race t2 if u==0

reg african t1 i.year if u==1, cluster(psu) robust 
reg african t1 i.year if u==0, cluster(psu) robust 

reg african t2 i.year if u==1, cluster(psu) robust 
reg african t2 i.year if u==0, cluster(psu) robust 

reg african t3 i.year if u==1, cluster(psu) robust 
reg african t3 i.year if u==0, cluster(psu) robust



g sh=.
replace sh=1 if rdp_s==1 & rdp_h==1
replace sh=0 if rdp_s==1 & rdp_h==0
egen tk=mean(sh), by(psu year)
replace tk=. if tk==0

reg tk near_dist i.year if u==1, robust cluster(psu)
reg tk near_dist i.year if u==0, robust cluster(psu)
* LOWER TAKE-UP CLOSE TO CITIES

g t1_near_dist=t1*near_dist
g t2_near_dist=t2*near_dist
g t3_near_dist=t3*near_dist

reg african t1 near_dist t1_near_dist i.year if u==1, cluster(psu) robust 
reg african t1 near_dist t1_near_dist i.year if u==0, cluster(psu) robust 

reg african t2 near_dist t2_near_dist i.year if u==1, cluster(psu) robust 
reg african t2 near_dist t2_near_dist i.year if u==0, cluster(psu) robust 

g t=1 if t1!=.
replace t=2 if t2!=.
replace t=3 if t3!=.

g rdp=(t1==1 | t2==1 | t3==1)
g rdp_near_dist=rdp*near_dist


reg african rdp near_dist rdp_near_dist i.year i.t u, cluster(psu) robust 
reg african rdp near_dist rdp_near_dist i.year i.t if u==1, cluster(psu) robust 
reg african rdp near_dist rdp_near_dist i.year i.t if u==0, cluster(psu) robust 

foreach var of varlist inc_c tog s hung gard hholdsz e_wage e_sal remit commute {
reg `var' rdp near_dist rdp_near_dist i.year i.t u, cluster(psu) robust 
reg `var' rdp near_dist rdp_near_dist i.year i.t if u==1, cluster(psu) robust 
reg `var' rdp near_dist rdp_near_dist i.year i.t if u==0, cluster(psu) robust 
}

* * * distance really doesn't work ! ! ! WHY?




* * * selection is happening in urban areas! mostly in later years

* WHAT CHANGES IN A PLACE TO CAUSE GREATER TAKE UP

