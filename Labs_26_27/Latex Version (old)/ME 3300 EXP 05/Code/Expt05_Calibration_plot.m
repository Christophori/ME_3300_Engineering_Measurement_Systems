% This script is for calibration curve for expt#5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 6th, 2020
% Dr. Vibhav Durgesh
% Rev 0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
% x = (voltage from pressure sensor - voltage at zero flow rate)
% y = flow rate from rotameter
% x2 = sqrt(x);
% This is a basic program uses polyfit command and
% calculating norm and standard error of a fit.
% User has to provide appropriate information - see beginning of code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% User have to manually add information
x = [0 0.02826252 0.0349675 0.10053993 0.1154252  0.16358307 0.2024039 ...
     0.24217532   0.3954376 0.5412818  0.72738973 0.83078135 0.99368491 ...
     1.33439636]; %Voltage Data
y = [0 1.0 1.2 1.8 2.0 2.4 2.8 3.2 3.8 4.4 5.0 5.4 6.0 7.0]; %Flowrate
x2 = sqrt(x); % Cretaing new variable 

t_nuP= 2.160; %Value read from t-student's table
plotTitle = 'Firstname Lastname''s Plot';
%% Performing linear curve fit
[p,s] = polyfit (x2,y,1); % Curve fitting with 1st order fit
xfit = x2;% Generating degree of freedom for the curve fit
yfit = polyval(p,xfit);
nu = s.df; % Getting degree of freedom for the curve fit 
norm = s.normr; % Getting the norm of the curve fitting
syx = norm/sqrt(nu);

%% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 3.250 3.750],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');

%% First plot (1st figure)
subplot(1,2,1)
plot(xfit,yfit,'b-','linewidth',2);hold on
plot(x2,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('$\sqrt{Volts}$($\sqrt{v}$)','interpreter','latex')
ylabel('Measured flowrate (scfm)')
xlim([0 1.1])
ylim([0 9])
grid on
%% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; %Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2], 'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','location','Southeast')
title(plotTitle)

text(0.1,8.0,sprintf('Q = %3.4f%s + %3.4f',p(1),'$\sqrt{V}$',p(2)),'Fontname','times','interpreter','latex')
text(0.1,7.5,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(0.1,6.5,sprintf('s_{yx} = %3.4f',syx),'Fontname','times')

%% Next plot plot (figure 1)
subplot(1,2,2)
plot(x,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('Volts (v)')
ylabel('Measured flowrate (scfm)')

ylim([0 7])
grid on
legend('Expt. data','location','Southeast')
%% Saving the files in png and pdf format
figName = ['..\Figures\Student_Name_Exp05_CalPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'Papersize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')