	**
	*This do file imports and harmonizes Flow Indicators
	**
	*___________________________________________________________________________________________________________________________________________________* 

	
	*___________________________________________________________________________________________________________________________________________________* 
	**
	**Importing
	**
	*___________________________________________________________________________________________________________________________________________________* 

		**
		**
		*2007
		*-----------------------------------------------------------------------------------------------------------------------------------------------*
		**
			import excel "$raw/Rendimento/TX RENDIMENTO ESCOLAS 2007.xls"   , sheet("Sudeste") 						cellrange(A10:BK55139) allstring clear
			save "Rendimento2007.dta"

		**
		**
		*2008
		*-----------------------------------------------------------------------------------------------------------------------------------------------*
		**
			import excel "$raw/Rendimento/TX RENDIMENTO POR ESCOLA 2008.xls", sheet("Sudeste") 						cellrange(A10:BK39125) allstring clear
			save "Rendimento2008.dta"

		**
		**
		*2009
		*-----------------------------------------------------------------------------------------------------------------------------------------------*
		**
			import excel "$raw/Rendimento/TX RENDIMENTO POR ESCOLA 2009.xls", sheet("Sudeste") 						cellrange(A10:BK39352) allstring clear
			save "Rendimento2009.dta"

		**
		**
		*2007-2009
		*---------------------------------------------------------------------------------------------------------------------------*
		**
			clear
			foreach 	year in 2007 2008 2009 {
						append using "Rendimento`year'.dta"
						erase 		 "Rendimento`year'.dta"
			}
			rename 		(A-BK) ///
						(year	region	uf	codmunic	municipality	 location	network	codschool school approval1grade	approval2grade	approval3grade	approval4grade	approval5grade	approval6grade	approval7grade	approval8grade	approval9grade	approvalEF1	approvalEF2	approvalEF	approvalEM1	approvalEM2	approvalEM3	approvalEM4	approvalEMNaoSeriado	approvalEM	repetition1grade	repetition2grade	repetition3grade	repetition4grade	repetition5grade	repetition6grade	repetition7grade	repetition8grade	repetition9grade	repetitionEF1	repetitionEF2	repetitionEF	repetitionEM1	repetitionEM2	repetitionEM3	repetitionEM4	repetitionEMNaoSeriado	repetitionEM	dropout1grade	dropout2grade	dropout3grade	dropout4grade	dropout5grade	dropout6grade	dropout7grade	dropout8grade	dropout9grade	dropoutEF1	dropoutEF2	dropoutEF	dropoutEM1	dropoutEM2	dropoutEM3	dropoutEM4	dropoutEMNaoSeriado	dropoutEM)

						
			*==============================>>
			keep 		if uf == "SP"
			*==============================>>
			
			**
			**	
			destring	 year codmunic codschool, replace

			**
			*Missings
			**
			foreach 	var of varlist approval* repetition* dropout*{
						replace  `var' = "." if `var' == "ND" | `var' == "ND*" | `var' == "ND**" |`var' == "" |`var' == "-" |`var' == "--"
						destring `var', replace
			}	
	
			**
			**
			format		codschool codmunic %15.0g
			format 		approval* repetition* dropout* %4.2fc

			**
			*Rede
			**
			replace   	network = "3" if network == "Municipal"
			replace   	network = "2" if network == "Estadual"
			replace   	network = "1" if network == "Federal"
			replace  	network = "4" if network == "Particular" | network == "Privada"		
			destring  	network, replace
			label     	define network 1 "Federal" 2 "Estadual" 3 "Municipal" 4 "Privada"
			label     	val    network network

			**
			*Localização
			**
			replace   	location = "1" if  location == "Urbana"
			replace   	location = "2" if  location == "Rural" 
			destring  	location, replace
			label 	  	define  location 1 "Urbana" 2 "Rural"
			label 	 	val  	location  location
			
			**
			*coduf
			**
			gen 	  	coduf = string(codmunic)
			replace   	coduf = substr(coduf, 1, 2)
			destring  	coduf, replace

			**
			*Ordem dos dados
			**
			order     	year codschool network location 
			keep 		year codschool network location approval5grade approval9grade approvalEF1 approvalEF2 approvalEF repetition5grade repetition9grade repetitionEF1 repetitionEF2 repetitionEF dropout5grade dropout9grade dropoutEF1 dropoutEF2
			
			**
			*Painel de escolas com indicadores de rendimento
			**
			sort 		codschool year
			compress
			save "$inter/Flow Indicators.dta", replace
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
