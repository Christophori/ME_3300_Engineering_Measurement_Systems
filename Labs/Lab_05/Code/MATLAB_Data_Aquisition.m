 ""% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for collecting the data to capture
% pendulum motion file for later use
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

%% Start of user information
Fs = 200; % Sampling rate data per sec
T = 5; % Time to aquire data
% Here change the device name and input channel as needed; if not sure then talk to TAs
deviceName = 'myDAQ1';
inputChannels = 0; % use to sample a single channel
enableLogging = true; % enable / disable logging to file (true/false)
enablePlotting = true; % enable / disable plotting on a figure during aquisition (true/false)
enableCalibratedPressure = false; % enable / disable calibrated flow rate (true/false)

%% Input the filename and directory where to store the data
filename = '../Data/Student_Name_VoltsVsTime.csv'; % Name/ location for storing data file
fid1 = fopen(filename,'w'); % this will fail if you don't create a blank csv in the required location first!

%% Add the slope and intercept values to convert volts to physical varaible (angle)
% NOTE: If you use this make sure to change the name of your file
%% Slope and intercept for "ai0"
slope = 1;
intercept = 0;
% New variable to bias your data
v0 = 0; % Voltage output from sensor at sensor at zero flow rate

% Uncomment for single-channel data aquisition
header = ["Times (s)","Voltage (Volts)"]; % set the column titles for the data file
%vheader = ["Times (s)","Voltage (Volts)","Flowrate (scfm)"]; % set the column titles for the data file

plotTitle = 'Firstname LastName''s plot - Lab #05';
fprintf(fid1,'%s,%s\n',header(1),header(2)); % modify this line as needed for more columns in later labs
% fprintf(fid1,'%s,%s,%s\n',header(1),header(2),header(3)); % modify this line as needed for more columns in later labs

%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannels],'Voltage');
s.Rate = Fs; % Sample rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
if enablePlotting == 1
    lh1 = addlistener(s,'DataAvailable',@(src, event)plotData(src,event,slope,intercept,v0,enableCalibratedPressure));
end

if enableLogging == 1
    lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src,event,fid1,slope,intercept,v0,enableCalibratedPressure));
end

errorListener = addlistener(s, 'ErrorOccurred',@(src, event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)

%% Function to store the data in a file- values are converted to physical variable using slope and intercept
function logData(src,evt, fid,m,c,v0,enableCalibratedPressure)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
    if enableCalibratedPressure == 0
        data = [evt.TimeStamps evt.Data];
        fprintf(fid,'%f,%f \n', data');
    elseif enableCalibratedPressure == 1
        data = [evt.TimeStamps evt.Data (m.*(sqrt(abs(evt.Data-v0))))+c];
        fprintf(fid,'%f,%f,%f \n', data');
    end
end

%% Function to plot the data as it is being acquired
function plotData(src,event,m,c,v0,enableCalibratedPressure)
    if enableCalibratedPressure == 0
        time = event.TimeStamps;
        voltage = event.Data; %Potentiometer data in voltage
        figure(1)
        plot(time, voltage,'k.-');hold on
        xlabel('time (s)')
        ylabel('Voltage (Volts)')
    elseif enableCalibratedPressure == 1
        time = event.TimeStamps;
        flowrate = (m.*(sqrt(abs(event.Data-v0))))+c; %flowrate
        figure(1)
        plot(time, flowrate,'k.-');hold on
        xlabel('time (s)')
        ylabel('Flowrate (scfm)')
    end
end
