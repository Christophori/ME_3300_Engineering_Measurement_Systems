% This is a generic program to aquire the data from myDAQ
% Sample data acquisition program for calibration purpose it logs the data
% in a file for later use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% Start of user information
Fs = 1000; %Sampling rate data per sec
T = 15; %Time to aquire data
filename = '../Data/Student_Name_Expt_03.dat'; %To file to store data
fid1 = fopen(filename,'w');

slope1 = -73.915; %Add your calibration slope for potentiometer
intercept1 = 190.4438; %Add you calibration intercept for potentioment

slope2 = -47.4958; %Add your calibration slope for accelerometer
intercept2 = 80.5470; %Add you calibration intercept for accelerometer

plotTitle = 'Student''s Name Plot - Experiment#3';
fprintf(fid1,'%s \t %s \t %s \n','times (s)','Angular position (degrees)','Accerleration (m/s^{2})'); % Header for the output file
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'myDAQ1',[0 1],'Voltage'); % Channel-1 is pot and #2 is accelerometer
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event,slope1,intercept1,slope2,intercept2));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1,slope1,intercept1,slope2,intercept2));
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

%% Function to plot the data during acquistion
function plotAndLogData(src, event, m1, c1, m2, c2)
time = event.TimeStamps;
angularPosition =  m1*event.Data(:,1) + c1; %Potentiometer data in voltage
acc = m2*event.Data(:,2) + c2; %Accerlerameter
figure(1)
plot(time, angularPosition,'k.-');hold on
plot(time, acc,'b.-')
xlabel('time (s)')
ylabel('Angular position (degrees)/ Accerleration (m/s^2)')
end

%% Function for storing the data in physical variables - 3 columns time, angle, accelrometer
function logData(src,evt, fid,m1,c1,m2,c2)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m1*evt.Data(:,1)+c1 m2*evt.Data(:,2)+c2];
fprintf(fid,'%f \t %f \t %f \n', data');
end