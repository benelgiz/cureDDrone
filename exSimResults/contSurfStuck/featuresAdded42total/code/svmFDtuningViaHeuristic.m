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

%% TUNING THE SVM CLASSIFIER using heuristic approach to select kernel scale

tic
% SVMModelTune is a trained ClassificationSVM classifier 
% By passing 'KernelScale','auto' the software utilizes a heuristic
% approach to select kernel scale
SVMModelTune1 = fitcsvm(feature_vec_training,output_vec_training, 'KernelFunction','rbf', 'KernelScale','auto','Standardize',true,'ClassNames',{'0','1'});

%% CROSS VALIDATION
% 10-fold cross validation on the training data
% inputs : trained SVM classifier (which also stores the training data)
% outputs : cross-validated (partitioned) SVM classifier from a trained SVM
% classifier

% CVSVMModelTune is a ClassificationPartitionedModel cross-validated classifier.
% ClassificationPartitionedModel is a set of classification models trained 
% on cross-validated folds.
CVSVMModelTune1 = crossval(SVMModelTune1,'CVPartition',cFold);

% To assess predictive performance of SVMModelTune on cross-validated data 
% "kfold" methods and properties of CVSVMModelTune, such as kfoldLoss is used

% Evaluate 10-fold cross-validation error.
% (Estimate the out-of-sample misclassification rate.)
crossValClassificErrTuning1 = kfoldLoss(CVSVMModelTune1);

% Predict response for observations not used for training
% Estimate cross-validation predicted labels and scores.
[elabelTune1,escoreTune1] = kfoldPredict(CVSVMModelTune1);

max(escoreTune1)
min(escoreTune1)

%% RETRAIN SVM CLASSIFIER
% Retrain for different values of BoxConstraint and KernelScale
% This KernelScale is the KernelScale found by the heuristic approach
sampleSpace = 11;
kernelScaleFactor = zeros(1,sampleSpace + 1);
boxConstraint = zeros(1,sampleSpace + 1);
crossValClassificErrTuning2 = zeros(sampleSpace,sampleSpace);

ks = SVMModelTune1.KernelParameters.Scale;
boxConstraint(1) = 1e-5;
kernelScaleFactor(1) = 1e-5;
minCrossValClassificError = 100;

for i = 1 : sampleSpace
    for j = 1 : sampleSpace
        
        SVMModelTune2 = fitcsvm(feature_vec_training,output_vec_training, 'KernelFunction','rbf', 'KernelScale',ks * kernelScaleFactor(j),'BoxConstraint',boxConstraint(i),'Standardize',true,'ClassNames',{'0','1'});
        
        % CrossValidate
        CVSVMModelTune2 = crossval(SVMModelTune2,'CVPartition',cFold);
        crossValClassificErrTuning2(i,j) = kfoldLoss(CVSVMModelTune2);
        if crossValClassificErrTuning2(i,j) < minCrossValClassificError
            minCrossValClassificError = crossValClassificErrTuning2(i,j);
            kernelScaleOptim = SVMModelTune2.KernelParameters.Scale;
            boxConstraintOptim = SVMModelTune2.ModelParameters.BoxConstraint;
        end
        kernelScaleFactor(j + 1) = kernelScaleFactor(j) * 10;
    end
    boxConstraint(i + 1) = boxConstraint(i) * 10;
end

toc

%% TRAIN AGAIN WITH THE TUNED KernelScale and BoxConstraint
SVMModelTune = fitcsvm(feature_vec_training,output_vec_training, 'KernelFunction','rbf', 'KernelScale',kernelScaleOptim,'BoxConstraint',boxConstraintOptim,'Standardize',true,'ClassNames',{'0','1'});

%% PREDICTION PHASE

[labelTune,scoreTune] = predict(SVMModelTune,feature_vec_test);

%% EVALUATING THE PERFORMANCE OF CLASSIFICATION WITH NEW DATA

% Evaluating the prediction performance of classification via
% CompactClassificationSVM class methods (e.g compareHoldout, edge, loss, margin, 
% predict)

eTune = edge(SVMModelTune, feature_vec_test, output_vec_test);
mTune = margin(SVMModelTune, feature_vec_test, output_vec_test);

% Evaluating the prediction performance of classification via confusion matrix

[f1scoreTune, precisionTune, recallTune] = calcF1score(output_vec_test, str2double(labelTune));