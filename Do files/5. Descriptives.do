
*----------------------------------------------------------------------------------------------------------------------------*
*WHAT WILL HAPPEN WITH IDEB AFTER COVID?
*----------------------------------------------------------------------------------------------------------------------------*
	use "$ideb/IDEB at municipal level.dta" if network == 3, clear
	gen treated = 0
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}

	keep if treated
	
	collapse (mean) idebEF1 targetEF1 math5 port5 approval5 spEF1, by (year)
	sort year
	
	replace math5 		= math5[_n-1] - 20  if year == 2021  //considering that we will lose one year of learning, which is estimated do be equivalent to 20 points in the SAEB score scale. 
	replace port5 		= port5[_n-1] - 20  if year == 2021 
	replace approval5   = approval5[_n-1] 	if year == 2021 
	
	gen media_nota = (math5+port5)/2
	
	gen var = media_nota[_n]/media_nota[_n-1] - 1
	
	replace spEF1 = spEF1[_n-1] + spEF1[_n-1]*var if year ==  2021 

	replace idebEF1 = spEF1*approval5 if year == 2021

	tw 	///
	(line idebEF1 year if year < 2021, lwidth(0.5) color(navy) lp(solid) connect(direct) recast(connected) 	 													///  
	ml() mlabcolor(gs2) msize(2) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
	(line targetEF1  year, lwidth(0.5) color(emidblue) lp(shortdash) connect(direct) recast(connected) 	 														///  
	ml() mlabcolor(gs2) msize(2) ms(o) mlabposition(12)  mlabsize(2.5))																							///
	(line idebEF1 year if year > 2017, lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 										///  
	ml() mlabcolor(gs2) msize(2) ms(o) mlabposition(12)  mlabsize(2.5)																							///
	ylabel(, labsize(small) gmax angle(horizontal) format(%4.1fc))											     												///
	yscale( alt )  																																				///
	title(, pos(12) size(medium) color(black))													 																///
	ytitle("IDEB, 1{sup:st} to 5{sup:th} grades", size(medium))																									/// 																																				///
	xtitle("") 																																					///
	xlabel(2005(2)2021, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
	legend(order(1 "Education Development Index" 2 "Target" 3 "After Covid" ) cols(1) size(large) region(lwidth(none) color(white) fcolor(none))) 				///
	ysize(5) xsize(7) 																										 									///
	note("", color(black) fcolor(background) pos(7) size(small)))  
	graph export "$figures/ideb_projected.pdf", as(pdf) replace

	


*----------------------------------------------------------------------------------------------------------------------------*
*Parallel trends 
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	duplicates drop tipo_municipio_ef1 codmunic year, force
	keep codmunic year tipo_municipio_ef1
	tempfile tipo
	save `tipo'
	
	use "$ideb/IDEB at municipal level.dta", clear
	

	keep if uf == "SP" & (network == 2 | network == 3) & year < 2009
	
		merge m:1 codmunic year using `tipo', nogen keep(3)


	gen id_M    = 1
	gen id_13_M = 0


	foreach munic in $treated_municipalities {
		replace id_M = 0 if codmunic == `munic'
		replace id_13_M = 1 if codmunic == `munic'
	}



	
	gen D = (year == 2007)
	gen G = id_M == 1
	gen E = network == 2
	gen beta1  = E
	gen beta2  = G
	gen beta3  = D
	gen beta4  = E*G
	gen beta5  = E*D
	gen beta6  = G*D
	gen beta7  = E*G*D 

reg math5 beta1-beta7


	
	use "$ideb/IDEB at municipal level.dta" , clear
	merge 1:1 codmunic year network using "$censoescolar/Enrollments at municipal level", nogen
	keep if uf == "SP" & (network == 2 | network == 3) & year < 2010
	sort codmunic year
	replace enrollment5grade = enrollment5grade[_n+1] if year[_n] == 2008 & year[_n+1] == 2009 & codmunic[_n] == codmunic[_n+1]
	merge m:1 codmunic year using `tipo', nogen keep(3)
		
	gen id_M = 1
	foreach munic in $treated_municipalities {
		replace id_M	  = 0 if codmunic == `munic'
	}	
	
	
		collapse (mean)math5 port5 [aw = enrollment5grade], by(year id_M network)
						tw 	///
						(line math5  year if network == 2, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 												///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
						(line math5  year if network == 3, by(id_M) lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 	///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
						ylabel(, labsize(small) gmax angle(horizontal) format(%4.1fc))											     												///
						yscale( alt )  																																				///
						title("", pos(12) size(medium) color(black))													 															///
						xtitle("")  																																				///
						xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "Estadual"  2 "Municipal"  3 "Contrafactual") size(small) region(lwidth(none) color(white) fcolor(none))) 									///
						ysize(5) xsize(5) 																										 									///
						note("", color(black) fcolor(background) pos(7) size(small)))  
						*graph export "$figures/trend_math.pdf", as(pdf) replace
						graph export "$figures/time trend for Math_graph in `language'.pdf", as(pdf) replace

	
	reshape wide math5 port5, i(year id_M) j(network)
	gen dif_math = math52-math53 
	
	gen dif_port = port52-port53 

						tw 	///
						(line math5  year if network == 3, by(id_M) lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 	///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
						ylabel(, labsize(small) gmax angle(horizontal) format(%4.1fc))											     												///
						yscale( alt )  																																				///
						title("", pos(12) size(medium) color(black))													 															///
						xtitle("")  																																				///
						xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "Estadual"  2 "Municipal"  3 "Contrafactual") size(small) region(lwidth(none) color(white) fcolor(none))) 									///
						ysize(5) xsize(5) 																										 									///
						note("", color(black) fcolor(background) pos(7) size(small)))  
						*graph export "$figures/trend_math.pdf", as(pdf) replace
						graph export "$figures/time trend for Math_graph in `language'.pdf", as(pdf) replace



*----------------------------------------------------------------------------------------------------------------------------*
*Tendência no tempo 
*----------------------------------------------------------------------------------------------------------------------------*

	*Math
	*------------------------------------------------------------------------------------------------------------------------*
		use "$inter/trend_math.dta", clear
		gen 	contrafactual = math5 + 4 if treated == 1 & year == 2009
		replace contrafactual = math5     if treated == 1 & year == 2007

			foreach language in english {

				if "`language'" == "english" {
					local ytitle  = "Test score, SAEB scale" 
					local legend1 = "Extended winter break"
					local legend2 = "Other municipalities"
					*local title   = "Math, 5{sup:th} grade"
					local note    = "Source: Prova Brasil." 
				}
				
				
				if "`language'" == "portuguese" {
					local ytitle  = "Proficiência, Escala SAEB" 
					local legend1 = "Adiamento das aulas"
					local legend2 = "Outros municípios"
					*local title   = "Matemática, 5{sup:o} ano"
					local note    = "Fonte: Prova Brasil." 
				}
					
						tw 	///
						(line math5 year if treated == 1, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 												///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
						(line math5 year if treated == 0, lwidth(0.5) color(gs12) lp(solid) connect(direct) recast(connected)  	 												 	///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(3)  mlabsize(2.5)) 										 													///
						(line contrafactual year if treated == 1 & (year == 2007 | year == 2009), lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 	///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
						ylabel(, labsize(small) gmax angle(horizontal) format(%4.0fc))											     												///
						yscale( alt )  																																				///
						xscale(r(2005(2)2009)) 																																		///
						yscale(r(170(10)220)) 																																		///
						ytitle("`ytitle'", size(small)) 																					 										///
						title("", pos(12) size(medium) color(black))													 															///
						xtitle("")  																																				///
						xlabel(2005(2)2009, labsize(medsmall) gmax angle(horizontal) format(%4.0fc))											     									///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "`legend1'"  2 "`legend2'"  3 "Contrafactual") pos(12) cols(1) size(medlarge) region(lwidth(none) color(white) fcolor(none))) 									///
						ysize(5) xsize(5) 																										 									///
						note("`note'", span color(black) fcolor(background) pos(7) size(small)))  
						*graph export "$figures/trend_math.pdf", as(pdf) replace
						graph export "$figures/time trend for Math_graph in `language'.pdf", as(pdf) replace
					
			}
		 
		 
	*Port
	*------------------------------------------------------------------------------------------------------------------------*
		use "$inter/trend_port.dta", clear
		gen 	contrafactual = port5 + 1 if treated == 1 & year == 2009
		replace contrafactual = port5 	  if treated == 1 & year == 2007

						tw 	///
						(line port5 year if treated == 1, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 		 											///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
						(line port5 year if treated == 0, lwidth(0.5) color(gs12) lp(solid) connect(direct) recast(connected)  	 													///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(3)  mlabsize(2.5)) 										 													///
						(line contrafactual year if treated == 1 & (year == 2007 | year == 2009), lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 	///  
						ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
						ylabel(170(10)200, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
						yscale( alt )  																																				///
						xscale(r(2005(2)2009)) 																																		///
						yscale(r(170(10)200)) 																																		///
						ytitle("Test score, SAEB scale", size(small)) 																					 							///
						xlabel(2005(2)2009, labsize(medsmall) gmax angle(horizontal) format(%4.0fc))											     									///
						title("", pos(12) size(medium) color(black))																												///
						xtitle("")  																																				///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "Extended winter break"  2 "Other municipalities"  3 "Contrafactual") cols(1) pos(12) size(medlarge) region(lwidth(none) color(white) fcolor(none))) 			///
						ysize(5) xsize(5) 																																			///
						note("Source: Prova Brasil.", span color(black) fcolor(background) pos(7) size(small)))  
						graph export "$figures/time trend for Portuguese_graph in english.pdf", as(pdf) replace
						
						

*----------------------------------------------------------------------------------------------------------------------------*
*Grupos de tratamento e comparação
*----------------------------------------------------------------------------------------------------------------------------*
	use "$geocodes/mun_brasil.dta" if coduf == 35, clear
	gen treated = 0
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	rename id _ID
	gen 	grupo = 1 if treated == 1
	replace grupo = 2 if treated == 0

		spmap  grupo using "$geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 1 2)																					///
		fcolor(cranberry*0.8 gs12 ) 																						///
		legorder(lohi) 																										///
		legend(order(2 "Extended winter break" 3 "Other municipalities") size(vlarge)) saving (distance_`distance', replace)
		graph export "$figures/tratamento_comparacao_englisg.pdf", as(pdf) replace
		graph export "$figures/tratamento_comparacao_english.png", as(png) replace
		
		spmap  grupo using "$geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 1 2)																					///
		fcolor(cranberry*0.8 gs12 ) 																						///
		legorder(lohi) 																										///
		legend(order(2 "Adiamento das aulas" 3 "Outros municípios") size(medium)) saving (distance_`distance', replace)
		*graph export "$figures/tratamento_comparacao.pdf", as(pdf) replace
		graph export "$figures/tratamento_comparacao_port.pdf", as(pdf) replace
		
		
	
*----------------------------------------------------------------------------------------------------------------------------*
*Rede afetada
*----------------------------------------------------------------------------------------------------------------------------*
	use 	"$inter/Enrollments at school level.dta", clear
	gen treated = .
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	replace treated   = 0 if treated == .
	
	keep 		if year == 2009 & (network == 3 | network == 2)
	collapse 	(sum)enrollmentEF, by (codschool treated)
	gen 		var1 = 1 if enrollmentEF > 0		//if the school has EI or EF
	drop 		if var1 == . 
	collapse 	(sum)var1 enrollmentEF*, by (treated)
		
	gen 		var2 = enrollmentEF
	drop 		enrollmentEF
	reshape 	long var, i(treated) j(tipo) 
	reshape 	wide var, i(tipo)    j(treated)
	
	label 		define municipalites 1 "School" 2 "Enrollments"
	label 		val    tipo municipalites
	set scheme s1mono
	graph pie var1 var0 , by(tipo, graphregion(fcolor(white))) pie(1,  color(cranberry*0.7)) pie(2, explode color(gs14))     							///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))  													///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 												 	///
	plabel(_all percent, gap(5) format(%12.1fc) size(medium)) 																							///
	title(, pos(12) size(medsmall) color(black)) 																										///
	legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6)) 	///
	note("Source: School Census, 2009.", span color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/students_affected.pdf", as(pdf) replace	 
		
		
*----------------------------------------------------------------------------------------------------------------------------*
*Desempenho
*----------------------------------------------------------------------------------------------------------------------------*
	set scheme economist
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if math5 > 300, clear

	twoway (histogram math5  if year == 2007 & treated == 1,  fcolor(emidblue) lcolor(black) percent) 													///
	       (histogram math5  if year == 2007 & treated == 0,  percent    																				///
	title("Math, 5{sup:th} grade", pos(12) size(medium) color(black))																					///
	subtitle("" , pos(12) size(medsmall) color(black))  																								///
	ylabel(, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 															///
	yscale(alt) 																																		///
	xtitle("Test score", size(medsmall) color(black))  																									///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
	ysize(5) xsize(7) 																																	///
	fcolor(none) lcolor(black)), legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6)) ///
	note("Source: INEP, 2007.", span color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/histogram_performance.pdf", as(pdf) replace	
	
	
*----------------------------------------------------------------------------------------------------------------------------*
*Histogram of gdp per capita				
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/GDP per capita.dta", clear
	replace pib_pcap= pib_pcap/1000
	
	foreach munic in $treated_municipalities {
		su 	  pib_pcap if codmunic == `munic'
		local pos`munic' = r(mean)
	}
	
	su 	  pib_pcap, detail
	local media = string(`r(mean)',"%10.2fc")
	local mean = r(mean)
	
	
	twoway (histogram pib_pcap  if year == 2007 , percent    																	///
	title("", pos(12) size(medsmall) color(black))																				///
	ylabel(0(5)20, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 							///
	ytitle("%", size(medsmall) color(black))  																					///
	yscale(alt) 																												///
	xtitle("In thousands 2009 BRL", size(medsmall) color(black))  																			///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	fcolor(none) lcolor(emidblue*1.5)),	///
	text(14 `pos3550308' "{bf:São Paulo}" 			 , size(vsmall) color(emidblue)) ///
	text(10 `pos3509502' "{bf:Campinas}"  			 , size(vsmall) color(emidblue)) ///
	text(8  `pos3513801' "{bf:Diadema}"   			 , size(vsmall) color(emidblue)) ///
	text(12 `pos3520509' "{bf:Indaiatuba}"			 , size(vsmall) color(emidblue)) ///
	text(10 `pos3528502' "{bf:Mairiporã}" 			 , size(vsmall) color(emidblue)) ///
	text(13 `pos3534401' "{bf:Osasco}"    			 , size(vsmall) color(emidblue)) ///
	text(8  `pos3548708' "{bf:São Bernardo do Campo}", size(vsmall) color(emidblue)) ///
	text(11 `pos3547809' "{bf:Santo André}" 		 , size(vsmall) color(emidblue)) ///
	text(2  `pos3548807' "{bf:São Caetano do Sul}" 	 , size(vsmall) color(emidblue)) ///
	text(13 `pos3552403' "{bf:Sumaré}" 				 , size(vsmall) color(emidblue)) ///
	text(18  55 		 "{bf: Average GDP per capita R$ `media'}" 			 , size(medium) color(navy)) 						///
	ysize(5) xsize(7) 																											///
	xline(`mean', lcolor(navy) lpattern(dash)) 																					///
	note("Source: IBGE, 2009.", span color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/pib_per_capita.pdf", as(pdf) replace	
	
	
*----------------------------------------------------------------------------------------------------------------------------*
*Expenditure per student	
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/FNDE Indicators.dta" if year == 2008, clear		
	gen treated = .
	
	foreach munic in $treated_municipalities2 {
		replace treated = 1 if codmunic2 == `munic' 
		su ind_49 if codmunic2 == `munic'
		local pos`munic' = r(mean)
	}
	
	su ind_49, detail
	local media = string(`r(mean)',"%10.2fc")
	local mean = r(mean)
	
	
	twoway (histogram ind_49  if year == 2008 ,  percent    																	///
	title("", pos(12) size(medsmall) color(black))																				///
	yscale(alt)																													///
	ylabel(0(5)20, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 							///
	ytitle("%", size(medsmall) color(black))  																					///
	xtitle("In 2008 BRL", size(medsmall) color(black))  																		///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	fcolor(none) lcolor(emidblue*1.5)), legend(order(1 "Grupo de Comparação" 2 "Grupo de Tratamento") region(lwidth(none))) 			///
	text(17 `pos355030' "{bf:São Paulo}" 			 , size(vsmall) color(cranberry*0.8)) ///
	text(10 `pos350950' "{bf:Campinas}"  			 , size(vsmall) color(cranberry*0.8)) ///
	text(8  `pos351380' "{bf:Diadema}"   			 , size(vsmall) color(cranberry*0.8)) ///
	text(12 `pos352050' "{bf:Indaiatuba}"			 , size(vsmall) color(cranberry*0.8)) ///
	text(10 `pos352850' "{bf:Mairiporã}" 			 , size(vsmall) color(cranberry*0.8)) ///
	text(13 `pos353440' "{bf:Osasco}"    			 , size(vsmall) color(cranberry*0.8)) ///
	text(8  `pos354870' "{bf:São Bernardo do Campo}" , size(vsmall) color(cranberry*0.8)) ///
	text(11 `pos354780' "{bf:Santo André}" 		 	 , size(vsmall) color(cranberry*0.8)) ///
	text(2  `pos354880' "{bf:São Caetano do Sul}" 	 , size(vsmall) color(cranberry*0.8)) ///
	text(15 `pos355240' "{bf:Sumaré}" 				 , size(vsmall) color(cranberry*0.8)) ///
	text(18  6500 		"{bf: Average expenditure per student R$ `media'}" 			 , size(medium) color(cranberry*1.2)) 		///
	ysize(5) xsize(7) 																											///
	xline(`mean', lcolor(cranberry) lpattern(dash)) ///
	note("Source: FNDE, 2009.", span color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/expenditure_student.pdf", as(pdf) replace	

	
*----------------------------------------------------------------------------------------------------------------------------*
*School infrastructure
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009,  clear
	/*
	foreach var of varlist $matching_schools {
		replace `var' = `var'*100
	}
	*/
	collapse (mean) $matching_schools, by(treated)
	
	rename (ComputerLab ScienceLab SportCourt Library InternetAccess) (var_1 var_2 var_3 var_4 var_5)
	reshape long var_, i(treated) j(infra)
	reshape wide var_, i(infra) j(treated)
	
	graph bar (asis) var_1 var_0  , graphregion(color(white)) bar(1, lwidth(0.2) lcolor(navy) color(emidblue)) bar(2, lwidth(0.2) lcolor(black) color(gs12))  bar(3, color(emidblue))   																	///
	over(infra, sort(infra) relabel(1  `" "Computer" "Lab" "'   2 `" "Science" "Lab" "'   3 `" "Sport" "Court" "'  4 `" "Library" "'  5 `" "Internet" "Access" "') label(labsize(small))) 				///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
	blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.1fc))   																								///
	ylabel(, nogrid labsize(small) angle(horizontal)) 																																					///
	yscale(alt) 																																														///
	ysize(5) xsize(7) 																																													///
	ytitle("%", size(medsmall) color(black))  																																							///
	legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6))													///
	note("Source: School Census INEP 2009.", span color(black) fcolor(background) pos(7) size(vsmall))
	graph export "$figures/school_infra.pdf", as(pdf) replace	

	
*----------------------------------------------------------------------------------------------------------------------------*
*Rede de São Paulo
*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$inter/Enrollments at school level.dta", clear
		keep if year == 2009 & (network == 2 | network == 3)
		gen treated = 0
			foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
		
		egen 	mat    = rowtotal(enrollmentEI enrollmentEF1 enrollmentEF2 enrollmentEMtotal)
		gen 	escola = school_EI == 1 | school_EF1 == 1 | school_EF2 == 1 | school_EM == 1
		gen 	affected = (treated == 1 | network == 2) & escola == 1
		keep if escola == 1
		
		collapse (sum) mat enrollmentEI enrollmentEF1 enrollmentEF2 enrollmentEMtotal school_*, by(affected network)
		sort network
		
*----------------------------------------------------------------------------------------------------------------------------*
*Numero de escolas
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009,  clear
		codebook codmunic  if id_13_mun == 0 & network == 2 & !missing(math5) 									//number of municipalities (among the ones that did not extend the winter break) with at lest one state school
		codebook codschool if id_13_mun == 0 & network == 2 & !missing(math5) 									//number of state schools in the municipalities that opted to not extend the winter break
		codebook codschool if id_13_mun == 0 & network == 3 & !missing(math5) & mun_escolas_estaduais_ef1 == 1  //number of municipal schools in the municipalities that opted to not extend the winter break
	
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009,  clear
		duplicates drop codmunic, force
		gen ind = 1
		collapse (sum) ind , by (id_13_mun tipo_municipio_ef1)
		
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009,  clear
		duplicates drop codmunic, force
		gen ind = 1
		collapse (sum) ind , by (id_13_mun tipo_municipio_ef2)
		
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2005,  clear
		gen ind_estadual  = 1 if network == 2 & !missing(math5)
		gen ind_municipal = 1 if network == 3 & !missing(math5)
		collapse (sum) ind_estadual ind_municipal , by (id_13_mun tipo_municipio_ef1)	
		
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009,  clear
		gen ind_estadual  = 1 if network == 2 & !missing(math9)
		gen ind_municipal = 1 if network == 3 & !missing(math9)
		collapse (sum) ind_estadual ind_municipal , by (id_13_mun tipo_municipio_ef2)	
				
		
*----------------------------------------------------------------------------------------------------------------------------*
*Balance test
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009 & !missing(math5) & network == 3, clear
	egen tag_mun = tag(codmunic) 
	replace pop = . if tag_mun!= 1
	iebaltab math5 port5 repetition5 dropout5 approval5 SIncentive2_5 SIncentive3_5 SIncentive4_5 SIncentive5_5 white_5 livesmother_5 computer_5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 ComputerLab ScienceLab Library InternetAccess SportCourt enrollment5 classhour5 tclass5 pop pib_pcap, format(%12.2fc) grpvar(treated) savetex("$descriptives/Balance Test_municipal networks") rowvarlabels replace 
	iebaltab math5 port5 repetition5 dropout5 approval5 SIncentive2_5 SIncentive3_5 SIncentive4_5 SIncentive5_5 white_5 livesmother_5 computer_5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 ComputerLab ScienceLab Library InternetAccess SportCourt enrollment5 classhour5 tclass5 pop pib_pcap, format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test_municipal networks") rowvarlabels replace 

	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if year == 2009 & !missing(math5) & id_M == 1, clear
	egen tag_mun = tag(codmunic) 
	replace pop = . if tag_mun!= 1
	iebaltab math5 port5 repetition5 dropout5 approval5 SIncentive2_5 SIncentive3_5 SIncentive4_5 SIncentive5_5 white_5 livesmother_5 computer_5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 ComputerLab ScienceLab Library InternetAccess SportCourt enrollment5 classhour5 tclass5 pop pib_pcap, format(%12.2fc) grpvar(state_network) savetex("$descriptives/Balance Test_state and municipal networks") rowvarlabels replace 
	iebaltab math5 port5 repetition5 dropout5 approval5 SIncentive2_5 SIncentive3_5 SIncentive4_5 SIncentive5_5 white_5 livesmother_5 computer_5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 ComputerLab ScienceLab Library InternetAccess SportCourt enrollment5 classhour5 tclass5 pop pib_pcap, format(%12.2fc) grpvar(state_network) save("$descriptives/Balance Test_state and municipal networks") rowvarlabels replace 

	
		
*----------------------------------------------------------------------------------------------------------------------------*
*Size of affected municipalities		
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/GDP per capita.dta", clear
	keep if year == 2009
	merge 1:1 codmunic using "$geocodes/mun_brasil.dta", keep(1 3)

	rename id _ID
	gen 	grupo = 1 if pop < 50 
	replace grupo = 2 if pop > 50  & pop < 100
	replace grupo = 3 if pop > 100 & pop < 500
	replace grupo = 4 if pop > 500 & !missing(pop)
	
		spmap  grupo using "$geocodes/mun_coord.dta", id(_ID) 																							///
		clmethod(custom) clbreaks(0 1 2 3 4 5)																											///
		fcolor(gs14 emidblue*0.5 emidblue red*1.05) 																									///
		legorder(lohi) 																																	///
		legend(order(2 "Up to 50k" 3 "Between 50k-100k" 4 "Between 100k-500k" 5 "More than 1 million") size(medium)) saving (distance_`distance', replace)
		graph export "$figures/pop.pdf", as(pdf) replace
	
		
*----------------------------------------------------------------------------------------------------------------------------*
*% com desempenho insuficiente em matemática
*----------------------------------------------------------------------------------------------------------------------------*
	use 	"$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	
	
	bys treated: su	 math_insuf_5 if year == 2007 & network == 3
	bys treated: su	 math5 if year == 2007 & network == 3
	
	bys treated: su  port_insuf_5 if year == 2007 & network == 3
	bys treated: su	 port5 if year == 2007 & network == 3
	
	
	bys id_13_mun: su	 math_insuf_5 if year == 2007 & network == 2
	bys id_13_mun: su	 math5 if year == 2007 & network == 2
	
	bys id_13_mun: su  port_insuf_5 if year == 2007 & network == 2
	bys id_13_mun: su	 port5 if year == 2007 & network == 2

	
	bys treated: su	 math_insuf_9 if year == 2007 & network == 3
	bys treated: su  port_insuf_9 if year == 2007 & network == 3
	
	keep 	 if year == 2009
	by 		 treated, sort: quantiles math5, gen(quintile) stable  nq(10)
	collapse (mean)repetition5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 tv_5 stereo_5 dvd_5 refri_5 car_5 bathroom_5 maid_5 nrepetition_5 ndropout_5 math_insuf_5, by(quintile treated)
	
	
*----------------------------------------------------------------------------------------------------------------------------*
*Municípios tratados com matrículas no 5o e 9o ano
*----------------------------------------------------------------------------------------------------------------------------*
	use 		"$censoescolar/Enrollments at municipal level.dta", clear
	keep if network == 3
		gen treated = .
			foreach munic in $treated_municipalities {
				replace treated = 1 if codmunic == `munic'
			}
	   
	 tab codmunic if treated == 1 & enrollment5grade !=0 & year == 2009
	 tab codmunic if treated == 1 & enrollment9grade !=0 & year == 2009
	   	
	
	
	
	
	
	
	
	
	
	
