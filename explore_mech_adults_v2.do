

cd "/Users/willviolette/Desktop/pstc_work/nids"

***********************************
*** EXPENDITURES WITH CHILD OUT ***
***********************************

use mech_c_edu_v1, clear

xtset pid

tab c_mthhh c_fthhh

** PROBLEM IS THAT THIS IS ONLY FROM THE PERSPECTIVE FROM THE WOMEN

**************************************
******* CHILDREN IN RESIDENCE ********
**************************************

*** OVERALL 
foreach o in child child_y child_o {
forvalues z=0/1 {
xi: xtreg `o' rdp i.prov*i.r if u==`z', fe cluster(hh1) robust
}
}
** urban areas move more on both fronts (although rural is still positive)

*** INTENSIVE MARGIN
foreach o in child child_y child_o {
forvalues z=0/1 {
xi: xtreg `o' rdp i.prov*i.r if u==`z' & `o'>0, fe cluster(hh1) robust
}
}
** no movement, potentially negative in urban areas (makes sense)
** especially for young children

*** EXTENSIVE MARGIN
foreach o in child child_y child_o {
forvalues z=0/1 {
xi: xtreg `o'_d rdp i.prov*i.r if u==`z', fe cluster(hh1) robust
}
}
** pronounced for the extensive margin (pretty equal across ages)

******************************************
******* CHILDREN OUT OF RESIDENCE ********
******************************************
foreach o in child_out child_out_y child_out_o {
forvalues z=0/1 {
xi: xtreg `o' rdp i.prov*i.r if u==`z' & sex==1, fe cluster(hh1) robust
}
}
** odd that this measure doesnt move

*** EXTENSIVE MARGIN
foreach o in child_out child_out_y child_out_o {
forvalues z=0/1 {
xi: xtreg `o'_d rdp i.prov*i.r if u==`z', fe cluster(hh1) robust
}
}
** also basically uncorrelated
** ** ** what is going on?  where are the other kids coming from?

** what are the chances that parents are resident

* father is not present more often than not * don't have a good measure?


xi: xtreg child_out rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out rdp i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg child_out_y rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out_y rdp i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg child_out_o rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out_o rdp i.prov*i.r if u==0, fe cluster(hh1) robust

**** child out is uncorrelated





xi: xtreg child_total rdp i.prov*i.r if u==1 & child_total>0, fe cluster(hh1) robust
xi: xtreg child_total rdp i.prov*i.r if u==0 & child_total>0, fe cluster(hh1) robust



xi: xtreg child_still rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_still rdp i.prov*i.r if u==0, fe cluster(hh1) robust
** much fewer in rural areas?!

xi: xtreg children rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg size rdp i.prov*i.r if u==0, fe cluster(hh1) robust



tab split if a>18
tab split if a<18
** slightly more likely to be split

xi: xtreg size rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg size rdp i.prov*i.r if u==0, fe cluster(hh1) robust


xi: xtreg split rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg split rdp i.prov*i.r if u==0, fe cluster(hh1) robust

** more likely to see split!

xi: xtreg split rdp i.prov*i.r if u==1 & a<16, fe cluster(hh1) robust
xi: xtreg split rdp i.prov*i.r if u==0 & a<16, fe cluster(hh1) robust


hist size if size<18, by(u)

* limit to small initial household size



xi: xtreg child_out i.rdp*i.sizer1 i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg child_out i.rdp*i.sizer1 i.prov*i.r if u==0, fe cluster(hh1) robust

xi: xtreg children i.rdp*i.sizer1 i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg children i.rdp*i.sizer1 i.prov*i.r if u==0, fe cluster(hh1) robust


xi: xtreg children rdp i.prov*i.r if u==1, fe cluster(hh1) robust
xi: xtreg children rdp i.prov*i.r if u==0, fe cluster(hh1) robust
** children increases!

** child_out increases... why / how?!


