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
													//upper bound (column 5), and quantile (column 6), when we run changes in changes (column stores the quantiles (10, 20, 30....90)), 
													//and grade studied (which in this case is 5th grade. 
													
		**											
		**									
		*Matrix to save RI results									
		*matrix   ri      	= (0,0,0)				//matrix to store the model tested (column 1), the dependent variable (column 2) and the p-value calculated by on Randomization Inference. 


	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**
	*Vars for models with interactions
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		
	global interactions medu mot spt prin absen atraso

	
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Program to store regression's results and estimate bootstrapped standard errors
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		cap program drop mat_res
		program define   mat_res
		syntax, model(integer) sub(integer) var1(string) var2(string) var3(string) dep_var(varlist) grade(integer) 			//model(number of model tested) 
																															//sub    (code of the dependent variable - 1, 2, 3, 4, 5, 6, 7, 8 ) 
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
					boottest `var1',  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have 13 municipalities
																															//that opted to close its schools and more than 600 that did not. (The analysis is at school level). 
					global pvalue 	= r(p)			
					local  lowerb 	= el(r(CI),1,1)
					local  upperb 	= el(r(CI),1,2)
					matrix results  = results \ (`model', `sub', `ATT', `lowerb', `upperb', 0, `grade')
				
				if "`var2'" != "novar" {																					//Standard errors using bootstrap for models in which we have the interaction of the treatment 
																															//with other variables, such as students per teacher, principal's effort and teacher abseenteism
					boottest `var2',  reps(1000)  boottype(wild) seed(141563) level(95) bootcluster(codmunic) quietly		
					global pvalue2	= r(p)	
					
					boottest `var3',  reps(1000)  boottype(wild) seed(938484) level(95) bootcluster(codmunic) quietly		
					global pvalue3	= r(p)	
					
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
		
			**
			**
			*P values
			if "`var2'" == "novar" {							//pvalues of the models in which we only have the treatment coeficient + controls. 
																//we need to save the p values in a separate matrix in order the estout the results taking the 
																//significance levels according to the bootstrapped p-values. 
				matrix define   pboots    = J(1,1,0)
				matrix colnames pboots    = "`var1'"
				matrix pboots[1,1]        = $pvalue
				estadd matrix pvalueboots = pboots: model`model'`sub'`grade' //the *** of the significant levels will be added according to bootstrapped pvalues. 
			}
			
			if "`var2'" !="novar" {											//pvalues of the models in which we only have the treatment coeficient + treatment coefficient versus interaction + controls
				matrix define   pboots    = J(1,3,0)
				matrix colnames pboots    = "`var1' `var2' `var3'"
				matrix pboots[1,1]        = $pvalue
				matrix pboots[1,2]        = $pvalue2
				matrix pboots[1,3]        = $pvalue3
				estadd matrix pvalueboots = pboots: model`model'`sub'`grade'
			}		
			
			**
			**
			*Mean and standart deviation of the dependent variable
			if `model' != 1 & `model' != 30 {								//adding dep var statistics, models 1 and 30 are placebos
				estadd scalar media       = media: 	model`model'`sub'`grade'
				estadd scalar sd          = sd:		model`model'`sub'`grade'
				estadd scalar att_sd      = att_sd:	model`model'`sub'`grade'
				estadd scalar mediaT      = mediaT: model`model'`sub'`grade'
				estadd scalar sdT         = sdT: 	model`model'`sub'`grade'
				estadd scalar att_sdT     = att_sdT:model`model'`sub'`grade'
				estadd scalar mediaC      = mediaC: model`model'`sub'`grade'
				estadd scalar sdC         = sdC: 	model`model'`sub'`grade'
				estadd scalar att_sdC     = att_sdC:model`model'`sub'`grade'
			}
			
			**
			**
			*Number of clusters
				unique codmunic  if network == 2 & year == 2009 & G == 1						//number of municipalities with state schools in G = 1 
				scalar  		codmunict2g1 = r(unique) 
				estadd scalar   codmunict2g1 = codmunict2g1: 	model`model'`sub'`grade'
				
				unique codschool if network == 2 & year == 2009 & G == 1						//number of state-managed schools in G = 1 
				scalar  		codschoolt2g1 = r(unique) 
				estadd scalar   codschoolt2g1 = codschoolt2g1: 	model`model'`sub'`grade'

				unique codmunic  if network == 2 & year == 2009 & G == 0						//number of municipalities with state schools in G = 0 
				scalar  		codmunict2g0 = r(unique) 
				estadd scalar   codmunict2g0 = codmunict2g0: 	model`model'`sub'`grade'		
				
				unique codschool if network == 2 & year == 2009 & G == 0						//number of state-managed schools in G = 0
				scalar  		codschoolt2g0 = r(unique) 
				estadd scalar   codschoolt2g0 = codschoolt2g0: 	model`model'`sub'`grade'		
				
				unique codmunic  if network == 3 & year == 2009 & G == 1						//number of municipalities with locally-managed schools in G = 1 
				scalar  		codmunict3g1 = r(unique) 
				estadd scalar   codmunict3g1 = codmunict3g1: 	model`model'`sub'`grade'		
				
				unique codschool if network == 3 & year == 2009 & G == 1						//number of locally-managed schools in G = 1 
				scalar  		codschoolt3g1 = r(unique) 
				estadd scalar   codschoolt3g1 = codschoolt3g1: 	model`model'`sub'`grade'		

				unique codmunic  if network == 3 & year == 2009 & G == 0						//number of municipalities with locally-managed schools in G = 0
				scalar  		codmunict3g0 = r(unique) 
				estadd scalar   codmunict3g0 = codmunict3g0: 	model`model'`sub'`grade'		
				
				unique codschool if network == 3 & year == 2009 & G == 0						//number of locally-managed schools in G = 0	
				scalar  		codschoolt3g0 = r(unique) 
				estadd scalar   codschoolt3g0 = codschoolt3g0: 	model`model'`sub'`grade'		
				
		end
		
		

	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Regressions
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*=============================>>YOU NEED STATA 16 FOR LASSO 
	*=============================>>

		**
		**
		**Dataset
		
			use "$final/h1n1-school-closures-sp-2009.dta", clear					
			
			label var T2007 	"ATT - 2007 versus 2005"
			label var T2009 	"ATT - 2009 versus 2007"
			label var T2008 	"ATT - 2008 versus 2007"
			label var beta7		"ATT - 2009 versus 2007"
			label var beta7P2	"ATT - 2008 versus 2007"
			tempfile file_reg
			save	`file_reg'

		**
		**
		**Outcomes
		foreach subject in math5 port5 sp5 math_insuf5 port_insuf5 approval5 repetition5 dropout5  { // math5 port5  sp5  math_insuf5 port_insuf5 approval5 repetition5 dropout5	 //regression for each of our dependent variables 
			 
			if  substr("`subject'", -1,.) == "5" 			{
				local etapa 1
				local weight enrollment5									//we weight all regressions by the number of students enrolled in fifth grade 
				local grade 5
			}
			if  substr("`subject'", 1,2)  == "sp"   		{
				local sub = 1												//subject = 1, Standardized score, Portuguese and Math
				local title = "Português e Matemática"
			}			
			if  substr("`subject'", 1,4) == "math" 			{
				local sub = 2												//subject = 2, Math
				local title = "Matemática"
			}
			if  substr("`subject'", 1,4) == "port" 			{
				local sub = 3												//subject = 3, Portuguese
				local title = "Português"	
			}
			if  substr("`subject'", 1,10) == "math_insuf"  	{
				local sub = 4												//subject = 4, % of students below the adequate level in Math
				local title = "% desempenho insuficiente em Matemática"
			}
			if  substr("`subject'", 1,10) == "port_insuf"  	{
				local sub = 5 				   								//subject = 5, % of students below the adequate level in Portuguese
				local title = "% desempenho insuficiente em Português"
			}
			if  substr("`subject'", 1,8)  == "approval"     {
				local sub = 6												//subject = 6, approval
				local title = "Approvação"
			}
			if  substr("`subject'", 1,10) == "repetition"  	{
				local sub = 7												//subject = 7, approval
				local title = "Reprovação"
			}
			if  substr("`subject'", 1,7)  == "dropout" 		{
				local sub = 8	 											//subject = 8, dropout
				local title = "Abandono"
			}
				
	
			*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			use `file_reg', clear	
			
			*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			**
			*Selecting our control variables
			**
			
				**
				**
				*Placebo Model. In our placebo model comparing 2005 (pre-treatement) and 2007 (fake post-treatment), we need to restrict the vector of controls variables since there are fewer variables available for 2005
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
					   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 

				if 	`sub' == 1 | `sub' == 2 | `sub' == 3 { 			//For 2005, we only have data performance scores. 
																	//approval, repetition and dropout are only available starting in 2007. 
					lasso linear `subject' $controls2005 i.year i.network if year <= 2007, rseed(030275)						
					global controls2005  `e(allvars_sel)'
				}
				
				**
				**
				*Placebo Model. In our placebo model comparing 2007 and 2008 data, we also need to restrict the vector of control variables since in 2008 we do not have socioeconomic variables
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				global controls2008 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
					   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 c.hour5##c.hour5 
		
				if `sub' == 6 | `sub' == 7 | `sub' == 8 { //We can only run this placebo model for approval, repetition and dropout. These are the outcomes that we have available in 2007 and 2008 (Prova Brasil data is not available in 2008). 
					lasso linear `subject' $controls2008 i.year i.network if year <= 2008, rseed(89018)						
					global controls2008  `e(allvars_sel)'
				}
				
				**
				**
				*Controls of our main model: comparing 2007 (pre-treatment data) with 2009. 
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					**
					**
					*Controls including only socioeconomic variables for students
					global controls2007 c.medu5##c.medu5 c.number_dropouts5##c.number_dropouts5 																	///
					c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5																			///
					c.pib_pcap##c.pib_pcap c.work5##c.work5 						   																				///
					c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 										///
					c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 																///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.hour5##c.hour5 c.tclass5##c.tclass5 													///
					c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5	 					///
					c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5		///
					c.enrollmentTotal##c.enrollmentTotal 
					lasso linear `subject' $controls2007 i.year i.network if year >= 2007, rseed(22224)		
					global controls2007  `e(allvars_sel)'
				
					**
					**
					*Controls including socioeconomic variables for students + teachers' and principals' controls (we lose a significant amount of observations)
					global controls_add_2007 c.medu5##c.medu5 c.number_dropouts5##c.number_dropouts5 																///
					c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5																			///
					c.pib_pcap##c.pib_pcap c.work5##c.work5 						   																				///
					c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 										///
					c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 																///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.hour5##c.hour5 c.tclass5##c.tclass5 													///
					c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5	 					///
					c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5		///
					c.enrollmentTotal##c.enrollmentTotal  																											///
					c.lack_books##c.lack_books c.quality_books4`grade'##c.quality_books4`grade' 																	///
					c.prin`grade'##c.prin`grade' c.student_effort_index`grade'##c.student_effort_index`grade'	 													///
					i.absenteeism_teachers c.classrooms_het_performance##c.classrooms_het_performance c.tenure5##c.tenure5 c.mot5##c.mot5							///
					
					lasso linear `subject' $controls_add_2007 i.year i.network if year >= 2007, rseed(78374)		
					global controls_add_2007  `e(allvars_sel)'								
				
			*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			**
			**Diference-in-diferences
			**
			**The strategy is to restrict the sample of locally managed schools. The treatment group  -> schools in the 13 municipalities that opted to extend the winter break.
																			   //The comparison group -> schools of the other municipalities in São Paulo that mantained their school calendar
																			   
				use `file_reg' if network == 3, clear					
				drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 				//municipalities without 5th grade scores in 2005. Since we can not test parallel trends for these municipalities, 
																										//we did not consider them in our analaysis
				sort 	codschool year
																									 
						
					*=============================> 
					**
					*Placebo models. 2007 versus 2005, or 2008 versus 2007.
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					
					//model 1, is the robusteness check. In this model, the post-treament year is 2007 and pre-treatment is 2005. 
					//We set up the treatment dummy (T2007) equal to 1 for the year = 2007, and 0 if year = 2005.
					
					local model = 1																		
						
					if `sub' != 6 & `sub' != 7 & `sub' != 8 {		//for performance data, our placebo compares 2005 with 2007. 
						reg  	`subject' T2007 		  								 		  i.T i.codmunic i.year $controls2005 	  			 		if year == 2005 | year == 2007  																										[aw = `weight'], cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("placebo")
						mat_res, 	model(`model') sub(`sub') var1(T2007) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')						//mat_res calls the program we set up in the beginning of the do file to store the estimates and calculate robust standard errors
					}
					
					if `sub' == 6 | `sub' == 7 | `sub' == 8 { 		//for approval, repetition and dropout, our placebo compares 2007 with 2008, since these dep vars are available starting in 2007
						reg  	`subject' T2008 		  										  i.T i.codmunic i.year $controls2008 						if year == 2007 | year == 2008 																											[aw = `weight'], cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("Dif-in-dif")
						mat_res, 	model(`model') sub(`sub') var1(T2008) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
					
					}
					local model = `model' + 1
						
						
					*=============================> 
					**
					*2009 versus 2007 (schools and socioeconomic characteristics of students).
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 2, dif in dif 
					//Estimation of the Average Treatment Effect (T2009). T2009 if equal if year = 2009, and 0 if year = 2007. 
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls2007 						if year == 2007 | year == 2009  																										[aw = `weight'], cluster(codmunic)
						eststo 	 	model`model'`sub'`grade', title("Dif-in-dif") 
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
						local 		model = `model' + 1
						
						
					*=============================> 
					**
					*2009 versus 2007 + additional controls (principal and teacher controls)
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 3, dif-in-dif with additional controls
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls_add_2007					if year == 2007 | year == 2009  																										[aw = `weight'], cluster(codmunic)
						eststo 	 	model`model'`sub'`grade', title("principal") 
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
						local 		model = `model' + 1
						
						
					*=============================> 
					**
					*Robustness. 
					/*
					In the comparison group, we can have spilovers if the same teacher works in a locally and a state-managed school at the same time. 
					This happens because the locally-managed school was opened but all the state-managed schools were closed. 
					In this robustness check we restrict the sample to schools in which the share of teachers that also work in state-managed schools is smaller than 5, 10, 15, 20 and 25% */
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 4, dif in dif, robustness with share of teachers in both networks < 5%
					//model 5, dif in dif, robustness with share of teachers in both networks < 10%
					//model 6, dif in dif, robustness with share of teachers in both networks < 15%
					//model 7, dif in dif, robustness with share of teachers in both networks < 20%
					//model 8, dif in dif, robustness with share of teachers in both networks < 25%
						forvalues share = 5(5)25 {
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls2007 						if (year == 2007 | year == 2009) & ((T == 1) | (T == 0 & share_teacher_both_networks < `share'))   								     	[aw = `weight'], cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("Dif-in-dif")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar)  dep_var(`subject') grade(`grade')
						local 		model = `model' + 1
						}
				
				
					*=============================> 
					**
					*Robustness. 
					/*
					One can also argue spillovers if a locally-managed school has teachers working for a state-managed school that was included in the Improving Management
					Practices Program implemented by the State Government of Sao Paulo. 
					In this robustness check, we restrict the sample to schools where there are no teachers participating in this Management Intervation. */
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 9, robusness
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls2007 						if (year == 2007 | year == 2009) & share_teacher_management_program == 0   																[aw = `weight'], cluster(codmunic)
						eststo 		model`model'`sub'`grade', title("Dif-in-dif")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar)  dep_var(`subject') grade(`grade')
						local 		model = `model' + 1
						
						
					*=============================> 
					**
					*Treatment with interactions
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 10 interaction of ATT versus mothers' education
					//model 11 interaction of ATT versus teacher motivation
					//model 12 interaction of ATT versus students per teacher
					//model 13 interaction of ATT versus principal effort
					//model 14 interaction of ATT versus teacher absenteeism
					//model 15 interaction of ATT versus % of students older than the correct grade for the series
					//model 16 interaction of ATT versus % of teachers with the correct degree to teach portuguese/math for 5th graders
										
						foreach variable in $interactions { //
								reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'   i.T i.codmunic i.year $controls2007 					if (year == 2007 | year == 2009) & ((T == 1) | (T == 0 & share_teacher_both_networks < 25)) &  share_teacher_management_program == 0 	[aw = `weight'], cluster(codmunic)
								eststo 		model`model'`sub'`grade', title("Dif-in-dif")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_`variable'`grade') var3(`variable'`grade')  dep_var(`subject') grade(`grade')
								local 		model = `model' + 1							
						}
						
						if `grade' == 5 & (`sub' == 2 | `sub' == 3) {
								reg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	   i.T i.codmunic i.year $controls2007  					if (year == 2007 | year == 2009) & ((T == 1) | (T == 0 & share_teacher_both_networks < 25)) &  share_teacher_management_program == 0   	[aw = `weight'], cluster(codmunic)
								eststo 		model`model'`sub'`grade', title("Dif-in-dif")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_adeq`subject') var3(adeq`subject')  dep_var(`subject') grade(`grade')
								local 		model = `model' + 1
						}
						
						
					/*	
					*=============================> 
					**
					*Changes in changes estimator
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 17
						if "`subject'" == "port5" | "`subject'" == "math5" {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic 	continuous `subject' T post_treat $controls2007 i.codmunic 														    if (year == 2007 | year == 2009) & share_teacher_management_program == 0  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix 	reg_results = r(table)
								matrix 	results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
							}
						}
					*/		
							
					*=============================> 
					**
					*Saving Data to check parallel trends
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
						preserve	
							sort codschool year						
							reg `subject'  T2009 i.T i.codmunic i.year [aw = `weight'], cluster(codmunic)
							keep if e(sample)
							collapse (mean)`subject' [aw = `weight'], by(year T)
							format 	 	   `subject' %4.1fc
							save 		   "$inter/time_trend_dif-in-dif_`subject'.dta", replace
						restore
				
			
			*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			**
			**Triple diference-in-diferences
			**
			**The advantage of this strategy is to include locally and state-managed schools
			
				local model = 20
									
					use `file_reg' if (year >= 2005 & year <= 2009) & tipo_municipio_ef`etapa' == 1, clear 		   //tipo_municipio_ef1 : municipalities with state and municipal schools offering 1st to 5th grade 
					
					drop 		if school_management_program == 1												   //excluding state schools included in the program to increase managerial practices
					
					replace share_teacher_management_program =  0 if year == 2007						  		   //In 2009, the Management Program of the state-managed network had not yet been implemented.
						
					*=============================> 
					**
					*2009 versus 2007, + additional controls (principal and teacher controls) + school fixed effects
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
						drop 	 T2009
						clonevar T2009 = beta7
						
						//model 20, triple dif, no restriction in the % of teachers working in a state and a locally-managed school
						//model 21, triple dif, share of teachers in both networks < 10%
						//model 22, triple dif, share of teachers in both networks < 15%
						//model 23, triple dif, share of teachers in both networks < 20%
						//model 24, triple dif, share of teachers in both networks < 25% 
						//model 25, triple dif, share of teachers in both networks < 25% 

							reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  [aw = `weight'] if (year == 2007 | year == 2009) & 																   share_teacher_management_program == 0, cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Triple-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							local 		model = `model' + 1					

						forvalues share = 5(5)25 {
							reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  [aw = `weight'] if (year == 2007 | year == 2009) & ((G == 1 & share_teacher_both_networks < `share') | (G == 0)) & share_teacher_management_program == 0, cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Triple-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							local 		model = `model' + 1					
						}
							
					*=============================> 
					**
					*2009 versus 2007, + additional controls (principal and teacher controls) , schools fixed effects
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 26
							xtreg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  				if (year == 2007 | year == 2009) & ((G == 1 & share_teacher_both_networks < 25) 	 | (G == 0)) & share_teacher_management_program == 0,  fe cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Triple-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							local 		model = `model' + 1	
													
				
					*=============================> 
					**
					*Treatment with interactions
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 27 interaction of ATT versus mothers' education
					//model 28 interaction of ATT versus teacher motivation
					//model 29 interaction of ATT versus students per teacher
					//model 30 interaction of ATT versus principal effort
					//model 31 interaction of ATT versus teacher absenteeism
					//model 32 interaction of ATT versus % of students older than the correct grade for the series
					//model 33 interaction of ATT versus % of teachers with the correct degree to teach portuguese/math for 5th graders
					
					foreach variable in $interactions { //
							reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'  beta1-beta6 i.codmunic $controls_add_2007 [aw = `weight'] if (year == 2007 | year == 2009) & ((G == 1 & share_teacher_both_networks < 25)		| (G == 0)) & share_teacher_management_program == 0, cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Triple-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
							local 		model = `model' + 1
					}
					
					if `grade' == 5 & (`sub' == 2 | `sub' == 3) {
							 reg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	   beta1-beta6 i.codmunic $controls_add_2007 [aw = `weight'] if (year == 2007 | year == 2009) & ((G == 1 & share_teacher_both_networks < 25)		| (G == 0)) & share_teacher_management_program == 0, cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Dif-in-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
							local 		model = `model' + 1
					}
					
					

					*=============================> 
					**
					*Changes in changes estimator
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 34
					/*
						preserve
						keep if ((G == 1 & share_teacher_both_networks < 25) | (G == 0)) & share_teacher_management_program == 0
						if  "`subject'" == "math5" | "`subject'" ==  "port5" {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic 	continuous `subject' beta4 beta3 beta1 beta2 beta5 beta6 $controls_add_2007 i.codmunic  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(500))
								matrix 	reg_results = r(table)
									matrix results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
								}
						}
						restore
					*/	
						
						local model = `model' + 1
				
									
					*=============================> 
					**
					*Triple dif placebo.   We run the placebo comparing approval, repetition and dropout rates in 2007 and 2008 (placebo post-treament period).
										 //we could not run the same for portuguese and math because we do no have state schools in Prova Brasil 2005. 
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					//model 35
					if `sub' == 6 | `sub' == 7 | `sub' == 8 {
						drop 	  T2008
						clonevar  T2008 = beta7P2
						label var T2008 "ATT, 2008 versus 2007"
							reg 	`subject' T2008											 beta1P2-beta6P2 i.codmunic $controls2008  	  [aw = `weight']  if (year == 2007 | year == 2008) & ((G == 1 & share_teacher_both_networks < 10) 		| (G == 0)) & share_teacher_management_program == 0, cluster(codmunic)
							eststo 		model`model'`sub'`grade', title("Triple-dif")   
							mat_res, 	model(`model') sub(`sub') var1(T2008) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							local		model = `model' + 1
					}
					
		}
		
		**
		**
		**Tables
		
		//Placebo (model1), dif-in-dif (model2), dif-in-dif robustness(model9) triple-dif (model 25)
		//subs 1, 2 and 3.
		//grade 5
		estout model115 model215 model915 model2515 model125 model225 model925 model2525 model135 model235 model935  model2535   							using "$results/Table2.csv"    , delimiter(";") keep(T2007  T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace

		
		//dif-in-dif (model 2), + testing models with different % of teachers who work in both state and locally-managed schools
		estout model225 model325 model425 model525 model625 model725 model825 model925  																	using "$results/TableA14.csv"  , delimiter(";") keep(		T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace

		
		//dif-in-dif (model 2), + testing models with different % of teachers who work in both state and locally-managed schools
		estout model235 model335 model435 model535 model635 model735 model835 model935 																		using "$results/TableA15.csv"  , delimiter(";") keep(		T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace
		
		
		//models 20, 21, 22, 23, 24, 25, 26
		estout model2025 model2125 model2225 model2325 model2425 model2525 model2625 model2035 model2135 model2235 model2335 model2435 model2535 model2635	using "$results/TableA16.csv"  , delimiter(";") keep(		T2009*) label cells(b(star   fmt(3)) p) 							starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace
		
		
		//Interactions, dif in dif, model 9 and models 10, 11, 12
		estout model925 model1025 model1225 model1225 model1325 model1425 model1525  ///
			   model935 model1035 model1235 model1235 model1335 model1435 model1535 																		using "$results/TableA17.csv"  , delimiter(";") keep(  		T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace
		
		
		//dif-in-dif models 2, 8, 9, 24 and 25
		//subs 4 and 5
		//grade 5
		estout model245 model845 model945 model2545 model2645 model255 model855 model955 model2555 model2655			 									using "$results/TableA18.csv"  , delimiter(";") keep(  		T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media space space mediaT space space mediaC									, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" " " "Treatment Group" "Mean" " " "Comparison Group" "Mean")) replace

			
		//Placebo (model1), placebo triple dif (model 30), dif in dif (model 2)
		//subs 6, 7 and 8
		//grade 5
		estout model3565 model965 model2565 model2665 model3575 model975 model2575 model2675 model3585 model965 model2585 model2685 						using "$results/TableA19.csv"  , delimiter(";") keep(T2008  T2009*) label cells(b(star pvalue(pvalueboots) fmt(3)) pvalueboots) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace

		
		//Interations, triple-dif
		estout model2525 model2625 model2725 model2825 model2925 model3025 model3125 model3225	///
			   model2535 model2635 model2735 model2835 model2935 model3035 model3135 model3235 																using "$results/TableA20.csv"  , delimiter(";") keep( 		T2009*) label cells(b(star   fmt(3)) p) 							starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space media sd att_sd space space mediaT sdT att_sdT space space mediaC sdC att_sdC, fmt(%9.0g %9.3f %9.2f) labels("Obs" "R2" " " "Pooled Sample" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Treatment Group" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Comparison Group" "Mean" "Standard Deviation" "Estimate of ATT(in sd)")) replace

		
		
		
	/*
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Results in DTA
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		clear
		svmat 	results
		drop  	in 1
		rename 	(results1-results7) (model sub  ATT lower upper quantile grade)	
		label 	define sub    1 "Português e matemática"  	2 "Matemática" 					3 "Português" 		4 "Insuficiente em matemática" 		5 "Insuficiente em Português"
		label 	define model  1 "2007 comparado com 2005" 	2 "2009 comparado com 2007" 	5 "Quantile"
		label 	val sub sub
		label 	val model model
		label 	var ATT    		"Average treatment effect"
		label 	var lower  		"Lower bound"
		label 	var upper  		"Upper bound"
		format 	ATT lower upper %4.2fc
		save 	"$final/Regression Results.dta", replace

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
			
			**
			**
			keep if (model == 1 | model == 2) & (sub == 2 | sub == 3)
			
			**
			**
			gen 	spec1 = model												//spec1 = 1 for portuguese & model 1, spec1 = 2 for portuguese & model 2.
																				//spec1 = 3 for math	   & model 1, spec1 = 4 for math 	   & model 2.
			replace spec1 = 3 if model == 1 & sub == 3
			replace spec1 = 4 if model == 2 & sub == 3
			
			
			**
			**
				foreach language in english {						//graphs in portuguese and english

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
						legend(order(1 "Placebo" 2 "`legend'" 3 "95% CI" ) span cols(3) region(lstyle(none) fcolor(none)) size(small))  																///
						text(3.5 1.5 "`math'") 																																							///
						text(3.5 3.5 "`port'" ) 																																						///
						ysize(4) xsize(4)  ///
						note("`note'", color(black) fcolor(background) pos(7) size(small)) 
						*graph export "$figures/ATT-graph-in-`language'.pdf", as(pdf) replace
						graph export "$figures/ATT_port&math.pdf", as(pdf) replace
				}		
		
		**
		**	
		*Estimates in standard deviation
		*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			use 	"$final/h1n1-school-closures-sp-2009.dta", clear
			keep 	if year == 2007															//pre-treatment year
			drop 	if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 		//municipalities without proficiency data for 2005
			
			
			**
			*Storing standard deviation 
			foreach 	  var of varlist sp5 math5 port5 {									//standard deviation of standardized performance, and proficiency in portuguese and math 
				su 		 `var', detail
				local sd_`var'  = r(sd)
			}

			matrix 	standard_deviation =   [1, `sd_sp5' \ 2, `sd_math5' \ 3, `sd_port5']    //subject and its standard deviation
			clear
			svmat 	standard_deviation
			rename (standard_deviation1 standard_deviation2) (sub sd)
			tempfile sd
			save    `sd' 
			
			
			**
			*Merging estimated with standard deviation
			use 	"$final/Regression Results.dta", clear									//merging ATT with standard deviation of the dependent variables
			merge 	m:1 sub using `sd', nogen
			foreach 	 var of varlist ATT lower upper {
				replace `var' = `var'/sd
			}
			
			**
			**
			keep if (sub == 1 | sub == 2 | sub == 3) & (model == 1 | model == 2)			//models 1 and 2, dependent variables: sp5, math5 and port5
			
			
			**
			**
			gen 	spec1 = model
			replace spec1 = 3 if model == 1 & sub == 2
			replace spec1 = 4 if model == 2 & sub == 2	
			replace spec1 = 5 if model == 1 & sub == 3
			replace spec1 = 6 if model == 2 & sub == 3	
			
			set 	scheme s1mono
				
				twoway 	   bar ATT spec1 if spec1 == 1, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
						|| bar ATT spec1 if spec1 == 3, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
						|| bar ATT spec1 if spec1 == 5, ml(ATT) barw(0.4) color(cranberry) || bar ATT spec1 if spec1 == 6, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	lwidth(thick) ///
						yline(0, lpattern(shortdash) lcolor(cranberry)) 																																///
						xline(2.5, lpattern(shortdash) lcolor(navy)) 																																	///
						xline(4.5, lpattern(shortdash) lcolor(navy)) 																																	///
						xtitle("", size(medsmall)) 											  																											///
						ytitle("{&gamma}, in standard deviation", size(small)) ylabel(-0.4(0.1)0.2, labsize(small) gmax angle(horizontal) format (%4.1fc))  											///					
						xlabel(1 `" "2007" "versus 2005" "' 2 `" "2009" "versus 2007" "' 3 `" "2007" "versus 2005" "' 4 `" "2009" "versus 2007" "' 5 `" "2007" "versus 2005" "' 6 `" "2009" "versus 2007" "', labsize(small) ) 									///
						title(, size(medsmall) color(black)) 																																			///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																		///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																				///						
						legend(order(1 "Robustness" 2 "Extended winter break" 3 "95% CI" ) cols(3) region(lstyle(none) fcolor(none)) size(medsmall))  													///
						text(0.2 1.6 "Portuguese & Math") 																																				///
						text(0.2 3.5 "Math") 																																							///
						text(0.2 5.5 "Portuguese" ) 																																					///
						ysize(4) xsize(6)  ///
						note("", color(black) fcolor(background) pos(7) size(small)) 
						graph export "$figures/ATT-port&math-standard-deviation.pdf", as(pdf) replace
		
		**
		**
		*Impact on Math/Portuguese by percentile
		*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			use "$final/Regression Results.dta", clear
		
			**
			foreach model in 14 30 {
			
			if `model' == 14 local modelo = "DiD"
			if `model' == 30 local modelo = "Triple-DiD"
			
				foreach sub in 2 3  {	

						if `sub' == 3  local title = "Portuguese"
						if `sub' == 2  local title = "Math"
						if `sub' == 2  local min = -10
						if `sub' == 3  local min = -8
			
						set scheme economist
						twoway 	scatter ATT quantile if sub == `sub' & model == `model', msymbol(O) msize(medium) color(cranberry) || rcap lower upper quantile if sub == `sub' & model == `model', lcolor(navy)  lwidth(medthick)	///
						yline(0, lp(shortdash) lcolor(gray)) ///
						xtitle("Percentiles of test score distribution", size(small)) xlabel(10(10)90, labsize(small))										  									///
						ytitle("{&gamma}, SAEB scale", size(medsmall)) ylabel(`min'(2)2, labsize(small) gmax angle(horizontal) format (%4.1fc))  												///					
						title(, size(large) color(black)) 																																		///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																		///						
						legend(order(1 "Extended winter break" 2 "95% CI" ) cols(2) region(lstyle(none) fcolor(none)) size(medsmall)) 	  														///
						ysize(4) xsize(5)  		///																											
						note("Source: Author's estimate.", color(black) fcolor(background) pos(7) size(small)) 
						graph export "$figures/CIC-`title'-`modelo'.pdf", as(pdf) replace
				}
			}

			
			/*

			*ritest T _b[T2009], seed(1) reps(1000) cluster(codmunic): reg `subject' T2009 i.T i.codmunic i.year $controls2007  if network == 3 & year >= 2007 & year <= 2009, cluster(codmunic)
			*matrix ri = ri\[1, `sub', el(r(p),1,1)] 	
					
					


					
