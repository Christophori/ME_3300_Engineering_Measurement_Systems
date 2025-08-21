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
Fs = 200; %Sampling rate Data per sec
T  = 10; % Time to acquire data
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2', [0], 'Voltage');
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
lh = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event));
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh)


function plotAndLogData(src,event)
time = event.TimeStamps;
voltage = event.Data; %Potentiometer data in voltage
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end