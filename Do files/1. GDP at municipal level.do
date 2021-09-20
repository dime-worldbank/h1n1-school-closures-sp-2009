	*________________________________________________________________________________________________________________________________* 
	**
	**
	*Population and GDP per capita at municipality level 
	**
	*________________________________________________________________________________________________________________________________* 

													  
	**
	*Population
	*________________________________________________________________________________________________________________________________* 

		**
		*2007
		**
		*---------------------------------------------------------------------------------------------------------------------------*
		**	
			import 	  		excel using "$raw/IBGE/popmunic2007layoutTCU14112007.xls", cellrange(A5:E5568) allstring clear 
			gen 	  		codmunic = B + C
			rename 	  		E pop
			keep 	  		pop codmunic
			gen       		year = 2007
			destring, 		replace
			expand 			2, 					gen(REP)
			replace 		year = 2005 	if  	REP == 1	
			drop 								REP
			expand 			2 if year == 2007, 	gen(REP)
			replace 		year =  2008 	if  	REP == 1
			drop 								REP		
			tempfile  		 pop_2007
			save     		`pop_2007'							//pop 2005 and 2008 = pop 2007 so we can use the GDP at municipality level to calculate the GDP per capita. 
		
	**
	*GDP by Municipality
	*________________________________________________________________________________________________________________________________* 
	
		**
		*2005-2010*
		**
		*---------------------------------------------------------------------------------------------------------------------------*
		**
			import 	  		excel using "$raw/IBGE/base.xls", allstring firstrow clear
			keep	  		ano cod_munic pib pop pib_pcap munic
			rename   		(cod_munic ano) (codmunic year)
			destring, 		replace
			keep 	  		if year == 2007 | year == 2009 | year == 2005 | year == 2008
			merge 	  		1:1 year codmunic using `pop_2007', nogen update 
			replace   		pib_pcap = (pib*1000)/pop     if year == 2007 | year == 2005 | year == 2008 
			tempfile  		pib
			save    	   `pib'
			
		**
		*2010-2014*
		**
		*---------------------------------------------------------------------------------------------------------------------------*
		**
			import 			excel using "$raw/IBGE/base_de_dados_2010_2014.xls", allstring firstrow clear
			keep 			 ProdutoInternoBrutopercapita  ProdutoInternoBrutoapreços Anodereferência CódigodoMunicípio
			rename 			(ProdutoInternoBrutopercapita  ProdutoInternoBrutoapreços Anodereferência CódigodoMunicípio) 	(pib_pcap pib year codmunic)
			destring, replace
			
	**
	*GDP per capita
	*________________________________________________________________________________________________________________________________* 
	
			append using  `pib'
		
			**
			**Affected and unaffected municipal networks
			**
			gen 		T = .
			foreach munic in $treated_municipalities {								
				replace T = 1 	if codmunic == `munic'
			}
			replace 	T = 0  	if T == .
			keep 				if year <= 2013
			
			**
			**GDP in 2019 BRL, IPCA is the consumer price index
			**
			local 			ipca2005 2.08
			local 			ipca2006 2.01
			local 			ipca2006 2.01
			local 			ipca2007 1.93
			local 			ipca2008 1.82
			local 			ipca2009 1.75
			local 			ipca2010 1.65			
			local 			ipca2011 1.55
			local 			ipca2012 1.46
			local 			ipca2013 1.38
			local 			ipca2014 1.30		//ipca2019 = 1

			foreach year in 2005 2007 2008 2009 2010 2011 2012 2013 {					//GDP in 2019 BRL
				su 			pib_pcap 	 					 if year == `year', detail
				replace 	pib_pcap = .				 	 if year == `year' & pib_pcap > r(p99) & T != 1 //Sao Caetano do Sul (treated municipality) do have a higher GDP per capita. If if we do not codeT != 1, we exclude this municipality
				replace 	pib_pcap = pib_pcap*`ipca`year'' if year == `year'
			}
			
			**
			**Size of the municipality
			**
			gen 			porte = 1 if pop <= 5000
			replace 		porte = 2 if pop >  5000   & pop < 50000
			replace 		porte = 3 if pop >  50000  & pop < 100000
			replace 		porte = 4 if pop >  100000 & pop < 500000
			replace 		porte = 5 if pop >  500000 & !missing(pop)
			
			label 	define  porte 1 "Up to 5k" 2 "Between 5k and 50k" 3 "Between 50k and 100k" 4 "Between 100k and 500k" 5 "More than 500k"
			label 	val     porte porte
			replace pop = pop/1000
			
			**
			**Formatting
			**
			format 		 	pib 		%25.2fc
			format		 	pop 		%4.2fc
			format 		 	pib_pcap %12.2fc
			drop   		 	pib munic
			
			gen 	 	 	codmunic2 = substr(string(codmunic), 1,6)
			destring 	 	codmunic2, replace
			order 		 	year codmunic codmunic2 pib_pcap pop porte T
			compress
			keep 		 	if year == 2005 | year == 2007 | year == 2009 | year == 2008
			gen 	 	 	coduf = substr(string(codmunic), 1,2)
			destring 	 	coduf, replace
			
			**
			**
			sort   		 	codmunic year
			compress
			save  		 	"$inter/GDP per capita.dta", replace


	
	*________________________________________________________________________________________________________________________________* 
	**
	**
	*GDP per capita at state level in 2008
	**
	*________________________________________________________________________________________________________________________________* 
	
		import 	  			excel using "$raw/IBGE/tabela5938.xlsx", cellrange(A6:B32) allstring clear
		
			destring, 			replace
			rename 				(A B) (uf pib_pcap)
			format  			pib_pcap %15.0fc
			
			**
			**
			#delimit ;
			replace 			uf 		= "RO" 	if uf == "Rondônia"		; replace uf = "AC" if uf == "Acre"				; replace uf = "AM" if uf == "Amazonas"			; 
			replace 			uf 		= "RR" 	if uf == "Roraima" 		; replace uf = "RJ" if uf == "Rio de Janeiro"	; replace uf = "SP" if uf == "São Paulo"		;
			replace 			uf 		= "PA" 	if uf == "Pará"	 		; replace uf = "AP" if uf == "Amapá"			; replace uf = "TO" if uf == "Tocantins"		;
			replace 			uf 		= "MA" 	if uf == "Maranhão"		; replace uf = "PI" if uf == "Piauí"			; replace uf = "CE" if uf == "Ceará"			; 
			replace 			uf 		= "PB" 	if uf == "Paraíba"		; replace uf = "PE" if uf == "Pernambuco"		; 
			replace 			uf 		= "AL" 	if uf == "Alagoas"		; replace uf = "SE" if uf == "Sergipe"			; replace uf = "BA" if uf == "Bahia"			;	
			replace 			uf 		= "MG" 	if uf == "Minas Gerais"	; replace uf = "ES" if uf == "Espírito Santo"	; 
			replace 			uf 		= "PR" 	if uf == "Paraná"		; replace uf = "SC" if uf == "Santa Catarina"	;  
			replace 			uf 		= "MT" 	if uf == "Mato Grosso"	; replace uf = "GO" if uf == "Goiás"			; replace uf = "DF" if uf == "Distrito Federal"	;
			replace 			uf 		= "RN" 	if uf == "Rio Grande do Norte"	; 
			replace 			uf 		= "MS" 	if uf == "Mato Grosso do Sul"	;
			replace 			uf 		= "RS" 	if uf == "Rio Grande do Sul"   	;
			gen 				coduf 	= 11 	if uf == "RO"; replace coduf = 12 if uf == "AC"; replace coduf = 13 if uf == "AM"; replace coduf = 14 if uf == "RR";
			replace 			coduf 	= 15 	if uf == "PA"; replace coduf = 16 if uf == "AP"; replace coduf = 17 if uf == "TO"; replace coduf = 21 if uf == "MA";
			replace 			coduf 	= 22 	if uf == "PI"; replace coduf = 23 if uf == "CE"; replace coduf = 24 if uf == "RN"; replace coduf = 25 if uf == "PB";
			replace 			coduf 	= 26 	if uf == "PE"; replace coduf = 27 if uf == "AL"; replace coduf = 28 if uf == "SE"; replace coduf = 29 if uf == "BA";
			replace 			coduf 	= 31 	if uf == "MG"; replace coduf = 32 if uf == "ES"; replace coduf = 33 if uf == "RJ"; replace coduf = 35 if uf == "SP";
			replace 			coduf 	= 41 	if uf == "PR"; replace coduf = 42 if uf == "SC"; replace coduf = 43 if uf == "RS"; replace coduf = 50 if uf == "MS";
			replace 			coduf 	= 51 	if uf == "MT"; replace coduf = 52 if uf == "GO"; replace coduf = 53 if uf == "DF";
			#delimit cr
			
			
			**
			**
			*save 			"$inter/GDP per capita at state level.dta", replace
		
	
