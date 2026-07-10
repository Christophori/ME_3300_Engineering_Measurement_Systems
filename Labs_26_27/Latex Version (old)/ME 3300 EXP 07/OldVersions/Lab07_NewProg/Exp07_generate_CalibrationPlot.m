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

mass = [0 0.4 0.4 0.6 0.6 0.8 0.8 1 1 1.2 1.2 1.4 1.4 1.6 1.6 1.8 1.8 2 2]; %Change to appropriate weight for experiment
unloadedweight = [2.1240 2.1264 2.1267 2.1277 2.1293 2.1299 2.1282 2.1291 2.1301 2.1305 2.1328 2.1330 2.1341 2.1341 2.1340 2.1341 2.1356 2.1347 2.1344];%Change to appropriate readout from DMM
loadedweight = [2.1240 2.2714 2.2714 2.3467 2.3467 2.4206 2.4206 2.4929 2.4929 2.5670 2.5670 2.6422 2.6422 2.7149 2.7149 2.7877 2.7877 2.8625 2.8625]; % Change to appropriate readout from DMM
L = 36/100; % length of beam using a tape measure
w = 1.499*(2.54/100); %width of the beam using a caliper
t = 0.2515*(2.54/100); %thickness of the beam using a micrometer
g = 9.8051; % gravitational constant (m/s)
GF = 2.012; % Gain Factor
G = 497.7538855; % gain using Rg = 101.66 ohm
Vi = 10; %Excitation Voltage

m = mass; % mass (kg)
dvo = abs(loadedweight-unloadedweight); %difference in voltage
%% Calculating Stress
stress = ((6*m*g*L)/(w*t^2))/(10^9); %Stress(MPa)

%% Calculating Strain
strain = (2*dvo)/(Vi*G*GF); %strain (unitless)

t_nuP = 2.110; %Value read from t-student's table (19 data points)
plotTitle = 'Paulo Yu''s plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(strain,stress,1); % Curve fitting data with 1st order fit
xfit = strain;% Generating x-data for curve fitting
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
plot(strain,stress,'ro','markersize',9,'markerfacecolor','r')
xlabel('\epsilon, strain')
ylabel('\sigma, GPa')
grid on
% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; % Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2],'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','95% CL range','location','Northwest')
title(plotTitle)
text(1e-4,0.01,sprintf('%s = %3.4f%s+%3.4f','\sigma',p(1),'\epsilon',p(2)),'Fontname','times')
text(1e-4,0.005,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(1e-4,0,sprintf('s_{yx} = %3.8f%s',syx,'GPa'),'Fontname','times') 
% % Saving the files in png and pdf format
figName = ['Paulo_Yu_Exp07_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')
% 
