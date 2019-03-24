
cd "/Users/willviolette/Desktop/pstc_work/nids"


use hh_v1, clear
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1

keep rdp_m rdp_n a size af children edu inc piped elec rooms u

bys rdp_m rdp_n u: outreg2 using sum_1_m_n, sum(log) eqkeep(mean N)  label excel replace 



use hh_v1, clear
keep if max_inc<10000
keep if a>18

* keep if sr==321
keep if tt!=.
g rdp_m=rdp*move
g rdp_n=rdp
replace rdp_n=0 if move==1


sort pid r
by pid: g rdp_m_sw=rdp_m[_n+1]-rdp_m[_n]
drop if rdp_m_sw==-1
by pid: g rdp_n_sw=rdp_n[_n+1]-rdp_n[_n]
drop if rdp_n_sw==-1


keep rdp_m_sw rdp_n_sw a size af children edu inc piped elec rooms u

bys rdp_m_sw rdp_n_sw u: outreg2 using sum_2_final, sum(log) eqkeep(mean N) label excel replace 




