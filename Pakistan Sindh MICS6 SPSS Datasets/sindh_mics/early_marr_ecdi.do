
use wm_hh_ch
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
gen weduc=.
replace weduc=welevel if welevel!=9
label define weduc 0 "No educ/preschool" 1 "Primary" 2 "Middle" 3 "secondary" 4 "Higher"
label values weduc weduc
rename HH6 area
gen child_mar=.
replace child_mar=0 if early_m==0
replace child_mar=1 if early_m==1 |early_m==2
label define child_mar 0 "No" 1 "Yes"
label values child_mar child_mar

***ECDI****
keep if UF17==1 
keep if UB2>=3 

/*4. ECDI comprises of four skills. Therefore, generate 4 new variables for each skill: 
a. "lit_num" for literacy and numeracy domain, 
b. "phy" for physical domain,
c. "socio_em" for social and emotional domain; and
d. "learn" for the learning domain   */ 
gen lit_num=0
gen phy=0
gen socio_em=0
gen learn=0

/*5. LIT AND NUMERACY: Replace values for proficiency in "lit_num" using MICS variables. 
The relevant variables are:
a. EC6 which has information on whether the child identifies at least ten letters of the alphabet 
 [EC6==1 means the child was able to execute the task and; EC6==2 means they were not able to execute it]
b. EC7 has information on whether the child was able to read four simple, popular words
[EC7==1 means the child was able to read four simple, popular words and; EC7==2 means they were unable to do so]
c. EC8 has information on whether the child was able to recognize the symbol of all numbers ffrom 1 to 10
[EC8==1 means the child was able to recognize the symbols; EC8==2 means the child was unable to do so]
A child is developmentally on track in literacy-numeracy if they can perform atleast 2 of these tasks.*/
replace lit_num=1 if EC6+EC7+EC8==2|EC6+EC7+EC8==3

/*6. PHYSICAL: Replace values for proficiency in "phy"  using MICS variables. 
The relevant variables are: 
a. EC9 which has information on whether child is able to pick up small objects using two fingers
[EC9==1 means the child was able to pick up the small object using two fingers; EC9==2 means that child was unable to do so
b. EC10   which has information on whether the child was too sick sometimes to play
[EC10==1 means the child was too sick sometimes to play; EC10==2 means the child was not too sick to play]  
A child is developmentally on track in physical if one of the two is true. */
replace phy=1 if EC9==1|EC10==1
/*7. SOCIAL EMOTIONAL: Replace values for proficiency in "socio_em" using MICS variables. 
The relevant variables are: 
a. EC13 which has information on whether child gets along with other children
[EC13==1 means the child does get along with other children; EC13==2 means the child does not get along]
b. EC14 which has information on whether the child kicks, bites or hits other children or adults
[EC14==1 means the child does kick, bite or hit children or adults; EC14==2 means the child does not]
c. EC15  which has information on whether child gets ditracted easily
[EC15==1 means the child does get distracted easily; EC15==2 means the child does not get distracted]
A child is developmentally on track in social and emotional skills if atleast two of the questions are true*/
replace socio_em=1 if EC13+EC14+EC15==2|EC13+EC14+EC15==3
/*8. LEARNING: Replace values for proficiency in "lear" using MICS variables.
The relevant variables are: 
a.  EC11 which has information on whether the child is able to follow simple directions 
[EC11==1 means the child is able to follow simple directions; EC11==2 means the child is unable to follow simple instructions]
b. EC12 which has information on whether the child is able to do things independently
[EC12==1 means the child is able to do things independently; EC12==2 means the child is unable to do things independently]
A child is developmentally on track in learning if atleast one of the question is true */
replace learn=1 if EC11==1|EC12==1
/*9. Generate a new variable "develop" to calculate ECDI. Childrenren are on track if they are on track in atleast three dimensions.
[develop=1 means children are developmentally on track
develop=0 means children are not developmentally on track] */
gen develop=0
replace develop=1 if lit_num+phy+socio+learn==3|lit_num+phy+socio+learn==4
label var develop "early childhood development indicator"
label define develop 0 "Not developed" 1 "Developed"
label values develop develop

logit develop i.early_m
outreg2 using sindh.xls
logit develop i.early_m i.weduc wscore i.area 
outreg2 using sindh.xls

keep develop early_m weduc wscore area
gen province="sindh"
save sindh_em_ecdi