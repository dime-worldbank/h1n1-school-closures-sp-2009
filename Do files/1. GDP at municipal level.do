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
		*2007*
		*---------------------------------------------------------------------------------------------------------------------------*
		**	
			import 	  excel using "$raw/IBGE/popmunic2007layoutTCU14112007.xls", cellrange(A5:E5568) allstring clear
			keep 	  if A == "SP" 								//state of Sao Paulo
			gen 	  codmunic = B + C
			rename 	  E pop
			keep 	  pop codmunic
			gen       year = 2007
			destring, replace
			expand 2, gen(REP)
			replace year = 2005 if REP == 1	
			drop REP
			expand 2 if year == 2007, gen(REP)
			replace year = 2008 if REP == 1	
			drop REP		
			tempfile  pop_2007
			save     `pop_2007'
		
	**
	*GDP by Municipality
	*________________________________________________________________________________________________________________________________* 
	
		**
		*2005-2010*
		*---------------------------------------------------------------------------------------------------------------------------*
		**
			import 	  excel using "$raw/IBGE/base.xls", allstring firstrow clear
			keep 	  if nome_uf == "São Paulo"
			keep	  ano cod_munic pib pop pib_pcap munic
			rename   (cod_munic ano) (codmunic year)
			destring, replace
			keep 	  if year == 2007 | year == 2009 | year == 2005 | year == 2008
			merge 	  1:1 year codmunic using `pop_2007', nogen update 
			replace   pib_pcap = (pib*1000)/pop     if year == 2007 | year == 2005 | year == 2008 
			tempfile  pib
			save     `pib'
			
		**
		*2010-2014*
		*---------------------------------------------------------------------------------------------------------------------------*
		**
			import 	excel using "$raw/IBGE/base_de_dados_2010_2014.xls", allstring firstrow clear
			keep 	if NomedaUnidadedaFederação == "São Paulo" 
			keep 	ProdutoInternoBrutopercapita  ProdutoInternoBrutoapreços Anodereferência CódigodoMunicípio
			rename (ProdutoInternoBrutopercapita ProdutoInternoBrutoapreços Anodereferência CódigodoMunicípio) (pib_pcap pib year codmunic )
			destring, replace
			
	**
	*GDP per capita
	*________________________________________________________________________________________________________________________________* 
	
			append using  `pib'
		
			**
			**Affected and unaffected municipal networks
			gen 	treated = .
			foreach munic in $treated_municipalities {								
				replace treated = 1 if codmunic == `munic'
			}
			replace treated = 0 	if treated == .
			keep if year <= 2013
			
			**
			**2019 BRL
			local ipca2005 2.08
			local ipca2006 2.01
			local ipca2006 2.01
			local ipca2007 1.93
			local ipca2008 1.82
			local ipca2009 1.75
			local ipca2010 1.65			
			local ipca2011 1.55
			local ipca2012 1.46
			local ipca2013 1.38
			local ipca2014 1.30		//ipca2019 = 1

			foreach year in 2005 2007 2008 2009 2010 2011 2012 2013 {					//GDP in 2019 BRL
				su 		pib_pcap 	 					 if year == `year', detail
				replace pib_pcap = .				 	 if year == `year' & pib_pcap > r(p99)
				replace pib_pcap = pib_pcap*`ipca`year'' if year == `year'
			}
			
			**
			**Size of the municipality
			gen 	porte = 1 if pop <= 5000
			replace porte = 2 if pop >  5000   & pop < 50000
			replace porte = 3 if pop >  50000  & pop < 100000
			replace porte = 4 if pop >  100000 & pop < 500000
			replace porte = 5 if pop >  500000 & !missing(pop)
			
			label define porte 1 "Up to 5k" 2 "Between 5k and 50k" 3 "Between 50k and 100k" 4 "Between 100k and 500k" 5 "More than 500k"
			label val    porte porte
			replace pop = pop/1000
			
			**
			**Formatting
			format pib 		%25.2fc
			format pop 		%4.2fc
			format pib_pcap %12.2fc
			drop   pib munic
			sort   codmunic year
			gen 	 codmunic2 = substr(string(codmunic), 1,6)
			destring codmunic2, replace
			order year codmunic codmunic2 pib_pcap pop porte treated
			compress
			keep if year == 2005 | year == 2007 | year == 2009 | year == 2008
			save   "$inter/GDP per capita.dta", replace


	
	
	
	
	
	
	
