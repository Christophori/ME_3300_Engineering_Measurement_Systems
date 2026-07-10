% This is a generic program to aquire the data from myDAQ 
% THis can be used to test circuit and DAQ is working properly
% Sample data acquisition program
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
%% ----- Start user required information ----- %%%%%%%%%%%%%%%%%%%
Fs = 200; %Sampling rate data per sec
T = 10; %Time to aquire data
%% Here change the device name and input channel as needed; if not sure then talk to TAs
deviceName = 'myDAQ1';
inputChannel = 'ai0';
%% ----- End user required information ----- %%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,deviceName,[inputChannel],'Voltage');
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh = addlistener(s,'DataAvailable',@(src,event)plotAndLogData(src,event));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event)plotAndLogData(src, event));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh)

%% Plotting the voltage and time information
function plotAndLogData(src, event)
time = event.TimeStamps; 
voltage = event.Data;%Potentiometer data in voltage
figure (1)
plot(time,voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end