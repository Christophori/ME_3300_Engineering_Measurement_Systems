% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for calibration purpose it logs the data
% in a file for later use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 7th, 2020
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
Fs = 100; %Sampling rate data per sec
T = 15; %Time to aquire data
filename = '../Data/LM358Data.dat'; %To store calibration data file
fid1 = fopen(filename,'w');

plotTitle = 'Student''s Name plot - Experiment#6';
fprintf(fid1,'%s \t %s \t %s \n','times (s)','Input Voltage (v)','Output Voltage (v)');
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0 1],'Voltage');
s.Rate = Fs; % Sample rate modaify as required
s.DurationInSeconds = T; % Sampling time modify as required
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
title(plotTitle,'fontname','times','fontsize',14)
function plotAndLogData(src, event)
time = event.TimeStamps;
InputData = event.Data(:,1);
OutputData = event.Data(:,2);
figure(1)
plot(time, InputData,'k.-');hold on
plot(time, OutputData,'r.-')
xlabel('time (s)')
ylabel('Voltage (v)')
end

function logData(src,evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data(:,1) evt.Data(:,2)];
fprintf(fid,'%f \t %f \t %f \n', data');
end