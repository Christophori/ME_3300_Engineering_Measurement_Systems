clear all
close all
clc

fid = fopen('TimeSeries_Temperature_01.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time1 = data(1,:)-1.695;
temperature1 = data(2,:);
fclose(fid);

fid = fopen('TimeSeries_Temperature_02.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time2 = data(1,:)-1.544;
temperature2 = data(2,:);
fclose(fid);

fid = fopen('TimeSeries_Temperature_03.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time3 = data(1,:)-1.155;
temperature3 = data(2,:);
fclose(fid);


% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(time1,temperature1,'ro','markersize',3,'markerfacecolor','r');hold on
plot(time2,temperature2,'bd','markersize',3,'markerfacecolor','b')
plot(time3,temperature3,'ks','markersize',3,'markerfacecolor','k')
xlim([-0.15 0.6])
ylim([15 100])
ylabel('Temperature (^{o}C)')
xlabel('Time (s)')
grid on
legend('Run01','Run02','Run03','location','Southeast')
title('FirstName LastName''s Temperature plot')
text(0.3,70,'\tau_{1} = 0.041 s','fontname','times')
text(0.3,65,'\tau_{2} = 0.051 s','fontname','times')
text(0.3,60,'\tau_{3} = 0.029 s','fontname','times')
% % % Saving the files in png and pdf format
figName = ['PostLabPlot'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')