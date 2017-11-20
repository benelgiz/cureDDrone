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
fault_id(fault_start_stop(1,23):fault_start_stop(2,23)) = 1;

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
nominal_id(nominal_start_stop(1,4):nominal_start_stop(2,4)) = 1;

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
feature_vector = [accel_nominal_cond gyro_nominal_cond; accel_fault_cond gyro_fault_cond];
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

% Number of next (and previous) measurements to add to the feature vector : N
feature_vector_original = feature_vector;
clear feature_vector;
N = 3;
[row,col] = size(feature_vector_original);

addedFeat = zeros(row, 2 * N + 1);
% feature_vector = zeros()

for i = 1 : col
    addedFeat = addFeaturesConseq(feature_vector_original(:,i),N);
    feature_vector(:,((i-1)*(2*N+1)+1):((i-1)*(2*N+1)+1+2*N)) = addedFeat;
%     if i == 1
%         feature_vector = addedFeat;
%     else
%         feature_vector = [feature_vector addedFeat];
%     end
end


% Figures to visualize data
feature = [accel_nominal_cond;accel_fault_cond];
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
