
												*ESTIMATIVA DO EFEITO DO ADIAMENTO DO RETORNO ÀS AULAS EM DECORRÊNCIA DO H1N1*
																  **ESCOLAS MUNICIPAIS DE SÃO PAULO**

*global final   "C:\Users\wb495845\OneDrive - WBG\Desktop"
*global results "C:\Users\wb495845\OneDrive - WBG\Desktop"
*global inter   "C:\Users\wb495845\OneDrive - WBG\Desktop"

															  
*Author: Vivian Amorim
*vivianamorim5@gmail.com

set scheme economist
set seed 1


*Program to store results -> We do that because we show the results in figures
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	estimates clear
	matrix 	results = (0,0,0,0,0,0)
	matrix  ri      = (0,0,0)
	
	cap program drop mat_res
	program define   mat_res
	syntax, model(integer) sub(integer) var(varlist) dep_var(varlist)
		
		*Mean & sd
		su 		`dep_var' if year == 2007 
		scalar 	 media = r(mean)
		scalar   sd    = r(sd)
		
		su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 1
		scalar 	 mediaT = r(mean)
		scalar   sdT    = r(sd)

		su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 0
		scalar 	 mediaC = r(mean)
		scalar   sdC    = r(sd)

		*Coeficient
		matrix A   = r(table) 	
		local beta = A[1,1]																					//Average treatment effect on the treated - ATT

		*CI
		boottest `var',  reps(1000)  boottype(wild)  seed(1) level(95) 	bootcluster(codmunic) quietly		//Confidence interval
		matrix A = r(CI)
		matrix results = results \ (`model', `sub', `beta', A[1,1], A[1,2], 0)								//Model tested, subject, ATT, lower bound, upper bound. 
		
		scalar pvalue 	= r(p)
		scalar lowerb 	= el(r(CI),1,1)
		scalar upperb 	= el(r(CI),1,2)
		
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar pvalue = pvalue: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar lowerb = lowerb: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar upperb = upperb: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar media  = media: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar sd     = sd: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar mediaT  = mediaT: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar sdT     = sdT: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar mediaC  = mediaC: model`model'`sub'
		if (`model' == 1 & `sub' < 4) | `model' == 2 estadd scalar sdC     = sdC: model`model'`sub'
				
	end

	
*Regressions
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		foreach subject in sp math math_insuf_ port port_insuf_ { 
		 
			if "`subject'" == "port" | "`subject'" == "padr_port" {
				local sub = 1					//subject = 1, Portuguese
				local title = "Português"
			}
			
			if "`subject'" == "math" | "`subject'" == "padr_math" {
				local sub = 2					//subject = 2, Math
				local title = "Matemática"
			}
			
			if "`subject'" == "sp"  {
				local sub = 3					//subject = 3, Standardized score, Portuguese and Math
				local title = "Português e Matemática"
			}
			
			if "`subject'" == "math_insuf_"  {
				local sub = 4					//subject = 4, % of students below the adequate level in Math
				local title = "% desempenho insuficiente em Matemática"
			}
						
			if "`subject'" == "port_insuf_"  {
				local sub = 5					//subject = 5, % of students below the adequate level in Portuguese
				local title = "% desempenho insuficiente em Português"
			}
						

				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				*A*
				*Dif in dif
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
				gen t = (year > 2007)
				keep if year == 2005 | year == 2007 | year == 2009
				drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 				//municipalities without 5th grade scores in 2005
				sort 	codschool year
				replace enrollment5 = enrollment5[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codschool[_n] == codschool[_n+1]
					
					*A.1*
					*Lasso to select controls - 2005 e 2007 
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	   ///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5

					*lasso linear `subject'5 $controls2005 if year <= 2007, rseed(1)						
					*global controls2005  `e(allvars_sel)'
				
					*A.2*
					*Lasso to select controls - 2007 e 2009
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2007 c.mother_edu_5##c.mother_edu_5 c.ndropout_5##c.ndropout_5 c.nrepetition_5##c.nrepetition_5 c.computer_5##c.computer_5	///
					c.pib_pcap##c.pib_pcap c.approval5##c.approval5  c.studentwork_5##c.studentwork_5 						   									///
					c.white_5##c.white_5 c.female_5##c.female_5 c.privateschool_5##c.privateschool_5 c.livesmother_5##c.livesmother_5 							///
					c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 															///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour5##c.classhour5 c.tclass5##c.tclass5 									///
					c.SIncentive1_5##c.SIncentive1_5 c.SIncentive2_5##c.SIncentive2_5 c.SIncentive3_5##c.SIncentive3_5	 										///
					c.SIncentive4_5##c.SIncentive4_5 c.SIncentive5_5##c.SIncentive5_5 c.SIncentive6_5##c.SIncentive6_5 										

					*lasso linear `subject'5 $controls2007 if year >= 2007, rseed(1)		
					*global controls2007  `e(allvars_sel)'
					
					global controls2007 mother_edu_5 c.mother_edu_5#c.mother_edu_5 ndropout_5 c.ndropout_5#c.ndropout_5 nrepetition_5 c.nrepetition_5#c.nrepetition_5 		///
					computer_5 c.computer_5#c.computer_5 pib_pcap c.pib_pcap#c.pib_pcap approval5 c.approval5#c.approval5	studentwork_5 c.studentwork_5#c.studentwork_5 	///
					white_5 c.white_5#c.white_5 female_5 c.female_5#c.female_5 privateschool_5 c.privateschool_5#c.privateschool_5 	c.livesmother_5#c.livesmother_5			///
					ComputerLab c.ScienceLab#c.ScienceLab c.Library#c.Library c.InternetAccess#c.InternetAccess classhour5 c.classhour5#c.classhour5 						///
					tclass5 c.tclass5#c.tclass5 c.SIncentive1_5#c.SIncentive1_5 c.SIncentive2_5#c.SIncentive2_5 c.SIncentive3_5#c.SIncentive3_5 SIncentive4_5 SIncentive5_5 ///
					c.SIncentive5_5#c.SIncentive5_5 c.SIncentive6_5#c.SIncentive6_5
					
					
					*A.3*
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					local weight enrollment5		//5th grade enrollment as weight 
					
						*2007 versus 2005
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 T2007 		  								 i.treated i.codmunic i.year $controls2005 	if year >= 2005 & year <= 2007  [aw = `weight'], cluster(codmunic)
							if `sub' != 4 & `sub' != 5 eststo model1`sub', title("I")
							mat_res, model(1) sub(`sub') var(T2007)	dep_var(`subject'5)	
							*ritest treated _b[T2007], seed(1) reps(1000) cluster(codmunic): reg `subject'5 T2007 i.treated i.codmunic i.year $controls2005 if year >= 2005 & year <= 2007, cluster(codmunic)
							*matrix ri = ri\[1, `sub', el(r(p),1,1)] 		//erro padrão com RI
						
						*2009 versus 2005/2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 T2007 T2009 	  							 	 i.treated i.codmunic i.year $controls2005 	if year >= 2005 & year <= 2009  [aw = `weight'], cluster(codmunic)					
							keep if e(sample) == 1

						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 	    T2009	  								 i.treated i.codmunic i.year $controls2007 	if year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
							eststo model2`sub', title("II")  
							mat_res, model(2) sub(`sub') var(T2009) dep_var(`subject'5)	

						/*
						*CIC
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						if "`subject'" == "port" | "`subject'" == "math" {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic continuous `subject'5 treated t $controls2007 i.codmunic if year >= 2007 & year <= 2009  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix A = r(table)
								matrix results = results \ (3, `sub', A[1, colsof(A)-2], A[5,colsof(A)-2], A[6,colsof(A)-2], `quantile')	 	
							}
						}
						*/
						
						*Parallel trends
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						collapse (mean)`subject'5 [aw = `weight'], by(year treated)
						format 	 	   `subject'5 %4.1fc
						save 		   "$inter/trend_`subject'.dta", replace
						
						tw 	///
						(line `subject'5 year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected) 	 ///  
						ml(`subject'5) mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) 									 ///
						(line `subject'5 year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  	 ///  
						ml(`subject'5) mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) 										 ///
						ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%4.0fc))											     ///
						ytitle("Escala SAEB", size(small)) 																					 ///
						title("`title', 5{sup:o} ano", pos(12) size(medsmall) color(black))													 ///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
						legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 						 ///
						ysize(6) xsize(7) 																									 ///
						note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small)))  
						
		}
		
	estout * using "$results/Regressions.csv", delimiter(";") keep(T20*) label cells(b(fmt(3)) se(fmt(3))) stats(N r2 pvalue lowerb upperb media sd mediaT sdT mediaC sdC) mgroups("Math & Portuguese" "Math" "% below adequate level" "Portuguese" "% below adequate level",   pattern(1 0 1 0 1 1 0 1)) replace 
 

*Results			
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	clear
	svmat results
	drop  in 1
	rename (results1-results6) (spec sub  beta lower upper quantile)	
	label define sub   1 "Português"  2 "Matemática" 3 "Português e matemática" 4 "Insuficiente em matemática" 5 "Insuficiente em Português"
	label define spec  1 "2007 comparado com 2005" 2 "2009 comparado com 2007"  3 "Quantile"
	label define quantile 0 "Total" 20 "1o quintil" 40 "2o quintil" 60 "3o quintil" 4 "4o quintil" 
	label val sub sub
	label val spec    spec
	label var beta   "Coef. adiamento das aulas"
	label var lower  "Lower bound"
	label var upper  "Upper bound"
	format beta lower upper %4.2fc
	save "$final/Regression Results.dta", replace


*Charts
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	
	**
	*Português e Matemática
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Regression Results.dta", clear
		drop if spec == 3 | sub == 3 | sub == 4 | sub == 5 //quantile
		gen spec1 = spec
		replace spec1 = 3 if spec == 1 & sub == 2
		replace spec1 = 4 if spec == 2 & sub == 2
		
			foreach language in port english {

				if "`language'" == "english" {
					local ytitle = "SAEB scale" 
					local legend = "Extended winter break"
					local port = "Portuguese"
					local math = "Math"
					local both = "Portuguese & Math"
					local note = "Source: Author's estimate." 
				}
				
				if "`language'" == "port" {
					local ytitle = "Escala SAEB" 
					local legend = "Adiamento das aulas"
					local port   = "Português"
					local math   = "Matemática"
					local note   = "Fonte: Estimativa dos autores." 
				}				
			
					twoway    bar beta spec1 if spec1 == 1, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
						   || bar beta spec1 if spec1 == 3, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
					yline(0, lpattern(shortdash) lcolor(cranberry)) 																																///
					xline(2.5, lpattern(shortdash) lcolor(navy)) 																																	///
					xtitle("", size(medsmall)) 											  																											///
					ytitle("{&gamma}, `ytitle'", size(small)) ylabel(-8(2)4, labsize(small) gmax angle(horizontal) format (%4.1fc))  																///					
				    xlabel(1 `" "2007" "versus 2005" "' 2 `" "2009" "versus 2007" "' 3 `" "2007" "versus 2005" "' 4 `" "2009" "versus 2007" "', labsize(small) ) 									///
					xscale(r(0.5 2.5)) 																																								///
					title(, size(medsmall) color(black)) 																																			///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																		///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																				///						
					legend(order(1 "Placebo" 2 "`legend'" 3 "95% CI" ) region(lstyle(none) fcolor(none)) size(medsmall))  																			///
					text(3.5 1.5 "`port'") 																																							///
					text(3.5 3.5 "`math'") 																																							///
					ysize(4) xsize(4)  ///
					note("`note'", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Dif-in-Dif_5ano_`language'.pdf", as(pdf) replace
			}		
		
	**	
	*Estimates in standard deviation
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2007
	drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 //municipios sem prova brasil em 2005
	
	foreach var of varlist sp5 math5 port5 {
		su `var', detail
		local sd_`var'  = r(sd)
	}

	matrix A =  [3, `sd_sp5' \ 2, `sd_math5' \ 1, `sd_port5']
	clear
	svmat A
	rename (A1-A2) (sub sd)
	tempfile sd
	save `sd' 
	
	use "$final/Regression Results.dta", clear
	merge m:1 sub using `sd', nogen
	foreach var of varlist beta lower upper {
		replace `var' = `var'/sd
	}
	keep if (sub == 1 | sub == 2 | sub == 3) & (spec == 1 | spec == 2)
			
	gen 	spec1 = spec
	replace spec1 = 3 if spec == 1 & sub == 1
	replace spec1 = 4 if spec == 2 & sub == 1	
	replace spec1 = 5 if spec == 1 & sub == 2
	replace spec1 = 6 if spec == 2 & sub == 2	
	set scheme s1mono
		
		twoway 	   bar beta spec1 if spec1 == 1, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
				|| bar beta spec1 if spec1 == 3, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
				|| bar beta spec1 if spec1 == 5, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 6, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
				yline(0, lpattern(shortdash) lcolor(cranberry)) 																																///
				xline(2.5, lpattern(shortdash) lcolor(navy)) 																																	///
				xline(4.5, lpattern(shortdash) lcolor(navy)) 																																	///
				xtitle("", size(medsmall)) 											  																											///
				ytitle("{&gamma}, in standard deviation", size(small)) ylabel(-0.4(0.1)0.2, labsize(small) gmax angle(horizontal) format (%4.1fc))  														///					
				xlabel(1 `" "2007" "versus 2005" "' 2 `" "2009" "versus 2007" "' 3 `" "2007" "versus 2005" "' 4 `" "2009" "versus 2007" "' 5 `" "2007" "versus 2005" "' 6 `" "2009" "versus 2007" "', labsize(small) ) 									///
				title(, size(medsmall) color(black)) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																		///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																				///						
				legend(order(1 "Robustness" 2 "Extended winter break" 3 "95% CI" ) cols(3) region(lstyle(none) fcolor(none)) size(medsmall))  													///
				text(0.2 1.6 "Portuguese & Math") 																																				///
				text(0.2 3.5 "Portuguese") 																																						///
				text(0.2 5.5 "Math") 																																							///
				ysize(4) xsize(6)  ///
				note("", color(black) fcolor(background) pos(7) size(small)) 
				graph export "$figures/Dif-in-Dif_5ano_all subjects.pdf", as(pdf) replace
	
	**
	*Impact on Math/Portuguese by percentile
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Regression Results.dta", clear
		keep if spec == 3 //quantile
		foreach sub in 1 2 {	

				*Title & cor
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if `sub' == 1  local title = "Portuguese"
					if `sub' == 2  local title = "Math"
		
					set scheme economist
					twoway 	scatter beta quantile if sub == `sub', msymbol(O) msize(medium) color(cranberry) || rcap lower upper quantile if sub == `sub', lcolor(navy)  lwidth(medthick)	///
					xtitle("Percentiles of test score distribution", size(small)) xlabel(10(10)90, labsize(small))										  								///
					ytitle("{&gamma}, SAEB scale", size(medsmall)) ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc))  														///					
					title(, size(large) color(black)) 																																		///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
					legend(order(1 "Extended winter break" 2 "95% CI" ) cols(2) region(lstyle(none) fcolor(none)) size(medsmall)) 	  																									///
					ysize(4) xsize(5)  		///																											
					note("Source: Author's estimate.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/Dif-in-Dif_Quantile_`title'_5ano.pdf", as(pdf) replace
			}
					

*estout q202 q402 q602 q802  q201 q401 q601 q801 using "$results/Quantiles",  style(tex) keep (q20 q40 q60 q80) label starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(fmt(3))) stats(N,  fmt(%5.0fc)  labels("Number of obs"))  mgroups("Math" "Portuguese",  pattern(1 0 0 0 1 0 0 0 )) replace //
