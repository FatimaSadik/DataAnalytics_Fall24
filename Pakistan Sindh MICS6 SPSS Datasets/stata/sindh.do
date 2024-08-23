//MICS cleaning
//Fatima Sadik-IBA
clear
set more off
cd "C:\Users\fatimasadik\OneDrive - Institute of Business Administration\unicef_MH\Pakistan Sindh MICS6 SPSS Datasets\stata"
use "wm.dta"
merge 1:m HH1 HH2 LN using bh.dta
drop if merge==2
rename _merge merge1

//merging women's data with their HH
merge m:1 HH1 HH2 using hh.dta
rename _merge merge2
drop if merge2==2
gen UF4=WM3
merge m:m HH1 HH2 UF4 using ch.dta
drop if merge==2
rename _merge merge3

