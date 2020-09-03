
**SCHOOL DATASET		
*------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------*


*1* 
*Socioeconomic characteristics at school level																													
*------------------------------------------------------------------------------------------------------------------------*
	
	*2007 & 2009
	*--------------------------------------------------------------------------------------------------------------------*
	*use 	   "$provabrasil/Socioeconomic Characteristics at student level.dta", clear
	*keep 	    if coduf == 35 & (network == 3 | network == 2) & !missing(codschool)
	*save 	   "$inter/Socioeconomic Characteristics at student level.dta", replace
	use 	   "$inter/Socioeconomic Characteristics at student level.dta", clear
	collapse   (mean) $socioeco_variables, by(grade year codschool)
	foreach var of varlist $socioeco_variables100 {
		replace `var' = `var'*100 
		format  `var' %4.2fc
	}
	format SIncentive* parentsincentive_* nrepetition_ ndropout_ math* port* %4.2fc
	reshape 	wide  $socioeco_variables, i(year codschool) j(grade)
	tempfile    socio_economic
	save       `socio_economic'

	
*2* 
*Flow Indicators																											
*------------------------------------------------------------------------------------------------------------------------*
	*use 	   "$rendimento/Flow Indicators at school level.dta", clear
	*keep 	    if uf == "SP" & (network == 3 | network == 2) & !missing(codschool)
	*save 	   "$inter/Flow Indicators at school level.dta", replace
	use 	   "$inter/Flow Indicators at school level.dta", clear
	drop 		*EM*
	tempfile    flow_index
	save       `flow_index'
	
	
*3* 
*School Infrastructure																									
*------------------------------------------------------------------------------------------------------------------------*
	*use 	   "$censoescolar/School Infrastructure at school level.dta", clear
	*keep 	    if uf == "SP" & (network == 3 | network == 2) & !missing(codschool)
	*save 	   "$inter/School Infrastructure at school level.dta", replace
	use 	   "$inter/School Infrastructure at school level.dta", clear
	keep 		$matching_schools year codschool coduf uf codmunic codmunic2 operation network location cfim_letivo cinicio_letivo mes_fim_letivo dia_fim_letivo CICLOS
	foreach var of varlist $matching_schools {
		replace `var' = `var'*100
	}
	tempfile    school_infra
	save       `school_infra'
	
	
*4* 
*Enrollments																								
*------------------------------------------------------------------------------------------------------------------------*
   *use 	   "$censoescolar/Enrollments at school level.dta", clear
   *keep 		if uf == "SP"
   *collapse 	(sum)$matriculas (mean)school_*, by(year codschool codmunic network)
   *save	   "$inter/Enrollments at school level.dta", replace
	use 	   "$inter/Enrollments at school level.dta", clear
	foreach var of varlist enrollment* {
		replace `var' = . if `var' == 0
	}
	keep 	    if (network == 3 | network == 2)  & !missing(codschool)
	keep 		year codschool enrollment5grade network
	tempfile    enrollments
	save       `enrollments'	
	
	
*5* 
*Class-hours																								
*------------------------------------------------------------------------------------------------------------------------*
   *use 	   "$censoescolar/Class-Hours at school level.dta", clear
   *keep 	    if uf == "SP" & (network == 3 | network == 2) & !missing(codschool)
   *save 	   "$inter/Class-Hours at school level.dta", replace
	use 	   "$inter/Class-Hours at school level.dta", clear
	keep 		classhour5grade year codschool
	tempfile    class_hours
	save       `class_hours'	
	
	
*6* 
*Size of the classrooms																						
*------------------------------------------------------------------------------------------------------------------------*
    *use 	   "$censoescolar/Class-Size at school level.dta", clear
    *keep 	    if uf == "SP" & (network == 3 | network == 2) & !missing(codschool)
    *save 	   "$inter/Class-Size at school level.dta", replace
	use 	   "$inter/Class-Size at school level.dta", clear
	keep 		tclass5grade year codschool
	tempfile    class_size
	save       `class_size'	
	
	
*7*
*Expenditure per student																						
*------------------------------------------------------------------------------------------------------------------------*
   *use 	   "$fnde/FNDE Indicators.dta", clear
   *keep 	    if (network == 3 | network == 2) & coduf == 35
   *save 	   "$inter/FNDE Indicators.dta", replace
	use 	   "$inter/FNDE Indicators.dta", clear
	keep 	    year codmunic2 ind_49 r_ind_49 //r_ind_49 gasto por aluno do EF em R$ de 2018
	tempfile    expenditure
	save       `expenditure'	
	

*8* 
*IDEB school level
*------------------------------------------------------------------------------------------------------------------------*
   use 		"$ideb/IDEB at school level.dta", clear
   *keep 	 	if uf == "SP" & (network == 3 | network == 2) & !missing(codschool)
   *save		"$inter/IDEB at school level.dta", replace
	use 		"$inter/IDEB at school level.dta", clear
	foreach var of varlist approval* {
		replace `var' = `var'*100
	}
	keep 		if year == 2005 | year == 2007 | year == 2009 | year == 2011 | year == 2013 | year == 2015
	rename 		(spEF1 spEF2) (sp5 sp9)
	drop 		flowindexEF* target* 
	tempfile    ideb
	save       `ideb'
	
	*List of schools included in Prova Brasil
	*--------------------------------------------------------------------------------------------------------------------*
	duplicates drop codschool, force
	keep 	 codschool
	tempfile data
	save 	`data'

	
*9* 
*Performance + school infrastructure + socioeconomic characteristics + GeoCodes + pib per capita + expenditure per student	
*------------------------------------------------------------------------------------------------------------------------*
	use 	`flow_index', clear
	drop 	approval*
	merge   1:1 codschool year using `school_infra'	 			, nogen
	merge   1:1 codschool year using `enrollments'	 			, nogen keepusing(enrollment5grade)
	merge   1:1 codschool year using `class_hours'	 			, nogen keepusing(classhour5grade)
	merge   1:1 codschool year using `class_size'	 			, nogen keepusing(tclass5grade)
	merge 	1:1 codschool year using `ideb'						, nogen
	merge 	1:1 codschool year using `socio_economic'			, nogen 
	merge   m:1 codmunic2 year using `expenditure'   			, nogen 
	merge   m:1 codmunic  year using "$inter/GDP per capita.dta", nogen keep(1 3) keepusing(pib_pcap pop)
	merge 	m:1 codschool 	   using `data'						, nogen keep(3) //para manter somente as escolas que estao na base da Prova Brasil
	sort 	codschool year 
	xtset   codschool year  
	
	
	
*------------------------------------------------------------------------------------------------------------------------*
	foreach var of varlist *grade {
		local newname  = substr("`var'",1, length("`var'")-5)
		rename `var'  `newname'
	}
	foreach var of varlist math5 port5 idebEF1 math9 port9 idebEF2 sp5 sp9 {                                    	
		gen padr_`var' = .
		gen def_`var'  = .
	}
	forvalues year = 2005(2)2013 {
		foreach var of varlist math5 port5 idebEF1 math9 port9 idebEF2 sp5 sp9 {           		//variables standartization
			sum    `var' 									  if year == `year', detail
			replace padr_`var' = (`var' - `r(mean)')/ `r(sd)' if year == `year',
		}
	}
	sort	codschool year
	foreach var of varlist math5 port5 idebEF1 math9 port9 idebEF2 sp5 sp9 {
		replace	def_`var' = `var'[_n-2] if codschool[_n] == codschool[_n-2] & year[_n] == year[_n-2] + 2 & year >= 2009
		replace	def_`var' = `var'[_n-1] if codschool[_n] == codschool[_n-1] & year[_n] == year[_n-1] + 2 & year == 2007
	}
	format  padr_* def_* %4.2fc	
		
		
*GEOCODES
*------------------------------------------------------------------------------------------------------------------------*
	merge m:1 codmunic using "$geocodes/mun_brasil.dta", nogen keep(1 3)
	keep if SIGLA == "SP"
		
		
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
	
	replace offers_ef1 = . if year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016
	replace offers_ef2 = . if year == 2008 | year == 2010 | year == 2012 | year == 2014 | year == 2016
	
	rename id _ID
	save "$final/Performance & Socioeconomic Variables of SP schools.dta", replace


	* ------------------------------------------------------------------------------------------------------------------ *
	gen 	pop_2007 = pop if year == 2007
	bys 	codmunic: egen max = max(pop_2007)
	drop 	pop_2007
	rename  max pop_2007
	
	*gen 	mat_pop = enrollmentEF/pop //matriculas a cada 1000 habitantes
	*format  mat_pop %4.2fc	
	
	
	* ------------------------------------------------------------------------------------------------------------------ *
	foreach grade in 5 9 {
		egen port_basic_more_`grade' = rowtotal(port_basic_`grade' port_adequ_`grade'), missing
		egen math_basic_more_`grade' = rowtotal(math_basic_`grade' math_adequ_`grade'), missing
	}
	
	
	* ------------------------------------------------------------------------------------------------------------------ *
	bys year: quantiles math5, gen(q_math5) stable nq(9)
	bys year: quantiles port5, gen(q_port5) stable nq(9)

	su 		mother_edu_5 		if year == 2009, detail
	gen 	T2009_maeE  	= year == 2009  & treated == 1 & mother_edu_5 >  r(p50) & mother_edu_5 != .
	gen 	T2009_maeNE 	= year == 2009  & treated == 1 & mother_edu_5 <= r(p50)
	replace T2009_maeE 		= . if missing(mother_edu_5) 
	replace T2009_maeNE 	= . if missing(mother_edu_5) 
	gen 	T2009_tclass 	= 1*tclass5	 	if year == 2009  & treated == 1
	replace T2009_tclass 	= 0 if missing(T2009_tclass) & !missing(tclass5)
	gen 	T2009_hours  	= 1*classhour5 	if year == 2009  & treated == 1
	replace T2009_hours 	= 0 if missing(T2009_hours)  & !missing(classhour5)
	
	* ------------------------------------------------------------------------------------------------------------------ *
	drop    region municipality SIGLA NOME_MUNIC NOME_MESO NOME_MICRO
	sort 	codschool year 
	order   codschool year network location treated  coduf uf codmunic codmunic2 n_munic pop pib_pcap ind_49 r_ind_49  operation cinicio_letivo cfim_letivo dia_fim_letivo mes_fim_letivo CICLOS math5 port5 math9 port9 padr_math5 padr_port5 def_math5 def_port5 padr_math9 padr_port9  def_math9 def_port9 
	rename (y_stub-MICRORREGI) (y_stub regiao meso_regiao micro_regiao)
	format pop %20.0fc
	
	*Labels
	* ------------------------------------------------------------------------------------------------------------------ *
	foreach grade in 5 9 {
		label var  tv_`grade'				"TV"
		label var  stereo_`grade' 			"Equipamento de som"
		label var  dvd_`grade' 				"DVD"
		label var  refri_`grade' 			"Geladeira"
		label var  car_`grade' 				"Carro"
		label var  computer_`grade' 		"Computador"
		label var  livesmother_`grade' 		"Mora com a mãe"
		label var  motherwrites_`grade' 	"Mão escreve"
		label var  motherreads_`grade' 		"Mãe lê"
		label var  livesfather_`grade' 		"Mora com o pai"
		label var  fatherwrites_`grade' 	"Pai escreve"
		label var  fatherreads_`grade' 		"Pai lê"
		label var  parentsincentive_`grade' "Incentivo dos pais"
		label var  washingmachine_`grade' 	"Máquinha de lavar"
		label var  mother_edu_`grade' 		"Mãe com ensino médio completo"
		label var  studentwork_`grade'  	"Trabalho"
		label var  preschool_`grade' 		"Pré-escola"
		label var  repetition_`grade' 		"Já repetiu"
		label var  dropout_`grade' 			"Já abandonou"
		label var  maid_`grade'				"Empregada doméstica"		
		label var  nrepetition_`grade'		"Número de reprovações"
		label var  ndropout_`grade' 		"Número de abandono" 
		label var  privateschool_`grade'    "Já estudou em escola particular"
		label var  SIncentive1_`grade'      "Comparecimento à reunião de pais"
		label var  SIncentive2_`grade'      "Incentivo a estudar"
		label var  SIncentive3_`grade'      "Incentivo a fazer o dever de casa"
		label var  SIncentive4_`grade'      "Incentivo a ler"
		label var  SIncentive5_`grade'      "Incentivo a ir às aulas"
		label var  SIncentive6_`grade'      "Conversa sobre acontecimentos na escola "
		label var  female_`grade'			"Meninas"
		label var  white_`grade'			"Brancos"	
		label var  timetv1_`grade'			"Uma hora ou menos de TV por dia"
		label var  timetv2_`grade'			"Duas horas de TV por dia"
		label var  timetv3_`grade'			"Três horas de TV por dia"
		label var  timetv4_`grade'			"Quatro horas ou mais de TV por dia"
		label var  cleanhouse1_`grade'		"Não ajuda nos afazeres domésticos"
		label var  cleanhouse2_`grade'		"Uma hora com afazeres domésticos"
		label var  cleanhouse3_`grade'		"Duas horas com afazeres domésticos"
		label var  cleanhouse4_`grade'		"Três horas com afazeres domésticos"
		label var  cleanhouse5_`grade'		"Quatro horas com afazeres domésticos"
		label var  portlesson1_`grade'		"Não faz o dever de português"
		label var  portlesson2_`grade'		"Sempre ou quase sempre faz o dever de português"
		label var  portlesson3_`grade'		"De vez em quando faz o dever de português"
		label var  mathlesson1_`grade'		"Não faz o dever de matemática"
		label var  mathlesson2_`grade'		"Sempre ou quase sempre faz o dever de matemática"
		label var  mathlesson3_`grade'		"De vez em quando faz o dever de matemática"
	}
	
	foreach x in 5 9 {
		label var math`x'        			"Matemática, `x'o ano"
		label var port`x' 		 			"Português, `x'o ano"
		label var padr_math`x' 	 			"Matemática padronizada, `x'o ano"
		label var padr_port`x'	 			"Português padronizada, `x'o ano"
		*label var padr_repetition`x' 	 	"Reprovação padronizada, `x'o ano"
		*label var padr_dropout`x'	 		"Abandono padronizada, `x'o ano"
		*label var padr_approval`x'	 		"Aprovação padronizada, `x'o ano"
		label var def_math`x'	 			"Matemática em t-2, `x'o ano"
		label var def_port`x'	 			"Português em t-2, `x'o ano"
		*label var def_repetition`x'	 	"Reprovação em t-1, `x'o ano"
		*label var def_dropout`x'	 		"Abandono em t-1, `x'o ano"
		*label var def_approval`x'	 		"Aprovação em t-1, `x'o ano"		
	}
	
	foreach x in EF1 EF2 {
		label var ideb`x'   	  	 		"IDEB `x'"
		label var padr_ideb`x'    	 		"IDEB padronizado `x'"
		label var def_ideb`x'     	 		"IDEB t-2 `x'"
	}
	
	foreach x in EF EF1 EF2  {
		label var repetition`x' 	 		"Reprovação no `x'"
		label var dropout`x' 		 		"Abandono no `x'"
	}
	
	forvalues x = 1/9 {
		label var approval`x'	 			"Aprovação no `x'o ano"
		label var repetition`x' 			"Reprovação no  `x'o ano"
		label var dropout`x'	 			"Abandono no `x'o ano"
	}

		label var r_ind_49 					"Investimento educacional por aluno do EF, em R$ de 2018"
		label var meso_regiao 				"Mesoregião"
		label var micro_regiao 				"Microregião"
		label var codschool					"Código INEP da Escola"
		label var year 						"Ano"
		label var network 					"=3, escolas municipais"
		label var location					"1 se urbana e 2 se rural"
		label var treated 					"1 para municípios que adiaram o retorno às aulas"
		label var coduf 					"Código da UF"
		label var uf 						"Sigla da UF"
		label var codmunic					"Código do município"
		label var codmunic2 				"Código do município, 6 digitos"
		label var pop 						"População"
		label var n_munic					"Nome do município"
		label var operation 				"1 escolas em atividade em t, 2 escolas fora de atividade, 3 escolas extintas e 4 escolas extintas no ano anterior"
		label var cinicio_letivo 			"Início do ano letivo"
		label var cfim_letivo 				"Fim do ano letivo"
		label var dia_fim_letivo 			"Dia em que terminou o ano letivo"
		label var mes_fim_letivo			"Mês em que terminou o ano letivo"
		
		**Labels em ingles
		label var math5 					"Proficiency in Math [SAEB scale 0 to 350] " 
		label var port5 					"Proficiency in Portuguese [SAEB scale 0 to 325]" 
		label var repetition5 				"Repetition rate" 
		label var dropout5 					"Dropout rate" 
		label var approval5 				"Approval rate" 
		label var SIncentive2_5 			"% of students whose parents incentive to study" 
		label var SIncentive3_5				"% of students whose parents incentive to do the homework" 
		label var SIncentive4_5 			"% of students whose parents incentive to read"
		label var SIncentive5_5 			"% of students whose parents incentive to go to school"
		label var white_5 					"% of white students" 
		label var livesmother_5 			"% that lives with their mothers" 
		label var computer_5 				"% with computer at home" 
		label var mother_edu_5 				"% of mothers with high school degree" 
		label var preschool_5 				"% students that did preschool"
		label var repetition_5 				"% students that already repeated one grade"
		label var dropout_5 				"% students that already dropout school before"
		label var studentwork_5 			"% students that work"
		label var ComputerLab 				"% of schools with computer lab"
		label var ScienceLab 				"% of schools with science lab"
		label var Library 					"% of schools with library"
		label var InternetAccess 			"% of schools internet access"
		label var SportCourt 				"% of schools sport court"
		label var enrollment5 				"Enrollment at school level"
		label var classhour5 				"Class hours per day"
		label var tclass5 					"Students per class"
		label var pop						"Population of the municipality, in thousands"
		label var pib_pcap					"GDP per capita of the municipality, in 2019 BRL"
		
		label var T2007 "2007 versus 2005"
		label var T2009 "2009 versus 2007"
		
		drop 	regiao  n_munic CICLOS operation def_idebEF1 padr_idebEF1 padr_idebEF2 def_idebEF2 school location
		sort 	codschool year
		xtset 	codschool year 	
		compress
		
	save "$final/Performance & Socioeconomic Variables of SP schools.dta", replace
