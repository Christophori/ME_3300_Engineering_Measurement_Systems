% This is a genric program to acquire the data from NI- 6001
%% Sample data acquistion program for collecting the data for OP-AMP circuit
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
Fs = 200; %Sampling rate Data per sec
T  = 5; % Time to acquire data
filename = '..\Data\AD622Data.dat'; % To store experiment data %% Change this name to appropriate chip
fid1 = fopen(filename,'w');

plotTitle = 'Firstname Lastname''s plot - Experiment#6';
fprintf(fid1,'%s \t %s \t %s\n','time (s)', 'Output Voltage(v)','Input Voltage(v)');
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
ch = addAnalogInputChannel(s,'MyDAQ1', [0 1], 'Voltage'); % Acquiring data on 2 channels
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required

addAnalogOutputChannel(s,'MyDAQ1',0,'Voltage');
s.Rate = Fs;
outputSignal1 = linspace(0,5,Fs*T)';
queueOutputData(s,outputSignal1);

lh1 = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1));
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
drawnow
startForeground(s);
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
title(plotTitle,'fontname','times','fontsize',14)

function plotAndLogData(src,event)
time = event.TimeStamps;
InputData = event.Data(:,1); 
OutputData = event.Data(:,2);
figure(1)
plot(time, InputData,'k-');hold on
plot(time, OutputData,'r-');
xlabel('time (s)')
ylabel('Voltage(v)')
legend('Input volt','Output volt','location','northwest')
grid on
end

function logData(src, evt, fid)
% Add the time stamp and the data values to data. To write data sequentially,
% transpose the matrix.
data = [evt.TimeStamps evt.Data(:,1) evt.Data(:,2)] ;
fprintf(fid,'%3.8f \t %3.8f \t %3.8f \n',data');
end