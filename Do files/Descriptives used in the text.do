		
		
	**
	**
	*Balance test -> Data Section. Characteristics of the municipalities that closed its schools
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		*
		**
		use 	"$final/h1n1-school-closures-sp-2009.dta" if year == 2009 & !missing(math5) & uf == "SP", clear

			foreach 		var of varlist $matching_schools	{
				replace    `var' = `var'*100
			}	

			foreach 	    var of varlist $balance_students5 $matching_schools def_student_loweffort5 def_absenteeism5 def_bad_behavior5 $balance_teachers $balance_principals adeqmath5 adeqport5 dif5  { 			
				di as red "`var'"
				ttest 	   `var' if network == 3	, by (T) 					  	//ttest by treatment and comparison groups
			}

			foreach 	    var of varlist formacao_adequada_math5 formacao_adequada_port5 dif_age_5   { 
				di as red "`var'"
				ttest 	   `var' if G == 1 		 	, by (network) 											
			}
			
			foreach 	    var of varlist formacao_adequada_math5 formacao_adequada_port5 dif_age_5   { 
				di as red "`var'"
				ttest 	   `var' if G == 0  		, by (network) 											
		}	
		
		
	**
	**
	*Share of teachers in dif in dif sample that worked in the state-managed network. 
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_triple_dif == 1) & math5 !=. & year == 2009 & network == 2, clear
		
		bys G: su share_teacher_both_networks
				
			   su share_teacher_both_networks
			
			
	**
	**
	*Share of teachers in dif in dif sample that worked in the state-managed network. 
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_dif == 1) & math5 !=. & year == 2009, clear
		
		bys T: su share_teacher_both_networks
				
			   su share_teacher_both_networks
			   
			   
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_triple_dif == 1) & math5 !=. & network == 2, clear
			   bys year:  su hw_corrected_math_always5
					
			
			
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_dif == 1) & math5 !=. & year == 2009, clear
		
		bys T : su share_teacher_management_program
		
		
		
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_triple_dif == 1) & math5 !=. & year == 2009 & network == 2, clear
		
		bys G : su share_teacher_management_program
		
		
		
		
		

	use 	"$final/h1n1-school-closures-sp-2009.dta" if  year == 2007 & T == 1, clear
		
		su math_insuf5 
		su port_insuf5
	
	
	
	tab 		teacher_both_networks  if T == 0 //75% 
	tab 		teacher_both_networks  
	
	
	
	

		
	use 	"$final/h1n1-school-closures-sp-2009.dta" if (sample_triple_dif == 1) & math5 !=. & year == 2009, clear
		 
		bys network: su share_teacher_management_program if G == 1
		
		bys network: su share_teacher_management_program if G == 0
		
		 
		bys network: su  share_teacher_both_networks if G == 1
		
		bys network: su  share_teacher_both_networks if G == 0
		
				
		
		
		
		
		/*
		use "$final/h1n1-school-closures-sp-2009.dta" if uf == "SP", clear
		
			**
			foreach 		 v of varlist $balance_principals {
				replace   	`v' = `v'*100
				format    	`v' %4.2fc
				local      l`v' : variable label `v'
				label var 	`v' "`l`v'', %"
			}
		
			**
			foreach var of varlist covered_curricula45 {
				di as red  "`var'"
				ttest 	    `var' if G == 0 & tipo_municipio_ef1 == 1 & year == 2007, by (E)
			}
			
				
		
		
		
		
		


		
						
	**
	**
	*Sample for dif-in-dif -> enrollments end number of schools - locally-managed schools
	**
	*--------------------------------------------------------------------------------------------------------------------------------*
		
		**
		use 		"$final/h1n1-school-closures-sp-2009.dta" if year == 2009 & !missing(math5) & uf == "SP" & network == 3	& sample_dif == 1, clear

		gen 		id = 1 
		collapse 	(sum)enrollment5* id, by(T)			//total enrollment in treatment and comparison schools
		
		

		
		
		
		
		**
		*Teachers that work in both state and locally-managed schools
		
		
		use "$final/h1n1-school-closures-sp-2009.dta" if sample_dif == 1, clear					

						
						
						
									egen 	tag_codmunic = tag(codmunic network)

			**
			gen 	sample = "Baseline"			//municipalities included in the baseline of the Triple-Dif
					
			**
			gen 		ind = 1
					
			/*
					
			collapse (sum)tag_codmunic ind enrollment5, by(G network)
					
			Se fizermos isso, vemos que temos 9 municipios em G = 0 com escolas estaduais e 10  municipios em G = 0 com escolas municipais
											 80 municipios em G = 1 com escolas estaduais e 118 municipios em G = 1 com escolas municipais. 
													 
			Como vamos usar apenas municipios que apresentam escolas estaduais e municipais, precisamos ajustar para que o numero de municipios se iguale em G = 0 e em G = 1
			
						
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		**
		use			"$inter/Teachers Managerial Practices Program.dta" if year == 2009, clear
		drop 		if school_management_program == 1
		
		su 			share_teacher_management_program  if T == 1 & network == 3
		su 			share_teacher_management_program  if T == 0 & network == 3
		
		su 			share_teacher_management_program  if G == 1 & network == 2
		su 			share_teacher_management_program  if G == 0 & network == 2
		
		
		
		
		
	use	"$inter/Teachers in state and municipal networks.dta", clear				//share of teachers per school that work in a state and in a locally-managed school

		
		**
		**
		merge 		1:1 codschool year using "$inter/Enrollments.dta", keep(3) nogen
		
		tab 		year teacher_both_networks if enrollment5grade != . 
		tab 		year teacher_both_networks if enrollment5grade != . & network == 3 
						
						
						
						
