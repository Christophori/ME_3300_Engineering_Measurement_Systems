% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for collecting the data to measure
% various amplifiers
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
inputChannels = [0 1]; % use to sample a single channel
enableLogging = true; % enable / disable logging to file (true/false)
enablePlotting = true; % enable / disable plotting on a figure during aquisition (true/false)

%% Input the filename and directory where to store the data
filename = '../Data/AD622Data.csv'; % Name/ location for storing data file
fid1 = fopen(filename,'w'); % this will fail if you don't create a blank csv in the required location first!
header = ["Times (s)","Output Voltage (v)","Input Voltage (v)"]; % set the column titles for the data file

plotTitle = 'Firstname LastName''s plot - Lab #06';
fprintf(fid1,'%s,%s,%s\n',header(1),header(2),header(3)); % modify this line as needed for more columns in later labs

%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannels],'Voltage');
s.Rate = Fs; % Sample rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required

% Create analog output for varying voltage
addAnalogOutputChannel(s,deviceName,0,'Voltage');
s.Rate = Fs;
outputSignal1 = linspace(0,5,Fs*T)';
queueOutputData(s,outputSignal1);

if enablePlotting == 1
    lh1 = addlistener(s,'DataAvailable',@(src, event)plotData(src,event));
end

if enableLogging
    lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src,event,fid1));
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
function logData(src,evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
    data = [evt.TimeStamps evt.Data(:,1) evt.Data(:,2)];
    fprintf(fid,'%f,%f,%f \n', data');
end

%% Function to plot the data as it is being acquired
function plotData(src,event)
    time = event.TimeStamps;
    outputvoltage = event.Data(:,1); % Amplified voltage
    inputvoltage = event.Data(:,2); % Output voltage 0-5V
    plot(time, inputvoltage,'k-');hold on
    plot(time, outputvoltage,'r-');
    xlabel('time (s)')
    ylabel('Voltage(v)')
    legend('Input volt','Output volt','location','northwest')
end
