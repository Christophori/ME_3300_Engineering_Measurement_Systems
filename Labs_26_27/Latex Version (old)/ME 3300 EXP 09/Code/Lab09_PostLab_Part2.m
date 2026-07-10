clear all
close all
clc

fid = fopen('../Data/TimeSeries_Temperature_02.dat'); istr = 1697;iend = 1900;
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time1 = data(1,istr:iend) - data(1,istr);
temperature1 = data(2,istr:iend);
fclose(fid);
Tss = 97.6; % steady state value from thermo meter
Y2 = log((temperature1-Tss)./(temperature1(1) - Tss)); % Error fraction operation
%% Performing Regression Analysis
[p,s] = polyfit(time1,Y2,1); % Curve fitting data with 1st order fit
xfit = time1;% Generating x-data for curve fitting
yfit = polyval(p,xfit);

nu = s.df; % Getting degree of freedom for the curve fit 
norm = s.normr; % Getting the norm of the curve fitting
syx = norm/sqrt(nu);
den = (time1-mean(time1)).^2;
sa1 = syx*sqrt(1/(sum(den)))
p_in_slope = 1.96*sa1/sqrt(nu+2) 
%% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
plot(time1,Y2,'ro','markersize',4,'markerfacecolor','r');hold on
plot(xfit,yfit,'b-','linewidth',2); 
legend('Curve fit','Expt. data','location','northeast')
text(0.02,-3,sprintf('%s%3.4f%s','\tau =',-1/p(1),'s'))
title('FirstName LastName''s Temperature plot')
ylabel('\Gamma (Error fraction)')
xlabel('Time (s)')
xlim([0 0.2])
grid on
grid minor

% % % Saving the files in png and pdf format
figName = ['..\Figures\PostLabPlot_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')