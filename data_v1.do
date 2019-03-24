* start from scratch putting the data together

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

* adults

use Adult_W1_Anon_V5.2.dta, clear
renpfix w1_
g r=1
save a1, replace

use Adult_W2_Anon_V2.2.dta, clear
renpfix w2_
g r=2
save a2, replace

use Adult_W3_Anon_V1.2.dta, clear
renpfix w3_
g r=3
save a3, replace

use a1, clear
append using a2
append using a3
sort pid r
save a_v1, replace

* individual derived
use indderived_W1_Anon_V5.2.dta, clear
renpfix w1_
g r=1
save i1, replace

use indderived_W2_Anon_V2.2.dta, clear
renpfix w2_
g r=2
save i2, replace

use indderived_W3_Anon_V1.2.dta, clear
renpfix w3_
g r=3
save i3, replace

use i1, clear
append using i2
append using i3
sort pid r
save i_v1, replace

* households
use HHQuestionnaire_W1_Anon_V5.2.dta, clear
renpfix w1_
g r=1
save h1, replace

use HHQuestionnaire_W2_Anon_V2.2.dta, clear
renpfix w2_
g r=2
save h2, replace

use HHQuestionnaire_W3_Anon_V1.2.dta, clear
renpfix w3_
g r=3
save h3, replace

use h1, clear
append using h2
append using h3
sort hhid r
save h_v1, replace

use hhderived_W1_Anon_V5.2.dta, clear
renpfix w1_
g r=1
save hd1, replace

use hhderived_W2_Anon_V2.2.dta, clear
renpfix w2_
g r=2
save hd2, replace

use hhderived_W3_Anon_V1.2.dta, clear
renpfix w3_
g r=3
save hd3, replace

use hd1, clear
append using hd2
append using hd3
sort hhid r
save hd_v1, replace

use Admin_W1_Anon_V5.2.dta, clear
renpfix w1_
g r=1
save ad1, replace

use Admin_W2_Anon_V2.2.dta, clear
renpfix w2_
g r=2
save ad2, replace

use Admin_W3_Anon_V1.2.dta, clear
renpfix w3_
g r=3
save ad3, replace

use ad1, clear
append using ad2
append using ad3
sort hhid r
save ad_v1, replace

use "Child_W1_Anon_V5.2.dta", clear
renpfix w1_
g r=1
save c1, replace

use "Child_W2_Anon_V2.2.dta", clear
renpfix w2_
g r=2
save c2, replace

use "Child_W3_Anon_V1.2.dta", clear
renpfix w3_
g r=3
save c3, replace

use c1, clear
append using c2
append using c3
sort pid r
save c_v1, replace

use "HouseholdRoster_W1_Anon_V5.2.dta", clear
renpfix w1_
g r=1
save hhr1, replace

use "HouseholdRoster_W2_Anon_V2.2.dta", clear
renpfix w2_
g r=2
save hhr2, replace

use "HouseholdRoster_W3_Anon_V1.2.dta", clear
renpfix w3_
g r=3
save hhr3, replace

use hhr1, clear
append using hhr2
append using hhr3
sort pid r
save hhr_v1, replace

*** now merge everything
use Link_File_W3_Anon_V1.2.dta, clear
renpfix w1_
drop w2_*
drop w3_*
g r=1
save l1, replace

use Link_File_W3_Anon_V1.2.dta, clear
drop w1_*
renpfix  w2_
drop w3_*
g r=2
save l2, replace

use Link_File_W3_Anon_V1.2.dta, clear
drop w1_*
drop w2_*
renpfix w3_
g r=3
save l3, replace

use l1, clear
append using l2
append using l3
save l_v1, replace

use l_v1, clear

merge 1:1 pid r using a_v1 
drop _merge

merge 1:1 pid r using i_v1
drop _merge

merge m:1 hhid r using h_v1
drop _merge

merge m:1 hhid r using hd_v1
drop _merge

merge m:1 pid r using ad_v1
drop _merge

merge m:1 pid r using c_v1
drop _merge

merge m:m pid r using hhr_v1
drop _merge

save data_v1.dta, replace



