	*________________________________________________________________________________________________________________________________* 
	**
	**
	*Hospitalizations due to H1N1 
	**
	*________________________________________________________________________________________________________________________________* 

										
	** 
	*Datasus
	*________________________________________________________________________________________________________________________________* 
														
		import 	delimited using "$raw/SUS/A161451189_28_143_208.csv", delimiter(";") clear
		drop 	in 1/5
		drop 	in 1919/1936
		gen 	 codmunic2 = substr(v1,1,6)
		destring codmunic2, replace
	
		local week = 16		//starts in week 16
		foreach var of varlist v2-v38 {
			replace `var' = "" if `var' == "-"
			rename  `var' week_`week'
			local week = `week' + 1
		}
		destring, replace
		gen 	year = 2009
		
		rename  v39 hosp_h1n1
		
		merge   1:1 codmunic2 year using "$inter/GDP per capita.dta", nogen keepusing(pop T)
		keep if year == 2009
		drop in 1	
		foreach var of varlist week_* hosp_h1n1 {
			replace `var' = 0 if `var' == .
			replace `var' = `var'/(pop/100)
		}		
		format week* hosp_h1n1 %5.2fc
		drop v1
	    order year codmunic2 T pop pop hosp_h1n1 
		save "$inter/H1N1.dta",replace
		
		gen 	 coduf = substr(string(codmunic2), 1,2 )
		destring coduf, replace
		collapse (sum)week* hosp_h1n1, by(year coduf)
		save "$inter/H1N1 at state level.dta",replace

		/*
		**
		use "$inter/H1N1.dta", clear
		*Average number of hospitalizations
			su hosp_h1n1 if T == 1 & year == 2009
			su hosp_h1n1 if T == 0 & year == 2009
			sort hosp_h1n1 
			
