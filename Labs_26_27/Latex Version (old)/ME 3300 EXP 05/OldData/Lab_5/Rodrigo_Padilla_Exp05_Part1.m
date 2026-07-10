clear all
close all
clc

%% Start of user information
Fs = 1000; %Sampling rate data per sec
T = 7; %Time to aquire data
filename ='TimeSeriesFlowRate_VoltageData2.dat'; %To store calibration data file  
fid1 = fopen(filename,'w');
slope = 5.9542; %Add your calibration slope for pressure transducer
intercept = -0.0748; %Add you calibration intercept for pressure transducer
v0 = 2.50856838; %Voltage output from sensor at sensor at zero flow rate
fprintf(fid1,'%s \t %s \t %s \n','time (s)','Voltage output','Flowrate (scfm)');
%% End of user information
d = daq.getDevices;
s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1',[0],'Voltage');
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

% data = readmatrix(filename);
% avgVolt = mean(data(:,3));
% gcf;
% title(['Average voltage: ' sprintf('%3.8f',avgVolt) ' (v)'],'fontname','times','fontsize',14)

function plotAndLogData(src,event,slope,intercept,v0)
time = event.TimeStamps;
flowrate = (slope*(sqrt(event.Data-v0)))+intercept; %flowrate
figure(1)
plot(time, flowrate,'k.-');hold on
xlabel('time (s)')
ylabel('Flowrate (scfm)')
end

function logData(src, evt, fid1,slope,intercept,v0)
%Add the time stamp and the data values to data. To write data sequentially
%transpose the matrix
data = [evt.TimeStamps evt.Data (slope*(sqrt(evt.Data-v0)))+intercept];
fprintf(fid1,'%f \t %f \t %f \n', data');
end
