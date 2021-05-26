	**
	*This do file imports and harmonizes Censo Escolar Data
	**
	*________________________________________________________________________________________________________________________________* 

	
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing 2005 data.
	**
	*________________________________________________________________________________________________________________________________* 
		do "$dofiles/Dictionaries/0. CensoEscolar_2005.do"


	*________________________________________________________________________________________________________________________________* 
	**
	**Importing School Infrastructure (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009 {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Escolas.do"
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Classrooms Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009  {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Turmas.do"
		}
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Teacher Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009 {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Professores.do"
		}

		
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Enrollment Data (2007, 2008 and 2009)
	**
	*________________________________________________________________________________________________________________________________* 
		forvalues year = 2007/2009  {
			do "$dofiles/Dictionaries/0. CensoEscolar_`year'Matrículas.do"
		}
			
	*________________________________________________________________________________________________________________________________* 
	**
	**Program to format School Census Data
	**
	*________________________________________________________________________________________________________________________________* 
		**
		**We use the program below across all harmonization of School Census Data
		cap program drop formatting
		program define   formatting

			#delimit ;
			
			gen 	uf = "RO" if coduf == 11; replace uf = "AC" if coduf == 12; replace uf = "AM" if coduf == 13; replace uf = "RR" if coduf == 14;
			replace uf = "PA" if coduf == 15; replace uf = "AP" if coduf == 16; replace uf = "TO" if coduf == 17; replace uf = "MA" if coduf == 21;
			replace uf = "PI" if coduf == 22; replace uf = "CE" if coduf == 23; replace uf = "RN" if coduf == 24; replace uf = "PB" if coduf == 25;
			replace uf = "PE" if coduf == 26; replace uf = "AL" if coduf == 27; replace uf = "SE" if coduf == 28; replace uf = "BA" if coduf == 29;
			replace uf = "MG" if coduf == 31; replace uf = "ES" if coduf == 32; replace uf = "RJ" if coduf == 33; replace uf = "SP" if coduf == 35;
			replace uf = "PR" if coduf == 41; replace uf = "SC" if coduf == 42; replace uf = "RS" if coduf == 43; replace uf = "MS" if coduf == 50;
			replace uf = "MT" if coduf == 51; replace uf = "GO" if coduf == 52; replace uf = "DF" if coduf == 53;
			#delimit cr
			
			label define state 11 "RO" 12 "AC" 13 "AM" 14 "RR" 15 "PA" 16 "AP" 17 "TO"  					///
							   21 "MA" 22 "PI" 23 "CE" 24 "RN" 25 "PB" 26 "PE" 27 "AL" 28 "SE" 29 "BA" 		///
							   31 "MG" 32 "ES" 33 "RJ" 35 "SP" 												///
							   41 "PR" 42 "SC" 43 "RS" 														///
							   50 "MS" 51 "MT" 52 "GO" 53 "DF"
			label val coduf state
			
			gen 	 codmunic2 = substr(string(codmunic), 1,6)
			destring codmunic2, replace
			
			label 	 define network  1 "Federal"           2 "State" 			 3 "Municipal" 			4 "Private"
			label 	 define location 1 "Urban"             2 "Rural"
			label 	 val 	location location
			label 	 val 	network  network
			
		end	
	
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing School Infrastructure 
	**
	*________________________________________________________________________________________________________________________________* 
		
		
		**
		*2005
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		use 	"$inter/CensoEscolar2005", clear
		merge 	1:1 MASCARA using "$inter/Máscara2005.dta", nogen 
		gen 	codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
		gen 	coduf 	 = substr(codmunic,1,2)
		
		*=====================>
		*keep if coduf == "35"   			//Sao Paulo
		*=====================>
		
		drop MASCARA CODMUNIC DE9F11G-NE9F117
		
		rename (ANO-S_CONEX) ///
			   (year network location ComputerLab ScienceLab ClosedSportCourt OpenedSportCourt Library ReadingRoom InternetAccess) 
		
		replace network  = "2" if network  == "Estadual"
		replace network  = "3" if network  == "Municipal"
		replace network  = "4" if network  == "Particular"
		replace network  = "1" if network  == "Federal"
		replace location = "1" if location == "Urbana"
		replace location = "0" if location == "Rural"
		
		foreach var of varlist ComputerLab-InternetAccess {
			replace `var' = "0" if `var' == "n"
			replace `var' = "1" if `var' == "s"
		}
		destring, replace
		gen		SportCourt = 1 if ClosedSportCourt == 1 | OpenedSportCourt == 1
		replace SportCourt = 0 if ClosedSportCourt == 0 & OpenedSportCourt == 0
		save "$inter/Escolas2005.dta", replace
		
		
		**
		*2007, 2008, 2009
		*----------------------------------------------------------------------------------------------------------------------------*
		forvalues year = 2007/2009 {
			
			use "$inter/Escolas`year'.dta", clear
			
			**
			if `year' == 2007 {
				keep 	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				order 	ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				rename (ANO_CENSO-ID_ALIMENTACAO) ///
				(year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	SchoolEmployees	MealsForStudents) 
				destring, replace
				gen 	operation2   = 1 if operation == "EM ATIVIDADE"
				replace operation2   = 2 if operation == "PARALISADA" 
				replace operation2   = 3 if operation == "EXTINTA" 
				drop 	operation
				rename  operation2 operation
			}
			
			**
			if `year' == 2008 {
				keep    ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				order   ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA NUM_FUNCIONARIOS	ID_ALIMENTACAO	
				rename (ANO_CENSO-ID_ALIMENTACAO)  ///
				(year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	BroadBandInternet SchoolEmployees	MealsForStudents) 
				destring, replace
			}
			
			**
			if `year' == 2009 {
				keep    ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	ID_SALA_LEITURA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA	NUM_FUNCIONARIOS	ID_ALIMENTACAO		DT_ANO_LETIVO_INICIO DT_ANO_LETIVO_TERMINO ID_FUND_CICLOS
				order   ANO_CENSO	PK_COD_ENTIDADE	DESC_SITUACAO_FUNCIONAMENTO	FK_COD_ESTADO 	FK_COD_MUNICIPIO	ID_DEPENDENCIA_ADM	ID_LOCALIZACAO	ID_LOCAL_FUNC_PREDIO_ESCOLAR	ID_LOCAL_FUNC_SALAS_EMPRESA	ID_ESCOLA_COMP_PREDIO	ID_LOCAL_FUNC_PRISIONAL	ID_LOCAL_FUNC_TEMPLO_IGREJA	ID_LOCAL_FUNC_CASA_PROFESSOR	ID_LOCAL_FUNC_GALPAO	ID_LOCAL_FUNC_OUTROS	ID_LOCAL_FUNC_SALAS_OUTRA_ESC	ID_AGUA_FILTRADA	ID_AGUA_INEXISTENTE	ID_ENERGIA_INEXISTENTE	ID_ESGOTO_INEXISTENTE	ID_LIXO_COLETA_PERIODICA	ID_LIXO_RECICLA	ID_SALA_DIRETORIA	ID_SALA_PROFESSOR	ID_LABORATORIO_INFORMATICA	ID_LABORATORIO_CIENCIAS	ID_QUADRA_ESPORTES	ID_COZINHA	ID_BIBLIOTECA	ID_SALA_LEITURA	NUM_SALAS_EXISTENTES	ID_EQUIP_TV	ID_EQUIP_VIDEOCASSETE	ID_EQUIP_DVD	ID_EQUIP_PARABOLICA	ID_EQUIP_COPIADORA	ID_EQUIP_RETRO	ID_EQUIP_IMPRESSORA	NUM_COMPUTADORES	ID_INTERNET	ID_BANDA_LARGA	NUM_FUNCIONARIOS	ID_ALIMENTACAO		DT_ANO_LETIVO_INICIO DT_ANO_LETIVO_TERMINO ID_FUND_CICLOS
				rename (ANO_CENSO-ID_FUND_CICLOS) ///
				(year	codschool	operation	coduf 	codmunic	network	location	OwnBuilding	CompanyRooms	RoomsAnotherSchool	PrisionalSystem	Church	TeacherHouse	Storage	Other	SharedBuilding	FilteredWater	WaterAccess1	EnergyAccess1	SewerAccess1	WasteCollection	WasteRecycling	PrincipalRoom	TeacherRoom	ComputerLab	ScienceLab	SportCourt	Kitchen	Library	ReadingRoom	TotalClasses	TV	VCR	DVD	Antenna	CopyingMachine	ProjectorMachine	Printer	NumberComputer	InternetAccess	BroadBandInternet	SchoolEmployees	MealsForStudents	inicio_letivo        fim_letivo CICLOS)
				destring, replace
				replace FilteredWater       = 0 if FilteredWater == 1
				replace FilteredWater       = 1 if FilteredWater == 2
				replace inicio_letivo 		= substr(inicio_letivo, 1, 9)
				replace fim_letivo    		= substr(fim_letivo   , 1, 9)
					
				foreach var of varlist *letivo {
					gen  c`var' = date(`var', "DMY")
					drop `var'
				}
				gen dia_fim_letivo 			= day(cfim_letivo)
				gen mes_fim_letivo 			= month(cfim_letivo)
				format cinicio_letivo cfim_letivo %td
			}
			
			*=====================>
			*keep if coduf == 35  				//Sao Paulo
			*=====================>

				gen 	Computer 		    = (NumberComputer >  0 & !missing(NumberComputer))
				replace Computer		    = . if missing(NumberComputer)
				gen		WaterAccess  	    = (WaterAccess1  == 0)
				gen 	EnergyAccess 	    = (EnergyAccess1 == 0)
				gen 	SewerAccess  	    = (SewerAccess1  == 0)
				foreach var of varlist  WaterAccess EnergyAccess SewerAccess {
					replace `var' = . if `var'1 == .
				}

				replace  location 			= 0 if location == 2
				save "$inter/Escolas`year'.dta", replace
		}
		
		**
		**-> Appending
		*----------------------------------------------------------------------------------------------------------------------------*
			clear
			foreach year in 2005 2007 2008 2009 {
				append using "$inter/Escolas`year'.dta"
				erase   	 "$inter/Escolas`year'.dta"
			}
			
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
				
				formatting
			
				order year coduf uf codmunic codmunic2 codschool  operation network location cfim_letivo cinicio_letivo dia_fim_letivo mes_fim_letivo CICLOS
				
				keep year-CICLOS ComputerLab ScienceLab ReadingRoom InternetAccess SportCourt FilteredWater  ///
				WasteCollection WasteRecycling PrincipalRoom TeacherRoom Kitchen TotalClasses NumberComputer ///
				SchoolEmployees MealsForStudents Computer WaterAccess EnergyAccess SewerAccess  BroadBandInternet Library
				
				label define yesno 1 "Yes" 0 "No"
				foreach var of varlist ComputerLab-Kitchen MealsForStudents-BroadBandInternet Library {
				label val `var' yesno
				}
				
				label define operation 1 "Em atividade" 2 "Paralisada" 3  "Extinta" 4 "Extinta no ano anterior" 
				label val   operation operation
				compress
				sort  codschool year
				save "$inter/School Infrastructure.dta", replace


	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Classrooms Data
	**
	*________________________________________________________________________________________________________________________________* 

		**
		*2005
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		use 	"$inter/CensoEscolar2005", clear
		merge 	1:1 MASCARA using "$inter/Máscara2005.dta", nogen 
		gen 	codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
		gen 	coduf 	 = substr(codmunic,1,2)
		
		*=====================>
		*keep if coduf == "35"   			//Sao Paulo
		*=====================>
		
		keep    ANO DEP LOC DE9F11G-NE9F117 codmunic codschool coduf
		rename (ANO DEP LOC) ///
			   (year network location) 
		
		replace network  	  = "2" if network  == "Estadual"
		replace network  	  = "3" if network  == "Municipal"
		replace network  	  = "4" if network  == "Particular"
		replace network  	  = "1" if network  == "Federal"
		replace location 	  = "1" if location == "Urbana"
		replace location 	  = "0" if location == "Rural"

		destring, replace
		
		egen turmas5 		  = rowtotal(DEF116  NEF116  DE9F117 NE9F117) 
		egen enrollment5grade = rowtotal(DE9F11G NE9F11G DEF11F  NEF11F )			//o 5o ano aqui eh equivalente a 4a serie 
		gen  tclass5grade 	  = enrollment5grade/turmas5				//alunos por turma
		destring, replace
		formatting	
		keep year network coduf uf codmunic codmunic2 codschool tclass5grade 
		save "$inter/Turmas2005.dta", replace

		
		**
		*2007, 2009
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007/2009 {

			use "$inter/Turmas`year'.dta", clear

			keep    ANO_CENSO	PK_COD_TURMA	NO_TURMA	HR_INICIAL	HR_INICIAL_MINUTO	NU_DURACAO_TURMA	NUM_MATRICULAS	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM 
			order   ANO_CENSO	PK_COD_TURMA	NO_TURMA	HR_INICIAL	HR_INICIAL_MINUTO	NU_DURACAO_TURMA	NUM_MATRICULAS	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM 
			rename (ANO_CENSO-ID_DEPENDENCIA_ADM)  ///
			(year	codclass	class	begins	beginsminute	last	enrollments	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codschool	coduf	codmunic	location	network)
			destring, replace 
			
			*=====================>
			*keep if coduf == 35   			//Sao Paulo
			*=====================>

			gen 	tclassEI        = 1 if  FK_COD_ETAPA_ENSINO == 1   | FK_COD_ETAPA_ENSINO  == 2   | FK_COD_ETAPA_ENSINO == 3
			gen 	tclasscreche    = 1 if  FK_COD_ETAPA_ENSINO == 1
			gen 	tclasspre       = 1 if  FK_COD_ETAPA_ENSINO == 2
			gen 	tclassEF1 		= 1 if (FK_COD_ETAPA_ENSINO >= 4   & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
			gen 	tclassEF2 		= 1 if (FK_COD_ETAPA_ENSINO >= 8   & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | (FK_COD_ETAPA_ENSINO == 41)
			gen 	tclassMultiEIEF = 1 if  FK_COD_ETAPA_ENSINO == 56
			gen 	tclassMulti8    = 1 if  FK_COD_ETAPA_ENSINO == 12
			gen 	tclassMulti9    = 1 if  FK_COD_ETAPA_ENSINO == 22
			gen 	tclassMulti8AD  = 1 if  FK_COD_ETAPA_ENSINO == 13
			gen 	tclassMulti9AD  = 1 if  FK_COD_ETAPA_ENSINO == 23
			gen 	tclassMulti89   = 1 if  FK_COD_ETAPA_ENSINO == 24
			gen	 	tclass1grade 	= 1 if  FK_COD_ETAPA_ENSINO == 14
			gen 	tclass2grade 	= 1 if (FK_COD_ETAPA_ENSINO == 4  | FK_COD_ETAPA_ENSINO == 15)
			gen 	tclass3grade 	= 1 if (FK_COD_ETAPA_ENSINO == 5  | FK_COD_ETAPA_ENSINO == 16)
			gen 	tclass4grade 	= 1 if (FK_COD_ETAPA_ENSINO == 6  | FK_COD_ETAPA_ENSINO == 17)
			gen 	tclass5grade 	= 1 if (FK_COD_ETAPA_ENSINO == 7  | FK_COD_ETAPA_ENSINO == 18)
			gen 	tclass6grade 	= 1 if (FK_COD_ETAPA_ENSINO == 8  | FK_COD_ETAPA_ENSINO == 19)
			gen 	tclass7grade 	= 1 if (FK_COD_ETAPA_ENSINO == 9  | FK_COD_ETAPA_ENSINO == 20)
			gen 	tclass8grade	= 1 if (FK_COD_ETAPA_ENSINO == 10 | FK_COD_ETAPA_ENSINO == 21)
			gen 	tclass9grade 	= 1 if (FK_COD_ETAPA_ENSINO == 11 | FK_COD_ETAPA_ENSINO == 41)
			gen 	tclassEF  		= 1 if tclassEF1 == 1 | tclassEF2 == 1
			egen    tclassMulti = rsum(tclassMultiEIEF tclassMulti8 tclassMulti9 tclassMulti8AD tclassMulti9AD tclassMulti89)
			replace tclassMulti = . 	if tclassMulti == 0
			gen 	tclassEFTotal 	= 1 if tclassEF ~=.  | tclassMulti ~= .
			drop 	tclassMultiEIEF-tclassMulti89 tclassMulti
			
			**
			*Educação regular, educação especial e EJA
			gen     type = 1 if FK_COD_MOD_ENSINO == 1
			replace type = 2 if FK_COD_MOD_ENSINO == 2
			replace type = 3 if FK_COD_MOD_ENSINO == 3
			label 	define type 1 "Regular Education" 2 "Special Education" 3 "Adult Education" 
			label 	val    type type

			keep year codclass enrollments last coduf codmunic	location network type codschool tclass*
			save "$inter/Turmas`year'.dta", replace

		}
	

		**
		**-> Appending
		*----------------------------------------------------------------------------------------------------------------------------*
		foreach year in 2007 2008 2009 {		
				append using "$inter/Turmas`year'.dta"
				*erase  		 "$inter/Turmas`year'.dta"
		}
		compress
		formatting	
	
		**
		*Class hours and average size of the class
		*----------------------------------------------------------------------------------------------------------------------------*
			foreach x in EI creche pre EF1 EF2 1grade 2grade 3grade 4grade 5grade 6grade 7grade 8grade 9grade EF EFTotal {
				gen	 	classhour`x' = last/60 			if tclass`x' == 1 	//duração da aula, em horas
				replace tclass`x' 	 = enrollments 		if tclass`x' == 1 	//número de alunos na turma
			}
			
			
		**
		*Data by school
		*----------------------------------------------------------------------------------------------------------------------------*
			preserve
				collapse (mean) classhour* [aw = enrollments], by (year network coduf uf codmunic codmunic2 codschool)			//matrícula por turma foi utilizada como ponderador, de modo que turmas com mais alunos pesam mais na média da escola
				order year coduf uf codmunic codmunic2 codschool network
				format classhour* %4.2fc
				sort codschool year
				save  "$inter/Class-Hours.dta", replace
			restore
			
			preserve
				collapse (mean) tclass*	   					 , by (year network coduf uf codmunic codmunic2 codschool)			//tamanho médio das turmas
				order year coduf uf codmunic codmunic2 codschool network
				format tclass* %4.2fc
				sort codschool year
				append using "$inter/Turmas2005.dta"
				save 		 "$inter/Class-Size.dta", replace
				erase 		 "$inter/Turmas2005.dta"
			restore
			
			
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Enrollment Data
	**
	*________________________________________________________________________________________________________________________________* 
		
		**
		*2005
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		use 	"$inter/CensoEscolar2005", clear
		merge 	1:1 MASCARA using "$inter/Máscara2005.dta", nogen 
		gen 	codmunic = substr(CODMUNIC,1,2) + substr(CODMUNIC, -5,.)
		gen 	coduf 	 = substr(codmunic,1,2)
		
		*=====================>
		*keep if coduf == "35"   			//Sao Paulo
		*=====================>
		
		keep    ANO DEP LOC DE9F11G-NE9F117 codmunic codschool coduf
		rename (ANO DEP LOC) ///
			   (year network location) 
		
		replace network  	  = "2" if network  == "Estadual"
		replace network  	  = "3" if network  == "Municipal"
		replace network  	  = "4" if network  == "Particular"
		replace network  	  = "1" if network  == "Federal"
		replace location 	  = "1" if location == "Urbana"
		replace location 	  = "0" if location == "Rural"

		destring, replace
		
		egen enrollment5grade = rowtotal(DE9F11G NE9F11G DEF11F  NEF11F )			//o 5o ano aqui eh equivalente a 4a serie 
		egen enrollment9grade = rowtotal(DE9F11N NE9F11L DEF11J NEF11J)	//o 5o ano aqui eh equivalente a 4a serie 

		
		destring, replace
		keep year network coduf codmunic codschool location enrollment*
		save "$inter/Matrículas2005.dta", replace
		
		
		**
		*2007, 2008, 2009
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007/2009 {
		
			foreach region in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
			
			use "$inter/Matrículas`year'`region'.dta", clear
			
			set dp period
			keep    						 				   ANO_CENSO	PK_COD_MATRICULA	FK_COD_ALUNO	NU_DIA		NU_MES		NU_ANO		NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_TURMA    PK_COD_ENTIDADE	FK_COD_ESTADO_ESCOLA	COD_MUNICIPIO_ESCOLA	ID_LOCALIZACAO_ESC	ID_DEPENDENCIA_ADM_ESC	ID_N_T_E_P	
			order  											   ANO_CENSO	PK_COD_MATRICULA	FK_COD_ALUNO	NU_DIA		NU_MES		NU_ANO		NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_TURMA	PK_COD_ENTIDADE	FK_COD_ESTADO_ESCOLA	COD_MUNICIPIO_ESCOLA	ID_LOCALIZACAO_ESC	ID_DEPENDENCIA_ADM_ESC  ID_N_T_E_P	
			rename (ANO_CENSO-ID_N_T_E_P) 					   (year		codenrollment		codstudent		BirthDay	BirthMonth	Birthyear	age			gender	color		FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codclass		codschool		coduf					codmunic				location			network 				transporte )
			
			destring, replace  
			
			**
			*Enrollments by grade
			*------------------------------------------------------------------------------------------------------------------------*
			gen enrollmentcreche    = 1 if  FK_COD_ETAPA_ENSINO == 1
			gen enrollmentpre       = 1 if  FK_COD_ETAPA_ENSINO == 2
			gen enrollmentEI        = 1 if  FK_COD_ETAPA_ENSINO == 1 |  FK_COD_ETAPA_ENSINO  == 2
			gen enrollmentEF1 		= 1 if (FK_COD_ETAPA_ENSINO >= 4  & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
			gen enrollmentEF2 		= 1 if (FK_COD_ETAPA_ENSINO >= 8  & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | FK_COD_ETAPA_ENSINO == 41
			gen enrollment1grade 	= 1 if  FK_COD_ETAPA_ENSINO == 14
			gen enrollment2grade 	= 1 if (FK_COD_ETAPA_ENSINO == 4  | FK_COD_ETAPA_ENSINO == 15)
			gen enrollment3grade 	= 1 if (FK_COD_ETAPA_ENSINO == 5  | FK_COD_ETAPA_ENSINO == 16)
			gen enrollment4grade 	= 1 if (FK_COD_ETAPA_ENSINO == 6  | FK_COD_ETAPA_ENSINO == 17)
			gen enrollment5grade 	= 1 if (FK_COD_ETAPA_ENSINO == 7  | FK_COD_ETAPA_ENSINO == 18)
			gen enrollment6grade 	= 1 if (FK_COD_ETAPA_ENSINO == 8  | FK_COD_ETAPA_ENSINO == 19)
			gen enrollment7grade 	= 1 if (FK_COD_ETAPA_ENSINO == 9  | FK_COD_ETAPA_ENSINO == 20)
			gen enrollment8grade 	= 1 if (FK_COD_ETAPA_ENSINO == 10 | FK_COD_ETAPA_ENSINO == 21)
			gen enrollment9grade 	= 1 if (FK_COD_ETAPA_ENSINO == 11 | FK_COD_ETAPA_ENSINO == 41)
			gen enrollmentEF  		= 1 if  enrollmentEF1 		== 1  | enrollmentEF2       == 1
			gen enrollmentEFtotal 	= 1 if  enrollmentEF 		== 1
			gen enrollmentEM1  		= 1 if  FK_COD_ETAPA_ENSINO == 25
			gen enrollmentEM2  		= 1 if  FK_COD_ETAPA_ENSINO == 26
			gen enrollmentEM3  		= 1 if  FK_COD_ETAPA_ENSINO == 27
			gen enrollmentEM4  		= 1 if  FK_COD_ETAPA_ENSINO == 28
			gen enrollmentEMns 		= 1 if  FK_COD_ETAPA_ENSINO == 29
			gen enrollmentEM  		= 1 if (FK_COD_ETAPA_ENSINO >= 25 & FK_COD_ETAPA_ENSINO <= 29)
			gen enrollmentEM1int  	= 1 if  FK_COD_ETAPA_ENSINO == 30
			gen enrollmentEM2int  	= 1 if  FK_COD_ETAPA_ENSINO == 31
			gen enrollmentEM3int  	= 1 if  FK_COD_ETAPA_ENSINO == 32
			gen enrollmentEM4int  	= 1 if  FK_COD_ETAPA_ENSINO == 33
			gen enrollmentEMnsint 	= 1 if  FK_COD_ETAPA_ENSINO == 34
			gen enrollmentEMint   	= 1 if  FK_COD_ETAPA_ENSINO >= 30 & FK_COD_ETAPA_ENSINO <= 34
			gen enrollmentEM1mag 	= 1 if  FK_COD_ETAPA_ENSINO == 35
			gen enrollmentEM2mag 	= 1 if  FK_COD_ETAPA_ENSINO == 36
			gen enrollmentEM3mag 	= 1 if  FK_COD_ETAPA_ENSINO == 37
			gen enrollmentEM4mag 	= 1 if  FK_COD_ETAPA_ENSINO == 38
			gen enrollmentEMmag  	= 1 if  FK_COD_ETAPA_ENSINO >= 35 & FK_COD_ETAPA_ENSINO <= 38
			gen enrollmentEMconc    = 1 if  FK_COD_ETAPA_ENSINO == 39 | FK_COD_ETAPA_ENSINO == 40  | FK_COD_ETAPA_ENSINO == 68  //Ensino técnico concomitante
			gen enrollmentEMtec     = 1 if  enrollmentEMint 	== 1  | enrollmentEMconc    == 1								//Total Técnico
			gen enrollmentEMst      = 1 if  enrollmentEM  		== 1  | enrollmentEMmag     == 1								//Total EM "normal" + magistério
			gen enrollmentEMtotal 	= 1 if  enrollmentEMst 		== 1  | enrollmentEMtec     == 1 								//Total EM técnico + "normal" + magistério
			
			drop enrollmentEM1-enrollmentEMst
			
			**
			*Educação regular, educação especial e EJA
			*------------------------------------------------------------------------------------------------------------------------*
			gen 	type = 1 if FK_COD_MOD_ENSINO == 1
			replace type = 2 if FK_COD_MOD_ENSINO == 2
			replace type = 3 if FK_COD_MOD_ENSINO == 3
	
		
			collapse (sum) enrollment*, by (location network codschool codmunic coduf year) 
			compress
			save "$inter/Matrículas`year'`region'.dta", replace
			
			}
		}
		
		**
		**-> Appending
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		clear 
		foreach year in 2007 2008 2009 {		
			foreach region in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
				append using "$inter/Matrículas`year'`region'.dta"
				erase   	 "$inter/Matrículas`year'`region'.dta"
			}
		}
			    append using    "$inter/Matrículas2005.dta"
				erase 		 	"$inter/Matrículas2005.dta"
	
		sort codschool year
		gen school_EI           = (enrollmentcreche  != 0 | enrollmentpre != 0)
		gen school_EF1          = (enrollmentEF1 	 != 0) 										    //identificação de escola de EF
		gen school_EF2          = (enrollmentEF2 	 != 0)										    //identificação de escola de EF
		gen school_EF 			= (enrollmentEF 	 != 0)	
		gen school_EM 			= (enrollmentEMtotal != 0)	
		
		foreach name in school_EI school_EF1 school_EF2 school_EF school_EM {
			bys codschool year: egen max = max(`name')
			drop 		`name'
			rename max  `name'
		} 
		formatting
		order year coduf uf codmunic codmunic2 codschool location network
		sort codschool year
		label define yesno 1 "Yes" 0 "No"
		foreach var of varlist school* {
		label val `var' yesno
		}
		compress
		replace location = 2 if location == 0 & year == 2005
		save 		"$inter/Enrollments", replace
		erase 		"$inter/CensoEscolar2005.dta"
		erase		"$inter/Máscara2005.dta"
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Teacher Data
	**
	*________________________________________________________________________________________________________________________________* 
		foreach year in 2007 2008 2009 {
			
			foreach region in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
			
			use "$inter/Professores`year'`region'.dta", clear

			local Teacher 1Grade 2Grade 3Grade 4Grade 5Grade 6Grade 7Grade 8Grade 9Grade
		
			keep    ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
			order   ANO_CENSO	FK_COD_DOCENTE	NU_DIA	NU_MES	NU_ANO	NUM_IDADE	TP_SEXO	TP_COR_RACA	FK_COD_ESCOLARIDADE	ID_ESPECIALIZACAO	ID_MESTRADO	ID_DOUTORADO	ID_TIPO_DOCENTE	PK_COD_TURMA	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	PK_COD_ENTIDADE	FK_COD_ESTADO	FK_COD_MUNICIPIO	ID_LOCALIZACAO	ID_DEPENDENCIA_ADM
			rename (ANO_CENSO-ID_DEPENDENCIA_ADM) ///
			(year	codteacher	birthday	birthmonth	birthyear	age	gender	color	schoolattainment	specialization	master	phd	occupation	codclass	FK_COD_MOD_ENSINO	FK_COD_ETAPA_ENSINO	codschool	coduf	codmunic	location	network)
				
			destring, replace
						
			format codteacher codschool codmunic %15.0g
			
			**
			*Educação regular, educação especial e EJA
			gen 	type = 1 if FK_COD_MOD_ENSINO == 1
			replace type = 2 if FK_COD_MOD_ENSINO == 2
			replace type = 3 if FK_COD_MOD_ENSINO == 3
			label 	define type 1 "Regular Education" 2 "Special Education" 3 "Adult Education" 
			label 	val    type type
			drop if type == . 
			
			**
			*1º ou 2º Ciclos do EF
			gen LTeacherEF1 = 1 if (FK_COD_ETAPA_ENSINO >= 4 & FK_COD_ETAPA_ENSINO  <= 7)  | (FK_COD_ETAPA_ENSINO >= 14 & FK_COD_ETAPA_ENSINO  <= 18)
			gen LTeacherEF2 = 1 if (FK_COD_ETAPA_ENSINO >= 8 & FK_COD_ETAPA_ENSINO  <= 11) | (FK_COD_ETAPA_ENSINO >= 19 & FK_COD_ETAPA_ENSINO  <= 21) | (FK_COD_ETAPA_ENSINO == 41)
			gen LTeacherEF  = 1 if LTeacherEF1 == 1 | LTeacherEF2 == 1
			
			gen LTeacher1grade = 1 if FK_COD_ETAPA_ENSINO == 14
			gen LTeacher2grade = 1 if (FK_COD_ETAPA_ENSINO == 4  | FK_COD_ETAPA_ENSINO == 15)
			gen LTeacher3grade = 1 if (FK_COD_ETAPA_ENSINO == 5  | FK_COD_ETAPA_ENSINO == 16)
			gen LTeacher4grade = 1 if (FK_COD_ETAPA_ENSINO == 6  | FK_COD_ETAPA_ENSINO == 17)
			gen LTeacher5grade = 1 if (FK_COD_ETAPA_ENSINO == 7  | FK_COD_ETAPA_ENSINO == 18)
			gen LTeacher6grade = 1 if (FK_COD_ETAPA_ENSINO == 8  | FK_COD_ETAPA_ENSINO == 19)
			gen LTeacher7grade = 1 if (FK_COD_ETAPA_ENSINO == 9  | FK_COD_ETAPA_ENSINO == 20)
			gen LTeacher8grade = 1 if (FK_COD_ETAPA_ENSINO == 10 | FK_COD_ETAPA_ENSINO == 21)
			gen LTeacher9grade = 1 if (FK_COD_ETAPA_ENSINO == 11 | FK_COD_ETAPA_ENSINO == 41)

			**
			*Identificação dos docentes
			gen     occupation2 = 1 if occupation == 0 & year == 2007
			replace occupation2 = 1 if occupation == 1 & year >  2007 //Em 2008, no dicionário está que essa variável é igual a 0 para docentes, mas na base a maior parte está como 1
			replace occupation2 = 2 if occupation == 2 & year >  2008
			replace occupation2 = 3 if occupation == 3 & year >  2008
			replace occupation2 = 4 if occupation == 4 & year >  2010
			replace occupation2 = 5 if occupation == 5 & year >= 2015
			replace occupation2 = 6 if occupation == 6 & year >= 2015
			
			label 	define occupation 1 "Docente" 2 "Auxiliar da educação infantil" 3 "Monitor" 4 "Intérprete de Libras" 5 "Docente tutor - EAD" 6 "Docente auxiliar - EAD"
			label 	val    occupation2 occupation
			
			**
			*Professores por escola
			keep if occupation2 == 1 		

			collapse (mean) LTeacher*,	 by (year codteacher occupation2 network codschool codmunic coduf location)
				
			foreach var of varlist LTeacher* {
				local newname = substr("`var'", 2, .)
				rename `var'  `newname'
			}
			collapse (sum) Teacher*,    by (year coduf network codmunic codschool)
			save "$inter/Professores por escola_`year'`region'.dta", replace
			/*
			Nessa base, cada linha é uma turma. Um professor pode aparecer mais de uma vez se: 
			(1) Der aula em mais de uma turma.
			(2) Se lecionar em diferentes redes de ensino, por exemplo, rede municipal e estadual.
			(3) Se der aula em duas escolas diferentes.
			*/
			
			erase "$inter/Professores`year'`region'.dta"
			}
		}
		
		
		**
		**-> Appending
		*----------------------------------------------------------------------------------------------------------------------------*
			clear
			foreach year in 2007 2008 2009 { 
				foreach region in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
					append using "$inter/Professores por escola_`year'`region'.dta",
					erase 		 "$inter/Professores por escola_`year'`region'.dta"
				}
			}
			keep year codschool Teacher*
			sort codschool year
			compress
			save "$inter/Teachers.dta", replace
	
		**
		**-> Students per teacher
		*----------------------------------------------------------------------------------------------------------------------------*
			use "$inter/Teachers.dta", clear
				merge 1:1 codschool year using "$inter/Enrollments.dta", keep (3) nogen
				
				foreach name in EF 5grade 9grade {
					gen 	spt`name' = enrollment`name'/Teacher`name' 					//students per teacher
					su 		spt`name', detail
					*replace spt`name' = . if spt_`name' <= r(p1) | spt_`name' >= r(p99)
				}
				format spt* %4.2fc
				keep year uf codschool spt* network
				sort codschool year
				compress
			save  "$inter/Students per teacher.dta", replace
			erase "$inter/Teachers.dta"

		
		
		
		
		
		
