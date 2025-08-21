clear all
close all
clc
%% Start user required information
Fs = 200; %Sampling rate data per sec
T = 10; %Time to aquire data
%% End user required information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0],'Voltage');
s.Rate = Fs; %Sample rate modaify as required
s.DurationInSeconds = T; %Sampling time modify as required
lh = addlistener(s,'DataAvailable',@(src,event)plotAndLogData(src,event));
errorListener = addlistener(s, 'ErrorOccurred',@(src, event)plotAndLogData(src, event));
drawnow
s.IsContinuous = true;
startBackground(s);
pause(T)
delete(s)
delete(lh)

function plotAndLogData(src, event)
time = event.TimeStamps; 
voltage = event.Data;%Potentiometer data in voltage
figure (1)
plot(time,voltage,'k.-');hold on
xlabel('time (s)')
ylabel('Voltage (v)')
end