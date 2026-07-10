clear all
close all
clc

%% Start of user information
Fs = 1000; %Sampling rate data per sec
T = 15; %Time to aquire data
filename = 'Expt_03_Rodrigo_Padilla.dat'; %To store calibration data file
fid1 = fopen(filename,'w');

slope1 = 68.1545; %Add your calibration slope for potentiometer
intercept1 = -105.6592; %Add you calibration intercept for potentioment

slope2 = -45.8882; %Add your calibration slope for accelerometer
intercept2 = 78.0708; %Add you calibration intercept for accelerometer

plotTitle = 'Rodrigo Padilla''s plot - Experiment#3';
fprintf(fid1,'%s \t %s \t %s \n','times (s)','Angular position (degrees)','Accerleration (m/s^{2})')
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0, 1],'Voltage');
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

function logData(src,evt, fid,m1,c1,m2,c2)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m1*evt.Data(:,1)+c1 m2*evt.Data(:,1)+c2];
fprintf(fid,'%f \t %f \t %f \n', data');
end