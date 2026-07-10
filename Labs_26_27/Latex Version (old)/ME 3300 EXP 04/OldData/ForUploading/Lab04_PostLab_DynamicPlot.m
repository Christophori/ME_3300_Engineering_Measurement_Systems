% This is a genric program to generate plots for Lab#4
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% This is basic program to plot the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc
%% USER INPUT REQUIRED %%%%%%%%%%%%%%%%%
% ADD CORRECT FILE NAMES FOR THREE FILES
fid = fopen(''); % 
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time1 = data(1,:);
y1 = data(2,:);
fclose(fid);

fid = fopen(''); % Reading data from the stored file
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time2 = data(1,:);
y2 = data(2,:);
fclose(fid);

fid = fopen(''); % Reading data from the stored file
line1 = fgetl(fid);
data = fscanf(fid,'%f \n', [2 inf]);
time3 = data(1,:);
y3 = data(2,:);
fclose(fid);

% Generating figure with specific size
%% USER INPUT REQUIRED %%%%%%%%
% ADD CORRECT TITLE NAMES FOR THE PLOT
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 7.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
subplot(3,1,1) % Plotting data for 3 peaks only
plot(time1(1:1:5000),y1(1:1:5000),'r.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =100 Hz, Acquired data =100Hz','fontsize',12)

subplot(3,1,2) % Plotting data for 3 peaks only
plot(time2(1:100),y2(1:100),'k.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =975Hz, Acquired data =25Hz','fontsize',12)

subplot(3,1,3) % Plotting data for 3 peaks only
plot(time3(1:15),y3(1:15),'b.-','markersize',6,'markerfacecolor','r');hold on
ylim([0.5 9.5])
xlabel('time (s)')
ylabel('Volts (v)')
grid on
% ylim([-3 9])
title('Sampling rate =1000Hz, Signal generator =1250Hz, Acquired data =250Hz','fontsize',12)
%%

% % % Saving the files in png and pdf format
figName = ['Firstname_Lastname_Exp04_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')


