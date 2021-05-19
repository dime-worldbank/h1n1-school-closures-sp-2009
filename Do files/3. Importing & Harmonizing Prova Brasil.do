
	**
	*This do file imports and harmonizes Prova Brasil Data
	**
	*________________________________________________________________________________________________________________________________* 

	
	
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Student Data
	**
	*________________________________________________________________________________________________________________________________* 

		**
		*2007*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		
		**
		*Socioeconomic 
		*----------------------------------------------------------------------------------------------------------------------------*
		clear
		#delimit;
			infix
			str ID_ALUNO 		   1-8
			str ID_SERIE 		   9-9
			str ID_DEPENDENCIA_ADM 10-10
			str ID_LOCALIZACAO     11-11
			str SIGLA_UF           12-13
			str COD_UF             14-15
			str NO_MUNICIPIO       16-65
			str COD_MUNICIPIO      66-72
			str Q1  73-73
			str Q2  74-74
			str Q3  75-75
			str Q4  76-76
			str Q5  77-77
			str Q6  78-78
			str Q7  79-79
			str Q8  80-80
			str Q9  81-81
			str Q10 82-82
			str Q11 83-83
			str Q12 84-84
			str Q13 85-85
			str Q14 86-86
			str Q15 87-87
			str Q16 88-88
			str Q17 89-89
			str Q18 90-90
			str Q19 91-91
			str Q20 92-92
			str Q21 93-93
			str Q22 94-94
			str Q23 95-95
			str Q24 96-96
			str Q25 97-97
			str Q26 98-98
			str Q27 99-99
			str Q28 100-100
			str Q29 101-101
			str Q30 102-102
			str Q31 103-103
			str Q32 104-104
			str Q33 105-105
			str Q34 106-106
			str Q35 107-107
			str Q36 108-108
			str Q37 109-109
			str Q38 110-110
			str Q39 111-111
			str Q40 112-112
			str Q41 113-113
			str Q42 114-114
			str Q43 115-115
			str Q44 116-116
			str Q45 117-117
			str Q46 118-118
			str Q47 119-119
			using "$raw/Prova Brasil/2007/DADOS/TS_QUEST_ALUNO.txt";
			tempfile  socioeconomic_2007 ;
			save	 `socioeconomic_2007';
			clear;	
		#delimit cr		
		
		**
		*Geral
		*----------------------------------------------------------------------------------------------------------------------------*
		clear
		#delimit;
		infix
				str ID_ALUNO 				1-8
				str ID_TURMA 				9-15
				str TX_HORARIO_INICIO 		16-20
				str TX_HORARIO_FINAL 		21-25
				str NU_QTD_ALUNO 			26-29
				str ID_SERIE 				30-30
				str PK_COD_ENTIDADE 		31-38
				str ID_DEPENDENCIA_ADM 		39-39
				str ID_LOCALIZACAO 			40-40
				str SIGLA_UF 				41-42
				str COD_UF 					43-44
				str NO_MUNICIPIO 			45-94
				str COD_MUNICIPIO 			95-101
				str ST_LINGUA_PORTUGUESA 	102-102
				str ST_MATEMATICA 			103-103
				str NU_THETA_L 				104-111
				str NU_SETHETA_L 			112-119
				str NU_THETAT_L 			120-127
				str NU_SETHETAT_L 			128-135
				str NU_SETHETA_M 			136-143
				str NU_THETAT_M 			144-151
				str NU_SETHETAT_M 			152-159
				str NU_THETA_M 				160-167
				using "$raw/Prova Brasil/2007/DADOS/TS_ALUNO.txt";
				tempfile  geral_2007 ;
				save	 `geral_2007';		
				clear;	
		#delimit cr		
		
		**
		*Socioeconomic + Geral
		*----------------------------------------------------------------------------------------------------------------------------*
		use `socioeconomic_2007', clear
			merge 1:1 ID_ALUNO using `geral_2007', nogen 
			destring ID_* CO* NU* PK*, replace
			*================================>
			keep if SIGLA_UF == "SP"
			*================================>
			compress
			save "$inter/Prova Brasil Questionnaire_2007.dta", replace
			
	
		**
		*2009*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		
		**
		*Socioeconomic 
		*----------------------------------------------------------------------------------------------------------------------------*
		clear
		insheet using "$raw/Prova Brasil/2009/DADOS/TS_QUEST_ALUNO.txt", names delimiter(";")
			forvalues i = 1/47 {
				gen Q`i' = substr(tx_respostas,`i',1)
			}
			drop tx_respostas
			keep id_aluno Q*
			tempfile  socioeconomic_2009 
			save	 `socioeconomic_2009'
			
		**
		*Geral
		*----------------------------------------------------------------------------------------------------------------------------*
		clear
		insheet using "$raw/Prova Brasil/2009/DADOS/TS_ALUNO.txt", names delimiter(";")
			tempfile  geral_2009
			save	 `geral_2009'
			
		**
		*Socioeconomic + Geral
		*----------------------------------------------------------------------------------------------------------------------------*
		use `socioeconomic_2009', clear
			merge 1:1 id_aluno using `geral_2009', nogen 
			destring id_* co* nu* pk*, replace
			*================================>
			keep if sigla_uf == "SP"
			*================================>
			compress
		save "$inter/Prova Brasil Questionnaire_2009.dta", replace
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Teacher Data
	**
	*________________________________________________________________________________________________________________________________* 

		**
		*2007*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		clear
		#delimit;
			infix
				str PK_COD_ENTIDADE 	   1-8
				str ID_DEPENDENCIA_ADM 	   9-9
				str ID_LOCALIZACAO 		   10-10
				str SIGLA_UF 			   11-12
				str COD_UF 				   13-14
				str NO_MUNICIPIO 		   15-64
				str COD_MUNICIPIO 		   65-71
				str ID_TURMA 			   72-78
				str ID_SERIE 			   79-79
				str DS_DISCIPLINA 		   80-80
				str Q1  81-81
				str Q2  82-82
				str Q3  83-83
				str Q4  84-84
				str Q5  85-85
				str Q6  86-86
				str Q7  87-87
				str Q8  88-88
				str Q9  89-89
				str Q10 90-90
				str Q11 91-91
				str Q12 92-92
				str Q13 93-93
				str Q14 94-94
				str Q15 95-95
				str Q16 96-96
				str Q17 97-97
				str Q18 98-98
				str Q19 99-99
				str Q20 100-100
				str Q21 101-101
				str Q22 102-102
				str Q23 103-103
				str Q24 104-104
				str Q25 105-105
				str Q26 106-106
				str Q27 107-107
				str Q28 108-108
				str Q29 109-109
				str Q30 110-110
				str Q31 111-111
				str Q32 112-112
				str Q33 113-113
				str Q34 114-114
				str Q35 115-115
				str Q36 116-116
				str Q37 117-117
				str Q38 118-118
				str Q39 119-119
				str Q40 120-120
				str Q41 121-121
				str Q42 122-122
				str Q43 123-123
				str Q44 124-124
				str Q45 125-125
				str Q46 126-126
				str Q47 127-127
				str Q48 128-128
				str Q49 129-129
				str Q50 130-130
				str Q51 131-131
				str Q52 132-132
				str Q53 133-133
				str Q54 134-134
				str Q55 135-135
				str Q56 136-136
				str Q57 137-137
				str Q58 138-138
				str Q59 139-139
				str Q60 140-140
				str Q61 141-141
				str Q62 142-142
				str Q63 143-143
				str Q64 144-144
				str Q65 145-145
				str Q66 146-146
				str Q67 147-147
				str Q68 148-148
				str Q69 149-149
				str Q70 150-150
				str Q71 151-151
				str Q72 152-152
				str Q73 153-153
				str Q74 154-154
				str Q75 155-155
				str Q76 156-156
				str Q77 157-157
				str Q78 158-158
				str Q79 159-159
				str Q80 160-160
				str Q81 161-161
				str Q82 162-162
				str Q83 163-163
				str Q84 164-164
				str Q85 165-165
				str Q86 166-166
				str Q87 167-167
				str Q88 168-168
				str Q89 169-169
				str Q90 170-170
				str Q91 171-171
				str Q92 172-172
				str Q93 173-173
				str Q94 174-174
				str Q95 175-175
				str Q96 176-176
				str Q97 177-177
				str Q98 178-178
				str Q99 179-179
				str Q100 180-180
				str Q101 181-181
				str Q102 182-182
				str Q103 183-183
				str Q104 184-184
				str Q105 185-185
				str Q106 186-186
				str Q107 187-187
				str Q108 188-188
				str Q109 189-189
				str Q110 190-190
				str Q111 191-191
				str Q112 192-192
				str Q113 193-193
				str Q114 194-194
				str Q115 195-195
				str Q116 196-196
				str Q117 197-197
				str Q118 198-198
				str Q119 199-199
				str Q120 200-200
				str Q121 201-201
				str Q122 202-202
				str Q123 203-203
				str Q124 204-204
				str Q125 205-205
				str Q126 206-206
				str Q127 207-207
				str Q128 208-208
				str Q129 209-209
				str Q130 210-210
				str Q131 211-211
			using "$raw/Prova Brasil/2007/DADOS/TS_QUEST_PROFESSOR.txt";
			*================================>
			keep if SIGLA_UF == "SP";
			*================================>
			compress;
			save  "$inter/Teachers_2007.dta", replace;
			clear;	
		#delimit cr	

		**
		*2009*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		clear
		insheet using "$raw/Prova Brasil/2009/DADOS/TS_QUEST_PROFESSOR.txt", names delimiter(";")
			forvalues i = 1/135 {
				gen Q`i' = substr(tx_resp_questionario,`i',1)
			}
			drop tx_resp_questionario
			*================================>
			keep if sigla_uf == "SP"
			*================================>
			compress
			save  "$inter/Teachers_2009.dta", replace
	
	
	*________________________________________________________________________________________________________________________________* 
	**
	**Importing Principal Data
	**
	*________________________________________________________________________________________________________________________________* 

		**
		*2007*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		clear
		#delimit;
			infix
				str PK_COD_ENTIDADE 	   1-8
				str ID_DEPENDENCIA_ADM 	   9-9
				str ID_LOCALIZACAO 		   10-10
				str SIGLA_UF 			   11-12
				str COD_UF 				   13-14
				str NO_MUNICIPIO 		   15-64
				str COD_MUNICIPIO 		   65-71
				str Q1 72-72
				str Q2 73-73
				str Q3 74-74
				str Q4 75-75
				str Q5 76-76
				str Q6 77-77
				str Q7 78-78
				str Q8 79-79
				str Q9 80-80
				str Q10 81-81
				str Q11 82-82
				str Q12 83-83
				str Q13 84-84
				str Q14 85-85
				str Q15 86-86
				str Q16 87-87
				str Q17 88-88
				str Q18 89-89
				str Q19 90-90
				str Q20 91-91
				str Q21 92-92
				str Q22 93-93
				str Q23 94-94
				str Q24 95-95
				str Q25 96-96
				str Q26 97-97
				str Q27 98-98
				str Q28 99-99
				str Q29 100-100
				str Q30 101-101
				str Q31 102-102
				str Q32 103-103
				str Q33 104-104
				str Q34 105-105
				str Q35 106-106
				str Q36 107-107
				str Q37 108-108
				str Q38 109-109
				str Q39 110-110
				str Q40 111-111
				str Q41 112-112
				str Q42 113-113
				str Q43 114-114
				str Q44 115-115
				str Q45 116-116
				str Q46 117-117
				str Q47 118-118
				str Q48 119-119
				str Q49 120-120
				str Q50 121-121
				str Q51 122-122
				str Q52 123-123
				str Q53 124-124
				str Q54 125-125
				str Q55 126-126
				str Q56 127-127
				str Q57 128-128
				str Q58 129-129
				str Q59 130-130
				str Q60 131-131
				str Q61 132-132
				str Q62 133-133
				str Q63 134-134
				str Q64 135-135
				str Q65 136-136
				str Q66 137-137
				str Q67 138-138
				str Q68 139-139
				str Q69 140-140
				str Q70 141-141
				str Q71 142-142
				str Q72 143-143
				str Q73 144-144
				str Q74 145-145
				str Q75 146-146
				str Q76 147-147
				str Q77 148-148
				str Q78 149-149
				str Q79 150-150
				str Q80 151-151
				str Q81 152-152
				str Q82 153-153
				str Q83 154-154
				str Q84 155-155
				str Q85 156-156
				str Q86 157-157
				str Q87 158-158
				str Q88 159-159
				str Q89 160-160
				str Q90 161-161
				str Q91 162-162
				str Q92 163-163
				str Q93 164-164
				str Q94 165-165
				str Q95 166-166
				str Q96 167-167
				str Q97 168-168
				str Q98 169-169
				str Q99 170-170
				str Q100 171-171
				str Q101 172-172
				str Q102 173-173
				str Q103 174-174
				str Q104 175-175
				str Q105 176-176
				str Q106 177-177
				str Q107 178-178
				str Q108 179-179
				str Q109 180-180
				str Q110 181-181
				str Q111 182-182
				str Q112 183-183
				str Q113 184-184
				str Q114 185-185
				str Q115 186-186
				str Q116 187-187
				str Q117 188-188
				str Q118 189-189
				str Q119 190-190
				str Q120 191-191
				str Q121 192-192
				str Q122 193-193
				str Q123 194-194
				str Q124 195-195
				str Q125 196-196
				str Q126 197-197
				str Q127 198-198
				str Q128 199-199
				str Q129 200-200
				str Q130 201-201
				str Q131 202-202
				str Q132 203-203
				str Q133 204-204
				str Q134 205-205
				str Q135 206-206
				str Q136 207-207
				str Q137 208-208
				str Q138 209-209
				str Q139 210-210
				str Q140 211-211
				str Q141 212-212
				str Q142 213-213
				str Q143 214-214
				str Q144 215-215
				str Q145 216-216
				str Q146 217-217
				str Q147 218-218
				str Q148 219-219
				str Q149 220-220
				str Q150 221-221
				str Q151 222-222
				str Q152 223-223
				str Q153 224-224
				str Q154 225-225
				str Q155 226-226
				str Q156 227-227
				str Q157 228-228
				str Q158 229-229
				str Q159 230-230
				str Q160 231-231
				str Q161 232-232
			using "$raw/Prova Brasil/2007/DADOS/TS_QUEST_DIRETOR.txt";
			*================================>
			keep if SIGLA_UF == "SP";
			*================================>
			compress;
			save  "$inter/Principals_2007.dta", replace;
			*clear;	
		#delimit cr	

		
		**
		*2009*
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		clear
		insheet using "$raw/Prova Brasil/2009/DADOS/TS_QUEST_DIRETOR.txt", names delimiter(";")
			forvalues i = 1/146 {
				gen Q`i' = substr(tx_resp_questionario,`i',1)
			}
			drop tx_resp_questionario
			*================================>
			keep if sigla_uf == "SP"
			*================================>
			compress
			save  "$inter/Principals_2009.dta", replace
		
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Student Data
	**
	*________________________________________________________________________________________________________________________________* 

	
		**
		*Identification variables
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
		
			use "$inter/Prova Brasil Questionnaire_`year'.dta", clear
			
			if `year' == 2007 {
				drop 	ST_LINGUA_PORTUGUESA ST_MATEMATICA SIGLA_UF NO_MUNICIPIO NU_QTD_ALUNO
				gen 	year = 2007
				rename (ID_ALUNO-COD_MUNICIPIO ID_TURMA-NU_THETA_M) 		 (id_student grade network location coduf codmunic id_class start_class end_class codschool 			  score_port sd_port score_saeb_port sd_saeb_port sd_math score_saeb_math sd_saeb_math score_math)
			}
			
			if `year' == 2009 {
				drop 	st_lingua_portuguesa st_matematica sigla_uf no_municipio
				gen 	year = 2009
				rename (id_aluno id_turma-nu_sethetat_m) 		    		 (id_student id_class class_time grade codschool network location  coduf codmunic  		   			 	  score_port sd_port score_saeb_port sd_saeb_port score_math sd_math score_saeb_math sd_saeb_math)
				tostring id_class, replace
			}
			save  "$inter/Prova Brasil Questionnaire_`year'.dta", replace
		}
	
		**
		* Socioeconomic questionnaire of 5th graders
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
			use  "$inter/Prova Brasil Questionnaire_`year'.dta" if grade == 4 | grade == 5, clear
			
			if `year' == 2007 {
				rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q12 Q13 Q14 Q16 Q17 Q15 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q33 Q34 Q35 Q36 Q37 Q38 Q39 Q40 Q41 Q42 Q43 ) ///
					   (gender skincolor month_birth age number_tv number_radio dvd number_fridge freezer wash_mash number_car computer_internet number_bath number_room n_family_members maid live_mother mother_edu mother_literate mother_reads live_father father_edu father_literate father_reads parents_sch_meetings incentive_study incentive_homework incentive_read incentive_school incentive_talk time_tv_games time_clean_house work enter_school type_school number_repetitions number_dropouts do_homework_port homework_corrected_port do_homework_math homework_corrected_math )
			}
			
			if `year' == 2009 {
				rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q10 Q11 Q12 Q13 Q14 Q16 Q17 Q15 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q33 Q34 Q35 Q36 Q37 Q38 Q39 Q40 Q41 Q42 Q43 ) ///
					   (gender skincolor month_birth age number_tv number_radio dvd number_fridge freezer wash_mash number_car computer_internet number_bath number_room n_family_members maid live_mother mother_edu mother_literate mother_reads live_father father_edu father_literate father_reads parents_sch_meetings incentive_study incentive_homework incentive_read incentive_school incentive_talk time_tv_games time_clean_house work enter_school type_school number_repetitions number_dropouts do_homework_port homework_corrected_port do_homework_math homework_corrected_math )			
			}
			
			drop Q*
			tempfile  5grade_`year'
			save 	 `5grade_`year''
		}
		
		**
		* Socioeconomic questionnaire of 9th graders
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
			use  "$inter/Prova Brasil Questionnaire_`year'.dta" if grade == 8 | grade == 9, clear
			
			if `year' == 2007 {
				rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q12 Q13 Q14 Q16 Q17 Q15 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q33 Q34 Q35 Q36 Q37 Q38 Q39 Q40 Q41 Q42 Q43 Q44 Q45 Q47 ) ///			
					   (gender skincolor month_birth year_birth number_tv number_radio dvd number_fridge freezer wash_mash number_car computer_internet number_bath number_room n_family_members maid live_mother mother_edu mother_literate mother_reads live_father father_edu father_literate father_reads parents_sch_meetings incentive_study incentive_homework incentive_read incentive_school incentive_talk time_tv_games time_clean_house work enter_school type_school number_repetitions number_dropouts like_port do_homework_port homework_corrected_port like_math do_homework_math homework_corrected_math aspiration )			
			}
			
			if `year' == 2009 {
				rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q10 Q11 Q12 Q13 Q14 Q16 Q17 Q15 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q33 Q34 Q35 Q36 Q37 Q38 Q39 Q40 Q41 Q42 Q43 Q44 Q45 Q47 ) ///					   
					   (gender skincolor month_birth year_birth number_tv number_radio dvd number_fridge freezer wash_mash number_car computer_internet number_bath number_room n_family_members maid live_mother mother_edu mother_literate mother_reads live_father father_edu father_literate father_reads parents_sch_meetings incentive_study incentive_homework incentive_read incentive_school incentive_talk time_tv_games time_clean_house work enter_school type_school number_repetitions number_dropouts like_port do_homework_port homework_corrected_port like_math do_homework_math homework_corrected_math aspiration )		
			}
			
			drop Q*
			tempfile  9grade_`year'
			save 	 `9grade_`year''
		}	
		
		**
		* -> Appending 5th and 9th grades
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
			clear
			append using `9grade_`year''
			append using `5grade_`year''
			compress
			save  "$inter/Prova Brasil Questionnaire_`year'.dta", replace
		} 

		**
		* -> Cleaning
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
		
			use "$inter/Prova Brasil Questionnaire_`year'.dta", clear
		
			if `year' == 2007 {
				destring start_class end_class, replace
				gen 	class_time = 1 if start_class >   650  & start_class < 1200  & !missing(start_class)
				replace class_time = 2 if start_class >=  1200 & start_class < 1800  & !missing(start_class) 
				replace class_time = 3 if start_class >=  1800 				         & !missing(start_class)
				drop 	start_class end_class
			}

			order 	year coduf codmunic codschool network location id_class class_time id_student grade month_birth year_birth age score_port-sd_saeb_math
			global 	variables age month_birth year_birth gender-aspiration
			format score* sd_* %12.2fc
				
				
			*Network
			*-----------------------------------------------------------------------------------------------------------------------*
			label define network 1 "Federal" 2 "State" 3 "Municipal" 4 "Private"
			label val 	 network network
			
			
			*Urban/rural
			*-----------------------------------------------------------------------------------------------------------------------*
			recode location (2 = 0)
			rename location urban
			label  define   urban 1 "Urban" 0 "Rural"
			label  val 	    urban urban
			
			
			*State
			*-----------------------------------------------------------------------------------------------------------------------*
			label define state 11 "RO" 12 "AC" 13 "AM" 14 "RR" 15 "PA" 16 "AP" 17 "TO"  					///
							   21 "MA" 22 "PI" 23 "CE" 24 "RN" 25 "PB" 26 "PE" 27 "AL" 28 "SE" 29 "BA" 		///
							   31 "MG" 32 "ES" 33 "RJ" 35 "SP" 												///
							   41 "PR" 42 "SC" 43 "RS" 														///
							   50 "MS" 51 "MT" 52 "GO" 53 "DF"
			label val coduf state

			
			*Turno
			*-----------------------------------------------------------------------------------------------------------------------*
			label define class_time 1 "Morning" 2 "Afternoon" 3 "Night" 
			label val 	 class_time class_time
				
				
			*Grade
			*-----------------------------------------------------------------------------------------------------------------------*
			recode 		 grade (4 = 5) (8 = 9)
			label define grade 5 "5{sub:th} grade" 9 "9{sub:th} grade"
			label val 	 grade grade
			
			
			*Enconding
			*-----------------------------------------------------------------------------------------------------------------------*
			foreach var of varlist $variables {
				replace `var' = "" if `var' == "*" | `var' == "."
				encode  `var', gen (`var'2)
				drop 	`var' 
				rename  `var'2 `var'
			}
			
			*Gender
			*-----------------------------------------------------------------------------------------------------------------------*
			label   define gender 2 "Female" 1 "Male"
			label   val    gender gender
			
			
			*Skin color
			*-----------------------------------------------------------------------------------------------------------------------*
			recode skincolor (6 = .)		//6 = "dont know my color"
			label define skincolor 1 "White" 2 "Brown" 3 "Black" 4 "Yellow" 5 "Indigenous"
			label val	 skincolor skincolor
			
			
			*Age
			*-----------------------------------------------------------------------------------------------------------------------*
			*5th graders
			recode age (1 = .) (2 = 9) (3 = 10) (4 = 11) (5 = 12) (6 = 13) (7 = 14) (8 = .)  if grade == 5		//1 = 8 or less /// 8 = 15 or more
			
			*9th graders
			label  val month_birth year_birth
			if `year' == 2007 | `year' == 2009 local year_b = 1994												//for 9th graders, instead of asking their age, they ask the year of birth
			forvalues i = 1(1)8 { 																				//student has 8 options with years of birth
				replace  year_birth   = `year_b'	 	if grade == 9 & year_birth == `i'						//since the test is applied in the end of the year, I will not make any age adjustment based on the month of birth
				local 	 year_b       = `year_b' - 1 
			}
			if `year' == 2007 | `year' == 2009	replace year_birth   = . if year_birth == 1994 | year_birth == 1987	
			replace age  = `year' - year_birth 	  		if grade == 9 & !missing(year_birth)
			drop 	month_birth year_birth	
			
			
			*Number of tv, radios, fridge, cars, baths, rooms
			*-----------------------------------------------------------------------------------------------------------------------*
			label  define number_tv  	    1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_radio		1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_car		1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_bath		1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_room		1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_computer	1 "One" 2 "Two"  3 "Three or more" 4 "Don't have"
			label  define number_fridge		1 "One" 2 "Two or more"  		   4 "Don't have"
			label  define computer_internet 1 "Computer + Internet" 2 "Computer, no internet" 3 "Don't have computer"	

			recode number_bath 		(4 = 3) (5 = 4)	//4 = 4 or more baths/rooms
			recode number_room 		(4 = 3) (5 = 4)
			recode number_fridge 			(3 = 4)
			
			foreach variable in number_tv number_radio number_car number_bath number_room number_fridge computer_internet {
					label val `variable' `variable' 
			}
			
			*Yes or no questions
			*-----------------------------------------------------------------------------------------------------------------------*
			recode live_mother 			(3 = 1)													//3 = woman responsible for the kid
			recode live_father 			(3 = 1) (4 = .)											//3 = man   responsible for the kid
			recode incentive_talk 		(3 = .)													//3 = error
			recode parents_sch_meetings (1 2 = 1) (3 = 0), gen (incentive_parents_meeting)
			recode freezer 	  			(3 = .)													//3 = dont know
			recode maid 		 		(2 = 1) (3 = 1) (4 = 2)		
			recode number_repetitions 	(1 = 0) (2 = 1) (3 = 2)  
			recode number_dropouts		(1 = 0) (2 = 1) (3 = 2)  
			
			foreach var of varlist mother_reads father_reads mother_literate father_literate {
				recode `var'        	(3 = .)					//3 = don't know. 
			}

			foreach item in tv radio car bath room fridge {		 //have or dont have in the house
				gen 	`item' = 0 if number_`item' == 4
				replace `item' = 1 if number_`item' <  4
			}
			
			gen     computer 	  		= 1				    if computer_internet  == 1 |  computer_internet == 2
			replace computer 	  		= 0 				if computer_internet  == 3
			gen 	ever_dropped  		= 1 				if number_dropouts    >= 1 & !missing(number_dropouts)
			replace ever_dropped  		= 0 				if number_dropouts    == 0 
			gen 	ever_repeated 		= 1 				if number_repetitions >= 1 & !missing(number_repetitions)
			replace ever_repeated 		= 0 				if number_repetitions == 0 
			
			label  define yesno 1 "Yes" 0 "No"
			foreach var of varlist tv radio car bath room fridge dvd wash_mash freezer incentive* mother_literate mother_reads father_literate father_reads work live_mother live_father like_port like_math maid ever_dropped ever_repeated computer {
				recode 		`var' (2 = 0) 
				label val 	`var' yesno
			}
			
			label define ever 0 "Zero" 1 "Yes, once" 2 "Twice or more"
			label val number_repetitions ever
			label val number_dropouts  	 ever

			
			*Mother and Father education
			*-----------------------------------------------------------------------------------------------------------------------*
			label define parents_edu 1 "Never studied or did not finish primary education" 2 "Elementar Education" 3 "Incomplete High School"  4 "Complete High School" 5 "Higher Education" 6 "Don't know"
			label val mother_edu parents_edu
			label val father_edu parents_edu
			
			
			*Time with tv or cleaning the house
			*-----------------------------------------------------------------------------------------------------------------------*
			recode time_tv_games    (1 5 = 1) (2 3 = 2) (4 = 3) 
			recode time_clean_house (1 5 = 1) (2 3 = 2) (4 = 3) 
			
			label  define time_tv_games			 1 "Don't watch or less than one hour"  2 "A couple hours" 3 "More than 3 hours" 
			label  val 	 time_tv_games time_tv_games

			label  define time_clean_house	 	 1 "Don't clean house or less than one" 2 "A couple hours" 3 "More than 3 hours" 
			label  val 	 time_clean_house time_clean_house
			
			
			*Number of household members
			*-----------------------------------------------------------------------------------------------------------------------*
			recode n_family_members (5 6 = 4)
			label define  n_family_members   1 "1 or 2" 2 "3" 3 "4" 4 "5 or more"
			label val 	  n_family_members n_family_members

			
			*Other
			*-----------------------------------------------------------------------------------------------------------------------*
			label define homework 		        1 "Always/Often"  2 "Sometimes"  3  "Never/Almost never" 	  4 "Don't have homework"
			
			foreach var of varlist  do_homework* homework_corrected* {
				label val `var' homework
			}
			 
			label define enter_school 		    1 "Daycare" 	  2 "Pre-school" 3 "Grade 1" 			   	  4 "After grade 1"
			label val 	 enter_school enter_school
			
			clonevar A = type_school
			replace type_school = .  if year < 2011 & grade == 5
			replace type_school = 1  if year < 2011 & grade == 5 & A == 2 					//only public school
			replace type_school = 1  if year < 2011 & grade == 5 & A == 1 & network <  4	//only public school		
			replace type_school = 2  if year < 2011 & grade == 5 & A == 1 & network == 4 	//current school is private and the student has always studied here. 
			replace type_school = 3  if year < 2011 & grade == 5 & A == 3 & network <  4 	//public and private
			replace type_school = 3  if 			  grade == 9 & A == 2 & network <  4	//there are 9th grade students that answered that only studied in private schools but the current school they are enrolled in is public....
			drop A
			
			label define type_school		    1 "Only public school" 		     2 "Only in private school"   3 "Public and private schools" 		
			label val 	 type_school type_school
			
			label define aspiration 		    1 "Only study" 				     2 "Only work"  			  3 "Study and work" 			4 "Don't know" 
			label val 	 aspiration aspiration
			
			gen 	only_intend_work =		  aspiration == 2 & grade == 9
			replace only_intend_work = . if  (aspiration == 4 & grade == 9) | (grade == 5)
					
			foreach var of varlist gender-ever_repeated {
				tab `var', mis
			}
		
			
			*Generate valid student dummy (score in both PT and MT)
			*-----------------------------------------------------------------------------------------------------------------------*
			gen 	byte valid_score = 1
			replace 	 valid_score = 0 if (score_port == . | score_math == .) | (score_port  == 0 & score_math == 0) 
			
			
			*Male, white, parent's education
			*-----------------------------------------------------------------------------------------------------------------------*
			recode gender     (1 = 1) (2 = 0)					, gen (male)
			recode skincolor  (1 = 1) (2 3 4 5 = 0)				, gen (white)
			recode mother_edu (4 5 = 1) (1 2 3 = 0) (6 = .)		, gen (mother_edu_highschool)	 //high school or more
			recode father_edu (4 5 = 1) (1 2 3 = 0) (6 = .)		, gen (father_edu_highschool)	

			
			*Socioeconomic Index
			*-----------------------------------------------------------------------------------------------------------------------*
			egen 	temp1 			    = rowmiss(number_fridge number_tv  number_car  number_bath number_room)
			egen 	socio_eco 	 		= rowmean(number_fridge number_tv  number_car  number_bath number_room)
			replace socio_eco 	 		= . if temp1 > 2
			drop 	temp1
			format socio_eco %4.2fc	
							
							
			*Students effort
			*-----------------------------------------------------------------------------------------------------------------------*
			recode 		do_homework_port (1 = 1) (2 3 = 0) (4 = .)  		if valid_score!= 0, gen (do_homework_port_always)
			recode 		do_homework_math (1 = 1) (2 3 = 0) (4 = .)  		if valid_score!= 0, gen (do_homework_math_always)

			gen     	do_homework_both_always = 1 			    		if valid_score!= 0 & 	 do_homework_port_always 		== 1 & do_homework_math_always 		 == 1
			replace 	do_homework_both_always = 0 			    		if valid_score!= 0 & 	(do_homework_port_always 		== 0 | do_homework_math_always 		 == 0) & !missing(do_homework_port_always) & !missing(do_homework_math_always)

			
			*Teacher's effort
			*-----------------------------------------------------------------------------------------------------------------------*
			recode 		homework_corrected_port  (1 = 1) (2 3 = 0) (4 = .) 	if valid_score!= 0, gen (homework_corrected_port_always)
			recode 		homework_corrected_math  (1 = 1) (2 3 = 0) (4 = .) 	if valid_score!= 0, gen (homework_corrected_math_always)
			
			gen     	homework_corrected_both_always = 1 			   	 	if valid_score!= 0 &  	 homework_corrected_port_always == 1 & homework_corrected_math_always == 1
			replace 	homework_corrected_both_always = 0 			    	if valid_score!= 0 & 	(homework_corrected_port_always == 0 | homework_corrected_math_always == 0) & !missing(homework_corrected_port_always) & !missing(homework_corrected_math_always)

			
			*Parents in school meetings
			*-----------------------------------------------------------------------------------------------------------------------*
			label 		define frequency  		    1 "Always/Often"  2 "Sometimes"  3  "Never/Almost never"
			label 		val    parents_sch_meetings	 frequency	
			
			
			*Private school and preschool
			*-----------------------------------------------------------------------------------------------------------------------*
			recode 		type_school  (2 3 = 1) (1    = 0),  gen (private_school)	//student already enrolled in a private school
			recode 		enter_school (1 2 = 1) (3 4  = 0),  gen (preschool)		//student did preschool
			
			
			*-----------------------------------------------------------------------------------------------------------------------*
			order 		year-sd_saeb_math valid_score age gender skincolor n_family_members enter_school type_school ever_* work aspiration time* number* radio dvd tv car bath room wash_mash freezer fridge maid computer computer_internet socio_eco incentive* mother* father*
		    compress
			save  "$inter/Prova Brasil Questionnaire_`year'.dta", replace
		}

		**
		* -> Appending years
		*--------------------------------------------------------------------------------------------------------------------------*
		**
			clear
			forvalues year = 2007(2)2009 {
				append using   "$inter/Prova Brasil Questionnaire_`year'.dta"
				erase 		   "$inter/Prova Brasil Questionnaire_`year'.dta"
			}
			
			*Insufficient, basic or adequate performance
			*-----------------------------------------------------------------------------------------------------------------------*
			gen 	math_insuf = 1 if grade == 5 & score_saeb_math <  200
			gen 	math_basic = 1 if grade == 5 & score_saeb_math >= 200	 &  		score_saeb_math < 275
			gen 	math_adequ = 1 if grade == 5 & score_saeb_math >= 275 	 & !missing(score_saeb_math)
			replace math_insuf = 1 if grade == 9 & score_saeb_math <  275
			replace math_basic = 1 if grade == 9 & score_saeb_math >= 275	 & 		    score_saeb_math < 350
			replace math_adequ = 1 if grade == 9 & score_saeb_math >= 350	 & !missing(score_saeb_math)
			gen 	port_insuf = 1 if grade == 5 & score_saeb_port <  200
			gen 	port_basic = 1 if grade == 5 & score_saeb_port >= 200	 & 		    score_saeb_port < 275
			gen 	port_adequ = 1 if grade == 5 & score_saeb_port >= 275	 & !missing(score_saeb_port)
			replace port_insuf = 1 if grade == 9 & score_saeb_port <  275
			replace port_basic = 1 if grade == 9 & score_saeb_port >= 275 	 & 		    score_saeb_port < 350
			replace port_adequ = 1 if grade == 9 & score_saeb_port >= 350 	 & !missing(score_saeb_port)
			
			foreach var of varlist math_insuf-math_adequ     {
				replace `var' = 0 if !missing(score_saeb_math) & `var' != 1
			}	
				foreach var of varlist port_insuf-port_adequ {
				replace `var' = 0 if !missing(score_saeb_port) & `var' != 1
			}	
			
			gen 	performance_insuf =   port_insuf == 1 | math_insuf == 1
			gen 	performance_basic =  (port_basic == 1 | math_basic == 1) & performance_insuf == 0
			gen 	performance_adequ =  (port_adequ == 1 & math_adequ == 1) 
			replace performance_insuf = . if port_insuf  == . & math_insuf == .
			replace performance_basic = . if port_basic  == . & math_basic == .
			replace performance_adequ = . if port_adequ  == . & math_adequ == .
			
			
			*-----------------------------------------------------------------------------------------------------------------------*
			gen treated   		= .				//1 for closed schools, 0 otherwise
			gen id_13_mun 		= 0				//1 for the 13 municipalities that extended the winter break, 0 otherwise
			gen G	  			= 1				//0 for the 13 municipalities that extended the winter break, 1 otherwise

			
			foreach munic in $treated_municipalities {
				replace treated   = 1 if codmunic == `munic' & network == 3
				replace id_13_mun = 1 if codmunic == `munic'
				replace G	  	  = 0 if codmunic == `munic'
			}		
			
			replace treated    = 1 if network == 2
			replace treated    = 0 if treated == .
			
			
			*Labels
			*-----------------------------------------------------------------------------------------------------------------------*
			label variable math_insuf						"Insufficient performance in Math"
			label variable math_basic						"Basic performance in Math"
			label variable math_adequ						"Adequate performance in Math"
			label variable port_insuf						"Insufficient performance in Portuguese"
			label variable port_basic						"Basic performance in Portuguese"
			label variable port_adequ						"Adequate performance in Portuguese"
			label variable performance_insuf				"Insufficient performance in Math and Portuguese"
			label variable performance_basic				"Basic performance in Math and Portuguese"
			label variable performance_adequ				"Adequate performance in Math and Portuguese"
			label variable male								"Male student"
			label variable white 							"White student"
			label variable coduf 							"State ID"
			label variable codmunic 						"Municipality ID"
			label variable codschool 						"School ID"
			label variable network 							"School administrative network"
			label variable grade 							"Grade"
			label variable id_student 						"Student ID"
			label variable year 							"Year"
			label variable age 								"Student's age"
			label variable urban							"1: Urban area. 0: Rural area"
			label variable class_time						"1: Morning. 2: Afternoon. 3: Night"
			label variable id_class							"Code of the class - you can check students in the same classroom"
			label variable gender							"Student's gender"
			label variable skincolor   						"Student's skin color"
			label variable mother_edu  						"Mother's education (highest degree acquired)"
			label variable father_edu  						"Father's education (highest degree acquired)"
			label variable parents_sch_meetings 			"Parental attendance to school meetings"
			label variable incentive_study 					"Parents encourage to study"
			label variable incentive_homework 				"Parents encourage to do the homework"
			label variable incentive_read 					"Parents encourage to read"
			label variable incentive_school 				"Parents encourage to go to school"
			label variable incentive_talk 					"Parents talk about what happens in the school"	
			label variable incentive_parents_meeting		"Parents go to parent's meeting"
			label variable time_tv_games					"Leisure time spent on TV, games, internet during on a school day"
			label variable time_clean_house 				"Leisure time spent on domestic activities during on a school day"
			label variable enter_school 					"When the student started school"
			label variable number_repetitions				"Number of repetitions"
			label variable number_dropouts					"Number of dropouts"
			label variable do_homework_port 				"Frequency that you do your Portuguese homework"
			label variable do_homework_math  				"Frequency that you do your Math homework"
			label variable homework_corrected_port  		"Frequency that your Portuguese teacher corrects the homework"
			label variable homework_corrected_math  		"Frequency that your Math teacher corrects the homework"
			label variable aspiration 						"Student aspiration after middle school"
			label variable number_tv 						"Number of TVs in the household"
			label variable number_radio 					"Number of radios in the household"
			label variable dvd 								"DVD in the household"
			label variable number_fridge 					"Number of fridges in the household"
			label variable wash_mash 						"Washing machine in the household"
			label variable number_car 						"Number of cars in the household"
			label variable computer_internet 				"1: Computer + Internet. 2: Computer and no Internet. 3: Don’t have computer."
			label variable number_bath 						"Number of baths in the household"
			label variable number_room 						"Number of rooms in the household"
			label variable n_family_members 				"Number of family members"
			label variable maid 							"Maid in the household"
			label variable live_mother 						"Student lives with mother (or legal responsible)"
			label variable mother_literate 					"Student's mother knows how to read and write"
			label variable mother_reads 					"Student sees mother reading"
			label variable live_father 						"Student lives with father (or legal responsible)"
			label variable father_literate 					"Student's father knows how to read and write"
			label variable father_reads 					"Student sees father reading"
			label variable tv 								"TV in the household"
			label variable radio 							"Radio in the household"
			label variable car								"Car in the household"
			label variable bath 							"Bath in the household"
			label variable room 							"Room in the household"
			label variable fridge 							"Fridge in the household"
			label variable computer 						"Computer in the household"
			label variable ever_dropped 					"Student has ever dropped and 0, otherwise"
			label variable ever_repeated 					"Student has ever repeated and 0, otherwise"
			label variable valid_score 						"Student has performance data for Portuguese and Math"
			label variable socio_eco 						"Socioeconomic Indicador for Household"
			label variable sd_port 							"Standard deviation of portuguese score (mean = 0, sd = 1)"
			label variable sd_saeb_port 					"Standard deviation of portuguese score (SAEB scale)"
			label variable sd_math 							"Standard deviation of math score (mean = 0, sd = 1)"
			label variable sd_saeb_math 					"Standard deviation of math score (SAEB scale)"
			label variable score_port 						"Portuguese score (mean = 0, sd = 1)"
			label variable score_saeb_port 					"Portuguese score (SAEB scale)"
			label variable score_math 						"Math score (mean = 0, sd = 1)"
			label variable score_saeb_math 					"Math score (SAEB scale)"
			label variable freezer 							"Freezer in the household"
			label variable work 							"Student works"
			label variable type_school 						"Type of school since 1st/grade for 5th/graders, and since 6th/grade for 9th"
			label variable like_port 						"Student that likes portuguese"
			label variable like_math 						"Student that likes math"
			label variable mother_edu_highschool 			"Student's mother finished high school"
			label variable father_edu_highschool 			"Student's father finished high school"
			label variable only_intend_work					"Children only intend to work after 9th grade"
			label variable do_homework_port_always 			"Children always finish the homework"
			label variable do_homework_math_always 			"Children always finish the homework"
			label variable do_homework_both_always 			"Children always finish the homework"
			label variable homework_corrected_port_always   "Teacher always corrects the homework"
			label variable homework_corrected_math_always 	"Teacher always corrects the homework"
			label variable homework_corrected_both_always 	"Teacher always corrects the homework"
			label variable private_school 					"Already attended Private School"
			label variable preschool						"Children did preschool"
			compress
			save "$inter/Students - Prova Brasil.dta", replace
			
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Teacher Data
	**
	*________________________________________________________________________________________________________________________________* 
		
		**
		* -> Renaming variables
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		forvalues year = 2007(2)2009 {
			use "$inter/Teachers_`year'.dta", clear
				if `year' == 2007 {
					gen 	 year = 2007
					drop 	 NO_MUNICIPIO SIGLA_UF  DS_DISCIPLINA
					rename  (PK_COD_ENTIDADE-ID_SERIE) (codschool network location coduf codmunic id_class grade)
					rename (Q1 Q2 Q3 Q4 Q5 Q6 Q8 Q9 Q10 Q16 Q15 Q17 Q18 Q19 Q23 Q20 Q21 Q22 Q47 Q49 Q52 Q53 Q54 Q77 Q78 Q79 Q73 Q76 Q80 Q74 Q82 Q83 Q59 Q60 Q63 Q64 Q66 Q67 Q68 Q69 Q72 Q71 Q65 Q94 Q114 Q115 Q118 Q119 Q120 Q121 Q122 Q123 Q56 Q57 Q58 Q130 Q126 Q127 Q131 Q55 ) ///
							   (teacher_gender teacher_age_range teacher_skincolor teacher_edu teacher_years_graduation type_university type_education postgrad area_postgrad teacher_wage teacher_other_job experience_asteacher teacher_exp_school teacher_exp_grade teacher_work_contract teacher_workhours_school nu_schools_work teacher_workhours_total use_news use_literature_books use_copy_machine pedagogic_plan meetings_class_council principal_learning principal_norms principal_maintenance principal_motivation principal_innovation principal_respect principal_trust work_decisions my_ideas def_schoolinfra def_curricula def_cover_curricula def_2muchwork def_teacher_insatisfaction def_student_socioback def_parents_culturalback def_noparents_support def_low_selfesteem def_student_loweffort def_bad_behavior def_absenteeism violence_lifethreat violence_student_threat violence_theft violence_robb violence_students_alcohol violence_students_drugs violence_students_knife violence_students_gun expec_finish_grade9 expec_finish_grade12 expec_get_college received_book students_books books_since_beg_year quality_books share_curricula )
				}
					
				if `year' == 2009 {
					drop 	 no_municipio sigla_uf
					gen 	 year = 2009
					rename  (pk_cod_entidade-id_serie)(codschool network location coduf codmunic id_class grade)
					rename  (Q1 Q2 Q3 Q4 Q5 Q6 Q8 Q9 Q10 Q16 Q15 Q17 Q18 Q19 Q23 Q20 Q21 Q22 Q47 Q50 Q54 Q55 Q56 Q81 Q82 Q83 Q77 Q80 Q84 Q78 Q86 Q87 Q63 Q66 Q67 Q68 Q69 Q70 Q71 Q72 Q74 Q75 Q76 Q98 Q118 Q119 Q122 Q123 Q124 Q125 Q126 Q127 Q60 Q61 Q62 Q134 Q130 Q131 Q135 Q59 ) ///
							(teacher_gender teacher_age_range teacher_skincolor teacher_edu teacher_years_graduation type_university type_education postgrad area_postgrad teacher_wage teacher_other_job experience_asteacher teacher_exp_school teacher_exp_grade teacher_work_contract teacher_workhours_school nu_schools_work teacher_workhours_total use_news use_literature_books use_copy_machine pedagogic_plan meetings_class_council principal_learning principal_norms principal_maintenance principal_motivation principal_innovation principal_respect principal_trust work_decisions my_ideas def_schoolinfra def_curricula def_cover_curricula def_2muchwork def_teacher_insatisfaction def_student_socioback def_parents_culturalback def_noparents_support def_low_selfesteem def_student_loweffort def_bad_behavior def_absenteeism violence_lifethreat violence_student_threat violence_theft violence_robb violence_students_alcohol violence_students_drugs violence_students_knife violence_students_gun expec_finish_grade9 expec_finish_grade12 expec_get_college received_book students_books books_since_beg_year quality_books share_curricula )
							 tostring id_class, replace
					}
					
				drop Q*
				destring codschool network location coduf codmunic grade, replace
				tempfile `year'
				save 	``year''
				erase "$inter/Teachers_`year'.dta"
			}
			
		**
		* -> Appending years
		*----------------------------------------------------------------------------------------------------------------------------*
		**
			clear 		
			forvalues year = 2007(2)2009 {
				append using ``year''
			}
			order year coduf codmunic codschool  network location id_class grade

		**
		* -> Cleaning
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		
		
			*Network
			*------------------------------------------------------------------------------------------------------------------------*
			label define network 1 "Federal" 2 "State" 3 "Municipal" 4 "Private"
			label val 	 network network
		
		
			*Urban/rural
			*------------------------------------------------------------------------------------------------------------------------*
			recode location (2 = 0)
			rename location urban
			label  define   urban 1 "Urban" 0 "Rural"
			label  val 	    urban urban
			
			
			*State
			*------------------------------------------------------------------------------------------------------------------------*
			label define state 11 "RO" 12 "AC" 13 "AM" 14 "RR" 15 "PA" 16 "AP" 17 "TO"  					///
							   21 "MA" 22 "PI" 23 "CE" 24 "RN" 25 "PB" 26 "PE" 27 "AL" 28 "SE" 29 "BA" 		///
							   31 "MG" 32 "ES" 33 "RJ" 35 "SP" 												///
							   41 "PR" 42 "SC" 43 "RS" 														///
							   50 "MS" 51 "MT" 52 "GO" 53 "DF"
			label val coduf state

			
			*Grade
			*------------------------------------------------------------------------------------------------------------------------*
			recode 		 grade (4 = 5) (8 = 9) (13 =12)
			label define grade 5 "5{sub:th} grade" 9 "9{sub:th} grade" 12 "Last year of high school"
			label val 	 grade grade
			
			
			*Enconding
			*------------------------------------------------------------------------------------------------------------------------*
			foreach var of varlist  teacher_gender-quality_books {
				replace `var' = "" if `var' == "*" | `var' == "."
				encode  `var', gen (`var'2)
				drop 	`var' 
				rename  `var'2 `var'
			}
			
			*teacher_gender
			*------------------------------------------------------------------------------------------------------------------------*
			label   define teacher_gender    2 "Feteacher_male" 1 "teacher_male"
			label   val    teacher_gender teacher_gender
			
			
			*Age
			*------------------------------------------------------------------------------------------------------------------------*
			label 	define teacher_age_range 1 "Up to 24 years old" 2 "Between 25-29 years old" 3 "Between 30 and 39 years old" 4 "Between 40 and 49 years old"  5 "Between 50 and 54 years old"  6 "More than 55 years old"
			label 	val    teacher_age_range teacher_age_range
			
			
			*Skin color
			*------------------------------------------------------------------------------------------------------------------------*
			recode 		   teacher_skincolor (6 7 = .)		//6 = "dont know my color"
			label 	define teacher_skincolor 1 "teacher_white" 2 "Brown" 3 "Black" 4 "Yellow" 5 "Indigenous"
			label 	val	   teacher_skincolor teacher_skincolor
			
			
			*Teacher Education
			*------------------------------------------------------------------------------------------------------------------------*
			label  	define teacher_edu  				1 "Less than high school"   2 "High school"  		3 "Undergraduate/Pedagogy"  4 "Undergraduate/Math"   5 "Undergraduate/Portuguese" 6 "Undergraude/others"
			label  	define teacher_years_graduation  	1 "Less than 2 years" 		2 "Between 3-7 years" 	3 "Between 8-14 yars" 		4 "Betweeen 15-20 years" 5 "More than 20 years" 
			label  	define postgrad   					1 "No grad. certificate"    2 "Short Course" 		3 "Specialization" 			4 "Masters" 			 5 "Phd"
			label 	define type_university 				1 "Federal"				    2 "State" 				3 "Municipal" 				4 "Private" 
			label 	define type_education 				1 "Face to Face"  		    2 "Face/Distance" 		3 "Distance Learning"  
			label 	define area_postgrad 				1 "Education" 			    0 "Other field" 
			recode 	teacher_edu 			(1 = 1) (2 3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 8 = 6)   	if year <  2013
			recode 	teacher_edu 			(1 = 1) (2 3 = 2) (4 = 3) (6 = 4) (7 = 5) (5 8 9 = 6) 	if year >= 2013
			recode 	postgrad 				(5 = 1) (1   = 2) (2 = 3) (3 = 4) (4 = 5)   		  	if year <  2013
			recode  type_university 		(5 = .) 								  		 		if year <  2013
			recode 	type_university 		(1 = .) (2   = 4) (3 = 1) (4 = 2) (5 = 3) 				if year >= 2013
			recode 	type_education	 		(4 = .) 												if year <  2013
			recode 	type_education 			(1 = .) (2   = 1) (3 = 2) (4 = 3) 						if year >= 2013
			recode 	area_postgrad 			(1 2 3   = 1) (4 = 0) (5 = .) 							if year <  2011
			recode 	area_postgrad 			(1 2 3 4 = 1) (5 = 0) 		   							if year == 2011
			recode 	area_postgrad 			(2 3 4 5 = 1) (6 = 0) (1 = .) 							if year >  2011
			label  	val teacher_years_graduation teacher_years_graduation
			label  	val teacher_edu teacher_edu
			label  	val postgrad postgrad
			label 	val type_university type_university
			label   val type_education type_education
			label   val area_postgrad area_postgrad

					
			*Teacher Experience
			*------------------------------------------------------------------------------------------------------------------------*
			label  	define experience 		  1 "First year"    2 "1-2 years"     3 "3-5 years"         4 "6-10 years" 5 "11-15 years" 6 "16-20 years" 7 "More than 20 years"
			label  	define teacher_exp_grade   1 "Up to 2 years" 2 "Between 3-6 years" 3 "More than 6 years" 
			recode 	experience_asteacher 	(4 5 = 4) (6   = 5) (7 = 6) (8 = 7) if year == 2011
			recode 	teacher_exp_school    	(4 5 = 4) (6   = 5) (7 = 6) (8 = 7) if year == 2011
			recode 	teacher_exp_grade 		(1   = 1) (2 3 = 2) (4 5     = 3) 	if year <  2013
			recode 	teacher_exp_grade 		(1 2 = 1) (3   = 2) (4 5 6 7 = 3)   if year >= 2013
			label   val teacher_exp_grade teacher_exp_grade
			label   val experience_asteacher experience  
			label   val teacher_exp_school    experience 

			
			*Type of contract/teacher_wage
			*------------------------------------------------------------------------------------------------------------------------*
			label 	define teacher_work_contract 	4 "No contract"				 			5 "Other" 								3  "Temporary contract" 				 2 "CLT" 							1 "Tenure (estatutário)" 
			label 	define hours_worked 			1 "More than 40 hours" 					2 "40 hours" 							3  "Between 20-39 hours" 		 		 4 "Less than 20 hours" 
			
			label 	define teacher_wage 			1 "Up to one minimum teacher_wage" 	  	2 "Between 1-1.5 minimum teacher_wage"  3  "Between 1.5-2 minimum teacher_wages" 4 "Between 2-2.5 minimum teacher_wages" ///
													5 "Between 2.5-3 minimum teacher_wages" 6 "Between 3-3.5 minimum teacher_wages" 7  "Between 3.5-4 minimum teacher_wages" 8 "Between 4-5 minimum teacher_wages"   ///
													9 "Between 5-7 minimum teacher_wages"   10 "Between 7-10 minimum teacher_wages" 11 "More than 10 minimum ages"
			label   define nu_schools_work  		1 "One school" 							2 "Two schools" 						3  "Three schools"				 		 4 "Four schools or more" 
			label   define teacher_other_job		1 "Yes, in education area"				2 "Yes, in other field"					3  "Don't have another job"
			
			
			replace teacher_wage = . if year == 2007
			recode  teacher_workhours_school (1 2 = 4) (3 4 5 6 7 8 9 = 3) (10 = 2) (11    = 1)  if year == 2007  
			recode  teacher_workhours_school (1   = 4) (2 3 4 5 6 7   = 3) (8  = 2) (9     = 1)  if year == 2009 | year == 2011  
			recode  teacher_workhours_total  (1 2 = 4) (3 4 5 6 7 8 9 = 3) (10 = 2) (11 12 = 1)  if year == 2007  
			recode  teacher_workhours_total  (1   = 4) (2 3 4 5 6 7   = 3) (8  = 2) (9  	  = 1)  if year == 2009 | year == 2011  
			label   val teacher_workhours_school hours_worked
			label   val teacher_workhours_total  hours_worked
			label   val teacher_work_contract teacher_work_contract
			label   val teacher_wage teacher_wage
			label   val nu_schools_work nu_schools_work
			label   val teacher_other_job teacher_other_job
			
			
			*Teacher uses in the class
			*------------------------------------------------------------------------------------------------------------------------*
			label   define use 0 "No/Never" 1 "Yes" 2 "School does not have"
			recode  use_news 			 (2 = 0) (3 = 2) 			 if year <   2013
			recode  use_literature_books (2 = 0) (3 = 2) 			 if year <   2013
			recode  use_copy_machine	 (2 = 0) (3 = 2) 			 if year <   2013
			recode  use_news 			 (1 = 2) (2 = 0) (3 4 = 1)   if year >=  2013
			recode  use_literature_books (1 = 2) (2 = 0) (3 4 = 1)   if year >=  2013
			recode  use_copy_machine	 (1 = 2) (2 = 0) (3 4 = 1)   if year >=  2013
			label   val use_news 			 use
			label   val use_literature_books use
			label   val use_copy_machine 	 use		
			label 	define  share_curricula 1 "Less than 40%" 2 "Between 40-60%" 3 "Between 60-80%" 4 "More than 80%"
			recode  		share_curricula (1 2 = 1) (3 = 2) (4 = 3) (5 = 4) if year >= 2013
			label 	val  	share_curricula share_curricula


			*Other
			*------------------------------------------------------------------------------------------------------------------------*
			label  define  yesno 							1 "Yes" 						0 "No"
			label  define  meetings_class_council  			1 "Once" 						2 "Twice"   								3 "Three times or more"  				  4 "None"  				5 "No school council"
			
			label  define  pedagogic_plan  					1 "No pedag. project" 				2 "Modelo pronto, sem discussão da equipe"			///
			3  "Modelo pronto com algumas modificações/modelo próprio mas sem teacher's active involvement" 4 "With active teacher's involvement"

			
			label  define  frequency				 		1 "Never" 						2 "Sometimes" 								3 "Often" 								  4 "Always"
			label  define  expectations 					1 "Few students" 				2 "Little less than half of the students" 	3 "Little more than half of the students" 4 "Almost all students"
			label  define  students_books				 	1 "No textbooks" 				2 "Less than half" 							3 "Half" 								  4 "Most of them" 			5 "All"
			label  define  quality_books 					1 "Bad" 						2 "Ok"						 				3 "Good" 								  4 "Great" 
			recode meetings_class_council 		(3     = 1) (4 = 2) 		(5 = 3) (2 = 4) (1 = 5)  		if year >= 2013
			recode pedagogic_plan 				(8 = 1) (1 = 2 ) (2   = 3) (3 4 5 = 4) (6 7 = .)			if year <  2013
			recode pedagogic_plan 				(2 = 1) (3 = 2 ) (5 7 = 3) (4 6 8 = 4) (1   = .) 			if year >= 2013
			
			recode students_books 				(5 = 1) 	(4 = 2) 		(3 = 3) (2 = 4) (1 = 5) 		if year <  2013
			recode quality_books 				(5 = .) 	(4 = 1) 		(3 = 2) (2 = 3) (1 = 4) 		if year <  2013
			recode quality_books 				(1 = .) 	(2 = 1) 		(3 = 2) (4 = 3) (5 = 4) 		if year >= 2013


			foreach var of varlist principal_* work_decisions my_ideas* {
				recode 		`var' (4 5 = 1) (3 = 2) (2 = 3) (1 = 4) 		if year < 2013
				label val 	`var' frequency
			}
			
			foreach var of varlist expec_* {
				recode 		`var' (4 = 1) (3 = 2) (2 = 3) (1 = 4) (5 = .) 	if year < 2013
				label  val 	`var' expectations
			}
			
			foreach var of varlist def_schoolinfra def_schoolinfra-def_low_selfesteem violence* received_book books_since_beg_year    {
				recode 	  `var' (1 = 1) (2 = 0) (3 = .)
				label val `var' yesno 
			}
			
			label   define  problem   0 "Not an issue" 					1 "Small" 											2 "A moderate/big issue"
			recode	def_absenteeism (1 = 0) (2   = 1) (3 4 = 2) if year >= 2013
			recode 	def_absenteeism (1 = 0) (2   = 1) (3   = 2) if year <  2013
			label 	val def_absenteeism  problem
			label   val students_books students_books
			label   val pedagogic_plan pedagogic_plan
			label   val meetings_class_council meetings_class_council
			label   val quality_books quality_books
			
			*Defining new variables
			*------------------------------------------------------------------------------------------------------------------------*
			**
			*teacher_males, teacher_whites and college degree
			**
			recode teacher_gender     	  (1 = 1) (2 = 0)					, gen (teacher_male)
			recode teacher_skincolor  	  (1 = 1) (2 3 4 5 = 0)				, gen (teacher_white)
			recode teacher_edu 			  (3 4 5 6 = 1) (2 1 = 0)			, gen (teacher_college_degree)
			recode teacher_work_contract  (1 = 1) (2 3 4 5 = 0)				, gen (teacher_tenure) 
			recode teacher_age_range	  (1 2 3 = 1) (4 5 6 = 0)			, gen (teacher_less_40years)
			recode teacher_wage			  (1/5 = 1) (6/11 = 0)				, gen (teacher_less3min_wages)
			recode experience_asteacher   (1/4 = 0) (5/7  = 1)				, gen (teacher_more10yearsexp)
			
			label  val teacher_male   				  yesno
			label  val teacher_white  				  yesno
			label  val teacher_tenure 				  yesno
			label  val teacher_less_40years   yesno
			label  val teacher_college_degree yesno

			**
			*Principal effort according to teacher's perspective
			**
			egen temp1 = rowmiss(principal_motivation-my_ideas)
			foreach var of varlist principal_motivation-my_ideas{
				recode `var' (1=0) (2=0.33) (3=0.66) (4=1), gen(II_`var')
			}
			egen principal_effort_index   = rowmean(II_*) if temp1 < 4
			drop II_* temp1
			
			**
			*Teacher's effort ???????????????????????????? -> Segui o Do file do Thomaz
			**
			gen teacher_effort_index      = use_literature_books + use_news/2  if !missing(use_literature_books) & !missing(use_literature_books)
			
			**
			*Parent's effort
			**
			gen parents_effort_index      = def_noparents_support
			
			**
			*Student's effort
			**
			egen 	temp1 = 			    rowmiss(def_student_loweffort def_absenteeism def_bad_behavior)
			egen 	student_effort_index  = rowmean(def_student_loweffort def_absenteeism def_bad_behavior)
			replace student_effort_index  = . if temp1 > 1
			drop 	temp1

			**
			*Violence in the school
			**
			egen 	temp1 = 		 	    rowmiss(violence_lifethreat-violence_students_gun)
			egen 	violence_index 		  = rowmean(violence_lifethreat-violence_students_gun)
			replace violence_index 		  = . if temp1 > 3
			drop 	temp1
		
			
			**
			*Teacher's expectations with their students
			**
			recode expec_finish_grade9  (1 2 3 = 0) (4 = 1), gen (almost_all_finish_grade9)
			recode expec_finish_grade12 (1 2 3 = 0) (4 = 1), gen (almost_all_finish_highschool)
			recode expec_get_college    (1 2 3 = 0) (4 = 1), gen (almost_all_get_college)
			label  val almost_all_finish_grade9 	    yesno
			label  val almost_all_finish_highschool 	yesno
			label  val almost_all_get_college	   		yesno
			
			label  val teacher_less3min_wages	   		yesno
			label  val teacher_more10yearsexp	   		yesno
			
			format *index* %4.2fc
			
			**
			*Other variables
			**
			tab share_curricula, gen(covered_curricula) 
			tab	work_decisions , gen(participation_decisions)
			tab students_books , gen(share_students_books)
			tab quality_books  , gen(quality_books)
			

			*-----------------------------------------------------------------------------------------------------------------------*
			gen treated   		= .				//1 for closed schools, 0 otherwise
			gen id_13_mun 		= 0				//1 for the 13 municipalities that extended the winter break, 0 otherwise
			gen G	  			= 1				//0 for the 13 municipalities that extended the winter break, 1 otherwise

			
			foreach munic in $treated_municipalities {
				replace treated   = 1 if codmunic == `munic' & network == 3
				replace id_13_mun = 1 if codmunic == `munic'
				replace G	  	  = 0 if codmunic == `munic'
			}		
			
			replace treated    = 1 if network == 2
			replace treated    = 0 if treated == .

			
			*Labels
			*------------------------------------------------------------------------------------------------------------------------*
			label variable principal_effort_index			"Principal's effort from teacher's perspective"
			label variable teacher_effort_index 			"Teacher's effort based on the use of news and literature books" 	
			label variable parents_effort_index 			"1 if parents support children (from teacher's perspective) and 0, otherwise"
			label variable student_effort_index				"Student's effort from teacher's perspective"
			label variable violence_index					"Index for the violence the teacher faces in the school"
			label variable almost_all_finish_grade9			"Teacher expects that almost all students will finish 9th grade"
			label variable almost_all_finish_highschool		"Teacher expects that almost all students will finish high school "
			label variable almost_all_get_college 			"Teacher expects that almost all students will get to college"
			label variable teacher_college_degree		    "Teacher finished the undergraduate and 0, otherwise"
			label variable teacher_male						"Male teachers"
			label variable teacher_white					"White teachers" 
			label variable teacher_age_range				"Teacher's age range"
			label variable teacher_years_graduation			"Years since graduation"
			label variable type_university					"1: Federal. 2: State. 3: Municipal. 4: Private"
			label variable type_education					"1: Face to face. 2: Face to face/distance. 3: Distance learning"
			label variable def_schoolinfra					"Deficit in student learning is due to: poor school infra/pedagogic"
			label variable def_curricula					"Deficit in student learning is due to: no adequate curricula"
			label variable def_cover_curricula				"Deficit in student learning is due to: not covering the curricula"
			label variable def_2muchwork					"Deficit in student learning is due to: teachers don't have time to plan"
			label variable def_teacher_insatisfaction		"Deficit in student learning is due to: teachers insatisfaction with teacher_wages"
			label variable def_student_socioback			"Deficit in student learning is due to: socioeconomic background"
			label variable def_parents_culturalback			"Deficit in student learning is due to: cultural background of the parents"
			label variable def_noparents_support			"Deficit in student learning is due to: no parents support"
			label variable def_low_selfesteem				"Deficit in student learning is due to: student's low self esteem"
			label variable def_student_loweffort			"Deficit in student learning is due to:	student's low effort"
			label variable def_bad_behavior					"Deficit in student learning is due to: student's bad behavior"
			label variable def_absenteeism					"Deficit in student learning is due to: student missing the classes"
			label variable violence_lifethreat  			"Teacher have ever had their life threatened in this school"
			label variable violence_student_threat  		"Teacher already had a student threatening your life in school" 
			label variable violence_theft  					"Teacher victim of theft in school? (no violence) "
			label variable violence_robb  					"Teacher victim of theft in school? (with iolence) "
			label variable violence_students_alcohol  		"Teacher already had a student in class under influence of alcohol"
			label variable violence_students_drugs  		"Teacher already had a student in class under infl. drugs"
			label variable violence_students_knife  		"Teacher already had a student in class with a knif "
			label variable violence_students_gun 			"Teacher already had a student in class with a gun"
			label variable expec_finish_grade9  			"How many students do you think will finish the 9th grade?"
			label variable expec_finish_grade12 			"How many students do you think will finish the high school?"
			label variable expec_get_college 				"How many students do you think will get to college?"
			label variable teacher_edu 						"Teacher's education"
			label variable postgrad  						"Teacher's graduate certificate"
			label variable experience_asteacher 			"Teacher's experience (overall)"
			label variable teacher_exp_school				"Teacher's experience (in school)"
			label variable teacher_exp_grade 				"Teacher's experience (in the grade he/she is currently teaching)"
			label variable teacher_work_contract 			"Teacher's contract type"
			label variable use_news 						"Teacher uses news/magazines as pedag. material"
			label variable use_copy_machine 				"Teacher uses copy machines as pedag. material"
			label variable use_literature_books 			"Teacher uses literature books as pedag. material"
			label variable meetings_class_council  			"Number of class council meetings"
			label variable pedagogic_plan 					"Development of the pedagogical plan"
			label variable coduf 							"State ID"
			label variable codmunic 						"Municipality ID"
			label variable codschool 						"School ID"
			label variable network 							"School administrative network"
			label variable grade 							"Grade teacher is in charge of"
			label variable year 							"Year"
			label variable urban							"1: Urban area. 0: Rural area"
			label variable id_class							"Code of the class teacher is in charge of"
			label variable teacher_gender					"Teacher's gender"
			label variable teacher_skincolor   				"Teacher's skin color"
			label variable principal_learning 				"Frequency that the principal: pays attention to students' learning"
			label variable principal_norms 					"Frequency that the principal: pays attention to administrative norms"
			label variable principal_maintenance 			"Frequency that the principal: pays attention to school maintenance"
			label variable principal_motivation 			"Frequency that the principal: motivates me"
			label variable principal_innovation 			"Frequency that the principal: encourages innovative activities"
			label variable principal_respect 				"Frequency that the principal: makes me feel respected"
			label variable principal_trust 					"Frequency that: I trust the principal as a professional"
			label variable work_decisions 					"Frequency that I participate in decisions related with my work"
			label variable my_ideas 						"Frequency that the teacher team takes my ideas into consideration"
			label variable area_postgrad 					"Area of Graduate School"
			label variable teacher_other_job 				"Do you have another job?"
			label variable teacher_wage 					"Gross teacher_wage as teacher (in all schools that teacher works)"
			label variable teacher_workhours_school 		"Weekly hours of work in this school"
			label variable nu_schools_work 					"Number of school the teacher works"
			label variable teacher_workhours_total 			"Weekly hours of work as teacher in all schools"
			label variable share_curricula 					"Amount of the school curricula teacher was able to cover"	
			label variable students_books 					"Students with textbooks" 
			label variable books_since_beg_year				"Did the students receive the book in the beggining of the school year?"
			label variable received_book 					"Did the school receive the textbooks?"
			label variable quality_books					"What is the quality of the book received"
			label variable teacher_more10yearsexp			"Teachers with more than 10 years of experience"
			label variable teacher_tenure					"Teacher with tenure"
			label variable teacher_less_40years				"Teacher with less than 40 years old"
			label variable teacher_less3min_wages			"Teacher's salary is less than 3 minimum wage"
			compress
			save "$inter/Teachers - Prova Brasil.dta", replace
					
		
	*________________________________________________________________________________________________________________________________* 
	**
	**Harmonizing Principal Data
	**
	*________________________________________________________________________________________________________________________________* 
		
		**
		* -> Renaming variables
		*----------------------------------------------------------------------------------------------------------------------------*
		**
			forvalues year = 2007(2)2009 {
				use "$inter/Principals_`year'.dta", clear
				
					if `year' == 2007 {
						gen 	 year = 2007
						drop 	 NO_MUNICIPIO SIGLA_UF 
						rename  (PK_COD_ENTIDADE-COD_MUNICIPIO) (codschool network location coduf codmunic)
						rename  (Q1 Q2 Q3 Q4 Q5 Q6 Q8 Q9 Q10 Q14 Q16 Q15 Q20 Q21 Q18 Q19 Q17 Q11 Q22 Q23 Q35 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 Q33 Q34 Q36 Q37 Q43 Q38 Q39 Q40 Q41 Q42 Q44 Q45 Q46 Q47 Q48 Q49 Q50 Q51 Q52 Q53 Q54 Q55 Q56 Q57 Q91 Q92 Q93 Q94 Q95 Q96 Q98 Q143 Q146 Q155 Q158 ) ///					(principal_gender principal_age_range principal_skincolor principal_edu_level principal_years_graduation type_university type_education postgrad area_postgrad principal_wage principal_other_job total_principal_wage principal_workhours_school principal_selection_work experience_asprincipal_total experience_asprincipal_school principal_exp_eductraining_last2years org_training teachers_training teachers_tenure meetings_school_council school_council_teachers school_council_students school_council_staff school_council_parents meetings_class_council pedagogic_plan students_admission school_offering criteria_classrooms criteria_teacher_classrooms prog_reduce_dropout prog_reduce_repetition prog_increase_learning absenteeism_talk_students absenteeism_talk_parents absenteeism_parents_meeting absenteeism_parents_inperson absenteeism_send_someone lack_finantial_resources lack_teachers lack_adm_staff lack_pedago_staff lack_pedago_resources interruption_school absenteeism_teachers absenteeism_students teachers_turnover student_bad_behavior interference_external_agents support_secretary_edu exchange_information support_community finantial_resourses_federal finantial_resourses_state finantial_resources_municipal books_since_beg_year lack_books books_received violence_students_teachers violence_between_students violence_lifethreat violence_student_threat violence_theft violence_robb violence_students_alcohol violence_students_drugs violence_students_knife violence_students_gun )
								(principal_gender principal_age_range principal_skincolor principal_edu_level principal_years_graduation type_university type_education postgrad area_postgrad principal_wage principal_other_job total_principal_wage principal_workhours_school principal_selection_work experience_asprincipal_total experience_asprincipal_school principal_exp_educ training_last2years org_training teachers_training teachers_tenure meetings_school_council school_council_teachers school_council_students school_council_staff school_council_parents meetings_class_council pedagogic_plan students_admission school_offering criteria_classrooms criteria_teacher_classrooms prog_reduce_dropout prog_reduce_repetition prog_increase_learning absenteeism_talk_students absenteeism_talk_parents absenteeism_parents_meeting absenteeism_parents_inperson absenteeism_send_someone lack_finantial_resources lack_teachers lack_adm_staff lack_pedago_staff lack_pedago_resources interruption_school absenteeism_teachers absenteeism_students teachers_turnover student_bad_behavior interference_external_agents support_secretary_edu exchange_information support_community finantial_resourses_federal finantial_resourses_state finantial_resources_municipal book_choice books_since_beg_year lack_books books_received agressao_prof1 agressao_prof2 agressao_func1 agressao_func2 )
					}
					
					if `year' == 2009 {
						drop 	 no_municipio sigla_uf
						gen 	 year = 2009
						rename  (pk_cod_entidade-cod_municipio)(codschool network location coduf codmunic)
						rename  (Q1 Q2 Q3 Q4 Q5 Q6 Q8 Q9 Q10 Q14 Q16 Q15 Q20 Q21 Q18 Q19 Q17 Q11 Q22 Q23 Q35 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 Q33 Q34 Q36 Q37 Q43 Q38 Q39 Q40 Q41 Q42 Q46 Q47 Q48 Q49 Q50 Q51 Q52 Q53 Q54 Q55 Q56 Q57 Q58 Q59 Q94 Q95 Q96 Q97 Q98 Q99 Q101 Q127 Q130 Q139 Q142 ) ///					
								(principal_gender principal_age_range principal_skincolor principal_edu_level principal_years_graduation type_university type_education postgrad area_postgrad principal_wage principal_other_job total_principal_wage principal_workhours_school principal_selection_work experience_asprincipal_total experience_asprincipal_school principal_exp_educ training_last2years org_training teachers_training teachers_tenure meetings_school_council school_council_teachers school_council_students school_council_staff school_council_parents meetings_class_council pedagogic_plan students_admission school_offering criteria_classrooms criteria_teacher_classrooms prog_reduce_dropout prog_reduce_repetition prog_increase_learning absenteeism_talk_students absenteeism_talk_parents absenteeism_parents_meeting absenteeism_parents_inperson absenteeism_send_someone lack_finantial_resources lack_teachers lack_adm_staff lack_pedago_staff lack_pedago_resources interruption_school absenteeism_teachers absenteeism_students teachers_turnover student_bad_behavior interference_external_agents support_secretary_edu exchange_information support_community finantial_resourses_federal finantial_resourses_state finantial_resources_municipal book_choice books_since_beg_year lack_books books_received agressao_prof1 agressao_prof2 agressao_func1 agressao_func2 )					
						}
					
					drop Q*
					destring codschool network location coduf codmunic, replace
					tempfile `year'
					save 	``year''
			erase "$inter/Principals_`year'.dta"
			}
			
		**
		* -> Appending years
		*----------------------------------------------------------------------------------------------------------------------------*
		**
			clear 		
			forvalues year = 2007(2)2009 {
				append using ``year''
			}
			order year coduf codmunic codschool  network location 
			
		**
		* -> Cleaning
		*----------------------------------------------------------------------------------------------------------------------------*
		**
			
			*Network
			*------------------------------------------------------------------------------------------------------------------------*
			label define network 1 "Federal" 2 "State" 3 "Municipal" 4 "Private"
			label val 	 network network
			
			
			*Urban/rural
			*------------------------------------------------------------------------------------------------------------------------*
			recode location (2 = 0)
			rename location urban
			label  define   urban 1 "Urban" 0 "Rural"
			label  val 	    urban urban
			
			
			*State
			*------------------------------------------------------------------------------------------------------------------------*
			label define state 11 "RO" 12 "AC" 13 "AM" 14 "RR" 15 "PA" 16 "AP" 17 "TO"  					///
							   21 "MA" 22 "PI" 23 "CE" 24 "RN" 25 "PB" 26 "PE" 27 "AL" 28 "SE" 29 "BA" 		///
							   31 "MG" 32 "ES" 33 "RJ" 35 "SP" 												///
							   41 "PR" 42 "SC" 43 "RS" 														///
							   50 "MS" 51 "MT" 52 "GO" 53 "DF"
			label val coduf state


			*Enconding
			*------------------------------------------------------------------------------------------------------------------------*
			foreach var of varlist  principal_gender-agressao_func2 {
				replace `var' = "" if `var' == "*" | `var' == "."
				encode  `var', gen (`var'2)
				drop 	`var' 
				rename  `var'2 `var'
			}
			
			*principal_gender
			*------------------------------------------------------------------------------------------------------------------------*
			label   define principal_gender    2 "Female" 1 "Male"
			label   val    principal_gender principal_gender
			
			
			*Age
			*------------------------------------------------------------------------------------------------------------------------*
			label 	define principal_age_range 1 "Up to 24 years old" 2 "Between 25-29 years old" 3 "Between 30 and 39 years old" 4 "Between 40 and 49 years old"  5 "Between 50 and 54 years old"  6 "More than 55 years old"
			label 	val    principal_age_range principal_age_range
			
			
			*Skin color
			*------------------------------------------------------------------------------------------------------------------------*
			recode 		   principal_skincolor (6 7 = .)		//6 = "dont know my color"
			label 	define principal_skincolor 1 "White" 2 "Brown" 3 "Black" 4 "Yellow" 5 "Indigenous"
			label 	val	   principal_skincolor principal_skincolor
			
			
			*Principal ducation
			*------------------------------------------------------------------------------------------------------------------------*
			label  	define principal_edu_level  		1 "Less than high school"   2 "High school"  		3 "Undergraduate/Pedagogy"  4 "Undergraduate/Math"   5 "Undergraduate/Portuguese" 6 "Undergraude/others"
			label  	define principal_years_graduation  	1 "Less than 2 years" 		2 "Between 3-7 years" 	3 "Between 8-14 yars" 		4 "Betweeen 15-20 years" 5 "More than 20 years" 
			label  	define postgrad   					1 "No grad. certificate"    2 "Short Course" 		3 "Specialization" 			4 "Masters" 			 5 "Phd"
			label 	define type_university 				1 "Federal"				    2 "State" 				3 "Municipal" 				4 "Private" 
			label 	define type_education 				1 "Face to Face"  		    2 "Face/Distance" 		3 "Distance Learning"  
			label 	define area_postgrad 				1 "Education" 			    0 "Other field" 
			recode 	principal_edu_level 			(1 = 1) (2 3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 8 = 6)   	if year <  2013
			recode 	postgrad 						(5 = 1) (1   = 2) (2 = 3) (3 = 4) (4 = 5)   		  	if year <  2013
			recode  type_university 				(5 = .) 								  		 		if year <  2013
			recode 	type_education	 				(4 = .) 												if year <  2013
			recode 	area_postgrad 					(1 2 3   = 1) (4 = 0) (5 = .) 							if year <  2011
			label  	val principal_years_graduation principal_years_graduation
			label  	val principal_edu_level principal_edu_level
			label  	val postgrad postgrad
			label 	val type_university type_university
			label   val type_education type_education
			label   val area_postgrad area_postgrad
			
					
			*Principal Experience
			*------------------------------------------------------------------------------------------------------------------------*
			label    define experience 		  		    	1 "Less than 2 years"    	2 "3-5 years"     	   3"6-10 years"  4 "11-15 years" 5 "More than 15 years"
			label    val principal_exp_educ 			 experience 
			label    val experience_asprincipal_total 	 experience 
			label    val experience_asprincipal_school   experience 
			

			*principal_wage, hours worked
			*------------------------------------------------------------------------------------------------------------------------*
			label 	define hours_worked 			1 "More than 40 hours" 						2 "40 hours" 								3  "Between 20-39 hours" 		 			4 "Less than 20 hours" 
			label 	define principal_wage 			1 "Up to one minimum principal_wage" 	  	2 "Between 1-1.5 minimum principal_wage"  	3  "Between 1.5-2 minimum principal_wages" 	4 "Between 2-2.5 minimum principal_wages" ///
													5 "Between 2.5-3 minimum principal_wages"   6 "Between 3-3.5 minimum principal_wages" 	7  "Between 3.5-4 minimum principal_wages" 	8 "Between 4-5 minimum principal_wages"   ///
													9 "Between 5-7 minimum principal_wages"     10 "Between 7-10 minimum principal_wages" 	11 "More than 10 minimum ages"
			label   define principal_other_job		1 "Yes, in education area"					2 "Yes, in other field"			3  "Don't have another job"
			
			
			replace principal_wage 			= . if year == 2007
			replace total_principal_wage	= . if year == 2007
			recode  principal_workhours_school (4 = 1) (3 = 2) (2 = 3) (1 = 4) if year < 2013
			label   val principal_workhours_school hours_worked
			label   val principal_wage 	   principal_wage
			label   val total_principal_wage principal_wage
			label   val principal_other_job principal_other_job
			
			
			*Other
			*------------------------------------------------------------------------------------------------------------------------*
			label  define  yesno 							1 "Yes" 							0 "No"
			label  define  meetings  						1 "Once" 							2 "Twice"   										3 "Three times or more"  				  			4 "None"  		   										5 "No school council"
			label  define  principal_selection_work 		1 "Election" 						2 "Election involving additional process"   		3 "Selection/civil servant" 						4 "Appointments"     									5 "Other process"
			label  define  teachers_tenure 					1 "25% or less"						2 "Between 26-50%"									3 "Between 51-75%" 						  			4 "Between 76%-90%"  									5 "More than 91%"
			label  define  students_admission				1 "Selection test"					2 "Lottery" 										3 "Household Address" 					  			4 "Order of arrival" 									5 "Other criteria" 						6 "No criteria"   
			label  define  school_offering					1 "More vacancies than enrollments" 2 "All vacancies were filles"						3 "Demand > vacancies offered"			  			4 "Demand much higher than vacancies offered"
			label  define  criteria_classrooms				1 "Similar ages"				    2 "Similar student's performance"					3 "Heterogeneity in age"  				  			4 "Heterogeneity in performance"  						5 "No criteria"
			label  define  criteria_teacher_classrooms	    1 "Teacher's choice" 				2 "More experienced teachers with high performers"  3 "More experienced teachers with low performers" 	4 "Keeping teachers with the same last year's students" 5 "Change of teachers between grades"   6 "Lottery"    7 "Other criteria" 8 "No criteria"  9 "Don't have 1st/5th grade"
			label  define  programa 						0 "No, even having the problem" 	1 "Yes"												2 "We don't have this problem"
			label  define  problem                          0 "Not an issue" 					1 "Small" 											2 "A moderate/big issue"
			label  define  teachers_training 				0 "No training" 					1 "Only a few"  									2 "A bit less than half"						    3 "More than half"
			label  define  book_choice 						1 "External agent" 					2 "Few people or someone alone" 					3 "Group choice"
			label  define  pedagogic_plan  					1 "No pedag. project" 				2 "Modelo pronto, sem discussão da equipe"			///
			3  "Modelo pronto com algumas modificações/modelo próprio mas sem teacher's active involvement" 4 "With active teacher's involvement"
			
			recode criteria_classrooms						(5 = .) (6 = 5) if year > 2011
			recode principal_selection_work  							(2 = 1) 	(3 = 2) 		(1     = 3) 	(4 5 6 = 4) (7 = 5)	 								if year <  2013
			recode principal_selection_work  							(2 = 1) 	(5 = 2) 		(1 4 6 = 3) 	(3     = 4) (7 = 5) 								if year >= 2013
			recode meetings_school_council  				(3 = 1) 	(4 = 2) 		(5 = 3) 		(2 = 4) 	(1 = 5)  											if year >= 2013
			recode meetings_class_council  					(3 = 1) 	(4 = 2) 		(5 = 3) 		(2 = 4) 	(1 = 5)  											if year >= 2013
			recode pedagogic_plan 							(6 7 = .) (8 = 1) (1 = 2) (2   = 3) (3 4 5    = 4)				 											if year <  2011
			recode pedagogic_plan 							(7 8 = .) (9 = 1) (1 = 2) (2   = 3) (3 4 5 6  = 4)				 											if year == 2011
			recode pedagogic_plan 							(1   = .) (2 = 1) (3 = 2) (5 7 = 3) (4 6 8    = 4)				 											if year >  2011
			recode criteria_teacher_classrooms  			(2   = 1) 	(3 = 2)  		(4 = 3)  		(5 = 4)  	(6 = 5)  (7 = 6) (8   = 7) (9  = 8) (1 = 9)  		if year <  2013
			recode criteria_teacher_classrooms  			(1 2 = 1) 	(3 = 2)  		(4 = 3)  		(5 = 4)  	(6 = 5)  (7 = 6) (8 9 = 7) (10 = 8) 		  		if year >= 2013		
			recode book_choice								(5 = 1) (3 4 = 2) (1 2 = 3) (6   = .)																		if year <  2013
			recode book_choice								(4 = 1) (3   = 2) (2   = 3) (1 5 = .)																		if year >= 2013
			
			label  val meetings_school_council 				meetings
			label  val meetings_class_council  				meetings
			label  val principal_selection_work 		   				principal_selection_work
			label  val teachers_tenure 		   				teachers_tenure
			label  val students_admission      				students_admission
			label  val school_offering		   				school_offering
			label  val criteria_classrooms	   				criteria_classrooms
			label  val criteria_teacher_classrooms 			criteria_teacher_classrooms 
			label  val pedagogic_plan						pedagogic_plan
			label  val book_choice							book_choice
			
			foreach var of varlist prog_reduce_dropout prog_reduce_repetition {
				recode 		`var' (3 = 0) (1 2   = 1) (4 = 2) if year <  2013
				recode 		`var' (1 = 0) (3 4 5 = 1) (2 = 2) if year >= 2013
				label val 	`var' programa
			}
			
			foreach var of varlist lack_finantial_resources-student_bad_behavior {
				recode		`var' (1 = 0) (2   = 1) (3 4 = 2) if year >= 2013
				recode 		`var' (1 = 0) (2   = 1) (3   = 2) if year <  2013
				label val   `var' problem
			}
		
			foreach var of varlist absenteeism_talk_students absenteeism_talk_parents absenteeism_parents_meeting absenteeism_parents_inperson absenteeism_send_someone {
				recode 		`var' (1 = 0) (2 3 4 = 1) if year >= 2013
				recode 		`var' (1 = 1) (2     = 0) if year <  2013
				label val   `var' yesno
			}
			
			foreach var of varlist  finantial_resourses_federal finantial_resourses_state finantial_resources_municipal books_since_beg_year lack_books books_received {
				recode 	  	`var' (1 = 1) (2 = 0) (3 = .)
				label val 	`var' yesno
			}
			
			gen 		 violence_students_teachers = .
			replace 	 violence_students_teachers = 0 if 				year < 2013
			foreach var of varlist agressao_prof1 agressao_prof2 agressao_func1 agressao_func2 {
				replace  violence_students_teachers = 1 if `var' == 1 & year < 2013
				drop 	`var'
			}

			foreach var of varlist org_training training_last2years prog_increase_learning {
				recode 		`var' (2 = 0) 		 	if year <  2013
				recode 		`var' (1 = 0) (2 = 1) 	if year >= 2013
				label val   `var' yesno
			}

			foreach var of varlist interference_external_agents support_secretary_edu exchange_information support_community {
				recode 		`var' (1 = 1) (2 = 0)
				label val 	`var' yesno
			}
		
			foreach var of varlist school_council_teachers school_council_students school_council_staff school_council_parents {
				recode 	    `var' (2 = 0) if year < 2013
				label val   `var' yesno
			}
			
			recode   teachers_training 		  		  (1  2 = 1) (3 = 2) (4   = 3) (5 = .) 	if  year <  2013
			replace  teachers_training 		  = 0  							    			if  year <  2013 & org_training == 0
			label    val teachers_training teachers_training
			 
			label val violence_students_teachers yesno
			 
			*Defining new variables
			*------------------------------------------------------------------------------------------------------------------------*
			**
			*Males, whites and college degree
			**
			recode principal_gender     (1 = 1) (2 = 0)					, gen (male)
			recode principal_skincolor  (1 = 1) (2 3 4 5 = 0)			, gen (white)
			recode principal_edu_level  (3 4 5 6 = 1) (2 1 = 0)			, gen (principal_college_degree)
			label  val male   yesno
			label  val white  yesno
			label  val principal_college_degree yesno
			
			**
			*External support
			**
			egen temp1 						 = rowmiss(interference_external_agents support_secretary_edu exchange_information support_community)
			egen external_support_mean 		 = rowmean(interference_external_agents support_secretary_edu exchange_information support_community)

			gen external_support_all 		 = 1
			foreach var of varlist 					  interference_external_agents support_secretary_edu exchange_information support_community {
				replace external_support_all = 0 if `var' == 0
			}
			replace external_support_mean    =.  if temp1 > 1
			replace external_support_all     =.  if temp1 > 1
			drop 	temp1
			
			**
			*Principal effort - implementation of projects to increase learning and reduce dropout/repetition
			**
			egen temp1 					 	 	    = rowmiss(prog_reduce_dropout prog_reduce_repetition prog_increase_learning)
			egen implementation_projects_mean	    = rowmean(prog_reduce_dropout prog_reduce_repetition prog_increase_learning)

			gen  implementation_projects_all        = 1
			foreach var of varlist 						   prog_reduce_dropout prog_reduce_repetition prog_increase_learning {
				replace implementation_projects_all = 0 if `var' == 0
			}
			replace implementation_projects_all  =. if temp1 > 1
			replace implementation_projects_mean =. if temp1 > 1
			drop 	temp1
			
			label val implementation_projects_all yesno
			label val external_support_all 		  yesno
			
			**
			*Student and teacher effort (principal's perspective)
			**
			egen temp1 =  rowmiss(absenteeism_students student_bad_behavior)
			egen temp2 =  rowmiss(absenteeism_teachers teachers_turnover)
			foreach var of varlist absenteeism_students student_bad_behavior absenteeism_teachers teachers_turnover {
				recode `var' (2 = 0) (1 = 0.5) (0 = 1), gen(`var't)
			}
			egen 	student_effort = rowmean(absenteeism_studentst student_bad_behaviort) if temp1 != .
			egen 	teacher_effort = rowmean(absenteeism_teachers teachers_turnover)      if temp2 != .
			drop 	absenteeism_studentst student_bad_behaviort absenteeism_teacherst teachers_turnovert temp1 temp2
			format  implementation* external* student_effort* teacher_effort* %4.2fc

			**
			*
			**
			tab teachers_training, 			gen(teachers_training)
			tab principal_selection_work, 	gen(principal_selection_work)
			tab absenteeism_teachers, 		gen(absenteeism_teachers)
			tab absenteeism_students, 		gen(absenteeism_students)
			tab teachers_turnover, 			gen(teachers_turnover)
			
			foreach var of varlist teachers_training1-teachers_turnover3 {
				label val `var' yesno
			}	
			
			
			*-----------------------------------------------------------------------------------------------------------------------*
			gen treated   		= .				//1 for closed schools, 0 otherwise
			gen id_13_mun 		= 0				//1 for the 13 municipalities that extended the winter break, 0 otherwise
			gen G	  			= 1				//0 for the 13 municipalities that extended the winter break, 1 otherwise

			
			foreach munic in $treated_municipalities {
				replace treated   = 1 if codmunic == `munic' & network == 3
				replace id_13_mun = 1 if codmunic == `munic'
				replace G	  	  = 0 if codmunic == `munic'
			}		
			
			replace treated    = 1 if network == 2
			replace treated    = 0 if treated == .
			
			
			label variable student_effort 				  	"Student effort - principal's view"
			label variable teacher_effort 				  	"Teacher effort - principal's view"
			label variable implementation_projects_mean  	"Mean principal effort - projects to reduce dropout/repetition and increase learning"
			label variable implementation_projects_all   	"Full principal effort - projects to reduce dropout/repetition and increase learning"
			label variable external_support_mean 		 	"Mean external stakeholder's suppport - principal's view"
			label variable external_support_all  		  	"Full external stakeholder's suppport - principal's view"
			label variable male								"Male principal"
			label variable white							"White principal" 
			label variable principal_age_range				"Principal's age range"
			label variable principal_years_graduation		"Years since graduation"
			label variable type_university					"1: Federal. 2: State. 3: Municipal. 4: Private"
			label variable type_education					"1: Face to face. 2: Face to face/distance. 3: Distance learning"
			label variable principal_edu_level 				"Principal's education"
			label variable postgrad  						"Principal's graduate certificate"
			label variable meetings_class_council  			"Number of class council meetings"
			label variable meetings_school_council  		"Number of student council meetings"
			label variable pedagogic_plan 					"Development of the pedagogical plan"
			label variable coduf 							"State ID"
			label variable codmunic 						"Municipality ID"
			label variable codschool 						"School ID"
			label variable network 							"School administrative network"
			label variable year 							"Year"
			label variable urban							"1: Urban area. 0: Rural area"
			label variable principal_gender					"Principal's gender"
			label variable principal_skincolor   			"Principal's skin color"
			label variable area_postgrad 					"Area of Graduate School"
			label variable principal_other_job 				"Do you have another job?"
			label variable principal_wage 					"Gross principal_wage as principal"
			label variable total_principal_wage 			"Gross principal_wage consideral all jobs the principal has"
			label variable principal_exp_educ				"Principal's experience working in education"
			label variable experience_asprincipal_total 	"Total experience as principal"
			label variable experience_asprincipal_school 	"Experience as principal in this school"
			label variable principal_workhours_school 		"Weekly hours of work in this school"
			label variable students_admission 				"Criteria for student's enrollment in the school"
			label variable school_offering 					"Demand and supply of vacancies"
			label variable criteria_classrooms 				"Criteria for student's allocation into classrooms"
			label variable criteria_teacher_classrooms		"Criteria for teacher's allocation into classrooms"
			label variable principal_selection_work 		"How principal was selected for the position"
			label variable org_training 					"Principal has organized teacher's training last two years"
			label variable teachers_training			 	"Teachers training. 1: no training. 2: only a few. 3: less half. 4: more than half"
			label variable training_last2years				"Principal has participated of some training last two years"
			label variable teachers_tenure 					"Share of teachers with tenure (civil servants)"
			label variable prog_reduce_dropout 				"0: no program reduce dropout but needs it/1: has a program/2: Does not need"
			label variable prog_reduce_repetition 			"0: no program reduce repetition but needs it/1: has a program/2: Does not need"
			label variable absenteeism_talk_students 		"Teachers talk to students to avoid their absenteeism"
			label variable absenteeism_talk_parents 		"Teachers communicate parents about student's absenteeism"
			label variable absenteeism_parents_inperson 	"Teachers invite parents to talk about student's absenteeism"
			label variable absenteeism_send_someone 		"School sends someone to student's home talk about absenteeim"
			label variable absenteeism_parents_meeting 		"Teachers talk about student's absenteeism in parent's meeting"
			label variable prog_increase_learning 			"0: no program increase learning but needs it/1: has a program/2: Does not need"
			label variable absenteeism_teachers 			"Teacher's absenteeism. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable teachers_turnover				"Teacher's turnover. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable lack_finantial_resources 		"Lack of finantial resources. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable lack_teachers 					"Lack of teachers. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable lack_adm_staff 					"Lack of adm staff. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable lack_pedago_staff 				"Lack of pegago staff. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable lack_pedago_resources 			"Lack of pedago resources. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable interruption_school 				"Interruption of classes. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable absenteeism_students 			"Absenteism of students. 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable student_bad_behavior 			"Student's bad behaviour 0: not an issue. 1: Small/moderate. 2: Big issue"
			label variable interference_external_agents 	"Interference of external agents in the principals management"
			label variable support_secretary_edu 			"Principal has the support from the secretary of education"
			label variable exchange_information 			"Principal exchange informations with other principals"
			label variable support_community 				"Principal has the support of the community"
			label variable finantial_resourses_federal 		"School receives finantial resources from Federal Government"
			label variable finantial_resourses_state 		"School receives finantial resources from State Government "
			label variable finantial_resources_municipal 	"School receives finantial resources from Municipal Government"
			label variable books_since_beg_year 			"Textbooks arrived in the begginning of the school year"
			label variable lack_books 						"There is lack of textbook"
			label variable books_received 					"Textbooks arrived in the school"
			label variable principal_college_degree			"Principal has a college degreee"
			label variable book_choice						"Principal does not know. 2: external choice. 3: internal choice"
			label variable school_council_teachers 			"Teachers participate of the school council"
			label variable school_council_students 			"Students participate of the school council"
			label variable school_council_staff				"School staff participate of the school council "
			label variable school_council_parents			"Parents participate of the school council"
			compress
			
			rename (male white) (principal_male principal_white)
			save "$inter/Principals - Prova Brasil.dta", replace

		
