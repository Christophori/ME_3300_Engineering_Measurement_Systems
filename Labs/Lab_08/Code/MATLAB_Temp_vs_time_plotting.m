clear all
close all
clc


%% User input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_0 = [1.561, 1.415, 1.484];

%% End of user input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('../Data/TimeSeries_Temperature01.dat'); %Reading data from the stored file
line1 = fgetl(fid);
data1 = fscanf(fid,'%f,%f \n', [2 inf]);
time1 = data1(1,:)- t_0(1);
temperature1 = data1(2,:);
fclose(fid);

fid = fopen('../Data/TimeSeries_Temperature02.dat'); %Reading data from the stored file
line1 = fgetl(fid);
data2 = fscanf(fid,'%f,%f \n', [2 inf]);
time2 = data2(1,:) - t_0(2);
temperature2 = data2(2,:);
fclose(fid);

fid = fopen('../Data/TimeSeries_Temperature03.dat'); %Reading data from the stored file
line1 = fgetl(fid);
data3 = fscanf(fid,'%f,%f \n', [2 inf]);
time3 = data3(1,:) - t_0(3);
temperature3 = data3(2,:);
fclose(fid);

%% Generating figure with specific size
figure (1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
%Plotting data
plot(time1,temperature1,'ro','markersize',3,'markerfacecolor','r');hold on
plot(time2,temperature2,'bo','markersize',3,'markerfacecolor','b')
plot(time3,temperature3,'ko','markersize',3,'markerfacecolor','k')
xlim([-.1 0.5])
ylim([20 100])
text(0.3,70,'\tau_{1} = 0.0 s', 'fontname','times') %Change tau value
text(0.3,67,'\tau_{2} = 0.0 s', 'fontname','times') %Change tau value
text(0.3,64,'\tau_{3} = 0.0 s', 'fontname','times') %Change tau value
text(0.3,61,'\tau_{avg} = 0.0 s', 'fontname','times') %Change average tau value
xlabel('Time(t)')
ylabel('Temperature (T)')
legend('Run 01','Run 02','Run 03','location','northwest')
grid on
title('Student''s Name Time Series Plot')

%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Time_Series_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Time_Series_Plot.pdf",Resolution=600) % for canvas submission 