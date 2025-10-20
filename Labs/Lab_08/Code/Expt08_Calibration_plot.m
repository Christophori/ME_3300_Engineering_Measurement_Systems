% This is a genric program to generate calibration plot and provide slope
% and intercept data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: August 9th, 2020
% Dr. Vibhav Durgesh
% Rev 0.0
% This is a basic program to demonstrating use of poly fit command and 
% calculating norm and standard error fit.
% User has to provide apropriate information see - begining of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% User have to manually add information
x = [0.2036 0.9748]; %Voltage Data
y = [24 98]; %Temperature from LIGT

t_nuP= 2.262; %Value read from t-student's table
plotTitle = 'Student''s Name Plot';
%% End of user information
[p,s] = polyfit (x,y,1); % Curve fitting with 1st order fit
xfit = x;% Generating degree of freedom for the curve fit
yfit = polyval(p,xfit);
nu = s.df; % Getting degree of freedom for the curve fit 
norm = s.normr; % Getting the norm of the curve fitting
syx = norm/sqrt(nu);

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');

% Plotting data
plot(xfit,yfit,'b-','linewidth',2); hold on
plot(x,y,'ro','markersize',9,'markerfacecolor','r')
xlabel('Volts (v)')
ylabel('Temperature ^{o}C')
xlim([0 1.1])
ylim([0 100])
grid on

legend('Curve fit','Expt. data','location','Southeast')
text(0.2, 80,sprintf('T=%3.4f%s + %3.4f', p(1),'V',p(2)),'Fontname','times')

%% Saving the files in png and pdf format
figName = ['../Figures/Student_Name_Exp05_CalPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'Papersize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')