% This is a generic program to aquire the data from myDAQ
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

%% ------ START USER REQUIRED INFORMATION ---------%%%%%%%%%%%%%%%%%%%%%%%%
Freq = 2000; % Current frequency produced by the Function Generator
peaks = 3; % Number of desired peaks/periods

%% ---------- Do not chage anything below here ---------------
filename = sprintf('../Data/%04dmHz.dat',Freq); % To store experiment data
fid1 = fopen(filename,'w');

T  = peaks/(Freq/1000); % Time to acquire data (period*number of peaks/periods)
Fs = 10000/T; % Sampling rate Data per sec (total samples/total sample time)

plotTitle = 'Student''s Name plot - Experiment#10';
fprintf(fid1,'%s \t %s \t %s \n','time (s)', 'Input Voltage(v)','Output Voltage(v)');
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannels],'Voltage');
addAnalogOutputChannel(s,'MyDAQ1',0,'Voltage');
s.Rate = Fs; % Sample rate modify as required
%s.DurationInSeconds = T; % Sampling time modify as required
npts = 10000; % Generating 1 sec of extra points
t = (1:(npts))/Fs;
outputSignal1 = 2*sin(2*pi*freq*t)';
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

% Function for multiple channels
function logData(src,evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data(:,1) evt.Data(:,2)];
fprintf(fid,'%3.8f,%3.8f,%3.8f \n', data');
end

%% Function to plot the data as it is being acquired

% Function for multiple channels
function plotData(src,event)
time = event.TimeStamps;
input =  event.Data(:,1); %Potentiometer data in voltage
output = event.Data(:,2); %Accerlerameter
figure(1)
plot(time, input,'k.-');hold on
plot(time, output,'b.-')
xlabel('time (s)')
ylabel('Input voltage (volt)/ Output voltage (volts)')
end