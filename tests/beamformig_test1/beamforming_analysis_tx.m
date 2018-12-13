%%*****---------------------------------------------------------------*****
%{

    - This script analyzes the signals transmitted by the antenna array in
    the beamforming process.
    - This script extracts the data obtained through GNU Radio, splits them
    into the differen zones and generates a binary file for each of them. 
    - Complementary files needed: "bin2complex.m", "test1tx1.bin",
    "test1tx2.bin".

%}
%%*****---------------------------------------------------------------*****

%% Clean stuff
clear all
close all
clc

%% Read data from GNU Radio output binaries
input_files = ["test1tx1" "test1tx2"];
f_in = zeros(length(input_files));
data_tx = zeros(length(input_files), 22562070);
for i=1:1:2
    f_in(i) = fopen(input_files(i), 'r');
    data_tx(i,:) = (real(bin2complex(f_in(i))))';
    fclose(f_in(i));
end

%% Plot raw data
figure;
for i=1:1:2
    subplot(2,1,i)
    plot(data_tx(i,:));
    hold on
    grid on
    axis([0 length(data_tx(i,:)) 1.2*min(data_tx(i,:)) 1.2*max(data_tx(i,:))]);
    title("Tx " + num2str(i) + " " + "raw data");
    xlabel('Sample number');
    ylabel('Amplitude');
    hold off
end

%% Divide datasets into zones
zone_size = 5e3;
%divs_rx1 = [1 2.3e6 3.95e6 5.63e6 7.1e6 7.9e6 9.27e6 10.8e6 12.1e6 13.5e6 14.9e6 16.4e6 17.8e6 18.7e6 20e6 21e6 22.3e6 length(data_rx1)];
divs_rx = [1e6 3.95e6 7.2e6 9.5e6 13e6 15e6 18e6 21e6];
data_zones = zeros(length(divs_rx), zone_size, length(input_files));
%figure
for i=1:1:2
    figure
    for j=1:1:8
       data_zones(j,:,i) = data_tx(i, divs_rx(j):divs_rx(j) + zone_size-1);
       subplot(4, 2, j)
       plot(data_zones(j,:,i));
       grid on
       axis([0 length(data_zones(j,:,i)) -0.12 0.12]);
       title("Tx Antenna " + num2str(i) + ", " + "Zone " + num2str(j));
       xlabel("Sample number");
       ylabel("Amplitude");
    end
end

%% Write zone values to new binary file
output_files = ["data11.bin" "data12.bin" "data13.bin" "data14.bin" "data15.bin" "data16.bin" "data17.bin" "data18.bin";
                "data21.bin" "data22.bin" "data23.bin" "data24.bin" "data25.bin" "data26.bin" "data27.bin" "data28.bin"];
f_out = zeros(length(divs_rx), length(divs_rx));
for i=1:1:2
    for j=1:1:length(divs_rx)
        f_out(i,j) = fopen(output_files(i,j), 'w');
        fwrite(f_out(i,j), data_zones(j,:,i), 'float32');
        fclose(f_out(i,j));
    end
end
