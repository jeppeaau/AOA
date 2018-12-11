clc; clear; close all;
% ***************************************************
%
% This scripts designs P controllers for the
% transfer functions G of a motor, so that it has 
% a certain speed bandwidth f_bw and a certain
% position bandwidth f_bw1. The relation bewteen
% bandwidths is given by f_bw1/f_bw=n_bw.
% The sampling frequency has to be 20~40 times bigger
% than the speed bandwidth.
%
% ***************************************************
%% Definition of the transfer function
% Electric parameters
R = 7.13;  % Ohms
L = 1.05e-3;  % H

% Electromechanical parameters
Ke = 1/26.18;    % (V*s)/rad
Kt = 38.2e-3;    % Nm/A

% Mechanical parameters
J = (41.9e-7);    % kg*m^2
% J = (41.9e-7)+1.23e-4;    % kg*m^2
b = 4.6e-6;

% Obtention of the transfer function
G = tf(Kt, [L*J, L*b+R*J, R*b+Kt*Kt]);

%% Find the proportional gain according to the desired bandwidth
% Desired bandwidth
f_bw=60;
n_bw=20;
w_bw=2*pi*f_bw;

% Compute proportional gain to make w_bw = w_c
k=1/abs(evalfr(G,j*w_bw));

% Plot open loop Bode diagrams
figure();
bode(G);
grid on;
hold on;

L1=k*G;
D1=tf(k,1);
bode(L1);
legend('P controller, no gain','P controller, gain k');

%% Closed loop function
H=tf(1,1);
T=minreal((D1*G)/(1+D1*G*H));

% Step response of the speed loop
figure();
step(T);
grid on;
title('Step response of the speed loop');

%% Design outer control loop
% Define the new plant, inner control loop with integrator
G1=T*tf(1,[1 0]);
figure();
bode(G1);
grid on;
hold on;

% Outer control loop 10 times slower than inner loop
w_bw1=w_bw/n_bw;

% Proportional controller
kp=1/abs(evalfr(G1,j*w_bw1));

L2=kp*G1;
bode(L2);

T1=minreal((L2)/(1+L2));
figure();
step(T1);
grid on;
title('Step response of the position loop');

%% Computation of the velocity error
Kv=evalfr(minreal(L2*tf([1 0],1)),0);
ev=1/Kv;

t=linspace(0,0.5,1e5);
output=lsim(T1,t,t);

figure();
plot(t,t);
hold on;
plot(t,output);
grid on;
title('Ramp response of position loop');

%% The designed controllers are:
D_vel=tf(D1);
D_pos=tf(kp,1);

%% Digitalization of the controllers
f_s=30*f_bw;
T_s=1/f_s;

D_pos_d=c2d(D_pos,T_s,'zoh');
D_pos_d.Variable='z^-1'
D_vel_d=c2d(D_vel,T_s,'zoh');
D_vel_d.Variable='z^-1'


