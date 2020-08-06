

*HOSPITALIZAÇÕES POR H1N1
*------------------------------------------------------------------------------------------------------------------------*
import 	excel using "$sus/H1N1_Hospitalizations.xlsx", firstrow allstring clear

drop	A D-TOTAL

destring, replace

gen 	year = 2009

merge   1:1 codmunic2 year using "$inter/GDP per capita.dta", keep(3) nogen keepusing(pop treated)

gen 	hosp_h1n1 = hosp/pop  //hospitalizacoes por h1n1 a cada 1000 habitantes

expand 2, gen(REP)

replace year = 2007 if REP == 1

drop 	REP

save "$inter/H1N1.dta",replace
 
su hosp_h1n1 if treated == 1 & year == 2009

su hosp_h1n1 if treated == 0

	twoway (histogram hosp  if  treated == 0,  fcolor(emidblue) lcolor(black) percent) 										///
	       (histogram hosp  if  treated == 1,  percent    																	///
	title("", pos(12) size(medsmall) color(black))																			///
	subtitle("" , pos(12) size(medsmall) color(black))  																	///
	ylabel(, labsize(small)) xlabel(, format (%12.1fc) labsize(small) gmax angle(horizontal)) 								///
	xtitle("", size(medsmall) color(black))  																				///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						///
	fcolor(none) lcolor(black)), legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") region(lwidth(none))) 		///
	note("", color(black) fcolor(background) pos(7) size(small)) 
	*graph export "$figures/histogram_performance.pdf", as(pdf) replace	
	
	
	
	use "$geocodes/mun_brasil.dta", clear
	gen codmunic2 = substr(string(codmunic),1, 6)
	destring codmunic2, replace
	keep if coduf == 35
	gen treated = 0
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	rename id _ID
	gen year = 2009
	

	merge 1:1 codmunic2 year using "$inter/H1N1.dta", nogen 
	
	

		spmap hosp_h1n1 using "$geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 0.14 0.38 1)																					///
		fcolor(gs12 gs8 cranberry) 																						///
		legorder(lohi) 																										///
