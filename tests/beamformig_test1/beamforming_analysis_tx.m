%%*****---------------------------------------------------------------*****
%{

    - This script analyzes the signals transmitted by the antenna array in
    the beamforming process.
    - This script extracts the data obtained through GNU Radio, splits them
    into the differen zones and generates a binary file for each of them. 
    - Complementary files needed: "bin2complex.m", "test1tx1.bin",
    "test1tx2.bin".
    - Output file sintaxis: "data_aXzY_tx.bin" means Tx file for antenna X
    corresponding to zone Y.

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
clear all
close all
clc

%% Read data from GNU Radio output binaries
input_files = ["test1tx1" "test1tx2"];              % Files to be read
f_in = zeros(length(input_files));                  % Pre-allocate memory
data_tx = zeros(length(input_files), 22562070);     
for i=1:1:length(input_files)                       % Iterate over number of files
    f_in(i) = fopen(input_files(i), 'r');           % Open file
    data_tx(i,:) = (real(bin2complex(f_in(i))))';   % Load binary data as complex float32. Transpose data.
    fclose(f_in(i));                                % Close file
end

%% Plot raw data
figure;
for i=1:1:length(input_files)               % Iterate over number of antennas
    subplot(2,1,i)
    plot(data_tx(i,:));                     % Plot signals
    hold on
    grid on
    axis([0 length(data_tx(i,:)) 1.2*min(data_tx(i,:)) 1.2*max(data_tx(i,:))]);
    title("Tx " + num2str(i) + " " + "raw data");
    xlabel('Sample number');
    ylabel('Amplitude');
    hold off
end

%% Divide datasets into zones
zone_size = 5e3;                                            % 5000 samples per zone
divs_tx = [1e6 3.95e6 7.2e6 9.5e6 13e6 15e6 18e6 21e6];     % Zone delimiters
data_zones = zeros(length(divs_tx), zone_size, length(input_files));
for i=1:1:length(input_files)        % Iterate over number of antennas
    figure
    for j=1:1:length(divs_tx)        % Iterate over number of zones
       data_zones(j,:,i) = data_tx(i, divs_tx(j):divs_tx(j) + zone_size-1); % Store samples of corresponding zone
       subplot(4, 2, j)
       plot(data_zones(j,:,i));      % Plot siganls for each zone
       grid on
       axis([0 length(data_zones(j,:,i)) -0.12 0.12]);
       title("Tx Antenna " + num2str(i) + ", " + "Zone " + num2str(j));
       xlabel("Sample number");
       ylabel("Amplitude");
    end
end

%% Write zone values to new binary file
% Names of the output files
output_files = ["data_a1z1_tx.bin" "data_a1z2_tx.bin" "data_a1z3_tx.bin" "data_a1z4_tx.bin" "data_a1z5_tx.bin" "data_a1z6_tx.bin" "data_a1z7_tx.bin" "data_a1z8_tx.bin";
                "data_a2z1_tx.bin" "data_a2z2_tx.bin" "data_a2z3_tx.bin" "data_a2z4_tx.bin" "data_a2z5_tx.bin" "data_a2z6_tx.bin" "data_a2z7_tx.bin" "data_a2z8_tx.bin"];
f_out = zeros(length(divs_tx), length(divs_tx));
for i=1:1:length(input_files)
    for j=1:1:length(divs_tx)
        f_out(i,j) = fopen(output_files(i,j), 'w');         % Open file
        fwrite(f_out(i,j), data_zones(j,:,i), 'float32');   % Write data to file
        fclose(f_out(i,j));                                 % Close file
    end
end
