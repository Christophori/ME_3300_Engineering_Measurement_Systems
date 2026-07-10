clear all
close all
clc

fid = fopen('DynamicSignal_0,5Hz.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time1 = data(1,:);
y1 = data(2,:);
fclose(fid);

fid = fopen('DynamicSignal_975Hz.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time2 = data(1,:);
y2 = data(2,:);
fclose(fid);

fid = fopen('DynamicSignal_1250Hz.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time3 = data(1,:);
y3 = data(2,:);
fclose(fid);

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 7.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
subplot(3,1,1)
plot(time1(1:1:5000),y1(1:1:5000),'r.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =0.5Hz, Acquired data =0.5Hz','fontsize',12)

subplot(3,1,2)
plot(time2(1:100),y2(1:100),'k.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =975Hz, Acquired data =25Hz','fontsize',12)

subplot(3,1,3)
plot(time3(1:15),y3(1:15),'b.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =1250Hz, Acquired data =250Hz','fontsize',12)


% % % Saving the files in png and pdf format
figName = ['Paulo_Yu_Exp04_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')


