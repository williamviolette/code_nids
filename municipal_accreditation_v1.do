
cd "/Users/willviolette/Desktop/pstc_work/ghs"


clear all
set mem 5g
use g2, clear
forvalues r=9/13 {
append using g`r'
}

merge m:m psu using psu
keep if _merge==3

g rdp1=.
foreach var of varlist *subs {
replace rdp1=`var' if `var'!=.
}

g rdp=rdp1==1
replace rdp=. if rdp1==9
replace rdp=. if rdp1==3

save ma, replace



use ma, clear
