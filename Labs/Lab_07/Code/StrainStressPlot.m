% This is a program to generate strain-stress plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 09/02/2025
% Author: Rodrigo Padilla
% Decription:
% This is basic program to demonstrating use of polyfit command and
% calculating norm and standard error of fit.
% User has to provide apropriate information see - begining of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE OVERWRITES THE DATA. PLEASE MOVE THE FILES OR RENAME PRIOR TO
% RERUNNING THE CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% USER HAVE TO MANUALLY ADD THIS INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
mass = [0.0 1.0 1.2 1.3 1.4 1.5 1.6 1.7 1.8 2.0]; %Change to appropriate weight 
Gdvo_avg = [0 0 0 0 0 0 0 0 0 0]; % Average voltage output
L = 0/100; % length of beam using a tape measure
w = 0*(2.54/100); %width of the beam using a caliper
t = 0*(2.54/100); %thickness of the beam using a micrometer
g = 10; % gravitational constant (m/s)
GF = 2.012; % Gauge Factor
G = 500; % gain using Rg = 101.66 ohm
Vi = 5; %Excitation Voltage to the wheatstone bridge circuit

m = mass; % mass (kg)

%% Calculating Stress
stressdata = ((6*m*g*L)/(w*t^2))/(10^9); %Stress(MPa)

%% Calculating Strain
straindata = (2*Gdvo_avg)/(Vi*G*GF); %strain (unitless)

t_nuP = 2.110; %Value read from t-student's table (19 data points)
plotTitle = 'First Name Last Name''s plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(straindata,stressdata,1); % Curve fitting data with 1st order fit
xfit = straindata;% Generating x-data for curve fitting
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
plot(straindata,stressdata,'ro','markersize',9,'markerfacecolor','r')
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
text(5e-5,0.01,sprintf('%s = %3.4f%s+%3.4f','\sigma',p(1),'\epsilon',p(2)),'Fontname','times')
text(5e-5,0.005,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(5e-5,0,sprintf('s_{yx} = %3.8f%s',syx,'GPa'),'Fontname','times') 

% % Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Stress_Strain_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Stress_Strain_Plot.pdf",Resolution=600) % for canvas submission  
