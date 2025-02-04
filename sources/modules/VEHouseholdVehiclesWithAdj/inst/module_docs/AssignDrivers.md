
# AssignDrivers Module
### May 8, 2020

This module assigns drivers by age group to each household as a function of the numbers of persons and workers by age group, the household income, land use characteristics, and public transit availability. Users may optionally specify regional targets for the ratio of drivers to persons by age group. If targets are supplied, the module will adjust the number of drivers in a selection of households to match the targets.

## Model Parameter Estimation

Binary logit models are estimated to predict the probability that a person has a drivers license. Two versions of the model are estimated, one for persons in a metropolitan (i.e. urbanized) area, and another for persons located in non-metropolitan areas. There are different versions because the estimation data have more information about transportation system and land use characteristics for households located in urbanized areas. In both versions, the probability that a person has a drivers license is a function of the age group of the person, whether the person is a worker, the number of persons in the household, the income and squared income of the household, whether the household lives in a single-family dwelling, and the population density of the Bzone where the person lives. In the metropolitan area model, the bus-equivalent transit revenue miles and whether the household resides in an urban mixed-use neighborhood are significant factors. Following are the summary statistics for the metropolitan model:

```

Call:
glm(formula = makeFormula(StartTerms_), family = binomial, data = EstData_df[TrainIdx, 
    ])

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.3128   0.1293   0.2088   0.3980   3.0793  

Coefficients:
                  Estimate Std. Error z value Pr(>|z|)    
(Intercept)     -1.802e+01  1.046e+02  -0.172    0.863    
Age15to19        1.714e+01  1.046e+02   0.164    0.870    
Age20to29        1.960e+01  1.046e+02   0.187    0.851    
Age30to54        1.991e+01  1.046e+02   0.190    0.849    
Age55to64        1.971e+01  1.046e+02   0.188    0.851    
Age65Plus        1.915e+01  1.046e+02   0.183    0.855    
Worker           1.260e+00  5.111e-02  24.650   <2e-16 ***
HhSize          -2.681e-01  1.656e-02 -16.185   <2e-16 ***
Income           4.404e-05  1.993e-06  22.100   <2e-16 ***
IncomeSq        -1.818e-10  1.189e-11 -15.290   <2e-16 ***
IsSF             4.439e-01  5.096e-02   8.710   <2e-16 ***
PopDensity      -4.143e-05  3.173e-06 -13.057   <2e-16 ***
IsUrbanMixNbrhd -5.938e-01  5.963e-02  -9.959   <2e-16 ***
TranRevMiPC     -8.115e-03  7.522e-04 -10.789   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 26759  on 31394  degrees of freedom
Residual deviance: 14926  on 31381  degrees of freedom
  (10167 observations deleted due to missingness)
AIC: 14954

Number of Fisher Scoring iterations: 16

```

Following are the summary statistics for the non-metropolitan model:

```

Call:
glm(formula = makeFormula(StartTerms_), family = binomial, data = EstData_df[TrainIdx, 
    ])

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.2811   0.1216   0.1761   0.3464   2.6088  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept) -1.941e+01  1.145e+02  -0.170    0.865    
Age15to19    1.848e+01  1.145e+02   0.161    0.872    
Age20to29    2.081e+01  1.145e+02   0.182    0.856    
Age30to54    2.103e+01  1.145e+02   0.184    0.854    
Age55to64    2.100e+01  1.145e+02   0.183    0.854    
Age65Plus    2.034e+01  1.145e+02   0.178    0.859    
Worker       1.630e+00  4.595e-02  35.479   <2e-16 ***
HhSize      -2.294e-01  1.466e-02 -15.653   <2e-16 ***
Income       4.338e-05  1.802e-06  24.065   <2e-16 ***
IncomeSq    -1.963e-10  1.132e-11 -17.343   <2e-16 ***
IsSF         3.993e-01  4.327e-02   9.228   <2e-16 ***
PopDensity  -6.212e-05  3.668e-06 -16.935   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 43517  on 57790  degrees of freedom
Residual deviance: 21801  on 57779  degrees of freedom
  (16555 observations deleted due to missingness)
AIC: 21825

Number of Fisher Scoring iterations: 17

```

The models are estimated using the *Hh_df* (household) and *Per_df* (person) datasets in the VE2001NHTS package. Information about these datasets and how they were developed from the 2001 National Household Travel Survey public use dataset is included in that package.

## How the Module Works

The module iterates through each age group excluding the 0-14 year age group and creates a temporary set of person records for households in the region. For each household there are as many person records as there are persons in the age group in the household. A worker status attribute is added to each record based on the number of workers in the age group in the household. For example, if a household has 2 persons and 1 worker in the 20-29 year age group, one of the records would have its worker status attribute equal to 1 and the other would have its worker status attribute equal to 0. The person records are also populated with the household characteristics used in the model. The binomial logit model is applied to the person records to determine the probability that each person is a driver. The driver status of each person is determined by random draws with the modeled probability determining the likelihood that the person is determined to be a driver. The resulting number of drivers in the age group is then tabulated by household.

The module accepts an optional input file *region_hh_ave_driver_per_capita.csv* that is used to specify ratios of licensed drivers to population by age group in the region for each model run year. The specifications for this file are described in the table below. If the file is present, the driver assignments computed by the model are adjusted to match the input target ratios. The process for making adjustments is described below. Although these inputs are not required, they may be important for calibrating the model for the base year and other past years that are modeled. The number of drivers in the household are significant inputs to the vehicle ownership and household travel models. Therefore if the modeled number of drivers is not consistent with observed values, the modeled estimates of household vehicles and household DVMT may not be consistent with observed values as well. These inputs may also be important for modeling future scenarios which assume future changes in driver licensing rates.

Adjustments to match target inputs are done by age group as follows:
1. The driver model (binomial logit model) is applied to make an initial assignment of drivers in the age group as described above.
2. The difference in the total modeled number of drivers in the region and target number of drivers is calculated.
3. If the model produces fewer drivers than the target number, additional drivers equal to the calculated difference are assigned from the unassigned population. The assignment is done by sampling from this population where the probability that a person is assigned is the modeled probability that the person is a driver.
4. If the model produced more drivers than the target number, then a number of assigned drivers equal to the calculated difference is removed from the assigned population. The unassignment is done by sampling from this population where the probability of a driver being unassigned is 1 minus the model probability that the person is a driver.

The values for the target ratios may be computed from state or federal data sources. State motor vehicle departments maintain data on licensed drivers and their ages. However, because the structure of those data and the means of acquiring them will vary by state no suggestions are made here regarding how to acquire or process them. Alternately, driver ratios may be computed from data published in Highway Statistics reports by the Federal Highway Administration. Both the state and federal data may be used to calculate the driver ratios by age group at the state level. However, if the user is not satisfied with using the state-level ratios for their model region, they will need to use data from their state's motor vehicle department for their area. The advantage of using data from the FHWA Highway Statistics reports is that they are available in a consistent and easy to use format from 1995 to the present. This can be useful for evaluating trends over time and consider the implications for future licensing rates. Following are the relevant report tables:

**Table DL-20** (Licensed drivers, by sex and percentage in each age group) provides ratios of drivers to population by age group for the nation. If the user is willing to assume that the driver ratios in their region match those of the nation then data in this table can be used to populate the values in the *region_hh_ave_driver_per_capita.csv* file. Aggregation of age groups in the table will be necessary.

**Table DL-22** (Licensed drivers, by State, sex, and age group) provides the number of drivers by age group by state. Aggregation of age groups in this table will be necessary. These data would need to be combined with estimates of population by age group to calculate the driver ratios. The population by age group tablulations are in the *azone_hh_pop_by_age.csv* input file that the user prepared for the *CreateHouseholds* module.


## User Inputs
The following table(s) document each input file that must be provided in order for the module to run correctly. User input files are comma-separated valued (csv) formatted text files. Each row in the table(s) describes a field (column) in the input file. The table names and their meanings are as follows:

NAME - The field (column) name in the input file. Note that if the 'TYPE' is 'currency' the field name must be followed by a period and the year that the currency is denominated in. For example if the NAME is 'HHIncomePC' (household per capita income) and the input values are in 2010 dollars, the field name in the file must be 'HHIncomePC.2010'. The framework uses the embedded date information to convert the currency into base year currency amounts. The user may also embed a magnitude indicator if inputs are in thousand, millions, etc. The VisionEval model system design and users guide should be consulted on how to do that.

TYPE - The data type. The framework uses the type to check units and inputs. The user can generally ignore this, but it is important to know whether the 'TYPE' is 'currency'

UNITS - The units that input values need to represent. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values may not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Value must be one of the listed values.

UNLIKELY - Values that are unlikely. Values that meet any of the listed conditions are permitted but a warning message will be given when the input data are processed.

DESCRIPTION - A description of the data.

### region_hh_ave_driver_per_capita.csv
This input file is OPTIONAL.

|NAME             |TYPE     |UNITS    |PROHIBIT     |ISELEMENTOF |UNLIKELY |DESCRIPTION                                                            |
|:----------------|:--------|:--------|:------------|:-----------|:--------|:----------------------------------------------------------------------|
|Year             |         |         |             |            |         |Must contain a record for each model run year                          |
|DrvPerPrsn15to19 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 15 to 19 years old age group |
|DrvPerPrsn20to29 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 20 to 29 years old age group |
|DrvPerPrsn30to54 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 30 to 54 years old age group |
|DrvPerPrsn55to64 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 55 to 64 years old age group |
|DrvPerPrsn65Plus |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 65 or older age group        |

## Datasets Used by the Module
The following table documents each dataset that is retrieved from the datastore and used by the module. Each row in the table describes a dataset. All the datasets must be present in the datastore. One or more of these datasets may be entered into the datastore from the user input files. The table names and their meanings are as follows:

NAME - The dataset name.

TABLE - The table in the datastore that the data is retrieved from.

GROUP - The group in the datastore where the table is located. Note that the datastore has a group named 'Global' and groups for every model run year. For example, if the model run years are 2010 and 2050, then the datastore will have a group named '2010' and a group named '2050'. If the value for 'GROUP' is 'Year', then the dataset will exist in each model run year group. If the value for 'GROUP' is 'BaseYear' then the dataset will only exist in the base year group (e.g. '2010'). If the value for 'GROUP' is 'Global' then the dataset will only exist in the 'Global' group.

TYPE - The data type. The framework uses the type to check units and inputs. Refer to the model system design and users guide for information on allowed types.

UNITS - The units that input values need to represent. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values in the datastore do not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Values in the datastore are one or more of the listed values.

|NAME             |TABLE     |GROUP |TYPE      |UNITS      |PROHIBIT     |ISELEMENTOF        |
|:----------------|:---------|:-----|:---------|:----------|:------------|:------------------|
|DrvPerPrsn15to19 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn20to29 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn30to54 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn55to64 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn65Plus |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|Marea            |Marea     |Year  |character |ID         |             |                   |
|TranRevMiPC      |Marea     |Year  |compound  |MI/PRSN/YR |NA, < 0      |                   |
|Bzone            |Bzone     |Year  |character |ID         |             |                   |
|D1B              |Bzone     |Year  |compound  |PRSN/SQMI  |NA, < 0      |                   |
|Marea            |Household |Year  |character |ID         |             |                   |
|Bzone            |Household |Year  |character |ID         |             |                   |
|HhId             |Household |Year  |character |ID         |             |                   |
|Age15to19        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age20to29        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age30to54        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age55to64        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age65Plus        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr15to19        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr20to29        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr30to54        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr55to64        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr65Plus        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Income           |Household |Year  |currency  |USD.2001   |NA, < 0      |                   |
|HhSize           |Household |Year  |people    |PRSN       |NA, <= 0     |                   |
|HouseType        |Household |Year  |character |category   |             |SF, MF, GQ         |
|IsUrbanMixNbrhd  |Household |Year  |integer   |binary     |NA           |0, 1               |
|LocType          |Household |Year  |character |category   |NA           |Urban, Town, Rural |

## Datasets Produced by the Module
The following table documents each dataset that is placed in the datastore by the module. Each row in the table describes a dataset. All the datasets must be present in the datastore. One or more of these datasets may be entered into the datastore from the user input files. The table names and their meanings are as follows:

NAME - The dataset name.

TABLE - The table in the datastore that the data is placed in.

GROUP - The group in the datastore where the table is located. Note that the datastore has a group named 'Global' and groups for every model run year. For example, if the model run years are 2010 and 2050, then the datastore will have a group named '2010' and a group named '2050'. If the value for 'GROUP' is 'Year', then the dataset will exist in each model run year. If the value for 'GROUP' is 'BaseYear' then the dataset will only exist in the base year group (e.g. '2010'). If the value for 'GROUP' is 'Global' then the dataset will only exist in the 'Global' group.

TYPE - The data type. The framework uses the type to check units and inputs. Refer to the model system design and users guide for information on allowed types.

UNITS - The native units that are created in the datastore. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values in the datastore do not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Values in the datastore are one or more of the listed values.

DESCRIPTION - A description of the data.

|NAME          |TABLE     |GROUP |TYPE   |UNITS |PROHIBIT |ISELEMENTOF |DESCRIPTION                                            |
|:-------------|:---------|:-----|:------|:-----|:--------|:-----------|:------------------------------------------------------|
|Drv15to19     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 15 to 19 years old                   |
|Drv20to29     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 20 to 29 years old                   |
|Drv30to54     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 30 to 54 years old                   |
|Drv55to64     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 55 to 64 years old                   |
|Drv65Plus     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 65 or older                          |
|Drivers       |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers in household                         |
|DrvAgePersons |Household |Year  |people |PRSN  |NA, < 0  |            |Number of people 15 year old or older in the household |
