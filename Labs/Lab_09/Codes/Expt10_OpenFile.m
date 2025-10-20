clear all
close all
clc

fid = fopen('../Data/10mHz.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [3 inf]);
time = data(1,:);
inputdata = -data(3,:);
outputdata = -data(2,:);
fclose(fid);

A = max(inputdata)- min(inputdata)
B = max(outputdata)- min(outputdata)

fid1 = fopen('../Data/2nd/10mHz.dat','w')
fprintf(fid1,'%s \t %s \t %s \n','time (s)', 'Input Voltage(v)','Output Voltage(v)');
fprintf(fid1,'%f \t %f \t %f \n',data);
fclose(fid1)

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(time,inputdata,'ro','markersize',3,'markerfacecolor','r');hold on
plot(time,outputdata,'bs','markersize',3,'markerfacecolor','b');hold on
% xlim([-0.25 0.85])
% ylim([15 100])
ylabel('Voltage (V)')
xlabel('Time (s)')
grid on
grid minor
legend('Input','Output','location','Southeast')
title('Student''s Name plot')



