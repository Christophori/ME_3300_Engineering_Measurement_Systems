clear all
close all
clc

%% Start of user information
Fs = 200; %Sampling rate data per sec
T = 15; %Time to aquire data
filename = 'Data_Rodrigo_Padilla_Expt_2.dat'; %To store calibration data file
fid1 = fopen(filename,'w');
slope = 64.9046; %Add your calibration slope for potentiometer
intercept = -97.3054; %Add you calibration intercept for potentioment
plotTitle = 'Rodrigo Padilla''s plot - Experiment#2';
fprintf(fid1,'%s \t %s \n','times (s)','Angular position (degrees)')
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0],'Voltage');
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh1 = addlistener(s,'DataAvailable',@(src, event)plotAndLogData(src, event,slope,intercept));
lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event,fid1,slope,intercept));
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
function plotAndLogData(src,event,m,c)
time = event.TimeStamps;
angularPosition =  m*event.Data + c; %Potentiometer data in voltage
figure(1)
plot(time, angularPosition,'k.-');hold on
xlabel('time (s)')
ylabel('Angular position (degrees)')
end

function logData(src,evt, fid,m,c)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps m*evt.Data+c];
fprintf(fid,'%f \t %f \n', data');
end