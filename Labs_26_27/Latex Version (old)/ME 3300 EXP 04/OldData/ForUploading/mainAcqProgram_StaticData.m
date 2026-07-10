% This is a genric program to acquire the data from NI- 6001
%% Sample data acquistion program acquire the data for a singal channel 
% and show the average of 500 data points.
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

%% ------ USER INPUT REQUIRED ---------%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sampling rate aata per sec and Time to acquire data
% Please use the correct variable names
% Set the sampling rate to 100 Hz and sampling time to 5 second

%% ---------------------------------------------------------------
filename = 'StaticSignal_5V.dat'; % Change the file name to store the data
fid1 = fopen(filename,'w');
%% -------------------------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
%% ------ USER INPUT REQUIRED ---------%%%%%%%%%%%%%%%%%%%%%%%%
% Set the correct channel number and device name
addAnalogInputChannel(s,'Dev1', [], 'Voltage');
%% ------------------------------------------------------------
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
lh1 = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1));
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh1)
delete(lh2)
fclose(fid1)
data = readmatrix(filename);
avgVolt = mean(data(:,2)); 
gcf;
title(['Average voltage: ' sprintf('%3.8f',avgVolt) ' (v)'],'fontname','times','fontsize',14)

function plotAndLogData(src,event)
time = event.TimeStamps;
voltage = event.Data; %Potentiometer data in voltage
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end

function logData(src, evt, fid)
% Add the time stamp and the data values to data. To write data sequentially,
% transpose the matrix.
data = [evt.TimeStamps evt.Data] ;
fprintf(fid,'%f \t %f \n',data');
end