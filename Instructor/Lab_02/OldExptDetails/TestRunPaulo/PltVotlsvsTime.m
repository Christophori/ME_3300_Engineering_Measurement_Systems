clear all
close all
clc

fid = fopen('AngVsTime.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
x = data(1,:);
y = data(2,:);
fclose(fid);


%G Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(x,y,'ro--','markersize',3,'markerfacecolor','r');hold on
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
legend('Expt. data','location','Southeast')
title('YourName''s plot')