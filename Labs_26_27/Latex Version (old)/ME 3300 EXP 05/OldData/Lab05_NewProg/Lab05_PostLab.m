% This is a genric program to plot post-lab data for experiment-5
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% This is basic program please modify as required
% User has to provide apropriate information see - begining of the code
clear all
close all
clc
fname = 'TimeSeriesFlowRate_VoltageData2.dat'; % File name where data is stored
fid = fopen(fname,'r'); % Opening file to read the data
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time = data(1,:);
voltage = data(2,:)-2.5534; % Subratcting zero voltage data - see instruction
flowrate = 5.5759*voltage+0.0668; % Use calibration to get SCFM data
fclose(fid);

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
yyaxis left
plot(time(2500:5000),voltage(2500:5000),'ro-','markersize',1,'markerfacecolor','r');hold on
xlim([2.5 5])
ylim([0 0.5])
ylabel('Voltage (v)')
yyaxis right
plot(time(2500:5000),flowrate(2500:5000),'bo-','markersize',1,'markerfacecolor','b');hold on
xlim([2.5 5])
ylim([0 2.5])
xlabel('time (s)')
ylabel('Calibrated flowrate (scfm)')
grid on
% ylim([-3 9])
legend('Voltage Data','Calibrated Flowrate Data','location','Southeast')
title('Firstname Lastname''s plot')

% % % Saving the files in png and pdf format
figName = ['Firstname_Lastname_Exp05_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')