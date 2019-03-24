
cd "/Users/willviolette/Desktop/pstc_work/nids"

*clear all
*insheet using Table_EA2011_PSU.csv
*rename psu_no_m psu
*replace psu=psu*1000
*save psu.dta, replace

***********************
** GHS LINK BY ROUND **
***********************
use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

g r=1 if year==2009
replace r=2 if year==2010 | year==2011
replace r=3 if year==2012 | year==2013

* get rid of old houses
* drop if h_age>3

*** TAKE-UP MEASURES
** now many new rdp's ?
g rdp_s_new=1 if rdp_s==1 & h_age==1
g rdp_h_new=1 if rdp_h==1 & h_age==1

g rdp_s_tot=1 if rdp_s==1
g rdp_h_tot=1 if rdp_h==1

** measure of total waitlist
g wl_new=1 if wl==1 & wl_yr>=year-2

** what is the average commuting time of new rdp's?
*** look at this commuting time relative to overall average commuting time
g rdp_commute=commute if rdp_h==1

g wl_commute=commute if wl==1

** what is the average number of rooms for new rdp's?
g rdp_rooms=rooms if rdp_s==1
g rdp_rooms_new=rooms if rdp_s==1 & h_age<4

** measure of total population
g pop=1

** wages for rdp
g rdp_e_wage=e_wage if rdp_s==1

** income for rdp
g rdp_inc_c=inc_c if rdp_s==1

** TAKE UP
g rdp_s_rdp_h=(rdp_s==1 & rdp_h==1)
egen rdp_s_rdp_h_sum=sum(rdp_s_rdp_h), by(mdb r)
egen rdp_h_sum=sum(rdp_h), by(mdb r)
g tk=rdp_s_rdp_h_sum/rdp_h_sum

collapse (median) wl_yr (sum) wl_new rdp_s_new rdp_h_new pop rdp_s_tot rdp_h_tot (mean) e_wage rdp_e_wage rooms h_age wl_commute rdp_commute rdp_rooms rdp_rooms_new wl rdp_s rdp_h tog sal african commute rdp_inc_c inc_c ben tk, by(r mdb)

rename african african_g
rename rooms rooms_g
rename tog tog_g

label variable wl_yr "Median Waitlist Year"
label variable wl_new "Waitlist New"
label variable rdp_s_new "RDP Subsidy New"
label variable rdp_h_new "RDP House New"
label variable pop "Population"
label variable rdp_s_tot "Total RDP Subsidy"
label variable rdp_h_tot "Total RDP Houses"
label variable e_wage "Average Wage"
label variable rdp_e_wage "Average Wage for RDP"
label variable rooms_g "Average Rooms"
label variable h_age "Average Age of All Houses"
label variable wl_commute "Average Commute for those on Waitlist"
label variable rdp_commute "Average Commute for RDP Houses"
label variable rdp_rooms "Average Rooms for RDP Subsidies"
label variable rdp_rooms_new "Average Rooms for new RDP Subsidies"
label variable wl "Average number on waitlist"
label variable rdp_s "Average RDP Subsidies"
label variable rdp_h "Average RDP Houses"
label variable tog_g "Average Relationship Status"
label variable sal "Average Salary"
label variable african_g "Average number of Africans"
label variable commute "Average Commute"
label variable rdp_inc_c "Average RDP Subsidy Income"
label variable inc_c "Average income"
label variable ben "Average Number of Original Beneficiaries Living in RDP Houses"
label variable tk "Take-up measured by subsidy recipients actually living in RDP houses"

save ghs_link_r.dta, replace


use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

g r=1 if year==2009
replace r=2 if year==2010 | year==2011
replace r=3 if year==2012 | year==2013

* get rid of old houses
* drop if h_age>3

*** TAKE-UP MEASURES
** now many new rdp's ?
g rdp_s_new=1 if rdp_s==1 & h_age==1
g rdp_h_new=1 if rdp_h==1 & h_age==1

g rdp_s_tot=1 if rdp_s==1
g rdp_h_tot=1 if rdp_h==1

** measure of total waitlist
g wl_new=1 if wl==1 & wl_yr>=year-2

** what is the average commuting time of new rdp's?
*** look at this commuting time relative to overall average commuting time
g rdp_commute=commute if rdp_h==1

g wl_commute=commute if wl==1

** what is the average number of rooms for new rdp's?
g rdp_rooms=rooms if rdp_s==1
g rdp_rooms_new=rooms if rdp_s==1 & h_age<4

** measure of total population
g pop=1

** wages for rdp
g rdp_e_wage=e_wage if rdp_s==1

** income for rdp
g rdp_inc_c=inc_c if rdp_s==1

** TAKE UP
g rdp_s_rdp_h=(rdp_s==1 & rdp_h==1)
egen rdp_s_rdp_h_sum=sum(rdp_s_rdp_h), by(mdb r)
egen rdp_h_sum=sum(rdp_h), by(mdb r)
g tk=rdp_s_rdp_h_sum/rdp_h_sum

collapse (median) wl_yr (sum) wl_new rdp_s_new rdp_h_new pop rdp_s_tot rdp_h_tot (mean) e_wage rdp_e_wage rooms h_age wl_commute rdp_commute rdp_rooms rdp_rooms_new wl rdp_s rdp_h tog sal african commute rdp_inc_c inc_c ben tk, by(mdb)

rename african african_g
rename rooms rooms_g
rename tog tog_g

label variable wl_yr "Median Waitlist Year"
label variable wl_new "Waitlist New"
label variable rdp_s_new "RDP Subsidy New"
label variable rdp_h_new "RDP House New"
label variable pop "Population"
label variable rdp_s_tot "Total RDP Subsidy"
label variable rdp_h_tot "Total RDP Houses"
label variable e_wage "Average Wage"
label variable rdp_e_wage "Average Wage for RDP"
label variable rooms_g "Average Rooms"
label variable h_age "Average Age of All Houses"
label variable wl_commute "Average Commute for those on Waitlist"
label variable rdp_commute "Average Commute for RDP Houses"
label variable rdp_rooms "Average Rooms for RDP Subsidies"
label variable rdp_rooms_new "Average Rooms for new RDP Subsidies"
label variable wl "Average number on waitlist"
label variable rdp_s "Average RDP Subsidies"
label variable rdp_h "Average RDP Houses"
label variable tog_g "Average Relationship Status"
label variable sal "Average Salary"
label variable african_g "Average number of Africans"
label variable commute "Average Commute"
label variable rdp_inc_c "Average RDP Subsidy Income"
label variable inc_c "Average income"
label variable ben "Average Number of Original Beneficiaries Living in RDP Houses"
label variable tk "Take-up measured by subsidy recipients actually living in RDP houses"

foreach var of varlist * {
rename `var' `var'_t
}
rename mdb_t mdb

save ghs_link_t.dta, replace


