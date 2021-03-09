

**SCHOOL DATASET		
*------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------*


*1* 
*Socioeconomic characteristics of the students at school level																													
*------------------------------------------------------------------------------------------------------------------------*
	
	*2007 & 2009
	*--------------------------------------------------------------------------------------------------------------------*
	use 	   "$provabrasil/Students.dta" if coduf == 35, clear
	save  	   "$inter/Socioeconomic Characteristics at student level.dta", replace
	use 	   "$inter/Socioeconomic Characteristics at student level.dta", clear
	collapse   (mean) $socioeco_variables, by(grade year codschool)
	foreach var of varlist $socioeco_variables100 {
		replace `var' = `var'*100 
		format  `var' %4.2fc
	}
	format 		incentive* number* %4.2fc
	reshape 	wide  $socioeco_variables, i(year codschool) j(grade)
	sort 		codschool year
	tempfile    socio_economic
	save       `socio_economic'

	
*2* 
*Flow Indicators																											
*------------------------------------------------------------------------------------------------------------------------*
	*use 	   "$rendimento/Flow Indicators at school level.dta" if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear
	*save 	   "$inter/Flow Indicators at school level.dta", replace
	use 	   "$inter/Flow Indicators at school level.dta", clear
	drop 		*EM*
	tempfile    flow_index
	save       `flow_index'
	
	
*3*
*School Infrastructure																									
*------------------------------------------------------------------------------------------------------------------------*
	*use 	   "$censoescolar/School Infrastructure at school level.dta"   if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear
	*save 	   "$inter/School Infrastructure at school level.dta", replace
	use 	   	$matching_schools year codschool coduf uf codmunic codmunic2 operation network location cfim_letivo cinicio_letivo mes_fim_letivo dia_fim_letivo CICLOS using "$inter/School Infrastructure at school level.dta", clear
	foreach var of varlist $matching_schools {
		replace `var' = `var'*100
	}
	tempfile    school_infra
	save       `school_infra'
	
	
*4* 
*Enrollments																								
*------------------------------------------------------------------------------------------------------------------------*
   use 	   "$censoescolar/Enrollments at school level.dta" if uf == "SP", clear
   collapse 	(sum)$matriculas (mean)school_*, by(year codschool codmunic network)
   save	   "$inter/Enrollments at school level.dta", replace
	use 		year codschool enrollment5grade network enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentEI enrollmentEMtotal  using "$inter/Enrollments at school level.dta"  if (network == 3 | network == 2)  & !missing(codschool), clear
	foreach var of varlist enrollment* {
		replace `var' = . if `var' == 0
	}
	
	egen enrollmentTotal = rsum(enrollmentEF1 enrollmentEF2 enrollmentEI enrollmentEMtotal)
	tempfile    enrollments
	save       `enrollments'	
	
	
*5* 
*Class-hours																								
*------------------------------------------------------------------------------------------------------------------------*
   *use 	   "$censoescolar/Class-Hours at school level.dta" if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear
   *save 	   "$inter/Class-Hours at school level.dta", replace
	use 		classhour5grade classhour9grade  year codschool using "$inter/Class-Hours at school level.dta", clear
	tempfile    class_hours
	save       `class_hours'	
	
	
*6* 
*Size of the classrooms																						
*------------------------------------------------------------------------------------------------------------------------*
    *use 	   "$censoescolar/Class-Size at school level.dta"  if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear
    *save 	   "$inter/Class-Size at school level.dta", replace
	use 	    tclass5grade tclass9grade year codschool 		using "$inter/Class-Size at school level.dta", clear
	tempfile    class_size
	save       `class_size'	
	
		
*7* 
*Students per teacher																		
*------------------------------------------------------------------------------------------------------------------------*
    *use 	   "$censoescolar/Students per teacher at school level.dta"  if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear
    *save 	   "$inter/Students per teacher at school level.dta" , replace
	use 	    spt_5grade spt_9grade 	  year codschool 	    using "$inter/Students per teacher at school level.dta", clear
	tempfile    students_teacher
	save       `students_teacher'	
		
	
*8*
*Expenditure per student																						
*------------------------------------------------------------------------------------------------------------------------*
   *use 	   "$fnde/FNDE Indicators.dta"  if (network == 3 | network == 2) & coduf == 35, clear
   *save 	   "$inter/FNDE Indicators.dta", replace
	use			year codmunic2 ind_49 r_ind_49 					using	"$inter/FNDE Indicators.dta", clear  //r_ind_49 gasto por aluno do EF em R$ de 2018
	tempfile    expenditure
	save       `expenditure'	
	

*9* 
*IDEB school level
*------------------------------------------------------------------------------------------------------------------------*
   *use 		"$ideb/IDEB at school level.dta" if uf == "SP" & (network == 3 | network == 2) & !missing(codschool), clear   *
   *save		"$inter/IDEB at school level.dta", replace
	use 		"$inter/IDEB at school level.dta" if year == 2005 | year == 2007 | year == 2009 | year == 2011 | year == 2013 | year == 2015, clear
	rename 		(spEF1 spEF2) (sp5 sp9)
	drop 		flowindexEF* target* approval*
	tempfile    ideb
	save       `ideb'
	
	*List of schools included in Prova Brasil
	*--------------------------------------------------------------------------------------------------------------------*
	duplicates drop codschool, force
	keep 	 codschool
	tempfile data
	save 	`data'
	
*10* 
*Teachers
*------------------------------------------------------------------------------------------------------------------------*
	use "$provabrasil/Teachers.dta" if !missing(grade) & grade < 12, clear
	save "$inter/Teachers.dta", replace
	use  "$inter/Teachers.dta", replace
	collapse 		 (mean)$teachers, 	by (		  codschool year    grade)
	reshape wide $teachers, 		   				i(codschool year) j(grade)
	format teacher_male5-quality_books49 %4.2fc
	tempfile teachers
	save	`teachers'
	

*11* 
*Principals
*------------------------------------------------------------------------------------------------------------------------*
	use  "$provabrasil/Principals.dta", clear
	save "$inter/Principals.dta", replace
	use  "$inter/Principals.dta", clear
	keep codschool year $principals
	tempfile principals
	save	`principals'

	
*12* 
*Performance + school infrastructure + socioeconomic characteristics + GeoCodes + pib per capita + expenditure per student	
*------------------------------------------------------------------------------------------------------------------------*
	use 	`flow_index', clear
	merge   1:1 codschool year using `school_infra'	 			, nogen
	merge   1:1 codschool year using `enrollments'	 			, nogen keepusing(enrollment5grade enrollment9grade enrollmentEF1 enrollmentEF2 enrollmentTotal)
	merge   1:1 codschool year using `class_hours'	 			, nogen keepusing(classhour5grade classhour9grade)
	merge   1:1 codschool year using `class_size'	 			, nogen keepusing(tclass5grade tclass9grade)
	merge   1:1 codschool year using `students_teacher'	 		, nogen keepusing(spt_5grade spt_9grade)
	merge 	1:1 codschool year using `ideb'						, nogen
	merge 	1:1 codschool year using `socio_economic'			, nogen 
	merge 	1:1 codschool year using `teachers'					, nogen 
	merge 	1:1 codschool year using `principals'				, nogen 
	merge   m:1 codmunic2 year using `expenditure'   			, nogen 
	merge   m:1 codmunic  year using "$inter/GDP per capita.dta", nogen keep(1 3) keepusing(pib_pcap pop porte)
	merge 	m:1 codschool 	   using `data'						, nogen keep(3) //para manter somente as escolas que estao na base da Prova Brasil
	sort 	codschool year 
	xtset   codschool year  
	

*------------------------------------------------------------------------------------------------------------------------*
	foreach var of varlist *grade {
		local newname  = substr("`var'",1, length("`var'") - 5)
		rename `var'  `newname'
	}
		
*Treated municipalities
*------------------------------------------------------------------------------------------------------------------------*
	gen treated   = .				//1 for closed schools, 0 otherwise
	gen id_13_mun = 0				//1 for the 13 municipalities that extended the winter break, 0 otherwise
	gen id_M	  = 1				//0 for the 13 municipalities that extended the winter break, 1 otherwise
	
	foreach munic in $treated_municipalities {
		replace treated   = 1 if codmunic == `munic' & network == 3
		replace id_13_mun = 1 if codmunic == `munic'
		replace id_M	  = 0 if codmunic == `munic'
	}		
	replace treated    = 1 if network == 2
	replace treated    = 0 if treated == .
	gen 	post_treat = (year > 2007)
	gen 	T2007 	   =  year == 2007  & treated == 1
	gen 	T2009 	   =  year == 2009  & treated == 1

	gen 	state_network = network == 2
	
*Type of municipalities
*------------------------------------------------------------------------------------------------------------------------*
	gen 	A = 1 if network == 2 & !missing(math5)
	bys 	year codmunic: egen mun_escolas_estaduais_ef1  = max(A)			//municipalities with state schools offering 1st to 5th grade
	drop 	A	
	
	gen 	A = 1 if network == 2 & !missing(math9) 
	bys 	year codmunic: egen mun_escolas_estaduais_ef2  = max(A)			//municipalities with state schools offering 6th to 9th grade
	drop 	A
	
	gen 	A = 1 if network == 3 & !missing(math5)
	bys 	year codmunic: egen mun_escolas_municipais_ef1 = max(A)			//municipalities with municipal schools offering 1st to 5th grade
	drop 	A
	
	gen 	A = 1 if network == 3 & !missing(math9) 
	bys 	year codmunic: egen mun_escolas_municipais_ef2 = max(A)			//municipalities with municipal schools offering 6th to 9th grade
	drop 	A	
	
	gen 	tipo_municipio_ef1 = 1 if mun_escolas_estaduais_ef1 == 1 & mun_escolas_municipais_ef1 == 1
	replace tipo_municipio_ef1 = 2 if mun_escolas_estaduais_ef1 == . & mun_escolas_municipais_ef1 == 1
	replace tipo_municipio_ef1 = 3 if mun_escolas_estaduais_ef1 == 1 & mun_escolas_municipais_ef1 == .
	replace tipo_municipio_ef1 = 4 if mun_escolas_estaduais_ef1 == . & mun_escolas_municipais_ef1 == .
	label 	define tipo_municipio_ef1 1 "Escolas Estaduais e Municipais com EF1" 2  "Sem escolas Estaduais e com escolas municipais de EF1" 3 "Com escolas Estaduais e sem escolas municipais de EF1" 4 "Sem escolas de EF1" 
	label 	val tipo_municipio_ef1 tipo_municipio_ef1
	
	gen 	tipo_municipio_ef2 = 1 if mun_escolas_estaduais_ef2 == 1 & mun_escolas_municipais_ef2 == 1
	replace tipo_municipio_ef2 = 2 if mun_escolas_estaduais_ef2 == . & mun_escolas_municipais_ef2 == 1
	replace tipo_municipio_ef2 = 3 if mun_escolas_estaduais_ef2 == 1 & mun_escolas_municipais_ef2 == .
	replace tipo_municipio_ef2 = 4 if mun_escolas_estaduais_ef2 == . & mun_escolas_municipais_ef2 == .
	label 	define tipo_municipio_ef2 1 "Escolas Estaduais e Municipais com EF2" 2  "Sem escolas Estaduais e com escolas municipais de EF2" 3 "Com escolas Estaduais e sem escolas municipais de EF2" 4 "Sem escolas de EF2" 
	label 	val tipo_municipio_ef2 tipo_municipio_ef2
	
	gen 	offers_ef1 = !missing(math5) 
	gen 	offers_ef2 = !missing(math9)
	gen 	offers_ef1_ef2 = offers_ef1 == 1 & offers_ef2 == 1
	
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
	
	foreach var of varlist offers* tipo_* {
		replace `var' = . if year == 2005 | year == 2006 | year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016
	}
	
	preserve
		duplicates drop codmunic year tipo_municipio_ef1 tipo_municipio_ef2, force
		keep 			codmunic year tipo_municipio_ef1 tipo_municipio_ef2 
		drop 		if year == 2005 | year == 2006 | year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016
		replace 	   year =  year + 1
		expand 2 	if year == 2008, gen(REP)
		replace 	   year =  2005 			if REP == 1
		drop REP
		
		tempfile tipo
		save 	`tipo'
	restore
	
	merge m:1 codmunic year using `tipo', update nogen

	
	* ------------------------------------------------------------------------------------------------------------------ *
	gen 	pop_2007 = pop if year == 2007
	bys 	codmunic: egen max = max(pop_2007)
	drop 	pop_2007
	rename  max pop_2007
	
	* ------------------------------------------------------------------------------------------------------------------ *
	foreach grade in 5 9 {
		egen port_basic_more_`grade' = rowtotal(port_basic`grade' port_adequ`grade'), missing
		egen math_basic_more_`grade' = rowtotal(math_basic`grade' math_adequ`grade'), missing
	}
	
	
	* ------------------------------------------------------------------------------------------------------------------ *
	bys year: quantiles math5, gen(q_math5) stable nq(9)
	bys year: quantiles port5, gen(q_port5) stable nq(9)

	
	* ------------------------------------------------------------------------------------------------------------------ *
	sort 	codschool year 
	order   codschool year network location treated  coduf uf codmunic codmunic2 n_munic pop pib_pcap ind_49 r_ind_49  operation cinicio_letivo cfim_letivo dia_fim_letivo mes_fim_letivo CICLOS 
	format  pop %20.0fc
	keep if year == 2005 | year == 2007 | year == 2009
	
	
	*Triple dif in dif
	* ------------------------------------------------------------------------------------------------------------------ *
	gen D = (year == 2009)
	gen G = id_M == 1
	gen E = state_network
	gen beta1  = E
	gen beta2  = G
	gen beta3  = D
	gen beta4  = E*G
	gen beta5  = E*D
	gen beta6  = G*D
	gen beta7  = E*G*D  //triple dif coefficient
	
	foreach variable in spt_ principal_effort_index teacher_tenure  { //principal_effort_index teacher_tenure 
		if "`variable'" == "principal_effort_index"		local name = "principal_int"
		if "`variable'" == "teacher_tenure" 			local name = "teacher_tenure_int"
		if "`variable'" == "spt_"						local name = "spt_int"
		
		foreach grade in 5 9{
			gen `name'`grade'  = 0						  	if 												    						     	!missing(`variable'`grade')
			gen `name'`grade'q = 0 					      	if 												    						     	!missing(`variable'`grade')	
				
				forvalues year = 2007(2)2009 {
					su 		`variable'`grade' 	  		  	if year == `year', detail
					replace `name'`grade'  = 1			  	if year == `year' 	& `variable'`grade' >= r(p50) & 							 	!missing(`variable'`grade')	
					replace `name'`grade'q = 1			  	if year == `year' 	& `variable'`grade' <= r(p25) & 							 	!missing(`variable'`grade')	
					replace `name'`grade'q = 2			  	if year == `year' 	& `variable'`grade' >  r(p25) & `variable'`grade' <=  r(p50) & 	!missing(`variable'`grade')	
					replace `name'`grade'q = 3			  	if year == `year' 	& `variable'`grade' >  r(p50) & `variable'`grade' <=  r(p75) & 	!missing(`variable'`grade')	
					replace `name'`grade'q = 4			  	if year == `year' 	& `variable'`grade' >  r(p75) &								  	!missing(`variable'`grade')	
				}
				
			gen 	T2009_`name'`grade'   = T2009*`name'`grade'
			
			gen 	T2009_`name'`grade'q1 = 1 			  	if `name'`grade'q == 1 & treated == 1 & year == 2009
			gen 	T2009_`name'`grade'q2 = 1			  	if `name'`grade'q == 2 & treated == 1 & year == 2009
			gen 	T2009_`name'`grade'q3 = 1            	if `name'`grade'q == 3 & treated == 1 & year == 2009
			gen	 	T2009_`name'`grade'q4 = 1			  	if `name'`grade'q == 4 & treated == 1 & year == 2009 
			 
			replace T2009_`name'`grade'q1 = 0 				if	missing(T2009_`name'`grade'q1) & 											 	!missing(`variable'`grade')	
			replace T2009_`name'`grade'q2 = 0 				if	missing(T2009_`name'`grade'q2) & 											 	!missing(`variable'`grade')	
			replace T2009_`name'`grade'q3 = 0 				if	missing(T2009_`name'`grade'q3) & 											 	!missing(`variable'`grade')	
			replace T2009_`name'`grade'q4 = 0 				if	missing(T2009_`name'`grade'q4) & 											 	!missing(`variable'`grade')	
		}
	}

	gen  	absenteeism_teachers_int5   = 				absenteeism_teachers 	  == 2 //teacher abseemteism is a big issue
	replace absenteeism_teachers_int5   = . if missing(absenteeism_teachers)
	gen T2009_absenteeism_teachers_int5 = T2009*absenteeism_teachers_int5
	
	gen  	absenteeism_teachers_int9   = 				absenteeism_teachers 	  == 2 //teacher abseemteism is a big issue
	replace absenteeism_teachers_int9   = . if missing(absenteeism_teachers)
	gen T2009_absenteeism_teachers_int9 = T2009*absenteeism_teachers_int9
	
	gen  	classrooms_similar_ages  	= criteria_classrooms  == 1
	gen 	classrooms_het_performance  = criteria_classrooms  == 4
	replace classrooms_similar_ages  	= . if missing(criteria_classrooms)
	replace classrooms_het_performance  = . if missing(criteria_classrooms)

	*Labels
	* ------------------------------------------------------------------------------------------------------------------ *
	foreach grade in 5 9 {
		label var  tv`grade'							"TV"
		label var  dvd`grade' 							"DVD"
		label var  fridge`grade' 						"Geladeira"
		label var  car`grade' 							"Carro"
		label var  computer`grade' 						"Computador"
		label var  live_mother`grade' 					"Mora com a mãe"
		label var  mother_literate`grade' 				"Mão escreve"
		label var  mother_reads`grade' 					"Mãe lê"
		label var  live_father`grade' 					"Mora com o pai"
		label var  father_literate`grade' 				"Pai escreve"
		label var  father_reads`grade' 					"Pai lê"
		label var  wash_mash`grade' 					"Máquinha de lavar"
		label var  mother_edu_highschool`grade' 		"Mãe com ensino médio completo"
		label var  work`grade'  						"Trabalho"
		label var  preschool`grade' 					"Pré-escola"
		label var  ever_repeated`grade' 				"Já repetiu"
		label var  ever_dropped`grade' 					"Já abandonou"
		label var  maid`grade'							"Empregada doméstica"		
		label var  number_repetitions`grade'			"Número de reprovações"
		label var  private_school`grade'    			"Já estudou em escola particular"
		label var  incentive_study`grade'      			"Incentivo a estudar"
		label var  incentive_homework`grade'       		"Incentivo a fazer o dever de casa"
		label var  incentive_read`grade'      			"Incentivo a ler"
		label var  incentive_school`grade'       		"Incentivo a ir às aulas"
		label var  incentive_talk`grade'      			"Conversa sobre acontecimentos na escola "
		label var  male`grade'							"Meninos"
		label var  white`grade'							"Brancos"
		
	}
	
	foreach x in 5 9 {
		label var math`x'        						"Matemática, `x'o ano"
		label var port`x' 		 						"Português, `x'o ano"
	}
	
	foreach x in EF1 EF2 {
		label var ideb`x'   	  	 					"IDEB `x'"
	}
	
	foreach x in EF EF1 EF2  {
		label var repetition`x' 	 					"Reprovação no `x'"
		label var dropout`x' 		 					"Abandono no `x'"
	}
	
	forvalues x = 1/9 {
		label var approval`x'	 						"Aprovação no `x'o ano"
		label var repetition`x' 						"Reprovação no  `x'o ano"
		label var dropout`x'	 						"Abandono no `x'o ano"
	}

		label var r_ind_49 								"Investimento educacional por aluno do EF, em R$ de 2018"
		label var codschool								"Código INEP da Escola"
		label var year 									"Ano"
		label var network 								"=3, escolas municipais"
		label var location								"1 se urbana e 2 se rural"
		label var treated 								"1 para municípios que adiaram o retorno às aulas"
		label var coduf 								"Código da UF"
		label var uf 									"Sigla da UF"
		label var codmunic								"Código do município"
		label var codmunic2 							"Código do município, 6 digitos"
		label var pop 									"População"
		label var n_munic								"Nome do município"
		label var operation 							"1 escolas em atividade em t, 2 escolas fora de atividade, 3 escolas extintas e 4 escolas extintas no ano anterior"
		label var cinicio_letivo 						"Início do ano letivo"
		label var cfim_letivo 							"Fim do ano letivo"
		label var dia_fim_letivo 						"Dia em que terminou o ano letivo"
		label var mes_fim_letivo						"Mês em que terminou o ano letivo"
		
		**Labels em ingles
		label var math5									"Proficiency in Math [SAEB scale 0 to 350] " 
		label var port5									"Proficiency in Portuguese [SAEB scale 0 to 325]" 
		label var repetition5 							"Repetition rate" 
		label var dropout5 								"Dropout rate" 
		label var approval5 							"Approval rate" 
		label var incentive_study5 						"% of students whose parents incentive to study" 
		label var incentive_homework5					"% of students whose parents incentive to do the homework" 
		label var incentive_read5						"% of students whose parents incentive to read"
		label var incentive_school5 					"% of students whose parents incentive to go to school"
		label var white5 								"% of white students" 
		label var male5 								"% of boys" 
		label var live_mother5 							"% that lives with their mothers" 
		label var computer5 							"% with computer at home" 
		label var mother_edu_highschool5 				"% of mothers with high school degree" 
		label var preschool5 							"% students that did preschool"
		label var ever_repeated5 						"% students that already repeated one grade"
		label var ever_dropped5 						"% students that already dropout school before"
		label var work5 								"% students that work"
		label var ComputerLab 							"% of schools with computer lab"
		label var ScienceLab 							"% of schools with science lab"
		label var Library 								"% of schools with library"
		label var InternetAccess 						"% of schools internet access"
		label var SportCourt 							"% of schools sport court"
		label var enrollment5 							"Enrollment at school level"
		label var classhour5 							"Class hours per day"
		label var tclass5 								"Students per class"
		label var pop									"Population of the municipality, in thousands"
		label var pib_pcap								"GDP per capita of the municipality, in 2019 BRL"
		label var enrollmentTotal						"Total enrollment"
		label var teacher_more10yearsexp5 				"% teachers with more than 10 years of experience"
		label var teacher_college_degree5 				"% teachers with Tertiary Education"
		label var teacher_tenure5 						"% teachers with tenure"
		label var teacher_less_40years5 				"% teachers with less than 40 years old"
		label var principal_effort_index5 				"Principal Effort Index according to teacher's perspective"
		label var student_effort_index5 				"Student Effort Index according to teacher's perspective"
		label var violence_index5 						"Violence in the school according to teacher's perspective"
		label var almost_all_finish_grade95 			"% teachers that believe almost all students will finish 9th grade"
		label var almost_all_finish_highschool5 		"% teachers that believe almost all students will finish high school"
		label var almost_all_get_college5 				"% teachers that believe almost all students will get to college"
		label var covered_curricula45 					"% teachers that covered more than 80% of the curricula"
		label var participation_decisions45 			"% teachers that always participate in the decisions regarding their work"
		label var share_students_books55 				"% schools in which all the students have the textbooks"
		label var quality_books45 						"% schools in which teachers classify textbooks as great"
		label var principal_college_degree 				"% principals with Tertiary Education"
		label var teachers_training4 					"% schools in which more than half of the teachers participated of training"
		label var principal_selection_work4 			"% schools in which the principal was appointed without a  selection criteria"
		label var absenteeism_teachers3		    		"% schools in which teacher absenteeism is a moderate/big issue"
		label var absenteeism_students3 				"% schools in which student absenteeism is a moderate/big issue"
		label var classrooms_similar_ages 				"% schools in which classrooms are formed based on age"
		label var classrooms_het_performance			"% schools in which classrooms are formed based on performance heterogeneity"
		label var teachers_turnover3					"% schools in which teacher turnover is a moderate/big issue"		
		label var lack_books							"% schools with lack of textbooks" 
		label var org_training 							"% schools with teacher's training"
				
		foreach grade in 5 9 {
		label var T2009_principal_int`grade'			"Shutdown versus mother's education"
		label var T2009_teacher_tenure_int`grade' 		"Shutdown versus teacher's tenure"
		label var T2009_absenteeism_teachers_int`grade'	"Shutdown versus teacher's absenteeism"
		label var T2009_spt_int`grade'					"Shutdown versus students per teacher"
		}	

		label var T2007 "2007 versus 2005"
		label var T2009 "2009 versus 2007"
		
		sort 	codschool year
		xtset 	codschool year 	
		compress
		
	save "$final/Performance & Socioeconomic Variables of SP schools.dta", replace
