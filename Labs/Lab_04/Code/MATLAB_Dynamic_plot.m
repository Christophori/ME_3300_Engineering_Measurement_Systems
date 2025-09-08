% This is a generic program to generate plots for Lab #4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 09/02/2025
% Author: Dr. Christopher Bitikofer
% Decription:
% This code and it's supporting functions can be configured to collect data
% using the NI-MyDAQ.
% The user must provide appropriate information - see beginning of code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE OVERWRITES THE DATA. PLEASE MOVE THE FILES OR RENAME PRIOR TO
% RERUNNING THE CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% UPDATE THIS SKELETON CODE TO CREATE FIGURE

% Open collected data
volt_data = readtable('..\Data\DynSignal_000Hz.csv');
time1 = volt_data.Time; % This step accesss the values from the table.
voltage1 = volt_data.Volts;  

volt_data = readtable('..\Data\DynSignal_000Hz.csv');
time2 = volt_data.Time; % This step accesss the values from the table.
voltage2 = volt_data.Volts;  

volt_data = readtable('..\Data\DynSignal_000Hz.csv');
time3 = volt_data.Time; % This step accesss the values from the table.
voltage3 = volt_data.Volts;  

%% Open more data here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
subplot(3,1,1) % Plotting data for 3 peaks only
plot(time1(1:1:5000),y1(1:1:5000),'r.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 4.5])
xlabel('times (s)')
ylabel('Volts (v)')
grid on
title('Sampling rate = 1000Hz, Signal generator =0.5Hz, Aquired data =0.5Hz','fontsize',12)


subplot(3,1,2) % Plotting data for 3 peaks only
plot(time2(1:1:100),y2(1:1:100),'k.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 4.5])
xlabel('times (s)')
ylabel('Volts (v)')
grid on
title('Sampling rate = 1000Hz, Signal generator =975Hz, Aquired data =0Hz','fontsize',12)


subplot(3,1,3) % Plotting data for 3 peaks only
plot(time3(1:15),y3(1:15),'b.-','markersize',6,'markerfacecolor','r')
ylim([0.5 4.5])
xlabel('times (s)')
ylabel('Volts (v)')
grid on
title('Sampling rate = 1000Hz, Signal generator=1250Hz, Aquired data =0Hz','fontsize',12)

%% Add more subplots here
% NOTE: Previous subplots should also be updated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Dynamic_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Dynamic_Plot.pdf",Resolution=600) % for canvas submission 