
	*________________________________________________________________________________________________________________________________* 
	**
	**SCHOOL DATASET	
	**
	*________________________________________________________________________________________________________________________________* 

	**
	*Socioeconomic characteristics of the students at school level																													
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	   "$inter/Students - Prova Brasil.dta" if (network == 2 | network == 3) & (year == 2007 | year == 2009), clear
		foreach v of var * {
		local l`v' : variable label `v'
			if `"`l`v''"' == "" {
			local l`v' "`v'"
			}
		}
		collapse   (mean) $socioeco_variables  number_dropouts number_repetitions, by(grade year codschool)
		foreach v of var * {
			label var `v' "`l`v''"
		}
		
		foreach var of varlist $socioeco_variables {
			replace `var' = `var'*100 
			format  `var' %4.2fc
		} 
		format 		incentive* number* %4.2fc
		
		foreach v  of varlist  incentive_study-number_repetitions {
			local l`v'5 : variable label `v'
			local l`v'9 : variable label `v'

		}
		reshape 	wide $socioeco_variables  number_dropouts number_repetitions, i(codschool year) j(grade)
		
		foreach v of varlist  incentive_study5-number_repetitions9 {
			if substr("`v'", -1, .) == "5" {
			local new = 1
			}
			if substr("`v'", -1, .) == "9" {
			local new = 2
			}
			local z = substr("`v'", 1,length("`v'")-1)
			if `new' == 1 label var `v' "`l`z'5', 5th grade - %" 
			if `new' == 2 label var `v' "`l`z'9', 9th grade - %" 
		}
		tempfile    socio_economic
		save       `socio_economic'
		

	**
	*Flow Indicators																												
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	   "$inter/Flow Indicators.dta", clear
		keep *5grade* *9grade* codschool year
		tempfile    flow_index
		save       `flow_index'
	

	**
	*School Infrastructure																											
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	   	$matching_schools year codschool coduf uf codmunic codmunic2 operation network cfim_letivo cinicio_letivo  location ///
		mes_fim_letivo dia_fim_letivo CICLOS using "$inter/School Infrastructure.dta"  if (network == 3 | network == 2), clear
		tempfile    school_infra
		save       `school_infra'
	
	
	**
	*Enrollments																										
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 		year codschool enrollmentEMtotal enrollmentEFtotal enrollment5grade network enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentEI  ///
		using "$inter/Enrollments"  if (network == 3 | network == 2)  & !missing(codschool), clear
		egen enrollmentTotal = rowtotal(enrollmentEMtotal enrollmentEFtotal enrollmentEI)
		foreach var of varlist enrollment* {
			replace `var' = . if `var' == 0
		}
		tempfile    enrollments
		save       `enrollments'	
	
	
	**
	*Class hours																								
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 		classhour5grade classhour9grade  year codschool network using "$inter/Class-Hours.dta" 			if network == 2 | network == 3, clear
		tempfile    class_hours
		save       `class_hours'	
	
	
	**
	*Students per class																							
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	    tclass5grade tclass9grade 		 year codschool network using "$inter/Class-Size.dta" 			if network == 2 | network == 3, clear
		tempfile    class_size
		save       `class_size'	
	
		
	**
	*Students per teacher																					
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	    spt_5grade spt_9grade 	  		 year codschool network	using "$inter/Students per teacher.dta" if network == 2 | network == 3, clear
		tempfile    students_teacher
		save       `students_teacher'	
		
	
	**
	*IDEB																						
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 		"$inter/IDEB by school.dta" if (year == 2005 | year == 2007 | year == 2009) & (network == 2 | network == 3), clear
		rename 		(spEF1 spEF2) (sp5 sp9)
		drop 		flowindexEF* target* approval*
		tempfile    ideb
		save       `ideb'
		
		
	**
	*List of schools included in Prova Brasil																					
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		duplicates drop codschool, force
		keep 	 codschool
		tempfile data
		save 	`data'
	
	
	**
	*Teachers																				
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use  "$inter/Teachers - Prova Brasil.dta" 	if (network == 2 | network == 3) & (year == 2007 | year == 2009), replace
		foreach v of var * {
		local l`v' : variable label `v'
			if `"`l`v''"' == "" {
			local l`v' "`v'"
			}
		}
		collapse 		 (mean)$teachers, 	by (codschool year grade)
		foreach v of var * {
			label var `v' "`l`v''"
		}
		foreach v  of varlist grade-quality_books4 {
			local l`v'5 : variable label `v'
			local l`v'9 : variable label `v'

		}
		
		foreach var of varlist teacher_more10yearsexp-teacher_less3min_wages almost_all_finish_grade9-quality_books4 {
			replace `var' = `var'*100
		}
		
		reshape wide $teachers, 		   				i(codschool year) j(grade)

		foreach v of varlist teacher_more10yearsexp5-quality_books49 {
			if substr("`v'", -1, .) == "5" {
			local new = 1
			}
			if substr("`v'", -1, .) == "9" {
			local new = 2
			}
			local z = substr("`v'", 1,length("`v'")-1)
			if `new' == 1 label var `v' "`l`z'5', 5th grade - %" 
			if `new' == 2 label var `v' "`l`z'9', 9th grade %" 
		}
		
		format teacher_more10yearsexp5-quality_books49 %4.2fc
		tempfile teachers
		save	`teachers'

		
	**
	*Principals																				
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use  "$inter/Principals - Prova Brasil.dta" if (network == 2 | network == 3) & (year == 2007 | year == 2009), clear
		keep codschool year $principals
		tempfile principals
		save	`principals'

		
	**
	*==============>> Merging all data
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	`school_infra'	, clear
		merge   1:1 codschool year using `flow_index'				, nogen
		merge   1:1 codschool year using `enrollments'	 			, nogen keepusing(enrollment5grade enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentTotal)
		merge   1:1 codschool year using `class_hours'	 			, nogen keepusing(classhour5grade classhour9grade)
		merge   1:1 codschool year using `class_size'	 			, nogen keepusing(tclass5grade tclass9grade)
		merge   1:1 codschool year using `students_teacher'	 		, nogen keepusing(spt_5grade spt_9grade)
		merge 	1:1 codschool year using `ideb'						, nogen
		merge 	1:1 codschool year using `socio_economic'			, nogen 
		merge 	1:1 codschool year using `teachers'					, nogen 
		merge 	1:1 codschool year using `principals'				, nogen 
		merge   m:1 codmunic  year using "$inter/GDP per capita.dta", nogen keep(1 3) keepusing(pib_pcap pop porte)
		merge 	m:1 codschool 	   using `data'						, nogen keep(3) //para manter somente as escolas que estao na base da Prova Brasil
		sort 	codschool year 
		xtset   codschool year  

	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Adjusting the name of the variables
	*-------------------------------------------------------------------------------------------------------------------------------*
		foreach var of varlist *grade {
			local newname  = substr("`var'",1, length("`var'") - 5)
			rename `var'  `newname'
		}
	
	*-------------------------------------------------------------------------------------------------------------------------------*
		drop school
		replace n_munic = n_munic[_n-1] if codmunic[_n] == codmunic[_n-1] & n_munic[_n] == "" & n_munic[_n-1] != ""
		replace n_munic = n_munic[_n+1] if codmunic[_n] == codmunic[_n+1] & n_munic[_n] == "" & n_munic[_n+1] != ""
		order year-codmunic2 n_munic location codschool-CICLOS

	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Labels
	*-------------------------------------------------------------------------------------------------------------------------------*
		label var codschool								"INEP Code of the school"
		label var year 									"Year"
		label var network 								"2 if state-managed. 3 if locally managed"
		label var location								"1 if urban. 0 if rural "
		label var coduf 								"Code of the state"
		label var uf 									"Brazilian state"
		label var codmunic								"Code of the municipality"
		label var codmunic2 							"Code of the municipality-6 digits"
		label var pop 									"Population of the municipality"
		label var n_munic								"Name of the municipality"
		label var operation 							"1 escolas em atividade em t, 2 escolas fora de atividade, 3 escolas extintas e 4 escolas extintas no ano anterior"
		label var cinicio_letivo 						"Início do ano letivo"
		label var cfim_letivo 							"Fim do ano letivo"
		label var dia_fim_letivo 						"Dia em que terminou o ano letivo"
		label var mes_fim_letivo						"Mês em que terminou o ano letivo"
		label var math5									"Proficiency in Math [SAEB scale 0 to 350] " 
		label var port5									"Proficiency in Portuguese [SAEB scale 0 to 325]" 
		label var sp5									"Performance in Math and Portuguese [0 to 10]" 
		label var repetition5 							"Repetition rate" 
		label var dropout5 								"Dropout rate" 
		label var approval5								"Approval rate" 
		label var repetition9 							"Repetition rate" 
		label var dropout9 								"Dropout rate" 
		label var approval9								"Approval rate" 
		label var ComputerLab 							"% of schools with computer lab"
		label var ScienceLab 							"% of schools with science lab"
		label var Library 								"% of schools with library"
		label var InternetAccess 						"% of schools internet access"
		label var SportCourt 							"% of schools sport court"
		label var enrollment5 							"Enrollments 5th grade"
		label var enrollment9 							"Enrollments 9th grade"
		label var classhour5 							"Class hours 5th grade"
		label var tclass5 								"Students per class 5th grade"
		label var classhour9 							"Class hours per day 9th grade"
		label var tclass9								"Students per class 9th grade"
		label var pop									"Population of the municipality, in thousands"
		label var pib_pcap								"GDP per capita of the municipality, in 2019 BRL"
		label var spt_5									"Students per teacher"
		label var spt_9									"Students per teacher"
		foreach x in 5 9 {
		label var math`x'        						"Math, `x'th grade"
		label var port`x' 		 						"Portuguese, `x'grade"
		label var sp`x'									"Standardized Performance, `x'grade"
		}
		foreach x in EF1 EF2 {
		label var ideb`x'   	  	 					"IDEB `x'"
		label var enrollment`x'							"Enrollments `x'"
		}
		label var porte									"Size of the municipality"
		label var CICLOS								"Schools with automatic approval" 
		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Treatment and Comparison Groups
	*-------------------------------------------------------------------------------------------------------------------------------*
		gen T   				= .										//1 for closed schools, 0 otherwise
		gen G	  				= 1										//0 for the 13 municipalities that extended the winter break, 1 otherwise
		gen E 					= network == 2
		gen id_13_mun 			= 0										//1 for the 13 municipalities that extended the winter break, 0 otherwise
		foreach munic in $treated_municipalities {
			replace T   		= 1 		if codmunic == `munic' & network == 3
			replace id_13_mun 	= 1 		if codmunic == `munic'
			replace G	  	  	= 0 		if codmunic == `munic'
		}		
		replace T    			= 1 		if network == 2
		replace T    			= 0 		if T == .
		gen 	post_treat 		= (year >  2007)
		gen 	T2007 	   		=  year == 2007  & T == 1
		gen 	T2008	   		=  year == 2008  & T == 1
		gen 	T2009 	   		=  year == 2009  & T == 1
		label var T 			"Schools that extended the winter break"
		label var G				"School in municipality that didnt extend the winter break of their local schools" 
		label var id_13_mun		"School in municipality that extend the winter break of their local schools" 
		label var E				"State-managed schools"
		label var post_treat	"Pos-treatment"
		label var T2007			"1 for treated schools in 2007"
		label var T2008			"1 for treated schools in 2008"
		label var T2009			"1 for treated schools in 2009"
		
		
		label define id_13_mun 0 "Locally-managed schools without winter break extended" 1 "Locally-managed schools with winter break extended" 
		label define G		   1 "Locally-managed schools without winter break extended" 0 "Locally-managed schools with winter break extended" 
		label val id_13_mun id_13_mun
		label val G         G
	
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Type of municipalities
	*-------------------------------------------------------------------------------------------------------------------------------*
		gen 	A = 1 if network == 2 & (!missing(approval5) | math5 != .)
		bys 	year codmunic: egen mun_escolas_estaduais_ef1  = max(A)			//municipalities with state schools offering 1st to 5th grade
		drop 	A	
		
		gen 	A = 1 if network == 2 & (!missing(approval9) | math9 != .)
		bys 	year codmunic: egen mun_escolas_estaduais_ef2  = max(A)			//municipalities with state schools offering 6th to 9th grade
		drop 	A
		
		gen 	A = 1 if network == 3 & (!missing(approval5) | math5 != .)
		bys 	year codmunic: egen mun_escolas_municipais_ef1 = max(A)			//municipalities with municipal schools offering 1st to 5th grade
		drop 	A
		
		gen 	A = 1 if network == 3 & (!missing(approval9) | math9 != .)
		bys 	year codmunic: egen mun_escolas_municipais_ef2 = max(A)			//municipalities with municipal schools offering 6th to 9th grade
		drop 	A	
		
		gen 	tipo_municipio_ef1 = 1 if mun_escolas_estaduais_ef1 == 1 & mun_escolas_municipais_ef1 == 1
		replace tipo_municipio_ef1 = 2 if mun_escolas_estaduais_ef1 == . & mun_escolas_municipais_ef1 == 1
		replace tipo_municipio_ef1 = 3 if mun_escolas_estaduais_ef1 == 1 & mun_escolas_municipais_ef1 == .
		replace tipo_municipio_ef1 = 4 if mun_escolas_estaduais_ef1 == . & mun_escolas_municipais_ef1 == .	
		gen 	tipo_municipio_ef2 = 1 if mun_escolas_estaduais_ef2 == 1 & mun_escolas_municipais_ef2 == 1
		replace tipo_municipio_ef2 = 2 if mun_escolas_estaduais_ef2 == . & mun_escolas_municipais_ef2 == 1
		replace tipo_municipio_ef2 = 3 if mun_escolas_estaduais_ef2 == 1 & mun_escolas_municipais_ef2 == .
		replace tipo_municipio_ef2 = 4 if mun_escolas_estaduais_ef2 == . & mun_escolas_municipais_ef2 == .
				
		gen 	offers_ef1 = !missing(math5) | approval5 != .
		gen 	offers_ef2 = !missing(math9) | approval5 != .
		gen 	offers_ef1_ef2 = offers_ef1 == 1 & offers_ef2 == 1
		
		label 	define 	tipo_municipio_ef1 		1 "State and locally-managed schools offering 1st to 5th grade"					 	 	2  "No state-managed schools but locally-managed schools offering 1st to 5th grade" ///
												3 "State-managed schools but no locally-managed schools offering 1st to 5th grade"  	4  "Without schools offering 1st to 5th grade" 
		label 	define 	tipo_municipio_ef2 		1 "State and locally-managed schools offering 6th to 9th grade"					 		2  "No state-managed schools but locally-managed schools offering 6th to 9th grade" ///
												3 "State-managed schools but no locally-managed schools offering 6th to 9th grade"  	4  "Without schools offering 6th to 9th grade" 
		label 	val 	tipo_municipio_ef2 		tipo_municipio_ef2
		label 	val 	tipo_municipio_ef1 		tipo_municipio_ef1
		
		label 	var mun_escolas_estaduais_ef1	"Municipality with state schools offering 1st to 5th grades"
		label 	var mun_escolas_estaduais_ef2	"Municipality with state schools offering 6th to 9th grades"
		label 	var mun_escolas_municipais_ef1	"Municipality with locally-managed schools offering 1st to 5th grades"
		label 	var mun_escolas_municipais_ef2	"Municipality with locally-managedschools offering 6th to 9th grades"
		label 	var tipo_municipio_ef1			"Type of municipality that offers 1st to 5h grades"
		label 	var tipo_municipio_ef2			"Type of municipality that offers 6th to 9h grades"
		label 	var offers_ef1					"School offers 1st to 5th grade"
		label 	var offers_ef2					"School offers 6th to 9th grade"
		label 	var offers_ef1_ef2				"School offers 1st to 9th grade"
	
		sort codschool year
		foreach var of varlist tipo_municipio* offers* {
			replace `var' = `var'[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codschool[_n] == codschool[_n+1]		//We do not have data of performance or approval rates in 2005 at school level
			
		}
		/*
		**We are selecting all municipal schools offering EF1 and EF2 in 2005. These schools will have the variable school_2005_ef1_ef2 = 1. 
		**with this, we can compare the same cohort of students. in 2005 = their performance in 5th grade; in 2009 their performance in 9th grade. 
		gen 	T = 1 if year == 2005 & network == 3 & offers_ef1_ef2 == 1 
		bys 	codschool: egen school_2005_ef1_ef2 = max(T)
		drop T
		foreach variable in {
			gen 	`variable' = `variable'5 if year == 2005
			replace `variable' = `variable'9 if year == 2009
		}
		*/

		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Population
	*-------------------------------------------------------------------------------------------------------------------------------*
		gen 	pop_2007 = pop if year == 2007
		bys 	codmunic: egen max = max(pop_2007)
		drop 	pop_2007
		rename  max pop_2007
		label 	var pop_2007 "Population of the municipality the school is located at"
	
	
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Students with basic or adequate performance 
	*-------------------------------------------------------------------------------------------------------------------------------*
		foreach grade in 5 9 {
			egen port_basic_more_`grade' = rowtotal(port_basic`grade' port_adequ`grade'), missing
			egen math_basic_more_`grade' = rowtotal(math_basic`grade' math_adequ`grade'), missing
		}
		label var port_basic_more_5		"Basic or adequate performance in Portuguese, 5th grade - %" 
		label var math_basic_more_5		"Basic or adequate performance in Mathm, 5th grade - %" 
		label var port_basic_more_9		"Basic or adequate performance in Portuguese, 9th grade - %" 
		label var math_basic_more_9		"Basic or adequate performance in Portuguese, 9th grade - %" 
		
		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Deciles of performance
	*-------------------------------------------------------------------------------------------------------------------------------*
		*bys year: quantiles math5, gen(q_math5) stable nq(9)
		*bys year: quantiles port5, gen(q_port5) stable nq(9)

	
	*-------------------------------------------------------------------------------------------------------------------------------*
		sort 	codschool year 
		format  pop %20.0fc	
	
	
	*-------------------------------------------------------------------------------------------------------------------------------*	
	**
	*Triple dif in dif
	*-------------------------------------------------------------------------------------------------------------------------------*	
		gen D 		 = (year == 2009)
		gen beta1    = E
		gen beta2    = G
		gen beta3    = D
		gen beta4    = E*G
		gen beta5    = E*D
		gen beta6  	 = G*D
		gen beta7    = E*G*D 				//triple dif coefficient
		
		gen DP1 	 = (year == 2007)		//coeficientes beta para triple dif placebo
		gen beta1P1  = E
		gen beta2P1  = G
		gen beta3P1  = DP1
		gen beta4P1  = E*G
		gen beta5P1  = E*DP1
		gen beta6P1  = G*DP1
		gen beta7P1  = E*G*DP1  			//triple dif coefficient	
		
		gen DP2 	 = (year == 2008)		//coeficientes beta para triple dif placebo
		gen beta1P2  = E
		gen beta2P2  = G
		gen beta3P2  = DP2
		gen beta4P2  = E*G
		gen beta5P2  = E*DP2
		gen beta6P2  = G*DP2
		gen beta7P2  = E*G*DP2  			//triple dif coefficient
		
		label var D   "2009"
		label var DP1 "2007"
		label var DP2 "2008"
		
		foreach var of varlist beta1* {
		label var `var' "State-managed schools"
		}
		foreach var of varlist beta2* {
		label var `var' "Municipalities that did not extend the winter-break of their locally-managed schools"
		}
		foreach var of varlist beta3* {
		label var `var' "Post-treatment year"
		}	
		foreach var of varlist beta4* {
		label var `var' "State-managed schools interacted with G = 1"
		}	
		foreach var of varlist beta5* {
		label var `var' "State-managed schools interacted with post-treatment year" 
		}	
		foreach var of varlist beta6* {
		label var `var' "Post-treatment interacted with G = 1" 
		}	
		foreach var of varlist beta7* {
		label var `var' "Triple difference in differences"
		}	
		
		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Interactions
	*-------------------------------------------------------------------------------------------------------------------------------*	
		sort codschool year
		
		**
		*Treatment status versus students per teacher, principal effort and teacher tenure
		foreach variable in spt_ principal_effort_index teacher_tenure  { 				//students per teacher, principal_effort_index teacher_tenure 
			if "`variable'" == "principal_effort_index"		local name = "principal_int"
			if "`variable'" == "teacher_tenure" 			local name = "tenure_int"
			if "`variable'" == "spt_"						local name = "spt_int"
			
			foreach grade in 5 9 {
				gen 	`name'`grade'    = 0					if 												 !missing(`variable'`grade')
					
				su 		`variable'`grade' 	  		  			if year == 2009, detail
				replace `name'`grade' 	 = 1					if year == 2009  & `variable'`grade' >= r(p50) & !missing(`variable'`grade')	
					
				replace `name'`grade'    = `name'`grade'[_n+1] 	if codschool[_n] == codschool[_n+1] & year[_n] == 2007 & year[_n+1] == 2009
				
					
				gen 	T2009_`name'`grade'   = T2009*`name'`grade'				//interaction with 1 or 0 
				gen 	T2009_`name'A`grade'  = T2009*`variable'`grade'			//interaction with the value assumed by the variable
				gen 	`name'A`grade'		  =`variable'`grade'
				format  `name'A`grade' %12.2fc
			}
		}

		**
		*Treatment status versus teacher absenteeism
		sort 	codschool year
		gen  	absenteeism_int5   = 			  absenteeism_teachers == 2 & year == 2009			//teacher abseemteism is a big issue
		gen  	absenteeism_int9   = 			  absenteeism_teachers == 2 & year == 2009	 
		replace absenteeism_int5   = . if missing(absenteeism_teachers)		& year == 2009	
		replace absenteeism_int9   = . if missing(absenteeism_teachers)		& year == 2009	 
		
		replace absenteeism_int5   = absenteeism_int5[_n+1] if codschool[_n] == codschool[_n+1] & year[_n] == 2007 & year[_n+1] == 2009
		replace absenteeism_int9   = absenteeism_int9[_n+1] if codschool[_n] == codschool[_n+1] & year[_n] == 2007 & year[_n+1] == 2009
		
		gen 	T2009_absenteeism_int5 = T2009*absenteeism_int5
		gen 	T2009_absenteeism_int9 = T2009*absenteeism_int9
		
		**
		*Labels
		label var T2009_spt_int5  		 "2009 interated with schools where students per teacher > median" 
		label var T2009_spt_intA5 		 "2009 interated with students per teacher" 
		label var spt_int5		  		 "School with students per teacher > median"
		label var spt_intA5		  		 "Students per teacher"
		
		label var T2009_spt_int9  		 "2009 interated with schools where students per teacher > median" 
		label var T2009_spt_intA9 		 "2009 interated with students per teacher" 
		label var spt_int9		  		 "School with students per teacher > median"
		label var spt_intA9		  		 "Students per teacher"	
		
		label var T2009_principal_int5   "2009 interated with schools where principal effort > median" 
		label var T2009_principal_intA5  "2009 interated with principal effort" 
		label var principal_int5		 "School with principal effort > median"
		label var principal_intA5	     "Principal Effort Index"
		
		label var T2009_principal_int9   "2009 interated with schools where principal effort > median" 
		label var T2009_principal_intA9  "2009 interated with principal effort" 
		label var principal_int9		 "School with principal effort > median"
		label var principal_intA9		 "Principal Effort Index"
				
		label var T2009_tenure_int5   	 "2009 interated with schools where teacher's tenure  > median" 
		label var T2009_tenure_intA5  	 "2009 interated with % teachers with tenure" 
		label var tenure_int5		 	 "School with teacher's tenure > median"
		label var tenure_intA5		 	 "% teachers with tenure"
		
		label var T2009_tenure_int9   	 "2009 interated with schools where teacher's tenure  > median" 
		label var T2009_tenure_intA9  	 "2009 interated with % teachers with tenure" 
		label var tenure_int9			 "School with teacher's tenure > median"
		label var tenure_intA9		 	 "% teachers with tenure"
				
		label var absenteeism_int5		 "Schoos where abseenteism is a big issue" 
		label var absenteeism_int9		 "Schoos where abseenteism is a big issue" 
		label var T2009_absenteeism_int5 "2009 interacted with schools where abseenteism is a big issue" 
		label var T2009_absenteeism_int9 "2009 interacted with schools where abseenteism is a big issue" 

		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Criteria to student's allocation into their classrooms
	*-------------------------------------------------------------------------------------------------------------------------------*	
		gen  	classrooms_similar_ages  	= criteria_classrooms  == 1
		gen 	classrooms_het_performance  = criteria_classrooms  == 4
		replace classrooms_similar_ages  	= . if missing(criteria_classrooms)
		replace classrooms_het_performance  = . if missing(criteria_classrooms)
	
		label 	var classrooms_similar_ages  	 "Students allocated into classrooms according to similar age"
		label 	var classrooms_het_performance 	 "Students allocated into classrooms according to hetero. performance"


	*-------------------------------------------------------------------------------------------------------------------------------*	
		sort 		codschool year
		xtset 		codschool year 	
		compress
		save "$final/h1n1-school-closures-sp-2009.dta", replace

