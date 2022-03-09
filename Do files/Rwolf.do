
	*____________________________________________________________________________________________________________________________________________________________________________________*
	set more off, permanently

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

			
			*............................................................................................................................................................................*
			**
			*Selecting our control variables
			**	
			use `file_reg', clear	
				
				**
				**
				*Controls of our main model: comparing 2007 (pre-treatment data) with 2009. 
				*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

				**
				**
				*Controls including socioeconomic variables for students + teachers' and principals' controls (excluding teacher motivation)
				
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
					

					tab codmunic, gen(codmunic1)
					
					
					
					global varlist1 T2009 T2009_prin5    prin5
					global varlist2 T2009 T2009_reddrop  reddrop
					
					gen year2009 = year == 2009
								
								reg 	 math5  T2009 T2009_prin5 prin5   					i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program  	if (year == 2007 | year == 2009) 							[aw = enrollment5], cluster(codmunic)
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	math5 					i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program   T2009 T2009_prin5 prin5    	if (year == 2007 | year == 2009) & corrected_sample == 1	[aw = enrollment5], cluster(codmunic)

								
								reg 	 math5 T2009 T2009_reddrop reddrop	 	   	   		i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program	 if (year == 2007 | year == 2009)  							[aw = enrollment5], cluster(codmunic)
								correcting_sample, year1(2007) year2(2009) model(dif)
								reg 	 math5    	 	   	   	i.T i.codmunic i.year $controls_add_2007 share_teacher_both_networks share_teacher_management_program  T2009 T2009_reddrop reddrop	 if (year == 2007 | year == 2009) & corrected_sample == 1   [aw = enrollment5], cluster(codmunic)
								
							reg   math5    $varlist1		if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = enrollment5], cluster(codmunic)
							reg   math5  	$varlist2       if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = enrollment5], cluster(codmunic)
							
								rwolf2  (reg   math5    $varlist1		if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = enrollment5], cluster(codmunic))	 ///
										(reg   math5  	$varlist2       if (year == 2007 | year == 2009) & corrected_sample == 1  	[aw = enrollment5], cluster(codmunic)),	///
										indepvars($varlist1, $varlist2) cluster(codmunic) seed(456774) reps(10)
							
							
							
											rwolf2 ( areg `rateType' school_treated if grade == 5 , abs(strata) rob )
					   ( areg `rateType' school_treated if grade == 6 , abs(strata) rob )
					   ( areg `rateType' school_treated if grade == 1 , abs(strata) rob )
					   , 	   indepvars(school_treated ,
										 school_treated ,
										 school_treated
										)
							   seed(${mhtSeedsNum}) reps(${repsNum})
							   strata(strata)
				;
							//closing grade & sub

							
							
							
							
							
		
			
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
		


					
