* start from scratch putting the data together

clear all
set mem 4g
set maxvar 10000


cd "${rawdata}"


cap prog drop a_save
prog define a_save
	use `2'_W`3'_Anon_`4'.dta, clear
	renpfix w`3'_
	g r=`3'
	save clean/`1'`3', replace
end

cap  prog drop cleaning
program define cleaning

	a_save `1' `2' 1 "V5.2" 
	a_save `1' `2' 2 "V2.2" 
	a_save `1' `2' 3 "V1.2" 
	a_save `1' `2' 4 "V2.0.0" 
	a_save `1' `2' 5 "V1.0.0" 

	use clean/`1'1, clear
	forvalues r=2/5 {
	quietly append using clean/`1'`r'
	}
	sort `3' r
	save clean/`1'_v1, replace

	forvalues r=1/5 {
		erase clean/`1'`r'.dta
	}
end


cleaning a Adult pid
cleaning i indderived pid
cleaning h HHQuestionnaire hhid
cleaning hd hhderived hhid
cleaning ad Admin hhid
cleaning c Child pid
cleaning hhr HouseholdRoster pid

	
cap prog drop lf
prog define lf
	use Link_File_W5_Anon_V1.0.0.dta, clear
	keep pid csm sample wave_died cluster w`1'_*
	renpfix w`1'_
	g r=`1'
	save clean/l`1', replace
end 

forvalues r=1/5 {
	lf `r'
}

use clean/l1, clear
forvalues r = 2/5 {
	quietly append using clean/l`r'
}
save clean/l_v1, replace

forvalues r=1/5 {
	erase clean/l`r'.dta
}


use clean/l_v1, clear
	merge 1:1 pid hhid r using clean/a_v1 
	drop _merge
	merge 1:1 pid hhid r using clean/i_v1
	drop _merge
	merge m:1 hhid r using clean/h_v1
	drop _merge
	merge m:1 hhid r using clean/hd_v1
	drop _merge
	merge m:1 pid hhid r using clean/ad_v1
	drop _merge
	merge m:1 pid hhid r using clean/c_v1
	drop _merge
	merge m:m pid hhid r using clean/hhr_v1
	drop _merge

	drop if best_gen==.                     /* KEY : GET RID OF ALL THE MISSING PEOPLE!! */
save clean/data_v1.dta, replace



		erase clean/a_v1.dta
		erase clean/i_v1.dta
		erase clean/h_v1.dta
		erase clean/hd_v1.dta
		erase clean/ad_v1.dta
		erase clean/c_v1.dta
		erase clean/hhr_v1.dta






