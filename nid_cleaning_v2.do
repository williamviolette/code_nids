* clean the big file

/*

cd "${rawdata}"

use clean/data_v1, clear

global i45 = " if r==4 | r==5 "
global i23 = " if r==2 | r==3 "

replace hhgeo2011 = geo2011 $i45
replace hhgeo2001 = geo2001 $i45

replace hhprov2011 = prov2011 $i45
replace hhmdbdc2011 = mdbdc2011 $i45


**** ISSUES ****
* travel : there's more on that
* house ownership : own1 own2 own3 4-5?




* location

**** URBAN ****
g u=hhgeo2011==2
order hhgeo2011

* PROVINCE
order hhprov2011 gc_prov2011
g prov=hhprov2011
replace prov=gc_prov2011  $i23
replace prov=. if prov==-3

* MDB
order hhmdbdc2011 gc_mdbdc2011
g mdb=hhmdbdc2011
replace mdb=gc_mdbdc2011 $i23
replace mdb="" if mdb=="-3"

*** RENT ***
g rent_d=1 if h_rnt==1
replace rent_d=0 if h_rnt==0

******************
** DEMOGRAPHICS **
******************

** relocate
* g relocate=a_relocate if a_relocate>0
* good variable to test...

** csm
g csm1=csm
drop csm
rename csm1 csm

** STAYER
order stayer
g move=1 if stayer==0
replace move=0 if stayer==1

* * * INDIVIDUAL * * *

* AGE *
g a=best_age_yrs if best_age_yrs>=0

* GENDER *
g sex=best_gen
replace sex=0 if sex==2
replace sex=. if sex==-8

* RACE *
g race=best_race
g af=race==1
replace af=. if race==.
g c=race==2
replace c=. if race==.

* EDUCATION *
g edu=best_edu
replace edu=edu-12 if edu>=13 & edu<=15
replace edu=12 if edu==18 | edu==19
replace edu=11 if edu==17 | edu==16
replace edu=edu+1
replace edu=0 if edu==26
replace edu=. if edu<0

g edu_d=(edu>0 & edu<.)

* MARITAL STATUS *
replace a_marstt = r_mar $i45
g marry=.
replace marry=0 if a_marstt>0 & a_marstt<.
replace marry=1 if a_marstt==1

g tog=.
replace tog=0 if a_marstt>0 & a_marstt<.
replace tog=1 if a_marstt==1 | a_marstt==2

* HEAD OF HOUSEHOLD RELATIONSHIP *
g hoh=.
replace hoh=0 if r_relhead>0 & r_relhead<.
replace hoh=1 if r_relhead==1

g relhh=r_relhead

* NUMBER OF OWN CHILDREN *
* only for women: need to sum over household
g child_d=.
replace child_d=1 if a_bhlive==1
replace child_d=0 if a_bhlive==0

g child=a_bhlive_n if a_bhlive_n>0

g child_out=a_bhali_n if a_bhali_n>0

* RESIDENT OF HOUSEHOLD *
g resident=r_pres==1
* USE THIS TO LINK TO HOUSEHOLD FOR EACH ROUND

* * * HOUSEHOLD * * *

* SIZE OF HOUSEHOLD * 
g size=hhsizer

* NUMBER OF CHILDREN *
egen children=sum(child), by(hhid r)

*** test with alternate measure, first measure looks like an upper bound which is good
* g child1=a<18
* egen children1=sum(child1), by(hhid r)

* INDIVIDUALS LOST BETWEEN ROUNDS (COUNT) *

g tsm1=csm==2
egen tsm=sum(tsm1), by(hhid r)
replace tsm=. if tsm>34
drop tsm1

* DECISION MAKING *

** COME BACK TO DECISION MAKING

******************
** EMPLOYMENT   **
******************

* EMPLOYMENT *
g e=empl_stat
replace e=. if e==-8
replace e=0 if empl_stat<=2
replace e=1 if e==3

g ue=empl_stat
replace ue=. if ue==-8
replace ue=0 if empl_stat==3
replace ue=1 if empl_stat==1 | empl_stat==2

* HOUSEHOLD EMPLOYMENT
g e_hh=h_empl if h_empl>0
replace e_hh=0 if h_empl==2

* SECTOR *
*** HARD TO GET RELIABLE DATA HERE

* WAGE *
* fwag cwag swag

* HOURS *
g hrs=a_em1hrs
replace hrs=. if hrs<0
g hrs_s=a_emshrs 
replace hrs_s=. if hrs_s<0
g hrs_c=a_emchrs
replace hrs_c=. if hrs_c<0

* TRANSPORT COST *
g travel=a_em1trncst
replace travel=. if travel<0

* TRAVEL TIME *
g t_min=a_em1trntime_m
replace t_min=. if a_em1trntime_m<0
g t_hrs=a_em1trntime_h 
replace t_hrs=. if a_em1trntime_h<0
replace t_hrs=t_hrs*60

replace t_min=0 if t_min==. & t_hrs!=.
replace t_hrs=0 if t_min!=. & t_hrs==.

g wdist=t_min+t_hrs
replace wdist=. if wdist>200

**************************
** HOUSING ATTRIBUTES   **
**************************

* RDP *
g rdp=h_sub
replace rdp=h_grnthse if r==2

** missing value in round 1
replace rdp=1 if rdp==-9 & r==1
replace rdp=. if rdp<0
replace rdp=0 if rdp==2
* keep missing values in rdp variable

* Very Key to look at Value of RDP!
g rdp_v=h_sub_v
* * * how useful is the subsidy to figure out what an RDP looks like?

* most people don't know the value of the subsidy
* * * explore this issue further by looking at rooms etc.

* DWELLING TYPE (INFORMAL, ETC) *
g dwell=h_dwltyp

order h_dwltyp

g inf=h_dwltyp
replace inf=. if inf<0
replace inf=0 if inf<7 | inf>9
replace inf=. if h_dwltyp==.
replace inf=1 if inf>=7 & inf<=9

g bkyd=h_dwltyp
replace bkyd=. if bkyd<0
replace bkyd=0 if bkyd<6 | bkyd>8
replace bkyd=. if h_dwltyp==.

g house=h_dwltyp
replace house=. if house<0
replace house=0 if house>1 & house<.
replace house=. if h_dwltyp==.

* OWNERSHIP * 
g own_d=h_ownd
replace own_d=. if own_d<0
replace own_d=0 if own_d==2

g own1=(pid==h_ownpid1)
g own2=(pid==h_ownpid2)
g own3=(pid==h_ownpid3)
g own=own1+own2+own3
replace own=1 if own==2

g paid_off=h_ownpaid
replace paid_off=. if paid_off<0
replace paid_off=0 if paid_off==2

* RENTAL VALUE *
g rent=h_rntpay
replace rent=. if h_rntpay<0

g rentv=h_ownrnt

*g rent_d=h_rnt
* replace rent_d=. if rent_d<0
*replace rent_d=0 if rent_d==2

* MARKET VALUE *
g mktv=h_mrkv
replace mktv=. if mktv<0

* MONTHLY BOND PAYMENTS *
g bond=h_ownmn if h_ownmn>=0

* WATER *
order h_watsrc
g water=h_watsrc
replace water=. if water<0
g piped=water
replace piped=0 if water>2 & water<.

* TOILET *
g toi=h_toi
g toi_shr=h_toishr
g flush=1 if h_toi==1 | h_toi==2
replace flush=0 if h_toi>2 & h_toi<.
order h_toi
order toi_shr

* ELECTRICITY *
g elec=h_enrgelec
replace elec=. if elec<0
replace elec=0 if elec==2

* ROOMS *
g rooms=h_dwlrms if h_dwlrms>=0 & h_dwlrms<100

* ROOF * 
order h_dwlmatroof
g roof=h_dwlmatroof if h_dwlmatroof>0
g roof_cor=0 if roof!=.
replace roof_cor=1 if roof==3

* WALLS *
order h_dwlmatrwll
g walls=h_dwlmatrwll if h_dwlmatrwll>0
g walls_b=0 if walls!=.
replace walls_b=1 if walls==1

* DISTANCE TO TRANSPORT *
g train=h_transtrain if h_transtrain>=0
g bus=h_transbus if h_transbus>=0
g mini=h_transmini if h_transmini>=0

* NEIGHBORHOOD ATTRIBUTES

g theft=h_nbthmf if h_nbthmf>=0
g domvio=h_freqdomvio if h_freqdomvio>=0 
g vio=h_freqvio if h_freqvio>=0
g gang=h_freqgang if h_freqgang>=0
g murder=h_freqmdr if h_freqmdr>=0
g drug=h_freqdrug if h_freqdrug>=0

****************************
** INCOME AND EXPENDITURE **
****************************

* TOTAL INCOME
g inc=pi_hhincome

* REMITTANCES
g inc_r=pi_hhremitt

* SOURCES OF REMITTANCE

g rec_d_r=a_cr if a_cr>0
replace rec_d_r=0 if rec_d_r==2

g p_code1_r=(a_crpid1==pid)
g loc1_r=a_crprv1
g p_code2_r=(a_crpid2==pid)
g loc2_r=a_crprv2

g send_r=a_cg
replace send_r=. if send_r<0
replace send_r=0 if send_r==2

g rec1_r=a_cgpid1
g rec2_r=a_cgpid2



* LABOR INC
g inc_l=pi_hhwage

* GOVERNMENT GRANTS
g inc_g=pi_hhgovt

** GET A SENSE FOR PERCENTAGES FROM DIFFERENT SOURCES

* EXPENDITURE ( WHAT ARE THE LARGEST GROUPS )
g exp=exprough
g exp_i=expenditure
g exp_f=expf

**********************************
** HEALTH AND SATISFACTION, ETC **
**********************************

********************
** CHILD OUTCOMES **
********************

** EDUCATION
g c_edu=c_ed12curgrd
replace c_edu=c_ed10curgrd if r==2
replace c_edu=c_ed08curgrd if r==1
replace c_edu=c_edcurgrd $i45

* ATTENDS SCHOOL
g c_att=.
replace c_att=1 if c_edu>0 & c_edu<.
replace c_att=0 if c_edu==7

* SCHOOL FEES
g c_fees=c_ed11spnfee
replace c_fees= c_ed13spnfee if r==4
replace c_fees= c_ed14spnfee if r==4 & c_fees==.
replace c_fees= c_ed16spnfee if r==5
replace c_fees=c_ed09spnfee if r==2
replace c_fees=c_ed07spnfee if r==1
replace c_fees=. if c_fees<0

* SCHOOL DISTANCE
g c_sch_travel=c_edtrn1

* SCHOOL DISTANCE
g t_min_s=c_edtrntime_mins
replace t_min_s=. if  c_edtrntime_mins<0
g t_hrs_s=c_edtrntime_hrs
replace t_hrs_s=. if c_edtrntime_hrs<0
replace t_hrs_s=t_hrs_s*60

replace t_min_s=0 if t_min_s==. & t_hrs_s!=.
replace t_hrs_s=0 if t_min_s!=. & t_hrs_s==.

g c_sch_d=t_min_s+t_hrs_s
replace c_sch_d=. if c_sch_d>200

* CLASS SIZE
g c_class_size=c_edsizecls if c_edsizecls>0

* DAYS ABSENT
g c_absent=c_edmssds if c_edmssds>0

* REPEAT GRADE
g c_repeat=1 if c_edrep==1
replace c_repeat=0 if c_edrep==2

* CHILD HEALTH
g c_health=c_hlthdes if c_hlthdes>0

* SERIOUS ILLNESS
g c_ill_ser=1 if c_hlser==1
replace c_ill_ser=0 if c_hlser==2

* HEALTH PROFESSIONAL
g c_check_up=c_hlchckup if c_hlchckup>0
replace c_check_up=0 if c_hlchckup==3

* HEATLHCARE FACILITY
g c_facility=1 if c_hldoc==1
replace c_facility=0 if c_hldoc==2

* CHILD ILL
g c_ill=c_hlill30 if c_hlill30>0
replace c_ill=0 if c_hlill30==2

* CHILD HEIGHT
g c_height=c_height_1 if c_height_1>0

* CHILD WEIGHT
g c_weight=c_weight_1 if c_weight_1>0

* MOTHER IS RESIDENT
g c_mother_res=1 if c_mthhh==1
replace c_mother_res=0 if c_mthhh==2

* MOTHER SEES CHILD
g c_mother_see=c_mthsee if c_mthsee>0

* MOTHER SUPPORTS CHILD
g c_mother_sup=1 if c_mthfin==1
replace c_mother_sup=0 if c_mthfin==2

* FATHER IS RESIDENT
g c_father_res=1 if c_fthhh==1
replace c_father_res=0 if c_fthhh==2

* FATHER SEES CHILD
g c_father_see=c_fthsee if c_fthsee>0

* FATHER SUPPORTS CHILD
g c_father_sup=1 if c_fthfin==1
replace c_father_sup=0 if c_fthfin==2

* 


**** WAGE OUTCOMES ****
rename fwag fwag1
g fwag=fwag1
drop fwag1

rename fwag_flg fwag_flg1
g fwag_flg=fwag_flg1
drop fwag_flg1

rename cwag cwag1
g cwag=cwag1
drop cwag1

rename cwag_flg cwag_flg1
g cwag_flg=cwag_flg1
drop cwag_flg1

rename swag swag1
g swag=swag1
drop swag1

rename swag_flg swag_flg1
g swag_flg=swag_flg1
drop swag_flg1


**** HHold IDENTIFIER FOR CLUSTERING ****
g hhid1=hhid if r==1
egen hh1=max(hhid1), by(pid)

** relocation?
g relocate=c_relocate



** KEY HERE !
drop a_pcode-r_noparh

label variable a "Age"
label variable rdp "RDP"
label variable size "Size"
label variable af "African"
label variable edu "Education"
label variable inc "Household Income"
label variable piped "Piped Water"
label variable rooms "Rooms"
label variable elec "Electricity"
label variable children "Children"
label variable u "Urban"
label variable e "Employed"
label variable inc_r "Remittances"
label variable inc_l "Labor Income"
label variable fwag "Formal Wages"
label variable inf "Informal Settlement"
label variable inc_g "Transfer Income"


* final cleaning and generating
replace sex=. if sex==-9
replace piped=1 if piped==2

replace h_toi=. if h_toi<0 | h_toi==9
g pit=(h_toi==4 | h_toi==5)
g chem=h_toi==3
g bucket=h_toi==6
g pub_tap=h_watsrc==3
g open_w=(h_watsrc==8 | h_watsrc==9)

* get rid of missing obs for province and mdb
drop if prov==10
drop if prov==.
drop if mdb==""

save clean_v1.dta, replace


*********************************************************************


use clean_v1.dta, clear
** assign people to a household
drop if resident==0

g rdp1=rdp
egen rm=max(rdp), by(pid)

*************
** FIX RDP **
*************
** could do a more careful job of making sure these are rdps!
sort pid r
by pid: g rdp_l1=rdp[_n+1]
by pid: g rdp_l2=rdp[_n+2]
by pid: g rdp_lg1=rdp[_n-1]
by pid: g rdp_lg2=rdp[_n-2]

* 1.) missing in round 1, take the value of round 2, then of round 3
replace rdp=rdp_l1 if r==1 & rdp==.
replace rdp=rdp_l2 if r==1 & rdp==.

* 2.) missing in round 2, take value of round 3
replace rdp=rdp_lg1 if r==2 & rdp==.

* 3.) missing in round 3, take value of round 2, then of round 1
replace rdp=rdp_lg1 if r==3 & rdp==.
replace rdp=rdp_lg2 if r==3 & rdp==.

** only look at housing responses
drop if rdp==.

*** income censor
egen max_inc=max(inc), by(pid)
drop if max_inc>20000

*** keep only respondents that responded in all 3 waves
g r1=r if r==1
replace r1=r*10 if r==2
replace r1=r*100 if r==3
egen sr=sum(r1), by(pid)
* keep if sum_r==6
** drops 18,000 obs

*************************
** HOUSEHOLD LONG-TERM **
*************************
*** drop if lose rdp or gain rdp in 3rd period
sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]
egen h_ch_m=min(h_ch), by(pid)
g h_ch_r3=h_ch if r==3
egen h_ch_r3_m=max(h_ch_r3), by(pid)

g lt=rdp
replace lt=. if h_ch_m==-1
replace lt=. if h_ch_r3_m==1
replace lt=. if r==2

*************************
* HOUSEHOLD SHORT-TERM **
*************************
*** if gain rdp in 2nd period drop 3rd period observation 
g h_ch_r2=h_ch if r==2
egen h_ch_r2_m=max(h_ch_r2), by(pid)

g st=rdp
replace st=. if h_ch_m==-1
replace st=. if h_ch_r2_m==1 & r==3

***************************
* HOUSEHOLD DIFF IN DIFF **
***************************

g dd=rdp
replace dd=. if h_ch_m==-1
replace dd=. if r==2


********************
* HOUSEHOLD TOTAL **
********************

g tt=rdp
replace tt=. if h_ch_m==-1	


replace bkyd=1 if bkyd>=6 & bkyd<=8

save hh_v1, replace


************************
** LINK WITH GHS DATA **
************************

/*

***********************
** GHS LINK BY BOTH **
***********************

*** FIRST R THEN MDB

use 09_13_analysis_t.dta, clear

merge m:m psu using psu
keep if _merge==3
drop _merge

rename dc_mdb_c2011 mdb

g r=1 if year==2009
replace r=2 if year==2010
replace r=3 if year==2012

g urb=(GeoType==1 | GeoType==2)
g tribal=GeoType==4
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

g rdp_commute_u=commute if rdp_h==1 & urb==1
g rdp_commute_r=commute if rdp_h==1 & urb==0

g commute_u=commute if urb==1
g commute_r=commute if urb==0

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

drop tribal

g u=urb

collapse (median) wl_yr (sum) wl_new rdp_s_new rdp_h_new pop rdp_s_tot rdp_h_tot (mean) e_wage rdp_e_wage rooms h_age wl_commute rdp_commute rdp_commute_u rdp_commute_r commute_u commute_r rdp_rooms rdp_rooms_new wl rdp_s rdp_h tog sal african commute rdp_inc_c inc_c ben tk, by(r mdb)

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

***** FINAL GHS MERGE *****

use hh_v1, clear

merge m:1 mdb r using ghs_link_r
drop _merge
*merge m:1 mdb using ghs_link_mdb
*drop _merge
*merge m:1 mdb u using ghs_link_u
*drop _merge

*************************************
*** GENERATE GEOGRAPHIC VARIABLES ***
*************************************

g metros=(mdb=="ETH" | mdb=="CPT" | mdb=="JHB" | mdb=="TSH")

g ma=1 if mdb=="ETH" & r>=2
replace ma=1 if mdb=="JHB" & r>=2
replace ma=1 if mdb=="TSH" & r>=2
replace ma=1 if mdb=="EKU" & r>=2
replace ma=1 if mdb=="CPT" & r>=2
* Siyanda
replace ma=1 if mdb=="DC8" & r>=2
* Pixleyka Seme
replace ma=1 if mdb=="DC7" & r>=2
* Frances Baard
replace ma=1 if mdb=="DC9" & r>=2
* Nelson Mandela Bay
replace ma=1 if mdb=="NMA" & r>=2
* Kwadikuza
replace ma=1 if mdb=="DC29" & r>=2
* Newcastle
replace ma=1 if mdb=="DC25" & r>=2
* Ladysmith
replace ma=1 if mdb=="DC23" & r>=2
*** Missing some!!
replace ma=0 if ma==.

** GENERATE MU
egen mdb1=group(mdb)
egen ma1=max(ma), by(mdb1)

********************************************
*** PROVINCE LEVEL PERFORMANCE VARIABLES ***
********************************************

* eastern cape
g sites=10245 if prov==2
g tops=12624 if prov==2
* free state
replace sites=6232 if prov==4
replace tops=6765 if prov==4
* gauteng
replace sites=8280 if prov==7
replace tops=20464 if prov==7
* kzn
replace sites=2790 if prov==5
replace tops=29084 if prov==5
* limpopo
replace sites=85 if prov==9
replace tops=2972 if prov==9
* mpumalanga
replace sites=3884 if prov==8
replace tops=7550 if prov==8
* northern cape
replace sites=2875 if prov==3
replace tops=2464 if prov==3
* north west
replace sites=166 if prov==6
replace tops=9362 if prov==6
* western cape
replace sites=6667 if prov==1
replace tops=11845 if prov==1

g ts=sites+tops

g t_per=tops/ts

label variable sites "Serviced Sites"
label variable tops "Top Structures"
label variable ts "Total Assistance"
label variable t_per "Percentage Top Structures"

save hh_v1_ghs, replace







