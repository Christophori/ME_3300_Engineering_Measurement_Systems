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
data = readmatrix("..\Data\Student_Name_Expt_03.csv");
time = data(:,1); % Time data
angularPosition = data(:,2); % Angular location (degree)
acc = data(:,3); % Accelerometer data (m/s^2)

rad = angularPosition*pi/180; % convert degree value to radians
theta_d =  diff(rad)./diff(angularPosition); % calculating angular velocity rad/s

acc_1 =  - (theta_d.^2) * r; % calculated acceleration m/s^2
acc_2 = acc - (g*cos(rad)); % removing acceleration due to gravity component accelerometer data


% Use previous code to fill in code here to plot both: acc_1 and acc_2
% into a single plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Acceleration_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Acceleration_Plot.pdf",Resolution=600) % for canvas submission 