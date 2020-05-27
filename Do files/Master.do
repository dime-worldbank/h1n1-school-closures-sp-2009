
														     *MASTER*
*****************************************************************************************************************************
*Author: Vivian Amorim
*vivianamorim5@gmail.com


   * PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   * - Install packages needed to run all dofiles called by this master dofile.
   * - Use ieboilstart to harmonize settings across users
 
   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
   local user_commands ietoolkit sxpose  spmap  quantiles xtbalance boottest diff
   foreach command of local user_commands  {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }

   *Standardize settings accross users
   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above

   
   set matsize 11000

   * PART 1:  PREPARING FOLDER PATH GLOBALS
  
   * Users
   * -----------
   * Vivian                  1    
   * Next User               2    

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------
   if $user == 1 {
       global projectfolder 	"/Users/vivianamorim/OneDrive/World Bank/Education/SP_H1N1 & School Closure"
	   
	   *If you want access to Education Data folder, please ask
	   global educationdata		"/Users/vivianamorim/OneDrive/Data Analysis"
	   global ideb         		"$educationdata/IDEB/DataWork/Datasets/3. Final"
	   global provabrasil       "$educationdata/Prova Brasil/DataWork/Datasets/3. Final"
	   global censoescolar      "$educationdata/Censo Escolar/DataWork/Datasets/3. Final"
	   global rendimento        "$educationdata/Rendimento/DataWork/Datasets/3. Final" 
	   global fnde        		"$educationdata/Gasto_FNDE/DataWork/Datasets/3. Final" 
   }

   if $user == 2 {
       global projectfolder ""  
   }
   
   * Project folder globals
   * ---------------------
   global datawork         	"$projectfolder/DataWork"
   global output           	"$datawork/Output"
   global datasets         	"$datawork/Datasets"
   global dofiles          	"$datawork/Do files"
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
	  
