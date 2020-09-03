
															*IMPACTS OF SCHOOL SHUTDOWNS ON STUDENT'S LEARNING*
																        *2009, São Paulo/Brazil*

																		
set seed 1

*Important definitions
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
/*
**Unit of observation: schools. 
**Grade level: fifth grade. 
**Source of the data: Prova Brasil and School Census. 
**Period: 2005, 2007 (pre-treatment) and 2009 (post-treatment). 
**Dependent variables: proficiency of students in Portuguese, proficiency of students in math, standardized performance in Portuguese and Math, percentage of students with
insufficient performance in Portuguese and percentage of students with insufficient performance in math. 
**Independent variables: treatment status (variable treated = 1 for Treament Group; and 0 for Comparison Group); year dummy (variable year); municipality in each the 
school is located at (variable codmunic).
Our analysis includes a series of controls at the school level to account for differences between the groups that are probably correlated with both the decision 
to close the schools and the performance of the students. The vector of control variables was chosen based on a Lasso regression, 
which selects the variables that better predict the variation in the proficiency score. The selected variables are: if the school has science and computer lab, sport court, 
library and access to the internet; instruction hours per day; students per class; approval rates; GDP per capita of the municipality where the school is located; 
and socioeconomic characteristics of fifth graders. The vector of socioeconomic variables includes the percentage of mothers with a high school diploma; 
the percentage of students that already repeated or dropped out school; the percentage of whites and girls; the percentage of students that already work, 
that previously studied in a private school and that have a computer at home; the percentage of students whose parent's incentive them to study, to do the homework, 
to read, to not miss classes, and that talk about what happens in the school.
*/

/*
Models: 1, 2 and 3. 

**Model 1 is the robusteness check. In this model, the post-treament year is 2007 and pre-treatment is 2005. 
We set up the treatment dummy (T2007) equal to 1 for the year = 2007, and 0 if year = 2005.

**Model 2 is the estimation of the Average Treatment Effect (T2009). T2009 if equal if year = 2009, and 0 if year = 2007. 

**Model 3 is the estimation of ATT by quantiles using Changes in Changes Model. 
*/

/*
Subjects: 

We establish a code (sub) for each one of our dependent variables (in order to store this code in our matrix with regression results). 

**Sub 1 -> Proficiency in Portuguese (variable port5).
**Sub 2 -> Proficiency in Math (variable math5).
**Sub 3 -> Standardized Performance in Portuguese and Math (variable sp5). 
**Sub 4 -> Percentage of students with insufficient proficiency in Math (variable math_insuf_5).
**Sub 5 -> Percentage of students with insufficient proficiency in Portuguese (variable port_insuf_5).
*/



*Program to store results -> We run this program after our regressions to store in a matrix the average treatment effect (ATT), and its lower bound and upper bound. 
*Then we create figures presenting these results. 
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	estimates clear
	matrix 	results = (0,0,0,0,0,0)			//matrix to store the model tested (column 1), depende variable (column 2), the ATT (column 3), lower bound (column 4), 
											//upper bound (column 5), and quantile (column 6). This last column is equal to 0 for Models 1 and 2. For model 3 is stores the 
											//quantiles (10, 20, 30....90). 
	*matrix  ri      = (0,0,0)				//matrix to store the model tested (column 1), the dependent variable (column 2) and the p-value calculated by on Randomization Inference. 
	
	cap program drop mat_res
	program define   mat_res
	syntax, model(integer) sub(integer) var(varlist) dep_var(varlist)  //model(number of model tested - 1, 2 or 3 ); sub (code of the dependent variable - 1, 2, 3, 4 and 5);
																	   //var(treatment dummy - T2007 or T2009); dep_var(dependent variable - math5, portuguese5, sp5, port_insuf_5 and math_insuf_5).																   
		*Average treatment effect
		matrix reg_results  = r(table) 	
		local ATT = reg_results[1,1]																					

		*Confidence Interval 
		boottest `var',  reps(1000)  boottype(wild)  seed(1) level(95) 	bootcluster(codmunic) quietly		//Confidence interval using bootstrap
			scalar pvalue 	= r(p)				
			scalar lowerb 	= el(r(CI),1,1)
			scalar upperb 	= el(r(CI),1,2)
			matrix results = results \ (`model', `sub', `ATT', lowerb, upperb, 0)								

		*Mean of the dependent variable and standard deviation
			**Pooled sample
			su 		`dep_var' if year == 2007 & e(sample) == 1 
			scalar 	 media = r(mean)
			scalar   sd    = r(sd)
		
			**Treatment group
			su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 1
			scalar 	 mediaT = r(mean)
			scalar   sdT    = r(sd)

			*Comparison group
			su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 0
			scalar 	 mediaC = r(mean)
			scalar   sdC    = r(sd)
			
			
		*We use estout to export regression results. Besides the coefficients, we export pvalues, confidence interval, mean and standard deviation of the dependent variable.
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar pvalue  = pvalue: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar lowerb  = lowerb: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar upperb  = upperb: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar media   = media: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar sd      = sd: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar mediaT  = mediaT: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar sdT     = sdT: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar mediaC  = mediaC: model`model'`sub'
			if ((`model' == 1 | `model' == 3) & `sub' < 4) | `model' == 2 | `model' == 4 estadd scalar sdC     = sdC: model`model'`sub'
	end
	
			

	
*Regressions
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		foreach subject in sp math math_insuf_ port port_insuf_ { 		//regression for each of our dependent variables 
		 
			if "`subject'" == "port" {
				local sub = 1					//subject = 1, Portuguese
				local title = "Português"		//saving the title for our line graph showing the time trend of treatment and comparison groups
			}
			
			if "`subject'" == "math" {
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
				*Dif in dif
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
				keep if year == 2005 | year == 2007 | year == 2009										
				drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 				//municipalities without 5th grade scores in 2005. Since we can not test parallel trends for these municipalities, we did not consider them in our analaysis
				sort 	codschool year
					
					**********************************
					**YOU NEED STATA 16 to run LASSO**
					**********************************
					*1*
					*Lasso to select controls of model 1
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	   ///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5

					*In case you have stata 16, just delete "*" from the two rows below
					*lasso linear `subject'5 $controls2005 if year <= 2007, rseed(1)						
					*global controls2005  `e(allvars_sel)'
				
					*2*
					*Lasso to select controls of model 2
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
					
					*In case you do not have STATA 16, these are the dependent variables selected:
					global controls2007 mother_edu_5 c.mother_edu_5#c.mother_edu_5 ndropout_5 c.ndropout_5#c.ndropout_5 nrepetition_5 c.nrepetition_5#c.nrepetition_5 		///
					computer_5 c.computer_5#c.computer_5 pib_pcap c.pib_pcap#c.pib_pcap approval5 c.approval5#c.approval5	studentwork_5 c.studentwork_5#c.studentwork_5 	///
					white_5 c.white_5#c.white_5 female_5 c.female_5#c.female_5 privateschool_5 c.privateschool_5#c.privateschool_5 	c.livesmother_5#c.livesmother_5			///
					ComputerLab c.ScienceLab#c.ScienceLab c.Library#c.Library c.InternetAccess#c.InternetAccess classhour5 c.classhour5#c.classhour5 						///
					tclass5 c.tclass5#c.tclass5 c.SIncentive1_5#c.SIncentive1_5 c.SIncentive2_5#c.SIncentive2_5 c.SIncentive3_5#c.SIncentive3_5 SIncentive4_5 SIncentive5_5 ///
					c.SIncentive5_5#c.SIncentive5_5 c.SIncentive6_5#c.SIncentive6_5
					
					*3*
					*Regressions
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					local weight enrollment5		//we weight all regressions by the number of students enrolled in fifth grade 
					
						*2007 versus 2005
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 T2007 		  								 i.treated i.codmunic i.year $controls2005 	if network == 3 & year >= 2005 & year <= 2007  [aw = `weight'], cluster(codmunic)
							if `sub' != 4 & `sub' != 5 eststo model1`sub', title("I")
							mat_res, model(1) sub(`sub') var(T2007)	dep_var(`subject'5)	
							
							/*
							P VALUE WITH RANDOMIZATION INFERENCE
							*ritest treated _b[T2007], seed(1) reps(1000) cluster(codmunic): reg `subject'5 T2007 i.treated i.codmunic i.year $controls2005 if network == 3 year >= 2005 & year <= 2007, cluster(codmunic)
							*matrix ri = ri\[1, `sub', el(r(p),1,1)] 		
							*/
						
						*2009 versus 2005/2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 T2007 T2009 	  							 	 i.treated i.codmunic i.year $controls2005 	if network == 3 & year >= 2005 & year <= 2009  [aw = `weight'], cluster(codmunic)					
						

						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 	    T2009	  								 i.treated i.codmunic i.year $controls2007 	if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
							eststo model2`sub', title("II")  
							mat_res, model(2) sub(`sub') var(T2009) dep_var(`subject'5)	

						/*
						*Changes in changes estimator
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						if "`subject'" == "port" | "`subject'" == "math" {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic continuous `subject'5 treated post_treat $controls2007 i.codmunic if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix reg_results = r(table)
								matrix results = results \ (5, `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile')	 	
							}
						}
						*/
						
						
						*Parallel trends
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						preserve	
						keep if network == 3
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
						graph export "$figures/parallel_trends_dif_in_dif_`subjet'.pdf", as(pdf) replace
						restore
		
							
						*2007 versus 2005
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5  T2007 		treated treated_state_network post_treated_state_network i.codmunic i.year $controls2005 	if tipo_municipio_ef1 == 1 & year >= 2005 & year <= 2007  [aw = `weight'], cluster(codmunic)
							if `sub' != 4 & `sub' != 5 eststo model3`sub', title("I")
							mat_res, model(3) sub(`sub') var(T2007)	dep_var(`subject'5)	
						
						*2009 versus 2005/2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5  T2007 T2009 treated treated_state_network post_treated_state_network i.codmunic i.year $controls2005 	if tipo_municipio_ef1 == 1 &  year >= 2005 & year <= 2009  [aw = `weight'], cluster(codmunic)					

						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject'5 		  T2009 treated treated_state_network post_treated_state_network i.codmunic i.year $controls2007 	if tipo_municipio_ef1 == 1 &  year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
							eststo model4`sub', title("II")  
							mat_res, model(4) sub(`sub') var(T2009) dep_var(`subject'5)	
							/*
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
							*/
		
		}
		
	estout * using "$results/Regressions.csv", delimiter(";") keep(T20*) label cells(b(fmt(3)) se(fmt(3))) stats(N r2 pvalue lowerb upperb media sd mediaT sdT mediaC sdC) mgroups("Math & Portuguese" "Math" "% below adequate level" "Portuguese" "% below adequate level",   pattern(1 0 0 0 1 0 0 0 1 0 1 0 0 0 1 0 )) replace 
 
/*
*Results			
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	clear
	svmat results
	drop  in 1
	rename (results1-results6) (model sub  ATT lower upper quantile)	
	label define sub   1 "Português"  2 "Matemática" 3 "Português e matemática" 4 "Insuficiente em matemática" 5 "Insuficiente em Português"
	label define model  1 "2007 comparado com 2005" 2 "2009 comparado com 2007" 5 "Quantile"
	label val sub sub
	label val model model
	label var ATT    "Average treatment effect"
	label var lower  "Lower bound"
	label var upper  "Upper bound"
	format ATT lower upper %4.2fc
	save "$final/Regression Results.dta", replace

/*
*Charts
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	
	**
	*ATT for Portuguese and Math. Models 1 and 2. Subjects 1 (portuguese) and 2 (math)
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Regression Results.dta", clear
		drop if model == 3 | sub == 3 | sub == 4 | sub == 5 				//keeping only models 1 and 2; subjects 1 and 2. 
		
		gen 	spec1 = model												//spec1 = 1 for portuguese & model 1, spec1 = 2 for portuguese & model 2.
																			//spec1 = 3 for math	   & model 1, spec1 = 4 for math 	   & model 2.
		replace spec1 = 3 if model == 1 & sub == 2
		replace spec1 = 4 if model == 2 & sub == 2
		
			foreach language in portuguese english {						//graphs in portuguese and english

				if "`language'" == "english" {
					local ytitle = "SAEB scale" 
					local legend = "Extended winter break"
					local port   = "Portuguese"
					local math   = "Math"
					local both   = "Portuguese & Math"
					local note   = "Source: Author's estimate." 
				}
				
				if "`language'" == "portuguese" {
					local ytitle = "Escala SAEB" 
					local legend = "Adiamento das aulas"
					local port   = "Português"
					local math   = "Matemática"
					local note   = "Fonte: Estimativa dos autores." 
				}				
			
					twoway    bar ATT spec1 if spec1 == 1, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
						   || bar ATT spec1 if spec1 == 3, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
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
					graph export "$figures/ATT_graph in `language'.pdf", as(pdf) replace
			}		
		
	**	
	*Estimates in standard deviation
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
	keep if year == 2007															//pre-treatment year
	drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 		//municipalities without proficiency data for 2005
	
	foreach var of varlist sp5 math5 port5 {										//standard deviation of standardized performance, and proficiency in portuguese and math 
		su `var', detail
		local sd_`var'  = r(sd)
	}

	matrix standard_deviation =   [3, `sd_sp5' \ 2, `sd_math5' \ 1, `sd_port5']	    //subject and its standard deviation
	clear
	svmat standard_deviation
	rename (standard_deviation1 standard_deviation2) (sub sd)
	tempfile sd
	save `sd' 
	
	use "$final/Regression Results.dta", clear										//merging ATT with standard deviation of the dependent variables
	merge m:1 sub using `sd', nogen
	foreach var of varlist ATT lower upper {
		replace `var' = `var'/sd
	}
	keep if (sub == 1 | sub == 2 | sub == 3) & (model == 1 | model == 2)			//models 1 and 2, dependent variables: sp5, math5 and port5
			
	gen 	spec1 = model
	replace spec1 = 3 if model == 1 & sub == 1
	replace spec1 = 4 if model == 2 & sub == 1	
	replace spec1 = 5 if model == 1 & sub == 2
	replace spec1 = 6 if model == 2 & sub == 2	
	set scheme s1mono
		
		twoway 	   bar ATT spec1 if spec1 == 1, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
				|| bar ATT spec1 if spec1 == 3, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
				|| bar ATT spec1 if spec1 == 5, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 6, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
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
				graph export "$figures/ATT in standard deviation_graph in english.pdf", as(pdf) replace
	
	**
	*Impact on Math/Portuguese by percentile
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Regression Results.dta", clear
		keep if model == 3 //changes in changes estimator
		
		foreach sub in 1 2 {	

				*Title & cor
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if `sub' == 1  local title = "Portuguese"
					if `sub' == 2  local title = "Math"
		
					set scheme economist
					twoway 	scatter ATT quantile if sub == `sub', msymbol(O) msize(medium) color(cranberry) || rcap lower upper quantile if sub == `sub', lcolor(navy)  lwidth(medthick)	///
					yline(0, lp(shortdash) lcolor(gray)) ///
					xtitle("Percentiles of test score distribution", size(small)) xlabel(10(10)90, labsize(small))										  									///
					ytitle("{&gamma}, SAEB scale", size(medsmall)) ylabel(, labsize(small) gmax angle(horizontal) format (%4.1fc))  														///					
					title(, size(large) color(black)) 																																		///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
					legend(order(1 "Extended winter break" 2 "95% CI" ) cols(2) region(lstyle(none) fcolor(none)) size(medsmall)) 	  																									///
					ysize(4) xsize(5)  		///																											
					note("Source: Author's estimate.", color(black) fcolor(background) pos(7) size(small)) 
					graph export "$figures/CIC estimator for `title' skills_graph in english.pdf", as(pdf) replace
			}

	
	**
	*ATT for Portuguese and Math. Models 1 and 2. Subjects 1 (portuguese) and 2 (math)
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Regression Results.dta", clear
		drop if model == 1 | model == 2 | model == 5 | sub == 3 | sub == 4 | sub == 5 				
		
		gen 	spec1 = 1 if model == 3 & sub == 1									
		replace spec1 = 2 if model == 4 & sub == 1									
				
		replace spec1 = 3 if model == 3 & sub == 2
		replace spec1 = 4 if model == 4 & sub == 2
		
			foreach language in portuguese{						//graphs in portuguese and english

				if "`language'" == "english" {
					local ytitle = "SAEB scale" 
					local legend = "Extended winter break"
					local port   = "Portuguese"
					local math   = "Math"
					local both   = "Portuguese & Math"
					local note   = "Source: Author's estimate." 
				}
				
				if "`language'" == "portuguese" {
					local ytitle = "Escala SAEB" 
					local legend = "Adiamento das aulas"
					local port   = "Português"
					local math   = "Matemática"
					local note   = "Fonte: Estimativa dos autores." 
				}				
			
					twoway    bar ATT spec1 if spec1 == 1, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
						   || bar ATT spec1 if spec1 == 3, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
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
					graph export "$figures/ATT_3_dif_graph in `language'.pdf", as(pdf) replace
			}		
					
		
			
			
			
			
			
			
			
			
			
			
			
			
	
*estout q202 q402 q602 q802  q201 q401 q601 q801 using "$results/Quantiles",  style(tex) keep (q20 q40 q60 q80) label starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(fmt(3))) stats(N,  fmt(%5.0fc)  labels("Number of obs"))  mgroups("Math" "Portuguese",  pattern(1 0 0 0 1 0 0 0 )) replace //
