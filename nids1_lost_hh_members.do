cd "/Users/willviolette/Desktop/pstc_work/nids"

forvalues r=1/3 {
use Link_File_W3_Anon_V1.2.dta, clear

g tsm=csm==2

egen tsm_tot=sum(tsm), by(w`r'_hhid)

rename w`r'_hhid hhid
duplicates drop hhid, force

keep hhid tsm_tot
g r=`r'
save tsm`r', replace
}

use tsm1, clear
append using tsm2
append using tsm3
sort hhid
save tsm, replace



