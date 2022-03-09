
																*IMPACTS OF SCHOOL SHUTDOWNS ON STUDENT'S LEARNING*
																
																			*2009, São Paulo/Brazil*
	*____________________________________________________________________________________________________________________________________________________________________________________*
	set more off, permanently

	*Important definitions*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	/*
		
		**
		**
		Subjects: 

		We establish a code (sub) for each one of our dependent variables (in order to store this code in our matrix with regression results). 

			**Sub 1 -> Standardized Performance in Portuguese and Math 							(variable sp5). 
			
			**Sub 2 -> Proficiency in Math 														(variable math5).
			
			**Sub 3 -> Proficiency in Portuguese 												(variable port5).
			
			**Sub 4 -> Percentage of students with insufficient proficiency in Math			 	(variable math_insuf_5).
			
			**Sub 5 -> Percentage of students with insufficient proficiency in Portuguese 	 	(variable port_insuf_5).
			
			**Sub 6 -> Approval 																(variable approval5).
			
			**Sub 7 -> Repetition 																(variable repetition_5).
			
			**Sub 8 -> Dropout 																	(variable dropout_5).
		*/

		
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**
	*Program to correct dif in dif and triple dif samples
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	{	
	cap program drop	 correcting_sample				
		program define 	 correcting_sample						
		syntax, year1(integer) year2(integer) model(string)
			/*
			We have the variables: sample_triple_dif and sample_dif. 
			 -> sample_triple_dif. Based on performance data, we only consider municipalities in which there are at least one state and one locally-managed school.
								   We also restric the sample to municipalities in which data is available for 2007 and 2009.
			
			 -> sample dif: only locally-managed schools for which the proficiency score is available since 2005. 
			 
			However, when whe test some models (restricting samples or adding controls), we may have to correct the sample one more time. 
			For ex, restricting the sample to schools in which there are no teachers working in the state and in the locally-managed network.
			We might have in this case, 10 municipalities T = 1 in 2009  but only 8 in T = 1 in 2007.
			*/
			
			
		cap noi drop corrected_sample //when running the program for the second time, we need to drop the variable "corrected_sample" that we created when we run for the 1st time. 
			
			
		*Dif in Dif
		*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			**
			if "`model'" == "dif" {
			
				**
				foreach T in 0 1					{ 
					foreach year in `year1' `year2' {
						preserve
							keep if e(sample) == 1 & year == `year' & T == `T'
							
							duplicates 	 drop codmunic, force
							keep 			  codmunic
								
							tempfile 	 sample`T'`year'
							save 		`sample`T'`year''
						restore
						}
					}
					
				**
				preserve
				
					**
					use 		 `sample1`year1'', clear
					merge  	 	 1:1 codmunic using  `sample1`year2'', nogen keep(3)		//in T = 1, comparing the same municipalities in year1 and year2
					tempfile  	 sample1
					save	    `sample1'
							
					**
					use 		 `sample0`year1'', clear
						merge 	 1:1 codmunic using  `sample0`year2'', nogen keep(3)		//in T = 0, comparing the same municipalities in year1 and year2
						append 	 using `sample1'
						
						keep 	 codmunic 
						gen 	 corrected_sample = 1
						tempfile corrected_sample
						save 	`corrected_sample'
						
				restore
					
				**
				merge 			m:1 codmunic using `corrected_sample', nogen				//corrected_sample = 1 for the dif in dif sample
			} // closing dif
			
			
		*Triple Dif
		*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			
			**
			if "`model'" == "triple" 		{
			
				**
				foreach year in `year1' `year2'	{
					foreach G in 0 1 		{																			
						preserve
							keep 			if e(sample) == 1 & G == `G' & network == 2 & year == `year'
							duplicates 	drop codmunic, force
							tempfile 	 A`G'`year'
							save 		`A`G'`year''
						restore
							
						preserve
							keep 			if e(sample) == 1 & G == `G' & network == 3 & year == `year'
							duplicates 		drop codmunic, force
							merge 			1:1  codmunic using `A`G'`year'', keep(3) nogen		//keeping only the municipalities in G = 0 and G = 1 where 
																								//we have state and locally-managed schools
							tempfile 		 A`G'`year'
							save 	   		`A`G'`year''
						restore
					}
				}
				
				**
				preserve
					
					**
					use 		`A1`year1'', clear
					merge 		1:1 codmunic  using `A1`year2'', nogen keep(3)						//G = 1, same municipalities in 2007 and 2009
					tempfile 	A1
					save 	   `A1'

					**	
					use 		`A0`year1'', clear
							
					merge 		1:1 codmunic using `A0`year2'',  nogen keep(3)						//G = 0, same municipalities in 2007 and 2009
					append 		using   `A1'
					
					keep 		codmunic
					gen 	 	corrected_sample = 1		
					tempfile 	corrected_sample
					save 	   `corrected_sample'
				restore
					
				**
				merge 			m:1 codmunic using `corrected_sample', nogen						//corrected_sample = 1 for the triple dif sample
			}	//closing triple
	end 
	}	
		
		
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**
	*Matrix to store regression's results
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	{
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
	}
	

	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**
	*Vars for models with interactions
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	{	
	global interactions medu spt prin absen atraso
	}

	
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Program to store regression's results and estimate bootstrapped standard errors
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	{	
		cap program drop 	 mat_res
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
					boottest `var1',  reps(1000)  boottype(wild) seed(789087) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have 13 municipalities
																															//that opted to close its schools and more than 600 that did not. (The analysis is at school level). 
					global pvalue 	= r(p)			
					local  lowerb 	= el(r(CI),1,1)
					local  upperb 	= el(r(CI),1,2)
					matrix results  = results \ (`model', `sub', `ATT', `lowerb', `upperb', 0, `grade')
					
				
				if "`var2'" != "novar" {																					//Standard errors using bootstrap for models in which we have the interaction of the treatment 
																															//with other variables, such as students per teacher, principal's effort and teacher abseenteism
					boottest `var2',  reps(1000)  boottype(wild) seed(630100) level(95) bootcluster(codmunic) quietly		
					global pvalue2	= r(p)	
					
					boottest `var3',  reps(1000)  boottype(wild) seed(095764) level(95) bootcluster(codmunic) quietly		
					global pvalue3	= r(p)	
					
				}
			}

				
			**
			**
			*We use estout to export regression results. Besides the coefficients, we export pvalues, confidence interval, mean and standard deviation of the dependent variable
			*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		
			**
			**
			*P values, we need to store the p-values in a matrix because we want the starts(*, ** and ***) to be based on the bootstrapped standard errors.

			*............................................................................................................................................................................*
			**
			**Models without interactions	
			if "`var2'" == "novar" {										//pvalues of the models in which we only have the treatment coeficient + controls. 
																			//we need to save the p values in a separate matrix in order the estout the results taking the 
																			//significance levels according to the bootstrapped p-values. 
				matrix define   pboots    = J(1,3,0)
				matrix colnames pboots    = "`var1'"
				matrix pboots[1,1]        = $pvalue
				estadd matrix pvalueboots = pboots: model`model'`sub'`grade' //the *** of the significant levels will be added according to bootstrapped pvalues. 
			}
			
			*............................................................................................................................................................................*
			**
			**Models with interactions
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
			*Mean of the dependent variable and standard  deviation
			*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				
				if `model' < 20 {											//dif in dif models
				**
				**Pooled sample
				su 		`dep_var' if year == 2007 & e(sample) == 1 
				scalar 	 media   = r(mean)
				scalar   sd      = r(sd)
				scalar   att_sd  = `ATT'/sd

				**
				**Treatment group
				su 		`dep_var' if year == 2007 & e(sample) == 1 & T == 1
				scalar 	 mediaT  = r(mean)
				scalar   sdT     = r(sd)
				scalar 	 att_sdT = `ATT'/sdT
				scalar   att_pcT = `ATT'/media
				
				**
				**Comparison group
				su 	`dep_var' 	  if year == 2007 & e(sample) == 1 & T == 0
				scalar 	 mediaC  = r(mean)
				scalar   sdC     = r(sd)
				scalar 	 att_sdC = `ATT'/sdC
				}
				
				else {														//triple dif models
				
				**
				**Pooled sample
				su 		`dep_var' if year == 2007 & e(sample) == 1 & G == 1
				scalar 	 media   = r(mean)
				scalar   sd      = r(sd)
				scalar   att_sd  = `ATT'/sd
			
			
				**
				**Treatment group
				su 		`dep_var' if year == 2007 & e(sample) == 1 & G == 1 & network == 2
				scalar 	 mediaT  = r(mean)
				scalar   sdT     = r(sd)
				scalar 	 att_sdT = `ATT'/sdT
				scalar   att_pcT = `ATT'/media
				
				**
				**Comparison group
				su 	`dep_var' 	  if year == 2007 & e(sample) == 1 & G == 1 & network == 3
				scalar 	 mediaC  = r(mean)
				scalar   sdC     = r(sd)
				scalar 	 att_sdC = `ATT'/sdC				
				}
				
				
			*............................................................................................................................................................................*
			if `model' != 1  {								//adding dep var statistics, models 1 are the placebos
				*estadd scalar media      = media: 	model`model'`sub'`grade'
				*estadd scalar sd         = sd:		model`model'`sub'`grade'
				*estadd scalar att_sd     = att_sd:	model`model'`sub'`grade'
				estadd scalar mediaT      = mediaT: model`model'`sub'`grade'
				estadd scalar sdT         = sdT: 	model`model'`sub'`grade'
				estadd scalar att_sdT     = att_sdT:model`model'`sub'`grade'
				estadd scalar att_pcT     = att_pcT:model`model'`sub'`grade'
				estadd scalar mediaC      = mediaC: model`model'`sub'`grade'
				estadd scalar sdC         = sdC: 	model`model'`sub'`grade'
				estadd scalar att_sdC     = att_sdC:model`model'`sub'`grade'
			}
			
			
			*............................................................................................................................................................................*
			**
			**
			*Number of clusters (municipalities) and schools in the sample
				
			foreach year in 2007 2009 {
				**
				unique codmunic  if network == 2 & year == `year' & G == 1 & e(sample) == 1		//number of municipalities with state schools in G = 1 
				scalar  			codmunict2g1`year' = r(unique) 
				estadd scalar   	codmunict2g1`year'  = codmunict2g1`year': 	model`model'`sub'`grade'
				
				**
				unique codschool if network == 2 & year == `year' & G == 1 & e(sample) == 1		//number of state-managed schools in G = 1 
				scalar  			codschoolt2g1`year'  = r(unique) 
				estadd scalar   	codschoolt2g1`year'  = codschoolt2g1`year': model`model'`sub'`grade'
				
				**
				unique codmunic  if network == 2 & year == `year' & G == 0 & e(sample) == 1		//number of municipalities with state schools in G = 0 
				scalar  			codmunict2g0`year'  = r(unique) 
				estadd scalar   	codmunict2g0`year'  = codmunict2g0`year': 	model`model'`sub'`grade'		
				
				**
				unique codschool if network == 2 & year == `year' & G == 0 & e(sample) == 1		//number of state-managed schools in G = 0
				scalar  			codschoolt2g0`year'  = r(unique) 
				estadd scalar   	codschoolt2g0`year'  = codschoolt2g0`year': model`model'`sub'`grade'		
				
				**
				unique codmunic  if network == 3 & year == `year' & G == 1 & e(sample) == 1		//number of municipalities with locally-managed schools in G = 1 
				scalar  			codmunict3g1`year'  = r(unique) 
				estadd scalar   	codmunict3g1`year'  = codmunict3g1`year': 	model`model'`sub'`grade'		
				
				**
				unique codschool if network == 3 & year == `year' & G == 1 & e(sample) == 1		//number of locally-managed schools in G = 1 
				scalar  			codschoolt3g1`year'  = r(unique) 
				estadd scalar   	codschoolt3g1`year'  = codschoolt3g1`year': model`model'`sub'`grade'		
				
				**
				unique codmunic  if network == 3 & year == `year' & G == 0 & e(sample) == 1		//number of municipalities with locally-managed schools in G = 0
				scalar  			codmunict3g0`year'  = r(unique) 
				estadd scalar   	codmunict3g0`year'  = codmunict3g0`year': 	model`model'`sub'`grade'		
				
				**
				unique codschool if network == 3 & year == `year' & G == 0 & e(sample) == 1		//number of locally-managed schools in G = 0	
				scalar  			codschoolt3g0`year'  = r(unique) 
				estadd scalar   	codschoolt3g0`year'  = codschoolt3g0`year': model`model'`sub'`grade'		
			}	
			
		end
	}	

	
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Regressions
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*=============================>>YOU NEED STATA 16 FOR LASSO 
	*=============================>>

		*................................................................................................................................................................................*
		*
		**
		**Dataset
		{
			use "$final/h1n1-school-closures-sp-2009.dta", clear	
			
			rename (hw_corrected_port_always5 hw_corrected_math_always5) (hwport5 hwmath5)
			
			gen 	  T2009_hwport5 = T2009*hwport5
			gen 	  T2009_hwmath5 = T2009*hwmath5
			
			label var T2009_hwport5 	"ATT verus \% of teachers that correct Portuguese homework" 
			label var T2009_hwmath5 	"ATT verus \% of teachers that correct Math homework" 
			label var T2007 	"Placebo"
			label var T2009 	"H1N1"
			label var T2008 	"Placebo"
			label var beta7		"H1N1"
			label var beta7P2	"Placebo7"
			tempfile file_reg
			save	`file_reg'
		}
			
		*................................................................................................................................................................................*
		**
		**
		**Outcomes
		foreach subject in sp5  { //regression for each of our dependent variables  //approval5 repetition5 dropout5  math_insuf5 port_insuf5
			  
			*............................................................................................................................................................................*
			**
			*Storing the code
			{
			** 
			if  substr("`subject'", -1,.) == "5" 			{
				local etapa 1
				local weight enrollment5									//we weight all regressions by the number of students enrolled in fifth grade 
				local grade 5
			}
			
			**
			if  substr("`subject'", 1,2)  == "sp"   		{
				local sub = 1												//subject = 1, Standardized score, Portuguese and Math
				local title = "Português e Matemática"
			}	
			
			**
			if  substr("`subject'", 1,4) == "math" 			{
				local sub = 2												//subject = 2, Math
				local title = "Matemática"
			}
			
			**
			if  substr("`subject'", 1,4) == "port" 			{
				local sub = 3												//subject = 3, Portuguese
				local title = "Português"	
			}
			
			**
			if  substr("`subject'", 1,10) == "math_insuf"  	{
				local sub = 4												//subject = 4, % of students below the adequate level in Math
				local title = "% desempenho insuficiente em Matemática"
			}
			
			**
			if  substr("`subject'", 1,10) == "port_insuf"  	{
				local sub = 5 				   								//subject = 5, % of students below the adequate level in Portuguese
				local title = "% desempenho insuficiente em Português"
			}
			
			**
			if  substr("`subject'", 1,8)  == "approval"     {
				local sub = 6												//subject = 6, approval
				local title = "Approvação"
			}
			
			**
			if  substr("`subject'", 1,10) == "repetition"  	{
				local sub = 7												//subject = 7, approval
				local title = "Reprovação"
			}
			
			**
			if  substr("`subject'", 1,7)  == "dropout" 		{
				local sub = 8	 											//subject = 8, dropout
				local title = "Abandono"
			}
			}
		

			*............................................................................................................................................................................*
			**
			*Selecting our control variables
			**	
			use `file_reg', clear	

				**
				**
				*Placebo Model, 2005 versus 2007
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				{
				/*
				In our placebo model we compare 2005 (pre-treatement) and 2007 (fake post-treatment).
				
				We need to restrict the vector of controls variables since there are fewer variables available for 2005
				*/
				
				**
				global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
					   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 
				
				**
				if 	`sub' == 1 | `sub' == 2 | `sub' == 3 { 			//For 2005, we only have data performance scores. 
																	//approval, repetition and dropout are only available starting in 2007. 
					lasso 	linear `subject' $controls2005 i.year i.network if year <= 2007, rseed(628879)						
					global 	controls2005  `e(allvars_sel)'
					
				}
				}
				**
				**
				*Placebo Model, 2007 versus 2008
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				{
				/*
				
				In our placebo model comparing 2007 and 2008 data, we also need to restrict the vector of control variables since in 2008 we do not have socioeconomic variables (we did not have Prova Brasil this year) 
				
				*/
				
				**
				global controls2008 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	  			///
					   c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5 c.hour5##c.hour5 
		
				**
				if `sub' == 6 | `sub' == 7 | `sub' == 8 { //We can only run this placebo model for approval, repetition and dropout. These are the outcomes that we have available in 2007 and 2008 (Prova Brasil data is not available in 2008). 
					lasso 	linear `subject' $controls2008 i.year i.network if year <= 2008, rseed(921588)						
					global 	controls2008  `e(allvars_sel)'
				}
				}
				
				**
				**
				*Controls of our main model: comparing 2007 (pre-treatment data) with 2009. 
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				{
				**
				**
				*Controls including only socioeconomic variables for students
				global controls2007 c.medu5##c.medu5 c.number_dropouts5##c.number_dropouts5 ///
				c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5 ///
				c.pib_pcap##c.pib_pcap c.work5##c.work5   ///
				c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 ///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt ///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.hour5##c.hour5 c.tclass5##c.tclass5 ///
				c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5 ///
				c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5 ///
				c.enrollmentTotal##c.enrollmentTotal

				if `sub' != 5 {
				**
				lasso linear `subject' $controls2007 i.year i.network if year >= 2007, rseed(610171)
				global controls2007  `e(allvars_sel)'
				}
				}
				
				**
				**
				*Controls including socioeconomic variables for students + teachers' and principals' controls (we lose a significant amount of observations)
				{
				global controls_add_2007 c.medu5##c.medu5 c.number_dropouts5##c.number_dropouts5 ///
				c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5 ///
				c.pib_pcap##c.pib_pcap c.work5##c.work5   ///
				c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 ///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt ///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.hour5##c.hour5 c.tclass5##c.tclass5 ///
				c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5 ///
				c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5 ///
				c.enrollmentTotal##c.enrollmentTotal   ///
				c.lack_books##c.lack_books c.quality_books45##c.quality_books45 ///
				c.prin5##c.prin5 c.student_effort_teacherpers5##c.student_effort_teacherpers5 ///
				i.absenteeism_teachers c.classrooms_het_performance##c.classrooms_het_performance c.tenure5##c.tenure5 c.mot5##c.mot5 ///

				**
				if `sub' != 5 {
				lasso linear `subject' $controls_add_2007 i.year i.network if year >= 2007, rseed(812790)
				global controls_add_2007  `e(allvars_sel)'
				}
				}
				
				**
				**
				*Controls including socioeconomic variables for students + teachers' and principals' controls (excluding teacher motivation)
				{
				//only did this because in the model with interaction between treatment and teachers that always correct the homework, we should not have teacher motivation (which is an index based on how frequenly teachers correct the homework). 
				global controls_add2_2007 c.medu5##c.medu5 c.number_dropouts5##c.number_dropouts5 ///
				c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5 ///
				c.pib_pcap##c.pib_pcap c.work5##c.work5   ///
				c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 ///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt ///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.hour5##c.hour5 c.tclass5##c.tclass5 ///
				c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5 ///
				c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5 ///
				c.enrollmentTotal##c.enrollmentTotal   ///
				c.lack_books##c.lack_books c.quality_books45##c.quality_books45 ///
				c.prin5##c.prin5 c.student_effort_teacherpers5##c.student_effort_teacherpers5 ///
				i.absenteeism_teachers c.classrooms_het_performance##c.classrooms_het_performance c.tenure5##c.tenure5 ///

				**
				if `sub' != 5 {
				lasso linear `subject' $controls_add2_2007 i.year i.network if year >= 2007, rseed(812790)
				global controls_add2_2007  `e(allvars_sel)'
				}
				}				
				
				
			*............................................................................................................................................................................*
			**
			*Diference-in-diferences
			/*
			-> Model1 -> Placebo
			-> Model2 -> controls2007
			-> Model3 -> controls2007add
			-> Model4 -> controls2007add + share of teachers working in state and locally-managed networks. To account for spillovers as there are teachers working in state-managed schools in the comparison group
			-> Model5 -> share of teachers that also in a state-managed school that implemented the management intervention
			-> Model6 -> controlsadd2007 + share of teachers working in both networks + share of teachers working in schools that implemented the management intervention
			*/
			
			
			**
			{
			/*
			
				The strategy is to restrict the sample of locally managed schools.
			
					The treatment group  -> schools in the 13 municipalities that opted to extend the winter break.
					
					The comparison group -> schools of the other municipalities in São Paulo that mantained their school calendar.
				
			 */			
				use `file_reg' if network == 3, clear					
							
				**
				**
				keep if sample_dif == 1  										//only municipalities in which we have proficiency data in 2005, so we can check parallel trends
										
				**
				**
				sort 	codschool year
																									 
						
					*........................................>>> 
					**
					**
					*Placebo models. 2007 versus 2005, or 2008 versus 2007.
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 1. 
					
						Robusteness check. In this model, the post-treament year is 2007 and pre-treatment is 2005. 
						
						We set up the treatment dummy (T2007) equal to 1 for the year = 2007, and 0 if year = 2005.
					*/
					{
					
						**
						local model = 1																		
						
						**
						*Proficiency outcomes
						**
						if `sub' != 6 & `sub' != 7 & `sub' != 8 & `sub' != 4 & `sub' != 5 {								//for performance data, our placebo compares 2005 with 2007. 
							**
							reg  	`subject' T2007 		  								 		  i.T i.codmunic i.year $controls2005 	  			 													if (year == 2005 | year == 2007)  							[aw = `weight'], cluster(codmunic)
								
							**
							correcting_sample, year1(2005) year2(2007) model(dif)
							reg  	`subject' T2007 		  								 		  i.T i.codmunic i.year $controls2005 	  			 													if (year == 2005 | year == 2007)  & corrected_sample == 1  	[aw = `weight'], cluster(codmunic)
								
							**
							eststo 		model`model'`sub'`grade', title("Placebo-DiD")
							mat_res, 	model(`model') sub(`sub') var1(T2007) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')								//mat_res calls the program we set up in the beginning of the do file to store the estimates and calculate robust standard errors
						}
						
						**
						*Repetition, dropout and approval rates
						**
						if `sub' == 6 | `sub' == 7 | `sub' == 8 { 								//for approval, repetition and dropout, our placebo compares 2007 with 2008, since these dep vars are available starting in 2007
							**
							reg  	`subject' T2008 		  										  i.T i.codmunic i.year $controls2008 																	if (year == 2007 | year == 2008) 							[aw = `weight'], cluster(codmunic)
								
							**
							correcting_sample, year1(2007) year2(2008) model(dif)		
							reg  	`subject' T2008 		  										  i.T i.codmunic i.year $controls2008 																	if (year == 2007 | year == 2008) 	& corrected_sample == 1 [aw = `weight'], cluster(codmunic)
								
							**
							eststo 		model`model'`sub'`grade', title("Placebo-DiD")
							mat_res, 	model(`model') sub(`sub') var1(T2008) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
						}
						
						if `sub' != 4 & `sub' != 5 {
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						}
						
						**
						local model = `model' + 1
					}
									
					*........................................>>> 
					**
					**
					*2009 versus 2007 -> Students and school controls
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 2.
						DiD with controls of schools and socioeconomic characteristics of students
					*/	
					{
						**
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls2007 																		if (year == 2007 | year == 2009)      						 [aw = `weight'], cluster(codmunic)
							
						**
						correcting_sample, year1(2007) year2(2009) model(dif)
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls2007 																		if (year == 2007 | year == 2009)   & corrected_sample == 1   [aw = `weight'], cluster(codmunic)

						**
						eststo 	 	model`model'`sub'`grade', title("DiD-`model'`sub'") 
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
							
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe

						**	
						local 		model = `model' + 1
					}

					*........................................>>> 
					**
					**
					*Baseline. 2009 versus 2007 -> Additional Controls
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 3.
						DiD with additional controls (principal and teacher controls)
					*/
					{
						**
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls_add_2007																	if (year == 2007 | year == 2009)  							 [aw = `weight'], cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(dif)
						reg 	`subject' 	    T2009	  								 		  i.T i.codmunic i.year $controls_add_2007																	if (year == 2007 | year == 2009)  & corrected_sample == 1    [aw = `weight'], cluster(codmunic)
						
						**	
						eststo 	 	model`model'`sub'`grade', title("DiD-`model'`sub'") 
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar)  dep_var(`subject') grade(`grade')
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**
						local 		model = `model' + 1
					}	
						
					*........................................>>> 
					**
					**
					*Saving Data to check parallel trends
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					{
						preserve //cannot add controls so we keep 2005 observations to set up the parallel trends graph
						reg 	`subject' T2009 i.T i.codmunic i.year if (year == 2005 | year == 2007 | year == 2009)  & corrected_sample == 1    [aw = `weight'], cluster(codmunic)

						codebook codmunic if T == 1
						codebook codmunic if T == 0
						
						keep 		if e(sample)
						collapse 	(mean)	`subject' 							   												 		  		  [aw = `weight'],  by(year T)
						format 	 	   		`subject' %4.1fc
						save   "$inter/time_trend_dif-in-dif_`subject'.dta", replace
						restore
					}

					*........................................>>> 
					**
					**
					*Robustness. 2009 versus 2007 -> Adding the % of teachers working in local and state-managed schools
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 4.
						In the comparison group, we can have spilovers if the same teacher works in a locally and a state-managed school at the same time. 
						This happens because the locally-managed school was opened but all the state-managed schools were closed. 
						In this robustness check we will add the variable share of teachers working in both networks. 
					*/
					{
					
						**
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_both_networks 									if (year == 2007 | year == 2009)     						 [aw = `weight'], cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(dif)
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_both_networks 									if (year == 2007 | year == 2009)  & corrected_sample == 1    [aw = `weight'], cluster(codmunic)
						
						**
						eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar)  dep_var(`subject') grade(`grade')
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**
						local 		model = `model' + 1
						
					}

					*........................................>>> 
					**
					**
					*Robustness. 2009 versus 2007 -> Adding the % of teachers included in the managerial practices intervention
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 5. 
						One can also argue spillovers if a locally-managed school has teachers working for a state-managed school that was included in the Improving Management
						Practices Program implemented by the State Government of Sao Paulo. 
						In this robustness check, we add as control the % of teachers included in the managerial practices intervention
					*/
					{
						**
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_management_program 							 	if (year == 2007 | year == 2009) 						  [aw = `weight'], cluster(codmunic)
					
						**
						correcting_sample, year1(2007) year2(2009) model(dif)
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_management_program 							 	if (year == 2007 | year == 2009) & corrected_sample == 1  [aw = `weight'], cluster(codmunic)
					
						**
						eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar)  dep_var(`subject') grade(`grade')
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "Yes":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**
						local 		model = `model' + 1
					}	

						
					*........................................>>> 
					*
					**
					*Robustness. 2009 versus 2007
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 6.
						Adding share of teachers working in both networks and share teachers management program.
					*/
					{
						**
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_both_networks share_teacher_management_program 	if (year == 2007 | year == 2009) 						  [aw = `weight'], cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(dif)
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_both_networks share_teacher_management_program 	if (year == 2007 | year == 2009)  & corrected_sample == 1 [aw = `weight'], cluster(codmunic)
						
						**
						eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar)  dep_var(`subject') grade(`grade')
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**
						local 		model = `model' + 1
					}	
					
					*........................................>>> 
					*
					**
					*Sample por CIC
					{
						preserve
						reg 	`subject' 	    T2009	  										   i.T i.codmunic i.year $controls_add_2007	 share_teacher_both_networks share_teacher_management_program 	if (year == 2007 | year == 2009)  & corrected_sample == 1 [aw = `weight'], cluster(codmunic)
						keep 		if e(sample) == 1
						keep 		codschool year
						tempfile 	sample_cic
						save 		`sample_cic'
						restore
					}	

					
					*........................................>>> 
					**
					**
					*Treatment with interactions
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					
					Model 7:  DiD, interaction of ATT versus mothers' education
					Model 8:  DiD, interaction of ATT versus students per teacher
					Model 9:  DiD, interaction of ATT versus principal effort
					Model 10: DiD, interaction of ATT versus teacher absenteeism
					Model 11: DiD, interaction of ATT versus % of students older than the correct grade for the series
					Model 12: DiD, interaction of ATT versus % correct degree to teach the subject
					Model 13: DiD, interaction of ATT teachers that always correct the homework. 
					Model 14: DiD, interaction of ATT versus program to reduce dropout
					medu spt prin absen atraso
					*/ 
					{
						if `grade' == 5 & (`sub' == 2 | `sub' == 3) {

							**
							foreach variable in $interactions { //
								
								**
								*Treatment versus student per teacher, principal managerial skills, mother education, abseenteism and age-grade distortion
								**		
								reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'   i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program  	if (year == 2007 | year == 2009) 							[aw = `weight'], cluster(codmunic)
								
								**
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'   i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program  	if (year == 2007 | year == 2009) & corrected_sample == 1	[aw = `weight'], cluster(codmunic)
								
								**
								eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_`variable'`grade') var3(`variable'`grade')  dep_var(`subject') grade(`grade')
								
										
								**
								estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
								estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
								estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
								estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
								estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
								
								**
								local 		model = `model' + 1
							}
								
								**
								*Treatment versus the correct degree to teach the subject
								**
								reg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	    i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program 	if (year == 2007 | year == 2009)  							[aw = `weight'], cluster(codmunic)
								
								**
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	    i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program 	if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'], cluster(codmunic)
								
								**
								eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_adeq`subject') var3(adeq`subject')  dep_var(`subject') grade(`grade')
						
								**
								estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
								estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
								estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
								estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
								estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
								**
								local 		model = `model' + 1
						
								**
								*Treatment versus teachers that always correct the homework. 
								**
								reg 	`subject' T2009 T2009_hw`subject' hw`subject' 	 	   	   i.T i.codmunic i.year $controls_add2_2007 share_teacher_both_networks share_teacher_management_program	 if (year == 2007 | year == 2009)  							[aw = `weight'], cluster(codmunic)
								
								**
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	`subject' T2009 T2009_hw`subject' hw`subject' 	 	   	   i.T i.codmunic i.year $controls_add2_2007 share_teacher_both_networks share_teacher_management_program 	 if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'], cluster(codmunic)
								
								**
								eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_hw`subject') var3(hw`subject')  dep_var(`subject') grade(`grade')
								
								**
								estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
								estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
								estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
								estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
								estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
								
								**
								local 		model = `model' + 1
								
								
								**
								*Treatment versus teachers program to reduce dropout
								**
								reg 	`subject' T2009 T2009_reddrop reddrop	 	   	   i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program	 if (year == 2007 | year == 2009)  							[aw = `weight'], cluster(codmunic)
								
								**
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	`subject' T2009 T2009_reddrop reddrop  	 	   	   i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program 	 if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'], cluster(codmunic)
								
								**
								eststo 		model`model'`sub'`grade', title("DiD-`model'`sub'")   
								mat_res, 	model(`model') sub(`sub') var1(T2009) var2(T2009_reddrop) var3(reddrop)  dep_var(`subject') grade(`grade')
								
								
								**
								estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
								estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
								estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
								estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
								estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
								
								**
								local 		model = `model' + 1			
								
								
								
								
								
								
								
								
								
								
								
								
								
						} //closing grade & sub
					}	
					
					/*
					*........................................>>> 
					**
					**
					*Changes in changes estimator
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/* 
					Model 14: DiD, impact by deciles
					*/
					{
					
					use `file_reg' if network == 3, clear					
						merge 1:1 codschool year using `sample_cic', nogen keep(3)
						if `grade' == 5 & (`sub' == 2 | `sub' == 3) {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								**
								cic 	continuous `subject' T post_treat $controls_add_2007 share_teacher_both_networks share_teacher_management_program  i.codmunic 									if (year == 2007 | year == 2009)  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix 	reg_results = r(table)
								matrix 	results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
							}
						}
					
					}
					*/
			}
			
			*............................................................................................................................................................................*
			**
			*Triple Diference-in-diferences
			**
			/*
			Model 20 -> Baseline, controlsadd2007
			Model 21 -> controlsadd2007 + share of teachers working in both networks
			Model 22 -> controlsadd2007 + share of teachers in management program
			Model 23 -> controlsadd2007 + share of teachers working in both networks + share of teachers in management program
			Model 24 -> model 23 + fe
			*/
			{
			/*
			The advantage of this strategy is to include locally and state-managed schools, and we have the advantage of not having to rely on the parallel trends assumption
			*/
					**
					use `file_reg' 	if (year >= 2005 & year <= 2009) , clear 		   //tipo_municipio_ef1 : municipalities with state and municipal schools offering 1st to 5th grade 
										

					//this variable sample_triple_dif only keeps municipalities in which we have both state and locally-managed schools
					**
					keep 			if sample_triple_dif == 1														   	//sample of triple dif includes municipalities that have state and locally-managed schools considering the exclusions we did 
																														//excluding state schools included in the program to increase managerial practices
																														//we do this because sometimes the municipality has state and locally-managed schools offering 1st to 5th grade 
																														//but once we perform the exclusions above, we only keep the state-managed or the locally-managed. 

					drop 			if school_management_program == 1
					
					**
					local 			model = 20

					
					*........................................>>> 
					**
					**
					*Baseline: 2009 versus 2007
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 20
					*/
					{
					drop 	 T2009
					clonevar T2009 = beta7
						
						**
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007 																if (year == 2007 | year == 2009) 							[aw = `weight'] , cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(triple)
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007 																if (year == 2007 | year == 2009) & corrected_sample == 1 	[aw = `weight'] , cluster(codmunic)
						
						**
						eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")   
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
							
						**
						local 		model = `model' + 1					
					}

					*........................................>>> 
					**
					**
					*Robustness1
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 21 
					*/
					{
						**
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_both_networks  	 							if (year == 2007 | year == 2009) 							[aw = `weight'] , cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(triple)
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_both_networks 								if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'],  cluster(codmunic)
						
						
						**
						eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "No":  model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe

						**	
						local 		model = `model' + 1			
					}	
						
					*........................................>>> 
					**
					**
					*Robustness 3
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 22 
					*/
					{
						**
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program 							if (year == 2007 | year == 2009) 							[aw = `weight'] , cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(triple)
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program    						if (year == 2007 | year == 2009) & corrected_sample == 1 	[aw = `weight'], cluster(codmunic)
						
						**
						eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "No":  model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**	
						local 		model = `model' + 1			
					}		
							
					*........................................>>> 
					**
					**
					*Robustness 4
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 23 
					*/
					{
						**
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks if (year == 2007 | year == 2009) 							[aw = `weight'], cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(triple)
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'],cluster(codmunic)
												
						**
						eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
						
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
						
						**	
						local 		model = `model' + 1			
					}
					
					*........................................>>> 
					**
					**
					*Sample por CIC
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					{
						preserve
						reg 	`subject' T2009 										 beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = `weight'],cluster(codmunic)
						keep 		if e(sample) == 1
						keep 		codschool year
						tempfile 	sample_cic
						save 		`sample_cic'
						restore
					}
							
					*........................................>>> 
					**
					**
					*Robustness 1: 2009 versus 2007
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 24 
					*/
					{
						**
						xtreg 	`subject' T2009 									    beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks	if (year == 2007 | year == 2009),  							fe 	cluster(codmunic)
						
						**
						correcting_sample, year1(2007) year2(2009) model(triple)
						xtreg 	`subject' T2009 									    beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks	if (year == 2007 | year == 2009) & corrected_sample == 1 ,  fe 	cluster(codmunic)
						
							
						**
						eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
						mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							
						**
						estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
						estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
						estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
						estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
						estadd local esp4	   = "Yes": model`model'`sub'`grade'  // school fe
								
						**
						local 		model = `model' + 1	
					}		
	
					*........................................>>> 
					**
					**
					*Treatment with interactions
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 25:  DiD, interaction of ATT versus mothers' education
					Model 26:  DiD, interaction of ATT versus students per teacher
					Model 27:  DiD, interaction of ATT versus principal effort
					Model 28:  DiD, interaction of ATT versus teacher absenteeism
					Model 29:  DiD, interaction of ATT versus % of students older than the correct grade for the series
					Model 30:  DiD, interaction of ATT versus % correct degree to teach the subject
					Model 31:  DiD, interaction of ATT teachers that always correct the homework. 
					Model 32:  DiD, interaction of ATT versus program to reduce dropout
					*/
					{
					**
					if `grade' == 5 & (`sub' == 2 | `sub' == 3) {

						**
						foreach variable in $interactions { //
							**
							xtreg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'  beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009)						, fe	cluster(codmunic)
							
							**
							correcting_sample, year1(2007) year2(2009) model(triple)
							xtreg 	`subject' T2009 T2009_`variable'`grade' `variable'`grade'  beta1-beta6 i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks if (year == 2007 | year == 2009) & corrected_sample == 1 , fe	cluster(codmunic)
							
							**
							eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'") 
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
							
							**
							estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
							estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
							estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
							estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
							estadd local esp4	   = "Yes": model`model'`sub'`grade'  // school fe

							local 		model = `model' + 1
						}

					
							**
							xtreg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	   beta1-beta6 i.codmunic $controls_add_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009)						 	, fe		cluster(codmunic)
							
							
							**
							correcting_sample, year1(2007) year2(2009) model(triple)
							xtreg 	`subject' T2009 T2009_adeq`subject' adeq`subject' 	 	   beta1-beta6 i.codmunic $controls_add_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009) & corrected_sample == 1 , fe		cluster(codmunic)
							
							
							eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
					
							**
							estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
							estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
							estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
							estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
							estadd local esp4	   = "Yes": model`model'`sub'`grade'  // school fe

							**
							local 		model = `model' + 1
						
							**
							xtreg 	`subject' T2009 T2009_hw`subject' hw`subject' 	 	   beta1-beta6 i.codmunic $controls_add2_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009) 							, fe		cluster(codmunic)
							
							**
							correcting_sample, year1(2007) year2(2009) model(triple)
							xtreg 	`subject' T2009 T2009_hw`subject' hw`subject' 	 	   beta1-beta6 i.codmunic $controls_add2_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009) & corrected_sample == 1 	, fe		cluster(codmunic)
							
							
							eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
							
							**
							estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
							estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
							estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
							estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
							estadd local esp4	   = "Yes": model`model'`sub'`grade'  // school fe
					
							**
							local 		model = `model' + 1
							
							
							**
							xtreg 	`subject' T2009 T2009_reddrop reddrop 	 	   beta1-beta6 i.codmunic $controls_add_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009) 							, fe		cluster(codmunic)
							
							**
							correcting_sample, year1(2007) year2(2009) model(triple)
							xtreg 	`subject' T2009 T2009_reddrop reddrop 	 	   beta1-beta6 i.codmunic $controls_add_2007 share_teacher_management_program share_teacher_both_networks  if (year == 2007 | year == 2009) & corrected_sample == 1 	, fe		cluster(codmunic)
							
							
							eststo 		model`model'`sub'`grade', title("Triple-DiD-`model'`sub'")  
							mat_res, 	model(`model') sub(`sub') var1(T2009) var2(novar)  var3(novar) dep_var(`subject') grade(`grade')
							
							**
							estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
							estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
							estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
							estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
							estadd local esp4	   = "Yes": model`model'`sub'`grade'  // school fe
					
							**
							local 		model = `model' + 1							
							
					}
					
					if `sub' != 2 & `sub' != 3 {
						local model = `model' + 7
					}
					}
	
					*........................................>>> 
					**
					*Changes in changes estimator
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					/*
					Model 32
					*/
					{
					
						preserve
						
						merge 1:1 codschool year using `sample_cic', keep(3) 
						
						if `grade' == 5 & (`sub' == 2 | `sub' == 3) {
							foreach quantile in 10 20 30 40 50 60 70 80 90 { 
								cic 	continuous `subject' beta4 beta3 beta1 beta2 beta5 beta6 		i.codmunic $controls_add_2007  share_teacher_management_program share_teacher_both_networks  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
								matrix 	reg_results = r(table)
									matrix results = results \ (`model', `sub', reg_results[1, colsof(reg_results)-2], reg_results[5,colsof(reg_results)-2], reg_results[6,colsof(reg_results)-2], `quantile', `grade')	 	
								}
						}
						
						restore
					
					}
					*/
					**
					local model = `model' + 1
				
									
					*........................................>>> 
					**
					**
					*Triple dif placebo: 2008 versus 2007
					*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					/*
					Model 33: Triple DiD
					
						We run the placebo comparing approval, repetition and dropout rates in 2007 and 2008 (placebo post-treament period).
						
						We could not run the same for portuguese and math because we do no have state schools in Prova Brasil 2005. 
					*/
					{
					**
					if `sub' == 6 | `sub' == 7 | `sub' == 8 {
						drop 	  T2008
						clonevar  T2008 = beta7P2						
							
							
							**
							reg 	`subject' T2008											 beta1P2-beta6P2 i.codmunic $controls2008  share_teacher_management_program share_teacher_both_networks	 if (year == 2007 | year == 2008)  [aw = `weight']  , cluster(codmunic)
							
							**
							correcting_sample, year1(2007) year2(2008) model(triple)
							reg 	`subject' T2008											 beta1P2-beta6P2 i.codmunic $controls2008  share_teacher_management_program share_teacher_both_networks	  if (year == 2007 | year == 2008) & corrected_sample == 1  [aw = `weight'] , cluster(codmunic)
							
							eststo 		model`model'`sub'`grade', title("Triple-DiD-`mode'`sub'") 
							mat_res, 	model(`model') sub(`sub') var1(T2008) var2(novar) var3(novar) dep_var(`subject') grade(`grade')	
							
							
							local		model = `model' + 1
							
							**
							estadd local esp0	   = "Yes": model`model'`sub'`grade'  // municipal fixed effects
							estadd local esp1      = "Yes": model`model'`sub'`grade'  // controls
							estadd local esp2	   = "Yes": model`model'`sub'`grade'  // % teachers in both networks
							estadd local esp3	   = "Yes": model`model'`sub'`grade'  // % teachers management program
							estadd local esp4	   = "No":  model`model'`sub'`grade'  // school fe
					}
					}
				}
		}

		*................................................................................................................................................................................*
		**
		**	
		*Results in DTA
		*................................................................................................................................................................................*
		*................................................................................................................................................................................*
		{
			/*
			clear
			svmat 	results
			drop  	in 1
			rename 	(results1-results7) (model sub  ATT lower upper quantile grade)	
			label 	define sub    1 "Português e matemática"  	2 "Matemática" 					3 "Português" 		4 "Insuficiente em matemática" 		5 "Insuficiente em Português"
			*label 	define model  1 "2007 comparado com 2005" 	2 "2009 comparado com 2007" 	5 "Quantile"
			label 	val sub sub
			*label 	val model model
			label 	var ATT    		"Average treatment effect"
			label 	var lower  		"Lower bound"
			label 	var upper  		"Upper bound"
			format 	ATT lower upper %4.2fc
			save 	"$final/Regression Results.dta", replace
			*/
		}
		
	
		
		*................................................................................................................................................................................*
		*
		**
		**Tables
		*................................................................................................................................................................................*
		*................................................................................................................................................................................*
		
		*---------------------------->>
		*Table 3 -> DiD and triple DiD 
		{
		//Proficiency
		//subs 2 and 3.
		//grade 5
			estout model325 model425 model625 model2025 model2125 model2225 model2325 model2425 ///
				   model335 model435 model635 model2035 model2135 model2235 model2325 model2435 ///
			using "$tables/Table3.xls", keep(T2009*) 		label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2)) ci(par fmt(1))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space mediaT sdT att_sdT space  space esp0 esp1 esp2 esp3 esp4, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " "Treatment Group, 2007" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Specifications" "Municipal FE" "Controls" "Both networks" "% management program" "School FE" )) replace
		
		//++ appending the estimate increase in the percentage of students with insufficient performance
		//subs 4 and 5
		//grade 5 
			estout model345 model445 model645 model2045 model2145 model2245 model2345 model2445 ///
				   model355 model455 model655 model2055 model2155 model2255 model2355 model2455 ///
			using "$tables/Table3.xls", keep(T2009*) 		label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2))) 				starlevels(* 0.10 ** 0.05 *** 0.01) stats(mediaT att_pcT, fmt(%9.2f)) append
		}
		
		
		*---------------------------->>
		*Table 4 -> Interactions - principals, DiD & Triple Dif
		{
			estout model625 model925 model1425   ///
				   model635 model935 model1435   ///
			using "$tables/Table4.xls",keep(T2009*) 		label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2))) 				starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " )) replace
		
			estout model2425 model2725 model3225  ///
				   model2435 model2735 model3235 ///
			using "$tables/Table4.xls",keep(T2009*) 		label cells(b(star  fmt(2)) p(par(`"="("' `")""')  fmt(2))) 											starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " )) append 
		}	
		
		
		*---------------------------->> 
		*Table 5 -> Interactions - Teachers, DiD & Triple Dif
		{
			estout model625 model825 model1025 model1325     ///
				   model635 model835 model1035 model1335     ///
			using "$tables/Table5.xls",keep(T2009*) 		label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2))) 				starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " )) replace
			
			estout  model2425 model2625 model2825  model3125 ///
					model2435 model2635 model2835  model3135 ///
			using "$tables/Table5.xls",keep(T2009*) 		label cells(b(star  fmt(2)) p(par(`"="("' `")""')  fmt(2))) 											starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " )) append 
		 }
		 
		 
		*---------------------------->>
		*Table A.13 -> Placebo
		{		
			estout model125 model325 model625 model2025 model2425 ///
				   model135 model335 model635 model2035 model2425 ///
			using "$tables/TableA13.xls",keep(T2007 T2009*)  label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2))) 				starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space esp0 esp1 esp2 esp3 esp4, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " "Specifications" "Municipal FE" "Controls" "Both networks" "% management program" "School FE" )) replace
		}
		
		
		*---------------------------->>
		*Table A.14 -> Approval, Repetition and Dropout
		{
			estout model3365 model665 model2065 model2465 ///
				   model3375 model675 model2075 model2475 ///
				   model3385 model685 model2085 model2485 ///
		    using "$tables/TableA14.xls",keep(T2008  T2009*) label cells(b(star   fmt(3)) p) 																		starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space mediaT sdT att_sdT space  space esp0 esp1 esp2 esp3 esp4, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " "Treatment Group, 2007" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Specifications" "Municipal FE" "Controls" "Both networks" "% management program" "School FE" )) replace
		}
		
		
		*---------------------------->>
		*Table A.15 -> Effect on standardized performance - we just need this when we calculate the potential impacts of the shutdowns on IDEB
		{
			estout  model315 model415 model615 model2015 model2115 model2215 model2315 model2415 ///  ///
			using "$tables/TableA15.xls", keep(T2009*) 		label cells(b(star pvalue(pvalueboots) fmt(2)) pvalueboots(par(`"="("' `")""')  fmt(2)) ci(par fmt(1))) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2 space space mediaT sdT att_sdT space  space esp0 esp1 esp2 esp3 esp4, fmt(%9.0g %9.1f %9.2f) labels("N. schools" "R2" " " "Treatment Group, 2007" "Mean" "Standard Deviation" "Estimate of ATT (in sd)" " " "Specifications" "Municipal FE" "Controls" "Both networks" "% management program" "School FE" )) replace
		}
		

	/*
	*____________________________________________________________________________________________________________________________________________________________________________________*
	**
	**	
	*Figures
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	{	
		**
		**
		*Impact on Math/Portuguese by percentile
		*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
			use "$final/Regression Results.dta", clear
		
			**
			foreach model in 14 32 {
			
				foreach sub in 2 3  {		
				
						if `model' == 32 & `sub' == 2 local t = "a"
						if `model' == 32 & `sub' == 3 local t = "c"
						if `model' == 14 & `sub' == 2 local t = "b"
						if `model' == 14 & `sub' == 3 local t = "d"

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
						ysize(4) xsize(5)  																											
						graph export "$figures/Figure2`t'.pdf", as(pdf) replace
				}
			}
		}
		
		
		
		
		
	****	
	**Old Pictures
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		/*
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
			
			/*

			*ritest T _b[T2009], seed(1) reps(1000) cluster(codmunic): reg `subject' T2009 i.T i.codmunic i.year $controls2007  if network == 3 & year >= 2007 & year <= 2009, cluster(codmunic)
			*matrix ri = ri\[1, `sub', el(r(p),1,1)] 	
					
					


					
