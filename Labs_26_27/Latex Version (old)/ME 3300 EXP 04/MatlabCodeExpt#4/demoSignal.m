% This program plots the sin signal to show Vpp and DC offset

clear all
close all
clc

dcOff = 2;
amp   = 3;
f = 1;
t = 0:0.01:4;

 y = dcOff + amp*sin(2*pi*f*t);
 
 figure(1)
 set(gcf,'units','inches','position',[0.50 0.50 6.00 3.00],'defaultaxesfontsize',12)
 plot(t,y,'k','linewidth',3);
 grid on
 grid minor
 xlabel('time (s)')
 ylabel('volts')
 
 figName = ['../Figures/demoSignal'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'Papersize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')