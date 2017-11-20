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

%% TUNING THE SVM CLASSIFIER using Bayesian Optimization
sigma = optimizableVariable('sigma',[1e-5,1e5],'Transform','log');
box = optimizableVariable('box',[1e-5,1e5],'Transform','log');

minfn = @(z)kfoldLoss(fitcsvm(feature_vec_training,output_vec_training,'CVPartition',cFold,...
    'KernelFunction','rbf','BoxConstraint',z.box,...
    'KernelScale',z.sigma));

results = bayesopt(minfn,[sigma,box],'IsObjectiveDeterministic',true,...
    'AcquisitionFunctionName','expected-improvement-plus')

z(1) = results.XAtMinObjective.sigma;
z(2) = results.XAtMinObjective.box;
SVMModelTuned = fitcsvm(feature_vec_training,output_vec_training,'KernelFunction','rbf',...
    'KernelScale',z(1),'BoxConstraint',z(2));

%% CROSS VALIDATION
% 10-fold cross validation on the training data
% inputs : trained SVM classifier (which also stores the training data)
% outputs : cross-validated (partitioned) SVM classifier from a trained SVM
% classifier

% CVSVMModel is a ClassificationPartitionedModel cross-validated classifier.
% ClassificationPartitionedModel is a set of classification models trained 
% on cross-validated folds.

CVSVMModelTuned = crossval(SVMModelTuned,'CVPartition',cFold);

% To assess predictive performance of SVMModel on cross-validated data 
% "kfold" methods and properties of CVSVMModel, such as kfoldLoss is used

% Evaluate 10-fold cross-validation error.
% (Estimate the out-of-sample misclassification rate.)
crossValClassificErrTuned = kfoldLoss(CVSVMModelTuned);

%% PREDICTION PHASE
[labelTuned,scoreTuned] = predict(SVMModelTuned,feature_vec_test);

%% EVALUATING THE PERFORMANCE OF CLASSIFICATION WITH NEW DATA

% Evaluating the prediction performance of classification via
% CompactClassificationSVM class methods (e.g compareHoldout, edge, loss, margin, 
% predict)

eTuned = edge(SVMModelTuned, feature_vec_test, output_vec_test);
mTuned = margin(SVMModelTuned, feature_vec_test, output_vec_test);

% Evaluating the prediction performance of classification via confusion matrix

[f1scoreTuned, precisionTuned, recallTuned] = calcF1score(output_vec_test, labelTuned);