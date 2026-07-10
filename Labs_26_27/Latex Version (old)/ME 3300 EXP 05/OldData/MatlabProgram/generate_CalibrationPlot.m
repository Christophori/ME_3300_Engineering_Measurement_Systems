% This is a genric program to generate calibration plot and provide slope
% and intercept data
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
% x = voltage from pressure sensor - voltage at zero flow rate
% y = flow rate from rotameter
% This is basic program to demonstrating use of polyfit command and
% calculating norm and standard error of fit.
% User has to provide apropriate information see - begining of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
%%%% USER HAVE TO MANUALLY ADD THIS INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 

x = [0    0.0272    0.0845    0.1249    0.1969    0.2524    0.3818    0.4889    0.6554 0.8015    1.0109    1.1408]; 
y = [0.0    1.0    1.6    2.0    2.6    3.0    3.6    4     4.6     5      5.6    6]; %Flowrate

x2 = sqrt(x);

t_nuP = 2.201; %Value read from t-student's table
plotTitle = 'Firstname Lastname''s plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(x2,y,1); % Curve fitting data with 1st order fit
xfit = x2;% Generating x-data for curve fitting
yfit = polyval(p,xfit);
nu = s.df; %Getting degree of freedom for the curve fit
norm = s.normr; % Getting the norm of the curve fitting
syx = norm/sqrt(nu);

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data(1st figure)
subplot(1,2,1)
plot(xfit,yfit,'b-','linewidth',2); hold on
plot(x2,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('$\sqrt{Volts}$ ($\sqrt{v}$)','interpreter','latex')
ylabel('Measured flowrate (scfm)')
xlim([0 1.1])
ylim([0 7])
grid on
% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; % Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2],'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','location','southeast')
%title(plotTitle)
text(0.2,6.0,sprintf('Q = %3.4f%s + %3.4f',p(1),'$\sqrt{V}$',p(2)),'Fontname','times','interpreter','latex')
text(0.2,5.5,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(0.2,5.0,sprintf('s_{yx} = %3.4f scfm',syx),'Fontname','times') 

subplot(1,2,2)
plot(x,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('Volts (v)')
ylabel('Measured Flowrate (scfm)')
ylim([0 7])
grid on
legend('Expt. data','location','southeast')


% % % Saving the files in png and pdf format
figName = ['Firstname_Lastname_Exp05_CalPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')
 
