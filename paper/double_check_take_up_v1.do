
cd "/Users/willviolette/Desktop/pstc_work/ghs"


use "09_13_analysis_t.dta", clear

xtset psu
xi: xtreg hholdsz rdp_s if rdp_h==1, fe robust
outreg2 using "/Users/willviolette/Desktop/pstc_work/nids/clean/tables/selection_1", nonotes tex(frag) label replace nocons title("Selection")



xi: xtreg hholdsz rdp_s i.year if rdp_h==1 & h_age==1, fe robust

xi: xtreg hholdsz i.rdp_s*i.h_age i.year if rdp_h==1, fe robust
** the ones that keep the houses are bigger households





use distance_analysis_v1, clear


xtset psu
xi: xtreg rdp_s hholdsz i.year1 if rdp_h==1, fe robust




label variable p_dist "Distance to Police Station"
label variable s_dist "Distance to School"
label variable h_dist "Distance to Hospital"
label variable t_dist "Distance to Town"
label variable r_dist "Distance to National Road"




*$*$*$*

drop near_dist
drop m_dist

egen mn=group(mn_mdb_c)
egen geo=group(GeoType)

foreach var of varlist *_dist {
g rdp_s_`var'=`var'*rdp_s
}

foreach var of varlist *_dist {
replace `var'=`var'*111.12
}



*$*$*$*

reg inc_c p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg sal p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg e_sal p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg remit p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg commute p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

* national road is the only thing that matters
reg piped p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)



reg e_wage p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg e_wage p_dist s_dist h_dist t_dist r_dist i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1 & gender==1, cluster(psu)
reg e_wage p_dist s_dist h_dist t_dist r_dist i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1 & gender==0, cluster(psu)


reg e_wage p_dist s_dist h_dist t_dist r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)




* comparing recipients and waitlist people directly
reg e_wage rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1 | wl==1, cluster(psu)
* don't control for urban/rural distinctions
reg e_wage rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011 if rdp_s==1 | wl==1, cluster(psu)

reg value rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011 if rdp_s==1 | wl==1, cluster(psu)
reg value rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011, cluster(psu)



reg remit rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo, cluster(psu)

reg commute rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.gender i.african age i.year1 i.pr_code2011 i.geo, cluster(psu)

reg commute rdp_s *t_dist i.gender i.african age i.year1 i.pr_code2011 i.geo, cluster(psu)


reg inc_c rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist  i.gender i.african age i.year1 i.pr_code2011 i.geo, cluster(psu)


reg gender rdp_s *p_dist *s_dist *h_dist *t_dist *r_dist i.african age i.year1 i.pr_code2011 i.geo, cluster(psu)




reg e_wage *_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg e_wage *_dist i.gender i.african age i.year1 i.pr_code2011 i.geo if rdp_s==0, cluster(psu)



reg e_wage *_dist i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg e_wage *_dist i.year1 i.pr_code2011 i.geo if rdp_s==0, cluster(psu)
* other amenities matter for non-RDP recipients, why is that? what can I do about it?

reg attend *_dist i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg repeat *_dist i.year1 i.pr_code2011 i.geo if rdp_s==1, cluster(psu)

reg repeat *_dist i.year1 i.pr_code2011 i.geo if rdp_s==0, cluster(psu)




*reg e_wage *_dist i.year1 i.dc_mn_c2011 if rdp_s==1, cluster(psu)
*reg e_wage *_dist i.year1 i.mn if rdp_s==1, cluster(psu)
*reg e_wage *_dist i.year1 if rdp_s==0, cluster(psu)
*reg e_wage *_dist i.year1 if wl==1, cluster(psu)






reg attend *_dist i.year1 if rdp_s==1, cluster(psu)

reg repeat *_dist i.year1 if rdp_s==1, cluster(psu)

