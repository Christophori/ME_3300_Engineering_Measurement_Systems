% This is program is for the experiment #4 purpose it logs the data
% in a file for later use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 6th, 2020
% Dr. Vibhav Durgesh
% Rev 0.0
% User has to provide appropriate information - see beginning of code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE OVERWRITES THE DATA. PLEASE MOVE THE FILES OR RENAME PRIOR TO
% RERUNNING THE CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% Start of user information %%
Fs = 100; % Sampling rate data per sec
T = 5; % Time to aquire data
filename = '../Data/StaticsSignal_5V.dat'; % Change the file name to store the data
fid1 = fopen(filename,'w');
%% DAQ information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'myDAQ1',[0],'Voltage');
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
data = readmatrix(filename);
avgVolt = mean(data(:,2));
gcf;
title(['Average voltage: ' sprintf('%3.8f',avgVolt) ' (v)'],'fontname','times','fontsize',14)

%% Function to plot the data
function plotAndLogData(src,event)
time = event.TimeStamps;
voltage = event.Data;
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end

%% Function to save the data
function logData(src, evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data];
fprintf(fid,'%f \t %f \n', data');
end
