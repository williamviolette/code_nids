
cd "/Users/willviolette/Desktop/pstc_work/nids"

use "HouseholdRoster_W1_Anon_V5.2.dta", clear
renpfix w1_
renpfix r_
keep pid hhid relhead pres absm
sort pid hhid
g r=1
save "hoh1.dta", replace

use "HouseholdRoster_W2_Anon_V2.2.dta", clear
renpfix w2_
renpfix r_
keep pid hhid relhead pres absm
sort pid hhid
g r=2
save "hoh2.dta", replace


use "HouseholdRoster_W3_Anon_V1.2.dta", clear
renpfix w3_
renpfix r_
keep pid hhid relhead pres absm
sort pid hhid
g r=3
save "hoh3.dta", replace

use hoh1, clear
append using hoh2
append using hoh3
sort pid r
save hoh.dta, replace


