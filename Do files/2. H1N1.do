

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
