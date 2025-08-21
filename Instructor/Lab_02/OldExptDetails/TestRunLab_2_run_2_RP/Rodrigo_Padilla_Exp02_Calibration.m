clear all
close all
clc

%% Start of user information
Fs = 20; %Sampling rate data per sec
T = 5; %Time to aquire data
filename = 'Cal_Data_01.dat'; %To store calibration data file
fid1 = fopen(filename,'w');
%% End of user required information 
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0],'Voltage');
s.Rate = Fs; %Sampling rate modify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event) disp(getReport(event.Error)));
drawnow
s.IsContinuous = true;
startBackground(s);
pause (T)
delete (s)
delete(lh1)
delete(lh2)
fclose(fid1)
data = readmatrix(filename);
avgVolt = mean(data(:,2));
gcf;
title(['Average voltage: ' sprintf('%3.4f',avgVolt) ' (v)'],'fontname','times','fontsize',14)

function plotAndLogData(src,event)
time = event.TimeStamps;
voltage = event.Data; %Potentiometer data in voltage 
figure(1)
plot(time, voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end

function logData(src, evt, fid)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data];
fprintf(fid,'%f \t %f \n', data');
end
