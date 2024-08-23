use wm.dta
collect clear
//using complete interviews
keep if WM17==1
/*3. Generate a variable for early marriage if men or women responded to the
question on marriage. 
If deriving only for women use 'MA1', and if only for men use 'MMA1'*/
gen early_m=0 if MA1!=.
/*4.Generate a variable for married when 15, and make it 0 if early marriage is 0 */
gen early15=0 if early_m==0
/*5.Generate a variable for married when 18, and make it 0 if early marriage is 0 */
gen early18=0 if early_m==0
/*6. Based on age at first marriage (WAGEM in women's dataset and MWAGEM in men's dataset) 
input the value for variables created in steps 4 and 5. */
replace early15=1 if WAGEM<=14
replace early18=1 if (WAGEM>=15 & WAGEM<18)
/*7. Men or women are assumed to be married early if they marry before 18. 
For better disaggregation, use marriage before 15 as well.  */
replace early_m=1 if early15==1
replace early_m=2 if early18==1
/*8.Define label values, as follows */
lab def lab_early_m  0 "No early marriage" 1 "Married < 15" 2 "Married 15 and 18"
/*9. Associate label values with variable*/
lab val early_m lab_early_m
/*10. Simple tabulation*/
tab early_m
gen weduc=.
replace weduc=welevel if welevel!=9
label define weduc 0 "No educ/preschool" 1 "Primary" 2 "Middle" 3 "secondary" 4 "Higher"
label values weduc weduc
tab weduc
tab weduc early_m
tab weduc early_m, col
table (weduc) (early_m), statistic(percent, across(weduc))

rename HH6 area
tab area early_m, col
table (area) (early_m), statistic(percent, across(area))
collect export "file3.xlsx"
gen preg_now=.
replace preg_now=1 if CP1==1
replace preg_now=0 if CP1==2 |CP1==8
label define preg_now 1 "yes" 0 "no"
label values preg_now preg_now

tab preg_now if WAGE<18 & early_m!=0 [aweight= wmweight ]
table (preg_now) [aweight= wmweight ] if WAGE<18& early_m!=0, statistic(percent, across(preg_now))
collect export "a3.xlsx"
tab CM1
rename CM1 birth_ever 
table (birth_ever) if WAGE<18 & early_m!=0 [aweight= wmweight ],statistic(percent, across(birth_ever))
collect export "a4.xlsx"
//child born but died early
rename CM8 child_died
table (child_died) if WAGE<18 & early_m!=0 [aw=wmweight], statistic(percent, across(child_died))
collect export "a5.xlsx"
rename MN2 prenatal_care
drop if prenatal_care==9
//RECEIVED PRENATAL CARE
table (prenatal_care) if WAGE<18 & early_m!=0 & birth_ever==1 [aw=wmweight], statistic(percent, across(prenatal_care))
collect export "a6.xlsx"
tab prenatal_care early_m if WAGE<18, col
table (prenatal_care) (early_m) if WAGE<18 [aw=wmweight], statistic(percent, across(prenatal_care))
collect export "a7.xlsx"
tab prenatal_care child_died[aw=wmweight],col
table (prenatal_care) (child_died) [aw=wmweight],statistic(percent, across(prenatal_care))
collect export "a8.xlsx"
rename MN32 birth_size
tab birth_size, nolabel
drop if birth_size==8
drop if birth_size==9
tab birth_size early_m [aw=wmweight], col
table (birth_size) (early_m) [aw=wmweight],statistic(percent, across(birth_size))
collect export "a9.xlsx"
gen satisfied=.
replace satisfied=0 if LS3==3 
replace satisfied=1 if LS3==2
replace satisfied=2 if LS3==1
label define  satisfied 0 "worse" 1 "same" 2 "better"

label values satisfied satisfied
gen child_mar=.
replace child_mar=0 if early_m==0
replace child_mar=1 if early_m==1 |early_m==2
label define child_mar 0 "No" 1 "Yes"
label values child_mar child_mar
tab satisfied
label variable satisfied "Life satisfaction compared to last year"
tab satisfied child_mar if WAGE<18 [aw=wmweight], col 
table (satisfied) (child_mar) if WAGE<18 [aw=wmweight],statistic(percent, across(satisfied))
collect export "a10.xlsx", replace
ologit satisfied i.child_mar
ologit satisfied i.child_mar if WAGE<20 [aw=wmweight]
outreg2 using results.doc
//probability of being most satisfied with life is lower for women who were married before 18 as compared to those who were married after 18
gen wealth_index=(wscore+3.110997)/(2.61825+3.110997)
//the formula is (actual value-minimum/(max-min))\\
sum wealth_index
label variable wealth_index "wscore normalized"
sort wealth_index
xtile wealth_index_deciles=wealth_index, nq(10) 
tab wealth_index_deciles
label define deciles_wealth_index 1 "D1" 2 "D2" 3 "D3" 4 "D4" 5 "D5" 6 "D6" 7 "D7" 8 "D8" 9 "D9" 10 "D10"
label values wealth_index_deciles deciles_wealth_index
tab child_mar wealth_index_deciles, col
table (child_mar) (wealth_index_deciles), statistic(percent, across(child_mar))

collect export "a11.xlsx"
table (child_died) (wealth_index_deciles), statistic(percent, across(child_died))

collect export "a12.xlsx"

table (prenatal_care) (wealth_index_deciles), statistic(percent, across(prenatal_care))

collect export "a13.xlsx"

table (child_mar) (child_died) if wealth_index_deciles==1,statistic(percent, across(child_mar)) 

collect export "a14.xlsx"

table (child_mar) (child_died) if wealth_index_deciles==10,statistic(percent, across(child_mar)) 

collect export "a15.xlsx"

table (child_mar) (child_died) if wealth_index_deciles==5,statistic(percent, across(child_mar)) 

collect export "a16.xlsx"
gen size=.

