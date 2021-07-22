
	*________________________________________________________________________________________________________________________________* 
	**
	**SCHOOL DATASET	
	**
	*________________________________________________________________________________________________________________________________* 

	
	**
	*IDESP at school level	(Performance Assessment of state-managed schools in Sao Paulo)																										
	*-------------------------------------------------------------------------------------------------------------------------------*
	**	
	
	*In 2008, the state government implemented a management program in low-performing schools in Sao Paulo.
	*We use data from the performance assessment of the state to identify the treated schools
	foreach etapa in AI AF EM { //AI -> 5grade, AF -> 9 grade, EM - > High School
		
			import delimited "$raw/IDESP/IDESP por Escola - 2007_2019_`etapa'.csv", delimiter(";")  clear 
			
			if "`etapa'" == "AI" local name = "5grade"
			if "`etapa'" == "AF" local name = "9grade"
			if "`etapa'" == "EM" local name = "EM"
				
			local 	  year = 2007
			foreach var of varlist v7-v19 {
				rename `var' idesp_`name'`year'
				local year = `year' + 1
			}
			drop if missing(codigoinep)
			drop nivelensino codigocie diretoria
			reshape long idesp_`name', i(codigoinep  escola municipio) j(year)
			tempfile `etapa'
			save    ``etapa''
		}
				
		merge 1:1 codigoinep year using `AI', nogen
		merge 1:1 codigoinep year using `AF', nogen
			
		foreach var of varlist idesp* {
			replace  `var' = subinstr(`var', ",",".",.)
			destring `var', replace
		}
		rename (codigoinep  escola municipio) (codschool school muni)
		compress
		save 	"$inter/IDESP.dta", replace
				
	**
	*Bottom 5% schools are the ones included in the program
	*-------------------------------------------------------------------------------------------------------------------------------*
		**
		*Bottom 5% in 2007, included in 2008
		use 		"$inter/IDESP.dta" if year == 2007, clear 		//selected schools in 2008 
		by			year, sort: quantiles idesp_EM,     gen(percentile_EM)      stable  nq(100)
		by	 		year, sort: quantiles idesp_5grade, gen(percentile_5grade)  stable  nq(100)
		by 			year, sort: quantiles idesp_9grade, gen(percentile_9grade)  stable  nq(100)
			
		gen 		school_management_program  			=  1 if (percentile_EM < 6 | percentile_5grade < 6 | percentile_9grade < 6) 
		replace 	school_management_program   		=  0 if (percentile_EM > 5 & percentile_5grade > 5 & percentile_9grade > 5) 
		replace 	school_management_program 			=  . if  missing(percentile_EM) & missing(percentile_5grade) & missing(percentile_9grade)
		
		keep 		if school_management_program == 1 
		keep 		codschool  school_management_program
		
		tempfile 	treatment_management_program
		save 	   `treatment_management_program'
	
		**
		*Bottom 5% in 2008, included in 2009
		use 	   	"$inter/IDESP.dta" if year == 2008, clear  		//selected schools in 2009
		by 			year, sort: quantiles idesp_EM,     gen(percentile_EM)      stable  nq(100)
		by 			year, sort: quantiles idesp_5grade, gen(percentile_5grade)  stable  nq(100)
		by 			year, sort: quantiles idesp_9grade, gen(percentile_9grade)  stable  nq(100)
			
		gen 		school_management_program  			=  1 if (percentile_EM < 6 | percentile_5grade < 6 | percentile_9grade < 6) 
		replace 	school_management_program   		=  0 if (percentile_EM > 5 & percentile_5grade > 5 & percentile_9grade > 5) 
		replace 	school_management_program 			=  . if  missing(percentile_EM) & missing(percentile_5grade) & missing(percentile_9grade)
		
		keep 		if school_management_program == 1
		keep 		codschool  school_management_program idesp*
		
		append 		using `treatment_management_program'			//the schools included in 2008 were also included in 2009
		
		duplicates 	drop codschool, force							//each row in a school included in the Program
		save 		"$inter/Managerial Practices Program.dta", replace
		
	**
	*Some teachers working in the state-managed school that was part of the Management Program can also work in a state-school
	//not included in the intervention or in a locally-manged school. We are going to identify the schools that have at least 
	//one teacher in this situation and also the % of teachers in this situation. 
	*-------------------------------------------------------------------------------------------------------------------------------*
		use 		"$inter/Código de Identificação dos professores" if (network == 2 | network == 3) & (year == 2009 | year  == 2008) & coduf == 35, clear		//Censo Escolar Data, each row is a teacher and a school where he/she works
																																								//the same codteacher can be in more than a row if the teacher works in different schools
		merge 		m:1 codschool using "$inter/Managerial Practices Program.dta", nogen keepusing(school_management_program)									//identifying the schools included in the Management Program. 


		
		
		bys 		year codteacher : egen teacher_management_program = max(school_management_program)															//identifying the teachers that work in state-managed schools included in the Management Program. 
		
		replace 	teacher_management_program 		 = 0 if teacher_management_program == .
		clonevar 	share_teacher_management_program = 		teacher_management_program 
		
		

		
				gen T   				= .										//1 for closed schools, 0 otherwise
		gen G	  				= 1										//0 for the 13 municipalities that extended the winter break, 1 otherwise
		foreach munic in $treated_municipalities {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			replace T   		= 1 		if codmunic == `munic' & network == 3
			replace G	  	  	= 0 		if codmunic == `munic'
		}		
		replace T    			= 1 		if network == 2
		replace T    			= 0 		if T == .

		tab year teacher_management_program if network == 3 & LTeacher5grade == 1 & T == 1
		tab year teacher_management_program if network == 3 & LTeacher5grade == 1 & T == 0
		
		
		
		
		
		
		
		
		collapse 	(max) teacher_management_program (mean)share_teacher_management_program (max)school_management_program , by(codschool network year) 				
		
		replace 	school_management_program = 0 if school_management_program == .

		preserve
		keep 		if year == 2008 //a few schools are listed in 2008 but not in 2009. To include all schools that already participated of the intervention, we are selecting those schools here to append with the schools included in 2009 
		tempfile 	2008
		save 	   `2008'
		restore
		
		keep 		if year == 2009 
		merge 		1:1 codschool using `2008', nogen
		
		replace  	share_teacher_management_program = share_teacher_management_program*100
		format   	share_teacher_management_program %4.2fc
		
		
		
		
		save 		"$inter/Teachers Managerial Practices Program.dta", replace			//share of teachers per school participating in the Management Program
		
		
	**
	*Some teachers work in state and locally-managed schools																								
	*-------------------------------------------------------------------------------------------------------------------------------*
	**	
		use 	"$inter/Código de Identificação dos professores" if (network == 2 | network == 3) & coduf == 35, clear
		bys 	year codteacher: egen min_network = min(network) 						//2 if state-managed
		bys 	year codteacher: egen max_network = max(network)						//3 if locally-managed
		
		
				
						gen T   				= .										//1 for closed schools, 0 otherwise
		gen G	  				= 1										//0 for the 13 municipalities that extended the winter break, 1 otherwise
		foreach munic in $treated_municipalities {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			replace T   		= 1 		if codmunic == `munic' & network == 3
			replace G	  	  	= 0 		if codmunic == `munic'
		}		
		replace T    			= 1 		if network == 2
		replace T    			= 0 		if T == .
		
		
		
		gen 	teacher_both_networks = 1 if min_network == 2 & max_network == 3
		replace teacher_both_networks = 0 if teacher_both_networks == .
	
		tab year teacher_both_networks if network == 3 & LTeacher5grade == 1
		tab year teacher_both_networks if network == 2 & LTeacher5grade == 1 & G == 1
			
			
		clonevar share_teacher_both_networks = teacher_both_networks
		collapse (max) teacher_both_networks (mean) share_teacher_both_networks, by(codschool year network codmunic) 		
		
		preserve
		keep if year == 2007
		tempfile 2007
		save 	`2007'
		restore
		
		preserve
		keep if year == 2008
		tempfile 2008
		save 	`2008'
		restore
				
		keep if year == 2009 
		merge 1:1 codschool using `2008', nogen
		merge 1:1 codschool using `2007', nogen
		
		replace  share_teacher_both_networks = share_teacher_both_networks*100
		format   share_teacher_both_networks %4.2fc
		


		save "$inter/Teachers in state and municipal networks.dta", replace				//share of teachers per school that work in a state and in a locally-managed school

		**
		**The majority of teachers of 5th grade students work in both state and municipal networks
		gen G	  				= 1										//0 for the 13 municipalities that extended the winter break, 1 otherwise
		foreach munic in $treated_municipalities {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			replace G	  	  	= 0 		if codmunic == `munic'
		}		
		merge 1:1 codschool year using "$inter/Enrollments.dta", keep(3) nogen
		
		tab year teacher_both_networks if enrollment5grade != . 
		tab year teacher_both_networks if enrollment5grade != . & network == 3 
	
	**
	*Socioeconomic characteristics of the students at school level																													
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	   "$inter/Students - Prova Brasil.dta" if (network == 2 | network == 3) & (year == 2007 | year == 2009) & coduf == 35, clear
		egen 		teacher_motivation = rowmean(teacher_motivation*)
		label var   teacher_motivation "Teacher motivation from students' perspective"

		foreach v of var * {
		local l`v' : variable label `v'
			if `"`l`v''"' == "" {
			local l`v' "`v'"
			}
		}
		collapse   (mean) $socioeco_variables teacher_motivation* number_dropouts number_repetitions, by(grade year codschool)
		
		foreach v of var * {
			label var `v' "`l`v''"
		}
		
		foreach var of varlist $socioeco_variables {
			replace `var' = `var'*100 
			format  `var' %4.2fc
		} 
		format 		incentive* number* teacher_motivation* %4.2fc
		
		foreach v  of varlist  incentive_study-teacher_motivation{
			local l`v'5 : variable label `v'
			local l`v'9 : variable label `v'

		}
		reshape 	wide $socioeco_variables teacher_motivation* number_dropouts number_repetitions, i(codschool year) j(grade)
		
		foreach v of varlist  incentive_study5-teacher_motivation5 {
			if substr("`v'", -1, .) == "5" {
			local new = 1
			}
			if substr("`v'", -1, .) == "9" {
			local new = 2
			}
			local z = substr("`v'", 1,length("`v'")-1)
			if `new' == 1 label var `v' "`l`z'5' - %" 
			if `new' == 2 label var `v' "`l`z'9' - %" 
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
		mes_fim_letivo dia_fim_letivo CICLOS using "$inter/School Infrastructure.dta"  if (network == 3 | network == 2) & codschool!= . & coduf == 35, clear
		tempfile    school_infra
		save       `school_infra'
	
	
	**
	*Enrollments																										
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 		year codschool enrollmentEMtotal enrollmentEFtotal enrollment5grade network enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentEI coduf  ///
		using "$inter/Enrollments"  if (network == 3 | network == 2)  & !missing(codschool) & coduf == 35, clear
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
		use 		classhour5grade classhour9grade  year codschool network coduf using "$inter/Class-Hours.dta" 			if (network == 2 | network == 3) & codschool !=. & coduf == 35, clear
		tempfile    class_hours
		save       `class_hours'	
	
	
	**
	*Students per class																							
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	    tclass5grade tclass9grade 		 year codschool network coduf using "$inter/Class-Size.dta" 			if (network == 2 | network == 3) & codschool !=. & coduf == 35, clear
		tempfile    class_size
		save       `class_size'	
	
		
	**
	*Students per teacher																					
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	    spt5grade spt9grade 	  		 year codschool network	uf    using "$inter/Students per teacher.dta"   if (network == 2 | network == 3) & codschool !=. & uf == "SP", clear
		tempfile    students_teacher
		save       `students_teacher'	
		
	
	**
	*IDEB																						
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 		"$inter/IDEB by school.dta" if (year == 2005 | year == 2007 | year == 2009) & (network == 2 | network == 3) & codschool !=. & coduf == 35, clear
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
		use  "$inter/Teachers - Prova Brasil.dta" 	if (network == 2 | network == 3) & (year == 2007 | year == 2009) & codschool !=. & grade != . & coduf == 35, replace
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
		foreach v  of varlist grade-def_bad_behavior {
			local l`v'5 : variable label `v'
			local l`v'9 : variable label `v'

		}
		
		foreach var of varlist teacher_more10yearsexp-teacher_less3min_wages almost_all_finish_grade9-def_bad_behavior {
			replace `var' = `var'*100
		}
		
		reshape wide $teachers, 		   				i(codschool year) j(grade)

		foreach v of varlist teacher_more10yearsexp5-def_bad_behavior9 {
			if substr("`v'", -1, .) == "5" {
			local new = 1
			}
			if substr("`v'", -1, .) == "9" {
			local new = 2
			}
			local z = substr("`v'", 1,length("`v'")-1)
			if `new' == 1 label var `v' "`l`z'5' - %" 
			if `new' == 2 label var `v' "`l`z'9' - %" 
		}
		
		format teacher_more10yearsexp5-def_bad_behavior9 %4.2fc
		tempfile teachers
		save	`teachers'

		
	**
	*Principals																				
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use  "$inter/Principals - Prova Brasil.dta" if (network == 2 | network == 3) & (year == 2007 | year == 2009) & codschool !=. & coduf == 35 , clear
		keep codschool year $principals
		tempfile principals
		save	`principals'

		
	**
	*==============>> Merging all data
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
		use 	`school_infra'	, clear
		merge   1:1 codschool year using `flow_index'											, nogen
		merge   1:1 codschool year using `enrollments'	 										, nogen keepusing(enrollment5grade enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentTotal)
		merge   1:1 codschool year using `class_hours'	 										, nogen keepusing(classhour5grade classhour9grade)
		merge   1:1 codschool year using `class_size'	 										, nogen keepusing(tclass5grade tclass9grade)
		merge   1:1 codschool year using `students_teacher'	 									, nogen keepusing(spt5grade spt9grade)
		merge 	1:1 codschool year using `ideb'													, nogen
		merge 	1:1 codschool year using `socio_economic'										, nogen 
		merge 	1:1 codschool year using `teachers'												, nogen 
		merge 	1:1 codschool year using `principals'											, nogen 
		merge   m:1 codmunic  year using "$inter/GDP per capita.dta"							, nogen keep(1 3) keepusing(pib_pcap pop porte)
		merge 	m:1 codschool 	   using "$inter/Managerial Practices Program.dta"				, nogen keepusing(school_management_program)
		merge 	m:1 codschool 	   using "$inter/Teachers Managerial Practices Program.dta"		, nogen keepusing(teacher_management_program share*)
		merge 	m:1 codschool 	   using "$inter/Teachers in state and municipal networks.dta"	, nogen 
		merge 	m:1 codschool 	   using `data'													, nogen keep(3) //para manter somente as escolas que estao na base da Prova Brasil
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
		
		gen school_year = cfim_letivo - cinicio_letivo
		
		order year-codmunic2 n_munic location codschool-mes_fim_letivo school_year CICLOS

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
		label var repetition5 							"Repetition - %" 
		label var dropout5 								"Dropout - %" 
		label var approval5								"Approval - %" 
		label var repetition9 							"Repetition - %" 
		label var dropout9 								"Dropout - %" 
		label var approval9								"Approval - %" 
		label var ComputerLab 							"Schools with computer lab - %" 
		label var ScienceLab 							"Schools with science lab - %" 
		label var Library 								"Schools with library - %" 
		label var InternetAccess 						"Schools internet access - %" 
		label var SportCourt 							"Schools sport court - %"
		label var enrollment5 							"Enrollments 5th grade"
		label var enrollment9 							"Enrollments 9th grade"
		label var classhour5 							"Class hours per day"
		label var tclass5 								"Students per class"
		label var classhour9 							"Class hours per day"
		label var tclass9								"Students per class"
		label var pop									"Population of the municipality, in thousands"
		label var pib_pcap								"GDP per capita of the municipality, in 2019 BRL"
		label var spt5									"Students per teacher"
		label var spt9									"Students per teacher"
		foreach x in 5 9 {
		label var math`x'        						"Math, `x'th grade"
		label var port`x' 		 						"Portuguese, `x'th grade"
		label var sp`x'									"Standardized Performance, `x'th grade"
		}
		foreach x in EF1 EF2 {
		label var ideb`x'   	  	 					"IDEB `x'"
		label var enrollment`x'							"Enrollments `x'"
		}
		label var porte									"Size of the municipality"
		label var CICLOS								"Schools with automatic approval" 
		label var enrollmentTotal						"Total enrollment, all grades"
		label var school_year							"Length of the school year (days)"
		

		
		
		
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
		label define G		   1 "Local authorities did not extend winter break" 0 "Local authoritied extend winter break"
		label define T		   0 "Comparison Group" 1 "Treatment Group"
		label define E		   0 "Locally-managed"  1 "State-managed"
		label val id_13_mun id_13_mun
		label val G G
		label val T T
		label val E	E
	
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
		label var `var' "State-managed"
		}
		foreach var of varlist beta2* {
		label var `var' "G = 1"
		}
		foreach var of varlist beta4* {
		label var `var' "State-managed versus G = 1"
		}	
		foreach var of varlist beta5* {
		label var `var' "State-managed versus post-treament" 
		}	
		foreach var of varlist beta6* {
		label var `var' "Post-treatment versus with G = 1" 
		}	
		foreach var of varlist beta7* {
		label var `var' "Triple difference in differences"
		}	
		label var beta3		"Post-treatment year (2009)"
		label var beta3P1	"Post-treatment year (2007)"
		label var beta3P2	"Post-treatment year (2008)"
		
	*-------------------------------------------------------------------------------------------------------------------------------*
	**
	*Interactions
	*-------------------------------------------------------------------------------------------------------------------------------*			
		**
		*Treatment status versus students per ttab eacher, principal effort and teacher tenure
		foreach variable in spt principal_effort teacher_tenure { 				//students per teacher, principal_effort_index teacher_tenure 
			foreach grade in 5 9 {
				gen 	T2009_`variable'`grade'   = T2009*`variable'`grade'	
			}
		}

		**
		*Treatment status versus teacher absenteeism
		clonevar  absenteeism_issue5 = absenteeism_teachers3 
		clonevar  absenteeism_issue9 = absenteeism_teachers3 
		gen T2009_absenteeism_issue5 = T2009*absenteeism_issue5
		gen T2009_absenteeism_issue9 = T2009*absenteeism_issue9

		**
		*Labels
		label var T2009_spt5  			 	"ATT versus students per teacher" 
		label var T2009_spt9  			 	"ATT versus students per teacher" 
		label var T2009_principal_effort5   "ATT versus principal effort" 
		label var T2009_principal_effort9  	"ATT versus principal effort" 
		label var T2009_teacher_tenure5  	"ATT versus % teachers with tenure" 
		label var T2009_teacher_tenure9  	"ATT versus % teachers with tenure"
		label var T2009_absenteeism_issue5 	"ATT versus teacher absenteeism" 
		label var T2009_absenteeism_issue9 	"ATT versus teacher absenteeism"  
		
		format T2009_* %4.2fc
		
		
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
	**
	*Delta performance
	*-------------------------------------------------------------------------------------------------------------------------------*	
	sort 		codschool year

	foreach subject in math5 port5 {
	gen 	delta_`subject' = `subject'[_n+1] - `subject'[_n] if year[_n] == 2007 & year[_n+1] == 2009 & codschool[_n] == codschool[_n+1] 
	replace delta_`subject' = `subject'[_n+2] - `subject'[_n] if year[_n] == 2007 & year[_n+2] == 2009 & codschool[_n] == codschool[_n+2] 
	}
	
	*-------------------------------------------------------------------------------------------------------------------------------*	
		xtset 		codschool year 	
		compress
		save "$final/h1n1-school-closures-sp-2009.dta", replace


