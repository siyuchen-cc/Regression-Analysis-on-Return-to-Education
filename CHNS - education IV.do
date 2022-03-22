
clear 
set more off
cap log close 

pwd 
cd
log using csy115020011.log, text replace 

use "/Users/csy/Desktop/educ_00.dta", clear 
rename IDind IDIND

merge m:1 IDIND using "/Users/csy/Desktop/mast_pub.dta", clear 

drop _merge
rename IDIND IDind
merge m:1 IDind using "/Users/csy/Desktop/wage.dta", clear 
drop _merge
merge m:1 IDind using "/Users/csy/Desktop/indic_pub.dta", clear 
drop _merge

merge m:1 IDind using "/Users/csy/Desktop/surveys_pub.dta", clear 
drop _merge
merge m:m COMMID using "/Users/csy/Desktop/urban_11.dta", clear 

drop _merge
merge m:m IDind using "/Users/csy/Desktop/jobs_00.dta", clear 

drop _merge
merge m:m IDind using "/Users/csy/Desktop/hlth_12.dta", clear 
drop _merge
merge m:m IDind using "/Users/csy/Desktop/ins_12.dta", clear 

save "/Users/csy/Desktop/chnsall.dta", replace


clear 
set more off
use "/Users/csy/Desktop/chnsall.dta", clear


destring MOON_DOB_Y, replace force
rename MOON_DOB_Y yob

gen HEE=1 if yob>1971
replace HEE=0 if yob<1971

//drop currently studuents 
drop if A13==1

gen Gender=.
replace Gender=1 if GENDER==1 // Male
replace Gender=0 if GENDER==2 // Female

gen education=.
replace education=0 if A11==0
replace education=A11-10 if A11!=0

rename A12 Education_degree

rename indinc_cpi yearly_netincome
replace yearly_netincome=. if yearly_netincome<0
gen logyearly_netincome=log(yearly_netincome)

rename C8 income
replace income=. if income<0
gen logincome=log(income)

gen illness=.
replace illness=1 if M23==1
replace illness=0 if M23==0

gen umployment=.
replace umployment=1 if B2==0
replace umployment=0 if B2==1


gen fulltime_ployment=.
replace fulltime_ployment=0 if C7<40
replace fulltime_ployment=1 if C5>=40

rename WAVE year
rename  index UrbanIndex

gen healthstatua=.
replace healthstatua=1 if M1A==4
replace healthstatua=2 if M1A==3
replace healthstatua=3 if M1A==2
replace healthstatua=4 if M1A==1

set more off
 
// First Stage Regression
xi:ivreg2 education HEE  Gender urban i.year, cluster(T1) first
outreg2 using first.xls, drop(_Iyear*) replace
xi:ivreg2 education HEE  Gender urban healthstatua illness i.year, cluster(T1) first
outreg2 using first.xls, drop(_Iyear*) append
xi:ivreg2 education HEE  Gender urban healthstatua illness econ health market i.year, cluster(T1) first
outreg2 using first.xls, drop(_Iyear*) append
 
 
// Baseline Result
xi:ivreg2 umployment (education=HEE)  Gender urban i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) replace

xi:ivreg2 logincome (education=HEE)  Gender urban i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append
 
xi:ivreg2 fulltime_ployment (education=HEE)  Gender urban i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append

xi:ivreg2 umployment (education=HEE)  Gender urban healthstatua illness i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append

xi:ivreg2 logincome (education=HEE)  Gender urban  healthstatua illness i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append
  
xi:ivreg2 fulltime_ployment (education=HEE)  Gender urban healthstatua illness i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append
  
*** control labor maket
xi:ivreg2 umployment (education=HEE)  Gender urban healthstatua illness econ health market i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append

xi:ivreg2 logincome (education=HEE)  Gender urban econ healthstatua illness health market i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append
 
xi:ivreg2 fulltime_ployment (education=HEE)  Gender urban healthstatua illness econ health market i.year i.T1, cluster(T1) first
outreg2 using table1.xls, drop(_Iyear*) append
  

**** Education Degree
xi:ivreg2 umployment (education=HEE)  Gender urban healthstatua illness econ health market i.year i.T1 if (Education_degree==1)|(Education_degree==2)|(Education_degree==3),cluster(T1) 
outreg2 using table2.xls, drop(_Iyear*) replace
xi:ivreg2 umployment (education=HEE)  Gender urban  healthstatua illness econ health market i.year i.T1 if (Education_degree==4)|(Education_degree==5)|(Education_degree==6),cluster(T1) 
outreg2 using table2.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE)  Gender urban healthstatua illness econ health market i.year i.T1 if (Education_degree==1)|(Education_degree==2)|(Education_degree==3),cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE)  Gender urban  healthstatua illness econ health market i.year i.T1 if (Education_degree==4)|(Education_degree==5)|(Education_degree==6),cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
 
 
**** urban-rural
xi:ivreg2 umployment (education=HEE)  Gender healthstatua illness econ health market i.year i.T1 if urban==1 ,cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
xi:ivreg2 umployment (education=HEE)  Gender healthstatua illness econ health market i.year i.T1 if urban==0 ,cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE)  Gender healthstatua illness econ health market i.year i.T1 if urban==1 ,cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE)  Gender healthstatua illness econ health market i.year i.T1 if urban==0 ,cluster(T1) 
outreg2 using table22.xls, drop(_Iyear*) append
  
  
  
***Gender difference 

xi:ivreg2 umployment (education=HEE) urban healthstatua illness econ health market i.year i.T1 if Gender==1 ,cluster(T1) 
outreg2 using table221.xls, drop(_Iyear*) append
xi:ivreg2 umployment (education=HEE)  urban  healthstatua illness econ health market i.year i.T1 if Gender==0 ,cluster(T1) 
outreg2 using table221.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE) urban healthstatua illness econ health market i.year i.T1 if Gender==1 ,cluster(T1) 
outreg2 using table221.xls, drop(_Iyear*) append
xi:ivreg2 logincome (education=HEE)  urban  healthstatua illness econ health market i.year i.T1 if Gender==0 ,cluster(T1) 
outreg2 using table221.xls, drop(_Iyear*) append



////testing for Rregression Discontinuity 

////X is the distance 

gen X=yob-1971
gen D=(X>=0)

gen DX=D*X
gen X2=X*X
gen DX2=D*X2
gen X3=X*X*X
gen DX3=D*X3


///density test
histogram X, discrete width(1) xline(0) legend(col(2)) xtitle("Birth Year and Month")
graph save "/Users/csy/Desktop/graph", replace
graph export "/Users/csy/Desktop/graph.tif", as(tif) replace


/// graph education
preserve

rdbwselect education X, bwselect(CCT)
gen bw_education_CCT=round(e(h_CCT)) //save IK h for male

reg education D X DX X2 DX2 if abs(X)<=bw_education_CCT, cluster(X)

predict hat_education if e(sample) //local linear fit
predict sd_education if e(sample), stdp //standard errors of local linear fit
gen ub_education=hat_education+1.96*sd_education //95% confidence interval
gen lb_education=hat_education-1.96*sd_education


rdbwselect logincome X, bwselect(CCT)
gen bw_logincome_CCT=round(e(h_CCT)) //save IK h for male

reg logincome D X DX if abs(X)<=bw_logincome_CCT, cluster(X)

predict hat_logincome if e(sample) //local linear fit
predict sd_logincome if e(sample), stdp //standard errors of local linear fit
gen ub_logincome=hat_logincome+1.96*sd_logincome //95% confidence interval
gen lb_logincome=hat_logincome-1.96*sd_logincome


*Graph

by X, sort: egen mean_logincome=mean(logincome) //mean outcome in each bin

keep if abs(X)<=bw_logincome_CCT+1

twoway 	(scatter mean_logincome X , mcolor(navy navy navy) msize(small small small) msymbol(0)) ///
(rline ub_logincome lb_logincome X if X<0, sort lpattern(dash)) ///
(rline ub_logincome lb_logincome X if X>=0, sort lpattern(dash)) ///
(line hat_logincome X if  X<0, sort lcolor(black) lwidth(medthick)) ///
(line hat_logincome X if  X>=0, sort lcolor(black) lwidth(medthick)), ///
ytitle(" ") xtitle(distance to the cutoff) xline(0) ///
title("logincome", size(large))
graph save "/Users/csy/Desktop/income", replace
graph export "/Users/csy/Desktop/income.tif", as(tif) replace
