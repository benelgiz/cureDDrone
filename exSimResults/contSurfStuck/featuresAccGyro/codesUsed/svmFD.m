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

%% TRAINING PHASE
tic
% SVMModel is a trained ClassificationSVM classifier.
SVMModel = fitcsvm(feature_vec_training,output_vec_training, 'KernelFunction','rbf','Standardize',true,'ClassNames',{'0','1'});
toc

% Support vectors
sv = SVMModel.SupportVectors;

%% CROSS VALIDATION
% 10-fold cross validation on the training data
% inputs : trained SVM classifier (which also stores the training data)
% outputs : cross-validated (partitioned) SVM classifier from a trained SVM
% classifier

% CVSVMModel is a ClassificationPartitionedModel cross-validated classifier.
% ClassificationPartitionedModel is a set of classification models trained 
% on cross-validated folds.

CVSVMModel = crossval(SVMModel,'CVPartition',cFold);

% To assess predictive performance of SVMModel on cross-validated data 
% "kfold" methods and properties of CVSVMModel, such as kfoldLoss is used

% Evaluate 10-fold cross-validation error.
% (Estimate the out-of-sample misclassification rate.)
crossValClassificErr = kfoldLoss(CVSVMModel);

% Predict response for observations not used for training
% Estimate cross-validation predicted labels and scores.
[elabelUntuned,escoreUntuned] = kfoldPredict(CVSVMModel);

max(escoreUntuned)
min(escoreUntuned)

% FIT POSTERIOR PROBABILITES fitPosterior(SVMModel) / fitSVMPosterior(CVSVMModel)
% [ScoreCVSVMModel,ScoreParameters] = fitSVMPosterior(CVSVMModel);
% Predict does not work here?


%% PREDICTION PHASE

[labelUntuned,scoreUntuned] = predict(SVMModel,feature_vec_test);

% %% FIT POSTERIOR PROBABILITES fitPosterior(SVMModel) / fitSVMPosterior(CVSVMModel)
% % "The transformation function computes the posterior probability 
% % that an observation is classified into the positive class (SVMModel.Classnames(2)).
% % The software fits the appropriate score-to-posterior-probability 
% % transformation function using the SVM classifier SVMModel, and 
% % by conducting 10-fold cross validation using the stored predictor data (SVMModel.X) 
% % and the class labels (SVMModel.Y) as outlined in REF : Platt, J. 
% % "Probabilistic outputs for support vector machines and comparisons 
% % to regularized likelihood methods". In: Advances in Large Margin Classifiers. 
% % Cambridge, MA: The MIT Press, 2000, pp. 61-74"
% ScoreSVMModel = fitPosterior(SVMModel);
% [~,postProbability] = predict(ScoreSVMModel,feature_vec_test);

%% EVALUATING THE PERFORMANCE OF CLASSIFICATION WITH NEW DATA

% Evaluating the prediction performance of classification via
% CompactClassificationSVM class methods (e.g compareHoldout, edge, loss, margin, 
% predict)

eUntuned = edge(SVMModel, feature_vec_test, output_vec_test);
mUntuned = margin(SVMModel, feature_vec_test, output_vec_test);

% Evaluating the prediction performance of classification via confusion matrix

[f1scoreUntuned, precisionUntuned, recallUntuned] = calcF1score(output_vec_test, str2double(labelUntuned));
%% Plot results
figure
gscatter(feature_vec_training(:,1),feature_vec_training(:,2),output_vec_training)
hold on
plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
legend('normal','fault','Support Vector')
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




