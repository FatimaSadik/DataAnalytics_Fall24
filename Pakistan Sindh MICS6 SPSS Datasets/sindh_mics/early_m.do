use wm.dta
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
tab welevel early_m
tab HH6 early_m