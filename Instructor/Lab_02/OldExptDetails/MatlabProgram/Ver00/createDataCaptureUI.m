function hGui = createDataCaptureUI(s)
%CREATEDATACAPTUREUI Create a graphical user interface for data capture.
%   HGUI = CREATEDATACAPTUREUI(S) returns a structure of graphics
%   components handles (HGUI) and creates a graphical user interface, by
%   programmatically creating a figure and adding required graphics
%   components for visualization of data acquired from a DAQ session (S).

% Create a figure and configure a callback function (executes on window close)
hGui.Fig = figure('Name','Software-analog triggered data capture', ...
    'NumberTitle', 'off', 'Resize', 'off', 'Position', [100 100 750 650]);
set(hGui.Fig, 'DeleteFcn', {@endDAQ, s});
uiBackgroundColor = get(hGui.Fig, 'Color');

% Create the continuous data plot axes with legend
% (one line per acquisition channel)
hGui.Axes1 = axes;
hGui.LivePlot = plot(0, zeros(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Continuous data');
legend(get(s.Channels, 'ID'), 'Location', 'northwestoutside')
set(hGui.Axes1, 'Units', 'Pixels', 'Position',  [207 391 488 196]);

% Create the captured data plot axes (one line per acquisition channel)
hGui.Axes2 = axes('Units', 'Pixels', 'Position', [207 99 488 196]);
hGui.CapturePlot = plot(NaN, NaN(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Captured data');

% Create a stop acquisition button and configure a callback function
hGui.DAQButton = uicontrol('style', 'pushbutton', 'string', 'Stop DAQ',...
    'units', 'pixels', 'position', [65 394 81 38]);
set(hGui.DAQButton, 'callback', {@endDAQ, s});

% Create a data capture button and configure a callback function
hGui.CaptureButton = uicontrol('style', 'togglebutton', 'string', 'Capture',...
    'units', 'pixels', 'position', [65 99 81 38]);
set(hGui.CaptureButton, 'callback', {@startCapture, hGui});

% Create a status text field
hGui.StatusText = uicontrol('style', 'text', 'string', '',...
    'units', 'pixels', 'position', [67 28 225 24],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor);

% Create an editable text field for the captured data variable name
hGui.VarName = uicontrol('style', 'edit', 'string', 'mydata',...
    'units', 'pixels', 'position', [87 159 57 26]);
% Create an editable text field for the trigger channel
hGui.TrigChannel = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [89 258 56 24]);
% Create an editable text field for the trigger signal level
hGui.TrigLevel = uicontrol('style', 'edit', 'string', '1.0',...
    'units', 'pixels', 'position', [89 231 56 24]);
% Create an editable text field for the trigger signal slope
hGui.TrigSlope = uicontrol('style', 'edit', 'string', '200.0',...
    'units', 'pixels', 'position', [89 204 56 24]);
% Create text labels
hGui.txtTrigParam = uicontrol('Style', 'text', 'String', 'Trigger parameters', ...
    'Position', [39 290 114 18], 'BackgroundColor', uiBackgroundColor);
hGui.txtTrigChannel = uicontrol('Style', 'text', 'String', 'Channel', ...
    'Position', [37 261 43 15], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.txtTrigLevel = uicontrol('Style', 'text', 'String', 'Level (V)', ...
    'Position', [35 231 48 19], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.txtTrigSlope = uicontrol('Style', 'text', 'String', 'Slope (V/s)', ...
    'Position', [17 206 66 17], 'HorizontalAlignment', 'right', ...
    'BackgroundColor', uiBackgroundColor);
hGui.txtVarName = uicontrol('Style', 'text', 'String', 'Variable name', ...
    'Position', [35 152 44 34], 'BackgroundColor', uiBackgroundColor);

end

function startCapture(hObject, ~, hGui)
if get(hObject, 'value')
    % If button is pressed clear data capture plot
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii), 'XData', NaN, 'YData', NaN);
    end
end
end

function endDAQ(~, ~, s)
if isvalid(s)
    if s.IsRunning
        stop(s);
    end
end
end