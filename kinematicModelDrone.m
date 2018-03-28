% Copyright 2018 Elgiz Baskaya

% This file is part of curedRone.

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

% Attitude kinematic and dynamic equations of motion
% Translational Motion of a drone

% inputs : state_prev  .:. states from the previous time t - 1. 
%                          state_prev = [q0 q1 q2 q3 p q r]'
%                          where;
%                               q = q0 + q1 * i + q2 * j + q3 * k
%                               w .:. describes the angular motion of the body 
%                                     frame b with respect to navigation frame 
%                                     North East Down(NED), expressed in body frame
%                               w = [p q r]' 
% outputs : q_dot  .:. time derivative of quaternions

function q_dot = kinematicModelDrone(q_prev,ang_vel)

quat_normalize_gain = 1;

% q .:. quaternion
% q = q0 + q1 * i + q2 * j + q3 * k;  
q0 = q_prev(1);
q1 = q_prev(2);
q2 = q_prev(3);
q3 = q_prev(4);

% w .:. angular velocity vector with components p, q, r
% w = [p q r]' 
% w describes the angular motion of the body frame b with respect to
% navigation frame NED, expressed in body frame.
p = ang_vel(1);
q = ang_vel(2);
r = ang_vel(3);

% Attitude kinematics of drone
q_dot = 1 / 2 * [-q1 -q2 -q3; q0 -q3 q2; q3 q0 -q1; -q2 q1 q0] * [p q r]' ...
    + quat_normalize_gain * (1 - (q0^2 + q1^2 + q2^2 + q3^2)) * [q0 q1 q2 q3]';