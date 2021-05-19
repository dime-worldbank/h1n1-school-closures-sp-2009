	*________________________________________________________________________________________________________________________________* 
	**
	**
	*Hospitalizations due to H1N1 
	**
	*________________________________________________________________________________________________________________________________* 

										
	** 
	*Datasus
	*________________________________________________________________________________________________________________________________* 
														
		import 	delimited using "$raw/SUS/A132420189_28_143_208.csv", delimiter(";") clear
		drop 	in 1/4
		drop 	in 2597/2613
		gen 	 codmunic2 = substr(v1,1,6)
		destring codmunic2, replace

		foreach var of varlist v2-v12 {
			replace `var' = "" if `var' == "-"
		}
		destring, replace
		gen 	year = 2009
		rename  v12 hosp
		drop    v1-v11
		
		
		merge   1:1 codmunic2 year using "$inter/GDP per capita.dta", keep(3) nogen keepusing(pop treated)
		gen 	hosp_h1n1 = hosp/pop  																		//hospitalizacoes por h1n1 a cada 1000 habitantes
		save "$inter/H1N1.dta",replace
		 
		**
		*Average number of hospitalizations
			su hosp_h1n1 if treated == 1 & year == 2009
			su hosp_h1n1 if treated == 0 & year == 2009
			sort hosp_h1n1 
			
