
*MASTER*
*Author: Vivian Amorim
*vivianamorim5@gmail.com

   * PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   local user_commands ietoolkit sxpose  spmap  quantiles xtbalance boottest diff
   foreach command of local user_commands  {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }
   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above

    set matsize 11000
	set scheme economist 
	set seed 1
	graph set window fontface arial

	
   * PART 1:  PREPARING FOLDER PATH GLOBALS
   * Users
   * -----------
   * Vivian                  1    
   * Next User               2    

   *Set this value to the user currently using this file
   **************************
   global user  1												//*CHANGE HERE TO SET UP A NEW USER
   **************************

   * Root folder globals
   * ---------------------
   if $user == 1 {
       global projectfolder 	"/Users/vivianamorim/OneDrive/World Bank/Education/SP_H1N1 & School Closure"
	   global dofiles			"/Users/vivianamorim/Documents/GitHub/h1n1-school-closures-sp-2009/Do files"
	   
	   *If you want access to Education Data folder, please ask, for running as a second user, you do not need access to these folders. 
	   **These datasets are
	   global educationdata		"/Users/vivianamorim/OneDrive/Data Analysis"
	   global ideb         		"$educationdata/IDEB/DataWork/Datasets/3. Final"
	   global provabrasil       "$educationdata/Prova Brasil/DataWork/Datasets/3. Final"
	   global censoescolar      "$educationdata/Censo Escolar/DataWork/Datasets/3. Final" 
	   global rendimento        "$educationdata/Rendimento/DataWork/Datasets/3. Final" 
	   global fnde        		"$educationdata/Gasto_FNDE/DataWork/Datasets/3. Final" 
   }

   if $user == 2 {
       global projectfolder ""  							//fill the path of where you saved the folder "SP_H1N1 & School Closure" 
	   global dofiles										//fill the path of where you saved the do files" 
   }
   
   * Project folder globals
   * ---------------------
   global datawork         	"$projectfolder/DataWork"
   global output           	"$datawork/Output"
   global datasets         	"$datawork/Datasets"
   global raw	           	"$datasets/1. Raw"
   global inter				"$datasets/2. Intermediate"
   global final            	"$datasets/3. Final" 
   global figures          	"$output/Figures"
   global tables           	"$output/Tables"
   global descriptives      "$tables/Descriptives"
   global results           "$tables/Results"
   global inep 				"$raw/INEP"
   global geocodes			"$raw/GeoCodes"
   global ibge				"$raw/IBGE"
   global sus				"$raw/SUS"

   * PART 2:  SETTING UP GLOBALS
     do "$dofiles/Global.do" 
	 
   * PART 3: RUN DO FILES
	 *do "$dofiles/1. PIB Municipal.do"
	 *do "$dofiles/2. H1N1.do"
	 *do "$dofiles/3. Setting up datasets.do"
	 *do "$dofiles/4. Regressions.do"
	 *do "$dofiles/5. Descriptives.do"
	 
	 
	 
	 
	 
	 
	  
