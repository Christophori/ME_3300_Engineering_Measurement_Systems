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

%% Start of user information
Fs = 200; % Sampling rate data per sec
T = 5; % Time to aquire data
% Here change the device name and input channel as needed; if not sure then talk to TAs
deviceName = 'myDAQ1';
% inputChannels = 'ai0'; % use to sample a single channel
inputChannels = ["ai0", "ai1"]; % use this line instead to aquire multiple channels
enableLogging = true; % enable / disable logging to file
enablePlotting = true; % enable / disable plotting on a figure during aquisition

%% Input the filename and directory where to store the data
filename = '../Data/Student_Name_VoltsVsTime.csv'; % Name/ location for storing data file
header = ["Times (s)","Voltage (Volts)"]; % set the column titles for the data file
fid1 = fopen(filename,'w'); % this will fail if you don't create a blank csv in the required location first!

%% Add the slope and intercept values to convert volts to physical varaible (angle)
% NOTE: If you use this make sure to change the name of your file
slope = 1; % Add your calibration slope for potentiometer for this experiment it is not required use default of 1
intercept = 0; % Add you calibration intercept for potentioment for this experiment it is not required used default of 0

slope2 = 1; % Add your calibration slope for potentiometer for this experiment it is not required use default of 1
intercept2 = 0; % Add your calibration slope for potentiometer for this experiment it is not required use default of 1

plotTitle = 'Firstname LastName''s plot - Lab #02';
fprintf(fid1,'%s,%s\n',header(1),header(2)); % modify this line as needed for more columns in later labs

%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannels],'Voltage');
s.Rate = Fs; % Sample rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
if enablePlotting == 1
    if length(inputChannels) < 2
        lh1 = addlistener(s,'DataAvailable',@(src, event)plotData(src,event,slope,intercept));
    else
        lh1 = addlistener(s,'DataAvailable',@(src, event)plotData2(src,event,slope,intercept,slope2,intercept2));
    end
end
if enableLogging
    if length(inputChannels) < 2
        lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src,event,fid1,slope,intercept));
    else
        lh2 = addlistener(s,'DataAvailable',@(src, event)logData2(src,event,fid1,slope,intercept,slope2,intercept2));
    end
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
function logData(src,evt, fid,m,c)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m*evt.Data+c];
fprintf(fid,'%f,%f \n', data');
end

% Function for multiple channels
function logData2(src,evt, fid, m1, c1, m2, c2)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m1*evt.Data(:,1)+c1 m2*evt.Data(:,2)+c2];
fprintf(fid,'%f,%f \n', data');
end

%% Function to plot the data as it is being acquired
function plotData(src,event,m,c)
time = event.TimeStamps;
voltage = m*event.Data + c; %Potentiometer data in voltage
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (Volts)')
end


% Function for multiple channels
function plotData2(src,event, m1, c1, m2, c2)
time = event.TimeStamps;
angularPosition =  m1*event.Data(:,1) + c1; %Potentiometer data in voltage
acc = m2*event.Data(:,2) + c2; %Accerlerameter
figure(1)
plot(time, angularPosition,'k.-');hold on
plot(time, acc,'b.-')
xlabel('time (s)')
ylabel('Angular position (degrees)/ Accerleration (m/s^2)')
end