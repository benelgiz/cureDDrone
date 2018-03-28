% Copyright 2017 Elgiz Baskaya

% This file is part of cureDDrone.

% cureDDrone is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% curedRone is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with curedRone.  If not, see <http://www.gnu.org/licenses/>.

% FAULT DETECTION VIA SVM
% This code assumes that you already have a data set of normal and faulty 
% situation sensor outputs.

%% FAULT SELECTION
% to check available fault indexes (the index when they are set by
% operator) setdiff(settings_index,set_nominal)
% and their corresponding start_index end_index, check fault_start_stop

fault_id = zeros(length(dataArray{1,1}),1);
% Select which fault interval you would like to investigate
% fault_id(fault_start_stop(1,FAULT_NUM_YOU_WANTTO_SIMULATE):fault_start_stop(2,FAULT_NUM_YOU_WANTTO_SIMULATE)) = 1;

% One surface stuck at zero fault
% fault_id(fault_start_stop(1,23):fault_start_stop(2,23)) = 1;

% One surface loss if efficiency fault
fault_id(fault_start_stop(1,3):fault_start_stop(2,3)) = 1;

% All faulty phase indexes
% for i = 1 : length(fault_start_stop)
%     fault_id(fault_start_stop(1,i):fault_start_stop(2,i)) = 1;
% end

gyro_fault_cond_id = fault_id & gyro_id_only;

gyro_fault_cond(:,1) = dataArray{1, 4}(gyro_fault_cond_id);
gyro_fault_cond(:,2) = array_col_5(gyro_fault_cond_id);
gyro_fault_cond(:,3) = dataArray{1, 6}(gyro_fault_cond_id);
t_gyro_fault_cond = dataArray{1, 1}(gyro_fault_cond_id);

accel_fault_cond_id = fault_id & accel_id_only;

accel_fault_cond(:,1) = dataArray{1, 4}(accel_fault_cond_id);
accel_fault_cond(:,2) = array_col_5(accel_fault_cond_id);
accel_fault_cond(:,3) = dataArray{1, 6}(accel_fault_cond_id);
t_accel_fault_cond = dataArray{1, 1}(accel_fault_cond_id);

% Selection of nominal condition
% to check available fault indexes (the index when they are set by
% operator) : see variable set_nominal
% and their corresponding start_index end_index, check nominal_start_stop

nominal_id = zeros(length(dataArray{1,1}),1);
% Select which nominal phase interval you would like to investigate
% nominal_id(nominal_start_stop(1,NOMINAL_COND_NUM_YOU_WANTTO_SIMULATE):nominal_start_stop(2,NOMINAL_COND_NUM_YOU_WANTTO_SIMULATE)) = 1;

% One surface stuck at zero fault
% nominal_id(nominal_start_stop(1,5):nominal_start_stop(2,5)) = 1;

% One surface loss if efficiency fault
% nominal_id(nominal_start_stop(1,1):nominal_start_stop(2,1)) = 1;
nominal_id(400000:nominal_start_stop(2,1)) = 1;

% All nominal phase indexes
% for i = 1 : length(nominal_start_stop)
%     nominal_id(nominal_start_stop(1,i):nominal_start_stop(2,i)) = 1;
% end

gyro_nominal_cond_id = nominal_id & gyro_id_only;

gyro_nominal_cond(:,1) = dataArray{1, 4}(gyro_nominal_cond_id);
gyro_nominal_cond(:,2) = array_col_5(gyro_nominal_cond_id);
gyro_nominal_cond(:,3) = dataArray{1, 6}(gyro_nominal_cond_id);
t_gyro_nominal_cond = dataArray{1, 1}(gyro_nominal_cond_id);

accel_nominal_cond_id = nominal_id & accel_id_only;

accel_nominal_cond(:,1) = dataArray{1, 4}(accel_nominal_cond_id);
accel_nominal_cond(:,2) = array_col_5(accel_nominal_cond_id);
accel_nominal_cond(:,3) = dataArray{1, 6}(accel_nominal_cond_id);
t_accel_nominal_cond = dataArray{1, 1}(accel_nominal_cond_id);

% Forming the feature and output vectors to apply classification.
% Here we form the matrix as 
% feature_vector = [acc_x_nominal acc_y_nom   acc_z_nom   gyro_x_nom  gyro_y_nom   gyro_z_nom
%                   acc_x_fault   acc_y_fault acc_z_fault gyro_x_faul gyro_y_fault gyro_z_fault]
% feature_vector = [accel_nominal_cond gyro_nominal_cond; accel_fault_cond gyro_fault_cond];

%% Changing the angular velocities to spinnors so that the angular 
%% velocities will be replaced

% feature_vector = [accel_nominal_cond spinnor_nominal_cond; accel_fault_cond spinnor_fault_cond];

dt_integration_nominal = t_gyro_nominal_cond(2:end) - t_gyro_nominal_cond(1:end-1);
dt_integration_fault = t_gyro_fault_cond(2:end) - t_gyro_fault_cond(1:end-1);

% Change of angular velocity attributes to spinnors for the nominal phase 
% of the flight 

% Preallocation for quaternion vector to be calculated by numerical
% integration 
quatern_nominal = zeros(4,length(dt_integration_nominal)+1);

% Initialization for the integration
quatern_nominal(:,1) = [1 0 0 0]';

for i=1:length(dt_integration_nominal)
    
  % Nonlinear attitude propagation
  % Integration via Runge - Kutta integration Algorithm
  quatern_nominal(:,i+1) = rungeKutta4('kinematicModelDrone', quatern_nominal(:,i), gyro_nominal_cond(i,:)', dt_integration_nominal(i)); 
end

% Taking the log of quaternion to calculate the spinnors
% Info = the quaternion that represent an attitude should be a unitary
% quaternion (have unit norm). For that during kinematics eqautions
% normalization is held. When the quaternion is unitary (has unit norm),
% thus represents the attitude, the logarithm of it (hence representing
% spinnor) is an imaginary quaternion, which means that its scalar part is
% equal to zero
spinnor_nominal = quatlog(quatern_nominal');

% First element of the spinnor (scalar part) equals to zero so we do not
% use this first element as an attribute
spinnor_nominal_cond = spinnor_nominal(:,2:end);

% Change of angular velocity attributes to spinnots for the faulty phase of
% the flight 

% Preallocation for quaternion vector to be calculated by numerical
% integration 
quatern_fault = zeros(4,length(dt_integration_fault)+1);

% Initialization for the integration
quatern_fault(:,1) = [1 0 0 0]';

for i=1:length(dt_integration_fault)
    
  % Nonlinear attitude propagation
  % Integration via Runge - Kutta integration Algorithm
  quatern_fault(:,i+1) = rungeKutta4('kinematicModelDrone', quatern_fault(:,i), gyro_fault_cond(i,:)', dt_integration_fault(i)); 
end

spinnor_fault = quatlog(quatern_fault');
% First element of the spinnor (scalar part) equals to zero so we do not
% use this first element as an attribute

spinnor_fault_cond = spinnor_fault(:,2:end);

feature_vector = [accel_nominal_cond spinnor_nominal_cond; accel_fault_cond spinnor_fault_cond];

% Assuming the time steps for the gyro and the accelerometers are sync.
t_features = [t_accel_nominal_cond; t_accel_fault_cond];
% Assuming same number of gyro and accelerometer data
% Labelling data

% nominal_label = cell(length(gyro_nominal_cond),1);
% nominal_label(:) = {'nominal'};
% fault_label = cell(length(gyro_fault_cond),1);
% fault_label(:) = {'fault'};
% label = [nominal_label; fault_label];
% output_vector = label;

nominal_label = zeros(length(gyro_nominal_cond),1);
fault_label = ones(length(gyro_fault_cond),1);
output_vector = [nominal_label; fault_label];

%% ADD FEATURES OF CONSEQUENT MEASUREMENTS

% % Number of next (and previous) measurements to add to the feature vector : N
% feature_vector_original = feature_vector;
% clear feature_vector;
% N = 3;
% [row,col] = size(feature_vector_original);
% 
% addedFeat = zeros(row, N + 1);

% for i = 1 : col
%     % If features added before the current time measurement
%     addedFeat = addFeaturesBefore(feature_vector_original(:,i),N);
%     feature_vector(:,((i-1)*(N+1)+1):((i-1)*(N+1)+1+N)) = addedFeat;
%     
%     % If features added both before and after the current time measurement
%     addedFeat = addFeaturesBeforeAfter(feature_vector_original(:,i),N);
%     feature_vector(:,((i-1)*(2*N+1)+1):((i-1)*(2*N+1)+1+2*N)) = addedFeat;
% end

% Figures to visualize data
% feature = [accel_nominal_cond;accel_fault_cond];
gscatter(feature_vector(:,1),feature_vector(:,3),output_vector,'gr')
legend('normal','fault')
set(legend,'FontSize',11);
xlabel({'$a_x$'},...
'FontUnits','points',...
'interpreter','latex',...
'FontSize',15,...
'FontName','Times')
ylabel({'$a_y$'},...
'FontUnits','points',...
'interpreter','latex',...
'FontSize',15,...
'FontName','Times')
print -depsc2 feat1vsfeat3.eps
