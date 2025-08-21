clear all
close all
clc
%% Start user required information

fid = fopen('AngVsTime.dat');
tline = fgetl(fid);
data = fscanf(fid, '%f \n', [2 inf]);
x = data(1,:);
y = data(2,:);
fclose(fid);
%% End user required information
[p,s] = polyfit(x,y,1);
xfit = x;
yfit = polyval(p,xfit);
nu = s.df;
norm = s.normr;
syx = norm/sqrt(nu);

%Generating figure with specific size
figure (1)
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
plot(x,y,'-ro','markersize',8,'markerfacecolor','r');
xlabel('Time (s)')
ylabel('Angle (^{o})')
grid on

ylim([-90 90])
xlim([0 15])

legend('Expt. data','location','Southeast')
title('Rodrigo Padilla''s plot')

text(12,70,'T_d = 1','Fontname','times')
text(12,60,'\omega_d = 2\pi','Fontname','times')

figName = ('Rodrigo_Padilla_Expt02_Postprocess');
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf, 'Position');
set(gcf, 'PaperSize', figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600') 