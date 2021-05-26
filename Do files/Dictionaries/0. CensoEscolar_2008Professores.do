clear
set more off
foreach i in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
#delimit ;
infix
str	ANO_CENSO	1	 - 	7
str	FK_COD_DOCENTE	8	 - 	22
str	NU_DIA	23	 - 	27
str	NU_MES	28	 - 	32
str	NU_ANO	33	 - 	39
str	NUM_IDADE	40	 - 	44
str	TP_SEXO	45	 - 	45
str	TP_COR_RACA	46	 - 	46
str	TP_NACIONALIDADE	47	 - 	47
str	FK_COD_PAIS_ORIGEM	48	 - 	53
str	FK_COD_ESTADO_DNASC	54	 - 	58
str	SIGLA_ESTADO_DNASC	59	 - 	60
str	FK_COD_MUNICIPIO_DNASC	61	 - 	75
str	FK_COD_ESTADO_DEND	76	 - 	80
str	SIGLA_ESTADO_DEND	81	 - 	82
str	FK_COD_MUNICIPIO_DEND	83	 - 	97
str	FK_COD_ESCOLARIDADE	98	 - 	102
str	FK_CLASSE_CURSO_1	103	 - 	107
str	PK_COD_AREA_OCDE_1	108	 - 	113
str	ID_LICENCIATURA_1	114	 - 	116
str	NU_ANO_CONCLUSAO_1	117	 - 	122
str	ID_TIPO_INSTITUICAO_1	123	 - 	125
str	ID_NOME_IES_1	126	 - 	225
str	FK_COD_IES_1	226	 - 	234
str	FK_CLASSE_CURSO_2	235	 - 	239
str	PK_COD_AREA_OCDE_2	240	 - 	245
str	ID_LICENCIATURA_2	246	 - 	248
str	NU_ANO_CONCLUSAO_2	249	 - 	254
str	ID_TIPO_INSTITUICAO_2	255	 - 	257
str	ID_NOME_IES_2	258	 - 	357
str	FK_COD_IES_2	358	 - 	366
str	FK_CLASSE_CURSO_3	367	 - 	371
str	PK_COD_AREA_OCDE_3	372	 - 	377
str	ID_LICENCIATURA_3	378	 - 	380
str	NU_ANO_CONCLUSAO_3	381	 - 	386
str	ID_TIPO_INSTITUICAO_3	387	 - 	389
str	ID_NOME_IES_3	390	 - 	489
str	FK_COD_IES_3	490	 - 	498
str	ID_QUIMICA	499	 - 	499
str	ID_FISICA	500	 - 	500
str	ID_MATEMATICA	501	 - 	501
str	ID_BIOLOGIA	502	 - 	502
str	ID_CIENCIAS	503	 - 	503
str	ID_LINGUA_LITERAT_PORTUGUESA	504	 - 	504
str	ID_LINGUA_LITERAT_INGLES	505	 - 	505
str	ID_LINGUA_LITERAT_ESPANHOL	506	 - 	506
str	ID_LINGUA_LITERAT_OUTRA	507	 - 	507
str	ID_ARTES	508	 - 	508
str	ID_EDUCACAO_FISICA	509	 - 	509
str	ID_HISTORIA	510	 - 	510
str	ID_GEOGRAFIA	511	 - 	511
str	ID_FILOSOFIA	512	 - 	512
str	ID_ESTUDOS_SOCIAIS	513	 - 	513
str	ID_INFORMATICA_COMPUTACAO	514	 - 	514
str	ID_PROFISSIONALIZANTE	515	 - 	515
str	ID_DIDATICA_METODOLOGIA	516	 - 	516
str	ID_FUNDAMENTOS_EDUCACAO	517	 - 	517
str	ID_DISC_ATENDIMENTO_ESPECIAIS	518	 - 	518
str	ID_DISC_DIVERSIDADE_SOCIO_CULT	519	 - 	519
str	ID_OUTRAS_DISCIPLINAS_PEDAG	520	 - 	520
str	ID_LIBRAS	521	 - 	521
str	ID_ESPECIALIZACAO	522	 - 	522
str	ID_MESTRADO	523	 - 	523
str	ID_DOUTORADO	524	 - 	524
str	ID_POS_GRADUACAO_NENHUM	525	 - 	525
str	ID_ESPECIFICO_CRECHE	526	 - 	526
str	ID_ESPECIFICO_PRE_ESCOLA	527	 - 	527
str	ID_ESPECIFICO_NEC_ESP	528	 - 	528
str	ID_ESPECIFICO_ED_INDIGENA	529	 - 	529
str	ID_INTERCULTURAL_OUTROS	530	 - 	530
str	ID_ESPECIFICO_NENHUM	531	 - 	531
str	ID_OUTRAS_DISCIPLINAS	532	 - 	532
str	ID_TIPO_DOCENTE	533	 - 	533
str	PK_COD_TURMA	534	 - 	546
str	FK_TIPO_TURMA	547	 - 	551
str	FK_COD_MOD_ENSINO	552	 - 	556
str	FK_COD_ETAPA_ENSINO	557	 - 	561
str	FK_COD_CURSO_PROF	562	 - 	571
str	PK_COD_ENTIDADE	572	 - 	582
str	FK_COD_ESTADO	583	 - 	587
str	SIGLA	588	 - 	589
str	FK_COD_MUNICIPIO	590	 - 	604
str	ID_LOCALIZACAO	605	 - 	605
str	ID_DEPENDENCIA_ADM	606	 - 	606
str	DESC_CATEGORIA_ESCOLA_PRIVADA	607	 - 	607
str	ID_CONVENIADA_PP	608	 - 	608
str	ID_TIPO_CONVENIO_PODER_PUBLICO	609	 - 	609
str	ID_MANT_ESCOLA_PRIVADA_EMP	610	 - 	610
str	ID_MANT_ESCOLA_PRIVADA_ONG	611	 - 	611
str	ID_MANT_ESCOLA_PRIVADA_SIND	612	 - 	612
str	ID_MANT_ESCOLA_PRIVADA_APAE	613	 - 	613
str	ID_DOCUMENTO_REGULAMENTACAO	614	 - 	614
str	ID_LOCALIZACAO_DIFERENCIADA	615	 - 	615
str	ID_EDUCACAO_INDIGENA	616	 - 	616
using "$raw/Censo Escolar/2008/DADOS/TS_DOCENTES_`i'.txt";
save "$inter/Professores2008`i'.dta", replace;
clear; 
};
