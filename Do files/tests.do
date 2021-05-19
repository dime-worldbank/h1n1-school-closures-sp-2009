

	
	use 	"$inter/IDEB by municipality.dta" if (network == 3 | network == 2) & G == 1  , clear
		
	keep 	codmunic network year math5 port5 idebEF1 T
	
	reshape wide math5 port5 idebEF1, i(codmunic T network) j(year)
	
	keep	if math52007 != .
	
	
	bys codmunic: gen total = _N
	
	keep if total == 2
	
	sort codmunic T 
	
	gen portdif =  port52007 - port52005 
	
	
	psmatch2 T portdif , common ties 


		
	keep if _support  == 1
	
	*tw (histogram math52007 if network == 3, fcolor(none) lcolor(blue)) || (histogram math52007 if network == 2, fcolor(none) lcolor(red))
		
	gen peso = _pscore/(1-_pscore)
	
	
											tw kdensity _pscore if T == 1 [aw = peso],  lw(thick) lp(dash) color(emidblue) 					///
										///
										|| kdensity _pscore if T == 0 [aw = peso],  lw(thick) lp(dash) color(gs12) 						///
											graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
											plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
											ylabel(, labsize(small) angle(horizontal) format(%2.1fc)) 											///
											xlabel(, labsize(small) gmax angle(horizontal)) 													///
											ytitle("", size(medsmall))			 																///
											xtitle("Propensity score", size(medsmall)) 															///
											title("", pos(12) size(medsmall)) 																	///
											subtitle(, pos(12) size(medsmall)) 																	

				drop total-peso
			
	
	reshape long port5 math5 idebEF1, i(codmunic network T) j(year)
		keep if year < 2011
	collapse (mean)port5, by(year T)
	
	tw line port5 year if T == 1, lcolor(red) || line port5 year if T == 0, lcolor(blue)
	
									
											
											
	duplicates drop codmunic, force
	keep codmunic

	tempfile munic
	save `munic' 
	
	
	
	
	
	
	use  "$final/h1n1-school-closures-sp-2009.dta" if year == 2007 | year == 2009, clear
	
	merge m:1 codmunic using `munic', keep (3)
											
	collapse (mean)	port5 math5 idebEF1 [aw = enrollment5], by(year T)
	
		tw line port5 year if T == 1, lcolor(red) || line port5 year if T == 0, lcolor(blue)

											
											
											
	use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) & G == 1 & tipo_municipio_ef1 == 1, clear
											
		reg math5  i.codmunic $controls2007 beta1-beta7 [aw = enrollment5] , cluster(codmunic)
									
		reg port5  i.codmunic $controls2007 i.year i.T T2009 [aw = enrollment5] , cluster(codmunic)

	
	
	use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) & G == 0, clear
	
		reg math5  i.codmunic $controls2007 i.year i.T T2009 [aw = enrollment5] , cluster(codmunic)

	
	use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) & G == 0, clear
	
		gen M = network == 3
		
		drop beta*
		
		gen beta1 = T*M
		gen beta2 = T*D
		gen beta3 = M*D
		
		
		reg math5  i.codmunic $controls2007 i.T i.M i.D beta3 [aw = enrollment5] , cluster(codmunic)
	
		reg port5  i.codmunic $controls2007 i.T i.M i.D beta3 [aw = enrollment5] , cluster(codmunic)
	
	
	
	
	
	
	
	
	
	
	

				global controls2007 c.mother_edu_highschool5##c.mother_edu_highschool5 c.number_dropouts5##c.number_dropouts5 									///
				c.number_repetitions5##c.number_repetitions5 c.computer5##c.computer5																			///
				c.pib_pcap##c.pib_pcap c.work5##c.work5 						   																				///
				c.white5##c.white5 c.male5##c.male5 c.private_school5##c.private_school5 c.live_mother5##c.live_mother5 										///
				c.ComputerLab##c.ComputerLab c.ScienceLab##c.ScienceLab c.SportCourt##c.SportCourt 																///
				c.Library##c.Library c.InternetAccess##c.InternetAccess c.classhour5##c.classhour5 c.spt_5##c.spt_5 											///
				c.incentive_study5##c.incentive_study5 c.incentive_homework5##c.incentive_homework5 c.incentive_read5##c.incentive_read5	 					///
				c.incentive_school5##c.incentive_school5 c.incentive_talk5##c.incentive_talk5 c.incentive_parents_meeting5##c.incentive_parents_meeting5	
			

				
				
			use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) & tipo_municipio_ef1 == 1 , clear
			
			gen M = network == 3


			gen beta8 = id_13_mun*D*M

			reg 	math5  i.codmunic $controls2007  beta1-beta6 beta8 [aw = enrollment5]  if year == 2007 | year == 2009, cluster(codmunic)
			reg 	port5  i.codmunic $controls2007  beta1-beta6 beta8 [aw = enrollment5]  if year == 2007 | year == 2009, cluster(codmunic)
			
			
			
			
			
			use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) &  network == 3 , clear
			drop
			
			
			
			reg 	math5  i.codmunic $controls2007  i.T i.year T2009  [aw = enrollment5], cluster(codmunic)
			
			boottest T2009,  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have a few number of 

			
			
			
			use  "$final/h1n1-school-closures-sp-2009.dta" if (year == 2007 | year == 2009) &  network == 3 , clear
			
			reg 	math5  i.codmunic $controls2007  i.T i.year T2009  [aw = enrollment5], cluster(codmunic)
			
			boottest T2009,  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have a few number of 

			reg 	port5 i.codmunic $controls2007  i.T i.year T2009  [aw = enrollment5], cluster(codmunic)
			
			boottest T2009,  reps(1000)  boottype(wild) seed(102846) level(95) bootcluster(codmunic) quietly		//Standard errors using bootstrap. We do this in our dif-in-dif models as we have a few number of 
			
			
			
			
			
			
			
			
			
			
			
			
			drop beta*
	
			gen beta1    = E*G
			gen beta2  	 = E*D
			gen beta3    = G*D	
	
			gen beta4    = E*T*D
			gen beta5    = M*T*D
		
			
			
			reg port5 E G D T $controls2007 i.codmunic beta1-beta5  if tipo_municipio_ef1 == 1
			
			
			gen beta8 = M*D*T

			
	
			eststo: reg port5  $controls2007  i.treated i.network i.group i.year  beta6 beta8  [aw = enrollment5] if (year == 2007 | year == 2009) & tipo_municipio_ef1 == 1 , cluster(codmunic)
					
					
					
					
					
					
					
								*drop if codmunic == 3509502 | codmunic == 3520509 | codmunic == 3548807 	
			sort 	codschool year
			
			egen group = group(codmunic network)
			

					
			eststo: reg math5  $controls2007  i.codmunic##i.network i.treated  i.year  T2009 [aw = enrollment5] if (year == 2007 | year == 2009)			  , cluster(codmunic)
					
					
			eststo: reg math5  i.treated i.codmunic i.year $controls2007 beta5  T2009 [aw = enrollment5] if (year == 2007 | year == 2009)  			  , cluster(codmunic)

			
			
			
			xtset codschool year 
			
			xtreg math5 i.year $controls2007  T2009 if (year == 2007 | year == 2009)  & tipo_municipio_ef1 == 1	& G == 1			  , cluster(codmunic)
			
			xtreg math5
			
			
			use "$final/Performance & Socioeconomic Variables of SP schools.dta" if !missing(codschool) & year < 2015, clear 
			
	collapse (mean)math5 port5, by(year id_M network)
			tw 	///
			(line math5  year if network == 2, lwidth(0.5) color(emidblue) lp(solid) connect(direct) recast(connected) 	 												///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)) 																						///
			(line math5  year if network == 3, by(id_M) lwidth(0.5) color(cranberry) lp(shortdash) connect(direct) recast(connected) 	 								///  
			ml() mlabcolor(gs2) msize(1) ms(o) mlabposition(12)  mlabsize(2.5)																							///
			ylabel(, labsize(small) gmax angle(horizontal) format(%4.1fc))											     												///
			yscale( alt )  																																				///
			title("", pos(12) size(medium) color(black))													 															///
			xtitle("")  																																				///
			xlabel(2005(2)2009, labsize(small) gmax angle(horizontal) format(%4.0fc))											     									///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 													///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 															///						
			legend(order(1 "Estadual"  2 "Municipal"  3 "Contrafactual") size(small) region(lwidth(none) color(white) fcolor(none))) 									///
			ysize(5) xsize(5) 																										 									///
			note("", color(black) fcolor(background) pos(7) size(small)))  
			*graph export "$figures/.pdf", as(pdf) replace

			
			
			
			
			drop if id_13_mun == 1
			
			
			
			keep if year == 2007 | year == 2009 | year == 2011 | year == 2013
			replace G = 0 if year == 2011 | year == 2013
			
			replace year = 2007 if year == 2011 & G == 0
			replace year = 2009 if year == 2013 & G == 0
			
			drop beta* E D 
			
			gen E 		 = state_network	
			gen D 		 = (year == 2009)

			gen beta1    = E
			gen beta2    = G
			gen beta3    = D
			gen beta4    = E*G
			gen beta5    = E*D
			gen beta6  	 = G*D
			gen beta7    = E*G*D 				 //triple dif coefficient
			eststo: reg math5  i.codmunic 	 beta1-beta7  if (year == 2007 | year == 2009) & tipo_municipio_ef1 == 1, cluster(codmunic)
			
			
			
			
			use "$final/Performance & Socioeconomic Variables of SP schools.dta", clear 
			drop 	 T2009
			clonevar T2009 = beta7
			
			gen t = 1 if year  == 2007
			replace  t = 2 if year == 2009

			eststo: reg math5  beta1-beta6 i.codmunic 		$controls2007 T2009 [aw = enrollment5] if (year == 2007 | year == 2009) & tipo_municipio_ef1 == 1, cluster(codmunic)
			
		
			egen group = group(codmunic network)
			
			eststo: reg math5  i.codmunic i.year $controls2007  i.treated	i.t##i.network				T2009  [aw = enrollment5] if (year == 2007 | year == 2009) & tipo_municipio_ef1 == 1 & G == 1, cluster(codmunic)

		
		
		
		
		
						
				
		estout * using "$tables/Table2.csv"  , delimiter(";") keep(T2009*) 	label cells(b se) starlevels(* 0.10 ** 0.05 *** 0.01) stats(N r2_a, fmt(%9.0g %9.3f %9.2f)) replace

		 
		
		
		
		
		
	use "$final/Performance & Socioeconomic Variables of SP schools.dta" if id_M == 1 & tipo_municipio_ef1 == 1, clear 

	psmatch2 treated $balance_students5 if year == 2007, common ties 
	
	
	
	
	keep if _support  == 1
	
	tw (histogram math5 if network == 3, fcolor(none) lcolor(blue)) || (histogram math5 if network == 2, fcolor(none) lcolor(red))
	
	keep codschool _weight _pscore treated
	
	gen peso = _pscore/(1-_pscore)
	
	
											tw kdensity _pscore if treated == 1 [aw = peso],  lw(thick) lp(dash) color(emidblue) 					///
										///
										|| kdensity _pscore if treated == 0 [aw = peso],  lw(thick) lp(dash) color(gs12) 						///
											graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
											plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
											ylabel(, labsize(small) angle(horizontal) format(%2.1fc)) 											///
											xlabel(, labsize(small) gmax angle(horizontal)) 													///
											ytitle("", size(medsmall))			 																///
											xtitle("Propensity score", size(medsmall)) 															///
											title("", pos(12) size(medsmall)) 																	///
											subtitle(, pos(12) size(medsmall)) 																	
												
	
	
	tempfile school
	save `school'
	
		use "$final/Performance & Socioeconomic Variables of SP schools.dta" if id_M == 1 & tipo_municipio_ef1 == 1 & (year == 2007 | year == 2009), clear 

		merge m:1 codschool using  `school', keep(3)
		
		
			tw (histogram math5 if network == 3 & year == 2007, fcolor(none) lcolor(blue)) || (histogram math5 if network == 2 & year == 2007, fcolor(none) lcolor(red))
			tw (histogram math5 if network == 3 & year == 2009, fcolor(none) lcolor(blue)) || (histogram math5 if network == 2 & year == 2009, fcolor(none) lcolor(red))
		
		egen group = group(codmunic network)
			eststo: reg math5  i.treated i.group i.year 	T2009  [aw = peso], cluster(group)
		
		
		
		
		tw ///
		line math5 year if uf == "SP", lcolor(red) || line math5 year if uf == "ES", lcolor(blue) || ///
		line		math5 year if uf == "MG", lcolor(green) || line math5 year  if uf == "RJ", lcolor(black)
		
		
		
		
