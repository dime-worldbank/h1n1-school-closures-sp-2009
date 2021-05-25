global final   "C:\Users\wb495845\OneDrive - WBG\Desktop"
global inter   "C:\Users\wb495845\OneDrive - WBG\Desktop"
global results "C:\Users\wb495845\OneDrive - WBG\Desktop"
global figures "C:\Users\wb495845\OneDrive - WBG\Desktop"

															*IMPACTS OF SCHOOL SHUTDOWNS ON STUDENT'S LEARNING*
																        *2009, São Paulo/Brazil*
*____________________________________________________________________________________________________________________________________________________________________________________*


*Important definitions*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	/*
	
	**
	Models: 1, 2 and 3. 

		**Model 1 is the robusteness check. In this model, the post-treament year is 2007 and pre-treatment is 2005. 
		We set up the treatment dummy (T2007) equal to 1 for the year = 2007, and 0 if year = 2005.

		**Model 2 is the estimation of the Average Treatment Effect (T2009). T2009 if equal if year = 2009, and 0 if year = 2007. 

		**Model 3 is equal to model 2, but it restrict the sample of comparison group to municipalities that only have locally-managed schools.

		**Models 4 to 17 are the models in which we interact the treatment with relevant variables, such as students per teacher, principal's effort and teacher abseenteism

		**Model 18 the estimation of ATT by quantiles using Changes in Changes Model. 

		**Model >= 20 -> Triple Dif-in-Dif
	

	**
	Subjects: 

	We establish a code (sub) for each one of our dependent variables (in order to store this code in our matrix with regression results). 

		**Sub 1 -> Standardized Performance in Portuguese and Math (variable sp5). 
		**Sub 2 -> Proficiency in Math 	(variable math5).
		**Sub 3 -> Proficiency in Portuguese (variable port5).
		**Sub 4 -> Percentage of students with insufficient proficiency in Math (variable math_insuf_5).
		**Sub 5 -> Percentage of students with insufficient proficiency in Portuguese (variable port_insuf_5).
		**Sub 6 -> Approval (variable approval5).
		**Sub 7 -> Repetition (variable repetition_5).
		**Sub 8 -> Dropout (variable dropout_5).
	*/

	
	
	
*____________________________________________________________________________________________________________________________________________________________________________________*
**
**
*Matrix to store regression's results
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	estimates clear
	
	**
	**
	*Matrix to store results so you set up our figures. We have figures showing the average treatment effect (ATT), and its lower and upper bounds. 
	matrix 	 results 	= (0,0,0,0,0,0,0)		//matrix to store the model tested (column 1), depende variable (column 2), the ATT (column 3), lower bound (column 4), 
												//upper bound (column 5), and quantile (column 6). This last column is equal to 0 for Models 1 and 2. For model 3, it stores the 
												//quantiles (10, 20, 30....90). 
	**											
	**									
	*Matrix to save RI results									
	*matrix   ri      	= (0,0,0)				//matrix to store the model tested (column 1), the dependent variable (column 2) and the p-value calculated by on Randomization Inference. 


*____________________________________________________________________________________________________________________________________________________________________________________*
**
**	
*Program to store regression's results and estimate bootstrapped standard errors
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	cap program drop mat_res
	program define   mat_res
	syntax, model(integer) sub(integer) var1(string) var2(string) dep_var(varlist) grade(integer) 						//model(number of model tested) 
																														//sub    (code of the dependent variable - 1, 2, 3, 4, 5, 6, 7,8 ) 
																														//var1   (treatment dummy 				 - T2007 or T2009) 
																														//var2   (treatment dummy interacted with a control variable)
																														//dep_var(dependent variable 			 - math, portuguese, sp, port_insuf, math_insuf, approval, repetition, dropout); 
																														//grade  (5 or 9)															   
		
		**
		**
		*ATT
		*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		local  ATT  = el(r(table),1,1)																					//average treatment effect

		**
		**
		*Confidence Interval 
		*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		if `model' >= 20 { 																								//model >= 20 for triple dif models, in these models, since we don't have the problem of a small 
																														//number of clusters, we do not use bootstrapped standard errors
				global pvalue 	= el(r(table),4,1)	
				local  lowerb 	= el(r(table),5,1)	
				local  upperb 	= el(r(table),6,1)	
				matrix results  = results \ (`model', `sub', `ATT', `lowerb', `upperb', 0, `grade')			
		}
		else {
				boottest `var1',  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have a few number of 
																														//clusters (only 13 municipalities) T and around 600 in the control
				global pvalue 	= r(p)			
				local  lowerb 	= el(r(CI),1,1)
				local  upperb 	= el(r(CI),1,2)
				matrix results  = results \ (`model', `sub', `ATT', `lowerb', `upperb', 0, `grade')
			
			if "`var2'" != "novar" {																					//Standard errors using bootstrap for models in which we have the interaction of the treatment 
																														//with other variables, such as students per teacher, principal's effort and teacher abseenteis
				boottest `var2',  reps(1000)  boottype(wild) seed(141563) level(95) bootcluster(codmunic) quietly		
				global pvalue2	= r(p)				
			}
		}

		**
		**
		*Mean of the dependent variable and standard  deviation
		*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			**Pooled sample
			su 		`dep_var' if year == 2007 & e(sample) == 1 
			scalar 	 media   = r(mean)
			scalar   sd      = r(sd)
			scalar   att_sd  = `ATT'/sd
		
			**Treatment group
			su 		`dep_var' if year == 2007 & e(sample) == 1 & T == 1
			scalar 	 mediaT  = r(mean)
			scalar   sdT     = r(sd)
			scalar 	 att_sdT = `ATT'/sdT

			**Comparison group
			su 	`dep_var' 	  if year == 2007 & e(sample) == 1 & T == 0
			scalar 	 mediaC  = r(mean)
			scalar   sdC     = r(sd)
			scalar 	 att_sdC = `ATT'/sdC
			
		**
		**
		*We use estout to export regression results. Besides the coefficients, we export pvalues, confidence interval, mean and standard deviation of the dependent variable
		*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		if "`var2'" == "novar" {						//pvalues of the models in which we only have the treatment coeficient + controls. 
														//we need to save the p values in a separate matrix in order the estout the results taking the 
														//significance levels according to the bootstrapped p-values. 
			matrix define   pboots  = J(1,1,0)
			matrix colnames pboots  = "`var1'"
			matrix pboots[1,1]      = $pvalue
			estadd matrix pvalueboots = pboots: model`model'`sub'`grade' //the *** of the significant levels will be added according to bootstrapped pvalues. 
		}
		
		if "`var2'" !="novar" {							//pvalues of the models in which we only have the treatment coeficient + treatment coefficient versus interaction + controls
			matrix define   pboots  = J(1,2,0)
			matrix colnames pboots  = "`var1' `var2'"
			matrix pboots[1,1]      = $pvalue
			matrix pboots[1,2]      = $pvalue2
			estadd matrix pvalueboots = pboots: model`model'`sub'`grade'
		}		
		
		if `model' != 1 & `model' != 25 {				//adding dep var statistics
			estadd scalar media   = media: 	model`model'`sub'`grade'
			estadd scalar sd      = sd:		model`model'`sub'`grade'
			estadd scalar att_sd  = att_sd:	model`model'`sub'`grade'
			estadd scalar mediaT  = mediaT: model`model'`sub'`grade'
			estadd scalar sdT     = sdT: 	model`model'`sub'`grade'
			estadd scalar att_sdT = att_sdT:model`model'`sub'`grade'
			estadd scalar mediaC  = mediaC: model`model'`sub'`grade'
			estadd scalar sdC     = sdC: 	model`model'`sub'`grade'
			estadd scalar att_sdC = att_sdC:model`model'`sub'`grade'
		}
	end

*____________________________________________________________________________________________________________________________________________________________________________________*
**
**	
*Regressions
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	
	**
	**
	**Models
	foreach subject in sp5 math5 port5 math_insuf5 port_insuf5 approval5 repetition5 dropout5  { // sp9 math9 port9 math_insuf9 port_insuf9 approval9 repetition9 dropout9	 //regression for each of our dependent variables 
		 
		if  substr("`subject'", -1,.) == "5" 			{
			local etapa 1
			local weight enrollment5		//we weight all regressions by the number of students enrolled in fifth grade 
			local grade 5
		}
		if  substr("`subject'", -1,.) == "9" 			{
			local etapa 2
			local weight enrollment9		//we weight all regressions by the number of students enrolled ninth-grade 
			local grade 9
		}	
		if  substr("`subject'", 1,2)  == "sp"   		{
			local sub = 1					//subject = 1, Standardized score, Portuguese and Math
			local title = "Português e Matemática"
		}			
		if  substr("`subject'", 1,4) == "math" 			{
			local sub = 2					//subject = 2, Math
			local title = "Matemática"
		}
		if  substr("`subject'", 1,4) == "port" 			{
			local sub = 3					//subject = 3, Portuguese
			local title = "Português"	
		}
		if  substr("`subject'", 1,10) == "math_insuf"  	{
			local sub = 4					//subject = 4, % of students below the adequate level in Math
			local title = "% desempenho insuficiente em Matemática"
		}
		if  substr("`subject'", 1,10) == "port_insuf"  	{
			local sub = 5 				    //subject = 5, % of students below the adequate level in Portuguese
			local title = "% desempenho insuficiente em Português"
		}
		if  substr("`subject'", 1,8)  == "approval"     {
			local sub = 6					//subject = 6, approval
			local title = "Approvação"
		}
		if  substr("`subject'", 1,10) == "repetition"  	{
			local sub = 7					//subject = 7, approval
			local title = "Reprovação"
		}
		if  substr("`subject'", 1,7)  == "dropout" 		{
			local sub = 8	 				//subject = 8, dropout
			local title = "Abandono"
		}
				
				
		*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		use  "$final/h1n1-school-closures-sp-2009.dta", clear	//YOU NEED STATA 16 FOR LASSO 

			**
			**
			*Teacher and principal controls
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			global 	teacher_principal 																															///
					c.teacher_more10yearsexp`grade'##c.teacher_more10yearsexp`grade' 																			///	
					c.violence_index`grade'##c.violence_index`grade' c.teacher_white`grade'##c.teacher_white`grade' 											///
					i.meetings_school_council i.meetings_class_council i.lack_books i.principal_age_range 														///
					i.principal_edu_level i.org_training i.teachers_training i.criteria_teacher_classrooms i.criteria_classrooms i.support_secretary_edu  		///
					i.support_community	i.training_last2years
					
					*c.student_effort_index`grade'##c.student_effort_index`grade' 																				///

		
			**
			**
			*Placebo Model. In our placebo model comparing 2005 and 2007 data, we need to restrict the vector of controls variables since there are fewer variables available for 2005. 
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
				   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 

			if `sub' == 1 | `sub' == 2 | `sub' == 3 { 			//For 2005, we only have data performance scores. 
																//approval, repetition and dropout are only available starting in 2007. 
				lasso linear `subject' $controls2005 i.year i.network if year <= 2007, rseed(030275)						
				global controls2005  `e(allvars_sel)'
			}
			
			**
			**
			*Placebo Model. In our placebo model comparing 2007 and 2008 data, we also need to restrict the vector of control variables since we do not have socioeconomic variables for this year.
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			global controls2008 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
				   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 c.classhour5##c.classhour5 
	
			if `sub' == 6 | `sub' == 7 | `sub' == 8 { //approval, rrepetition and dropout. Outcomes that we have since 2007
				lasso linear `subject' $controls2008 i.year i.network if year<= 2008, rseed(89018)						
				global controls2008  `e(allvars_sel)'
			}
			
			**
			**
			*Controls of our main model: comparing 2007 (pre-treatment data) with 2009. 
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			if `etapa' == 1 {				//5th grade
				global controls2007 c.mother_edu_highschool5##c.mother_edu_highschool5 c.number_dropouts5##c.number_dropouts5 									///
				c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5																			///
				c.pib_pcap##c.pib_pcap c.work5##c.work5 						   																				///
				c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 										///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 																///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour5##c.classhour5 c.spt5##c.spt5 												///
				c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5	 					///
				c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5	
			
				lasso linear `subject' $controls2007 i.year i.network if year >= 2007, rseed(22224)		
				global controls2007  `e(allvars_sel)'
			}
					
			if `etapa' == 2 {				//9th grade
				global controls2007 c.mother_edu_highschool9##c.mother_edu_highschool9 c.number_dropouts9##c.number_dropouts9 									///
				c.number_repetitions9##c.number_repetitions9 c.computer9##c.computer9																			///
				c.pib_pcap##c.pib_pcap   c.work9##c.work9 						   																				///
				c.white9##c.white9 c.male9##c.male9 c.private_school9##c.private_school9 c.live_mother9##c.live_mother9 										///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 																///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour9##c.classhour9 c.spt_9##c.spt_9 											///
				c.incentive_study9##c.incentive_study9 c.incentive_homework9##c.incentive_homework9 c.incentive_read9##c.incentive_read9	 					///
				c.incentive_school9##c.incentive_school9 c.incentive_talk9##c.incentive_talk9 c.incentive_parents_meeting9##c.incentive_parents_meeting9									
						
				if `sub' != 5 {	 //The model does not converge when sub == 5, so in sub = 5 we use the same controls as sub = 4
					lasso linear `subject' $controls2007 i.year i.network if year >= 2007, rseed(34464)		
					global controls2007  `e(allvars_sel)'
				}
			}
			
			**
			*Diference-in-diferences
			**The strategy is to restrict the sample to locally managed schools. The treatment group  -> schools in the 13 municipalities that opted to extend the winter break.
																			   //The comparison group -> schools of the other municipalities in São Paulo that mantained their school calendar
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			use  "$final/h1n1-school-closures-sp-2009.dta" if network == 3, clear					
			drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 				//municipalities without 5th grade scores in 2005. Since we can not test parallel trends for these municipalities, 
																									//we did not consider them in our analaysis
			sort 	codschool year
			
			if `etapa' == 1 {  																		//we only run the dif-in-dif for 5th graders as not all the 13 municipalities that extended the winter break 
																									//offered 6th to 9th graders. In this case, we would have just a small number of clusters. 
					
				*=============================> 
				*Placebo models. 2007 versus 2005, or 2008 versus 2007.
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				local model = 1
					
				if `sub' != 6 & `sub' != 7 & `sub' != 8 {		//for performance data our placebo compares 2005 with 2007. 
					reg  	`subject' T2007 		  								 		  i.T i.codmunic i.year $controls2005 	    if year == 2005 | year == 2007  [aw = `weight'], cluster(codmunic)
					eststo 		model`model'`sub'`grade', title("dif_dif_placebo`subject'`grade'")
					mat_res, 	model(`model') sub(`sub') var1(T2007) var2(novar) dep_var(`subject') grade(`grade')
				}
				
				if `sub' == 6 | `sub' == 7 | `sub' == 8 { 		//for approval, repetition and dropout, our placebo compares 2007 with 2008
					reg  	`subject' T2008 		  										  i.T i.codmunic i.year $controls2008 		if year == 2007 | year == 2008 [aw = `weight'], cluster(codmunic)
					eststo 		model`model'`sub'`grade', title("dif_dif_placebo`subject'`grade'")
					mat_res, 	model(`model') sub(`sub') var1(T2008) var2(novar) dep_var(`subject') grade(`grade')
					
				}
				local model = `model' + 1
					
				*=============================> 
				*2009 versus 2007
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls2007 		if year == 2007 | year == 2009  [aw = `weight'], cluster(codmunic)
					eststo 	 	model`model'`sub'`grade', title("Dif-in-dif`subject'`grade'") 
					mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) dep_var(`subject') grade(`grade')
					local 		model = `model' + 1

				*=============================> 
				*Robustness. Comparison group: only municipalities that do not have state schools, since one can argue that in municipalities with state and municipal schools, 
											 //we can have spilovers if the same teacher works in a municipal and a state schools at the same time. 
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls2007 		if year == 2007 | year == 2009 & (T == 1 | (T == 0 & tipo_municipio_ef1 == 2))  [aw = `weight'], cluster(codmunic)
					eststo 		model`model'`sub'`grade', title("Dif-in-dif`subject'`grade'")  
					mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  dep_var(`subject') grade(`grade')
					local 		model = `model' + 1
				
				*=============================> 
				*Treatment with interactions
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if `grade' == 5 & (`sub' == 2 | `sub' == 3) {
						foreach variable in spt_intA principal_intA  absenteeism_int { //
							reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'  i.T i.codmunic i.year $controls2007 		if year == 2007 | year == 2009  [aw = `weight'], cluster(codmunic)					
							eststo 		model`model'`sub'`grade',title("Dif-in-dif`subject'`grade'")  
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_`variable'`grade')  dep_var(`subject') grade(`grade')
							local 		model = `model' + 1
						}
					}
				
				/*
				*=============================> 
				*Changes in changes estimator
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if "`subject'" == "port5" | "`subject'" == "math5" {
						foreach quantile in 10 20 30 40 50 60 70 80 90 { 
							cic 	continuous `subject' T post_treat $controls2007 i.codmunic 											if year == 2007 | year == 2009  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
							matrix 	reg_results = r(table)
							matrix 	results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile')	 	
						}
					}
				*/				
						
				*=============================> 
				*Parallel trends
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					preserve	
						sort codschool year						
						reg `subject'  T2009 i.T i.codmunic i.year [aw = `weight'], cluster(codmunic)
						keep if e(sample)
						collapse (mean)`subject' [aw = `weight'], by(year T)
						format 	 	   `subject' %4.1fc
						save 		   "$inter/time_trend_dif-in-dif_`subject'.dta", replace
					restore
			}
			
			**		
			*Triple difference-in-differences
			*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			local model = 20
			
			if `etapa' == 1 | `etapa' == 2 { //triple dif we run for 5th and 9th grades
					
				use "$final/h1n1-school-closures-sp-2009.dta" if (year >= 2005 & year <= 2009) & tipo_municipio_ef`etapa' == 1, clear //tipo_municipio_ef1 : municipalities with state and municipal schools offering 1st to 5th grade 
																																	  //tipo_municipio_ef2 : municipalities with state and municipal schools offering 6th to 9th grade
					
				*=============================> 
				*2009 versus 2007
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					drop 	 T2009
					clonevar T2009 = beta7
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls2007 [aw = `weight'] if year == 2007 | year == 2009, cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("Triple-dif`subject'`grade'")   
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) dep_var(`subject') grade(`grade')	
						local 		model = `model' + 1
				
				*=============================> 
				*Treatment with interactions
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					foreach variable in spt_intA principal_intA  absenteeism_int { //
						reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade' beta1-beta6 i.codmunic $controls2007 [aw = `weight'] if year == 2007 | year == 2009, cluster(codmunic)					
						eststo 		model`model'`sub'`grade', title("Triple-dif`subject'`grade'")   
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  dep_var(`subject') grade(`grade')
						local 		model = `model' + 1
					}

				*=============================> 
				*Changes in changes estimator
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					if  "`subject'" == "math5" | "`subject'" ==  "port5" {
						foreach quantile in 10 20 30 40 50 60 70 80 90 { 
							cic 	continuous `subject' beta4 beta3 beta1 beta2 beta5 beta6 $controls2007 i.codmunic  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(500))
							matrix 	reg_results = r(table)
								matrix results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
							}
					}
					*/
					local model = `model' + 1
				
				*=============================> 
				*Triple dif placebo.   We run the placebo comparing approval, repetition and dropout rates in 2007 and 2008 (placebo post-treament period).
									 //we could not run the same for portuguese and math because we do no have state schools in Prova Brasil 2005. 
				*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				if `sub' == 6 | `sub' == 7 | `sub' == 8 {
					drop 	 T2008
					clonevar T2008 = beta7P2
						reg 	`subject' T2008											 beta1P2-beta6P2 i.codmunic $controls2008 [aw = `weight'] if year == 2007 | year == 2008, cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("Triple-dif`subject'`grade'")   
						mat_res, 	model(`model') sub(`sub') var1(T2008) var2() dep_var(`subject') grade(`grade')	
						local		model = `model' + 1
				}
			}
	}

	**
	**
	**Tables
	//Placebo (model1), dif-in-dif (model2), triple-dif (model 20)
	//subs 1, 2 and 3.
	//grade 5
	estout model115 model215 model2015 model125 model225 model2025 model135 model235 model2035   								using "$results/Table2.csv"  , delimiter(";") keep(T2007  T2009*) 	label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
		
		
	//dif-in-dif, tiple dif
	//subs 4 and 5
	//grade 5
	estout model245 model2045 model255 model2055 			  							 										using "$results/TableA13.csv", delimiter(";") keep( 	  T2009*) 	label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
		
	//Dif in dif, models 2 and 3.
	//subs 1, 2 and 3.
	//grade 5
	estout model215 model315 model225 model325 model235 model335  								  							 	using "$results/TableA14.csv", delimiter(";") keep( 	  T2009*)   label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
		
	//Placebo, placebo triple dif, dif in dif, triple dif.
	//subs 6, 6 and 8
	//grade 5
	estout model165 model2565 model265 model2065 model175 model2575 model275 model2075 model185 model2585 model285 model2085  	using "$results/TableA15.csv", delimiter(";") keep(T2008  T2009*)	label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
	
	//triple dif
	//subs 1, 2 and 3
	//grade 9
	estout  model2019 model2029 model2039   																					using "$results/TableA16.csv", delimiter(";") keep(		  T2009*)   label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
	
	
	/*
	//		
	estout  model2135 model2235 model2335				 					 													using "$results/TableA18.csv", delimiter(";") keep( 	  T2009*)   label cells(b(star 					   fmt(3)) p		  ) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
	
	*Interactions, dif in dif
	estout model225 model425 model525 model625 model235 model435 model535 model635									 		 	using "$results/TableA19.csv", delimiter(";") keep( 	  T2009*)   label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f)) replace
	

	
	
	
	
/*
		
*____________________________________________________________________________________________________________________________________________________________________________________*
**
**	
*Results in DTA
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

*____________________________________________________________________________________________________________________________________________________________________________________*
**
**	
*Figures
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	
	**
	*ATT for Portuguese and Math. Models 1 and 2. Subjects 1 (portuguese) and 2 (math)
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Regression Results.dta", clear
		keep if (model == 1 | model == 2) & (sub == 1 | sub == 1 | sub == 3)
		
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
					

*ritest T _b[T2009], seed(1) reps(1000) cluster(codmunic): reg `subject' T2009 i.T i.codmunic i.year $controls2007  if network == 3 & year >= 2007 & year <= 2009, cluster(codmunic)
*matrix ri = ri\[1, `sub', el(r(p),1,1)] 	
				
