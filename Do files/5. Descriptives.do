


*----------------------------------------------------------------------------------------------------------------------------*

*Tendência no tempo
*----------------------------------------------------------------------------------------------------------------------------*

	*Math
	*------------------------------------------------------------------------------------------------------------------------*
		use "$inter/trend_math.dta", clear
		gen 	contrafactual = math5 + 4 if treated == 1 & year == 2009
		replace contrafactual = math5     if treated == 1 & year == 2007

			foreach language in english port {

				if "`language'" == "english" {
					local ytitle  = "Test score, SAEB scale" 
					local legend1 = "Extended winter break"
					local legend2 = "Other municipalities"
					local title   = "Math, 5{sup:th} grade"
					local note    = "Source: Prova Brasil." 
				}
				
				
				if "`language'" == "port" {
					local ytitle  = "Proficiência, Escala SAEB" 
					local legend1 = "Adiamento das aulas"
					local legend2 = "Outros municípios"
					local title   = "Matemática, 5{sup:o} ano"
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
						title("", pos(12) size(medium) color(black))													 														///
						xtitle("")  																																				///
						xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "`legend1'"  2 "`legend2'"  3 "Contrafactual") size(small) region(lwidth(none) color(white) fcolor(none))) 									///
						ysize(5) xsize(5) 																										 									///
						note("`note'", color(black) fcolor(background) pos(7) size(small)))  
						*graph export "$figures/trend_math.pdf", as(pdf) replace
						graph export "$figures/trend_math_`language'.pdf", as(png) replace
					
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
						ytitle("Test score, SAEB scale", size(small)) 																					 										///
						xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
						title("", pos(12) size(medium) color(black))																						///
						xtitle("")  																																				///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
						legend(order(1 "Extended winter break"  2 "Other municipalities"  3 "Contrafactual") size(small) region(lwidth(none) color(white) fcolor(none))) 			///
						ysize(5) xsize(5) 																																			///
						note("Source: Prova Brasil.", color(black) fcolor(background) pos(7) size(small)))  
						graph export "$figures/trend_port_english.pdf", as(png) replace
						
						

*----------------------------------------------------------------------------------------------------------------------------*

*Grupos de tratamento e comparação
*----------------------------------------------------------------------------------------------------------------------------*
	use "$geocodes/mun_brasil.dta", clear
	keep if coduf == 35
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
		legend(order(2 "Extended winter break" 3 "Other municipalities") size(medium)) saving (distance_`distance', replace)
		*graph export "$figures/tratamento_comparacao_englisg.pdf", as(pdf) replace
		graph export "$figures/tratamento_comparacao_english.png", as(png) replace
		
		spmap  grupo using "$geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 1 2)																					///
		fcolor(cranberry*0.8 gs12 ) 																						///
		legorder(lohi) 																										///
		legend(order(2 "Adiamento das aulas" 3 "Outros municípios") size(medium)) saving (distance_`distance', replace)
		*graph export "$figures/tratamento_comparacao.pdf", as(pdf) replace
		graph export "$figures/tratamento_comparacao_port.png", as(png) replace
		
		
	
*----------------------------------------------------------------------------------------------------------------------------*

*Rede afetada
*----------------------------------------------------------------------------------------------------------------------------*
	use 	"$inter/Enrollments at school level.dta", clear
	gen treated = .
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	replace treated   = 0 if treated == .
	
	keep 		if year == 2009 & network == 3
	collapse 	(sum)enrollment5grade, by (codschool treated)
	gen 		var1 = 1 if enrollment5grade > 0		//if the school has EI or EF
	drop 		if var1 == . 
	collapse 	(sum)var1 enrollment*, by (treated)
		
	gen 		var2 = enrollment5grade
	drop 		enrollment5grade
	reshape 	long var, i(treated) j(tipo) 
	reshape 	wide var, i(tipo)    j(treated)
	
	label 		define municipalites 1 "School" 2 "Enrollments"
	label 		val    tipo municipalites
	set scheme s1mono
	graph pie var1 var0 , by(tipo, graphregion(fcolor(white))) pie(1,  color(cranberry*0.7)) pie(2, explode color(gs12))     							///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))  													///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 												 	///
	plabel(_all percent, gap(5) format(%12.1fc) size(small)) 																							///
	title(, pos(12) size(medsmall) color(black)) 																										///
	legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(small) position(6)) 	///
	note("Source: School Census, 2009.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/students_affected.pdf", as(pdf) replace	 
		
		
*----------------------------------------------------------------------------------------------------------------------------*

*Performance
*----------------------------------------------------------------------------------------------------------------------------*
	set scheme economist
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	drop if math5 > 300
	
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
	fcolor(none) lcolor(black)), legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(small) position(6)) ///
	note("Source: INEP, 2007.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/histogram_performance.pdf", as(pdf) replace	
	
	
*----------------------------------------------------------------------------------------------------------------------------*
														
*Histogram of gdp per capita				
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/GDP per capita.dta", clear
	
	foreach munic in $treated_municipalities {
		su 	  pib_pcap if codmunic == `munic'
		local pos`munic' = r(mean)
	}
	
	su 	  pib_pcap, detail
	local media = string(`r(mean)',"%10.2fc")
	local mean = r(mean)
	
	
	twoway (histogram pib_pcap  if year == 2007 ,  percent    																	///
	title("", pos(12) size(medsmall) color(black))																				///
	ylabel(0(5)20, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 							///
	ytitle("%", size(medsmall) color(black))  																					///
	yscale(alt) 																												///
	xtitle("2009 BRL", size(medsmall) color(black))  																			///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
	fcolor(none) lcolor(gs12)),	///
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
	text(18  55000 		 "{bf: Average GDP per capita R$ `media'}" 			 , size(vsmall) color(navy)) 						///
	ysize(5) xsize(7) 																											///
	xline(`mean', lcolor(navy) lpattern(dash)) 																					///
	note("Source: IBGE, 2009.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/pib_per_capita.pdf", as(pdf) replace	
	
	
*----------------------------------------------------------------------------------------------------------------------------*
	
*Expenditure per student	
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/FNDE Indicators.dta", clear
	keep if year == 2008
		
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
	fcolor(none) lcolor(gs12)), legend(order(1 "Grupo de Comparação" 2 "Grupo de Tratamento") region(lwidth(none))) 			///
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
	text(18  6500 		"{bf: Average expenditure per student R$ `media'}" 			 , size(vsmall) color(cranberry*1.2)) 		///
	ysize(5) xsize(7) 																											///
	xline(`mean', lcolor(cranberry) lpattern(dash)) ///
	note("Source: FNDE, 2009.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/expenditure_student.pdf", as(pdf) replace	

	
*----------------------------------------------------------------------------------------------------------------------------*

*School infrastructure
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2009
	
	foreach var of varlist $matching_schools {
		replace `var' = `var'*100
	}
	
	collapse (mean) $matching_schools, by(treated)
	
	rename (ComputerLab ScienceLab SportCourt Library InternetAccess) (var_1 var_2 var_3 var_4 var_5)
	reshape long var_, i(treated) j(infra)
	reshape wide var_, i(infra) j(treated)
	
	graph bar (asis) var_1 var_0  , graphregion(color(white)) bar(1, color(emidblue)) bar(2, color(gs12))  bar(3, color(emidblue))   																	///
	over(infra, sort(infra) relabel(1  `" "Computer" "Lab" "'   2 `" "Science" "Lab" "'   3 `" "Sport" "Court" "'  4 `" "Library" "'  5 `" "Internet" "Access" "') label(labsize(small))) 				///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																									///
	blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.1fc))   																								///
	ylabel(, nogrid labsize(small) angle(horizontal)) 																																					///
	yscale(alt) 																																														///
	ysize(5) xsize(7) 																																													///
	ytitle("%", size(medsmall) color(black))  																																							///
	legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(small) position(6))	///
	note("Source: School Census INEP 2009.", color(black) fcolor(background) pos(7) size(vsmall))
	graph export "$figures/school_infra.pdf", as(pdf) replace	

	
*----------------------------------------------------------------------------------------------------------------------------*

*Rede de São Paulo
*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$inter/Enrollments at school level.dta", clear
		gen treated = 0
			foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
	
		codebook codschool   if year == 2009 & (treated == 1 | network == 2) & (school_EI == 1 | school_EF1 == 1 | school_EF2 == 1 | school_EM == 1) //escolas que fecharam
		codebook codschool   if year == 2009 & (network == 3 | network == 2) & (school_EI == 1 | school_EF1 == 1 | school_EF2 == 1 | school_EM == 1) //total de escolas
		
		
		gen 	affected = 	    year == 2009 & (treated == 1 | network == 2) & (school_EI == 1 | school_EF1 == 1 | school_EF2 == 1 | school_EM == 1)
		replace affected = . if year != 2009
		egen 	mat = rowtotal(enrollmentEI enrollmentEF1 enrollmentEF2 enrollmentEM)
		total 	mat, over(affected)			//number of students affected
		

		codebook codschool if year == 2009 & (network == 2 | network == 1 | network == 3 ) & (school_EF1 == 1)	//numero de escolas do EF1 
		codebook codschool if year == 2009 & (network == 2 								 ) & (school_EF1 == 1)  //escolas estaduais
		codebook codschool if year == 2009 & (								network == 3 ) & (school_EF1 == 1)  //escolas municipais
		codebook codschool if year == 2009 & (				 network == 1				 ) & (school_EF1 == 1)
	
		total 	enrollmentEF1 if year == 2009 & network == 2	//matrículas do EF1 em escolas estaduais
		total 	enrollmentEF1 if year == 2009 & network == 3	//matrículas do EF1 em escolas estaduais
		
		codebook codschool 			if year == 2009 & (treated == 1) & !missing(enrollment5grade) & enrollment5grade != 0 & network == 3 //escolas municipais
		total 	 enrollment5grade   if year == 2009 & (treated == 1) & network == 3  

		
*----------------------------------------------------------------------------------------------------------------------------*

*Balance test
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2009 & !missing(math5)
	egen tag_mun = tag(codmunic) 
	replace pop = . if tag_mun!= 1
	iebaltab math5 port5 repetition5 dropout5 approval5 SIncentive2_5 SIncentive3_5 SIncentive4_5 SIncentive5_5 white_5 livesmother_5 computer_5 mother_edu_5 preschool_5 repetition_5 dropout_5 studentwork_5 ComputerLab ScienceLab Library InternetAccess SportCourt enrollment5 classhour5 tclass5 pop pib_pcap, format(%12.2fc) grpvar(treated) savetex("$descriptives/Balance") rowvarlabels replace 

		
/*
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
	su		  math_insuf_5 if treated == 1 & year == 2007
	
	keep 	 if year == 2009
	by 		 treated, sort: quantiles math5, gen(quintile) stable  nq(5)
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
	   

*----------------------------------------------------------------------------------------------------------------------------*

*Variação do IDEB
*----------------------------------------------------------------------------------------------------------------------------*
	use 		"$ideb/IDEB at municipal level.dta", clear
	 keep if network == 3 & coduf == 35
		gen treated = .
			foreach munic in $treated_municipalities {
				replace treated = 1 if codmunic == `munic'
			}
		collapse (mean)math5 math9 spEF1 spEF2, by (year)
		
		gen var1 = math9[_n] - math5[_n-2]
		gen var2 = spEF2[_n] - spEF1[_n-2]
		replace var1 = var1/4
	
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/*
	use "$inter/Enrollments at school level.dta", clear
	keep if year == 2009 & network == 3
	
	gen treated = 0
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	
	collapse (sum)enrollmentEF1 enrollmentEF2 enrollment5grade, by(treated)
	
	reshape  long enrollment, i(treated) j(ciclo)     string
	reshape  wide enrollment, i(ciclo)   j(treated) 
	
	replace  ciclo = "1" if ciclo == "EF1"
	replace  ciclo = "2" if ciclo == "EF2"
	replace  ciclo = "3" if ciclo == "5grade"
	destring ciclo, replace
	
	label	 define ciclo 1 "1{sup:o} ao 5{sup:o} ano" 2 "6{sup:o} ao 9{sup:o} ano" 3 "5{sup:th} grade"
	label 	 val    ciclo ciclo
	
	graph pie enrollment1 enrollment0  if ciclo == 3, pie(1,  color(emidblue)) pie(2, explode color(gs12)) pie(3, explode color(gs12))      ///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))  ///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
	plabel(_all percent, gap(5) format(%12.1fc) size(small)) ///
	title(, pos(12) size(medsmall) color(black)) ///
	legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(small) position(6)) ///
	note("Fonte: Censo Escolar, 2009.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/enrollment_treated.pdf", as(pdf) replace	
	
	
	
	
	
	
	
/*

	use "$ideb/IDEB at school level.dta", clear
	keep if network == 3 & coduf == 35 
	gen treated = .
		foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
		keep if treated== 0
			
	
	
		collapse (mean)math5 math9 spEF1 spEF2, by (year)
	
	gen var1 = math9[_n] - math5[_n-2]
	gen var2 = spEF2[_n] - spEF1[_n-2]
	
	
	replace var1 = var1/4
	
	
	
	
	

	
	

	use "$inter/IDEB at schoool level.dta", clear

	xtset codschool year
	
	keep if year == 2005 | year == 2007
	
	bys codschool: egen vezes = count(codschool) if math5 != .
	
*keep if vezes == 2

collapse (mean)math5 math9, by(year)


use "$censoescolar/Enrollments at school level.dta", clear

keep if coduf == 35 & (network == 3 | network == 2)

gen school_eb = (school_EI == 1 | school_EF == 1 | school_EM == 1)

gen treated = .
foreach munic in $treated_municipalities {
	replace treated = 1 if codmunic == `munic' & network == 3
}

keep if network == 2 | treated == 1


collapse (sum)enrollmentEI enrollmentEF enrollmentEMtotal school_eb, by (network year)




/*
use "$final/Performance & Socioeconomic Variables of SP municipalities.dta", clear

keep if year == 2005 | year == 2007 | year == 2009

	foreach grade in 5 {
		foreach var of varlist port`grade' {
			
				gen a = 1 if !missing(`var') & year == 2005	//municipio que tem a variavel calculada em 2005
				bys codmunic: egen max_a = max(a)
				keep 	if max_a == 1

				collapse (mean)`var' [pw = enrollment5], by(year treated)
				
							tw 	///
								(line `var' year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected)  ///  
								ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) ///
								///
								(line `var' year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  ///  
								ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) ///
								ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%4.2fc)) ///
								ytitle("", size(small)) ///
								xtitle("",) ///
								xlabel(, labsize(vsmall)) xscale(range()) ///
								title("", pos(12) size(medsmall) color(black)) ///
								subtitle("", pos(12) size(medsmall) color(black)) ///
								graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
								plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
								legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 	///
								ysize(6) xsize(7) saving("$figures/A`var'", replace) ///
								note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small))) 
		}
	}

	

/*
















































use "$final/Performance & Socioeconomic Variables of SP municipalities.dta", clear
keep if year == 2005 | year == 2007 | year == 2009


	foreach grade in 5 {a
		foreach var of varlist math`grade' {
			preserve
							
				bys codmunic: egen total = count(math5) if math5 !=.
			
			
				gen a = 1 if !missing(`var') & year == 2005	//municipio que tem a variavel calculada em 2005
				bys codmunic: egen max_a = max(a)
				keep 	if max_a == 1
			
					if "`var'" == "math5" | "`var'" == "port5" | "`var'" == "math9" | "`var'" == "port9"{
						local lower = 2005
						local upper = 2009
						keep if year >= 2005 & year <= 2009
						if "`var'" == "math5" local title = "Matemática 5{sup:o} ano"
						if "`var'" == "port5" local title = "Português 5{sup:o} ano"
						if "`var'" == "math9" local title = "Matemática 9{sup:o} ano"
						if "`var'" == "port9" local title = "Português 9{sup:o} ano"
						local pulo = 2
						local format = "4.0"
					}
					if "`var'" == "repetition5grade" |  "`var'" == "dropout5grade" | "`var'" == "repetition9grade" |  "`var'" == "dropout9grade" {
						local lower = 2007
						local upper = 2009
						keep if year >= 2007 & year <= 2009
						local pulo = 1
						local format = "4.2"
						if "`var'" == "repetition5grade" local title "Reprovação 5{sup:o} ano, em %"
						if "`var'" == "dropout5grade" 	 local title "Abandono 5{sup:o} ano, em %"
						if "`var'" == "repetition9grade" local title "Reprovação 9{sup:o} ano, em %"
						if "`var'" == "dropout9grade" 	 local title "Abandono 9{sup:o} ano, em %"
					}
						collapse (mean)`var' , by(year treated)
							tw 	///
								(line `var' year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected)  ///  
								ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) ///
								///
								(line `var' year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  ///  
								ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) ///
								ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%`format'fc)) ///
								ytitle("", size(small)) ///
								xtitle("",) ///
								xlabel(`lower'(`pulo')`upper', labsize(vsmall)) xscale(range()) ///
								title("`title'", pos(12) size(medsmall) color(black)) ///
								subtitle("", pos(12) size(medsmall) color(black)) ///
								graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
								plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
								legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 	///
								ysize(6) xsize(7) saving("$figures/A`var'", replace) ///
								note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small))) 
			restore
		}
	}

	
	
	/*
	foreach grade in 9  {
		graph combine "$figures/Amath`grade'.gph" "$figures/Aport`grade'.gph" , cols(2)   scheme(s1color )
		graph export  "$figures/time_trend_`grade'ano.pdf", as(pdf) replace
		graph export  "$figures/time_trend_`grade'ano.png", as(png) replace	
		erase "$figures/Amath`grade'.gph"
		erase "$figures/Aport`grade'.gph"

	}



/*



*3*														
*Enrollments by network					
*----------------------------------------------------------------------------------------------------------------------------*
	use "$inter/Enrollments at school level.dta", clear
		





*1*														
*Treatment and control groups according to maximum distance between them									
*----------------------------------------------------------------------------------------------------------------------------*

	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear

		duplicates drop codmunic, force
		
		foreach distance in 20 40 60 80 { 
			gen 	group`distance'  = 1 if treated == 1
			replace group`distance'  = 2 if treated == 0 & distance`distance'  == 1
			replace group`distance'  = 3 if group`distance' ==.
		}
			
		foreach distance in 20 40 60 { 
			spmap  group`distance'  using "$geocodes/mun_coord.dta", id(_ID) 													///
			clmethod(custom) clbreaks(0 1 2 3)																					///
			fcolor(cranberry*0.8 emidblue gs16) 																				///
			title ("`distance' km", size(large)) 																				///
			legorder(lohi) 																										///
			legend(off) saving (distance_`distance', replace)
			*graph export "9$figures/groups_`distance'.pdf", as(pdf) replace
		}

			spmap  group80  using "$geocodes/mun_coord.dta", id(_ID) 															///
			clmethod(custom) clbreaks(0 1 2 3)																					///
			fcolor(cranberry*0.8 emidblue gs16) 																				///
			title ("80 km", size(large)) 																						///
			legorder(lohi) 																										///
			legend(label(2 "Com fechamento") label(3 "Sem fechamento") label(4 "Outros") size(small) position(8)) saving (distance_80, replace)
			*graph export "$figures/groups_80.pdf", as(pdf) replace
		
		graph combine distance_20.gph distance_40.gph distance_60.gph distance_80.gph, cols(2)   scheme(s1color )
		graph export "$figures/comparison_groups.pdf", as(pdf) replace
		

		
*2*														
*Balance test for schools and students								
*----------------------------------------------------------------------------------------------------------------------------*
	
	
	*Schools
	*------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear

		forvalues distance = 20(20)80 {
			iebaltab $matching_schools pib_pcap pop if year == 2007 & distance`distance' == 1, format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Schools_`distance'km") rowvarlabels replace
		}
			iebaltab $matching_schools pib_pcap pop if year == 2007 						 , format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Schools") 			   rowvarlabels replace


	*Students
	*------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear

		forvalues distance = 20(20)80 {
			iebaltab $balance_students5		if year == 2007 & distance`distance' == 1, format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Students_5ano_`distance'km") rowvarlabels replace
			iebaltab $balance_students9		if year == 2007 & distance`distance' == 1, format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Students_9ano_`distance'km") rowvarlabels replace
		}
			iebaltab $balance_students5 	if year == 2007							 , format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Students_5ano") 			 rowvarlabels replace
			iebaltab $balance_students9 	if year == 2007							 , format(%12.2fc) grpvar(treated) save("$descriptives/Balance Test for Students_9ano") 			 rowvarlabels replace
		
		
		


	
*4*														
*Enrollments and schools by treatment group		
*----------------------------------------------------------------------------------------------------------------------------*


	



	

	
*9*														
*Student's socioeconomic characteristics
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2009
	
	expand 2 if distance20 == 1, gen(REP)
	
	foreach var of varlist $matching_schools {
		replace `var' = `var'*100
	}
	
	replace treated = 2 if REP == 1
	
	keep treated repetition_5 dropout_5 preschool_5 studentwork_5 privateschool_5 mother_edu_5 computer_5

	collapse (mean)repetition_5 dropout_5 preschool_5 studentwork_5 privateschool_5 mother_edu_5 computer_5, by(treated)
	
	rename (repetition_5 dropout_5 preschool_5 studentwork_5 privateschool_5 mother_edu_5 computer_5) (var_1 var_2 var_3 var_4 var_5 var_6 var_7)
	reshape long var_, i(treated) j(socioec)
	reshape wide var_, i(socioec) j(treated)
	
	
	graph bar (asis) var_1 var_2 var_0, graphregion(color(white)) bar(1, color(gs12)) bar(2, color(emidblue*1.5))  bar(3, color(emidblue)) ///
	over(socioec, sort(socioec) relabel(1  `" "Já" "reprovaram" "'   2 `" "Já" "abandonaram" "'   3 `" "Pré-escola" "'  4 `" "Trabalha"  "'  5 `" "Já freq. "esc. part "' 6 `" "Mãe" "EM completo" "' 7 `" "Computador" "em casa" "'  ) label(labsize(small))) ///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
	blabel(bar, position(outside) orientation(horizontal) size(vsmall)  color(black) format (%12.1fc))   ///
	ylabel(, labsize(small) angle(horizontal)) ///
	ysize(5) xsize(7) ///
	ytitle("Em%", size(medsmall) color(black))  																		///
	legend(order(1 "Adiaram"  2 "Não adiaram o retorno às aulas, 20km" 3 "Não adiaram o retorno às aulas") size(small) cols(2) region(lwidth(none))) 	///
	note("Fonte: Prova Brasil, 2009.", color(black) fcolor(background) pos(7) size(vsmall))
	graph export "$figures/socioec_students.pdf", as(pdf) replace	
	
	
*10*														
*Trends
*----------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	duplicates drop codmunic, force
	keep codmunic distance0 distance20 distance50 distance100
	tempfile distances
	save    `distances'
	
	use "$rendimento/Flow Indicators at municipal level.dta", clear
	keep if network == 3 & coduf == 35 
	merge 1:1 year codmunic network using "${inter}/IDEB at municipal level.dta", nogen keepusing(ideb* math* port*)
	merge m:1 codmunic using `distances'
	
	gen treated = .
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	replace 	treated = 0 if treated == .
	
	format port* math* repetition* dropout* %4.1fc
	
	foreach var of varlist math5 port5 repetition5grade dropout5grade  {
		foreach distance in 0 20 50 100 {
			preserve
				keep if distance`distance' == 1
				
				if "`var'" == "math5" | "`var'" == "port5" {
					local lower = 2005
					local upper = 2017
					keep if year >= 2005 & year <= 2017
					if "`var'" == "math5" local title = "Matemática 5{sup:o} ano"
					if "`var'" == "port5" local title = "Português 5{sup:o} ano"
					local pulo = 2
					local format = "4.0"
				}
				
				if "`var'" == "repetition5grade" |  "`var'" == "dropout5grade" {
					local lower = 2007
					local upper = 2016
					keep if year >= 2007 & year <= 2016
					local pulo = 1
					local format = "4.2"
					if "`var'" == "repetition5grade" local title "Reprovação 5{sup:o} ano, em %"
					if "`var'" == "dropout5grade" 	 local title "Abandono 5{sup:o} ano, em %"

				}
					collapse (mean)`var', by(year treated)
						tw 	///
							(line `var' year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected)  ///  
							ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) ///
							///
							(line `var' year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  ///  
							ml() mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) ///
							ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%`format'fc)) ///
							ytitle("", size(small)) ///
							xtitle("",) ///
							xlabel(`lower'(`pulo')`upper', labsize(vsmall)) xscale(range()) ///
							title("`distance' km - `title'", pos(12) size(medsmall) color(black)) ///
							subtitle("", pos(12) size(medsmall) color(black)) ///
							graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 	///
							ysize(6) xsize(7) saving("$figures/A`var'_`distance'", replace) ///
							note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small))) 
			restore
		}
		
	}
		
		foreach var of varlist math5 port5 repetition5grade dropout5grade {
			graph combine "$figures/A`var'_0.gph" "$figures/A`var'_20.gph" "$figures/A`var'_50.gph" "$figures/A`var'_100.gph", cols(2)   scheme(s1color )
			graph export  "$figures/`var'_trend.pdf", as(pdf) replace
			graph export  "$figures/`var'_trend.png", as(png) replace	
			erase "$figures/A`var'_0.gph"
			erase "$figures/A`var'_20.gph"
			erase "$figures/A`var'_50.gph" 
			erase "$figures/A`var'_100.gph"
		}
		
		
		
		
		

	
*11*														
*Final do ano letivo
*----------------------------------------------------------------------------------------------------------------------------*
	use 	"$inter/School Infrastructure at school level.dta", clear
	
	merge 1:1 year codschool using "$inter/Enrollments at school level.dta", keep(3) nogen keepusing(school_EI_EF)
	
	gen treated = .
	foreach munic in $treated_municipalities {
		replace treated = 1 if codmunic == `munic'
	}
	replace treated   = 0 if treated == .
	
	keep 	if year == 2009 & mes_fim_letivo == 12 & school_EI_EF == 1
	
	gen     week = 1 if dia_fim_letivo <= 4
	replace week = 2 if dia_fim_letivo >  4  & dia_fim_letivo <= 11
	replace week = 3 if dia_fim_letivo >  11 & dia_fim_letivo <= 18	
	replace week = 4 if dia_fim_letivo >  18 & dia_fim_letivo <= 25
	replace week = 5 if dia_fim_letivo >  25 & !missing(dia_fim_letivo)

	
	collapse (sum) school_EI_EF, by (week treated)
	
	reshape wide school_EI_EF, i(week) j(treated)
	
	egen total_control = sum(school_EI_EF0) 
	egen total_treated = sum(school_EI_EF1)
	
	gen share_control = (school_EI_EF0/total_control)*100
	
	gen share_treated = (school_EI_EF1/total_treated)*100
	
	
	graph bar (asis)share_control share_treated , graphregion(color(white)) bar(1, color(emidblue)) bar(2, color(gs12))   ///
	over(week, sort(week) relabel(1  `" "1{sup:a}" "semana" "'   2 `" "2{sup:a}" "semana" "'   3 `" "3{sup:a}" "semana" "'  4 `" "4{sup:a}" "semana"  "'  5 `" "5{sup:a}" "semana" "') label(labsize(small))) ///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
	blabel(bar, position(outside) orientation(horizontal) size(small)  color(black) format (%12.1fc))   ///
	ylabel(, labsize(small) angle(horizontal)) ///
	ysize(5) xsize(7) ///
	ytitle("Em%", size(medsmall) color(black))  																		///
	legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") region(lwidth(none))) 	///
	note("Fonte: Prova Brasil, 2009.", color(black) fcolor(background) pos(7) size(vsmall))
	graph export "$figures/end_school_year.pdf", as(pdf) replace	
	
	
	
	
	
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2009
	
	gen dia = day( cinicio_letivo)
	gen mes = month( cinicio_letivo)
	
	
	twoway (histogram dia if mes == 2 & treated == 0, bin(12) fcolor(emidblue) lcolor(black) percent) 					///
	       (histogram dia if mes == 2 & treated == 1, bin(12) percent    												///
	title("IDEB, 1{sup:o} ao 5{sup:o} ano", pos(12) size(medsmall) color(black))										///
	subtitle("" , pos(12) size(medsmall) color(black))  																///
	ylabel(, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 							///
	xtitle("Dia de início das aulas, Fevereiro de 2009", size(medsmall) color(black))  									///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					///
	fcolor(none) lcolor(black)), legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") region(lwidth(none))) 	///
	note("Fonte: INEP, 2007.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/histogram_performance.pdf", as(pdf) replace	

	
	gen group = 1 
	
	
	drop if classhour5 >= 5
	twoway (histogram classhour5 if treated == 0 ,  fcolor(emidblue) lcolor(black) percent) 					///
	       (histogram classhour5 if treated == 1 ,  percent    												///
	title("IDEB, 1{sup:o} ao 5{sup:o} ano", pos(12) size(medsmall) color(black))										///
	subtitle("" , pos(12) size(medsmall) color(black))  																///
	ylabel(, labsize(small)) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 							///
	xtitle("Dia de início das aulas, Fevereiro de 2009", size(medsmall) color(black))  									///
	graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					///
	plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					///
	fcolor(none) lcolor(black)), legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") region(lwidth(none))) 	///
	note("Fonte: INEP, 2007.", color(black) fcolor(background) pos(7) size(small)) 
	graph export "$figures/histogram_performance.pdf", as(pdf) replace	
	
	
	
	
	
	
	/*
	
	use 	"$inter/Enrollments_2007.dta", clear
	keep 	if network == 3
	collapse (sum)enrollmentEF, by (codmunic2 codmunic year)

	
	tempfile enrollment
	save    `enrollment'
	
	use "$inter/Expenditure per student.dta", clear
	
	keep if year == 2008  | year == 2009
	
	replace year  = 2007 if year == 2008
		
		merge 1:1 codmunic2 network year using "$inter/IDEB at municipal level.dta", keep (3) nogen keepusing(idebEF1 n_munic)
		
		merge 1:1 codmunic2			year using `enrollment', 		 				 keep (3) nogen keepusing(enrollmentEF codmunic)
		
		merge 1:1 codmunic          year using "$inter/GDP per capita.dta", 		 keep (3) nogen keepusing(pop)
	
		gen treated = . 
	
		foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
		replace treated   = 0 if treated == .
		
		replace treated  = 2  if pop <= 50000   & 				   treated == 0
		
		replace treated  = 3  if pop >  50000   & pop <= 100000  & treated == 0
		
		replace treated  = 4  if pop >  100000  & pop <= 500000  & treated == 0
		
		replace treated  = 5  if pop >  500000  & pop <= 1000000 & treated == 0
		
		replace treated  = 6  if pop >  1000000 & !missing(pop)  & treated == 0
		
		
		replace n_munic  = "Até 50 mil" 		      if treated == 2
		replace n_munic  = "Entre 50 e 100 mil hab"   if treated == 3
		replace n_munic  = "Entre 100 mil e 500 mil"  if treated == 4
		replace n_munic  = "Entre 500 mil e 1 milhão" if treated == 5
		replace n_munic  = "Mais de um milhão" 		  if treated == 6
		
		
		preserve
		collapse (sum)enrollmentEF, by(n_munic treated)
			
			tempfile enrollment
			save `enrollment'
		restore
		
		collapse (mean) idebEF1 ind_49 [w=enrollmentEF] , by (n_munic treated)
		merge 1:1 treated  n_munic using `enrollment'
	

		
		twoway ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 1 & n_munic != "Sumaré",	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(cranberry)) || (scatter  idebEF1 ind_49 [w=enrollmentEF] , msymbol(none) mlabcolor(black) mlabsize(vsmall) mlabpos(12) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 1 & n_munic == "Sumaré",	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(cranberry)) || (scatter  idebEF1 ind_49 [w=enrollmentEF] , msymbol(none) mlabcolor(black) mlabsize(vsmall) mlabpos(10) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 2,	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(emidblue))  || (scatter  idebEF1 ind_49 [w=enrollmentEF] if treated == 2 , msymbol(none) mlabcolor(black) mlabsize(tiny)   mlabpos(11) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 3,	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(emidblue))  || (scatter  idebEF1 ind_49 [w=enrollmentEF] if treated == 3 , msymbol(none) mlabcolor(black) mlabsize(tiny)   mlabpos(5) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 4,	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(emidblue))  || (scatter  idebEF1 ind_49 [w=enrollmentEF] if treated == 4 , msymbol(none) mlabcolor(black) mlabsize(tiny)   mlabpos(3) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 5,	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(emidblue))  || (scatter  idebEF1 ind_49 [w=enrollmentEF] if treated == 5 , msymbol(none) mlabcolor(black) mlabsize(tiny)   mlabpos(4) mlab(n_munic)) ///
		(scatter idebEF1 ind_49 [w=enrollmentEF] if treated == 6,	yline(5.6) xline(0) msymbol(circle_hollow) mcolor(emidblue))  || (scatter  idebEF1 ind_49 [w=enrollmentEF] if treated == 6 , msymbol(none) mlabcolor(black) mlabsize(tiny)   mlabpos(11) mlab(n_munic) ///
		///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
		///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
		///
		ylabel(3.5(1)6, labsize(small) gmax angle(horizontal) format(%12.0fc)) ///
		///
		ytitle("IDEB dos anos iniciais", size(medsmall) color(black) ) ///
		///
		xlabel(, labsize(small) gmax angle(horizontal) format(%12.0fc)) ///
		///
		xtitle("Gasto por aluno, em R$ de 2009", size(medsmall)) ///
		///
		title("", pos(12) size(medsmall) color(black)  ) ///
		///
		subtitle("", color(black)  pos(12) size(medsmall)) ///
		///
		legend(order(1 "Municípios que adiaram o início das aulas" 2 "" 3 "Demais redes municipais"  4 "") region(lwidth(none)) cols(5) position(6) size(small)) ///
		///
		note("Fonte: Elaboração própria com base em dados do FNDE.", color(black) fcolor(background) pos(7) size(small)) ///
		ysize(5) xsize(7))
		
		
		
		graph export "dispersão do ganho e do IDEB do EF1.eps", as(eps) replace
		graph export "dispersão do ganho e do IDEB do EF1.png", as(png) replace

		
		
		
	
	
		
	
	
	
	
	use "$ideb/IDEB at municipal level.dta", clear
	gen treated = 0
	foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
	keep if coduf == 35 & network == 3 & year <= 2009

	merge 1:1 codmunic year network using "$inter/Enrollments at municipal level.dta", keep(1 3) keepusing(enrollment5grade enrollment9grade)
	
	xtset codmunic year
	
	replace enrollment5grade = enrollment5grade[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codmunic[_n] == codmunic[_n+1]
	replace enrollment9grade = enrollment9grade[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codmunic[_n] == codmunic[_n+1]
	
	
	foreach grade in 5 9 {
	
		preserve

			keep if math`grade' != .
			
			bys codmunic: egen count = count(codmunic)

			keep if count == 3
			
			collapse (mean)math* port* [aw = enrollment`grade'grade], by(year treated)
			
			tw ///
			(line  port`grade' year if treated == 1, lcolor(gs12)) ///
			(line  port`grade' year if treated == 0, lcolor(emidblue) saving("port`grade'_mun", replace)) 
		
			tw ///
			(line  math`grade' year if treated == 1, lcolor(gs12)) ///
			(line  math`grade' year if treated == 0, lcolor(emidblue) saving("math`grade'_mun", replace)) 

		restore
	}

	
	
	
	use "$ideb/IDEB at school level.dta", clear
	
	gen treated = 0
	foreach munic in $treated_municipalities {
			replace treated = 1 if codmunic == `munic'
		}
	keep if coduf == 35 & network == 3 & year <= 2009
	
	merge 1:1 codschool year network using "$inter/Enrollments at school level.dta", nogen keep(1 3) keepusing(enrollment5grade enrollment9grade)
	
	sort codschool year
	
	replace enrollment5grade = enrollment5grade[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codschool[_n] == codschool[_n+1]
	replace enrollment9grade = enrollment9grade[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codschool[_n] == codschool[_n+1]
	

	foreach grade in 5 9 {
	
		preserve

			keep if math`grade' != .
			
			bys codschool: egen count = count(codschool)

			keep if count == 3
			
			collapse (mean)math* port* [aw = enrollment`grade'grade], by(year treated)
			
			tw ///
			(line  port`grade' year if treated == 1, lcolor(gs12)) ///
			(line  port`grade' year if treated == 0, lcolor(emidblue) saving("port`grade'_esc", replace)) 
		
			tw ///
			(line  math`grade' year if treated == 1, lcolor(gs12)) ///
			(line  math`grade' year if treated == 0, lcolor(emidblue) saving("math`grade'_esc", replace)) 

		restore
	}

	
	foreach grade in 5 9 {
		foreach subject in port math {
			graph combine "`subject'`grade'_esc" "`subject'`grade'_mun"
			graph export  "`subject'`grade'.png", as(png) replace 
			erase "`subject'`grade'_esc.gph"
			erase "`subject'`grade'_mun.gph"
		}
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
