* look for loan evidence


cd "/Users/willviolette/Desktop/pstc_work/nids"


use "div1.dta", clear

g house=dwell==1
g hut=dwell==2
g hab=(house==1 | hut==1)
g inf=(dwell>=6 & dwell<=8)

g rdp=h==1
replace rdp=1 if h==-9

drop if hh_income>20000

g hi=.
forvalues r=0(1000)20000 {
replace hi=`r' if hh_income>=`r' & hh_income<`r'+1000
}


collapse house hut hab inf, by(r hi rdp)


twoway scatter house hi if r==1 & rdp==1, color(blue) || scatter house hi if r==1 & rdp==0, color(red)

twoway scatter house hi if r==2 & rdp==1, color(blue) || scatter house hi if r==2 & rdp==0, color(red)

twoway scatter house hi if r==3 & rdp==1, color(blue) || scatter house hi if r==3 & rdp==0, color(red)


twoway scatter hut hi if r==1 & rdp==1, color(blue) || scatter hut hi if r==1 & rdp==0, color(red)

twoway scatter hut hi if r==2 & rdp==1, color(blue) || scatter hut hi if r==2 & rdp==0, color(red)

twoway scatter hut hi if r==3 & rdp==1, color(blue) || scatter hut hi if r==3 & rdp==0, color(red)



twoway scatter hab hi if r==1 & rdp==1, color(blue) || scatter hab hi if r==1 & rdp==0, color(red)

twoway scatter hab hi if r==2 & rdp==1, color(blue) || scatter hab hi if r==2 & rdp==0, color(red)

twoway scatter hab hi if r==3 & rdp==1, color(blue) || scatter hab hi if r==3 & rdp==0, color(red)




twoway scatter inf hi if r==1 & rdp==1, color(blue) || scatter inf hi if r==1 & rdp==0, color(red)

twoway scatter inf hi if r==2 & rdp==1, color(blue) || scatter inf hi if r==2 & rdp==0, color(red)

twoway scatter inf hi if r==3 & rdp==1, color(blue) || scatter inf hi if r==3 & rdp==0, color(red)

