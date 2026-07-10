function softwareAnalogTriggerCapture
%softwareAnalogTriggerCapture DAQ data capture using software-analog triggering
%   softwareAnalogTriggerCapture launches a user interface for live DAQ data
%   visualization and interactive data capture based on a software analog
%   trigger condition.

% Configure data acquisition session and add analog input channels
s = daq.createSession('ni');
ch1 = addAnalogInputChannel(s, 'Dev2', 0, 'Voltage');
ch2 = addAnalogInputChannel(s, 'Dev2', 1, 'Voltage');

% Set acquisition configuration for each channel
ch1.TerminalConfig = 'SingleEnded';
ch2.TerminalConfig = 'SingleEnded';
ch1.Range = [-10.0 10.0];
ch2.Range = [-10.0 10.0];

% Set acquisition rate, in scans/second
s.Rate = 10000;

% Specify the desired parameters for data capture and live plotting.
% The data capture parameters are grouped in a structure data type,
% as this makes it simpler to pass them as a function argument.

% Specify triggered capture timespan, in seconds
capture.TimeSpan = 0.45;

% Specify continuous data plot timespan, in seconds
capture.plotTimeSpan = 0.5;

% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
% Determine required buffer timespan, seconds
capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan * 3, callbackTimeSpan * 3]);
% Determine data buffer size
capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);

% Display graphical user interface
hGui = createDataCaptureUI(s);

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
dataListener = addlistener(s, 'DataAvailable', @(src,event) dataCapture(src, event, capture, hGui));

% Add a listener for acquisition error events which might occur during background acquisition
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

% Start continuous background data acquisition
s.IsContinuous = true;
startBackground(s);

% Wait until session s is stopped from the UI
while s.IsRunning
    pause(0.5);
end

delete(dataListener);
delete(errorListener);
delete(s);
end