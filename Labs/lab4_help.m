%% This code is written to help students understand experiement #4 dyanmics
% section of the lab
% By: Rodrigo Padilla
% Created: 2/9/2024
clear all
close all
clc

f = 450;
t = [0:1/10000:1]; % This fixes the sample rate at 10000 Hz so the signal is not alliased
y = 2.5 + 2.*sin(2*pi*f*t);
t2 = [0.0005:1/1000:1.0005]; % This matches the sample created in the lab
y2 = 2.5 + 2.*sin(2*pi*f*t2);
plot(t,y,'r-'); hold on
plot(t2,y2,'mo-')
xlim([0 0.01])
xlabel('time (s)')
ylabel('voltage (V)')
