% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for collecting the data to capture
% pendulum motion file for later use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 5th, 2020
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

%% Start of user information
Fs = 200; %Sampling rate data per sec
T = 20; %Time to aquire data
%% Here change the device name and input channel as needed; if not sure then talk to TAs
deviceName = 'myDAQ1';
inputChannel = 'ai0';
%% Input the filename and directory where to store the data
filename = '../Data/Student_Name_AngVsTime.dat'; %To store calibration data file
fid1 = fopen(filename,'w');
%% Add the slope and intercept values to convert volts to physical varaible (angle)
slope = -73.915; %Add your calibration slope for potentiometer
intercept = 190.4438; %Add you calibration intercept for potentioment
plotTitle = 'Firstname LastName''s plot - Experiment#2';
fprintf(fid1,'%s \t %s \n','Times (s)','Angular Position (degrees)')
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannel],'Voltage');
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event,slope,intercept));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1,slope,intercept));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
title(plotTitle,'fontname','times','fontsize',14)
%% Function to plot the data as it is being acquired
function plotAndLogData(src,event,m,c)
time = event.TimeStamps;
voltage =  m*event.Data + c; %Potentiometer data in voltage
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Angular position (degrees)')
end

%% Function to store the data in a file- values are converted to physical variable using slope and intercept
function logData(src,evt, fid,m,c)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m*evt.Data+c];
fprintf(fid,'%f \t %f \n', data');
end