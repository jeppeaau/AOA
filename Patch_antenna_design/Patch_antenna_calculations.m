%%*****---------------------------------------------------------------*****
%{

    - This script designs a patch antenna and its corresponding 2-element
    array for an operating frequency of 2.421 GHz.

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
close all
clear all
clc

%% Calculate wave length and wave number
f = 2.421e9;    % Operating frequency
c = physconst('LightSpeed');    % Velocity of light
lambda = c/f;   % Wavelength of the signal
k0 = 2*pi/lambda;   % Wave number

%% Calculate patch dimensions
epsilonR = 4.7; % Relative dielectric constant of FR4
h = 0.0015; % Substrate thickness
W = (lambda/2)*sqrt(2/(epsilonR + 1));  % Microstrip width
epsilonEff = (epsilonR+1)/2 + (epsilonR-1)/2 * 1/(sqrt(1+12*h/W)); % Effective dielectric constant
deltaL = h*0.412*((epsilonEff+0.3)*(W/h+0.264))/((epsilonEff-0.258)*(W/h+0.8)); % Length increment due to fringing
L = c/(2*f*sqrt(epsilonEff)) - 2*deltaL; % Physical length of the patch

%% Calculate impedance and feeding point
G1 = (W/(120*lambda))*(1-(k0*h)^2/24); % Single-slot conductance
Z = @(b) k0.*L.*sin(b);
X = @(b) ((sin(((k0*W)/2)*cos(b)))./cos(b)).^2.*besselj(0, Z(b)).*sin(b).^3;
G12 =1/(120*pi^2) * integral(X, 0, pi); % Mutual conductance
Rin = 50;   % Input impedance
R0 = 1/(2*(G1+G12));    % Impedance at the origin
FeedDistance = acos(sqrt(Rin/R0))*L/pi; % Feeding point

%% Calculate directivity
I_1 = -2 + cos(k0*W) + k0*W*sinint(k0*W) + sin(k0*W)/(k0*W);
D_0 = (2*pi*W/lambda)^2*1/I_1; % Directivity of a single slot
%G1 = I_1/(120*pi^2);
g12 = G12/G1;
D_AF = 2/(1 + g12); % Array factor of directivity
D_2 = D_0*D_AF; % Directivity of two slots

%% Single patch simulation
PatchAntenna = design(patchMicrostrip, f);
PatchDielectric = dielectric('FR4');
PatchDielectric.Thickness = h;
PatchDielectric.EpsilonR = epsilonR;
PatchAntenna.Substrate = PatchDielectric;
PatchAntenna.Length = W;    % Width and length are switched to rotate antennas
PatchAntenna.Width = L;
PatchAntenna.Height = h;
PatchAntenna.FeedOffset = [0 L/2-FeedDistance];

figure
show(PatchAntenna); % Antenna diagram
title('Single patch antenna');
figure
pattern(PatchAntenna, f)    % Radiation pattern
title('Single patch radiation pattern');
figure
beamwidth(PatchAntenna, f, 0, 0:1:360, 3) % HPBW, XZ plane
title('Single patch beamwidth (-3dB, \theta = [0:2\pi], \phi = 0)');
figure
beamwidth(PatchAntenna, f, 0:1:360, 0, 3) % HPBW, XY plane
title('Single patch beamwidth (-3dB, \theta = 0, \phi = [0:2\pi])');

%% Build array antenna
PatchSpacing = lambda/2;    % Separation between elements
PatchArray = linearArray('Element', PatchAntenna, 'ElementSpacing', PatchSpacing);

figure
show(PatchArray)    % Array diagram
title('Patch array antenna');
figure
pattern(PatchArray, f) % Radiation pattern
title('Patch array radiation pattern');
figure
beamwidth(PatchArray, f, 0, 0:1:360, 3) % HPBW, XZ plane
title('Patch array beamwidth (-3dB, \theta = [0:2\pi], \phi = 0)');
figure
beamwidth(PatchArray, f, 0:1:360, 0, 3) % HPBW, XY plane
title('Patch array beamwidth (-3dB, \theta = 0, \phi = [0:2\pi])');

%% Outputs
fprintf('Frequency: %.3f Hz \n', f)
fprintf('Patch substrate relative permitivity : %.3f \n', epsilonR)
fprintf('Patch substrate height : %.3f m \n', h)
fprintf('Patch input impedance : %.3f ohms \n', Rin)
fprintf('Impedance G1 : %.3f S \n', G1)
fprintf('Impedance G12 : %.3f S \n', G12)
fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch physical Length: %.3f m \n', L)
fprintf('Patch Fringing length (Delta L): %.3f m \n', DeltaL)
fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch feed distance from edge : %.5f m \n', FeedDistance)
