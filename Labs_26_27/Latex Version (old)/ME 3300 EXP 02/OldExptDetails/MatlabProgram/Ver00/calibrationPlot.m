% This script performs the calibration for the pendulum experiment.
% ----- LIST OF VARIABLES -------
% theta = Pendulum angle in degrees
% avgV  = Average voltage output for calibration in volts
% ----- VER 0.0 -----------------
% Date 25th July 2019

clear all
close all
clc

theta = [-90 -70 -50 -30 -10 0 10 30 50 70 90];
avgVolt = [1.21 1.43 1.65 2.00 2.31 2.50 2.55 2.82 3.20 3.51 3.74];

[p s] = polyfit(avgVolt,theta,1);

xfit = avgVolt;
yfit = p(1)*xfit + p(2);

figure(1);
set(gcf,'unit','inches','position',[0.50 0.50 6.50 4.50],'defaultaxesfontname','times','defaultaxesfontsize',12);
plot(avgVolt, theta,'ko','markersize',6,'markerfacecolor','k');
hold on;
plot(xfit,yfit,'r-','linewidth',2)
% Now printing text at desired location for my equations and other
% parameters
xlabel('Output voltage (v)')
ylabel('Angular position (^o)')
txt1 = sprintf('%s= %3.4fx %3.4f','y',p(1),p(2)); % Linear curve fit equation
txt2 = sprintf('%s= %3.4f','norm',s.normr); % Norm of the fit
txt3 = sprintf('%s= %3.4f','s_{yx}', s.normr/sqrt(s.df)); % Standard error of fit
text(3,-40, txt1,'fontsize',12,'fontname','times')
text(3,-52, txt2,'fontsize',12,'fontname','times')
text(3,-64, txt3,'fontsize',12,'fontname','times')
legend('Experimental data','Curve fit','location','northwest')

title('Dr. Vibhav Durgesh''s calibration plot')
% Saving the files in png and pdf format with 600 dpi
figName = ['FirstName_LastName_Expt02_Calibration'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf, 'PaperUnits', 'inches', 'Units', 'inches');
figpos = get(gcf, 'Position');
set(gcf, 'PaperSize', figpos(3:4), 'Units', 'inches');
print(figName,'-dpdf','-r600')
