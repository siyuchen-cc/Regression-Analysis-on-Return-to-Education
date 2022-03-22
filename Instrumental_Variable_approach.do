
clear 
set more off

clear
use "/Users/csy/Desktop/ecfps2010adult.dta"
rename qe2 marriage 
save "/Users/csy/Desktop/ecfps2010adult.dta", replace


clear
use "/Users/csy/Desktop/ecfps2012adult.dta"
rename cfps2010_marriage marriage  ////married=1, not married=2/// 
rename cfps2010_eduy eduy
rename cfps2010_qa1y_best qa1y_best
rename provcd qa102acode
rename urban12 urban
save "/Users/csy/Desktop/ecfps2012adult.dta", replace

clear
use "/Users/csy/Desktop/ecfps2014adult.dta"
rename urban14 urban
rename cfps2012_marriage marriage  ////married=1, not married=2/// 

rename CFPS_BIR qa1y_best
rename provcd14 qa102acode
save "/Users/csy/Desktop/ecfps2014adult.dta", replace
 
 
clear
use "/Users/csy/Desktop/ecfps2016adult.dta"
rename urban16 urban
rename marriagen marriage ////married=1, not married=0/// 

replace marriage=2 if marriage==0 ////married=1, not married=2/// 
rename cfps_birthy qa1y_best
rename provcd16 qa102acode
save "/Users/csy/Desktop/ecfps2016adult.dta", replace

 use "/Users/csy/Desktop/ecfps2010adult.dta", clear
 append using "/Users/csy/Desktop/ecfps2012adult.dta", force
 append using "/Users/csy/Desktop/ecfps2014adult.dta", force

 

 save "/Users/csy/Desktop/CFPSall.dta", replace
 
 //////
  clear 
 set more off
 use "/Users/csy/Desktop/CFPSall.dta", clear
 
 
gen yob=qa1y_best
replace yob=. if qa1y_best<0
gen mob=qa1m
replace mob=. if qa1m<0

gen birth=ym(yob, mob) 



replace marriage=. if marriage<0
replace marriage=. if (marriage!=1)&(marriage!=2)

gen province=qa102acode
replace province=. if qa102acode<0

format birth %tm

gen cutoff=ym(1979,09)

//受政策影响前后 10 年时间内 出生的个体，即出生于 1962 年 1 月至 1982 年 12 月
keep if birth>=ym(1959,01)


////X is the distance 

gen X=ym(yob,mob)-cutoff

gen D=(X>=0)


gen DX=D*X
gen X2=X*X
gen DX2=D*X2
gen X3=X*X*X
gen DX3=D*X3



gen education=eduy

replace education=. if eduy<0


rename cfps2010_gender gender2010
rename cfps2012_gender gender2012
rename cfps_gender gender2016 
egen Male= rowtotal(employ*)

gen self_health=qp3 
replace self_health=. if qp3 <0

gen healthstatus=qz202
replace healthstatus=. if qz202<0


gen logincome=log(income)
replace logincome=. if income<0


rename employ employ1
egen employment= rowtotal(employ*)

gen unemployment=.
replace unemployment=0 if employment==1
replace unemployment=1 if (employment==0)|(employment==3)


///density test
histogram X, discrete width(1) xline(0) legend(col(2)) xtitle("Birth Year and Month")
graph save "/Users/csy/Desktop/ECO3211_PS3/CFPS2010/density_graph", replace
graph export "/Users/csy/Desktop/ECO3211_PS3/CFPS2010/density_graph.tif", as(tif) replace


/// graph education
preserve

rdbwselect education X, bwselect(CCT)
gen bw_education_CCT=round(e(h_CCT)) //save IK h for male

reg education D X DX X2 DX2 if abs(X)<=bw_education_CCT, cluster(X)

predict hat_education if e(sample) //local linear fit
predict sd_education if e(sample), stdp //standard errors of local linear fit
gen ub_education=hat_education+1.96*sd_education //95% confidence interval
gen lb_education=hat_education-1.96*sd_education


*Graph



keep if abs(X)<=bw_education_CCT+1
by X, sort: egen mean_education=mean(education)
twoway 	(scatter mean_education X , mcolor(navy navy navy) msize(medium medium medium) msymbol(0)) ///
(rline ub_education lb_education X if X<0, sort lpattern(dash)) ///
(rline ub_education lb_education X if X>=0, sort lpattern(dash)) ///
(line hat_education X if  X<0, sort lcolor(black) lwidth(medthick)) ///
(line hat_education X if  X>=0, sort lcolor(black) lwidth(medthick)), ///
ytitle(" ") xtitle(distance to the cutoff) xline(0) ///
title("education", size(small))
graph save "/Users/csy/Desktop/educ", replace
graph export "/Users/csy/Desktop/educ.tif", as(tif) replace

restore 



//// Income 不显著 但是有cutoff

*Graph

preserve

rdbwselect logincome X, bwselect(CCT)
gen bw_logincome_CCT=round(e(h_CCT)) //save IK h for male

reg logincome D X DX if abs(X)<=bw_logincome_CCT, cluster(X)

predict hat_logincome if e(sample) //local linear fit
predict sd_logincome if e(sample), stdp //standard errors of local linear fit
gen ub_logincome=hat_logincome+1.96*sd_logincome //95% confidence interval
gen lb_logincome=hat_logincome-1.96*sd_logincome


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

restore 

///// first-stage 
xi:ivreg2 education D X DX male urban Agriculturalhukou marriage province  i.cyear i.provcd, cluster(X)


xi:ivreg2 logincome (education=D) X DX male urban Agriculturalhukou marriage province  i.cyear i.provcd, cluster(X)

outreg2 using Table_Parametric, excel dec(3) drop(_I*)


xi:ivreg2 unemployment (education=D) male urban Agriculturalhukou marriage province  i.cyear i.provcd, cluster(X)

outreg2 using Table_Parametric, excel dec(3) drop(_I*)
