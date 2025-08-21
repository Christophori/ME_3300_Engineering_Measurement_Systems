% This is a genric program to acquire the data from NI- 6001
%% Sample data acquistion program 
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% This is basic program to acquire data from a data acqusition device.
% User has to provide apropriate information see - begining of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE OVERWRITE THE DATA. PLEASE MOVE THE FILES OR REMANE PRIOR TO
% RERUNNING THE CODE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% ------ START USER REQUIRED INFORMATION ---------%%%%%%%%%%%%%%%%%%%%%%%%
outputFileName = 'AngVsTime.dat'; % This program will overwrite the file
slope = 69.4489; % Slope for converting voltage to appropriate unit
intercept = -164.3504; % Intercept for converting voltage to appropriate unit
Fs = 200; %Sampling rate Data per sec
T  = 15; % Time to acquire data
choice = 1; %% Set to 1 to write data to a file otherwise 0
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2', 'ai0', 'Voltage'); 
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
if choice == 1
    fid1 = fopen(outputFileName,'w'); % File name to store your data
    fprintf(fid1,'%s \t %s \n','Time(s)','Volt (v)');
else
    fid1 = 0;
end
lh = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event, fid1,slope,intercept,choice)); 
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
drawnow
startBackground(s);
pause
delete(s)
delete(lh)
if choice == 1
    fclose(fid1);
end