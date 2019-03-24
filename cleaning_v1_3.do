* clean the big file


cd "/Users/willviolette/Desktop/pstc_work/nids"

use data_v1, clear

order c_parrel c_mthhh c_fthhh c_mthhh_pid c_fthhh_pid c_parrel c_mthhh c_fthhh c_* a_b* 

order r_relhead r_res r_absm r_absexp r_absprov r_absacc r_mem h_fd*
order  h_nf* h_ag* h_own* a_hl30* 
order a_emo* a_dec* a_com* h_food h_hou 
order h_clth h_hlth h_sch h_own1 h_own2 h_ownpid1 h_own3 h_ownpid2 h_ownpid3 a_bp* a_hllfhivtst numzscore zhfa zwfa zbmi zwfh a_trstcls a_trststrn a_wblv a_wbsat a_wbsat10yr a_relnb a_rel a_hltb a_hltb_yr a_hltb_med a_hltb_stl a_hlbp a_hlbp_yr a_hlbp_med a_hlbp_stl a_hldia a_hldia_yr a_hldia_med a_hldia_stl a_slpw a_slpm a_popgrp a_lng a_lng_o a_marstt a_mary a_timesep a_bhbrth a_bhlive a_bhlive_n a_bhali a_bhali_n a_mthhh a_fthhh  

order h_sub h_grn*
order r_parhp r_parhpid

* ** TAKE A CAREFUL LOOK AT CONSUMPTION EXPENDITURES
g fexp_imp=expf
g exp_imp=expenditure
g rent_imp=hhimprent_exp

g booze=h_nfalcspn if h_nfalcspn>0
g gamble=h_nflotspn if h_nflotspn>0



*** CARETAKER
drop care
rename c_carerel care
order care

g care1=care
g parent=care==8
replace parent=. if care==.
g grandparent=care==14
replace grandparent=. if care==.

* location

**** HEALTH
g health=a_hldes if a_hldes>0
g health_visit=a_hlcon if a_hlcon>0
g health_care=h_hlth if h_hlth>0
g health_ins=h_nfmedaid if h_nfmedaid>0
replace health_ins=0 if h_nfmedaid==2


**** URBAN ****
g u=hhgeo2011==2
order hhgeo2011

* PROVINCE
order hhprov2011 gc_prov2011
g prov=hhprov2011
replace prov=gc_prov2011 if r>=2
replace prov=. if prov==-3

* MDB
order hhmdbdc2011 gc_mdbdc2011
g mdb=hhmdbdc2011
replace mdb=gc_mdbdc2011 if r>=2
replace mdb="" if mdb=="-3"

*** RENT ***
g rent_d=1 if h_rnt==1
replace rent_d=0 if h_rent==0

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

g c_edu1=c_edcmpgrd if c_edcmpgrd>0 & c_edcmpgrd<=10

* SCHOOL QUALITY
g sch_q=ed12m_quin
replace sch_q=ed08m_quin if r==1
replace sch_q=ed10m_quin if r==2
replace sch_q=. if sch_q==-9

* LEARNER TO TEACHER RATIO
g lratio=ed08m_ltrr08 
replace lratio=ed10m_ltrr10 if r==2

* FEES
g fees=ed08m_nofee 
replace fees=ed10m_nofee if r==2
replace fees=ed12m_nofee if r==3

* ATTENDS SCHOOL
g c_att=.
replace c_att=1 if c_edu>0 & c_edu<.
replace c_att=0 if c_edu==7

g c_att1=c_ed11att if r==3
replace c_att1=c_ed09att if r==2
replace c_att1=c_ed07att if r==1
replace c_att1=. if c_att1<0


* SCHOOL FEES
g c_fees=c_ed11spnfee
replace c_fees=c_ed09spnfee if r==2
replace c_fees=c_ed07spnfee if r==1
replace c_fees=. if c_fees<0

* REPEAT A GRADE
g c_repeat=c_edrep
replace c_repeat=. if c_repeat<0
replace c_repeat=0 if c_repeat==2

* FAILED a grade
g c_failed=0
replace c_failed=. if (c_ed07res==. | c_ed07res<0) & r==1
replace c_failed=1 if (c_ed07res==2) & r==1
replace c_failed=. if (c_ed09res==. | c_ed09res<0) & r==2
replace c_failed=1 if (c_ed09res==2) & r==2
replace c_failed=. if (c_ed11res==. | c_ed11res<0) & r==3
replace c_failed=1 if (c_ed11res==2) & r==3


* SCHOOL DISTANCE
g sch_travel=c_edtrn1

* SCHOOL DISTANCE
g t_min_s=c_edtrntime_mins
replace t_min_s=. if  c_edtrntime_mins<0
g t_hrs_s=c_edtrntime_hrs
replace t_hrs_s=. if c_edtrntime_hrs<0
replace t_hrs_s=t_hrs_s*60

replace t_min_s=0 if t_min_s==. & t_hrs_s!=.
replace t_hrs_s=0 if t_min_s!=. & t_hrs_s==.

g sch_d=t_min_s+t_hrs_s
replace sch_d=. if sch_d>200

* CLASS SIZE
g class_size=c_edsizecls if c_edsizecls>0

* DAYS ABSENT
g absent=c_edmssds if c_edmssds>=0

* CHILD HEALTH
g c_health=c_hlthdes if c_hlthdes>0

* HEALTH PROFESSIONAL
g check_up=c_hlchckup if c_hlchckup>0
replace check_up=0 if c_hlchckup==3

* CHILD ILL
g c_ill=c_hlill30 if c_hlill30>0
replace c_ill=0 if c_hlill30==2

* SERIOUS ILLNESS
g c_ill_ser=c_hlser if c_hlser>0
replace c_ill_ser=0 if c_ill_ser==2

* TAKE TO HEALTH CARE FACILITY
g c_doc=c_hldoc if c_hldoc>0
replace c_doc=0 if c_hldoc==2

* CHILD HEIGHT
g height=c_height_1 if c_height_1>0

* CHILD WEIGHT
g weight=c_weight_1 if c_weight_1>0

* TB or ASTHMA
g c_resp=(c_hl1==1 | c_hl1==2)


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

drop a_pcode-r_head

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

replace sex=. if sex==-9
replace piped=1 if piped==2

save clean_v1.dta, replace




*********************************************************************


use clean_v1.dta, clear

*  hist rooms if h_grnthse>0 & rooms<10, by(h_grnthse)

*  hist rooms if h_sub>0 & rooms<10 & r==3, by(h_sub)

** assign people to a household
drop if resident==0

*** wave id
g r1=r if r==1
replace r1=r*10 if r==2
replace r1=r*100 if r==3
egen sr=sum(r1), by(pid)

*************
** FIX RDP **
*************
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

**
g rdp_fixed=rdp
** RDP _ FIXED looks pretty good

***** CAREFUL EDITING *****
** get rid of those that we only observe as rdp
egen mr=min(r), by(pid)
* definitely round 1
g rdp_r1=rdp if r==1
egen rdp_r1_max=max(rdp_r1), by(pid)
replace rdp=0 if rdp_r1_max==1
* round 2's that start RDP
g rdp_r2=rdp if r==2 & mr==2
egen rdp_r2_max=max(rdp_r2), by(pid)
replace rdp=0 if rdp_r2_max==1
* round 3's that start RDP
g rdp_r3=rdp if r==3 & mr==3
egen rdp_r3_max=max(rdp_r3), by(pid)
replace rdp=0 if rdp_r3_max==1

sort pid r
by pid: g hc=rdp[_n]-rdp[_n-1]
by pid: g hcf=rdp_fixed[_n]-rdp_fixed[_n-1]

tab hc r
tab hcf r

tab rdp r
tab rdp_fixed r

tab rdp r if sr==321
tab rdp_fixed r if sr==321

tab r rdp, r
tab r rdp_fixed, r 



save  hh_v2_d_p_ghs, replace


use hh_v2_d_p_ghs, clear

sort pid r
by pid: g h_ch=rdp[_n]-rdp[_n-1]

egen min_h_ch=min(h_ch), by(pid)
replace rdp=. if min_h_ch==-1

** FOUR CRITERIA

* 1.) get rid of movers (FOR ALL RDP)

g move_h_ch=h_ch*move
egen move_h_ch_max=max(move_h_ch), by(pid)
replace rdp=. if move_h_ch_max==1

* 2.) value is in range for looking like rdp

g rdpt=rdp
replace rdpt=0 if (mktv<10000 | mktv>60000) & u==1
replace rdpt=0 if (mktv<10000 | mktv>30000) & u==0

sort pid r
by pid: g h_cht=rdpt[_n]-rdpt[_n-1]

egen min_h_cht=min(h_cht), by(pid)
replace rdpt=. if min_h_cht==-1

label variable rdpt "Value Censor"

* 3.) multiple people from the original household are tracked there

duplicates tag hh1 r hhid, g(dup)

*** NEW DEFINITION OF DUPLICATES
g sizer1_id=size if r==1
egen sizer1=max(sizer1_id), by(pid)

g rdpd=rdp
replace rdpd=0 if dup<1 & sizer1>2

sort pid r
by pid: g h_chd=rdpd[_n]-rdpd[_n-1]

egen min_h_chd=min(h_chd), by(pid)
replace rdpd=. if min_h_chd==-1

label variable rdpd "Over 2 Members Co-Move"

g rdpd1=rdp
replace rdpd1=0 if dup<2

label variable rdpd1 "Min 3 Members Co-Move"

sort pid r
by pid: g h_chd1=rdpd1[_n]-rdpd1[_n-1]

egen min_h_chd1=min(h_chd1), by(pid)
replace rdpd1=. if min_h_chd1==-1

* 4.) the HH owns the new dwelling

g rdpo=rdp
replace rdpo=0 if own_d==0

sort pid r
by pid: g h_cho=rdpo[_n]-rdpo[_n-1]

egen min_h_cho=min(h_cho), by(pid)
replace rdpo=. if min_h_cho==-1

label variable rdpo "HH Owns RDP"

**************************************
*** COMPILE THIS VARIABLE TOGETHER ***
**************************************

** FINAL VARIABLE **
g rdpf=.
replace rdpf=0 if rdpo==0 & rdpd==0 & rdpt==0
replace rdpf=1 if  rdpo==1 & rdpd==1 & rdpt==1

sort pid r
by pid: g h_chf=rdpf[_n]-rdpf[_n-1]

label variable rdpf "Final RDP"

** DUPLICATES AND OWNERSHIP VARIABLE  ( NO MARKET VALUE ADJUSTMENT )
g rdpdo=.
replace rdpdo=0 if rdpo==0 & rdpd==0 
replace rdpdo=1 if  rdpo==1 & rdpd==1 

sort pid r
by pid: g h_chdo=rdpdo[_n]-rdpdo[_n-1]

label variable rdpdo "Co-Move and Ownership"

**********************************
**  Deaton and Paxson Variables **
**********************************

g ag=h_agrlnd==1
egen m_ag=max(ag), by(hh1) 

g fd=h_fdtot if h_fdtot>0

drop h_fd*
drop h_ag*
drop rdp_v
drop health_visit

foreach var of varlist *spnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist *spn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen non_food=rowtotal( *spnyr *spn)

g te=fd+non_food

g w=fexp_imp/exp_imp
g w_alt=fd/te

g x_n=exp_imp/size
g x_n_alt=te/size
g ln_x_n=ln(x_n)
g ln_x_n_alt=ln(x_n_alt)

g n=size
g ln_n=ln(n)

egen e_tot=sum(e), by(hhid)
g e_n=e_tot/n

forvalues i=0(10)100 {
forvalues j=0/1 {
g k_`i'_`j'=(sex==`j' & a>=`i' & a<`i'+10)
egen si_`i'_`j'=sum(k_`i'_`j'), by(hhid)
replace si_`i'_`j'=si_`i'_`j'/n
drop k_`i'_`j'
}
}

** cleaning and generating demographic variables

egen m=group(mdb)

g rooms_r1=rooms if r==1
egen roomsr1=max(rooms_r1), by(pid)
replace roomsr1=. if roomsr1>7

g dwell_r1=dwell if r==1
egen dwellr1=max(dwell_r1), by(pid)

g own_r1=own if r==1
egen ownr1=max(own_r1), by(hh1)

replace rooms=. if rooms>8

*replace mktv=. if mktv>70000

egen hh_a_max=max(a), by(hhid)
g ya_a=a if a>17
egen hh_a_mean=mean(ya_a), by(hhid)

egen hh_a_m=mean(a), by(hhid)

egen hh_gender=mean(sex), by(hhid)

g hoh_gender_id=sex if relhh==1
egen hoh_gender=max(hoh_gender_id), by(hhid)

g hoh_a_id=a if relhh==1
egen hoh_a=max(hoh_a_id), by(hhid)

g adults=size-children
replace adults=. if adults<=0

g kids_per_adult=children/adults


foreach var of varlist h_nfalcspn h_nfcigspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen vice=rowtotal(h_nfalcspn h_nfcigspn)
g vice_per=vice/te


foreach var of varlist h_nfcerspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist  h_nfcerspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen ceremony=rowtotal(h_nfcerspnyr  h_nfcerspn )
g ceremony_per=ceremony/te


foreach var of varlist h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist h_nffrnspn h_nfdwlspn h_nfkitspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen h_prod=rowtotal(h_nffrnspnyr h_nfdwlspnyr h_nfkitspnyr h_nffrnspn h_nfdwlspn h_nfkitspn)
g h_prod_per=h_prod/te


foreach var of varlist h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

foreach var of varlist h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen sch_spending=rowtotal( h_nfschospnyr h_nfschunispnyr h_nfschstatspnyr h_nfschfeespnyr h_nfschospn h_nfschunispn h_nfschstatspn h_nfschfeespn )
g sch_per=sch_spending/te

g y=fexp_imp/n
g y_alt=fd/n

egen health_exp=rowtotal( h_nfhspspnyr h_nfdocspnyr h_nftradspnyr h_nfhomspn h_nftradspn h_nfmedspn h_nfhspspn h_nfdocspn h_nfmedaidspn )
g health_exp_per=health_exp/te

egen doc=rowtotal (h_nfdocspnyr h_nfdocspn)
rename h_nfmedspn med

** more non-food
foreach var of varlist h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn {
replace `var'=0 if `var'<=0 | `var'==.
}

foreach var of varlist h_nfbedspnyr h_nfmatspnyr {
replace `var'=0 if `var'<=0 | `var'==.
replace `var'=`var'/12
} 

egen non_food_more=rowtotal ( h_nfbedspnyr h_nfmatspnyr h_nfbedspn h_nfmatspn h_nfentspn h_nfsprspn h_nfperspn h_nfjewspn h_nfpapspn h_nfcelspn h_nftelspn h_nflotspn )


** more public
foreach var of varlist  h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn {
replace `var'=0 if `var'<=0 | `var'==.
}

egen public_more= rowtotal (h_nfentspn h_nfcelspn h_nftelspn h_nfnetspn h_nfwatspn h_nfelespn h_nfenespn h_nfmunspn h_nflevspn h_nfinslspn h_nfinsfspn h_nfdomspn)

** non-food
g non_fd= health_exp + sch_spending + vice + non_food_more
g public= h_prod + ceremony + public_more



*** DEFINE YOUNG CHILDREN ***
drop child
drop child_out
drop child_d

forvalues r=1/16 {
g c_a_`r'=a_bhdob_y`r'
replace c_a_`r'=2008-c_a_`r' if r==1
replace c_a_`r'=2010-c_a_`r' if r==2
replace c_a_`r'=2012-c_a_`r' if r==3
replace c_a_`r'=. if c_a_`r'<0
g c_res_`r'=(c_a_`r'<=15 & a_bhlive`r'==1 & a_bhali1==1)
g c_nres_`r'=(c_a_`r'<=15 & a_bhlive`r'==2 & a_bhali1==1)
g c_yres_`r'=(c_a_`r'<=5 & a_bhlive`r'==1 & a_bhali1==1)
g c_ynres_`r'=(c_a_`r'<=5 & a_bhlive`r'==2 & a_bhali1==1)
g c_ores_`r'=(c_a_`r'>5 & c_a_`r'<=15 & a_bhlive`r'==1 & a_bhali1==1)
g c_onres_`r'=(c_a_`r'>5 & c_a_`r'<=15 & a_bhlive`r'==2 & a_bhali1==1)
}

egen child=rowtotal(c_res_*)
egen child_out=rowtotal(c_nres_*)
g child_total=child+child_out

egen child_y=rowtotal(c_yres_*)
egen child_out_y=rowtotal(c_ynres_*)
g child_total_y=child_y+child_out_y

egen child_o=rowtotal(c_ores_*)
egen child_out_o=rowtotal(c_onres_*)
g child_total_o=child_o+child_out_o

foreach x in child child_out child_y child_out_y child_o child_out_o {
g `x'_d=(`x'>0 & `x'<.)
}


** CLEAN EDUCATION VARIABLES

replace c_edu=. if c_edu<0
replace fees=. if fees<0
replace lratio=. if lratio<0
label variable c_fees "value of fees"
g absent1=absent
replace absent1=0 if absent1==. & c_att==1
label variable absent1 "includes perfect attendance"

save mech_c_edu_v1, replace


