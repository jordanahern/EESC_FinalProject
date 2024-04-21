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
%Load dataset
Sundata = readtable("SolarData.csv");
%Specify columns
Suncolumns =  {'capacity_factor','capacity_mw','area_sq_km','longitude','latitude'};
%Latitude and Longitude
sunlat = Sundata.latitude;
sunlon = Sundata.longitude;
%New dataset w specified columns
NewSunData = Sundata(:,Suncolumns);
% Replace NaN values with zeros

for idx = 1:length(Suncolumns)
    NewSunData.(Suncolumns{idx})(isnan(NewSunData.(Suncolumns{idx}))) = 0;
end

suncapacityfactor = Sundata.capacity_factor;
suncapacitymw = Sundata.capacity_mw;
rawsuncapacity = suncapacityfactor.*suncapacitymw;
sizeData = 100 * (rawsuncapacity / max(rawsuncapacity));
colorData = Sundata.capacity_factor;
figure; 
g = geoscatter(sunlat, sunlon, sizeData, colorData, 'filled');
hold on
title('Solar Technical Capacity (MW)')

%% 
% Load dataset
Sundata = readtable("SolarData.csv");
% Specify columns
Suncolumns = {'capacity_factor','capacity_mw','area_sq_km','longitude','latitude'};
% Latitude and Longitude
sunlat = Sundata.latitude;
sunlon = Sundata.longitude;
% New dataset with specified columns
NewSunData = Sundata(:,Suncolumns);
% Replace NaN values with zeros
for idx = 1:length(Suncolumns)
    NewSunData.(Suncolumns{idx})(isnan(NewSunData.(Suncolumns{idx}))) = 0;
end

suncapacityfactor = Sundata.capacity_factor;
suncapacitymw = Sundata.capacity_mw;
rawsuncapacity = suncapacityfactor .* suncapacitymw;
sizeData = 100 * (rawsuncapacity / max(rawsuncapacity));
colorData = Sundata.capacity_factor;

figure;
g = geoscatter(sunlat, sunlon, sizeData, colorData, 'filled');
hold on;
title('Solar energy Technical Potential. Sized by Capacity (MW), Colored by Capacity Factor (%)');
colorbar; % Adds a color bar on the side of the figure
colormap parula; % Sets the color map used for the color bar
caxis([min(colorData) max(colorData)]); % Sets the range of data values covered by the colormap
ylabel(colorbar, 'Capacity Factor'); % Label the color bar
hold off;


%% WIND

% Load the dataset
WindData = readtable('WindData.csv');
% Specify the columns to include in the new dataset
WindColumnsToInclude = {'longitude', 'latitude', 'capacity', 'capacity_factor', 'wind_speed'};
% Create the new dataset with the specified columns
NewWindData = WindData(:, WindColumnsToInclude);
% Specify new, more readable names for these columns
newWindColumnNames = {'Longitude', 'Latitude', 'Capacity', 'Capacity_Factor', 'Wind_Speed'};
% Rename the columns in the new dataset
NewWindData.Properties.VariableNames = newWindColumnNames;
% Convert all necessary columns from strings to numeric (if any were imported as strings)
for idx = 1:length(newWindColumnNames)
    if iscategorical(NewWindData.(newWindColumnNames{idx})) || iscell(NewWindData.(newWindColumnNames{idx}))
        NewWindData.(newWindColumnNames{idx}) = str2double(strrep(strrep(table2array(NewWindData(:, idx)), '(', '-'), ')', ''));
    end
end
% Replace NaN values with zeros
for idx = 1:length(newWindColumnNames)
    NewWindData.(newWindColumnNames{idx})(isnan(NewWindData.(newWindColumnNames{idx}))) = 0;
end
% Calculate Energy Output
WindEnergyOutput = NewWindData.Capacity .* NewWindData.Capacity_Factor;
% Add the new variable to the table
NewWindData = addvars(NewWindData, WindEnergyOutput);

% Prepare color and size data
colorWindData = NewWindData.Capacity_Factor;  % Color by capacity factor
sizeWindData = 100 * (WindEnergyOutput / max(WindEnergyOutput));  % Size relative to maximum output

% Create a figure to hold the map
figure;
% Plot each power plant on the map using geoscatter
f = geoscatter(NewWindData.Latitude, NewWindData.Longitude, sizeWindData, colorWindData, 'filled');
% Set the colormap
colormap(parula);  % 'parula' has a nice gradient from blue to yellow, good for continuous data
colorbar;  % Adds a color bar to indicate the scale of capacity factors
ylabel(colorbar, 'Capacity Factor (%)');  % Label the color bar

% Set map limits to focus on the specific geographic area if needed
% geolimits([24 50],[-125 -66]);  % Uncomment and adjust if you need to set specific geographic boundaries

% Add a title
title('Wind energy Technical Potential. Sized by Capacity (MW), Colored by Capacity Factor (%)');
% Set the map's appearance
geobasemap grayland;  % A simple basemap that highlights data points
grid on;  % Turn on the grid for better orientation




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

%%

% Define the latitude and longitude limits for the continental US
latlim = [min(NewPlantData.Latitude) max(NewPlantData.Latitude)];
lonlim = [min(NewPlantData.Longitude) max(NewPlantData.Longitude)];

% Define a grid for interpolation
[xq, yq] = meshgrid(linspace(lonlim(1), lonlim(2), 500), ...
                    linspace(latlim(1), latlim(2), 500));

% Interpolate the data
F = scatteredInterpolant(NewPlantData.Latitude, NewPlantData.Longitude, NewPlantData.CO2_Emissions, 'natural', 'none');
vq = F(yq, xq);

% Set up the US map
figure;
ax = usamap(latlim, lonlim);
set(ax, 'Visible', 'off') % Hide the default axes

% Display the heatmap
surfm(yq, xq, vq);

% Overlay the state boundaries
states = shaperead('usastatelo', 'UseGeoCoords', true);
geoshow(ax, states, 'DisplayType', 'polygon', 'FaceColor', 'none');

% Set the colormap and colorbar
colormap(ax, parula);
colorbar;

% Add title
title('Heatmap of US Power Plants: Color by CO2 Rate');


%% 

% Aggregate solar and wind data to nearest power plant coordinates
% We'll use a simple nearest neighbor approach here for demonstration
% Find nearest solar data point for each power plant
nearestSolarIndex = knnsearch([NewSunData.latitude, NewSunData.longitude], [NewPlantData.Latitude, NewPlantData.Longitude]);
nearestSolarCapacity = NewSunData.capacity_mw(nearestSolarIndex);

% Find nearest wind data point for each power plant
nearestWindIndex = knnsearch([NewWindData.Latitude, NewWindData.Longitude], [NewPlantData.Latitude, NewPlantData.Longitude]);
nearestWindCapacity = NewWindData.Capacity(nearestWindIndex);

% Calculate Pearson correlation for CO2 emissions with solar and wind capacities
[rSolar, pValueSolar] = corr(NewPlantData.CO2_Emissions, nearestSolarCapacity, 'Type', 'Pearson');
[rWind, pValueWind] = corr(NewPlantData.CO2_Emissions, nearestWindCapacity, 'Type', 'Pearson');

% Display results
fprintf('Pearson correlation coefficient between CO2 Emissions and Solar Capacity: %f (p-value = %f)\n', rSolar, pValueSolar);
fprintf('Pearson correlation coefficient between CO2 Emissions and Wind Capacity: %f (p-value = %f)\n', rWind, pValueWind);
%% 
% Scatter plot for CO2 Emissions vs. Solar Capacity
figure;
scatter(NewPlantData.CO2_Emissions, nearestSolarCapacity, 'filled');
xlabel('CO2 Emissions (tons)');
ylabel('Solar Capacity (MW)');
title('Scatter Plot of CO2 Emissions vs. Solar Capacity');

% Scatter plot for CO2 Emissions vs. Wind Capacity
figure;
scatter(NewPlantData.CO2_Emissions, nearestWindCapacity, 'filled');
xlabel('CO2 Emissions (tons)');
ylabel('Wind Capacity (MW)');
title('Scatter Plot of CO2 Emissions vs. Wind Capacity');
%% 
% Constants
maxDistanceKm = 50; % Maximum distance to include renewable data points
earthRadiusKm = 6371; % Earth's radius in kilometers

% Convert degrees to radians for computation
plantDataRadians = [deg2rad(NewPlantData.Latitude), deg2rad(NewPlantData.Longitude)];
solarDataRadians = [deg2rad(NewSunData.latitude), deg2rad(NewSunData.longitude)];
windDataRadians = [deg2rad(NewWindData.Latitude), deg2rad(NewWindData.Longitude)];

% Pre-allocate arrays for storing weighted averages
weightedSolarCapacityFactor = zeros(height(NewPlantData), 1);
weightedWindCapacityFactor = zeros(height(NewPlantData), 1);

% Calculate weighted average for Solar Capacity Factor
for i = 1:height(NewPlantData)
    distances = distance(plantDataRadians(i,1), plantDataRadians(i,2), solarDataRadians(:,1), solarDataRadians(:,2), earthRadiusKm);
    withinThreshold = distances <= maxDistanceKm;
    weights = 1 ./ distances(withinThreshold);
    weightedSolarCapacityFactor(i) = sum(NewSunData.capacity_factor(withinThreshold) .* weights) / sum(weights);
end

% Calculate weighted average for Wind Capacity Factor
for i = 1:height(NewPlantData)
    distances = distance(plantDataRadians(i,1), plantDataRadians(i,2), windDataRadians(:,1), windDataRadians(:,2), earthRadiusKm);
    withinThreshold = distances <= maxDistanceKm;
    weights = 1 ./ distances(withinThreshold);
    weightedWindCapacityFactor(i) = sum(NewWindData.Capacity_Factor(withinThreshold) .* weights) / sum(weights);
end

% Now perform correlation analysis with these weighted averages
[rhoSolar, pValueSolar] = corr(NewPlantData.CO2_Emissions, weightedSolarCapacityFactor, 'Type', 'Spearman');
[rhoWind, pValueWind] = corr(NewPlantData.CO2_Emissions, weightedWindCapacityFactor, 'Type', 'Spearman');

% Display the correlation results
fprintf('Spearman correlation coefficient between CO2 Emissions and Weighted Solar Capacity Factor: %f (p-value = %f)\n', rhoSolar, pValueSolar);
fprintf('Spearman correlation coefficient between CO2 Emissions and Weighted Wind Capacity Factor: %f (p-value = %f)\n', rhoWind, pValueWind);
