%%*****---------------------------------------------------------------*****
%{
    - NOT FULLY TESTED!!
    - This script computes the value of the gain for a 2-element array when
    beamforming is applied.

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
%close all
clear all
clc

%% Ask for parameters
alpha_deg = input("Introduce beacon position, in degrees: ");
alpha = deg2rad(alpha_deg);
r = input('Choose radius, in meters: ');

%% Design antenna array
% Calculate wave length and wave number
f = 2.421e9;                    % Operating frequency
c = physconst('LightSpeed');    % Velocity of light
lambda = c/f;                   % Wavelength of the signal
k0 = 2*pi/lambda;               % Wave number

% Calculate patch dimensions
epsilonR = 4.7;                             % Relative dielectric constant of FR4
h = 0.0015;                                 % Substrate thickness
W = (lambda/2)*sqrt(2/(epsilonR + 1));      % Microstrip width
epsilonEff = (epsilonR+1)/2 + (epsilonR-1)/2 * 1/(sqrt(1+12*h/W));              % Effective dielectric constant
deltaL = h*0.412*((epsilonEff+0.3)*(W/h+0.264))/((epsilonEff-0.258)*(W/h+0.8)); % Length increment due to fringing
L = c/(2*f*sqrt(epsilonEff)) - 2*deltaL;    % Physical length of the patch

% Calculate impedance and feeding point
G1 = (W/(120*lambda))*(1-(k0*h)^2/24);          % Single-slot conductance
Z = @(b) k0.*L.*sin(b);
X = @(b) ((sin(((k0*W)/2)*cos(b)))./cos(b)).^2.*besselj(0, Z(b)).*sin(b).^3;
G12 =1/(120*pi^2) * integral(X, 0, pi);         % Mutual conductance
Rin = 50;                                       % Input impedance
R0 = 1/(2*(G1+G12));                            % Impedance at the origin
FeedDistance = acos(sqrt(Rin/R0))*L/pi;         % Feeding point

% Calculate directivity
I_1 = -2 + cos(k0*W) + k0*W*sinint(k0*W) + sin(k0*W)/(k0*W);
D_0 = (2*pi*W/lambda)^2*1/I_1;       % Directivity of a single slot
%G1 = I_1/(120*pi^2);
g12 = G12/G1;
D_AF = 2/(1 + g12);                  % Array factor of directivity
D_2 = D_0*D_AF;                      % Directivity of two slots

% Single patch simulation
PatchAntenna = design(patchMicrostrip, f);
PatchDielectric = dielectric('FR4');
PatchDielectric.Thickness = h;
PatchDielectric.EpsilonR = epsilonR;
PatchAntenna.Substrate = PatchDielectric;
PatchAntenna.Length = W;        % Width and length are switched to rotate antennas
PatchAntenna.Width = L;
PatchAntenna.Height = h;
PatchAntenna.FeedOffset = [0 L/2-FeedDistance];

% Build array antenna
PatchSpacing = lambda/2;        % Separation between elements
PatchArray = linearArray('Element', PatchAntenna, 'ElementSpacing', PatchSpacing);

%% Compute phase shift
t = linspace(0, 2*1/f, 2*280+1);

% Beacon distance and antenna positioning
x_A = r - PatchSpacing/2;       % Antennas' position
x_B = r + PatchSpacing/2;

% Compute angles of arrival to antennas
x_s = r .* (1 + cos(alpha));            % Beacon's coordinates (4-quadrant)
y_s = r .* abs(sin(alpha - pi));
aoa_A = atan2(y_s, abs(x_s - x_A));     % Angles of arrival to both antennas (4-quadrant)
aoa_B = atan2(y_s, abs(x_s - x_B));

% Compute distances from beacon to antennas
dof_A = (abs(x_s - x_A))./cos(aoa_A);   % Distance of flight to antennas (4-quadrant)
dof_B = (abs(x_s - x_B))./cos(aoa_B);

% Compute time of flight
tof_A = dof_A./c;
tof_B = dof_B./c;

% Compute phase of each antenna
phs_A = zeros(length(tof_A), length(t));  % Preallocate space
phs_B = zeros(length(tof_B), length(t));
for i=1:1:length(tof_A)   
    phs_A(i,:) = 2*pi*f.*(t + tof_A(i));  % Phases of the equivalent signals at A and B
    phs_B(i,:) = 2*pi*f.*(t + tof_B(i));  
end

% Phase shift
phsShift = phs_B(1) - phs_A(1);           % Left antenna as phase reference
if phsShift > 0
    PatchArray.PhaseShift = [0 rad2deg(phsShift)];
elseif phsShift < 0
    PatchArray.PhaseShift = [rad2deg(phsShift) 0];
elseif phsShift == 0
    PatchArray.PhaseShift = [0 0];
end
az_angle = 1:1:360;
el_angle = 1:1:180;
figure
pattern(PatchArray, f, 0, el_angle, 'CoordinateSystem', 'rectangular');

% Compute angle of arrival
AoA = 180 - rad2deg(acos((phsShift*c)/(2*pi*f*PatchSpacing)));   % Beamforming angle
