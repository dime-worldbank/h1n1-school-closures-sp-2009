global final   "C:\Users\wb495845\OneDrive - WBG\Desktop"
global inter   "C:\Users\wb495845\OneDrive - WBG\Desktop"
global results "C:\Users\wb495845\OneDrive - WBG\Desktop"
global figures "C:\Users\wb495845\OneDrive - WBG\Desktop"

															*IMPACTS OF SCHOOL SHUTDOWNS ON STUDENT'S LEARNING*
																        *2009, São Paulo/Brazil*
																	
set seed 892823

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

**Model >= 20 -> Triple Dif-in-Dif
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
	matrix 	results 	= (0,0,0,0,0,0,0)		//matrix to store the model tested (column 1), depende variable (column 2), the ATT (column 3), lower bound (column 4), 
	matrix  ri      	= (0,0,0)				//matrix to store the model tested (column 1), the dependent variable (column 2) and the p-value calculated by on Randomization Inference. 
	postfile table2 str10 ATT lowerb upperb pvalue space1 obs r2 space2 media sd space3 mediaT sdT space mediaC sdC using mytable2, replace

	
	
	
	cap program drop mat_res
	program define   mat_res
	syntax, model(integer) sub(integer) var(varlist) dep_var(varlist) grade(integer) //model(number of model tested - 1, 2 or 3 ); sub (code of the dependent variable - 1, 2, 3, 4 and 5);
																	   //var(treatment dummy - T2007 or T2009); dep_var(dependent variable - math5, portuguese5, sp5, port_insuf_5 and math_insuf_5).																   
		*Average treatment effect
		scalar ATT  = el(r(table),1,1)	
		local  obs  = string(e(N)   , "%5.0f")
		local  r2a  = string(e(r2_a), "%5.2fc")
		local  ATTs = string(ATT    , "%5.2fc")
				
		
		*Confidence Interval 
		if `model' >= 20 { //dif in dif models, model > 20 triple dif
			scalar pvalue 	= el(r(table),4,1)	
			scalar lowerb 	= el(r(table),5,1)	
			scalar upperb 	= el(r(table),6,1)	
			matrix results = results \ (`model', `sub', ATT, lowerb, upperb, 0, `grade')			
		}
		else {
			boottest `var',  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Confidence interval using bootstrap
			scalar pvalue 	= r(p)				
			scalar lowerb 	= el(r(CI),1,1)
			scalar upperb 	= el(r(CI),1,2)
			matrix results = results \ (`model', `sub', ATT, lowerb, upperb, 0, `grade')								
		}
		
		local pvalues = string(pvalue, "%10.3fc")
		local lowerbs = string(lowerb, "%10.2fc")
		local upperbs = string(upperb, "%10.2fc")
		
		*Mean of the dependent variable and standard  deviation
			**Pooled sample
			su 		`dep_var' if year == 2007 & e(sample) == 1 
			local 	 media = string(`r(mean)', "%10.2fc")
			local 	 sd    = string(`r(sd)'  , "%10.2fc")

			**Treatment group
			su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 1
			local 	 mediaT = string(`r(mean)', "%10.2fc")
			local 	 sdT    = string(`r(sd)'  , "%10.2fc")

			*Comparison group
			su 		`dep_var' if year == 2007 & e(sample) == 1 & treated == 0
			local 	 mediaC = string(`r(mean)', "%10.2fc")
			local 	 sdC    = string(`r(sd)'  , "%10.2fc")

		if `model' == 1 | `model' == 2 | `model' == 20 {
			post 	 table2	 ("`ATTs'") ("`lowerb'") ("`upperb'") ("0") ("`obs'")  ("`r2a'") ("0") ("`media'") ("`sd'") ("0") ("`mediaT'") ("`sdT'") ("0") ("`mediaC'") ("`sdC'") ("0")\
			

		}
		
	end
	
	
	*postclose summary
	*use mytable2, clear

*Regressions // 
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		foreach subject in sp5 { //math5 port5 math_insuf5 port_insuf5 repetition5 dropout5 sp9 math9 port9 math_insuf9 port_insuf9 repetition9 dropout9 	 //regression for each of our dependent variables 
		 
			if  substr("`subject'", -1,.) == "5" {
				local etapa 1
				local weight enrollment5		//we weight all regressions by the number of students enrolled in fifth grade 
				local grade 5
			}
			
			if  substr("`subject'", -1,.) == "9" {
				local etapa 2
				local weight enrollment9		//we weight all regressions by the number of students enrolled ninth-grade 
				local grade 9
			}					

			if  substr("`subject'", 1,4) == "port" {
				local sub = 1					//subject = 1, Portuguese
				local title = "Português"	
			}
			
			if  substr("`subject'", 1,4) == "math" {
				local sub = 2					//subject = 2, Math
				local title = "Matemática"
			}
			
			if  substr("`subject'", 1,2) == "sp"   {
				local sub = 3					//subject = 3, Standardized score, Portuguese and Math
				local title = "Português e Matemática"
			}
			
			if  substr("`subject'", 1,10) == "math_insuf"  {
				local sub = 4					//subject = 4, % of students below the adequate level in Math
				local title = "% desempenho insuficiente em Matemática"
			}
						
			if  substr("`subject'", 1,10) == "port_insuf"  {
				local sub = 5					//subject = 5, % of students below the adequate level in Portuguese
				local title = "% desempenho insuficiente em Português"
			}
			
			if  substr("`subject'", 1,8) == "approval"     {
				local sub = 6					//subject = 6, approval
				local title = "Approvação"
			}
			
			if  substr("`subject'", 1,10) == "repetition"  {
				local sub = 7					//subject = 7, approval
				local title = "Reprovação"
			}
						
			if  substr("`subject'", 1,7) == "dropout" { //subject = 8, dropout
				local sub = 8	
				local title = "Abandono"
			}
							
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				*Dif in dif
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
				drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 				//municipalities without 5th grade scores in 2005. Since we can not test parallel trends for these municipalities, we did not consider them in our analaysis
				sort 	codschool year
				
					**********************************
					**YOU NEED STATA 16 to run LASSO**
					**********************************
				
					*1*
					*Teacher and principal controls
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global 	teacher_principal c.teacher_tenure`grade'##c.teacher_tenure`grade' c.teacher_more10yearsexp`grade'##c.teacher_more10yearsexp`grade' 	///
						c.teacher_less_40years`grade'##c.teacher_less_40years`grade' 																				///
						c.principal_effort_index`grade'##c.principal_effort_index`grade' c.student_effort_index`grade'##c.student_effort_index`grade' 				///
						c.violence_index`grade'##c.violence_index`grade'  																							///
						c.teacher_white`grade'##c.teacher_white`grade' i.absenteeism_teachers i.teachers_turnover i.principal_selection_work 						///
						i.meetings_school_council 	i.meetings_class_council i.lack_books i.principal_gender i.principal_age_range i.principal_skincolor			///
						i.principal_edu_level	i.org_training i.teachers_training i.criteria_teacher_classrooms i.criteria_classrooms i.support_secretary_edu  	///
						i.support_community	i.training_last2years
					
					*2*
					*Lasso to select controls for models in which year == 2005 or year == 2007. In 2005, we have less control options
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  		///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5

					lasso linear `subject' $controls2005 if year <= 2007, rseed(89018)						
					global controls2005  `e(allvars_sel)'
					

					*3*
					*Lasso to select controls for the remaining models
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if `etapa' == 1 {
						global controls2007 c.mother_edu_highschool5##c.mother_edu_highschool5 c.number_dropouts5##c.number_dropouts5 								///
						c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5																		///
						c.pib_pcap##c.pib_pcap c.approval5##c.approval5  c.work5##c.work5 						   													///
						c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 									///
						c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 															///
						c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour5##c.classhour5 c.tclass5##c.tclass5 									///
						c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5	 				///
						c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5	
						
						lasso linear `subject' $controls2007 if year >= 2007, rseed(22224)		
						global controls2007  `e(allvars_sel)'
					}
					if `etapa' == 2 {
						global controls2007 c.mother_edu_highschool9##c.mother_edu_highschool9 c.number_dropouts9##c.number_dropouts9 								///
						c.number_repetitions9##c.number_repetitions9 c.computer9##c.computer9																		///
						c.pib_pcap##c.pib_pcap c.approval9##c.approval9  c.work9##c.work9 						   													///
						c.white9##c.white9 c.male9##c.male9 c.private_school9##c.private_school9 c.live_mother9##c.live_mother9 									///
						c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 															///
						c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour9##c.classhour9 c.tclass9##c.tclass9 									///
						c.incentive_study9##c.incentive_study9 c.incentive_homework9##c.incentive_homework9 c.incentive_read9##c.incentive_read9	 				///
						c.incentive_school9##c.incentive_school9 c.incentive_talk9##c.incentive_talk9 c.incentive_parents_meeting9##c.incentive_parents_meeting9									
						
						lasso linear `subject' $controls2007 if year >= 2007, rseed(34464)		
						global controls2007  `e(allvars_sel)'
					}
					
					*4*
					*Regressions
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					
						*2007 versus 2005
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						if `etapa' == 1 {
						
							reg `subject' T2007 		  								 i.treated i.codmunic i.year $controls2005 					    	if network == 3 & year >= 2005 & year <= 2007  [aw = `weight'], cluster(codmunic)
							eststo model1`sub'`grade', title("dif_dif_placebo`subject'`grade'")
							mat_res, model(1) sub(`sub') var(T2007)	dep_var(`subject') grade(`grade')
							

						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject' 	    T2009	  								 i.treated i.codmunic i.year $controls2007 							if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
							eststo model2`sub'`grade', title("Dif-in-dif`subject'`grade'")  
							mat_res, model(2) sub(`sub') var(T2009) dep_var(`subject') grade(`grade')
							
							*ritest treated _b[T2009], seed(1) reps(1000) cluster(codmunic): reg `subject' T2009 i.treated i.codmunic i.year $controls2007  if network == 3 & year >= 2007 & year <= 2009, cluster(codmunic)
							*matrix ri = ri\[1, `sub', el(r(p),1,1)] 		
							
							
						*Robustness
						*Comparison group: only municipalities that do not have state schools, since one can argue that in municipalities with state and municipal schools, we can have
						*spilovers if the same teacher works in a municipal and a state schools at the same time. 
						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							reg `subject' 	    T2009	  								 i.treated i.codmunic i.year $controls2007 							if network == 3 & year >= 2007 & year <= 2009 & (treated == 1 | (treated == 0 & tipo_municipio_ef1 == 2))  [aw = `weight'], cluster(codmunic)
							eststo model3`sub'`grade', title("Dif-in-dif`subject'`grade'")  
							mat_res, model(3) sub(`sub') var(T2009) dep_var(`subject') grade(`grade')

						/*
						*Interactions
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						local model = 4
						
						*Students controls
						foreach variable in mother_int class_int principal_int teacher_temure_int enrollment_int teacher_exp_int absenteeism_teachers_int  {
							reg `subject' T2009 T2009_`variable'`grade' `variable'`grade'    i.treated i.codmunic i.year $controls2007 						if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)					
							eststo model`model'`sub'`grade',title("Dif-in-dif`subject'`grade'")  
							mat_res, model(`model') sub(`sub') var(T2009) dep_var(`subject') grade(`grade')
							local model = `model' + 1
							
							reg `subject' T2009 T2009_`variable'`grade' `variable'`grade'  	 i.treated i.codmunic i.year $controls2007 $teacher_principal	if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)					
							eststo model`model'`sub'`grade', title("Dif-in-dif`subject'`grade'")   
							mat_res, model(`model') sub(`sub') var(T2009) dep_var(`subject') grade(`grade')
							local model = `model' + 1
						}
						*/
						
						/*
						*Changes in changes estimator
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						if "`subject'" == "port" | "`subject'" == "math" {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic continuous `subject' treated post_treat $controls2007 i.codmunic 														if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix reg_results = r(table)
								matrix results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile')	 	
							}
						}
						*/
												
						*Parallel trends
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						/*						
						preserve	
							sort codschool year
							replace enrollment5 = enrollment5[_n+1] if year[_n] == 2008 & year[_n+1] == 2009 & codschool[_n] == codschool[_n+1]
							replace enrollment9 = enrollment9[_n+1] if year[_n] == 2008 & year[_n+1] == 2009 & codschool[_n] == codschool[_n+1]
						
							if  substr("`subject'", 1,4) == "port" |  substr("`subject'", 1,4) == "math" {
								reg `subject' 	    T2009	  								 i.treated i.codmunic i.year $controls2007 	if network == 3 & year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
								keep if e(sample)
							}
								
							keep if network == 3
							collapse (mean)`subject' [aw = `weight'], by(year treated)
							format 	 	   `subject' %4.1fc
							save 		   "$inter/trend_`subject'.dta", replace
							
							tw 	///
							(line `subject' year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected) 	 ///  
							ml(`subject') mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) 										 ///
							(line `subject' year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  	 	 ///  
							ml(`subject') mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) 										 ///
							ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%4.0fc))											     ///
							ytitle("Escala SAEB", size(small)) 																					 ///
							title("`title', `grade'{sup:o} ano", pos(12) size(medsmall) color(black))											 ///
							graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
							plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
							legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 						 ///
							ysize(6) xsize(7) 																									 ///
							note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small)))  
							graph export "$figures/parallel_trends_dif_in_dif_`subjet'_`grade'.pdf", as(pdf) replace
							restore
						*/
						}

						*Triple Dif in Dif
						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*							
						if `etapa' == 1 | `etapa' == 2 {
							use "$final/Performance & Socioeconomic Variables of SP schools.dta" if (year == 2007 | year == 2009) & tipo_municipio_ef`etapa' == 1, clear //tipo_municipio_ef1 : municipalities with state and municipal schools offering 1st to 5th grade, tipo_municipio_ef2 : municipalities with state and municipal schools offering 6th to 9th grade
							
							drop T2009
							clonevar T2009 = beta7
							reg `subject' T2009 beta1-beta6 i.codmunic $controls2007 					[aw = `weight'], cluster(codmunic)
							eststo model20`sub'`grade', title("Triple-dif`subject'`grade'")   
							mat_res, model(20) sub(`sub') var(T2009) dep_var(`subject') grade(`grade')	
							
							*reg `subject' T2009 beta1-beta6 i.codmunic $controls2007 $teacher_principal [aw = `weight'], cluster(codmunic)
							*eststo model21`sub'`grade', title("Triple-dif`subject'`grade'")   
							*mat_res, model(21) sub(`sub') var(T2009) dep_var(`subject') grade(`grade')	
							
							/*
							if  "`subject'" == "math5" | "`subject'" ==  "port5" {
								foreach quantile in 10 20 30 40 50 60 70 80 90 { 
									cic continuous `subject' beta4 beta3 beta1 beta2 beta5 beta6 $controls2007 i.codmunic  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(500))
									matrix reg_results = r(table)
									matrix results = results \ (22, `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
								}
							}
							*/
						}
		}
		

		
		*estout  using "$results/Regressions.csv", delimiter(";") keep(T2007 T2009) label cells(b(fmt(3)) se(fmt(2))) stats(N r2_a pvalue lowerb upperb media sd mediaT sdT mediaC sdC) replace
 
/*
*Results			
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	clear
	svmat results
	drop  in 1
	rename (results1-results7) (model sub  ATT lower upper quantile grade)	
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
		keep if model == 7 //changes in changes estimator
		
		foreach sub in 2  {	

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
