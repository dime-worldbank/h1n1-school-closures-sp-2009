	
	**
	*This do file imports and harmonizes Censo Escolar Data
	**
	*________________________________________________________________________________________________________________________________* 

	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing Census Data
	**
	*________________________________________________________________________________________________________________________________* 

	..
	{
	
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing 2005 data.
	**
	*________________________________________________________________________________________________________________________________* 
		do "$dofiles/Dictionaries/0. CensoEscolar_2005.do"


	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing School Infrastructure (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009 {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Escolas.do"
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing Classrooms Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009  {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Turmas.do"
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing Teacher Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009  {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Professores.do"
		}

		
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Importing Enrollment Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009 {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Matrículas.do"
		}
		
	..	
	}	
	..	
	
	
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Program to format School Census Data
	**
	*________________________________________________________________________________________________________________________________* 
	..
	{
	
		**
		**
		**We use the program below across all harmonization of School Census Data
		cap program drop formatting
		program define   formatting
			
			**
			**Brazilian states: codes and names
			**
			#delimit ;
			gen 		uf = "RO" if coduf == 11; replace uf = "AC" if coduf == 12; replace uf = "AM" if coduf == 13; replace uf = "RR" if coduf == 14;
			replace 	uf = "PA" if coduf == 15; replace uf = "AP" if coduf == 16; replace uf = "TO" if coduf == 17; replace uf = "MA" if coduf == 21;
			replace 	uf = "PI" if coduf == 22; replace uf = "CE" if coduf == 23; replace uf = "RN" if coduf == 24; replace uf = "PB" if coduf == 25;
			replace 	uf = "PE" if coduf == 26; replace uf = "AL" if coduf == 27; replace uf = "SE" if coduf == 28; replace uf = "BA" if coduf == 29;
			replace 	uf = "MG" if coduf == 31; replace uf = "ES" if coduf == 32; replace uf = "RJ" if coduf == 33; replace uf = "SP" if coduf == 35;
			replace		uf = "PR" if coduf == 41; replace uf = "SC" if coduf == 42; replace uf = "RS" if coduf == 43; replace uf = "MS" if coduf == 50;
			replace 	uf = "MT" if coduf == 51; replace uf = "GO" if coduf == 52; replace uf = "DF" if coduf == 53;
			#delimit cr
			
			label 		define state 	11 "RO" 12 "AC" 13 "AM" 14 "RR" 15 "PA" 16 "AP" 17 "TO"  							///
										21 "MA" 22 "PI" 23 "CE" 24 "RN" 25 "PB" 26 "PE" 27 "AL" 28 "SE" 29 "BA" 			///
										31 "MG" 32 "ES" 33 "RJ" 35 "SP" 													///
										41 "PR" 42 "SC" 43 "RS" 															///
										50 "MS" 51 "MT" 52 "GO" 53 "DF"
			label 		val    coduf state
			
			**
			**
			gen 	 	codmunic2 = substr(string(codmunic), 1,6)
			destring 	codmunic2, replace
			
			**
			**
			label 	 	define network  1 "Federal"           2 "State" 			 3 "Municipal" 			4 "Private"
			label 	 	define location 1 "Urban"             2 "Rural"
			
			**
			**
			label 	 	val    location location
			label 		val    network  network
			
		end	
		
	}	
	
	
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Harmonizing School Infrastructure 
	**
	*________________________________________________________________________________________________________________________________* 
		
		
		**
		*----------------->>
		*2005
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		
		..
		{
		use 		"$inter/CensoEscolar2005", clear
		
			merge 		1:1 MASCARA using "$inter/Máscara2005.dta", nogen 			//code of the schools
			gen 		codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
			gen 		coduf 	 = substr(codmunic,1,2)
			
			*=====================>
			keep 		if coduf == "35"   			//Sao Paulo
			*=====================>
			
			**
			**
			drop 	 	MASCARA CODMUNIC DE9F11G-NE9F117
			rename 		(ANO-S_CONEX) ///
						(year network location ComputerLab ScienceLab ClosedSportCourt OpenedSportCourt Library ReadingRoom InternetAccess) 
			
			**
			**
			replace 	network  = "2" if network  == "Estadual"
			replace 	network  = "3" if network  == "Municipal"
			replace 	network  = "4" if network  == "Particular"
			replace 	network  = "1" if network  == "Federal"
			
			**
			**
			replace 	location = "1" if location == "Urbana"
			replace 	location = "0" if location == "Rural"
			
			**
			**
			foreach 	 var of varlist ComputerLab-InternetAccess {
			replace 	`var' = "0" if `var' == "n"
			replace 	`var' = "1" if `var' == "s"
			}
			
			**
			**
			destring, 	replace
			
			**
			**
			gen			SportCourt = 1 if ClosedSportCourt == 1 | OpenedSportCourt == 1
			replace 	SportCourt = 0 if ClosedSportCourt == 0 & OpenedSportCourt == 0
			
			**
			**
			compress
			save		"$inter/Escolas2005.dta", replace
			
		..	
		}
		
		**
		*----------------->>
		*2007, 2008, 2009
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		..
		{
		
		forvalues year = 2007/2009 {
			
			use "$inter/Escolas`year'.dta", clear
			
			**
			**
			if `year' == 2007 {
				keep 		ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				order 		ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				
				**
				**
				rename 	   (ANO_CENSO-ID_ALIMENTACAO) ///
						   (year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	SchoolEmployees	MealsForStudents) 
				destring, 	replace
				
				**
				**
				gen 		operation2   = 1 if operation == "EM ATIVIDADE"
				replace 	operation2   = 2 if operation == "PARALISADA" 
				replace 	operation2   = 3 if operation == "EXTINTA" 
				drop 		operation
				rename  	operation2 operation
			}
			
			**
			**
			if `year' == 2008 {
				keep    	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				order   	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				
				**
				**
				rename 	   (ANO_CENSO-ID_ALIMENTACAO)  ///
				           (year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	BroadBandInternet SchoolEmployees	MealsForStudents) 
				destring, 	replace
			}
			
			**
			**
			if `year' == 2009 {
				keep    	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	ID_SALA_LEITURA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA	NUM_FUNCIONARIOS	ID_ALIMENTACAO		DT_ANO_LETIVO_INICIO DT_ANO_LETIVO_TERMINO ID_FUND_CICLOS
				order  	 	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	ID_SALA_LEITURA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA	NUM_FUNCIONARIOS	ID_ALIMENTACAO		DT_ANO_LETIVO_INICIO DT_ANO_LETIVO_TERMINO ID_FUND_CICLOS
				
				**
				**
				rename 	   (ANO_CENSO-ID_FUND_CICLOS) ///
						   (year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	ReadingRoom	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	BroadBandInternet	SchoolEmployees	MealsForStudents	inicio_letivo        fim_letivo CICLOS)
				destring, 	replace
				
				**
				**
				replace 	FilteredWater       = 0 if FilteredWater == 1
				replace 	FilteredWater       = 1 if FilteredWater == 2
				replace 	inicio_letivo 		= substr(inicio_letivo, 1, 9)
				replace 	fim_letivo    		= substr(fim_letivo   , 1, 9)
					
				**
				**
				foreach 	  var of varlist *letivo {
				gen  		c`var' = date(`var', "DMY")
				drop 		 `var'
				}
				gen 		dia_fim_letivo 			= day(  cfim_letivo)
				gen 		mes_fim_letivo 			= month(cfim_letivo)
				format  	cinicio_letivo cfim_letivo %td
			}
			
			*=====================>
			keep if coduf == 35  				//Sao Paulo
			*=====================>

				**
				**
				gen 		Computer 		    = (NumberComputer >  0 & !missing(NumberComputer))
				replace 	Computer		    = . if 					  missing(NumberComputer)
				gen			WaterAccess  	    = (WaterAccess1  == 0)
				gen 		EnergyAccess 	    = (EnergyAccess1 == 0)
				gen 		SewerAccess  	    = (SewerAccess1  == 0)
				foreach 	var of varlist  WaterAccess EnergyAccess SewerAccess {
				replace    `var' = . 				if `var'1   == .
				}
				replace  	location 			= 0 if location == 2
				
				**
				**
				compress
				save "$inter/Escolas`year'.dta", replace
		}
		
		..
		}
		
		
		**
		**-> Appending 2005 to 2009
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		.. 
		{
			
			clear
			foreach year in 2005 2007 2008 2009 {
				append using "$inter/Escolas`year'.dta"
				erase   	 "$inter/Escolas`year'.dta"
			}
			
				**
				**
				label var OwnBuilding 			"Prédio próprio"
				label var location  			"Urbana"
				label var FilteredWater 		"Água filtrada"
				label var WasteCollection		"Coleta de lixo"
				label var ComputerLab			"Laboratório de informática"
				label var ScienceLab			"Laboratório de ciências"
				label var SportCourt			"Quadra de esportes"
				label var Library				"Biblioteca"
				label var InternetAccess		"Acesso à internet"
				label var MealsForStudents		"Refeição para os alunos"
				label var EnergyAccess			"Energia elétrica"
				label var SewerAccess			"Saneamento básico"
				
				**
				**
				formatting
			
				order 		year coduf uf codmunic codmunic2 codschool  operation network location cfim_letivo cinicio_letivo dia_fim_letivo mes_fim_letivo CICLOS
				
				keep 		year-CICLOS ComputerLab ScienceLab ReadingRoom InternetAccess SportCourt FilteredWater 				 			///
							WasteCollection WasteRecycling PrincipalRoom TeacherRoom Kitchen TotalClasses NumberComputer				 	///
							SchoolEmployees MealsForStudents Computer WaterAccess EnergyAccess SewerAccess  BroadBandInternet Library	
				
				
				**
				**
				label 		define yesno 1 "Yes" 0 "No"
				foreach 	 var 						of varlist ComputerLab-Kitchen MealsForStudents-BroadBandInternet Library {
				label 	val `var'  yesno
				}
				
				**
				**
				label	 	define operation 1 "Em atividade" 2 "Paralisada" 3  "Extinta" 4 "Extinta no ano anterior" 
				label 	val    	   operation operation
				
				**
				**
				sort  	codschool year
				compress
				save "$inter/School Infrastructure.dta", replace
				
		}


	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Harmonizing Classrooms Data
	**
	*________________________________________________________________________________________________________________________________* 

	
		**
		*----------------->>
		*2005
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		..
		{
		
		use 		"$inter/CensoEscolar2005", clear
			merge 		1:1 MASCARA using "$inter/Máscara2005.dta", nogen 
			gen 		codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
			gen 		coduf 	 = substr(codmunic,1,2)
			
			*=====================>
			keep 		if coduf == "35"   			//Sao Paulo
			*=====================>
			
			**
			**
			keep    	 ANO DEP LOC DE9F11G-NE9F117 codmunic codschool coduf
			rename 		(ANO DEP LOC) ///
						(year network location) 
				   
			**
			*Network
			**
			replace 	network  	  		= "2" if network  == "Estadual"
			replace 	network  	  		= "3" if network  == "Municipal"
			replace 	network  	  		= "4" if network  == "Particular"
			replace 	network  	  		= "1" if network  == "Federal"
			replace 	location 	  		= "1" if location == "Urbana"
			replace 	location 	  		= "0" if location == "Rural"

			destring, replace
			
			**
			*Matrículas, turmas de 5o ano e tamamho médio das turmas
			**
			egen 		turmas5 		  	= rowtotal(DEF116  NEF116  DE9F117 NE9F117) 			//numero de turmas
			egen 		enrollment5grade  	= rowtotal(DE9F11G NE9F11G DEF11F  NEF11F )			//total de matriculas, 5o ano aqui eh equivalente a 4a serie 
			gen  		tclass5grade 	  	= enrollment5grade/turmas5							//alunos por turma
			
			**
			**
			formatting	
			keep 		year network coduf uf codmunic codmunic2 codschool tclass5grade 
			
			**
			save 	"$inter/Turmas2005.dta", replace
		}
		
		
		**
		*----------------->>
		*2007, 2008, 2009
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		..
		{
		forvalues year = 2007/2009 {

			use "$inter/Turmas`year'.dta", clear

			keep    	ANO_CENSO	PK_COD_TURMA	NO_TURMA	HR_INICIAL	HR_INICIAL_MINUTO	NU_DURACAO_TURMA	NUM_MATRICULAS	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM 
			order   	ANO_CENSO	PK_COD_TURMA	NO_TURMA	HR_INICIAL	HR_INICIAL_MINUTO	NU_DURACAO_TURMA	NUM_MATRICULAS	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM 
			rename 	   (ANO_CENSO-ID_DEPENDENCIA_ADM)  ///
					   (year	codclass	class	begins	beginsminute	last	enrollments	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codschool	coduf	codmunic	location	network)
			destring, replace 
			
			*=====================>
			keep if coduf == 35   			//Sao Paulo
			*=====================>

			gen 		tclassEI        = 1 if  FK_COD_ETAPA_ENSINO == 1   | FK_COD_ETAPA_ENSINO  == 2   | FK_COD_ETAPA_ENSINO == 3
			gen 		tclassEF1 		= 1 if (FK_COD_ETAPA_ENSINO >= 4   & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
			gen 		tclassEF2 		= 1 if (FK_COD_ETAPA_ENSINO >= 8   & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | (FK_COD_ETAPA_ENSINO == 41)
			gen 		tclass5grade 	= 1 if (FK_COD_ETAPA_ENSINO == 7   | FK_COD_ETAPA_ENSINO == 18)
			gen 		tclass9grade 	= 1 if (FK_COD_ETAPA_ENSINO == 11  | FK_COD_ETAPA_ENSINO == 41)
			gen 		tclassEF  		= 1 if tclassEF1 == 1 | tclassEF2 == 1		
			
			**
			*Educação regular, educação especial e EJA
			**
			gen     	type = 1 if FK_COD_MOD_ENSINO == 1
			replace 	type = 2 if FK_COD_MOD_ENSINO == 2
			replace 	type = 3 if FK_COD_MOD_ENSINO == 3
			label 		define type 1 "Regular Education" 2 "Special Education" 3 "Adult Education" 
			label 		val    type type
			
			**
			**
			keep 		year codclass enrollments last coduf codmunic	location network type codschool tclass*
			compress
			
			**
			tempfile  Turmas`year'
			save 	 `Turmas`year''
			erase  	"$inter/Turmas`year'.dta"
		}
		
		..
		}
	

		**
		**Appending 2007 to 2009
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		..
		{
			clear
			foreach 	year in 2007 2008 2009 {		
						append using `Turmas`year''
			}
			
			**
			**
			compress
			
			**
			**
			formatting	
			
		..	
		}
		
		**
		**Class hour and class-size
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		{
		**
		*Turmas e suas respectivas matrículas para fazer o merge com as turmas que têm docentes com formação adequada e calcular a proporção de turmas que têm aulas com docentes com formação adequada. 
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			preserve
				keep 	if tclass5grade == 1
				keep 		codschool codclass year enrollments
				
				**
				**
				sort 		codschool codclass
				save 		"$inter/Relação de turmas por escola.dta", replace   
			restore
	
	
		**
		*Class hours and average size of the class
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			foreach 	grade in EI EF1 EF2 5grade 9grade EF {
				gen	 		classhour`grade' = last/60 			if tclass`grade' == 1 	//duração da aula, em horas
				replace	 	tclass`grade' 	 = enrollments 		if tclass`grade' == 1 	//número de alunos na turma
			}
			
			
		**
		*Collapsing by school
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			preserve
				collapse 	(mean) classhour* [aw = enrollments], by (year network coduf uf codmunic codmunic2 codschool)			//matrícula por turma foi utilizada como ponderador, de modo que turmas com mais alunos pesam mais na média da escola
				order 		year coduf uf codmunic codmunic2 codschool network
				format 		classhour* %4.2fc
				sort 		codschool year
				save  				"$inter/Class-Hours.dta", replace
			restore
			
			preserve
				collapse 	(mean) tclass*	   					 , by (year network coduf uf codmunic codmunic2 codschool)			//tamanho médio das turmas
				order 		year coduf uf codmunic codmunic2 codschool network
				format 		tclass* %4.2fcwww
				sort 		codschool year
				append 		using 	"$inter/Turmas2005.dta"
				save 		 		"$inter/Class-Size.dta", replace
				erase 		 		"$inter/Turmas2005.dta"
			restore
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Harmonizing Enrollment Data
	**
	*________________________________________________________________________________________________________________________________* 
		
		**
		*2005
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		{
		use 		"$inter/CensoEscolar2005", clear
			merge 		1:1 MASCARA using "$inter/Máscara2005.dta", nogen 
			gen 		codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
			gen 		coduf 	 = substr(codmunic,1,2)
			
			*=====================>
			keep 		if coduf == "35"   			//Sao Paulo
			*=====================>
			
			**
			**
			keep    	 ANO DEP LOC DE9F11G-NE9F117 codmunic codschool coduf
			rename 		(ANO DEP LOC) 											(year network location) 
			
			**
			**
			replace 	network  	  = "2" if network  == "Estadual"
			replace 	network  	  = "3" if network  == "Municipal"
			replace 	network  	  = "4" if network  == "Particular"
			replace 	network  	  = "1" if network  == "Federal"
			
			**
			**
			replace 	location 	  = "1" if location == "Urbana"
			replace 	location 	  = "0" if location == "Rural"

			**
			**
			destring, 	replace
			
			**
			**
			egen 		enrollment5grade = rowtotal(DE9F11G NE9F11G DEF11F NEF11F)			//o 5o ano aqui eh equivalente a 4a serie 
			egen 		enrollment9grade = rowtotal(DE9F11N NE9F11L DEF11J NEF11J)			//o 5o ano aqui eh equivalente a 4a serie 

			**
			**
			keep 		year network coduf codmunic codschool location enrollment*
			compress
			
			**
			save 		"$inter/Matrículas2005.dta", replace
		}
		
		**
		*2007, 2008, 2009
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		{
		forvalues 	year = 2007/2009 {
		
			foreach 	region in SP { // RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF
			 
			use 		"$inter/Matrículas`year'`region'.dta", clear
			
			**
			**
			set 		dp period
			keep    						 				   ANO_CENSO	PK_COD_MATRICULA	FK_COD_ALUNO	NU_DIA		NU_MES		NU_ANO		NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_TURMA    PK_COD_ENTIDADE	FK_COD_ESTADO_ESCOLA	COD_MUNICIPIO_ESCOLA	ID_LOCALIZACAO_ESC	ID_DEPENDENCIA_ADM_ESC	ID_N_T_E_P	
			order  											   ANO_CENSO	PK_COD_MATRICULA	FK_COD_ALUNO	NU_DIA		NU_MES		NU_ANO		NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_TURMA	PK_COD_ENTIDADE	FK_COD_ESTADO_ESCOLA	COD_MUNICIPIO_ESCOLA	ID_LOCALIZACAO_ESC	ID_DEPENDENCIA_ADM_ESC  ID_N_T_E_P	
			
			**
			**
			rename 		(ANO_CENSO-ID_N_T_E_P)  (year		codenrollment	codstudent			BirthDay	BirthMonth	Birthyear	age			gender	color		FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codclass		codschool		coduf					codmunic				location			network 				transporte )
			
			**
			**
			destring, 	replace  
			
			**
			*Enrollments by grade
			**
			*------------------------------------------------------------------------------------------------------------------------*
			gen 		enrollmentEI        = 1 if  FK_COD_ETAPA_ENSINO == 1  |  FK_COD_ETAPA_ENSINO  == 2
			gen 		enrollmentEF1 		= 1 if (FK_COD_ETAPA_ENSINO >= 4  & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
			gen 		enrollmentEF2 		= 1 if (FK_COD_ETAPA_ENSINO >= 8  & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | FK_COD_ETAPA_ENSINO == 41
			gen 		enrollment5grade 	= 1 if (FK_COD_ETAPA_ENSINO == 7  | FK_COD_ETAPA_ENSINO  == 18)
			gen 		enrollment9grade 	= 1 if (FK_COD_ETAPA_ENSINO == 11 | FK_COD_ETAPA_ENSINO  == 41)
			gen 		enrollmentEF  		= 1 if  enrollmentEF1 		== 1  | enrollmentEF2        == 1
			gen 		enrollmentEM  		= 1 if (FK_COD_ETAPA_ENSINO >= 25 & FK_COD_ETAPA_ENSINO  <= 29)
			gen 		enrollmentEMint   	= 1 if  FK_COD_ETAPA_ENSINO >= 30 & FK_COD_ETAPA_ENSINO  <= 34
			gen 		enrollmentEMmag  	= 1 if  FK_COD_ETAPA_ENSINO >= 35 & FK_COD_ETAPA_ENSINO  <= 38
			gen 		enrollmentEMconc    = 1 if  FK_COD_ETAPA_ENSINO == 39 | FK_COD_ETAPA_ENSINO  == 40  | FK_COD_ETAPA_ENSINO == 68  //Ensino técnico concomitante
			gen		 	enrollmentEMtec     = 1 if  enrollmentEMint 	== 1  | enrollmentEMconc     == 1								//Total Técnico
			gen 		enrollmentEMst      = 1 if  enrollmentEM  		== 1  | enrollmentEMmag      == 1								//Total EM "normal" + magistério
			gen 		enrollmentEMtotal 	= 1 if  enrollmentEMst 		== 1  | enrollmentEMtec      == 1 								//Total EM técnico + "normal" + magistério
			drop 		enrollmentEMint enrollmentEMmag enrollmentEMconc enrollmentEMtec  enrollmentEMst
			
			**
			*Educação regular, educação especial e EJA
			**
			*------------------------------------------------------------------------------------------------------------------------*
			gen 		type = 1 if FK_COD_MOD_ENSINO == 1
			replace 	type = 2 if FK_COD_MOD_ENSINO == 2
			replace 	type = 3 if FK_COD_MOD_ENSINO == 3
	
	
			**
			*Matrículas por escola
			**
			*------------------------------------------------------------------------------------------------------------------------*
			preserve
			
				collapse	 (sum) enrollment*, by (location network codschool codmunic coduf year) 
				
				**
				**
				compress
				save 		"$inter/Matrículas`year'`region'.dta", replace
			restore
			
			**
			*Difefença de idade entre o mais novo e o mais velho da turma //a ideia é ver se turmas com distinção muito alta sofreram mais com o fechamento das escolas
			**
			*------------------------------------------------------------------------------------------------------------------------*
			
			**
			keep 	if enrollment5grade == 1
			
			**
			tostring BirthDay	BirthMonth	Birthyear, force replace 
			
			replace  BirthDay   = "0" + BirthDay 					if length(BirthDay ) == 1
						
			replace  BirthMonth = "0" + BirthMonth					if length(BirthMonth) == 1

			egen 	 bd = concat(BirthDay BirthMonth Birthyear)

			gen 	 birth_date = date(bd,"DMY") 																																		//note that month is unknow, the Value is 20 and if the year is unknow the Value is the presumed age
					
			format 	 birth_date %td
				
			**
			drop 	 age
				
			gen 	 base_date 	= mdy(3,31,`year') 		
				
			**	
			gen 	 age 		= (base_date - birth_date)/365.25
			
			replace  age 		= . if age <   8		//outliers
			
			replace  age		= . if age >  18

			**
			gen 	 atraso5    = 1 if age >  11  & !missing(age)
			
			replace  atraso5 	= 0 if age <= 11		
			
			**
			gen 	 min_age = age
			gen 	 max_age = age
			 
			 
			**
			gen 		  		enrollment = 1
			collapse 	(sum)	enrollment  (max)max_age (min) min_age (mean)atraso5 , by (codclass codschool year network) 
				
			
			**
			gen 				dif_age_5grade = max_age -  min_age
			
			**
			collapse 	(mean)	dif_age_5grade atraso5 [w = enrollment], by(codschool year)		
			
			**
			merge 		1:1 	codschool year using "$inter/Matrículas`year'`region'.dta", nogen
			
			**
			compress
			save 						   			 "$inter/Matrículas`year'`region'.dta", replace
			
			}
		}
		}
		
		**
		**Appending enrollment 2005 to 2009
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		{
			clear 
			foreach 	year in 2007 2008 2009 {		
				foreach 	region in SP {
						append using "$inter/Matrículas`year'`region'.dta"
						erase   	 "$inter/Matrículas`year'`region'.dta"
				}
			}
						append using    "$inter/Matrículas2005.dta"
						erase 		 	"$inter/Matrículas2005.dta"
			
			**
			**
			replace 	location  = 2 if location == 0 & year == 2005
			
			**
			**
			gen  	school_EI           = (enrollmentEI 	 != 0)
			gen  	school_EF1          = (enrollmentEF1 	 != 0) 										     //identificação de escola de EF
			gen  	school_EF2          = (enrollmentEF2 	 != 0)										   		 //identificação de escola de EF
			gen  	school_EF 			= (enrollmentEF 	 != 0)	
			gen  	school_EM 			= (enrollmentEMtotal != 0)	
			
			
			**
			**
			foreach name in school_EI school_EF1 school_EF2 school_EF school_EM {
				bys codschool year: egen max = max(`name')
				drop 		`name'
				rename max  `name'
			} 
			
			**
			formatting
			order 		year coduf uf codmunic codmunic2 codschool location network			
			label 		define 	  yesno 1 "Yes" 0 "No"
			foreach 		 var of varlist school* {
			label 		val `var' yesno
			}
		
			
			**
			**
			foreach var of varlist enrollment* {
				replace `var' = . if `var' == 0
			}
			
			**
			**
			sort 	codschool year
			compress
			save 		"$inter/Enrollments", replace
			erase 		"$inter/CensoEscolar2005.dta"
			erase		"$inter/Máscara2005.dta"
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**
	**Harmonizing Teacher Data
	**
	*________________________________________________________________________________________________________________________________* 
	{
		foreach year in 2009 	{
			
			foreach region in SP  		{
			
			use 	"$inter/Professores`year'`region'.dta", clear
			*erase  "$inter/Professores`year'`region'.dta"
			
			/*
			Nessa base, cada linha é uma turma. Um professor pode aparecer mais de uma vez se: 
			(1) Der aula em mais de uma turma.
			(2) Se lecionar em diferentes redes de ensino, por exemplo, rede municipal e estadual.
			(3) Se der aula em duas escolas diferentes.
			*/
			
			
				if 		`year' == 2007 {
				keep    	ID_MATEMATICA ID_LINGUA_LITERAT_PORTUGUESA COD_CURSO_1 COD_CURSO_2 COD_CURSO_3 ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	 NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
				order   	ID_MATEMATICA ID_LINGUA_LITERAT_PORTUGUESA COD_CURSO_1 COD_CURSO_2 COD_CURSO_3 ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	 NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
				}
				
				if 		`year' == 2008 | `year' == 2009 {
				keep    	ID_MATEMATICA ID_LINGUA_LITERAT_PORTUGUESA  *K_COD_AREA_OCDE_*				   ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	 NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
				order   	ID_MATEMATICA ID_LINGUA_LITERAT_PORTUGUESA  *K_COD_AREA_OCDE_* 				   ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	 NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
				}

				**
				**
				rename 		(ANO_CENSO-ID_DEPENDENCIA_ADM) ///
							(year	codteacher	birthday	birthmonth	birthyear	age	gender	color	schoolattainment	specialization	master	phd	occupation	codclass	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codschool	coduf	codmunic	location	network)
					
				**
				**
				destring, 	replace
				format 		codteacher codschool codmunic %15.0g
				
				
				**
				*Educação regular, educação especial e EJA
				**
				gen 			type = 1 if FK_COD_MOD_ENSINO == 1
				replace 		type = 2 if FK_COD_MOD_ENSINO == 2
				replace 		type = 3 if FK_COD_MOD_ENSINO == 3
				label 	define 	type 1 "Regular Education" 2 "Special Education" 3 "Adult Education" 
				label 	val    	type type
				drop  	if 		type == .
				
				**
				*1º ou 2º Ciclos do EF
				**
				gen 		TeacherEF1    = 1 if (FK_COD_ETAPA_ENSINO >= 4  & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
				gen 		TeacherEF2    = 1 if (FK_COD_ETAPA_ENSINO >= 8  & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | (FK_COD_ETAPA_ENSINO == 41)
				gen 		Teacher5grade = 1 if (FK_COD_ETAPA_ENSINO == 7  | FK_COD_ETAPA_ENSINO  == 18)
				gen 		Teacher9grade = 1 if (FK_COD_ETAPA_ENSINO == 11 | FK_COD_ETAPA_ENSINO  == 41)
				gen 		TeacherEF     = 1 if  TeacherEF1 == 1 | TeacherEF2 == 1

				
				**
				***
				if 			`year' == 2007   							keep if occupation == 0 		//docentes
				if 			`year' == 2009 |  `year' == 2008			keep if occupation == 1 
				
			**
			*Total de professores por escola
			**
			*------------------------------------------------------------------------------------------------------------------------*
			preserve
				**
				**
				collapse 	(mean) Teacher*,	 by (year coduf network codmunic codschool codteacher location	)
				save 		"$inter/Código de Identificação dos professores_`year'`region'.dta", replace					//we are going to use this dataset to check if the same teacher works for local and state schools.
				
				**
				**
				collapse 	(sum)  Teacher*,    by (year coduf network codmunic codschool						)
				save 		"$inter/Professores por escola_`year'`region'.dta", replace
			restore
			
			**
			*Turmas com professores com formação adequada para lecionar no 5o ano
			**
			*------------------------------------------------------------------------------------------------------------------------*
			keep 		if Teacher5grade == 1 & (ID_MATEMATICA == 1 | ID_LINGUA_LITERAT_PORTUGUESA == 1) //professores do 5o ano que lecionam portugues ou matematica, vamos ver se esses professores são formados em pedagogia ou em portugues e matemática
			
				if 		`year' == 2007 {
					gen 		formacao_adequada_port5  =  inlist(COD_CURSO_1, 28, 22) | inlist(COD_CURSO_2, 28, 22) | inlist(COD_CURSO_3, 28, 22)  	//pedagogia, portugues
					gen 		formacao_adequada_math5  =  inlist(COD_CURSO_1, 28, 25) | inlist(COD_CURSO_2, 28, 25) | inlist(COD_CURSO_3, 28, 25)	//pedagogia, matematica
				}
				
				if 		`year' == 2009 {
					gen 		formacao_adequada_port5 = inlist(FK_COD_AREA_OCDE_1, "144F02", "144F05", "144F06", "144F11", "145F15", "145F16", "220L01", "220P01","220L03") ///
														| inlist(FK_COD_AREA_OCDE_2, "144F02", "144F05", "144F06", "144F11", "145F15", "145F16", "220L01", "220P01","220L03") ///
														| inlist(FK_COD_AREA_OCDE_3, "144F02", "144F05", "144F06", "144F11", "145F15", "145F16", "220L01", "220P01","220L03")
												  
					gen 		formacao_adequada_math5 = inlist(FK_COD_AREA_OCDE_1, "144F02", "144F05", "144F06", "144F11", "145F18", "461M01") 	///
														| inlist(FK_COD_AREA_OCDE_2, "144F02", "144F05", "144F06", "144F11", "145F18", "461M01") 	
				}
			
				if		 `year' == 2008 {
					gen 		formacao_adequada_port5  = .
					gen 		formacao_adequada_math5  = .
				}
				
				**
				**
				collapse 	(max) formacao_adequada*, by(codclass codschool network year codmunic coduf) 			//algumas turmas apresentam mais de um professor de portuguës/matematica. Vamos considerar o professor com a maior formacao. 
				
				**
				**
				compress
				sort 		codschool year
				save 		"$inter/Professores formação adequada_`year'`region'.dta", replace
			}
		}
		
		**
		**Total de professores por escola
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			clear
			foreach 	year in 2007 2008 2009 { 
				foreach 	region in SP {
						append using "$inter/Professores por escola_`year'`region'.dta",
						erase 		 "$inter/Professores por escola_`year'`region'.dta"
				}
			}
			
			**
			**
			keep	 codschool year Teacher*
			sort 	 codschool year
			
			**
			sort 	 codschool year
			compress
			save "$inter/Teachers.dta", replace
			
			
		**
		**Relação de professores por escola
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			clear
			foreach year in 2007 2008 2009 { 
				foreach region in SP {
					append using  "$inter/Código de Identificação dos professores_`year'`region'.dta"
					erase 		  "$inter/Código de Identificação dos professores_`year'`region'.dta"
				}
			}
			
			**
			**
			keep 	year codteacher location network codschool codmunic coduf Teacher*
			
			**
			**
			sort 	codschool year
			compress
			save "$inter/Código de Identificação dos professores", replace			
			
			
		**
		**Proporção de tumas com docentes com formação adequada
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			clear
			foreach 	year in 2007 2008 2009 { 
				foreach 	region in SP {
						append using "$inter/Professores formação adequada_`year'`region'.dta"
						*erase 		 "$inter/Professores formação adequada_`year'`region'.dta"
				}
			}
			
			**
			**
			keep 		year codschool codclass formacao* network coduf codmunic

			
			**
			**
			merge 		1:1 codclass codschool year using  "$inter/Relação de turmas por escola.dta", keep(3)   //numero de alunos da turma
			
			**
			**
			collapse 	(mean)formacao* [w = enrollments], by(codschool year network coduf codmunic)			//proporcao de turmas com docentes com formacao adequada, ponderado pelo numero de alunos da turma 
			
			**
			**
			replace 	formacao_adequada_math5 = formacao_adequada_math5*100
			replace 	formacao_adequada_port5 = formacao_adequada_port5*100
			format 		formacao* %4.2fc
			
			
			**
			sort 		codschool year
			
			**
			compress
			save 		"$inter/Formação Adequada dos Docentes.dta", replace
			
		
		
		**
		**Alunos por professor
		**
		*----------------------------------------------------------------------------------------------------------------------------*
			use 	"$inter/Teachers.dta", clear
			
				**
				merge 1:1 codschool year using "$inter/Enrollments.dta", keep (3) nogen
				
					**
					foreach  grade in EF 5grade 9grade {
						gen 	 spt`grade' = enrollment`grade'/Teacher`grade' 						//students per teacher
						su 		 spt`grade', detail
						*replace spt`grade' = . if spt_`name' <= r(p1) | spt_`name' >= r(p99)
					}
					
					**
					**
					format	 	spt* %4.2fc
					keep 	 	year uf codschool spt* network

					**
					**
					sort 		codschool year
					
					**
					compress
					save  		"$inter/Students per teacher.dta", replace
					*erase 		"$inter/Teachers.dta"
		}
					
		
