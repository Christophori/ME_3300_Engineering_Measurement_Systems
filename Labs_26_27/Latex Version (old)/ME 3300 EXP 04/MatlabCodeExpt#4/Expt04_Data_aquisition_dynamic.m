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
Fs = 1000; %Sampling rate data per sec
T = 0.2; %Time to aquire data
filename = '../Data/DynSignal_1250Hz.dat'; %To store calibration data file
fid1 = fopen(filename,'w');
plotTitle = 'Firstname Lastname''s plot - Experiment#4';
fprintf(fid1,'%s \t %s \n','times (s)','Voltage (V)');
%% Providing information for the DAQ device
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
title(plotTitle,'fontname', 'times','fontsize',14)

%% Function to plot the data
function plotAndLogData(src,event)
time = event.TimeStamps;
voltage = event.Data;  
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end

%% FUnction to save the data in a file
function logData(src, evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data];
fprintf(fid,'%f \t %f \n', data');
end
