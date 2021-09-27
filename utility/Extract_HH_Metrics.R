# Extract metrics from a Portland Metro VERSPM model and save the results
# Assumptions: 
# 1. You have completed one or more VERSPM models
# 2. These models are in the `models` directory of your VisionEval installation
# 3. You launched VisionEval.Rproj to open this session in RStudio
# 4. You want to extract a select set of household level metrics 

# Setup ----
library(dplyr)   # install.packages(dplyr)
library(stringr) # install.packages(stringr)

# User Input ----
# Input the name of the completed VERSPM model

modelName <- 'VERSPM'  # could be RefCase or similar

metric_level <- 'Bzone' # Options are Bzone or Household. If Household, will report out metrics for each Household (large files).

# Extract ----
# Define a function to extract metrics from each model folder

extract_scenario_metrics <- function(modelName){
  # Will return an error if the model doesn't exist yet
  mod <- openModel(modelName) 
  
  # Household level
  # First clear the selections
  mod$tables <- ''
  mod$fields <- ''
  
  mod$tables <- 'Household'
  mod$fields <- c('Bzone',
                  'Dvmt',
                  'DailyCO2e'
                  
                  # Other options include:
                  # 'Income',
                  # 'OwnCost',
                  # 'WalkTrips',
                  # 'VehicleTrips',
                  # 'BikeTrips',
                  # 'TransitTrips',
                  # 'DailyKWH',
                  # Daily GGE
                  )
  
  cat('Extracting \t', mod$groupsSelected, '\t',
      mod$tablesSelected, '\n', 
      paste(mod$fieldsSelected, collapse = '\t'))
  
  hh_results <- mod$extract(saveTo = F, quiet = T)
  
  hh_results
}



results <- extract_scenario_metrics(modelName)

# This looks for a four-digit number in the names of the results tables, e.g. _2010_, and returns just the year 2010
years_run = str_match(names(results), '(?:_)(\\d{4})(?:_)')[,2]

if(metric_level == 'Household'){

  hh_compiled <- vector() # make one big data frame for all years
  
  # Also have individual year data frames, e.g. hh_2010
  
  for(y in years_run){
    
    assign(paste0('hh_', y), results[[grep(y, names(results))]]) 
    
    hh_compiled <- rbind(hh_compiled, data.frame(Year = y, get(paste0('hh_', y))))
    
    # Save to csv as well
    output_path = file.path(ve.runtime, 'models', modelName, 'output')
    if(!dir.exists(output_path)){ dir.create(output_path)}
    
    write.csv(get(paste0('hh_', y)),
              file.path(output_path, paste0('Household_Metrics_', y, '.csv')),
              row.names = F)
    
  }
  
  
  # Now you have one big data frame with all the years (this could be super big, one row per household per year)
  View(hh_compiled)
}

if(metric_level == 'Bzone'){
  
  Bz_compiled <- vector() # make one big data frame for all years
  
  for(y in years_run){
    
    assign(paste0('hh_', y), results[[grep(y, names(results))]]) 
    
    # Aggregate to Bzone. Assumes metrics are to be summed; requries modification for other aggregation methods
    Bz_y <- get(paste0('hh_', y))
    Bz_y_agg <- Bz_y %>%
      group_by(Bzone) %>%
      summarise_if(is.numeric, sum) 

    Bz_compiled <- rbind(Bz_compiled, data.frame(Year = y, Bz_y_agg))
    
  } 
  
  output_path = file.path(ve.runtime, 'models', modelName, 'output')
  if(!dir.exists(output_path)){ dir.create(output_path)}
  
  write.csv(Bz_compiled,
            file.path(output_path, 'Bzone_Metrics.csv'),
            row.names = F)
} 

# Summarize by Bzone geography type ----

# To extract metrics for just a subset of Bzones, now you can join in a table with two columns:
# Bzone | CityofPortland
# Then you can subset the whole hh_compiled data frame for just those Bzones which are in the City of Portland
# Or if aggregated to Bzone level already, just take the metrics applicable by Bzone.

# You also have a data frame for each year
# View(hh_2010) # if you have a 2010 year



bzone_geo_file <- 'bzone_summary_RVMPO.csv' # Replace with bzone_summary_Portland.csv or similar

if(!file.exists(bzone_geo_file)){
  stop(paste(bzone_geo_file, 'not found in the directory', path.expand(getwd()), '\n Please place the Bzone geography file in this directory.'))
}

bzone_geo <- read.csv(bzone_geo_file)

# Make sure this geo file has the same Bzones as in our model
stopifnot(all(bzone_geo$Bzone %in% Bz_compiled$Bzone) & all(Bz_compiled$Bzone %in% bzone_geo$Bzone))

Bz_compiled <- Bz_compiled %>% left_join(bzone_geo)

COP_measures <- Bz_compiled %>%
  filter(COP == 1) %>%
  group_by(Year) %>%
  summarize(HHCO2_COP = sum(DailyCO2e),
            HHVMT_COP = sum(Dvmt)) 

Urban_measures <- Bz_compiled %>%
  filter(Urban == 1) %>%
  group_by(Year) %>%
  summarize(HHCO2_Urban = sum(DailyCO2e),
            HHVMT_Urban = sum(Dvmt))

Region_measures <- Bz_compiled %>%
  filter(Region == 1) %>%
  group_by(Year) %>%
  summarize(HHCO2_Region = sum(DailyCO2e),
            HHVMT_Region = sum(Dvmt))

# Join together and organize 
overall <- left_join(COP_measures, Urban_measures)
overall <- left_join(overall, Region_measures) 

overall <- tibble::column_to_rownames(overall, var = 'Year')
overall <- tibble::rownames_to_column(as.data.frame(t(overall)), var = 'Measure')
overall <- overall %>% arrange(Measure)

write.csv(overall,
          file.path(output_path, 'Bzone_Metrics_Geo_Summary.csv'),
          row.names = F)

# Get units ----

# DatastoreListing
# This listing is maintained internally and contains the definitive list of what is in the Datastore.

dfls <- get(load(file.path('models', modelName, "Datastore", "DatastoreListing.Rda")))

# DatastoreListing attributes
attr.names <- unique(unlist(sapply(dfls$attributes, names)))

attr2df <- function(atts) {
  td <- lapply(atts,function(x)lapply(x, paste, collapse=" | ")) # make attributes into strings (some are vectors)
  df <- data.frame(sapply(attr.names, function(x) character(0)))          # empty data.frame to hold results
  el <- lapply(attr.names, function(x) "")                                # create list of empty strings
  names(el) <- attr.names                                               # name the list after attr.names
  df.rows <- lapply(td, function(x) { nw <- el; nw[names(x)] <- x; nw })
  atts <- data.frame(bind_rows(df.rows))
  atts <- atts[which(atts$NAME != "" & atts$TABLE != "" & atts$GROUP != ""),]  # Keep only the datasets
  return(atts)
}

atts <- attr2df(dfls$attributes)

# Subset to the metrics we used
# First, identify the compiled metrics we extracted
if(exists('hh_compiled')){
  extracted_metric_compilation = hh_compiled
} 

if(exists('Bz_compiled')){
  extracted_metric_compilation = Bz_compiled
  
}

metric_units <- atts %>%
  filter(NAME %in% c(names(extracted_metric_compilation))) %>%
  filter(TABLE %in% c('Household')) %>%
  select(NAME, TABLE, TYPE, UNITS, DESCRIPTION, MODULE) %>%
  filter(!duplicated(NAME))


write.csv(metric_units, file.path(output_path, "Extracted_Metric_Units.csv"),
          row.names = F)
