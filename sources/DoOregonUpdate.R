#================
#DoOregonUpdate.R
#================

#Brian Gregor
#12/19/2019

#This script updates an official VisionEval installation to include all the new or modified VisionEval packages that have been developed for the Oregon DOT. This script sources in the updateVisionEvalInstall.R script which defines the updateVisionEvalInstall.R script which implements the updating. Some important things to note:
#1) The VEInstallationDir argument is used to specify the full path to the VisionEval installation. Since it is unlikely that your installation directory (folder) is the same as mine, you will need to modify the argument assignment to identify the location of your VisionEval installation directory (folder).
#2) The Packages argument identifies all the new or modified VisionEval packages that have been developed for the Oregon DOT. Users who are not modeling places in Oregon may not want the install all the VEPowertrainsAndFuels packages. The packages that have names such as VEPowertrainsAndFuelsx4TargetRule reflect vehicle and fuel scenarios that Oregon is using for various studies. You may find them useful as well or you may want to develop VEVehiclesAndFuels packages that reflect vehicle and fuel characteristics of specific interest to your jurisdiction. You should, however, use the VEVehicleAndFuels package in this repository because it contains some code fixes to the official VEVehiclesAndFuels package.

# On install of R 4.0.2, may need to rebuild strex:
# install.packages('strex', lib = 've-lib')


# install.packages(c('devtools', 'httr'), lib = 've-lib')

source("updateVisionEvalInstall.R")
library(devtools)
library(httr)
updateVisionEvalInstall(
  From = list(
    Repository = "gregorbj/OregonDOT-VisionEval",
    Branch = "master"
  ),
  Packages = c(
    # "sources/framework/visioneval",
    # "sources/modules/VESimHouseholds",
    # "sources/modules/VEHouseholdVehicles",
    # "sources/modules/VEHouseholdVehiclesWithAdj",
    # "sources/modules/VEHouseholdTravel",
    # "sources/modules/VEPowertrainsAndFuels",
    "sources/modules/VEPowertrainsAndFuelsx4TargetRule",
    "sources/modules/VEPowertrainsAndFuelsxAP",
    "sources/modules/VEPowertrainsAndFuelsxSTSRec",
    "sources/modules/VEPowertrainsAndFuelsxSTSRecOnRoad"
    # "sources/modules/VESimLandUse",
    # "sources/modules/VETravelPerformance",
    # "sources/modules/VEReports",
    # "sources/modules/VELandUse"
  ),
  VEInstallationDir = "C:\\Users\\Daniel.Flynn\\Desktop\\VE_4-0-2"
)


### Usage:

# make a copy of VERSPM
rspm <- openModel('VERSPM')

odot_rspm <- rspm$copy('ODOT_VERSPM')

# Now manually edit models/ODOT_VERSPM/run_model.R to use VEPowertrainsAndFuelsx4TargetRule

# e.g.: runModule("CalculateCarbonIntensity",        "VEPowertrainsAndFuelsx4TargetRule", RunFor = "AllYears",    RunYear = Year)

# Then run the model

odot_rspm$run()
