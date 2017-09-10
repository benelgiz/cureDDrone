% Copyright 2016 Elgiz Baskaya

% This file is part of curedRone.

% curedRone is free software: you can redistribute it and/or modify
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

% Select the number of classes
classNum = 2;

%% Arrange data
% training set (around %70 percent of whole data set)

feature_vec = [sensor_sim_out_normal'; sensor_sim_out_fault'];

% normal = repmat('normal', length(sensor_sim_out_normal'), 1);
% normal = cellstr(normal);
% fault = repmat('fault', length(sensor_sim_out_fault'), 1);
% fault = cellstr(fault);
% output_vec = vertcat(normal, fault);

normal(1:length(sensor_sim_out_normal'), 1) = 1;
fault(1:length(sensor_sim_out_fault'), 1) = 2;
output_vec = [normal;fault];

trainingDataExNum = ceil(70 / 100 * (length(feature_vec)));

% Select %70 of data for training and leave the rest for testing
randomSelectionColoumnNum = randperm(length(feature_vec),trainingDataExNum);

% Training set for feature and output
feature_vec_training = feature_vec(randomSelectionColoumnNum, :);
output_vec_training = output_vec(randomSelectionColoumnNum, :);

% Test set for feature and output

feature_vec_test = feature_vec;
feature_vec_test(randomSelectionColoumnNum, :) = [];

output_vec_test = output_vec;
output_vec_test(randomSelectionColoumnNum, :) = [];

%% SVM Call
tic
SVMModel = fitcsvm(feature_vec_training,output_vec_training);
toc
% 
sv = SVMModel.SupportVectors;

%% Plot results
figure
gscatter(feature_vec_training(:,1),feature_vec_training(:,2),output_vec_training)
hold on
% plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
% legend('normal','fault','Support Vector')
legend('normal','fault')
hold off
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
% 
e = edge(SVMModel, feature_vec_test, output_vec_test);
m = margin(SVMModel, feature_vec_test, output_vec_test);
[label,score] = predict(SVMModel,feature_vec_test);

