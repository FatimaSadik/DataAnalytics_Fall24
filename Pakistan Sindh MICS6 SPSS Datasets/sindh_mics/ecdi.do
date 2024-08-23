****************DEVELOPMENT AND SKILLS***********************

**EARLY CHILDHOOD DEVELOPMENT INDEX()
*1. The first step is to imput the address where the questionnaire data is stored

/*2. To calculate ECDI, data from the under-5 questionnaire is used, saved as "ch" and generate a variable for all observations */
use ch,clear
gen total=1

/*3. First, we get rid of all the incomplete questionnaires and keep the information for only.
The relevant MICS variable are:
a. UF17 has information on whether the interview was completed or not
[Usually, UF17==1 indicates that the interview was completed. However, please "tab UF17" and "tab UF17, nol" 
to confirm]
b. UB2 has the age of the child. 
[Please use "tab UB2" and "tab UB2, nol" to confirm the values assigned.
Usually for this indicator we need children older than 36 months and therefore UB2>=3 is the syntax]
*/

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
/*10. ECDI for all children will be given by the following command */
label var develop "early childhood development indicator"
label define develop 0 "Not developed" 1 "Developed"
label values develop develop
/*10. ECDI for all children will be given by the following command */
table (develop) [aw=chweight], statistic(percent,across(develop)) 
collect export "ch1.xlsx"

*table total [pw=chweight], c (mean develop) f(%9.2f) 

/*11. Tabulation to comapre dimension with the total will be giiven by the following command  */
*table total [pw=chweight], c (mean lit_num mean phy mean socio mean learn mean develop) f(%9.2f) 

/* Tabulations based on socioeconomic and demographic MICS variables. These are:
a. HL4 represents gender
b. HH6 represents locaion
c. UB2 represents age
d. UB8 represents ECE attendance
e. disability repesents disability  */
*foreach var of var total HL4 HH6 UB2 UB8 cdisability  {
*table  `var'  [pw=chweight], c (mean lit_num mean phy mean socio mean learn mean develop) f(%9.2f) 
*}

/*13.Save this file as the new variables are useful for further analysis */
*save sindh_ch_ready, replace

table (HH6) (develop)  [aw=chweight], statistic(percent,across(develop))
collect export "ch2.xlsx"
table (HL4) (develop)  [aw=chweight], statistic(percent,across(develop))
collect export "ch3.xlsx"

/*13.Save this file as the new variables are useful for further analysis */

summarize wscore
gen wealth_index=(wscore+2.609)/(2.226+2.609)
//the formula is (actual value-minimum/(max-min))\\
sum wealth_index
label variable wealth_index "wscore normalized"
sort wealth_index
xtile wealth_index_deciles=wealth_index, nq(10) 
tab wealth_index_deciles

label define deciles_wealth_index 1 "D1" 2 "D2" 3 "D3" 4 "D4" 5 "D5" 6 "D6" 7 "D7" 8 "D8" 9 "D9" 10 "D10"
label values wealth_index_deciles deciles_wealth_index
table (develop) (wealth_index_deciles), statistic(percent, across(develop))
collect export "ch4.xlsx"