	*________________________________________________________________________________________________________________________________* 
	**
	**
	*Number of confirmed cases of to H1N1 
	**
	*________________________________________________________________________________________________________________________________* 

										
	** 
	*Datasus
	*________________________________________________________________________________________________________________________________* 
														
		**
		**Weekly number of confirmed H1N1 cases
		**
		import 			delimited using "$raw/SUS/A161451189_28_143_208.csv", delimiter(";") clear		//number of confimed H1N1 cases
		drop 			in 1/5
		drop 			in 1919/1936
		
		**
		**
		gen 	 		codmunic2 = substr(v1,1,6)														//6-digit code of the municipality
		destring 		codmunic2, replace
	
		**
		**Cases registered from week 16 to 52       //April to December
		**
		local 		week = 16		//starts in week 16
		foreach 	var of varlist v2-v38 {
			replace 	`var' = "" if `var' == "-"
			rename 		`var' week_`week'
			local 	week = `week' + 1
		}
		destring, 	replace
		
		**
		**
		gen  		year = 2009
		
		**
		**
		drop 		v39
		
		**
		*Number of confirmed cases between April and July (when the decision to close was made)
		**
		egen 		hosp_h1n1_july = rsum(week_16-week_31)		
		
		
		**
		**Population and treatment Status
		**
		merge   	1:1 codmunic2 year using "$inter/GDP per capita.dta", nogen keepusing(pop T)
		keep 		if year == 2009
		drop 		in 1	
		
		**
		*Number of confirmed cases per 100.000 inhabitants
		**
		foreach 	var of varlist week_*  hosp_h1n1_july {
			replace 	`var' = 0 if `var' == .	
			replace 	`var' = 	 `var'/(pop/100)					
		}		
		
		**
		**
		format 		week* hosp_h1n1* %5.2fc
		drop 		v1
	    order 		year codmunic2 T pop pop hosp_h1n1* 
		
		**
		**
		sort 		codmunic2
		compress
		save 		"$inter/H1N1.dta",replace
		
		
		**
		*Confirmed H1N1 cases at state level
		*------------------------------------------------------------------------------------------------------------------------------------*
		**
		gen 	 	coduf = substr(string(codmunic2), 1,2 )
		destring 	coduf, replace
		collapse 	(sum)week* hosp_h1n1*,  by(year coduf)
		*save 		"$inter/H1N1 at state level.dta",replace

		
		
		
		/*
		**
		use "$inter/H1N1.dta", clear
		*Average number of hospitalizations
			su hosp_h1n1 if T == 1 & year == 2009
			su hosp_h1n1 if T == 0 & year == 2009
			sort hosp_h1n1 
			
