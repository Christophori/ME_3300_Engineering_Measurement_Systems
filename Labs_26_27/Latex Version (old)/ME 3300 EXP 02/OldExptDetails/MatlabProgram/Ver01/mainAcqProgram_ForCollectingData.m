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
Fs = 500; %Sampling rate Data per sec
T  = 10; % Time to acquire data
filename = 'Data_Vibhav_Durgesh_Expt_2.dat'; % To store experiment data
fid1 = fopen(filename,'w');
slope = 1; % Add your calibration slope for potentiometer
intercept = 0; % Add your calibration intercept for potentioment
plotTitle = 'Dr. Vibhav Durgesh''s plot - Experiment#2';
fprintf(fid1,'%s \t %s \n','time (s)', 'Angular position (degrees)')
%% --------END USER REQUIRED INFORMATION ----------%%%%%%%%%%%%%%%%%%%%%%%%
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2', [0], 'Voltage');
s.Rate = Fs; % Sampling rate modify as required
s.DurationInSeconds = T; % Sampling time modify as required
lh1 = addlistener(s,'DataAvailable', @(src, event)plotAndLogData(src, event,slope,intercept));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1, slope, intercept));
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
function plotAndLogData(src,event,m,c)
time = event.TimeStamps;
angularPosition = m*event.Data +c; %Potentiometer data in voltage
figure(1)
plot(time, angularPosition,'k.-');hold on
xlabel('time (s)')
ylabel('Angular position (degrees)')
end

function logData(src, evt, fid,m,c)
% Add the time stamp and the data values to data. To write data sequentially,
% transpose the matrix.
data = [evt.TimeStamps m*(evt.Data)+c] ;
fprintf(fid,'%f \t %f \n',data');
end