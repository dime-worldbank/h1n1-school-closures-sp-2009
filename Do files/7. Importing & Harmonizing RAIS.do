	**
	*This do file imports and harmonizes Rais
	**
	*________________________________________________________________________________________________________________________________* 
	
	
	**
	*Name and code of Brazilian Municipalities
	**
	do "$dofiles/Dictionaries/0. Code of Brazilian Municipalities.do"
	
	**
	*Hours of work in state and locally-managed schools
	**
	
	import excel "$raw/RAIS/Teachers hours of work.xlsx", cellrange(A6:M4657) allstring clear
