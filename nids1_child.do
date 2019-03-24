* children in nids

cd "/Users/willviolette/Desktop/pstc_work/nids"

use "Child_W1_Anon_V5.2.dta", clear

g w1_c_edtrntime_m=.

* keep w1_c_grcur w1_c_grcurtyp w1_c_grcurecpc w1_c_grcurecr w1_c_grcurecpid w1_c_grcur_m w1_c_grcur_y w1_c_grpst w1_c_grpststrt_m w1_c_grpststrt_y w1_c_grpststp_m w1_c_grpststp_y w1_c_grapp w1_c_dob_m w1_c_dob_y w1_hhid pid  w1_c_edtrn1 w1_c_ed07spnfee w1_c_ed07spnuni w1_c_ed07spnbks w1_c_ed07spntrn w1_c_ed07spno w1_c_ed07payr1 w1_c_ed07paypid1 w1_c_ed07payr2 w1_c_ed07paypid2 w1_c_ed08curgrd w1_c_edatt w1_c_edcmpgrd w1_c_edrep w1_c_edrep1 w1_c_edtrntime w1_c_edtrntime_m w1_c_hlthdes
* order w1_c_grcur w1_c_grcurtyp w1_c_grcurecpc w1_c_grcurecr w1_c_grcurecpid w1_c_grcur_m w1_c_grcur_y w1_c_grpst w1_c_grpststrt_m w1_c_grpststrt_y w1_c_grpststp_m w1_c_grpststp_y w1_c_grapp w1_c_dob_m w1_c_dob_y w1_hhid pid  w1_c_edtrn1 w1_c_ed07spnfee w1_c_ed07spnuni w1_c_ed07spnbks w1_c_ed07spntrn w1_c_ed07spno w1_c_ed07payr1 w1_c_ed07paypid1 w1_c_ed07payr2 w1_c_ed07paypid2 w1_c_ed08curgrd w1_c_edatt w1_c_edcmpgrd w1_c_edrep w1_c_edrep1 w1_c_edtrntime w1_c_edtrntime_m w1_c_hlthdes

replace w1_c_edtrntime=w1_c_edtrntime/60 if w1_c_edtrntime>=0

sort pid 
save "child1.dta", replace

use "Child_W2_Anon_V2.2.dta", clear


rename w2_c_ed09spnfee  w2_c_ed07spnfee
rename w2_c_ed09spnuni  w2_c_ed07spnuni
rename w2_c_ed09spnbks  w2_c_ed07spnbks 
rename w2_c_ed09spntrn  w2_c_ed07spntrn 
rename w2_c_ed09spno w2_c_ed07spno 
rename w2_c_ed09pay w2_c_ed07pay 
rename w2_c_ed09paypid1 w2_c_ed07paypid1 
rename w2_c_ed09paypr1 w2_c_ed07payr1 
rename w2_c_ed09paypid2 w2_c_ed07paypid2 
rename w2_c_ed09paypr2 w2_c_ed07payr2
*g w2_c_dob_m=.
* g w2_c_dob_y=.


rename w2_c_ed08res w2_c_edrep
rename w2_c_ede08wdexp w2_c_edrep1

* keep w2_hhid pid   w2_c_ed07spnfee w2_c_ed07spnuni w2_c_ed07spnbks w2_c_ed07spntrn w2_c_ed07spno w2_c_ed07payr1 w2_c_ed07paypid1 w2_c_ed07payr2 w2_c_ed07paypid2 w2_c_ed10curgrd w2_c_edatt w2_c_edcmpgrd w2_c_edrep w2_c_edrep1 w2_c_edtrntime_hrs w2_c_edtrntime_min w2_c_hlthdes
* order w2_hhid pid   w2_c_ed07spnfee w2_c_ed07spnuni w2_c_ed07spnbks w2_c_ed07spntrn w2_c_ed07spno w2_c_ed07payr1 w2_c_ed07paypid1 w2_c_ed07payr2 w2_c_ed07paypid2 w2_c_ed10curgrd w2_c_edatt w2_c_edcmpgrd w2_c_edrep w2_c_edrep1 w2_c_edtrntime_hrs w2_c_edtrntime_min w2_c_hlthdes

rename w2_c_edtrntime_hrs w2_c_edtrntime
rename w2_c_edtrntime_min w2_c_edtrntime_m

rename w2_c_ed10curgrd w2_c_ed08curgrd

sort pid
save "child2.dta", replace


use "Child_W3_Anon_V1.2.dta", clear

rename w3_c_ed11spnfee  w3_c_ed07spnfee
rename w3_c_ed11spnuni  w3_c_ed07spnuni
rename w3_c_ed11spnbks  w3_c_ed07spnbks 
rename w3_c_ed11spntrn  w3_c_ed07spntrn 
rename w3_c_ed11spno w3_c_ed07spno 
rename w3_c_ed11pay w3_c_ed07pay 
rename w3_c_ed11paypid1 w3_c_ed07paypid1 
rename w3_c_ed11paypr1 w3_c_ed07payr1 
rename w3_c_ed11paypid2 w3_c_ed07paypid2 
rename w3_c_ed11paypr2 w3_c_ed07payr2 
* g w3_c_dob_m=.
* g w3_c_dob_y=.

rename w3_c_ed10res w3_c_edrep
rename w3_c_ed10wdexp w3_c_edrep1

* keep w3_hhid pid   w3_c_ed07spnfee w3_c_ed07spnuni w3_c_ed07spnbks w3_c_ed07spntrn w3_c_ed07spno w3_c_ed07payr1 w3_c_ed07paypid1 w3_c_ed07payr2 w3_c_ed07paypid2 w3_c_ed12curgrd w3_c_edatt w3_c_edcmpgrd w3_c_edrep w3_c_edrep1 w3_c_edtrntime_hrs w3_c_edtrntime_min w3_c_hlthdes
* order w3_hhid pid   w3_c_ed07spnfee w3_c_ed07spnuni w3_c_ed07spnbks w3_c_ed07spntrn w3_c_ed07spno w3_c_ed07payr1 w3_c_ed07paypid1 w3_c_ed07payr2 w3_c_ed07paypid2 w3_c_ed12curgrd w3_c_edatt w3_c_edcmpgrd w3_c_edrep w3_c_edrep1 w3_c_edtrntime_hrs w3_c_edtrntime_min w3_c_hlthdes

rename w3_c_edtrntime_hrs w3_c_edtrntime
rename w3_c_edtrntime_min w3_c_edtrntime_m

rename w3_c_ed12curgrd w3_c_ed08curgrd

sort pid
save "child3.dta", replace



forvalues r=1/3 {
use Link_File_W3_Anon_V1.2.dta, clear
sort pid
merge pid using child`r'
keep if _merge==3

rename w`r'_hhid hhid


rename w`r'_c_grcur grcur
rename w`r'_c_grcurtyp grcurtyp
* rename w`r'_c_grcurecpc grcurecpc
rename w`r'_c_grcurecr grcurecr
rename w`r'_c_grcurecpid grcurecpid 
rename w`r'_c_grcur_m grcur_m 
rename w`r'_c_grcur_y grcur_y
rename w`r'_c_grpst grpst
rename w`r'_c_grpststrt_m grpststrt_m
rename w`r'_c_grpststrt_y grpststrt_y
rename w`r'_c_grpststp_m grpststp_m
rename w`r'_c_grpststp_y grpststp_y
rename w`r'_c_grapp grapp


rename w`r'_c_ed08curgrd grade
rename w`r'_c_edatt attend
rename w`r'_c_edcmpgrd grade_max
rename w`r'_c_edrep edu_res
rename w`r'_c_edrep1 edu_rep
rename w`r'_c_edtrntime d_sch_hrs
rename w`r'_c_edtrntime_m d_sch_min
rename w`r'_c_hlthdes ch_health

rename w`r'_c_ed07spnfee spnfee
rename w`r'_c_ed07spnuni spnuni
rename w`r'_c_ed07spnbks spnbks
rename w`r'_c_ed07spntrn spntrn
rename w`r'_c_ed07spno spno
rename w`r'_c_ed07payr1 payr1
rename w`r'_c_ed07paypid1 paypid1
rename w`r'_c_ed07payr2 payr2
rename w`r'_c_ed07paypid2 paypid2

rename w`r'_c_dob_m dob_m
rename w`r'_c_dob_y dob_y


g r=`r'

keep  hhid pid r grade attend grade_max edu_res edu_rep d_sch_hrs d_sch_min ch_health spnfee spnuni spnbks spntrn spno payr1 paypid1 payr2 paypid2 grcur grcurtyp grcurecr grcurecpid grcur_m grcur_y grpst grpststrt_m grpststrt_y grpststp_m grpststp_y grapp
order hhid pid r grade attend grade_max edu_res edu_rep d_sch_hrs d_sch_min ch_health spnfee spnuni spnbks spntrn spno payr1 paypid1 payr2 paypid2 grcur grcurtyp grcurecr grcurecpid grcur_m grcur_y grpst grpststrt_m grpststrt_y grpststp_m grpststp_y grapp

save child`r'1.dta, replace
}


use child11.dta, clear
append using child21.dta
append using child31.dta
sort hhid
save child.dta, replace





