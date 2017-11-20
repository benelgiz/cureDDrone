function [f1Score,precision,recall] = calcF1score(labelActual, labelPredicted)

truePositive = sum(labelPredicted & labelActual);
falsePositive = sum(~((~labelPredicted)|labelActual));
falseNegative = sum((~labelPredicted) & labelActual);
% trueNegative = sum(~(labelPredicted|labelActual));

precision = truePositive / (truePositive + falsePositive);
recall = truePositive / (truePositive + falseNegative);
f1Score = 2 * precision * recall / (precision + recall);
end