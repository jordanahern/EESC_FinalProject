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
title('THE SUN!!!!!!!!!!!')


%% Wind

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
% Create Energy Output variable
% Create your new variable
WindEnergyOutput = (NewWindData.Capacity_Factor).*(NewWindData.Capacity);
% Add the new variable to the table
NewWindData = addvars(NewWindData, WindEnergyOutput);

% Prepare color data: Use Capacity
colorWindData = NewWindData.WindEnergyOutput;
% Create a figure to hold the map
figure;
% Plot each power plant on the map using geoscatter
f = geoscatter(NewWindData.Latitude, NewWindData.Longitude, NewWindData.WindEnergyOutput, colorWindData, 'filled');
% Enhance the colormap to represent emissions rate intensity
colormap(parula);  % 'parula' uses a spectrum from blue to yellow
colorbar;  % Adds a color bar to indicate the scale of CO2 Rates
% Set map limits to focus on the United States
geolimits([24 50],[-125 -66]);  % These limits roughly frame the continental US
% Add a title
title('Map of US Wind Energy Potential: Color by Energy Potential in Megawatts');
% Improve the map appearance
geobasemap grayland; %
grid on;  % Turn on the grid to help orient the map

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
