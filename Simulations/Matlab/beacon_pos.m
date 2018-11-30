%%*****---------------------------------------------------------------*****
%{

    - This script simulates the trajectory of the beacon around the antennas
    - Trajectory radius, distance between antennas and number of simulated
    positions are programmable parameters

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
close all
clear all
clc

%% Ask for parameters
r = input('Choose radius, in meters: ');
d = input('Choose distance between antennas, in meters: ');
alpha_step = input('Choose beacon angle step size, in degrees: ');

%% Generate position arrays
alpha_samps = 360/alpha_step;
alpha = linspace(0, 2*pi, uint16(alpha_samps+1));   % Generate beacon positionElektronik og IT (EIT) 2016s
x_s = r.*cos(alpha);    % Compute beacon's coordinates
y_s = r.*sin(alpha);    
x_A = -d/2; % Antenna A's coordinates
y_A = 0;    
x_B = d/2;  % Antenna B's coordinates
y_B = 0;

%% Plot
figure
plot(x_A, y_A, 'xg', x_B, y_B, 'xg'); % Antennas
hold on
grid on
axis([-1.25*r 1.25*r -1.25*r 1.25*r])
xlabel('X-position [m]');
ylabel('Y-position [m]');
for k = 1:1:length(x_s)
    plot(x_s(1:k), y_s(1:k), 'or'); % Instantaneous position of beacon
    vec_s = plot([0 x_s(k)], [0 y_s(k)], '--r');    % Center-beacon line
    vec_A = plot([x_A x_s(k)], [y_A y_s(k)], '--g');    % Antenna A-beacon line
    vec_B = plot([x_B x_s(k)], [y_B y_s(k)], '--g');    % Antenna B-beacon line
    pause(500e-3);  % Wait before plotting next position
    delete(vec_s);  % Clean lines
    delete(vec_A);
    delete(vec_B);
end
legend('Antenna A', 'Antenna B', 'Beacon');
hold off
