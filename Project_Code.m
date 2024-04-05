% Load in data 
PlantData = readtable('Power_Generation_Emissions.csv');

boxplot(PlantData.x2023_CO2_Rate,PlantData.FuelType)















