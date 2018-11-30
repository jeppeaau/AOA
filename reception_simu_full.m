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
beta = input('Choose platform rotation, in degrees: ');
beta = linspace(deg2rad(-beta), deg2rad(beta), 2+1);

%% Generate beacon samples
c = 3e8;    % Speed of light (m/s)
alpha_samps = 360/alpha_step;
alpha = linspace(0, 2*pi, uint16(alpha_samps+1));   % Generate beacon positions
f = 2.4e9;  % Transmitting frequency (Hz)
t = linspace(0, 2*1/f, 2*280+1);    % Generate time samples
t_A = zeros(length(alpha), length(beta), length(t));    % Antenna A time tensor
t_B = zeros(length(alpha), length(beta), length(t));    % Antenna B time tensor
for a = 1:1:length(t)   % Store time samples as 3rd dimension of time tensors
    t_A(1:length(alpha), 1:length(beta), a) = t(a);
    t_B(1:length(alpha), 1:length(beta), a) = t(a);
end
s = sin(2*pi*f.*t); %Generate beacon's signal

x_s = zeros(length(alpha), length(beta));   % Preallocate space
y_s = zeros(length(alpha), length(beta));
x_A = zeros(length(beta));
y_A = zeros(length(beta));
x_B = zeros(length(beta));
y_B = zeros(length(beta));
aoa_A = zeros(length(alpha), length(beta));
aoa_B = zeros(length(alpha), length(beta));
dof_A = zeros(length(alpha), length(beta));
dof_B = zeros(length(alpha), length(beta));
tof_A = zeros(length(alpha), length(beta));
tof_B = zeros(length(alpha), length(beta));

%% Compute angles of arrival to antennas
for j = 1:1:length(alpha)   % For every beacon position
    for k = 1:1:length(beta)    % For every platform orientation
    x_s(j,k) = r.*(1+cos(alpha(j)));    % Beacon's coordinates (4-quadrant)
    y_s(j,k) = r.*(1+abs(sin(alpha(j))));
    x_A(k) = r-(d/2)*cos(beta(k));  % Antenna A's coordinates (4-quadrant)
    y_A(k) = r-(d/2)*sin(beta(k));
    x_B(k) = r+(d/2)*cos(beta(k));  % Antenna B's coordinates (4-quadrant)
    y_B(k) = r+(d/2)*sin(beta(k));
    aoa_A(j,k) = atan2(abs(y_s(j)-y_A(k)), abs(x_s(j)-x_A(k)));   % Angles of arrival to both antennas (4-quadrant)
    aoa_B(j,k) = atan2(abs(y_s(j)-y_B(k)), abs(x_s(j)-x_B(k)));
    
    %% Compute distances from beacon to antennas
    dof_A(j,k) = (abs(x_s(j)-x_A(k)))./cos(aoa_A(j,k)); % Distance of flight to antennas (4-quadrant)
    dof_B(j,k) = (abs(x_s(j)-x_B(k)))./cos(aoa_B(j,k));
    
    %% Compute time of flight
    tof_A(j,k) = dof_A(j,k)./c;
    tof_B(j,k) = dof_B(j,k)./c;
    end
end

%% Add times of flight to time tensors (every alpha/beta configuration)
for b = 1:1:length(t)   
   t_A(:,:,b) = t_A(:,:,b) + tof_A;
   t_B(:,:,b) = t_B(:,:,b) + tof_B;
end

%% Compute phase of each antenna
phs_A = 2*pi*f.*t_A;  
phs_B = 2*pi*f.*t_B;  

%% Regenerate received signals (beacon + delay)
s_A = sin(phs_A); 
s_B = sin(phs_B);

%% Plot signals for every beacon position (constant alpha)
for m = 1:1:length(alpha)
    figure
    plot(t, squeeze(s_A(m,1,:)), 'g', t, squeeze(s_B(m,1,:)), 'r', t, s, 'b'); % Signals on A, B and beacon
    grid on
    title(['Equivalent signal on antennas A and B (\alpha=', num2str(rad2deg(alpha(m))), 'º)']);
    xlabel('Time [s]');
    ylabel('Amplitude');
    legend('Antenna A', 'Antenna B', 'Beacon');
    pause(50e-3);
end

%% Plot signals for a platform orientation (constant beta)
for n = 1:1:length(beta)
    figure
    plot(t, squeeze(s_A(1,n,:)), 'g', t, squeeze(s_B(1,n,:)), 'r', t, s, 'b'); % Signals on A, B and beacon
    grid on
    title(['Equivalent signal on antennas A and B (\beta=', num2str(rad2deg(beta(n))), 'º)']);
    xlabel('Time [s]');
    ylabel('Amplitude');
    legend('Antenna A', 'Antenna B', 'Beacon');
    pause(50e-3);
end
