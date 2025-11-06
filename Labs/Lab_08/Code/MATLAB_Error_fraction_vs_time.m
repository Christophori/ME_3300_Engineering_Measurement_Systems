clear all
close all
clc


%% User input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('../Data/TimeSeries_Temperature01.dat'); %Reading data from the stored file
istr = 1562; iend = 1647;% Index of T_0 and T_ss

%% End of user input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
line = fgetl(fid);
data = fscanf(fid,'%f,%f \n', [2 inf]);
time = data(1,istr:iend) - data(1,istr);
temperature = data(2,istr:iend);
fclose(fid);
Tss = 98.0; % Steady State value from thermometer
Y2 = log((temperature-Tss)./(temperature(1)-Tss)); %Error fraction operation
%% Performing Regression Analysis
[p,s] = polyfit (time,Y2,1); %curve fitting with 1st order fit
xfit = time;%Generating degree of freedom for the curve fit
yfit = polyval(p,xfit);

% Generating figure with specific size
figure (1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(time,Y2,'ro','markersize',4,'markerfacecolor','r');hold on
plot(xfit,yfit,'b-','linewidth',2);
xlim([0 0.06])
%ylim([0 10])
xlabel('\Gamma (Error fraction)')
ylabel('Time (s)')
legend('Curve fit','Expt. data','location','northeast')
text(0.01,-1.4,sprintf('%s%3.4f%s','\tau=',-1/p(1),'s'))
grid on
grid minor
title('Student''s Name Error Fraction plot')

%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Error_Fraction_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Error_Fraction_Plot.pdf",Resolution=600) % for canvas submission 