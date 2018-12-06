%%*****---------------------------------------------------------------*****
%{

    - This script computes the signals seen by both antennas for a given set
    of values of beacon positions, by means of the angle of arrival and
    the time of flight.
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

%% Generate beacon samples
c = 3e8;    % Speed of light (m/s)
alpha_samps = 360/alpha_step;
alpha = linspace(0, 2*pi, uint16(alpha_samps+1));   % Generate beacon positions
f = 2.4e9;  % Transmitting frequency (Hz)
t = linspace(0, 2*1/f, 2*280++1);    % Generate time samples
s = sin(2*pi*f.*t); % Generate beacon's signal

%% Beacon distance and antenna positioning
x_A = r-d/2;    % Antennas' position
x_B = r+d/2;

%% Compute angles of arrival to antennas
x_s = r.*(1+cos(alpha));    % Beacon's coordinates (4-quadrant)
y_s = r.*abs(sin(alpha-pi));
aoa_A = atan2(y_s, abs(x_s-x_A));   % Angles of arrival to both antennas (4-quadrant)
aoa_B = atan2(y_s, abs(x_s-x_B));

%% Compute distances from beacon to antennas
dof_A = (abs(x_s-x_A))./cos(aoa_A); % Distance of flight to antennas (4-quadrant)
dof_B = (abs(x_s-x_B))./cos(aoa_B);

%% Compute time of flight
tof_A = dof_A./c;
tof_B = dof_B./c;

%% Compute phase of each antenna
phs_A=zeros(length(tof_A), length(t));  % Preallocate space
phs_B=zeros(length(tof_B), length(t));
for i=1:1:length(tof_A)   
    phs_A(i,:) = 2*pi*f.*(t+tof_A(i));  % Phases of the equivalent signals at A and B
    phs_B(i,:) = 2*pi*f.*(t+tof_B(i));  
end

%% Regenerate received signals
s_A=zeros(length(phs_A(:,1)), length(t));   % Preallocate space
s_B=zeros(length(phs_B(:,1)), length(t));
for k=1:1:length(phs_A(:,1))
    s_A(k,:) = sin(phs_A(k,:)); % Equivalent signals at A and B
    s_B(k,:) = sin(phs_B(k,:));
end

%{
%% Plot results
figure
subplot(2,1,1)
plot(rad2deg(alpha), rad2deg(aoa_A), 'g');    % AoA as a function of beacon's position
grid on
title('Angle of arrival of antenna A');
xlabel('Beacon position [deg]');
ylabel('Angle [deg]');
subplot(2,1,2)
plot(rad2deg(alpha), rad2deg(aoa_B), 'r');
grid on
title('Angle of arrival of antenna B');
xlabel('Beacon position [deg]');
ylabel('Angle [deg]');
%}

for m=1:1:length(s_A(:,1))
    figure
    plot(t, s_A(m,:), 'g', t, s_B(m,:), 'r', t, s, 'b'); % Signals on beacon, A and B
    grid on
    title(['Equivalent signal on antennas A and B (\alpha=', num2str(rad2deg(alpha(m))), 'º)']);
    xlabel('Time [s]');
    ylabel('Amplitude');
    legend('Antenna A', 'Antenna B', 'Beacon');
    pause(50e-3);
end
