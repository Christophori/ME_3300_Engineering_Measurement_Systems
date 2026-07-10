clear all
close all
clc

%% User have to manually add information
x = [0 0.01711475 0.02665734 0.06077683 0.12348476 0.19786824 0.29432843 0.42161687 0.65160562 1.11312439 1.35023453 1.77559718]; %Voltage Data
y = [0 0.5 1.0 1.4 2.0 2.6 3.2 3.8 4.8 6.0 6.8 8.0]; %Flowrate
x2 = sqrt(x)

t_nuP= 2.262; %Value read from t-student's table
plotTitle = 'Rodrigo Padilla''s Plot';
%% End of user information
[p,s] = polyfit (x2,y,1); %curve fitting with 1st order fit
xfit = x2;%Generating degree of freedom for the curve fit
yfit = polyval(p,xfit);
nu = s.df; %Getting degree of freedom for the curve fit 
norm = s.normr; %Getting the norm of the curve fitting
syx = norm/sqrt(nu);

%Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');

%Plotting data(1st figure)
subplot(1,2,1)
plot(xfit,yfit,'b-','linewidth',2);hold on
plot(x2,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('$\sqrt{Volts}$($\sqrt{v}$)','interpreter','latex')
ylabel('Measured flowrate (scfm)')
xlim([0 1.1])
ylim([0 7])
grid on
%Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; %Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2], 'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','location','Southeast')

text(0.1,6.0,sprintf('Q = %3.4f%s + %3.4f',p(1),'$\sqrt{V}$',p(2)),'Fontname','times','interpreter','latex')
text(0.1,5.5,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(0.1,5.0,sprintf('s_{yx} = %3.4f',syx),'Fontname','times')

subplot(1,2,2)
plot(x,y,'ro','markersize',6,'markerfacecolor','r')
xlabel('Volts (v)')
ylabel('Measured flowrate (scfm)')

ylim([0 7])
grid on
legend('Expt. data','location','Southeast')
%% Saving the files in png and pdf format
figName = ['Rodrigo_Padilla_Exp05_CalPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'Papersize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')