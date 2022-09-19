% Mean and STD of solar irradiance from ilmatieteenlaitos
% https://en.ilmatieteenlaitos.fi/download-observations
% The data is from Jyväskylän lentoasema

Irradiance = cell2mat(struct2cell(load('Mean_STD_Solar.mat'))); % Irradiance per w/m2
%Irradiance2 = cell2mat(struct2cell(load('Mean_STD_Solar.mat'))); % Irradiance per w/m2

PV1 = zeros(8760,2);
PV2 = zeros(8760,2);

PV1(:,1) = -Irradiance(:,1)*(1.65*6*0.2*0.001); % Mean: Irradiance*surface of each panel*num of panels*efficiency
PV1(:,2) = Irradiance(:,2)*(1.65*6*0.2*0.001); % STD

PV2(:,1) = -1*Irradiance(:,1)*(1.65*12*0.2*0.001); %Mean
PV2(:,2) = 1*Irradiance(:,2)*(1.65*12*0.2*0.001);   % STD

clear Irradiance1 Irradiance2