% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script draws the graph shown in
% the first AoA test (wired test). It
% imports the data from the specified
% file (test_1.bin, found in Drive)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;
%% Open files and initialize variables
% Variables and files
name1=input('Introduce file with test data: ','s');

f1=fopen(name1,'r');

% Parameters of the system
samp=256e3;  % Samples/s, each sample contains 64 bits


%% Read files
if f1~=-1
    data_1=bin2complex(f1);
    
    % Compute angle of arrival
    aoa_data=real(rad2deg(data_1));
    
    % Plot phase shift vs time
    T=1/samp;
    t=(0:T:(length(aoa_data)/samp-T)).';
    
    figure();
    plot(t,aoa_data,'r.');
    grid on;
    hold on;
    % Plot moving average of the data, taking a time interval T_av
    T_av=1;           % seconds
    aoa_average=movmean(aoa_data,T_av*samp);
    plot(t,aoa_average,'b','LineWidth',2);
    xlabel('Time (s)');
    ylabel('Angle (deg)');
    plot([0 max(t)],[90 90],'-k','LineWidth',1);
    legend('Angle of arrival','Average','90º Reference');
    xlim([0 max(t)]);
    title('Angle of Arrival Test Results');
    disp('Done');
else
    disp('Files not found');
end
    
    