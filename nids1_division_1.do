* NIDS

cd "/Users/willviolette/Desktop/pstc_work/nids"

* cd "/Users/willviolette/Google Drive/nids"

* FOCUS ON INCOME!

clear all
set mem 1000m
set maxvar 10000

** LOOK AT DEMOGRAPHIC CORRELATES
use Adult_W1_Anon_V5.2.dta, clear
* keep pid w1_a_cr w1_a_crpid1 w1_a_crprv1 w1_a_crrel1 w1_a_crt1 w1_a_cryrv1 w1_a_crpid2 w1_a_crprv2 w1_a_crrel2 w1_a_crt2 w1_a_cryrv2 w1_a_brndc w1_hhid w1_a_lv06dc w1_a_marstt w1_a_mary w1_a_movy w1_a_bhlive_n w1_a_em1pay w1_a_dtbnd w1_a_ownbic w1_a_hl30fl w1_a_emohap w1_a_fwbinc5yr w1_a_gen w1_a_dob_y w1_a_marstt w1_a_popgrp w1_a_em1 w1_a_hllfexer w1_a_wblv w1_a_bpsys_1 w1_a_emodep w1_a_com2 w1_a_relnb w1_a_fwbstp2yr w1_a_fwbstptd w1_a_em1pay w1_a_em1occ_c w1_a_em1trncst w1_a_hldes w1_a_hl30d w1_a_com1 w1_a_com2 w1_a_com3 w1_a_com4 w1_a_com5 w1_a_com6 w1_a_com7 w1_a_com8 w1_a_com9 w1_a_com10 w1_a_com11 w1_a_com12 w1_a_com13 w1_a_com14 w1_a_com15 w1_a_com16 w1_a_com17 

g w1_a_em1trntime_h=.
g w1_a_em1trntime_m=.
g w1_a_lvevoth=.
sort pid
save w1_id.dta, replace

use Adult_W2_Anon_V2.2.dta, clear


rename w2_a_decd w2_a_decdpid
rename w2_a_decd2 w2_a_decdpid2 
rename w2_a_declrg w2_a_declrgpid
rename w2_a_declrg2 w2_a_declrgpid2
rename w2_a_decmem w2_a_decmempid
rename w2_a_decmem2 w2_a_decmempid2
rename w2_a_declv w2_a_declvpid
rename w2_a_declv2 w2_a_declvpid2
rename w2_a_decsch w2_a_decschpid
rename w2_a_decsch2 w2_a_decschpid2
* * keep pid w2_a_cr w2_a_crpid1 w2_a_crprv1 w2_a_crrel1 w2_a_crt1 w2_a_cryrv1 w2_a_crpid2 w2_a_crprv2 w2_a_crrel2 w2_a_crt2 w2_a_cryrv2 w2_hhid w2_a_lv08dc w2_a_marstt w2_a_mary w2_a_lvevoth w2_a_mvsuby w2_a_bhlive_n w2_a_em1pay w2_a_dtbnd w2_a_ownbic w2_a_hl30fl w2_a_emohap w2_a_fwbinc5yr w2_a_gen w2_a_dob_y w2_a_marstt w2_a_popgrp w2_a_em1 w2_a_hllfexer w2_a_wblv w2_a_bpsys_1 w2_a_emodep w2_a_com2 w2_a_relnb w2_a_fwbstp2yr w2_a_fwbstptd w2_a_em1pay w2_a_em1occ_c w2_a_em1trncst w2_a_hldes w2_a_hl30d w2_a_em1trntime_h w2_a_em1trntime_m  w2_a_com1 w2_a_com2 w2_a_com3 w2_a_com4 w2_a_com5 w2_a_com6 w2_a_com7 w2_a_com8 w2_a_com9 w2_a_com10 w2_a_com11 w2_a_com12 w2_a_com13 w2_a_com14 w2_a_com15 w2_a_com16 w2_a_com17 

ren w2_a_mvsuby w2_a_movy 
ren w2_a_lv08dc w2_a_lv06dc
drop w2_a_brndc
g w2_a_brndc=.
sort pid
save w2_id.dta, replace

use Adult_W3_Anon_V1.2.dta, clear
* * keep pid w3_a_cr w3_a_crpid1 w3_a_crprv1 w3_a_crrel1 w3_a_crt1 w3_a_cryrv1 w3_a_crpid2 w3_a_crprv2 w3_a_crrel2 w3_a_crt2 w3_a_cryrv2 w3_hhid w3_a_em1pay w3_a_mary w3_a_lvevoth w3_a_moveyr w3_a_bhlive_n w3_a_dtbnd w3_a_ownbic w3_a_hl30fl w3_a_emohap w3_a_fwbinc5yr w3_a_gen w3_a_dob_y w3_a_marstt w3_a_popgrp w3_a_em1 w3_a_hllfexer w3_a_wblv w3_a_bpsys_1 w3_a_emodep w3_a_relnb w3_a_fwbstp2yr w3_a_fwbstptd w3_a_em1pay w3_a_em1occ_c w3_a_hldes w3_a_hl30d 

forvalues r=1/17 {
g w3_a_com`r'=.
}
drop w3_a_brndc

ren w3_a_moveyr w3_a_movy
g w3_a_lv06dc=.
g w3_a_em1trncst=.
g w3_a_em1trntime_h=.
g w3_a_em1trntime_m=.
g w3_a_brndc=.
sort pid
save w3_id.dta, replace

** INDIVIDUAL DERIVED
use indderived_W1_Anon_V5.2.dta, clear
* keep w1_hhid pid w1_fwag w1_cwag w1_swag w1_remt w1_brid_flg w1_empl_stat
sort pid
save w1_id1.dta, replace

use indderived_W2_Anon_V2.2.dta, clear
* keep w2_hhid pid w2_fwag w2_cwag w2_swag w2_remt w2_brid_flg w2_empl_stat 
rename w2_cdep w2_care
rename w2_cdep_flg w2_care_flg
sort pid
save w2_id1.dta, replace

use indderived_W3_Anon_V1.2.dta, clear
rename w3_cdep w3_care
rename w3_cdep_flg w3_care_flg
* keep w3_hhid pid w3_fwag w3_cwag w3_swag w3_remt w3_brid_flg w3_empl_stat
sort pid
save w3_id1.dta, replace



** ORIGINAL HH
use HHQuestionnaire_W1_Anon_V5.2.dta, clear
rename w1_h_sub w1_h_grnthse
rename w1_h_nbthf w1_h_nbthmf
* keep w1_hhid w1_h_toi w1_h_toishr w1_h_dwltyp w1_h_dwlrms w1_h_dwlmatroof w1_h_dwlmatrwll w1_h_ownd w1_h_ownpid1 w1_h_ownpaid w1_h_ownrnt w1_h_rntpay w1_h_mrkv w1_h_sub_v w1_h_lndgrn w1_h_lndrst w1_h_ownpid1 w1_h_grnthse w1_h_tinc w1_h_fdtot w1_h_nbthmf w1_h_watsrc w1_h_enrgelec w1_h_nftranspn w1_h_nbhlp

sort w1_hhid
save w1_hh.dta, replace

use HHQuestionnaire_W2_Anon_V2.2.dta, clear
* keep w2_hhid w2_h_toi w2_h_toishr w2_h_dwltyp w2_h_dwlrms w2_h_dwlmatroof w2_h_dwlmatrwll w2_h_ownd w2_h_ownpid1 w2_h_ownpaid w2_h_rnt w2_h_rntpay w2_h_mrkv w2_h_lndgrn w2_h_lndrst w2_h_ownpid1 w2_h_grnthse w2_h_tinc w2_h_fdtot w2_h_nbthmf w2_h_watsrc w2_h_enrgelec w2_h_nftranspn
rename w2_h_rnt w2_h_ownrnt
g w2_h_sub_v=.
sort w2_hhid
save w2_hh.dta, replace

use HHQuestionnaire_W3_Anon_V1.2.dta, clear
rename w3_h_sub w3_h_grnthse
* keep w3_hhid w3_h_toi w3_h_toishr w3_h_dwltyp w3_h_dwlrms w3_h_dwlmatroof w3_h_dwlmatrwll w3_h_ownd w3_h_ownpid1 w3_h_ownpaid w3_h_rnt w3_h_rntpay w3_h_mrkv w3_h_lndgrn w3_h_lndrst w3_h_ownpid1 w3_h_grnthse w3_h_tinc w3_h_fdtot w3_h_nbthmf w3_h_watsrc w3_h_enrgelec w3_h_nftranspn
rename w3_h_rnt w3_h_ownrnt
g  w3_h_sub_v=.
sort w3_hhid
save w3_hh.dta, replace

** DERIVED HH
use hhderived_W1_Anon_V5.2.dta, clear
keep w1_hhid w1_pi_hhincome w1_pi_hhwage w1_pi_hhgovt w1_pi_hhremitt w1_expf w1_expnf w1_hhagric w1_hhsizer w1_rentexpend w1_hhgeo2011
sort w1_hhid
save hhd_w1.dta, replace

use hhderived_W2_Anon_V2.2.dta, clear
keep w2_hhid w2_pi_hhincome w2_pi_hhwage w2_pi_hhgovt w2_pi_hhremitt w2_expf w2_expnf w2_hhagric w2_hhsizer w2_rentexpend w2_hhgeo2011
sort w2_hhid
save hhd_w2.dta, replace

use hhderived_W3_Anon_V1.2.dta, clear
keep w3_hhid w3_pi_hhincome w3_pi_hhwage w3_pi_hhgovt w3_pi_hhremitt w3_expf w3_expnf w3_hhagric w3_hhsizer w3_rentexpend w3_hhgeo2011
sort w3_hhid
save hhd_w3.dta, replace


use Link_File_W3_Anon_V1.2.dta, clear

** DEMOGRAPHIC MERGE
sort pid
merge pid using w1_id.dta
keep if _merge==3
drop _merge

sort pid
merge pid using w2_id.dta
keep if _merge==3
drop _merge

sort pid
merge pid using w3_id.dta
keep if _merge==3
drop _merge

** INDIVIDUAL DERIVED MERGE

sort pid
merge pid using w1_id1.dta
keep if _merge==3
drop _merge
*
sort pid
merge pid using w2_id1.dta
keep if _merge==3
drop _merge
*
sort pid
merge pid using w3_id1.dta
keep if _merge==3
drop _merge


** ORIGINAL MERGE
sort w1_hhid
merge w1_hhid using w1_hh.dta
keep if _merge==3
drop _merge

sort w2_hhid
merge w2_hhid using w2_hh.dta
keep if _merge==3
drop _merge

sort w3_hhid
merge w3_hhid using w3_hh.dta
keep if _merge==3
drop _merge

** DERIVED MERGE
sort w1_hhid
merge w1_hhid using hhd_w1.dta
keep if _merge==3
drop _merge

sort w2_hhid
merge w2_hhid using hhd_w2.dta
keep if _merge==3
drop _merge

sort w3_hhid
merge w3_hhid using hhd_w3.dta
keep if _merge==3
drop _merge

* tab w1_h_nbhlp w1_h_grnthse
* make famsize var
g i=1
egen w1_fam=sum(i), by(w1_hhid)
egen w2_fam=sum(i), by(w2_hhid)
egen w3_fam=sum(i), by(w3_hhid)
drop i


forvalues r=1/3 {
g h`r'=w`r'_h_grnthse
}

save wrk3_1.dta, replace



forvalues r=1/3 {

use wrk3_1.dta, clear


renpfix w`r'_h_

g r=`r'
save d`r'.dta, replace
}

use d1.dta, clear
append using d1
append using d3
save dt.dta, replace

use dt.dta, clear
drop w1_*
drop w2_*
drop w3_*
drop dwltyp dwlrms dwlmatroof dwlmatrwll ownd own1 own2 ownpid1 own3 ownpid2 ownpaid ownpid3 ownowd ownmn ownrnt rnt rntpay rntpot mrkv grnthse sub_v lndgrn lndrst watsrc watdis toi toishr enrgelec enrgck enrght enrglght tellnd telcel transtrain transbus transmini refrem strlght hngradlt hngrchld expnd food hou clth hlth sch nbhlp nbtog nbagg nbthmf empl rent grn prvpen tinc tinc_show fdtot fdmm fdmmspn fdmmgft fdmmpay fdmmprd fdsmp fdsmpspn fdsmpgft fdsmppay fdsmpprd fdflr fdflrspn fdflrgft fdflrpay fdflrprd fdrice fdricespn fdricegft fdricepay fdriceprd fdpas fdpasspn fdpasgft fdpaspay fdpasprd fdbis fdbisspn fdbisgft fdbispay fdbisprd fdrm fdrmspn fdrmgft fdrmpay fdrmprd fdrmc fdrmcspn fdrmcgft fdrmcpay fdrmcprd fdchi fdchispn fdchigft fdchipay fdchiprd fdfsh fdfshspn fdfshgft fdfshpay fdfshprd fdfshc fdfshcspn fdfshcgft fdfshcpay fdfshcprd fdvegd fdvegdspn fdvegdgft fdvegdpay fdvegdprd fdpot fdpotspn fdpotgft fdpotpay fdpotprd fdvego fdvegospn fdvegogft fdvegopay fdvegoprd fdfru fdfruspn fdfrugft fdfrupay fdfruprd fdoil fdoilspn fdoilgft fdoilpay fdoilprd fdmar fdmarspn fdmargft fdmarpay fdmarprd fdpb fdpbspn fdpbgft fdpbpay fdpbprd fdmlk fdmlkspn fdmlkgft fdmlkpay fdmlkprd fdegg fdeggspn fdegggft fdeggpay fdeggprd fdsug fdsugspn fdsuggft fdsugpay fdsugprd fdsd fdsdspn fdsdgft fdsdpay fdsdprd fdfrut fdfrutspn fdfrutgft fdfrutpay fdfrutprd fdcer fdcerspn fdcergft fdcerpay fdcerprd fdbaby fdbabyspn fdbabygft fdbabypay fdbabyprd fdslt fdsltspn fdsltgft fdsltpay fdsltprd fdsoy fdsoyspn fdsoygft fdsoypay fdsoyprd fdcof fdcofspn fdcofgft fdcofpay fdcofprd fdhmp fdhmpspn fdhmpgft fdhmppay fdhmpprd fdrdy fdrdyspn fdrdygft fdrdypay fdrdyprd fdout fdoutspn fdoutgft fdoutpay fdoutprd fdo fdospn fdogft fdopay fdoprd nfcig nfcigspn nfalc nfalcspn nfent nfentspn nfspr nfsprspn nfper nfperspn nfjew nfjewspn nfpap nfpapspn nfcel nfcelspn nftel nftelspn nflot nflotspn nfnet nfnetspn nftrp nftrpspn nfcer nfcerspn nfcar nfcarspn nfpetr nfpetrspn nftran nftranspn nfwat nfwatspn nfele nfelespn nfene nfenespn nfmun nfmunspn nflev nflevspn nfinsl nfinslspn nfinsf nfinsfspn nfinsedu nfinseduspn nfinssh nfinsshspn nfkit nfkitspn nfdwl nfdwlspn nfbed nfbedspn nfmat nfmatspn nfhp nfhpspn nffrn nffrnspn nfclth nfclthspn nfcltha nfclthaspn nfclthm nfclthmspn nfmedaid nfmedaidspn nfdoc nfdocspn nfhsp nfhspspn nfmed nfmedspn nftrad nftradspn nfhom nfhomspn nfschfee nfschfeespn nfschstat nfschstatspn nfschuni nfschunispn nfscho nfschospn nfwsh nfwshspn nfchld nfchldspn nfrel nfrelspn nfdom nfdomspn nfswim nfswimspn nfpets nfpetsspn nftoys nftoysspn nfgfts nfgftsspn nfinctax nfinctaxspn ownrad ownhif owntel ownsat ownvid owncom owncam owncel ownelestv owngasstv ownparstv ownmic ownfrg ownwsh ownsew ownlng ownvehpri ownvehcom ownmot ownbic ownboat ownboatmot owncrt ownplg owntra ownwhl ownmll negdthf negdthfmn negdthfyr negdthfinc negdthfr negdthfrmn negdthfryr negdthfrin negdtho negdthomn negdthoyr negdthocst negill negillmn negillyr negillcst negstc negstcmn negstcyr negstccst negcrp negcrpmn negcrpyr negcrpcst negwrk negwrkmn negwrkyr negwrkinc negjob negjobmn negjobyr negjobinc negrem negremmn negremyr negreminc neggrn neggrnmn neggrnyr neggrninc negpro negpromn negproyr negprocst nego negomn negoyr negoinc negocst posjob posjobmn posjobyr posjobinc posrem posremmn posremyr posreminc posgrn posgrnmn posgrnyr posgrninc posinh posinhmn posinhyr posinhv posfrm posfrmmn posfrmyr posfrmv possch posschmn posschyr posschv poso1 poso1mn poso1yr poso1inc poso1v poso2 poso2mn poso2yr poso2inc poso2v ag agcom aglndcom aglndemp aglndref aglndequ aglndcomm aglndres agcr agcrml agcrmlu agcrmlhar agcrmlsll agcrmlval agcrmlgv agcrmlcon agcrsor agcrsoru agcrsorhar agcrsorsll agcrsorval agcrsorgv agcrsorcon agcrwht agcrwhtu agcrwhthar agcrwhtsll agcrwhtval agcrwhtgv agcrwhtcon agcrmil agcrmilu agcrmilhar agcrmilsll agcrmilval agcrmilgv agcrmilcon agcrpas agcrpasu agcrpashar agcrpassll agcrpasval agcrpasgv agcrpascon agcrcot agcrcotu agcrcothar agcrcotsll agcrcotval agcrcotgv agcrcotcon agcrsug agcrsugu agcrsughar agcrsugsll agcrsugval agcrsuggv agcrsugcon agcrtea agcrteau agcrteahar agcrteasll agcrteaval agcrteagv agcrteacon agcrtim agcrtimu agcrtimhar agcrtimsll agcrtimval agcrtimgv agcrtimcon agcrgrn agcrgrnu agcrgrnhar agcrgrnsll agcrgrnval agcrgrngv agcrgrncon agcrdec agcrdecu agcrdechar agcrdecsll agcrdecval agcrdecgv agcrdeccon agcrcit agcrcitu agcrcithar agcrcitsll agcrcitval agcrcitgv agcrcitcon agcrsub agcrsubu agcrsubhar agcrsubsll agcrsubval agcrsubgv agcrsubcon agcrfo agcrfou agcrfohar agcrfosll agcrfoval agcrfogv agcrfocon agcrtom agcrtomu agcrtomhar agcrtomsll agcrtomval agcrtomgv agcrtomcon agcrspi agcrspiu agcrspihar agcrspisll agcrspival agcrspigv agcrspicon agcrws agcrwsu agcrwshar agcrwssll agcrwsval agcrwsgv agcrwscon agcrcab agcrcabu agcrcabhar agcrcabsll agcrcabval agcrcabgv agcrcabcon agcrpot agcrpotu agcrpothar agcrpotsll agcrpotval agcrpotgv agcrpotcon agcrpmp agcrpmpu agcrpmphar agcrpmpsll agcrpmpval agcrpmpgv agcrpmpcon agcrcar agcrcaru agcrcarhar agcrcarsll agcrcarval agcrcargv agcrcarcon agcrmad agcrmadu agcrmadhar agcrmadsll agcrmadval agcrmadgv agcrmadcon agcroni agcroniu agcronihar agcronisll agcronival agcronigv agcronicon agcrgb agcrgbu agcrgbhar agcrgbsll agcrgbval agcrgbgv agcrgbcon agcrdb agcrdbu agcrdbhar agcrdbsll agcrdbval agcrdbgv agcrdbcon agcrlet agcrletu agcrlethar agcrletsll agcrletval agcrletgv agcrletcon agcrveg agcrvegu agcrveghar agcrvegsll agcrvegval agcrveggv agcrvegcon agcrbr agcrbru agcrbrhar agcrbrsll agcrbrval agcrbrgv agcrbrcon agcrgp agcrgpu agcrgphar agcrgpsll agcrgpval agcrgpgv agcrgpcon agls aglscat aglscatown aglscatsll aglscatval aglscatgv aglscatlss aglscatcon aglsshp aglsshpown aglsshpsll aglsshpval aglsshpgv aglsshplss aglsshpcon aglsgt aglsgtown aglsgtsll aglsgtval aglsgtgv aglsgtlss aglsgtcon aglspig aglspigown aglspigsll aglspigval aglspiggv aglspiglss aglspigcon aglshrs aglshrsown aglshrssll aglshrsval aglshrsgv aglshrslss aglshrscon aglsdnk aglsdnkown aglsdnksll aglsdnkval aglsdnkgv aglsdnklss aglsdnkcon aglschc aglschcown aglschcsll aglschcval aglschcgv aglschclss aglschccon aglsdck aglsdckown aglsdcksll aglsdckval aglsdckgv aglsdcklss aglsdckcon aglsost aglsostown aglsostsll aglsostval aglsostgv aglsostlss aglsostcon aglsrab aglsrabown aglsrabsll aglsrabval aglsrabgv aglsrablss aglsrabcon aglstur aglsturown aglstursll aglsturval aglsturgv aglsturlss aglsturcon ageggu ageggnum ageggsll ageggrev agegggv ageggcon agdrmlkm agdrmlku agdrmlkprd agdrmlksll agdrmlkval agdrmlkgv agdrmlkcon agdrbutm agdrbutu agdrbutprd agdrbutsll agdrbutval agdrbutgv agdrbutcon agdrom agdrou agdroprd agdrosll agdroval agdrogv agdrocon agwlm agwlu agwlnum agwlsll agwlval agwlgv agwlcon agmhm agmhu agmhnum agmhsll agmhval agmhgv agmhcon agilab agilabspn agifrt agifrtspn agiman agimanspn agichm agichmspn agiplgh agiplghspn agiseed agiseedspn agidip agidipspn agivet agivetspn agifeed agifeedspn agiinv agiinvspn agirep agirepspn intlng1 intlng2 intlng3 intlng4 intlng_o intresp intrespact intresphear intrespque intresppc1 intresppid1 intresppc2 intresppid2 intresppc3 intresppid3 intrvend h1 h2 h3 outcome refexpl refexpl_o refint refgen refage duration respondent mrtliv1 mrtpid1 mrtliv2 mrtpid2 mrtliv3 mrtpid3 mrtliv4 mrtpid4 dwlrate dwltyp_o dwlmatflr dwlrepr dwlrepr_v watsrc_o toi_o freqdomvio freqvio freqgang freqmdr freqdrug tinc_brac1 tinc_brac2 tinc_brac3 tinc_brac4 tinc_brac5 tinc_brac6 tinc_cat fdtot_brac1 fdtot_brac2 fdtot_brac3 fdtot_brac4 fdtot_brac5 fdtot_brac6 fdtot_cat fdrec fdprd fdcon fdmmss_v fdsmpss_v fdflrss_v fdricess_v fdpasss_v fdbisss_v fdrmss_v fdrmcss_v fdchiss_v fdfshss_v fdfshcss_v fdvegdss_v fdpotss_v fdvegoss_v fdfruss_v fdoilss_v fdmarss_v fdpbss_v fdmlkss_v fdeggss_v fdsugss_v fdsdss_v fdfrutss_v fdcerss_v fdbabyss_v fdsltss_v fdsoyss_v fdcofss_v fdhmpss_v fdrdyss_v fdoutss_v fdoss_v nflob nflobspn agrlnd agrlnd_a aglndacc aglndacc_o agpou aglvstk agcrop agorch aghort agoth agoth_o agcrmlhkg agcrmlsllyn agcrmlskg agcrsorhkg agcrsorsllyn agcrsorskg agcrfrt agcrfrthkg agcrfrtsllyn agcrfrtskg agcrfrtval agcrpothkg agcrpotsllyn agcrpotskg agcrpmphkg agcrpmpsllyn agcrpmpskg agcrmadhkg agcrmadsllyn agcrmadskg agcronihkg agcronisllyn agcroniskg agcrdbhkg agcrdbsllyn agcrdbskg agcrgrnveg agcrgrnveghkg agcrgrnvegsllyn agcrgrnvegskg agcrgrnvegval agcwmlkmth agcwmlkamt aggtmlkmth aggtmlkamt

sort pid r

save dt1.dta, replace



