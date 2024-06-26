% Load the dataset
PlantData = readtable('Power_Generation_Emissions.csv');

% Specify the columns to keep and make new dataset
columnsToInclude = {'Lat', 'Long', 'x2023_CO2_Emissions', 'x2023_NOX_Emissions', 'x2023_SO2_Emissions', 'x2023_CO2_Rate', 'x2023_NOX_Rate', 'x2023_SO2_Rate', 'HeatRate_MBTU'};
NewPlantData = PlantData(:, columnsToInclude);

% Change names of columns
newColumnNames = {'Latitude', 'Longitude', 'CO2_Emissions', 'NOX_Emissions', 'SO2_Emissions', 'CO2_Rate', 'NOX_Rate', 'SO2_Rate', 'Heat_Rate'};
NewPlantData.Properties.VariableNames = newColumnNames;

% Convert all necessary columns from strings to numeric and replace nan
for idx = 1:length(newColumnNames)
    if iscategorical(NewPlantData.(newColumnNames{idx})) || iscell(NewPlantData.(newColumnNames{idx}))
        NewPlantData.(newColumnNames{idx}) = str2double(strrep(strrep(table2array(NewPlantData(:, idx)), '(', '-'), ')', ''));
    end
end

for idx = 1:length(newColumnNames)
    NewPlantData.(newColumnNames{idx})(isnan(NewPlantData.(newColumnNames{idx}))) = 0;
end

% remove rows where CO2_Emissions is zero. I.e. they arent emitters
NewPlantData(NewPlantData.CO2_Emissions == 0, :) = [];

%% Boxplots! 

CO2_Rate = NewPlantData.CO2_Rate;
boxplot(CO2_Rate);
title('Box Plot of 2023 CO2 Emission Rates');
xlabel('CO2 Emission Rate');
ylabel('lb of CO2 per MMBTU');

SO2_Rate = NewPlantData.SO2_Rate;
boxplot(SO2_Rate);
title('Box Plot of 2023 SO2 Emission Rates');
xlabel('SO2 Emission Rate');
ylabel('lb of SO2 per MMBTU');


NOX_Rate = NewPlantData.NOX_Rate;
boxplot(NOX_Rate);
title('Box Plot of 2023 NOX Emission Rates');
xlabel('NOX Emission Rate');
ylabel('lb of NOX per MMBTU');


%%  Solar Data load and Map
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

Size_Solar_Capacity = 100* (Sundata.capacity_mw/ max(Sundata.capacity_mw));
Solar_CF = Sundata.capacity_factor;

% Sort the solar data by capacity factor in ascending order
[sortedSolarCF, idx] = sort(Solar_CF);
sortedSunLat = sunlat(idx);
sortedSunLon = sunlon(idx);
sortedSizeSolarCapacity = Size_Solar_Capacity(idx);  % Assuming Size_Solar_Capacity is aligned with the original data

% Visualization with sorted data
figure;
g = geoscatter(sortedSunLat, sortedSunLon, sortedSizeSolarCapacity, sortedSolarCF, 'filled');
hold on;
title('Solar energy Technical Potential, Colored by Capacity Factor (%)');
colorbar; % Adds a color bar on the side of the figure
colormap parula; % Sets the color map used for the color bar
caxis([min(sortedSolarCF) max(sortedSolarCF)]); % Adjusts the range of data values covered by the colormap to the sorted data
ylabel(colorbar, 'Capacity Factor'); % Label the color bar
hold off;


%% Wind data load and map

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
NewWindData = addvars(NewWindData, WindEnergyOutput);


% Sort the wind data by capacity factor in ascending order
sizeWindData = 100 * (NewWindData.Capacity / max(NewWindData.Capacity));  % Size relative to maximum output
[sortedWindCF, idx] = sort(NewWindData.Capacity_Factor);
sortedLat = NewWindData.Latitude(idx);
sortedLon = NewWindData.Longitude(idx);
sortedSize = sizeWindData(idx);  


% Visualization with sorted data
figure;
f = geoscatter(sortedLat, sortedLon, sortedSize, sortedWindCF, 'filled');
f.MarkerEdgeAlpha = .5;
f.MarkerFaceAlpha = .5;
colormap(parula);  % 'parula' has a nice gradient from blue to yellow, good for continuous data
colorbar;  % Adds a color bar to indicate the scale of capacity factors
ylabel(colorbar, 'Capacity Factor (%)');  % Label the color bar
title('Wind energy Technical Potential. Sized by Capacity (MW), Colored by Capacity Factor (%)');
geobasemap grayland;  % A simple basemap that highlights data points
grid on;  % Turn on the grid for better orientation







%% Map for Plant Emissions
% Replace any zero emissions to avoid errors in size scaling
NewPlantData.CO2_Emissions(NewPlantData.CO2_Emissions == 0) = min(NewPlantData.CO2_Emissions(NewPlantData.CO2_Emissions > 0));
% Prepare size data: Scale CO2 Emissions for visibility
% You can adjust the scaling factor as needed
sizeData = 100 * (NewPlantData.CO2_Emissions / max(NewPlantData.CO2_Emissions));
% Prepare color data: Use CO2 Rates
colorData = NewPlantData.CO2_Rate;

figure;
% Plot each power plant on the map
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
hold off

%% Map for Plant Emissions

% Replace any zero emissions to avoid errors in size scaling
NewPlantData.SO2_Emissions(NewPlantData.SO2_Emissions == 0) = min(NewPlantData.SO2_Emissions(NewPlantData.SO2_Emissions > 0));
% Prepare size data: Scale CO2 Emissions for visibility
sizeData_SO2 = 300 * (NewPlantData.SO2_Emissions / max(NewPlantData.SO2_Emissions));
% Prepare color data: Use CO2 Rates
colorData_SO2 = NewPlantData.SO2_Rate;
figure;
% Plot each power plant on the map using geoscatter
t = geoscatter(NewPlantData.Latitude, NewPlantData.Longitude, sizeData_SO2, colorData_SO2, 'filled');
% Enhance the colormap to represent emissions rate intensity
colormap(parula);  % 'parula' uses a spectrum from blue to yellow
colorbar;  % Adds a color bar to indicate the scale of CO2 Rates
% Set color limits starting at 100
%caxis([100 max(colorData)]);
% Set map limits to focus on the United States
geolimits([24 50],[-125 -66]);  % These limits roughly frame the continental US
% Add a title
title('Map of US Power Plants: Size by SO2 Emissions, Color by SO2 Rate');
% Improve the map
geobasemap grayland; %
grid on;  % Turn on the grid to help orient the map
hold off

%% Test of an interpolated heatmap of emissions rates

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
surfm(yq, xq, vq);

% Overlay the state boundaries
states = shaperead('usastatelo', 'UseGeoCoords', true);
geoshow(ax, states, 'DisplayType', 'polygon', 'FaceColor', 'none');

% Set the colormap and colorbar and title
colormap(ax, parula);
colorbar;
title('Heatmap of US Power Plants: Color by CO2 Rate');

%% Exploratory Scatter Plots

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
%% Correlation Calculations

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

%% Cost Basis Comparisons
Sundata = readtable("SolarData.csv");
WindData = readtable('WindData.csv');

% Extract Needed Data from Solar
Suncolumns = {'capacity_factor', 'longitude', 'latitude'};
NewSunData = Sundata(:, Suncolumns);
suncapacityfactor = Sundata.capacity_factor;

% Prepare Wind Data
WindColumnsToInclude = {'capacity_factor', 'longitude', 'latitude'};
NewWindData = WindData(:, WindColumnsToInclude);
NewWindData.Properties.VariableNames = {'Capacity_Factor', 'Longitude', 'Latitude'};

% LCOE Constants ($/MWh)
LCOE_Solar = 1;
LCOE_Wind = 1;

% Calculate Cost Effectiveness
sunCostEffectiveness = LCOE_Solar ./ suncapacityfactor;
windCostEffectiveness = LCOE_Wind ./ NewWindData.Capacity_Factor;

% Match Data and Calculate Differences
DifferenceCostEffectiveness = NaN(size(NewSunData, 1), 1);

for i = 1:size(NewSunData, 1)
    distances = sqrt((NewWindData.Latitude - NewSunData.latitude(i)).^2 + ...
                     (NewWindData.Longitude - NewSunData.longitude(i)).^2);
    [~, idx] = min(distances);
    if distances(idx) < 0.01
        DifferenceCostEffectiveness(i) = sunCostEffectiveness(i) - windCostEffectiveness(idx);
    end
end

% Visualization
% Normalize for color mapping:
normalizedDifference = DifferenceCostEffectiveness / max(abs(DifferenceCostEffectiveness));

figure;
h = geoscatter(NewSunData.latitude, NewSunData.longitude, 36, normalizedDifference, 'filled');
title('Cost-Effectiveness Difference ($/Capacity Factor)');
geobasemap grayland;
grid on;

% Custom Blue-Red Diverging Colormap
N = 256; % Number of color levels
red = [ones(1, N/2) linspace(1, 0, N/2)]; % Red decreases
green = [linspace(0, 1, N/2) linspace(1, 0, N/2)]; % Green goes up then down
blue = [linspace(0, 1, N/2) ones(1, N/2)]; % Blue increases
customCMap = [red' green' blue']; % Combine into an Nx3 matrix

colormap(gca, customCMap);
caxis([-1 1]);  % Ensure the color axis is scaled from -1 to 1
colorbar;  % Adds a color bar on the side of the figure
ylabel(colorbar, 'Normalized Difference in Cost-Effectiveness');


