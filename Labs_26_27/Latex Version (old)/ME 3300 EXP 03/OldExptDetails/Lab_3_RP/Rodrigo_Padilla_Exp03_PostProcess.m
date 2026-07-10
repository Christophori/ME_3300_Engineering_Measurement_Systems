% Sample program to process your data for post-lab
%%%%%%%%%%%%%%%%%%%%%% Make sure to modify as required %%%%%%%%%%%%%%%%%%%%
close all
clear all
clc

%% Prefined Parameters
r = 0.2159; %Length of the pendulum (m)
g = -9.81; %Constant gravity (m/s^2)
%% Start user required information
fid = fopen('Expt_03_Rodrigo_Padilla.dat');
linel = fgetl(fid);
data = fscanf(fid, '%f \n', [3 inf]);
x = data(1,:);
y1 = data(2,:);
y2 = data(3,:);
fclose(fid);

rad = y1*pi/180; %turn the read degree values to radians
theta_d =  diff(rad)./ diff(x); %rad/s

acc_1 =  - (theta_d.^2) * r; %calculated acceleration m/s^2
acc_2 = y2 - (g*cos(rad)); %gravity reduction


%% End user required information

figure (1)
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
plot(x(1:end-1),acc_1,'-bo','markersize',3);hold on
plot(x,acc_2,'ro','markersize',3,'markerfacecolor','r');
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')
grid on

ylim([-70 10])
xlim([0 15])

legend('Calculated from angular position','Accelerometer data','location','Southeast')
title('Firstname Lastname''s plot')

figName = ('Firstname_Lastname_Expt02_Postprocess');
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf, 'Position');
set(gcf, 'PaperSize', figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600') 