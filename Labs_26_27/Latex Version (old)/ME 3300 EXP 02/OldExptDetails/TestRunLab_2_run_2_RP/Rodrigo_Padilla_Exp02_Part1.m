clear all
close all
clc

%% User have to manually add information
x = [1.5044 1.6449 1.7960 1.9837 2.0805 2.3068 2.4392 2.5662 2.7249 2.8787]; %Voltage Data
y = [0 10 20 30  40 50 60 70 80 90]; %Angular Location of Pendulum
t_nuP= 2.262; %Value read from t-student's table
plotTitle = 'Rodrigo Padilla''s calibration Plot';
%% End of user information
[p,s] = polyfit (x,y,1); %curve fitting with 1st order fit
xfit = x;%Generating degree of freedom for the curve fit
yfit = polyval(p,xfit);
nu = s.df; %Getting degree of freedom for the curve fit 
norm = s.normr; %Getting the norm of the curve fitting
syx = norm/sqrt(nu);

%Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
%Plotting data
plot(xfit,yfit,'b-','linewidth',2);hold on
plot(x,y,'ro','markersize',9,'markerfacecolor','r')
xlabel('Volts (v)')
ylabel('Angle (^{o})')
%Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; %Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2], 'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','95% Cl range','location','Northwest')
title(plotTitle)
text(2.5,0,sprintf('y = %3.4fx %3.4f',p(1),p(2)),'Fontname','times')
text(2.5,-7,sprintf('Norm = %3.4fx',s.normr),'Fontname','times')
text(2.5,-14,sprintf('s_{yx} = %3.4f',syx),'Fontname','times')
%% Saving the files in png and pdf format
figName = ['Rodrigo_Padilla_Exp02_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'Papersize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')