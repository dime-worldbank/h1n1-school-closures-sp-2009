
												*ESTIMATIVA DO EFEITO DO ADIAMENTO DO RETORNO ÀS AULAS EM DECORRÊNCIA DO H1N1*
																  **ESCOLAS MUNICIPAIS DE SÃO PAULO**

global final   "C:\Users\wb495845\OneDrive - WBG\Desktop"
global results "C:\Users\wb495845\OneDrive - WBG\Desktop"
global inter   "C:\Users\wb495845\OneDrive - WBG\Desktop"
																  
*Author: Vivian Amorim
*vivianamorim5@gmail.com

set scheme economist
set seed 1


*Program to store results
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	estimates clear
	matrix 	results = (0,0,0,0,0,0)
	matrix  ri      = (0,0,0)
	
	cap program drop mat_res
	program define   mat_res
	syntax, model(integer) sub(integer) var(varlist) 
		
		*Coeficient
		matrix A   = r(table) 	
		local beta = A[1,1]																//coeficiente do tratamento

		*CI
		boottest `var',  reps(1000)  boottype(wild)  seed(1) level(95) 					//intervalo de confiança para nossa estimativa
		matrix A = r(CI)
		matrix results = results \ (`model', `sub', `beta', A[1,1], A[1,2], 0)			//modelo testado, disciplina, coeficiente do tratamento, lower bound, upper bound + 0 (só porque precisamos de uma coluna a mais para salvar o quantil - quando fazemos a regressão por quantil)
	
	end

	
*Regressions
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		foreach subject in port_insuf_  {
		
			if "`subject'" == "port" | "`subject'" == "padr_port" {
				local sub = 1
				local title = "Português"
			}
			
			if "`subject'" == "math" | "`subject'" == "padr_math" {
				local sub = 2
				local title = "Matemática"
			}
			
			if "`subject'" == "sp"  {
				local sub = 3
				local title = "Português e Matemática"
			}
			
			if "`subject'" == "math_insuf_"  {
				local sub = 4
				local title = "% desempenho insuficiente em Matemática"
			}
						
			if "`subject'" == "port_insuf_"  {
				local sub = 5
				local title = "% desempenho insuficiente em Português"
			}
						

				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				*A*
				*Dif in dif
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
				use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear
				gen t = (year > 2007)
				keep if year == 2005 | year == 2007 | year == 2009
				drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 //municipios sem prova brasil em 2005
				
				sort codschool year
				replace enrollment5 = enrollment5[_n+1] if year[_n] == 2005 & year[_n+1] == 2007 & codschool[_n] == codschool[_n+1]
					
				*Foi preciso separar a seleção dos controles porque nem todas as variáveis disponíveis em 2007 e 2009 estão disponíveis em 2005
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*

					*A.1*
					*Lasso para seleção dos controles - 2005 e 2007 
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2005 c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt c.pib_pcap##c.pib_pcap 		   	   ///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.tclass5##c.tclass5

					lasso linear `subject'5 $controls2005 if year <= 2007, rseed(1)						
					global controls2005  `e(allvars_sel)'
				
					*A.2*
					*Lasso para seleção dos controles - 2007 e 2009
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					global controls2007 c.mother_edu_5##c.mother_edu_5 c.ndropout_5##c.ndropout_5 c.nrepetition_5##c.nrepetition_5 c.computer_5##c.computer_5	///
					c.pib_pcap##c.pib_pcap c.approval5##c.approval5  c.studentwork_5##c.studentwork_5 						   									///
					c.white_5##c.white_5 c.female_5##c.female_5 c.privateschool_5##c.privateschool_5 c.livesmother_5##c.livesmother_5 							///
					c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 															///
					c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour5##c.classhour5 c.tclass5##c.tclass5 									///
					c.SIncentive1_5##c.SIncentive1_5 c.SIncentive2_5##c.SIncentive2_5 c.SIncentive3_5##c.SIncentive3_5	 										///
					c.SIncentive4_5##c.SIncentive4_5 c.SIncentive5_5##c.SIncentive5_5 c.SIncentive6_5##c.SIncentive6_5 										
				
					lasso linear `subject'5 $controls2007 if year >= 2007, rseed(1)		
					global controls2007  `e(allvars_sel)'

					*Peso das regressões
					*----------------------------------------------------------------------------------------------------------------------------------------------------------------*
					local weight enrollment5

					
						*2007 versus 2005
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							eststo: reg `subject'5 T2007 		  i.treated i.codmunic i.year $controls2005 	if year >= 2005 & year <= 2007  [aw = `weight'], cluster(codmunic)
							mat_res, model(1) sub(`sub') var(T2007)		
							*ritest treated _b[T2007], seed(1) reps(1000) cluster(codmunic): reg `subject'5 T2007 i.treated i.codmunic i.year $controls2005 if year >= 2005 & year <= 2007, cluster(codmunic)
							*matrix ri = ri\[1, `sub', el(r(p),1,1)] 		//erro padrão com RI
							
						*2009 versus 2005/2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
							eststo: reg `subject'5 T2007 T2009 	  i.treated i.codmunic i.year $controls2005 	if year >= 2005 & year <= 2009  [aw = `weight'], cluster(codmunic)					
					
					
						*2009 versus 2007
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						keep if e(sample) == 1
							eststo: reg `subject'5 	     T2009	  i.treated i.codmunic i.year $controls2007 	if year >= 2007 & year <= 2009  [aw = `weight'], cluster(codmunic)
							mat_res, model(2) sub(`sub') var(T2009)	
							*ritest treated _b[T2009], seed(1) reps(1000) cluster(codmunic): reg `subject'5 T2009 i.treated i.codmunic i.year $controls2007 if year >= 2007 & year <= 2009, cluster(codmunic)
							*matrix ri = ri\[2, `sub', el(r(p),1,1)] 	
								
								
							/*
							*Efeito por quintil
							*--------------------------------------------------------------------------------------------------------------------------------------------------------*
							if "`subject'" == "port" | "`subject'" == "math" {
								foreach quantile in 20 40 50 60 80 {
									cic continuous `subject'5 treated t $controls2007 i.codmunic 				if year >= 2007 & year <= 2009  [aw = `weight'], did at(`quantile') vce(bootstrap, reps(1000))
									matrix A = r(table)
									matrix results = results \ (3, `sub', A[1, colsof(A)-2], A[5,colsof(A)-2], A[6,colsof(A)-2], `quantile')	 		 	 
								}
							}
							*/
							}
						
						*Parallel trends
						*------------------------------------------------------------------------------------------------------------------------------------------------------------*
						collapse (mean)`subject'5 [aw = `weight'], by(year treated)
						format 	 	   `subject'5 %4.1fc
						save 		   "$inter/trend_`subject'.dta", replace
						
						tw 	///
						(line `subject'5 year if treated == 0, lwidth(0.5) color(ebblue) lp(shortdash) connect(direct) recast(connected) 	 ///  
						ml(`subject'5) mlabcolor(gs2) msize(1.5) ms(o) mlabposition(12)  mlabsize(2.5)) 									 ///
						(line `subject'5 year if treated == 1, lwidth(0.5) color(gs12) lp(shortdash) connect(direct) recast(connected)  	 ///  
						ml(`subject'5) mlabcolor(gs2) msize(1.5) ms(o) mlabposition(3)  mlabsize(2.5) 										 ///
						ylabel(, nogrid labsize(small) gmax angle(horizontal) format(%4.0fc))											     ///
						ytitle("Escala SAEB", size(small)) 																					 ///
						title("`title', 5{sup:o} ano", pos(12) size(medsmall) color(black))													 ///
						graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
						plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 					 ///
						legend(order(1 "Não adiaram o retorno às aulas" 2 "Adiaram") size(small) region(lwidth(none))) 						 ///
						ysize(6) xsize(7) 																									 ///
						note("Fonte: Prova Brasil.", color(black) fcolor(background) pos(7) size(small)))  
						*/
		}
	estout * using "$results/Regressions.csv", delimiter(";") label starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(fmt(3))) stats(N r2) mlabels() replace


*Results			
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	clear
	svmat results
	drop  in 1
	rename (results1-results6) (spec sub  beta lower upper quantile)	
	label define sub   1 "Português"  2 "Matemática" 3 "Português e matemática" 4 "Insuficiente em matemática" 5 "Insuficiente em Português"
	label define spec  1 "2007 comparado com 2005" 2 "2009 comparado com 2007"  3 "Quantile" 
	label define quantile 0 "Total" 20 "1o quintil" 40 "2o quintil" 60 "3o quintil" 4 "4o quintil" 
	label val sub sub
	label val spec    spec
	label var beta   "Coef. adiamento das aulas"
	label var lower  "Lower bound"
	label var upper  "Upper bound"
	format beta lower upper %4.2fc
	save "$final/Regression Results.dta", replace
	

	
*Gráficos
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	
	
	*Português e Matemática
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
	use "$final/Regression Results.dta", clear
		drop if spec == 3 | sub == 3 | sub == 4 | sub == 5 //quantile
		
		gen spec1 = spec
		replace spec1 = 3 if spec == 1 & sub == 2
		replace spec1 = 4 if spec == 2 & sub == 2		
			
					twoway    bar beta spec1 if spec1 == 1, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 2, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
						   || bar beta spec1 if spec1 == 3, ml(beta) barw(0.4) color(cranberry) || bar beta spec1 if spec1 == 4, barw(0.4) color(emidblue) || rcap lower upper spec1, lcolor(navy)	///
					yline(0, lpattern(shortdash) lcolor(cranberry)) 																																///
					xline(2.5, lpattern(shortdash) lcolor(navy)) 																																	///
					xtitle("", size(medsmall)) 											  																											///
					ytitle("{&gamma}, escala SAEB", size(small)) ylabel(-8(2)4, labsize(small) gmax angle(horizontal) format (%4.1fc))  															///					
				    xlabel(1 `" "2007" "versus 2005" "' 2 `" "2009" "versus 2007" "' 3 `" "2007" "versus 2005" "' 4 `" "2009" "versus 2007" "', labsize(small) ) 									///
					xscale(r(0.5 2.5)) 																																								///
					title(, size(medsmall) color(black)) 																																			///
					legend(order(1 "Placebo" 2 "Adiamento das aulas" 3 "95% CI" ) region(lstyle(none) fcolor(none)) size(medsmall))  																///
					text(3.5 1.5 "Português") 																																						///
					text(3.5 3.5 "Matemática") 																																						///
					ysize(4) xsize(4)  																													
					graph export "$figures/Dif-in-Dif_5ano.pdf", as(pdf) replace
					
	
	*Português, Matemática e Nota Padronizada, separadamente
	*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
		use "$final/Regression Results.dta", clear
		set scheme economist
		drop if quantile == 0 & spec == 3
		replace spec = 4 if spec == 3 & quantile == 40
		replace spec = 5 if spec == 3 & quantile == 60
		replace spec = 6 if spec == 3 & quantile == 80
					
		foreach sub in 1 2 {	
		
				*scale
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					su 	  upper if sub == `sub' , detail
					local max = r(max) + 0.1
					su 	  lower if sub == `sub' , detail
					local min = r(min) - 0.1
					if 	 `max' < 0 local max = 0
					local div = (`max' - `min')/4
					
				*Title & cor
				*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*
					if `sub' == 1  local title = "Portuguese"
					if `sub' == 2  local title = "Math"
					if `sub' == 3  local title = "Português e Matemática"
			
					if `sub' == 1 | `sub' == 2 {
						local min    = -8
						local max    =  4
						local pulo   =  2
						local ytitle = "Test score"
					}
					if `sub' == 3 {
						local min  = -0.3
						local max  =  0.1
						local pulo =  0.1
						local ytitle = "Nota padronizada (0-10)"						
					}
					
					if `sub' == 4 | `sub' == 5 {
						local min  = -20
						local max  =  10
						local pulo =  20
						local ytitle = "% de alunos"						
					}	
					
					set scheme economist 
					twoway bar beta spec if sub == `sub' & (spec == 1), ml(beta) barw(0.4) color(cranberry) || bar beta spec if sub == `sub' & (spec > 1), barw(0.4) color(emidblue) || rcap lower upper spec if sub == `sub', lcolor(navy)	///
					yline(0, lpattern(shortdash) lcolor(cranberry)) 																							///
					xtitle("", size(medsmall)) 											  																		///
					ytitle("{&gamma}, `ytitle'", size(medsmall)) ylabel(`min'(`pulo')`max', labsize(small) gmax angle(horizontal) format (%4.1fc))  			///					
				    xlabel(1 `" "2007" "versus 2005" "' 2 `" "2009" "versus 2007" "' 3 `" "20{sup:th}" "percentile" "' 4 `" "40{sup:th}" "percentile" "' 5 `" "60{sup:th}" "percentile" "' 6 `"  "80{sup:th}" "percentile" "', labsize(medsmall) ) 														///
					xscale(r(0.5 2.5))																															///
					title("`title', 5{sup:th} grade", size(large) color(black)) 																				///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 									///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 											///						
					legend(order(1 "Placebo" 2 "Extended winter break" 3 "95% CI" ) region(lstyle(none) fcolor(none)) size(medsmall)) 	  																									///
					ysize(4) xsize(5)  																													
					graph export "$figures/Dif-in-Dif_`title'5ano.pdf", as(pdf) replace
			}

					use "$final/Regression Results.dta", clear
					keep if spec == 2 & (sub == 4 | sub == 5)
					replace spec = 1 if sub == 4
					
					twoway bar beta spec if sub == 4, ml(beta) barw(0.4) color(emidblue) || bar beta spec if sub == 5 , barw(0.4) color(erose) || rcap lower upper spec , lcolor(navy)	///
					yline(0, lpattern(shortdash) lcolor(cranberry)) 																							///
					xtitle("", size(medsmall)) 											  																		///
					ytitle("{&gamma}, %", size(medsmall)) ylabel(-2(2)8, labsize(small) gmax angle(horizontal) format (%4.1fc))  			///					
				    xlabel(1 `" "Math" "' 2 `" "Portuguese" "', labsize(medsmall) ) 														///
					xscale(r(0.5 2.5))																															///
					title("5{sup:th} grade, 95 CI", size(large) color(black)) 																				///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
					plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
					legend(off)	  																									///
					ysize(4) xsize(4)  																													
					graph export "$figures/Dif-in-Dif_Insuficiente_5ano.pdf", as(pdf) replace
	
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
