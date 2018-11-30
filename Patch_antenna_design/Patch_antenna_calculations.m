%% Clean stuff
close all
clear all
clc

%% Calculate lambda (Wave length)
f = 2.421e9; % Operating frequency
c = physconst('LightSpeed');
lambda = c/f;

%% Calculate the wave number k0
k0 = 2.*pi/(lambda);

%% Calculate the Width of patch antenna
epsylonr = 4.7;
W = lambda/2*sqrt(2/(epsylonr + 1));

%% Epsilon Reff for W > h
h = 0.0015;
EpsylonReff = (epsylonr +1)/2 + (epsylonr -1)/2 * 1/(sqrt(1+12*h/W));

%% Extra length due to fringing DeltaL
DeltaL = h*0.412*((EpsylonReff+0.3)*(W/h+.264))/((EpsylonReff-.258)*(W/h+0.8));

%% Physical length of Patch PL
PL = c/(2*f*sqrt(EpsylonReff))-2*DeltaL;

%% Impedence computation G1
if W * 10 < lambda
    G1 = 1/90 * (W/lambda)^2;
elseif W > 10 * lambda
    G1 = 1/120 * (W/lambda);
else
    G1 = 1/90 * (W/lambda)^2;
end

%% Impedence computation G12
Z = @(b) k0.*PL.*sin(b);
X = @(b) ((sin(((k0*W)/2)*cos(b)))./cos(b)).^2.*besselj(0,Z(b)).*sin(b).^3;
G12 =1/(120*pi^2) * integral(X, 0, pi);

%% Impedence computation Rin
Rin = 50;
R0 = 1/(2*(G1+G12));
FeedDistance = acos(sqrt(Rin/R0))*PL/pi;

%% Single patch simulation
PatchAntenna = design (patchMicrostrip, 2.421e9);
PatchDielectric = dielectric('FR4');
PatchDielectric.Thickness = h;
PatchDielectric.EpsilonR = epsylonr;
PatchAntenna.Substrate = PatchDielectric;
PatchAntenna.Length = PL;
PatchAntenna.Width = W;
PatchAntenna.Height = h;
PatchAntenna.FeedOffset = [PL/2-FeedDistance 0];
PatchAntenna;

figure
show(PatchAntenna)
title('Single patch antenna');
figure
pattern(PatchAntenna, f)
title('Single patch radiation pattern');
figure
beamwidth(PatchAntenna, f, 0, 0:1:360, 3)
title('Single patch beamwidth (-3dB, \theta = [0:2\pi], \phi = 0)');
figure
beamwidth(PatchAntenna, f, 0:1:360, 0, 3)
title('Single patch beamwidth (-3dB, \theta = 0, \phi = [0:2\pi])');

%% Single patch directivity
I_1 = -2 + cos(k0*W) + k0*W*sinint(k0*W) + sin(k0*W)/(k0*W);
D_0 = (2*pi*W/lambda)^2*1/I_1;
g12 = G12/G1;
D_AF = 2/(1 + g12);
D_2 = D_0*D_AF;

%% Array (option 1)
PatchSpacing = 6e-2;
PatchArray = linearArray('Element', PatchAntenna, 'ElementSpacing', PatchSpacing);

figure
show(PatchArray)
title('Patch array antenna');
figure
pattern(PatchArray, f)
title('Patch array radiation pattern');
figure
beamwidth(PatchArray, f, 0, 0:1:360, 3)
title('Patch array beamwidth (-3dB, \theta = [0:2\pi], \phi = 0)');
figure
beamwidth(PatchArray, f, 0:1:360, 0, 3)
title('Patch array beamwidth (-3dB, \theta = 0, \phi = [0:2\pi])');

%% Array (option 2)
PatchAntenna_2 = PatchAntenna;
PatchAntenna_2.Length = W;
PatchAntenna_2.Width = PL;
PatchAntenna_2.FeedOffset = [0 PL/2-FeedDistance];

PatchArray_2 = linearArray('Element', PatchAntenna_2, 'ElementSpacing', PatchSpacing);

figure
show(PatchArray_2)
title('Patch array antenna');
figure
pattern(PatchArray_2, f)
title('Patch array radiation pattern');
figure
beamwidth(PatchArray_2, f, 0, 0:1:360, 3)
title('Patch array beamwidth (-3dB, \theta = [0:2\pi], \phi = 0)');
figure
beamwidth(PatchArray_2, f, 0:1:360, 0, 3)
title('Patch array beamwidth (-3dB, \theta = 0, \phi = [0:2\pi])');

%% Outputs
fprintf('Frequency: %.3f Hz \n', f)
fprintf('Patch substrate relative permitivity : %.3f \n', epsylonr)
fprintf('Patch substrate height : %.3f m \n', h)
fprintf('Patch input impedance : %.3f ohms \n', Rin)
fprintf('Impedance G1 : %.3f S \n', G1)
fprintf('Impedance G12 : %.3f S \n', G12)
fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch physical Length: %.3f m \n', PL)
fprintf('Patch Fringing length (Delta L): %.3f m \n', DeltaL)
fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch feed distance from edge : %.5f m \n', FeedDistance)
