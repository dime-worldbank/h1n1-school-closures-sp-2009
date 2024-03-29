
											*SET UP STANDARDIZATION GLOBALS AND OTHER CONSTANTS*
*________________________________________________________________________________________________________________________________* 

*Sao Paulo, Campinas, Diadema, Embu das Artes, Indaiatuba, Mairiporã, Osasco, São Bernardo do Campo, Santo André, São Caetano do Sul, Sumaré, Ribeirao Preto, Taboao da Serra.
*Exceto em Sumaré, as aulas retornaram dia 17 de Agosto. Em Sumaré, as aulas retornaram dia 10. 

global socioeco_variables         incentive* parents_sch_meetings male white private_school live_mother computer mother_edu_highschool 									///
							      preschool ever_repeated ever_dropped work tv  dvd fridge car bath maid  mother_literate mother_reads 									///
							      live_father father_literate father_reads freezer wash_mash  do_homework_math_always													///
							      do_homework_port_always math_insuf port_insuf port_basic math_basic port_adequ math_adequ	 											///
								  hw_corrected_port_always hw_corrected_math_always							
							  
global balance_students5	      math5 port5 repetition5 dropout5 approval5 incentive_study5-incentive_talk5 white5 live_mother5 										///
								  computer5 medu5 preschool5  ever_repeated5 ever_dropped5 work5 tclass5 hour5    														///
								  math_insuf5 port_insuf5 hw_corrected_port_always5 hw_corrected_math_always5	


global treated_municipalities     3550308 3509502 3513801 3520509 3528502 3534401 3548708 3547809 3548807 3552403 3543402 3552809 3515004

global treated_municipalities2    355030  350950  351380  352050  352850  353440  354870  354780  354880  355240  354340  355280  351500
	
global matching_schools		      ComputerLab ScienceLab SportCourt Library InternetAccess

global matriculas				  enrollmentEI enrollmentcreche enrollmentpre enrollmentEF enrollmentEF1 enrollmentEF2 enrollment5grade enrollment9grade 				///

global teachers 		  		  teacher_more10yearsexp  teacher_male  teacher_white  teacher_college_degree  teacher_tenure  teacher_less_40years 					///
								  teacher_less3min_wages   principal_effort_teacherpers  student_effort_teacherpers violence_index  almost_all_finish_grade9  			///
								  almost_all_finish_highschool  almost_all_get_college covered_curricula1-quality_books4 def_student_loweffort def_absenteeism 			///
								  def_bad_behavior
	
global balance_teachers 		  tenure5 teacher_less_40years5 ///
								  prin5  violence_index5 almost_all_finish_grade95   					 																///
								  almost_all_finish_highschool5 covered_curricula45	participation_decisions45															///
								  share_students_books55 quality_books45  teacher_less3min_wages5 def_student_loweffort5 def_absenteeism5 def_bad_behavior5				///
								  adeqport5 adeqmath5
		  
global principals				  teachers_training1-absenteeism_students3 principal_male principal_white principal_college_degree support_secretary_edu support_community  ///
								  lack_books principal_gender principal_age_range principal_skincolor principal_edu_level		 										///
								  absenteeism_*  teachers_turnover* org_training teachers_training training_last2years													///
								  principal_selection_work meetings_school_council  meetings_class_council  															///
								  criteria_classrooms criteria_teacher_classrooms teacher_effort_principalpers student_effort_principalpers prog_increase_learning prog_reduce_dropout prog_reduce_repetition

global balance_principals		  org_training lack_books principal_selection_work4 absenteeism_teachers3 																///
								  absenteeism_students3 classrooms_similar_ages classrooms_het_performance

								  
global balance_municipalities 	 