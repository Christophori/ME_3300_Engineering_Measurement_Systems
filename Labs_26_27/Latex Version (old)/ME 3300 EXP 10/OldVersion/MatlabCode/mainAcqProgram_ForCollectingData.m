% This is a genric program to acquire the data from NI- 6001
%% Sample data acquistion program for collecting the data to capture pendulum motion
% file for later use 
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
Fs = 1000; %Sampling rate Data per sec
T  = 310; % Time to acquire data
filename = '10mHz.dat'; % To store experiment data
fid1 = fopen(filename,'w');
slope1= 1; % Add your calibration slope for input 1
intercept1 = 0; % Add your calibration intercept for input 1

slope2 = -1; % Add your calibration slope for input 2
intercept2 = 0; % Add your calibration intercept for input 2

plotTitle = 'Paulo Yu''s plot - Experiment#10';
fprintf(fid1,'%s \t %s \t %s\n','time (s)', 'Input Voltage(v)','Output Voltage(v)');
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', [0 1], 'Voltage');
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
lh1 = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event,slope1,intercept1,slope2,intercept2));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1,slope1,intercept1,slope2,intercept2));
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
title(plotTitle,'fontname','times','fontsize',14)
function plotAndLogData(src,event,slope1,intercept1,slope2,intercept2)
time = event.TimeStamps;
InputData = slope1*event.Data(:,1)+intercept1; 
OutputData = slope2*event.Data(:,2)+intercept2;
figure(1)
plot(time, InputData,'k.-');hold on
plot(time, OutputData,'r.-');grid on
xlabel('time (s)')
ylabel('Voltage(v)')
end

function logData(src, evt, fid,slope1,intercept1,slope2,intercept2)
% Add the time stamp and the data values to data. To write data sequentially,
% transpose the matrix.
data = [evt.TimeStamps slope1*evt.Data(:,1)+intercept1 slope2*evt.Data(:,2)+intercept2] ;
fprintf(fid,'%f \t %f \n',data');
end

