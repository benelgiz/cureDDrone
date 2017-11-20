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


%% Arrange training/test sets

feature_vec = feature_vector;
output_vec = output_vector;

% training set (around %80 percent of whole data set)
trainingDataExNum = ceil(80 / 100 * (length(feature_vec)));

% Select %80 of data for training and leave the rest for testing
randomSelectionColoumnNum = randperm(length(feature_vec),trainingDataExNum);

% Training set for feature and output
% feature_vec_training .:. feature matrix for training
% output_vec_training .:. output vector for training
feature_vec_training = feature_vec(randomSelectionColoumnNum, :);
output_vec_training = output_vec(randomSelectionColoumnNum, :);

% Test set for feature and output
feature_vec_test = feature_vec;
feature_vec_test(randomSelectionColoumnNum, :) = [];

output_vec_test = output_vec;
output_vec_test(randomSelectionColoumnNum, :) = [];

test_set_time = t_features;
test_set_time(randomSelectionColoumnNum) = [];
