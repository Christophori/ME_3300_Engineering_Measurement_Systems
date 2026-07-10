clear all
close all
clc

fid = fopen('AngVsTime.dat');
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
x = data(1,:);
y = data(2,:);
fclose(fid);

% Calculating the average and standard deviation
xavg = mean(x);
xstd = std(x);
yavg = mean(y)
%G Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(x,y,'ro','markersize',4);hold on
xlabel('time (s)')
ylabel('Angle (\theta)')
grid on
% ylim([-3 9])
legend('Expt. data','location','Southeast')
title('Paulo Yu''s plot')

text(10,80,'T_{d}=1s','fontname','times')
text(10,60,'\omega_{d}=2\pi','fontname','times')

%Saving the files in png and pdf format
figName = ['Paulo_Yu_Exp02_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')

