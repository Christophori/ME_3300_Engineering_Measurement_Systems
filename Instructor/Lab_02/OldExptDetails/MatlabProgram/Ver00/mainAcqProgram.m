% This is a genric program to acquire the data from NI- 6001

clear all
close all
clc
fid1 = fopen('DataFile.dat','w+');
fprintf(fid1,'%s \t %s \n','Time(s)','Volt (v)');
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2', 'ai0', 'Voltage');
s.Rate = 100;
s.DurationInSeconds = 10;
lh = addlistener(s,'DataAvailable', @(src, event)plotData(src, event, fid1)); 
%lh2 = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1));
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

drawnow
startBackground(s);

pause

delete(s)
delete(lh)
delete(lh2)
fclose(fid1);