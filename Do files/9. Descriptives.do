
	**
	**Descriptives
	**
	*________________________________________________________________________________________________________________________________* 



	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Enrollments and number of schools
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use 	"$inter/Enrollments.dta" if year == 2009 & (network == 2 | network == 3), clear
		gen T = 0
			foreach munic in $treated_municipalities {											//13 municipalities that opted to extend the winter break in their schools
			replace T = 1 if codmunic == `munic'
		}
	
		egen 	mat    = rowtotal(enrollmentEI enrollmentEF1 enrollmentEF2 enrollmentEMtotal)	//total enrollment at school level	
		gen 	escola = school_EI == 1 | school_EF1 == 1 | school_EF2 == 1 | school_EM == 1	
		gen 	affected = (T ==1 | network == 2) & escola == 1							//affected network by winter break extention -> 
																								//locally managed schools in the 13 municipalities that opted to extend the winter break
																								// + state-state managed schools in all municipalities of the state of Sao Paulo. 
																								
		keep if escola == 1 																	//schools offering preschool, 1st to 9th grade or high school	
		
		collapse (sum) mat enrollmentEI enrollmentEF1 enrollmentEF2 enrollmentEMtotal school_*, by(affected network) //total number of schools and enrollment by state and local networks, affected and non-affected by the shutdowns
		drop 	mat school_EF
		sort 	affected network 
		
		set obs 6
		
		gen 	network2 = "Local" if network == 3
		replace network2 = "State" if network == 2
		
		replace network2 = "Affected"   in 4
		replace network2 = "Unaffected" in 5
		
		foreach var of varlist * {
			tostring `var', replace
		}
		
		replace enrollmentEI  		= "Pre-K" 				in 6
		replace enrollmentEF1 		= "Elementary"  		in 6
		replace enrollmentEF2 		= "Lower sec" 			in 6
		replace enrollmentEMtotal 	= "High School"  		in 6
		replace school_EI  			= "Pre-K"				in 6
		replace school_EF1 			= "Elementary"  		in 6
		replace school_EF2 			= "Lower sec"  			in 6
		replace school_EM 			= "High School"  		in 6
		
		gen 	order = 1 in 6
		replace order = 2 in 5
		replace order = 3 in 1
		replace order = 4 in 4
		sort order 
		
		drop 	network affected order
		order 	network*

		export 	excel "$tables/Table1.xlsx", replace
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Number of municipalities and schools in our sample
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		*===========>
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009,  clear
			codebook codmunic  if id_13_mun == 0 & network == 2 & !missing(math5) 									//number of municipalities (among the ones that did not extend the winter break) with at lest one state school
			codebook codschool if id_13_mun == 0 & network == 2 & !missing(math5) 									//number of state schools in the municipalities that opted to not extend the winter break
			codebook codschool if id_13_mun == 0 & network == 3 & !missing(math5) & mun_escolas_estaduais_ef1 == 1  //number of municipal schools in the municipalities that opted to not extend the winter break

		*===========>
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009,  clear
			duplicates drop codmunic, force
			gen ind = 1
			collapse (sum) ind 						  , by (id_13_mun tipo_municipio_ef1)						   //number of municipalities offering 1st to 5th grade
			tempfile munef1
			save    `munef1'
		
		*===========>
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009,  clear
			duplicates drop codmunic, force
			gen ind = 1
			collapse (sum) ind 						  , by (id_13_mun tipo_municipio_ef2)  							//number of municipalities offering 6th to 9th grade
			tempfile munef2
			save    `munef2'
			
		*===========>
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009,  clear
			gen ind_estadual  = 1 if network == 2 & !missing(approval5)
			gen ind_municipal = 1 if network == 3 & !missing(approval5)
			collapse (sum) ind_estadual ind_municipal , by (id_13_mun tipo_municipio_ef1)							 //number of schools offering 1st to 5th grade 
			merge 1:1 id_13_mun tipo_municipio_ef1 using `munef1', nogen
			
			gen 	order = 1 in 4
			replace order = 2 in 5
			replace order = 3 in 1
			replace order = 4 in 2
			replace order = 5 in 3
			sort	order
			
			mkmat  ind		    , matrix(ind)
			matrix ind			 = ind'
			mkmat  ind_estadual , matrix(ind_estadual)
			mkmat  ind_municipal, matrix(ind_municipal)
		
			matrix B = (el(ind_estadual,1,1), el(ind_municipal,1,1), el(ind_municipal,2,1), el(ind_estadual,3,1), el(ind_municipal,3,1), el(ind_municipal,4,1), el(ind_estadual,5,1))
			matrix A = (el(ind,1,1), 0, el(ind,1,2), el(ind,1,3), 0, el(ind,1,4), el(ind,1,5))\B
			
			clear
			svmat A
			foreach var of varlist * { 
			tostring `var', replace
			replace  `var' = "" if `var' == "0" 		in 1
			}
			
			gen 	name = "Number of municipalities"  	in 1
			replace name = "Number of schools" 			in 2
			
			foreach var of varlist A1 A4 A7 {
			replace `var' = `var' + " - state" in 2
			}
			foreach var of varlist A2 A3 A5 A6 {
			replace `var' = `var' + " - local" in 2
			}			
			
			set obs 5
			replace A1  = "13 municipalities in which " 		in 3
			replace A2  = "the local governments"  				in 3
			replace A3  = "extended the winter break" 			in 3
			replace A4  = "Other municipalities"  			 	in 3 
			replace A5  = "of the state in which "  			in 3 
			replace A6  = "local authorities did not"			in 3 
			replace A7  = "change the school calendar"			in 3 
			replace A1  = "With state" 							in 4 
			replace A2  = "and local schools"					in 4 
			replace A3  = "Only with local schools" 			in 4
			replace A4  = "With state" 							in 4 
			replace A5  = "and local schools" 					in 4 
			replace A6  = "Only with local schools" 			in 4 
			replace A7  = "Only with state schools " 			in 4 	
			replace A1  = "" 									in 5
			
			order name 
			gen 	order = 1 in 3
			replace order = 2 in 4
			replace order = 3 in 1
			replace order = 4 in 5
			replace order = 5 in 2
			sort 	order
			drop    order
			export excel "$tables/TableA1.xlsx", replace
	
	
		*===========>
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009,  clear
			gen ind_estadual  = 1 if network == 2 & !missing(approval9)
			gen ind_municipal = 1 if network == 3 & !missing(approval9)
			collapse (sum) ind_estadual ind_municipal , by (id_13_mun tipo_municipio_ef2) 							//number of schools offering 6th to 9th grade 
			merge 1:1 id_13_mun tipo_municipio_ef2 using `munef2'
			
			gen 	order = 1 in 4
			replace order = 2 in 5
			replace order = 3 in 1
			replace order = 4 in 2
			replace order = 5 in 3
			sort	order
			
			mkmat  ind		    , matrix(ind)
			matrix ind			 = ind'
			mkmat  ind_estadual , matrix(ind_estadual)
			mkmat  ind_municipal, matrix(ind_municipal)
		
			matrix B = (el(ind_estadual,1,1), el(ind_municipal,1,1), el(ind_estadual,2,1), el(ind_estadual,3,1), el(ind_municipal,3,1), el(ind_municipal,4,1), el(ind_estadual,5,1))
			matrix A = (el(ind,1,1), 0, el(ind,1,2), el(ind,1,3), 0, el(ind,1,4), el(ind,1,5))\B
			
			clear
			svmat A
			foreach var of varlist * { 
			tostring `var', replace
			replace  `var' = "" if `var' == "0" 		in 1
			}
			
			gen 	name = "Number of municipalities"  	in 1
			replace name = "Number of schools" 			in 2
			
			foreach var of varlist A1 A4 A7 {
			replace `var' = `var' + " - state" in 2
			}
			foreach var of varlist A2 A3 A5 A6 {
			replace `var' = `var' + " - local" in 2
			}			
			
			set obs 5
			replace A1  = "13 municipalities in which " 		in 3
			replace A2  = "the local governments"  				in 3
			replace A3  = "extended the winter break" 			in 3
			replace A4  = "Other municipalities"  			 	in 3 
			replace A5  = "of the state in which "  			in 3 
			replace A6  = "local authorities did not"			in 3 
			replace A7  = "change the school calendar"			in 3 
			replace A1  = "With state" 							in 4 
			replace A2  = "and local schools"					in 4 
			replace A3  = "Only with state schools" 			in 4
			replace A4  = "With state" 							in 4 
			replace A5  = "and local schools" 					in 4 
			replace A6  = "Only with local schools" 			in 4 
			replace A7  = "Only with state schools " 			in 4 	
			replace A1  = "" 									in 5
			order name 
			gen 	order = 1 in 3
			replace order = 2 in 4
			replace order = 3 in 1
			replace order = 5 in 2
			replace order = 4 in 5			
			sort 	order
			drop order 
			export excel "$tables/TableA2.xlsx", replace
		
	
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Balance test
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$final/h1n1-school-closures-sp-2009.dta" if year == 2009 & !missing(math5) & uf == "SP", clear
		
		foreach var of varlist $matching_schools	{
			replace `var' = `var'*100
		}	

		
		*=============> Locally-managed schools in treated versus non-treated municipalities 
		iebaltab  $balance_students5  $matching_schools school_year enrollmentTotal pib_pcap if network == 3					, format(%12.2fc) grpvar(T) savetex("$tables/TableA3") 	rowvarlabels replace 

		
		*=============> Locally-managed schools versus state managed schools across all municipalities that did not extend the winter break of their local schools
		iebaltab  $balance_students5 $matching_schools  school_year enrollmentTotal pib_pcap if G == 1 & tipo_municipio_ef1 == 1, format(%12.2fc) grpvar(E) savetex("$tables/TableA4") 	rowvarlabels replace 

		
		*=============> Locally-managed schools versus state managed schools across all municipalities that did extend the winter break of their local schools
		iebaltab  $balance_students5 $matching_schools  school_year enrollmentTotal pib_pcap if G == 0 & tipo_municipio_ef1 == 1, format(%12.2fc) grpvar(E) savetex("$tables/TableA5") 	rowvarlabels replace 

		
		*=============> State managed schools in G = 1 and G = 0
		label drop G
		label define G 0 "State-managed in G = 0" 1 "State-managed in G = 1"
		label val    G G
		iebaltab  $balance_students5 $matching_schools school_year enrollmentTotal pib_pcap if network == 2						, format(%12.2fc) grpvar(G)	savetex("$tables/TableA6") 	rowvarlabels replace 
		
		
		*=============> Teachers and principals
		use "$final/h1n1-school-closures-sp-2009.dta" if uf == "SP", clear
		foreach v of varlist $balance_principals {
			replace   `v' = `v'*100
			format    `v' %4.2fc
			local    l`v' : variable label `v'
			label var `v' "`l`v'', %"
		}

		*=============> Locally-managed schools in treated versus non-treated municipalities 
		iebaltab  $balance_teachers $balance_principals if year == 2009 & !missing(math5) & network == 3				    	, format(%12.2fc) grpvar(T) savetex("$tables/TableA7")   rowvarlabels replace 
			
	
		*=============> Locally-managed schools versus state managed schools across all municipalities that did not extend the winter break of their local schools
		iebaltab  $balance_teachers $balance_principals if year == 2009 & !missing(math5) & G == 1 & tipo_municipio_ef1 == 1	, format(%12.2fc) grpvar(E) savetex("$tables/TableA8")   rowvarlabels replace 
				
		
		*=============> Locally-managed schools versus state managed schools across all municipalities that did extend the winter break of their local schools
		iebaltab  $balance_teachers $balance_principals if year == 2009 & !missing(math5) & G == 0 & tipo_municipio_ef1 == 1	, format(%12.2fc) grpvar(E) savetex("$tables/TableA9")   rowvarlabels replace 
				
				
		*=============> State managed schools in G = 1 and G = 0
		label drop G
		label define G 0 "State-managed, G=0" 1 "State-managed, G=1"
		label val    G G
		iebaltab  $balance_teachers $balance_principals if year == 2009 & !missing(math5) & network == 2						, format(%12.2fc) grpvar(G) savetex("$tables/TableA10")  rowvarlabels replace 
				

				
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Dif-in-dif -> Checking parallel trends of locally managed schools affected and non-affected by the school shutdowns
	**
	*--------------------------------------------------------------------------------------------------------------------------------*

		**
		*Math =============>
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$inter/time_trend_dif-in-dif_math5.dta", clear
		gen 	contrafactual = math5 + 4 if T == 1 & year == 2009
		replace contrafactual = math5     if T == 1 & year == 2007

		foreach language in english {

			if "`language'" == "english" {
				local ytitle  = "Test score, SAEB scale" 
				local legend1 = "Extended winter break"
				local legend2 = "Other municipalities"
				*local title  = "Math, 5{sup:th} grade"
				local note    = "Source: Prova Brasil." 
			}
			if "`language'" == "portuguese" {
				local ytitle  = "Proficiência, Escala SAEB" 
				local legend1 = "Adiamento das aulas"
				local legend2 = "Outros municípios"
				*local title  = "Matemática, 5{sup:o} ano"
				local note    = "Fonte: Prova Brasil." 
			}
					
			tw 	///
			(line math5 year if T == 1, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 													///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line math5 year if T == 0, lwidth(0.5) color(gs12) lp(solid) connect(direct) recast(connected)  	 												 		///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(3)  mlabsize(2.5)) 										 													///
			(line contrafactual year if T == 1 & (year == 2007 | year == 2009), lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 		///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
			ylabel(, labsize(small) gmax angle(horizontal) format(%4.0fc))											     												///
			yscale( alt )  																																				///
			xscale(r(2005(2)2009)) 																																		///
			yscale(r(170(10)220)) 																																		///
			ytitle("`ytitle'", size(small)) 																					 										///
			title("", pos(12) size(medium) color(black))													 															///
			xtitle("")  																																				///
			xlabel(2005(2)2009, labsize(medsmall) gmax angle(horizontal) format(%4.0fc))											     								///
		    graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "`legend1'"  2 "`legend2'"  3 "Contrafactual") pos(12) cols(1) size(medlarge) region(lwidth(none) color(white) fcolor(none))) 				///
			ysize(5) xsize(5) 																										 									///
			note("`note'", span color(black) fcolor(background) pos(7) size(small)))  
			graph export "$figures/time-trend-math.pdf", as(pdf) replace
			*graph export "$figures/time-trend-math_graph-`language'.pdf", as(pdf) replace
		}
		 
		**
		*Portuguese =============>
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$inter/time_trend_dif-in-dif_port5.dta", clear
		gen 	contrafactual = port5 + 1 if T ==1 & year == 2009
		replace contrafactual = port5 	  if T ==1 & year == 2007

			tw 	///
			(line port5 year if T ==1, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 		 													///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line port5 year if T ==0, lwidth(0.5) color(gs12) lp(solid) connect(direct) recast(connected)  	 														///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(3)  mlabsize(2.5)) 										 													///
			(line contrafactual year if T ==1 & (year == 2007 | year == 2009), lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 		///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
			ylabel(170(10)200, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
			yscale( alt )  																																				///
			xscale(r(2005(2)2009)) 																																		///
			yscale(r(170(10)200)) 																																		///
			ytitle("Test score, SAEB scale", size(small)) 																					 							///
			xlabel(2005(2)2009, labsize(medsmall) gmax angle(horizontal) format(%4.0fc))											     								///
			title("", pos(12) size(medium) color(black))																												///
			xtitle("")  																																				///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "Extended winter break"  2 "Other municipalities"  3 "Contrafactual") cols(1) pos(12) size(medlarge) region(lwidth(none) color(white) fcolor(none))) ///
			ysize(5) xsize(5) 																																			///
			note("Source: Prova Brasil.", span color(black) fcolor(background) pos(7) size(small)))  
			graph export "$figures/time-trend_port.pdf", as(pdf) replace
						
		**
		*Repetition =============>
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$inter/time_trend_dif-in-dif_repetition5.dta", clear

			tw 	///
			(line repetition5 year if T ==1, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 		 											///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line repetition5 year if T ==0, lwidth(0.5) color(gs12) lp(solid) connect(direct) recast(connected)  	 													///  
		    ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(3)  mlabsize(2.5)										 													///
			ylabel(, labsize(small) gmax angle(horizontal) format(%4.0fc))											     												///
			yscale( alt )  																																				///
			xscale(r(2007(1)2009)) 																																		///
			yscale(r()) 																																				///
			ytitle("%", size(small)) 																					 												///
			xlabel(2007(1)2009, labsize(medsmall) gmax angle(horizontal) format(%4.0fc))											     								///
			title("", pos(12) size(medium) color(black))																												///
			xtitle("")  																																				///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "Extended winter break"  2 "Other municipalities"  3 "Contrafactual") cols(1) pos(12) size(medlarge) region(lwidth(none) color(white) fcolor(none))) ///
			ysize(5) xsize(5) 																																			///
			note("Source: Prova Brasil.", span color(black) fcolor(background) pos(7) size(small)))  
			
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Triple Dif -> Checking parallel trends of state and local-managed schools prior to 2009
	*Dependent variables: math and portuguese performance
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		**
		*Municipalities by grades they offered
		use 			tipo_municipio_ef1 tipo_municipio_ef2 codmunic year  using"$final/h1n1-school-closures-sp-2009.dta", clear
		duplicates drop codmunic year, force
		tempfile tipo
		save 	`tipo'
	
		**
		**IDEB at municipal level for state and locally-managed schools
		use "$inter/IDEB by municipality.dta" if uf == "SP" & (network == 2 | network == 3) & year < 2009, clear
		merge m:1 codmunic year using `tipo', nogen keep(3)

		**
		*Parameters for triple dif
		gen D = (year == 2007)
		gen E = network == 2

		gen beta1  = E
		gen beta2  = D
		gen beta3  = D*E
		gen beta4  = G
		gen beta5  = E*G
		gen beta6  = G*D
		gen beta7  = E*G*D 
		label var beta1 "State-managed"
		label var beta2 "Post-treatment year (2007)" 
		label var beta3 "State-managed versus post-treatment" 
		label var beta4 "G = 1"
		label var beta5 "State-managed versus G = 1"
		label var beta6 "Post-treatment versus with G = 1" 
		label var beta7 "Triple difference in differences"
		
		/*
		1st -> we run a dif-in-dif comparing local and state-managed schools in G = 1 (that is, municipalities that did not extend the winter break of their
		local schools. In G = 1, the treatment group => state managed schools; and comparison group => locally-managed schools.
		We can observe that these groups do not have parallel trends prior to 2009. 
		
		2nd -> we run a triple dif in dif. The 1st difference is a dif-in-dif model comparing state and locally-managed schools in G = 1.
										   The 2nd difference is a dif-in-dif model comparing state and locally managed schools in G = 0. 
										   That is why we have beta1 to beta7 as defined above. The triple dif coefficient is the beta7 coefficient. 
		
		*/
		
		**
		*Regressions
		eststo: reg math5 beta1 beta2 beta3	 	 if tipo_municipio_ef1 == 1	& G == 1	//dif in dif, municipalities with state and locally managed schools offering 1st to 5th grade
		eststo: reg math5 beta1-beta7		 	 if tipo_municipio_ef1 == 1				//triple dif-in-dif
	 
		eststo: reg port5 beta1 beta2 beta3		 if tipo_municipio_ef1 == 1 & G == 1
		eststo: reg port5 beta1-beta7			 if tipo_municipio_ef1 == 1
		
		eststo: reg math9 beta1 beta2 beta3		 if tipo_municipio_ef2 == 1 & G == 1
		eststo: reg math9 beta1-beta7			 if tipo_municipio_ef2 == 1
	
		eststo: reg port9 beta1 beta2 beta3		 if tipo_municipio_ef2 == 1 & G == 1
		eststo: reg port9 beta1-beta7		 	 if tipo_municipio_ef2 == 1
		
		estout * using "$tables/TableA11.csv", keep(beta*) delimiter(";") label cells(b(star fmt(3))  se(fmt(2))) stats(N r2_a, fmt(%9.0g %9.3f)) replace
		
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Triple Dif -> Checking parallel trends of state and local-managed schools prior to 2009
	*Dependent variables: approval, repetition and dropout rates
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		estimates clear
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2007 | year == 2008, clear
				
		**
		*Regressions
		eststo: reg approval5 	beta1P2 beta3P2 beta5P2 i.codmunic  if tipo_municipio_ef1 == 1 & G == 1 //dif in dif, municipalities with state and locally managed schools offering 1st to 5th grade
		eststo: reg approval5 	beta1P2-beta7P2			i.codmunic  if tipo_municipio_ef1 == 1			//triple dif-in-dif
		 
		eststo: reg repetition5 beta1P2 beta3P2 beta5P2 i.codmunic if tipo_municipio_ef1 == 1 & G == 1
		eststo: reg repetition5 beta1P2-beta7P2			i.codmunic if tipo_municipio_ef1 == 1
			
		eststo: reg dropout5 	beta1P2 beta3P2 beta5P2 i.codmunic if tipo_municipio_ef1 == 1 & G == 1
		eststo: reg dropout5 	beta1P2-beta7P2 		i.codmunic if tipo_municipio_ef1 == 1
					
		eststo: reg approval9 	beta1P2 beta3P2 beta5P2 i.codmunic if tipo_municipio_ef2 == 1 & G == 1
		eststo: reg approval9 	beta1P2-beta7P2			i.codmunic if tipo_municipio_ef2 == 1

		eststo: reg repetition9 beta1P2 beta3P2 beta5P2 i.codmunic if tipo_municipio_ef2 == 1 & G == 1
		eststo: reg repetition9 beta1P2-beta7P2			i.codmunic if tipo_municipio_ef2 == 1
		
		eststo: reg dropout9 	beta1P2 beta3P2 beta5P2 i.codmunic if tipo_municipio_ef2 == 1 & G == 1
		eststo: reg dropout9 	beta1P2-beta7P2	 		i.codmunic if tipo_municipio_ef2 == 1
			
		estout * using "$tables/TableA12.csv", keep(beta*) delimiter(";") label cells(b(star fmt(3))  se(fmt(2))) stats(N r2_a, fmt(%9.0g %9.3f)) replace
		
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*OLS, 2007 at municipalily level, probability of closing schools according to  characteristics of the municipalities
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$inter/H1N1.dta" if substr(string(codmunic2), 1,2) == "35", clear
		egen hosp_h1n1_july = rsum(week*)
		
		bys T: su hosp_h1n1
		
		use  "$final/h1n1-school-closures-sp-2009.dta" if uf == "SP" & network == 3 & year == 2007, clear
		foreach v of var * {
		local l`v' : variable label `v'
			if `"`l`v''"' == "" {
			local l`v' "`v'"
			}
		}
	
		*collapse (mean) spt5 $balance_students5 $balance_teachers $balance_principals [aw = enrollment5], by (T codmunic year)
		foreach v of var * {
			label var `v' "`l`v''"
		}
		foreach var of varlist $balance_principals {
			replace `var' = `var'*100
		}
		
		merge m:1  codmunic year using "$inter/GDP per capita.dta", keep(1 3) nogen
		
		merge m:1  codmunic2 	 using "$inter/H1N1.dta"		  , keep(1 3) nogen keepusing(week_16 week_31) 
		egen  hosp_h1n1_july = rsum(week*)

		

		label var hosp_h1n1_july  "H1N1 cases per 1.000 inhabitants (Late July 2009)"
		label var pop 		"Population"
		label var pib_pcap  "GDP per capita"


		estimates clear
		eststo: reg T math5 port5 repetition5 dropout5 ///
		classhour5 spt5 lack_books quality_books45 ///
		share_students_books55 covered_curricula45 ///
		student_effort_index5 principal_effort5 teacher_tenure5 absenteeism_students3 ///
		absenteeism_teachers3 classrooms_similar_ages pib_pcap pop  hosp_h1n1_july 

		estout * using "$tables/TableA13.csv",  delimiter(";") label varlabels(_cons Constant) cells(b(star fmt(3))  se(fmt(3))) stats(N r2_a, labels ("Obs" "Adj. R-squared") fmt(%9.0g %9.4f)) replace
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Visual analysis comparing state and locally-managed schools
	**
	*--------------------------------------------------------------------------------------------------------------------------------*

		**
		*Enrollment by municipality
		use 	"$inter/Enrollments.dta", clear
		collapse (sum)enrollment*, by(year codmunic network)
		tempfile enrollments
		save 	`enrollments'
		
		**
		*Municipalities by grades they offered
		estimates clear
		use 			tipo_municipio_ef1 tipo_municipio_ef2 codmunic year  using"$final/h1n1-school-closures-sp-2009.dta", clear
		duplicates drop codmunic year, force
		tempfile tipo
		save 	`tipo'
	
		**
		*Performance in Math
		use 	"$inter/IDEB by municipality.dta" if uf == "SP" & (network == 2 | network == 3) , clear
		merge 	1:1 codmunic year network using `enrollments', nogen keep(3)
		sort 	codmunic year
		merge	m:1 codmunic year using `tipo', nogen keep(3)
		
		keep if tipo_municipio_ef1 == 1	

		collapse (mean)math5 port5 [aw = enrollment5grade], by(year G network)
			tw 	///
			(line  math5  year if network == 2, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 											///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line math5  year if network == 3, by(G) lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 									///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
			ylabel(, labsize(small) gmax angle(horizontal) format(%4.1fc))											     												///
			yscale( alt )  																																				///
			title("", pos(12) size(medium) color(black))													 															///
			xtitle("")  																																				///
			xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "Estadual"  2 "Municipal" ) size(small) region(lwidth(none) color(white) fcolor(none))) 														///
			ysize(5) xsize(5) 																										 									///
			note("", color(black) fcolor(background) pos(7) size(small)))  

		**
		*Aproval rates
		use"$final/h1n1-school-closures-sp-2009.dta" if year > 2005, clear
		collapse (mean)approval5 repetition5 dropout5 [aw = enrollment5], by(year G network)
			tw 	///
			(line approval5  year if network == 2, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 											///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line approval5 year if network == 3, by(G) lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 								///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
			ylabel(80(5)100, labsize(small) gmax angle(horizontal) format(%4.1fc))											     										///
			yscale( alt )  																																				///
			title("", pos(12) size(medium) color(black))													 															///
			xtitle("")  																																				///
			xlabel(2007(1)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "Estadual"  2 "Municipal" ) size(small) region(lwidth(none) color(white) fcolor(none))) 														///
			ysize(5) xsize(5) 																										 									///
			note("", color(black) fcolor(background) pos(7) size(small)))  

			
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*IDEB estimate after Covid
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$inter/IDEB by municipality.dta" if network == 3, clear
		gen T = 0
		foreach munic in $treated_municipalities {
			replace T = 1 if codmunic == `munic'
		}

		keep if treated
		collapse (mean) idebEF1 targetEF1 math5 port5 approval5 spEF1, by (year)
		sort year
		replace   math5 		 = math5[_n-1] - 20  				if year == 2021  //considering that we will lose one year of learning, which is estimated do be equivalent to 20 points in the SAEB score scale. 
		replace   port5 		 = port5[_n-1] - 20  				if year == 2021 
		replace   approval5      = approval5[_n-1] 					if year == 2021 
		gen 	  media_nota 	 = (math5+port5)/2
		gen var = media_nota[_n]/media_nota[_n-1] - 1
		replace   spEF1   		 = spEF1[_n-1] + spEF1[_n-1]*var 	if year == 2021 
		replace   idebEF1 		 = spEF1*approval5 			  		if year == 2021

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
		*graph export "$figures/ideb_projected.pdf", as(pdf) replace
				
				
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Treatment and comparison groups
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$raw/Geocodes/mun_brasil.dta" if coduf == 35, clear
		gen T = 0
		foreach munic in $treated_municipalities {
			replace T = 1 if codmunic == `munic'
		}
		rename id _ID
		gen 	grupo = 1 if T ==1
		replace grupo = 2 if T ==0

		spmap  grupo using "$raw/Geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 1 2)																						///
		fcolor(cranberry*0.8 gs12 ) 																							///
		legorder(lohi) 																											///
		legend(order(2 "Extended winter break" 3 "Other municipalities") size(vlarge)) 
		graph export "$figures/treatment-comparison.pdf", as(pdf) replace
		
		spmap  grupo using "$raw/Geocodes/mun_coord.dta", id(_ID) 																///
		clmethod(custom) clbreaks(-1 1 2)																						///
		fcolor(cranberry*0.8 gs12 ) 																							///
		legorder(lohi) 																											///
		legend(order(2 "Adiamento das aulas" 3 "Outros municípios") size(medium))
		
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Affected network by the shutdowns
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use 	"$inter/Enrollments.dta" if year == 2009 & (network == 3 | network == 2), clear
		gen T = 0
		foreach munic in $treated_municipalities {
			replace T = 1 if codmunic == `munic'
		}
			replace T = 1 if network == 2
		
		collapse 	(sum)enrollmentEF, by (codschool treated)
		gen 		var1 = 1 if enrollmentEF > 0 & !missing(enrollmentEF)  //1 if the school offers EF
		drop 		if var1 == . 
		collapse 	(sum)var1 enrollmentEF*, by (treated)
			
		gen 		var2 = enrollmentEF
		drop 		enrollmentEF
		reshape 	long var, i(treated) j(tipo) 
		reshape 	wide var, i(tipo)    j(treated)
		
		label 		define municipalites 1 "School" 2 "Enrollments"
		label 		val    tipo municipalites
		set scheme s1mono
		graph pie var1 var0 , by(tipo, note("") graphregion(fcolor(white))) pie(1,  color(cranberry*0.7)) pie(2, explode color(gs14))     					///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))  													///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 												 	///
		plabel(_all percent, gap(5) format(%12.1fc) size(medium)) 																							///
		title(, pos(12) size(medsmall) color(black)) 																										///
		legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6)) 	///
		note("Source: School Census, 2009.", span color(black) fcolor(background) pos(7) size(small)) 
		*graph export "$figures/students-affected.pdf", as(pdf) replace	 
			
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Histogram the math performance of treatment and comparison groups
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use"$final/h1n1-school-closures-sp-2009.dta" if network == 3, clear		//only locally-managed schools

		twoway (histogram math5  if year == 2007 & T == 1,  fcolor(emidblue) lcolor(black) percent) 														///
			   (histogram math5  if year == 2007 & T == 0,  percent    																						///
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
		*graph export "$figures/histogram-performance-math.pdf", as(pdf) replace	
	
	
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Histogram GDP per capita
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$inter/GDP per capita.dta", clear
		replace pib_pcap = pib_pcap/1000
		
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
		xtitle("In thousands 2009 BRL", size(medsmall) color(black))  																///
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
		*graph export "$figures/gdp-per-capita.pdf", as(pdf) replace	
	
	/*
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Expenditure per student
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$inter/FNDE Indicators.dta" if year == 2008 & network == 3, clear		
		gen T = .
		
		foreach munic in $treated_municipalities2 {
			replace T = 1 if codmunic2 == `munic' 
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
		fcolor(none) lcolor(emidblue*1.5)), legend(order(1 "Grupo de Comparação" 2 "Grupo de Tratamento") region(lwidth(none))) 	///
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
	*/
		
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Hospitalizations due to H1N1
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use week_16-week_31 hosp_h1n1 treated codmunic2 using "$inter/H1N1.dta", clear

		foreach munic in $treated_municipalities2 {
			su hosp_h1n1  if codmunic2 == `munic'
			local pos`munic' = r(mean)
		}
		
		su 	  hosp_h1n1, detail
		local media = string(`r(mean)',"%10.2fc")
		local mean = r(mean)
		
		twoway (histogram hosp_h1n1 ,  percent    																					///
		title("", pos(12) size(medsmall) color(black))																				///
		yscale(alt)																													///
		ylabel(, labsize(small)) xlabel(, format (%12.2fc) labsize(small) gmax angle(horizontal)) 									///
		ytitle("%", size(medsmall) color(black))  																					///
		xtitle("Hospitalization per 1.000 inhabitants", size(small) color(black))  													///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							///
		fcolor(emidblue*0.5) lcolor(emidblue*1.5)), legend(order(1 "Grupo de Comparação" 2 "Grupo de Tratamento") region(lwidth(none))) ///
		text(15 `pos355030' "{bf:São Paulo}" 			 , size(vsmall) color(cranberry*0.8)) ///
		text(20 `pos350950' "{bf:Campinas}"  			 , size(vsmall) color(cranberry*0.8)) ///
		text(14 `pos351380' "{bf:Diadema}"   			 , size(vsmall) color(cranberry*0.8)) ///
		text(13 `pos352050' "{bf:Indaiatuba}"			 , size(vsmall) color(cranberry*0.8)) ///
		text(12 `pos352850' "{bf:Mairiporã}" 			 , size(vsmall) color(cranberry*0.8)) ///
		text(11 `pos353440' "{bf:Osasco}"    			 , size(vsmall) color(cranberry*0.8)) ///
		text(10 `pos354870' "{bf:São Bernardo do Campo}" , size(vsmall) color(cranberry*0.8)) ///
		text(9  `pos354780' "{bf:Santo André}" 		 	 , size(vsmall) color(cranberry*0.8)) ///
		text(13 `pos354880' "{bf:São Caetano do Sul}" 	 , size(vsmall) color(cranberry*0.8)) ///
		text(18 `pos355240' "{bf:Sumaré}" 				 , size(vsmall) color(cranberry*0.8)) ///
		text(16 `pos354340' "{bf:Ribeirão Preto}" 		 , size(vsmall) color(cranberry*0.8)) ///
		text(14 `pos355280' "{bf:Taboão da Serra}" 		 , size(vsmall) color(cranberry*0.8)) ///
		text(17 `pos351500' "{bf:Embu das Artes}" 		 , size(vsmall) color(cranberry*0.8)) ///
		text(25  0.55		"{bf: Average number of hospitalizations}" 			 , size(medsmall) color(cranberry*1.2)) 			///
		legend(order(1 "poi"))																										///
		ysize(5) xsize(7) 																											///
		xline(`mean', lcolor(cranberry) lpattern(dash)) ///
		note("Source: DATASUS, 2009.", span color(black) fcolor(background) pos(7) size(small)) 
		*graph export "$figures/hospitalizations-h1n1.pdf", as(pdf) replace	
	
	    drop hosp_h1n1
	    reshape long week_, i(codmunic2 treated) j(week)
		replace week_ = 0 if week_ == .
		drop if week_ == 0 

		twoway (histogram week_  if treated == 1,  bin(10) fcolor(emidblue) lcolor(black)      percent) 								///
			   (histogram week_  if treated == 0,  bin(40) fcolor(none)     lcolor(cranberry)  percent    								///
		title("", pos(12) size(medium) color(black))																					///
		subtitle("" , pos(12) size(medsmall) color(black))  																			///
		ylabel(, labsize(small)) xlabel(, format (%12.3fc) labsize(small) gmax angle(horizontal)) 										///
		yscale(alt) 																													///
		xtitle("Hospitalization per 1.000 inhabitants", size(medsmall) color(black))  													///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 								///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 								///
		ysize(5) xsize(7) 																												///
		fcolor(none) lcolor(black)), legend(order(1 "Extended winter break" 2 "Other municipalities") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(6)) ///
		note("Source: DATASUS.", span color(black) fcolor(background) pos(7) size(small)) 
		graph export "$figures/hospitalizations-h1n1.pdf", as(pdf) replace	
	

		
	
	
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*School infrastructure
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use"$final/h1n1-school-closures-sp-2009.dta" if year == 2009 & network == 3,  clear
		collapse (mean) $matching_schools, by(T)
		
		rename (ComputerLab ScienceLab SportCourt Library InternetAccess) (var_1 var_2 var_3 var_4 var_5)
		reshape long var_, i(T) j(infra)
		reshape wide var_, i(infra) j(T)
		
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
		*graph export "$figures/school-infra.pdf", as(pdf) replace	

		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*Size of the affected municipalities
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use "$inter/GDP per capita.dta", clear
		keep if year == 2009
		merge 1:1 codmunic using "$raw/Geocodes/mun_brasil.dta", keep(1 3)

		rename id _ID
		gen 	grupo = 1 if pop < 50 
		replace grupo = 2 if pop > 50  & pop < 100
		replace grupo = 3 if pop > 100 & pop < 500
		replace grupo = 4 if pop > 500 & !missing(pop)
	
		spmap  grupo using "$raw/Geocodes/mun_coord.dta", id(_ID) 																						///
		clmethod(custom) clbreaks(0 1 2 3 4 5)																											///
		fcolor(gs14 emidblue*0.5 emidblue red*1.05) 																									///
		legorder(lohi) 																																	///
		legend(order(2 "Up to 50k" 3 "Between 50k-100k" 4 "Between 100k-500k" 5 "More than 1 million") size(medium)) saving (distance_`distance', replace)
		*graph export "$figures/population.pdf", as(pdf) replace
	
		
	*--------------------------------------------------------------------------------------------------------------------------------*
	**
	*% of students with insufficient performance
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		use 	"$final/Performance & Socioeconomic Variables of SP schools.dta", clear

		bys T:   		su	 math_insuf5 	if year == 2007 & network == 3
		bys T:   		su	 math5 	      	if year == 2007 & network == 3
		
		bys T:   		su   port_insuf5 	if year == 2007 & network == 3
		bys T:   		su	 port5 			if year == 2007 & network == 3
		
		bys id_13_mun: 	su	 math_insuf5 	if year == 2007 & network == 2
		bys id_13_mun: 	su	 math5 			if year == 2007 & network == 2
		
		bys id_13_mun: 	su   port_insuf5 	if year == 2007 & network == 2
		bys id_13_mun: 	su   port5 			if year == 2007 & network == 2
		
		bys T:   		su	 math_insuf9 	if year == 2007 & network == 3
		bys T:   		su   port_insuf9 	if year == 2007 & network == 3
		
		keep 	 if year == 2009
		by 		 T, sort: quantiles math5, gen(quintile) stable  nq(10)
		collapse (mean)mother_edu_highschool5 ever_repeated5 ever_dropped5 number_repetitions5 math_insuf5, by(quintile T)
		
