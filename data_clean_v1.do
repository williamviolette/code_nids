* start from scratch putting the data together

clear all
set mem 4g
set maxvar 10000

cd "/Users/willviolette/Desktop/pstc_work/nids"

program define main
	adult_cleaning
	individual_cleaning
	household_cleaning
	household_derived_cleaning
	admin_cleaning
	child_cleaning
	roster_cleaning
	merge_file
	merging
end

program define adult_cleaning
	use Adult_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/a1, replace
	use Adult_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/a2, replace
	use Adult_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/a3, replace
	use clean/a1, clear
	quietly append using clean/a2
	quietly append using clean/a3
	sort pid r
	save clean/a_v1, replace
end

program define individual_cleaning
	use indderived_W1_Anon_V5.2.dta, clear	
	renpfix w1_
	g r=1
	save clean/i1, replace
	use indderived_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/i2, replace
	use indderived_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/i3, replace
	use clean/i1, clear
	quietly append using clean/i2
	quietly append using clean/i3
	sort pid r
	save clean/i_v1, replace
end

* households
program define household_cleaning
	use HHQuestionnaire_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/h1, replace
	use HHQuestionnaire_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/h2, replace
	use HHQuestionnaire_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/h3, replace
	use clean/h1, clear
	quietly append using clean/h2
	quietly append using clean/h3
	sort hhid r
	save clean/h_v1, replace
end

* household derived
program define household_derived_cleaning
	use hhderived_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/hd1, replace
	use hhderived_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/hd2, replace
	use hhderived_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/hd3, replace
	use clean/hd1, clear
	quietly append using clean/hd2
	quietly append using clean/hd3
	sort hhid r
	save clean/hd_v1, replace
end

program define admin_cleaning
	use Admin_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/ad1, replace
	use Admin_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/ad2, replace
	use Admin_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/ad3, replace
	use clean/ad1, clear
	quietly append using clean/ad2
	quietly append using clean/ad3
	sort hhid r
	save clean/ad_v1, replace
end

program define child_cleaning 
	use Child_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/c1, replace
	use Child_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/c2, replace
	use Child_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/c3, replace
	use clean/c1, clear
	quietly append using clean/c2
	quietly append using clean/c3
	sort pid r
	save clean/c_v1, replace
end

program define roster_cleaning
	use HouseholdRoster_W1_Anon_V5.2.dta, clear
	renpfix w1_
	g r=1
	save clean/hhr1, replace
	use HouseholdRoster_W2_Anon_V2.2.dta, clear
	renpfix w2_
	g r=2
	save clean/hhr2, replace
	use HouseholdRoster_W3_Anon_V1.2.dta, clear
	renpfix w3_
	g r=3
	save clean/hhr3, replace
	use clean/hhr1, clear
	quietly append using clean/hhr2
	quietly append using clean/hhr3
	sort pid r
	save clean/hhr_v1, replace
end

*** now merge everything

program define merge_file
	use Link_File_W3_Anon_V1.2.dta, clear
	renpfix w1_
	drop w2_*
	drop w3_*
	g r=1
	save clean/l1, replace
	use Link_File_W3_Anon_V1.2.dta, clear
	drop w1_*
	renpfix  w2_
	drop w3_*
	g r=2
	save clean/l2, replace
	use Link_File_W3_Anon_V1.2.dta, clear
	drop w1_*
	drop w2_*
	renpfix w3_
	g r=3
	save clean/l3, replace
	use clean/l1, clear
	quietly append using clean/l2
	quietly append using clean/l3
	save clean/l_v1, replace
end

program define merging
	use clean/l_v1, clear
	quietly merge 1:1 pid hhid r using clean/a_v1 
	drop _merge
	quietly merge 1:1 pid hhid r using clean/i_v1
	drop _merge
	quietly merge m:1 hhid r using clean/h_v1
	drop _merge
	quietly merge m:1 hhid r using clean/hd_v1
	drop _merge
	quietly merge m:1 pid hhid r using clean/ad_v1
	drop _merge
	quietly merge m:1 pid hhid r using clean/c_v1
	drop _merge
	quietly merge m:m pid hhid r using clean/hhr_v1
	drop _merge
	save clean/data_v1.dta, replace
end

main


