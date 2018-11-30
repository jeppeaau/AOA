
%Calculates the impedance og G12 for the patch antenna 

clear all
clc
%calculate lambda (Wave length)
f = 2.421e9; % Operating frequency
c = physconst('LightSpeed');
lambda = c/f;

% Calculate the wave number k0
k0 = 2.*pi/(lambda);

% Calculate the Width of pach antenna
epsylonr = 4.7;
W = lambda/2*sqrt(2/(epsylonr + 1));

% Epsylon Reff for W > h
h = 0.0015;
EpsylonReff = (epsylonr +1)/2 + (epsylonr -1)/2 * 1/(sqrt(1+12*h/W));

% Extra length due to fringing DeltaL
DeltaL = h*0.412*((EpsylonReff+0.3)*(W/h+.264))/((EpsylonReff-.258)*(W/h+0.8));

% Physical length of Patch PL
PL = c/(2*f*sqrt(EpsylonReff))-2*DeltaL;

% Impedence computation G1
if W * 10 < lambda
    G1 = 1/90 * (W/lambda)^2;
    
elseif W > 10 * lambda
    G1 = 1/120 * (W/lambda);
else
    G1 = 1/90 * (W/lambda)^2;
end

% Impedence computation G12
Z = @(b) k0.*PL.*sin(b);
X = @(b) ((sin(((k0*W)/2)*cos(b)))./cos(b)).^2.*besselj(0,Z(b)).*sin(b).^3;

G12 =1/(120*pi^2)* integral(X, 0, pi);

% Impedence computation Rin

Rin = 50;
R0 = 1/(2*(G1+G12));
FeedDistance = acos(sqrt(Rin/R0))*PL/pi;


% Patch simulation
%PatchAntenna = design (patchMicrostrip, 2.421e9);
%PatchDielectric = dielectric('FR4');
%PatchDielectric.Thickness = h;
%PatchDielectric.EpsilonR = epsylonr;
%PatchAntenna.Substrate = PatchDielectric;

%PatchAntenna.Length = PL;
%PatchAntenna.Width = W;
%PatchAntenna.Height = h;
%PatchAntenna.FeedOffset = [0, FeedDistance];
%PatchAntenna
%figure
%show(PatchAntenna)
%figure
%pattern(PatchAntenna,f)

%Array
%PatchSpacing = 0.1;
%PatchArray = linearArray('Element',PatchAntenna,'ElementSpacing', PatchSpacing);
%figure
%pattern(PatchArray,f)





% Outputs
fprintf('Frequency: %.3f Hz \n', f)
fprintf('Patch substrate relative permitivity : %.3f \n', epsylonr)
fprintf('Patch substrate height : %.3f m \n', h)
fprintf('Patch input impedance : %.3f ohms \n', Rin)
fprintf('Impedance G1 : %.3f siemens \n', G1)
fprintf('Impedance G12 : %.3f siemens \n', G12)

fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch physical Length: %.3f m \n', PL)
fprintf('Patch Fringing length (Delta L): %.3f m \n', DeltaL)
fprintf('Patch Width: %.3f m \n', W)
fprintf('Patch feed distance from edge : %.5f m \n', FeedDistance)

