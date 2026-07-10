% This is a genric program to generate calibration plot and provide slope
% and intercept data
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% This is basic program to demonstrating use of polyfit command and
% calculating norm and standard error of fit.
% User has to provide apropriate information see - begining of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
%%%% USER HAVE TO MANUALLY ADD THIS INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 

x = [.2461 1.0031]; % Voltage data
y = [25 99]; %Temperature from LIGT

plotTitle = 'FirstName LastName''s plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(x,y,1); % Curve fitting data with 1st order fit
xfit = x;% Generating x-data for curve fitting
yfit = polyval(p,xfit);


% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data(1st figure)
plot(xfit,yfit,'b-','linewidth',2); hold on
plot(x,y,'ro','markersize',9,'markerfacecolor','r')
xlabel('Voltage, V','interpreter','latex')
ylabel('Temperature ^{o}C')
xlim([0 1.1])
ylim([0 100])
grid on

legend('Curve fit','Expt. data','location','southeast')
%title(plotTitle)
text(0.2,80,sprintf('T = %3.4f%s + %3.4f',p(1),'V',p(2)),'Fontname','times')

% % % Saving the files in png and pdf format
figName = ['FirstName_LastName_CalibrationPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')
 
