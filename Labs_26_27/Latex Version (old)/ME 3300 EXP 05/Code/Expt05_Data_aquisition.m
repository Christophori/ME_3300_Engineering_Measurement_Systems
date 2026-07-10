% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for calibration purpose it logs the data
% in a file for later use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 6th, 2020
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
Fs = 1000; % Sampling rate data per sec
T = 7; % Time to aquire data
filename ='../Data/TimeSeriesFlowRate_VoltageData2.dat'; % To store calibration data file  
fid1 = fopen(filename,'w');
slope = 5.9848; % Add your calibration slope for pressure transducer
intercept = 0.0200; % Add you calibration intercept for pressure transducer
v0 = 2.35068885; % Voltage output from sensor at sensor at zero flow rate
fprintf(fid1,'%s \t %s \t %s \n','time (s)','Voltage output','Flowrate (scfm)');
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0],'Voltage'); % Check the device name and channel number
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event,slope,intercept,v0));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1,slope,intercept,v0));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
%% Reading data from the stored file to calcualte average
data = readmatrix(filename);
avgVolt = mean(data(:,3));
gcf;
title(['Average Flowrate: ' sprintf('%3.8f',avgVolt) ' (scfm)'],'fontname','times','fontsize',14)

%% Function to plot and log the data
function plotAndLogData(src,event,slope,intercept,v0)
time = event.TimeStamps;
flowrate = (slope*(sqrt(abs(event.Data-v0))))+intercept; %flowrate
figure(1)
plot(time, flowrate,'k.-');hold on
xlabel('time (s)')
ylabel('Flowrate (scfm)')
end

%% Function to log the data in a file
function logData(src, evt, fid1,slope,intercept,v0)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data (slope*(sqrt(abs(evt.Data-v0))))+intercept];
fprintf(fid1,'%f \t %f \t %f \n', data');
end
