%%*****---------------------------------------------------------------*****
%{

    - This script computes the value of the gain for a 2-element array when
    beamforming is applied.

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
close all
clear all
clc

%% Ask for parameters
alpha = input("Introduce beacon position, in degrees: ");
r = input('Choose radius, in meters: ');

%% Design antenna array
f = 2.421e9;
c = physconst('LightSpeed');
lambda = c/f;

% Calculate the wave number 
k0 = 2*pi/lambda;

% Calculate the Width of patch antenna
epsylonr = 4.7;
W = (lambda/2)*sqrt(2/(epsylonr + 1));

% Epsilon Reff for W > h
h = 0.0015;
EpsylonReff = (epsylonr+1)/2 + (epsylonr-1)/2 * 1/(sqrt(1+12*h/W));

% Extra length due to fringing DeltaL
DeltaL = h*0.412*((EpsylonReff+0.3)*(W/h+0.264))/((EpsylonReff-0.258)*(W/h+0.8));

% Physical length of Patch 
PL = c/(2*f*sqrt(EpsylonReff))-2*DeltaL;

% Impedence computation 
Z = @(b) k0.*PL.*sin(b);
X = @(b) ((sin(((k0*W)/2)*cos(b)))./cos(b)).^2.*besselj(0, Z(b)).*sin(b).^3;
G12 =1/(120*pi^2) * integral(X, 0, pi);

% Single patch directivity
I_1 = -2 + cos(k0*W) + k0*W*sinint(k0*W) + sin(k0*W)/(k0*W);
G1 = I_1/(120*pi^2);
Rin = 50;
R0 = 1/(2*(G1+G12));
FeedDistance = acos(sqrt(Rin/R0))*PL/pi;

% Single patch simulation
PatchAntenna = design(patchMicrostrip, f);
PatchDielectric = dielectric('FR4');
PatchDielectric.Thickness = h;
PatchDielectric.EpsilonR = epsylonr;
PatchAntenna.Substrate = PatchDielectric;
PatchAntenna.Height = h;
PatchAntenna.Length = W;
PatchAntenna.Width = PL;
PatchAntenna.FeedOffset = [0 PL/2-FeedDistance];

% Microstrip array
PatchSpacing = lambda/2;
PatchArray = linearArray('Element', PatchAntenna, 'ElementSpacing', PatchSpacing);

%% Compute phase shift
t = linspace(0, 2*1/f, 2*280+1);

% Beacon distance and antenna positioning
x_A = r - PatchSpacing/2;    % Antennas' position
x_B = r + PatchSpacing/2;

% Compute angles of arrival to antennas
x_s = r .* (1 + cos(alpha));    % Beacon's coordinates (4-quadrant)
y_s = r .* abs(sin(alpha - pi));
aoa_A = atan2(y_s, abs(x_s - x_A));   % Angles of arrival to both antennas (4-quadrant)
aoa_B = atan2(y_s, abs(x_s - x_B));

% Compute distances from beacon to antennas
dof_A = (abs(x_s - x_A))./cos(aoa_A); % Distance of flight to antennas (4-quadrant)
dof_B = (abs(x_s - x_B))./cos(aoa_B);

% Compute time of flight
tof_A = dof_A./c;
tof_B = dof_B./c;

% Compute phase of each antenna
phs_A=zeros(length(tof_A), length(t));  % Preallocate space
phs_B=zeros(length(tof_B), length(t));
for i=1:1:length(tof_A)   
    phs_A(i,:) = 2*pi*f.*(t + tof_A(i));  % Phases of the equivalent signals at A and B
    phs_B(i,:) = 2*pi*f.*(t + tof_B(i));  
end

% Phase shift
phsShift = phs_B - phs_A; % Right antenna as phase reference
linearArray.PhaseShift = [phsShift 0];
az_angle = 1:1:180;
el_angle = -180:1:180;
figure
pattern(linearArray, f, 0, el_angle, 'CoordinateSystem', 'rectangular');
