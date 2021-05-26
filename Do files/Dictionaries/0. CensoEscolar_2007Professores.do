clear
set more off
foreach i in RO AC AM RR PA AP TO MA PI CE RN PB PE AL SE BA MG ES RJ SP PR SC RS MS MT GO DF {
#delimit ;
infix
str	ANO_CENSO  		1	 - 	4
str	FK_COD_DOCENTE	5	 - 	16
str	NU_DIA			17	 - 	18
str	NU_MES			19	 - 	20
str	NU_ANO			21	 - 	24
str	NUM_IDADE		25	 - 	27
str	TP_SEXO			28	 - 	28
str	TP_COR_RACA		29	 - 	29
str	TP_NACIONALIDADE	30	 - 	30
str	FK_COD_PAIS_ORIGEM	31	 - 	33
str	FK_COD_ESTADO_DNASC	34	 - 	35
str	SIGLA_ESTADO_DNASC	36	 - 	37
str	FK_COD_MUNICIPIO_DNASC	38	 - 	44
str	FK_COD_ESTADO_DEND	45	 - 	46
str	SIGLA_ESTADO_DEND	47	 - 	48
str	FK_COD_MUNICIPIO_DEND	49	 - 	55
str	FK_COD_ESCOLARIDADE		56	 - 	56
str	COD_CURSO_1	57	 - 	58
str	COD_CURSO_2	59	 - 	60
str	COD_CURSO_3	61	 - 	62
str	ID_QUIMICA	63	 - 	63
str	ID_FISICA	64	 - 	64
str	ID_MATEMATICA	65	 - 	65
str	ID_BIOLOGIA	66	 - 	66
str	ID_CIENCIAS	67	 - 	67
str	ID_LINGUA_LITERAT_PORTUGUESA	68	 - 	68
str	ID_LINGUA_LITERAT_INGLES	69	 - 	69
str	ID_LINGUA_LITERAT_ESPANHOL	70	 - 	70
str	ID_LINGUA_LITERAT_OUTRA	71	 - 	71
str	ID_ARTES	72	 - 	72
str	ID_EDUCACAO_FISICA	73	 - 	73
str	ID_HISTORIA	74	 - 	74
str	ID_GEOGRAFIA	75	 - 	75
str	ID_FILOSOFIA	76	 - 	76
str	ID_ESTUDOS_SOCIAIS	77	 - 	77
str	ID_INFORMATICA_COMPUTACAO	78	 - 	78
str	ID_PROFISSIONALIZANTE	79	 - 	79
str	ID_DIDATICA_METODOLOGIA	80	 - 	80
str	ID_FUNDAMENTOS_EDUCACAO	81	 - 	81
str	ID_DISC_ATENDIMENTO_ESPECIAIS	82	 - 	82
str	ID_DISC_DIVERSIDADE_SOCIO_CULT	83	 - 	83
str	ID_OUTRAS_DISCIPLINAS_PEDAG	84	 - 	84
str	ID_LIBRAS	85	 - 	85
str	ID_OUTRAS_DISCIPLINAS	86	 - 	86
str	ID_ESPECIALIZACAO	87	 - 	87
str	ID_MESTRADO	88	 - 	88
str	ID_DOUTORADO	89	 - 	89
str	ID_POS_GRADUACAO_NENHUM	90	 - 	90
str	ID_ESPECIFICO_CRECHE	91	 - 	91
str	ID_ESPECIFICO_PRE_ESCOLA	92	 - 	92
str	ID_ESPECIFICO_NEC_ESP	93	 - 	93
str	ID_ESPECIFICO_ED_INDIGENA	94	 - 	94
str	ID_INTERCULTURAL_OUTROS	95	 - 	95
str	ID_ESPECIFICO_NENHUM	96	 - 	96
str	ID_TIPO_DOCENTE	97	 - 	97
str	PK_COD_TURMA	98	 - 	107
str	FK_TIPO_TURMA	108	 - 	109
str	FK_COD_MOD_ENSINO	110	 - 	111
str	FK_COD_ETAPA_ENSINO	112	 - 	114
str	FK_COD_CURSO_PROF	115	 - 	122
str	PK_COD_ENTIDADE	123	 - 	130
str	FK_COD_ESTADO	131	 - 	132
str	SIGLA	133	 - 	134
str	FK_COD_MUNICIPIO	135	 - 	141
str	ID_LOCALIZACAO	142	 - 	142
str	ID_DEPENDENCIA_ADM	143	 - 	143
str	DESC_CATEGORIA_ESCOLA_PRIVADA	144	 - 	144
str	ID_CONVENIADA_PP	145	 - 	145
str	ID_MANT_ESCOLA_PRIVADA_EMP	146	 - 	146
str	ID_MANT_ESCOLA_PRIVADA_ONG	147	 - 	147
str	ID_MANT_ESCOLA_PRIVADA_SIND	148	 - 	148
str	ID_MANT_ESCOLA_PRIVADA_APAE	149	 - 	149
str	ID_DOCUMENTO_REGULAMENTACAO	150	 - 	150
str	ID_LOCALIZACAO_DIFERENCIADA	151	 - 	151
str	ID_EDUCACAO_INDIGENA	152	 - 	152
using "$raw/Censo Escolar/2007/DADOS/TS_DOCENTES_`i'.txt";
save "$inter/Professores2007`i'.dta", replace;
clear; 
};

