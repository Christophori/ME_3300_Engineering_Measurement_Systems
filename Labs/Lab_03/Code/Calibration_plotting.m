% This is a generic program to generate calibration plot and provide slope
% and intercept data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 09/02/2025
% Author: Dr. Christopher Bitikofer
% Decription:
% This code and it's supporting functions can be configured to collect data
% using the NI-MyDAQ.
% The user must provide appropriate information - see beginning of code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE OVERWRITES THE DATA. PLEASE MOVE THE FILES OR RENAME PRIOR TO
% RERUNNING THE CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% User have to manually add information
x = [1.7107 1.9208 1.7166 1.5067]; %Voltage Data
y = [0 -9.81 0 9.81]; % Acceleration
t_nuP= 0; % Value read from t-student's table
plotTitle = 'Student''s Name Calibration Plot';

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
plot(xfit,yfit,'b-','linewidth',2);hold on
scatter(x,y,90,'ro','filled')
xlabel('Volts (v)')
ylabel('Acceleration (m/s^{2})')
% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; % Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2], 'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);
grid on
grid minor

legend('Curve fit','Expt. data','95% Cl range','location','Northeast')
title(plotTitle)
text(1.55,-5,sprintf('y = %3.4fx + %3.4f',p(1),p(2)),'Fontname','times')
text(1.55,-7,sprintf('Norm = %3.4fx',s.normr),'Fontname','times')
text(1.55,-9,sprintf('s_{yx} = %3.4f',syx),'Fontname','times')

%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\Student_Name_Exp03_Calibration.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\Student_Name_Exp03_Calibration.pdf",Resolution=600) % for canvas submission 
