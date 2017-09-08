% Selection of fault
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
nominal_label = cell(length(gyro_nominal_cond),1);
nominal_label(:) = {'nominal'};
fault_label = cell(length(gyro_fault_cond),1);
fault_label(:) = {'fault'};
label = [nominal_label; fault_label];
outputVector = label;

% Figures to visualize data
feature = [accel_nominal_cond;accel_fault_cond];
gscatter(feature(:,1),feature(:,3),label)
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
print -depsc2 feat1vsfeat2.eps
