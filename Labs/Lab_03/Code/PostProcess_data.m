% Sample program to process your data for post-lab
%%%%% Make sure to modify as required %%%%%%
close all
clear all
clc

%% Prefined Parameters
r = 0.2159; %Length of the pendulum (m)
g = -9.81; %Constant gravity (m/s^2)

%% load the data using readmatrix
% alternatively we can directly read in data values with readmatrix
data = readmatrix("../Data/Expt_03_Jasmeen_Manshahia.csv");
time = data(:,1); % Time data
angularPosition = data(:,2); % Angular location (degree)
acc = data(:,3); % Accelerometer data (m/s^2)

rad = angularPosition*pi/180; % convert degree value to radians
theta_d =  diff(rad)./diff(time); % calculating angular velocity rad/s

acc_1 =  - (theta_d.^2) * r; % calculated acceleration m/s^2
acc_2 = acc - (g*cos(rad)); % removing acceleration due to gravity component accelerometer data


% Use previous code to fill in code here to plot both: acc_1 and acc_2
% into a single plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
better_fig = figure (1)
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
%% Plotting data
plot(time(1:end-1),acc_1,'-bo','markersize',3);hold on
plot(time,acc_2,'ro','markersize',3,'markerfacecolor','r');
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')
grid on


legend('Expt. data','Accelerometer data','location','Southeast')
title("Student''s Firstname-Lastname''s Plot")

%% Saving the files in png and pdf format
figName = ('../Figures/Student''s Firstname-Lastname''s_Expt03_Postprocess');
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf, 'Position');
set(gcf, 'PaperSize', figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600') 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

