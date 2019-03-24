

cd "/Users/willviolette/Desktop/pstc_work/nids"

use "Admin_W1_Anon_V5.2.dta", clear
renpfix w1_
keep hhid pid edlstm_schcd edlstm_prov edlstm_quin edlstm_phase edlstm_nofee edlstm_exdept
g r=1
sort pid hhid r
save "school_r1.dta", replace


use "Admin_W2_Anon_V2.2.dta", clear
renpfix w2_
keep hhid pid edlstm_schcd edlstm_prov edlstm_quin edlstm_phase edlstm_nofee edlstm_exdept
g r=2
sort pid hhid r
save "school_r2.dta", replace


use "Admin_W3_Anon_V1.2.dta", clear
renpfix w3_
keep hhid pid edlstm_schcd edlstm_prov edlstm_quin edlstm_phase edlstm_nofee edlstm_exdept
g r=3
sort pid hhid r
save "school_r3.dta", replace

use school_r1, clear
append using school_r2
append using school_r3
sort pid r
save "school.dta", replace

* test merge

use school_r1, clear
sort edlstm_schcd
save school_test.dta, replace

use school_r2, clear
sort edlstm_schcd
merge edlstm_schcd using school_test
tab _merge
