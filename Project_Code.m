% Load the dataset
PlantData = readtable('Power_Generation_Emissions.csv');

% Specify the columns to include in the new dataset
columnsToInclude = {'Lat', 'Long', 'x2023_CO2_Emissions', 'x2023_NOX_Emissions', 'x2023_SO2_Emissions', 'x2023_CO2_Rate', 'x2023_NOX_Rate', 'x2023_SO2_Rate', 'HeatRate_MBTU'};

% Create the new dataset with the specified columns
NewPlantData = PlantData(:, columnsToInclude);

% Specify new, more readable names for these columns
newColumnNames = {'Latitude', 'Longitude', 'CO2_Emissions', 'NOX_Emissions', 'SO2_Emissions', 'CO2_Rate', 'NOX_Rate', 'SO2_Rate', 'Heat_Rate'};

% Rename the columns in the new dataset
NewPlantData.Properties.VariableNames = newColumnNames;

% Convert all necessary columns from strings to numeric (if any were imported as strings)
for idx = 1:length(newColumnNames)
    if iscategorical(NewPlantData.(newColumnNames{idx})) || iscell(NewPlantData.(newColumnNames{idx}))
        NewPlantData.(newColumnNames{idx}) = str2double(strrep(strrep(table2array(NewPlantData(:, idx)), '(', '-'), ')', ''));
    end
end

% Replace NaN values with zeros
for idx = 1:length(newColumnNames)
    NewPlantData.(newColumnNames{idx})(isnan(NewPlantData.(newColumnNames{idx}))) = 0;
end

% Remove rows where CO2_Emissions is zero
NewPlantData(NewPlantData.CO2_Emissions == 0, :) = [];

%% 
CO2_Rate = NewPlantData.CO2_Rate;
boxplot(CO2_Rate);
title('Box Plot of 2023 CO2 Emission Rates');
xlabel('CO2 Emission Rate');
ylabel('lb of CO2 per MMBTU');

%% 
SO2_Rate = NewPlantData.SO2_Rate;
boxplot(SO2_Rate);
title('Box Plot of 2023 SO2 Emission Rates');
xlabel('SO2 Emission Rate');
ylabel('lb of SO2 per MMBTU');

%% 
NOX_Rate = NewPlantData.NOX_Rate;
boxplot(NOX_Rate);
title('Box Plot of 2023 NOX Emission Rates');
xlabel('NOX Emission Rate');
ylabel('lb of NOX per MMBTU');

%% 

% Replace any zero emissions to avoid errors in size scaling
NewPlantData.CO2_Emissions(NewPlantData.CO2_Emissions == 0) = min(NewPlantData.CO2_Emissions(NewPlantData.CO2_Emissions > 0));

% Prepare size data: Scale CO2 Emissions for visibility
% You can adjust the scaling factor as needed
sizeData = 100 * (NewPlantData.CO2_Emissions / max(NewPlantData.CO2_Emissions));

% Prepare color data: Use CO2 Rates
colorData = NewPlantData.CO2_Rate;

% Create a figure to hold the map
figure;

% Plot each power plant on the map using geoscatter
h = geoscatter(NewPlantData.Latitude, NewPlantData.Longitude, sizeData, colorData, 'filled');

% Enhance the colormap to represent emissions rate intensity
colormap(parula);  % 'parula' uses a spectrum from blue to yellow
colorbar;  % Adds a color bar to indicate the scale of CO2 Rates

% Set color limits starting at 100
caxis([100 max(colorData)]);

% Set map limits to focus on the United States
geolimits([24 50],[-125 -66]);  % These limits roughly frame the continental US

% Add a title
title('Map of US Power Plants: Size by CO2 Emissions, Color by CO2 Rate');

% Improve the map appearance
geobasemap grayland; %
grid on;  % Turn on the grid to help orient the map

