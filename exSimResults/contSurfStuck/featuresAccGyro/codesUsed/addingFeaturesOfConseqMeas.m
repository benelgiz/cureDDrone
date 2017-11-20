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

%% FEATURE ADDITION
% Add features (measurements) of up to N - 1 measurements before and after
% An example : Lets say N = 3
% Before adding the features the feature vector 
% v = [v1 
%      v2
%      v3 
%      v4
%      v5
%      v6
%       .
%       .
%      v_m]     where m is the number of measurements

% For a given feature matrix above this file outputs 
% v_(N-2) ... v_(-1) 


function [vNew] = addFeaturesConseq(v,N) 

v_a = v;
v_b = v;
vNew(:,N) = v;

for i = 1 : N - 1
    v_a(1:end-1,:) = v_a(2:end,:);
    vNew(:,i + N) = v_a;
    v_b(2:end,:) = v_b(1:end-1,:);
    vNew(:,N - i) = v_b;
end