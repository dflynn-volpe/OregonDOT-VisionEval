require(devtools)

# Launch from VisionEval.Rproj
# Assumes you've already copied the module sources from OregonDOT-VisionEval repository
# Into a location called 'ODOT_Modules'
# This avoids the httr dependency which causes problems for PBOT users
# It still requires devtools, installation of which might be problematic for PBOT as it requires RTools 


update_modules <- c('VEPowertrainsAndFuels',
                    'VEPowertrainsAndFuelsx4TargetRule',
                    'VEPowertrainsAndFuelsxAP',
                    'VEPowertrainsAndFuelsxAP2',
                    'VEPowertrainsAndFuelsxAP20200131',
                    'VEPowertrainsAndFuelsxSTSRec',
                    'VEPowertrainsAndFuelsxSTSRecOnRoad')

source_location <- 'ODOT_Modules'

if(!dir.exists(source_location)) { 
  dir.create(source_location)
  cat(paste('Please copy the module folders from OregonDOT-VisionEval and put them here:', source_location))
  }

available_modules <- update_modules[update_modules %in% dir(source_location)]

for (Pkg in available_modules) {
  devtools::install_local(
    path = file.path(source_location, Pkg), 
    dependencies = TRUE,
    upgrade = FALSE,
    lib = 've-lib')
}
