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
x = [2.3944 2.4554 2.6941 2.8042 2.9650 3.0667 3.1868 3.4169 3.4862 3.6748]; % Voltage data
y = [0 10 20 30 40 50 60 70 80 90]; % Angular location of pendulum
t_nuP = 2.262; %Value read from t-student's table
plotTitle = 'Dr. Vibhav Durgesh''s calibration plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(x,y,1) % Curve fitting data with 1st order fit
xfit = x;% Generating x-data for curve fitting
yfit = polyval(p,xfit);
nu = s.df; %Getting degree of freedom for the curve fit
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
ylabel('Angle (^{o})')
grid on
% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; % Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2],'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','95% CL range','location','Northwest')
title(plotTitle)
text(3.3,0,sprintf('y = %3.4fx  %3.4f',p(1),p(2)),'Fontname','times')
text(3.3,-7,sprintf('Norm = %3.4fx',s.normr),'Fontname','times')
text(3.3,-14,sprintf('s_{yx} = %3.4f',syx),'Fontname','times') 
% % Saving the files in png and pdf format
figName = ['Vibahv_Durgesh_Exp02_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')
% 
