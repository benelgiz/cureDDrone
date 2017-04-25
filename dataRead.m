% Written by Ewoud Smeur 
% Modified by Elgiz Baskaya



%%%%%%% This part from Ewoud %%%%%%%%%
filename = 'flightData2.data';


formatSpec = '%f%f%s%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';

formatSpecHeader = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
delimiter = ' ,';
startRow = 1;
fileID = fopen(filename,'r');
header = textscan(fileID, formatSpecHeader,1, 'Delimiter', delimiter, 'EmptyValue' ,NaN);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow, 'ReturnOnError', false);
fclose(fileID);
 
N = length(dataArray{1, 1})-1;

%%%%%%% This part from Elgiz %%%%%%%%%

% Selecting the drone with whose data you want to work with
index_drone_select = find(dataArray{1,2}==25);
drone_select_id = zeros(length(dataArray{1,1}),1);

% Set indexes to 1s if it is the drone of interest
drone_select_id(index_drone_select) = 1;

% Finding flight interval
index_altitude = find(dataArray{1,8}>190000);
altitude_limit_id = zeros(length(dataArray{1,8}),1);

% Sets indexes to 1s if the altitude is greater than the given limit
altitude_limit_id(index_altitude) = 1;

% dataArray{1,8} can be something else then GPS data so select the GPS 
% indexed as well
gps_id = strcmp(dataArray{1,3},'GPS');

% find out the first time of pass of the altitude limit of drone of interest
% and last time of pass of the altitude limit of the drone of interest
% And indexes i. if it is GPS data
%            ii. if it is greater than the altitude of interest
%           iii. if it is drone of interest

index_drone_gps_alt = altitude_limit_id & gps_id & drone_select_id;
first_altPass = find(index_drone_gps_alt, 1, 'first');
last_altPass = find(index_drone_gps_alt, 1, 'last');

% All the times in between the first passing of altitude limit and last
% passing of the altitude limit are assumed to be the flight duration
flight_duration_id = zeros(length(dataArray{1,1}),1);
flight_duration_id(first_altPass:last_altPass) = 1;

%%%%%%%%% Ewoud again ! %%%%%%%%%%%%%
array_col_5 = zeros(length(dataArray{1, 5}),1);
for i = 1:length(dataArray{1, 5})
    try
        array_col_5(i) = str2num(dataArray{1,5}{i});
    end
end

%%%%%%%% Here we welcome Elgiz %%%%%%%
% The idea is to AND all the required indexes

gyro_id_only = strcmp(dataArray{1,3},'IMU_GYRO');
gyro_id = gyro_id_only & drone_select_id & flight_duration_id;
gyro(:,1) = dataArray{1, 4}(gyro_id);
gyro(:,2) = array_col_5(gyro_id);
gyro(:,3) = dataArray{1, 6}(gyro_id);
t_gyro = dataArray{1, 1}(gyro_id);

commands_id_only = strcmp(dataArray{1,3},'COMMANDS');
commands_id = drone_select_id & commands_id_only & flight_duration_id;
commands_index = find(commands_id == 1);
commands(:,1) = dataArray{1, 7}(commands_id);
commands(:,2) = dataArray{1, 8}(commands_id);
t_commands = dataArray{1, 1}(commands_id);

gps_id = drone_select_id & gps_id & flight_duration_id;
altitude(:,1) = dataArray{1, 8}(gps_id)/1000;
t_altitude = dataArray{1, 1}(gps_id);

%% Labeling data (Fault or Normal)

%% FAULT 1

%% Labeling faulty COMMANDS

% Sets indexes to 1s if the altitude is greater than the given limit
negative1_id = dataArray{1,7} < 0;

% And with commands id to find negative values corresponding to COMMANDS 
faultyCommand1_id = negative1_id & commands_id_only & flight_duration_id &drone_select_id;
fault1_index = find(faultyCommand1_id==1);

%% Labeling the data inbetween COMMANDS (label accelerometer/ gyro/ other data)

% Insert 1s if fault1_indexes appear in commands_index vector. 
% Length of isFault1Command_id is the same as commands_index
isFault1Command_id = ismember(commands_index,fault1_index);

% find indexes of the vector where it passes from 0 to 1 or 1 to zero,
% corresponding to passing from normal phase to faulty phase or faulty 
% phase to normal phase respectively.
faulty1_id = diff(isFault1Command_id)~=0;

% Finding the indexes of passes
changingIndexes1 = find(faulty1_id==1);

% Reshaping the indexes of faults such that first row corresponds to 1st 
% entry and leaving indexes to fault, second row corresponds to 2nd enry
% and leaving indexes to fault
groupedChangingIndexes1 = reshape(changingIndexes1,2,[]);

% n gives how many times you experienced that fault.
[m,n] = size(groupedChangingIndexes1);

% Adding 1s serves for different reasons for each row
% Adding 1s to first row compansates for the index being one less then the
% real index for the fault entry index(due to diff command above)
% Adding 1s to second row helps to find the first index of the not faulty
% command just after the faulty phase. This is due to the fact that all the
% measurements after the last faulty command to the next normal command
% will be labeled as faulty (accelerometer, gyro and other measurements
% between the last faulty COMMANDS and first not faulty COMMANDS just after 
% faulty phase )
groupedChangingIndexes1 = ones(m,n) + groupedChangingIndexes1;

isFault1 = zeros(length(dataArray{1,1}),1);

% commands_index holds the indexes of the whole data as its values
% what we have done is to find out the indexes of commands_index that 
% corresponds to faulty and normal COMMANDS changes and read the
% corresponding value to see which index it corresponds in the whole data
% set
for i = 1:n
    isFault1(commands_index(groupedChangingIndexes1(1,i)) : commands_index(groupedChangingIndexes1(2,i)) - 1) = 1;
end

%% FAULT 2

%% Labeling faulty COMMANDS

% Sets indexes to 1s if the altitude is greater than the given limit
negative2_id = dataArray{1,8} < 0;

% And with commands id to find negative values corresponding to COMMANDS 
faultyCommand2_id = negative2_id & commands_id_only & flight_duration_id &drone_select_id;
fault2_index = find(faultyCommand2_id==1);

%% Labeling the data inbetween COMMANDS (label accelerometer/ gyro/ other data)

% Insert 1s if fault2_indexes appear in commands_index vector. 
% Length of isFault2Command_id is the same as commands_index
isFault2Command_id = ismember(commands_index,fault2_index);

% find indexes of the vector where it passes from 0 to 1 or 1 to zero,
% corresponding to passing from normal phase to faulty phase or faulty 
% phase to normal phase respectively.
faulty2_id = diff(isFault2Command_id)~=0;

% Finding the indexes of passes
changingIndexes2 = find(faulty2_id==1);

% Reshaping the indexes of faults such that first row corresponds to 1st 
% entry and leaving indexes to fault, second row corresponds to 2nd enry
% and leaving indexes to fault
groupedChangingIndexes2 = reshape(changingIndexes2,2,[]);

% n gives how many times you experienced that fault.
[m,n] = size(groupedChangingIndexes2);

% Adding 1s serves for different reasons for each row
% Adding 1s to first row compansates for the index being one less then the
% real index for the fault entry index(due to diff command above)
% Adding 1s to second row helps to find the first index of the not faulty
% command just after the faulty phase. This is due to the fact that all the
% measurements after the last faulty command to the next normal command
% will be labeled as faulty (accelerometer, gyro and other measurements
% between the last faulty COMMANDS and first not faulty COMMANDS just after 
% faulty phase )
groupedChangingIndexes2 = ones(m,n) + groupedChangingIndexes2;

isFault2 = zeros(length(dataArray{1,1}),1);

% commands_index holds the indexes of the whole data as its values
% what we have done is to find out the indexes of commands_index that 
% corresponds to faulty and normal COMMANDS changes and read the
% corresponding value to see which index it corresponds in the whole data
% set
for i = 1:n
    isFault2(commands_index(groupedChangingIndexes2(1,i)) : commands_index(groupedChangingIndexes2(2,i)) - 1) = 1;
end

%%%%%%%%%  Hello Ewoud %%%%%%%%%%
% act_id = strcmp(dataArray{1,3},'ROTORCRAFT_CMD');
% u_in(:,1) = dataArray{1, 4}(act_id);
% u_in(:,2) = array_col_5(act_id);
% u_in(:,3) = dataArray{1, 6}(act_id);
% u_in(:,4) = dataArray{1, 7}(act_id);
% t_act = dataArray{1, 1}(act_id);
% 
% gps_id = strcmp(dataArray{1,3},'GPS_INT');
% ecefv(:,1) = dataArray{1, 11}(gps_id)/100;
% ecefv(:,2) = dataArray{1, 12}(gps_id)/100;
% ecefv(:,3) = dataArray{1, 13}(gps_id)/100;
% t_gps = dataArray{1, 1}(gps_id);