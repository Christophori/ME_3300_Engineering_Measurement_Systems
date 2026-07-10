% This program reads the data from data file and generates the M(w) and
% phase shift plot

clear all
close all
clc

fname = {'../Data/Signal_00040_mHz.dat', '../Data/Signal_00060_mHz.dat' ...
         '../Data/Signal_00080_mHz.dat', '../Data/Signal_00100_mHz.dat' ...
         '../Data/Signal_00200_mHz.dat', '../Data/Signal_00400_mHz.dat' ...
         '../Data/Signal_00600_mHz.dat', '../Data/Signal_00800_mHz.dat' ...
         '../Data/Signal_01000_mHz.dat', '../Data/Signal_02000_mHz.dat'};

 f = [40 60 80 100 200 400 600 800 1000 2000 ]/1000;
 tau = (5*10^6)*0.05*10^(-6);

for i = 1:10;
fid = fopen(fname{i},'r');
line1 = fgetl(fid);
data = fscanf(fid,'%f %f %f',[3 inf]);
fclose(fid);
t = data(1,:);
y = data(2,:);
x = data(3,:);

xpp = max(x)-min(x);
ypp = max(y)-min(y);
Mf(i) = ypp/xpp;
plot(t,x,'k','linewidth',2); hold on; plot(t,y,'b','linewidth',1); grid on; grid minor
legend('Input','Output')
hold off
end
omgtau = 0.1:0.01:20;
mwtheo = 1./sqrt(1+(omgtau).^2)
figure(2);
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50])
loglog(2*pi*f*tau,Mf,'ko','markerfacecolor','k');
hold on
ylabel('M(\omega)')
xlabel('\tau \omega')
loglog(omgtau,mwtheo,'b','linewidth',2)