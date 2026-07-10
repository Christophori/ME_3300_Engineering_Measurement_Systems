% This is a genric program to plot the data acquired from the op-amp and
% instument amplifier
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% Rev 0.1 Modified for new DAQ and circuit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc


fid = fopen('..\Data\LM358Data.dat'); % Input data file for LM358
line1 = fgetl(fid);
data1 = fscanf(fid,'%f \n', [3 inf]);
time1 = data1(1,:);
output1 = data1(2,:);
input1 = data1(3,:);
fclose(fid);

fid = fopen('..\Data\AD622Data.dat'); % Input data file for AD622
line1 = fgetl(fid);
data2 = fscanf(fid,'%f \n', [3 inf]);
time2 = data2(1,:);
output2 = data2(2,:);
input2 = data2(3,:);
fclose(fid);
nstr = 1;
nend = 600;
%% Perform Linear Regression for Non-Invertig Amplifier
[p,s] = polyfit(input1(nstr:nend),output1(nstr:nend),1);
xfitLM358 = input1;
yfitLM358 = polyval(p,xfitLM358);

[p2,s2] = polyfit(input2(nstr:nend),output2(nstr:nend),1);
xfitAD622 = input2;
yfitAD622 = polyval(p2,xfitAD622);


% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 7.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
subplot(2,1,1)
plot(input1(1:3:end),output1(1:3:end),'ro','markersize',6,'markerfacecolor','r');hold on
plot(xfitLM358,yfitLM358,'k-','linewidth',2)
%xlim([0 3.5])
%ylim([0 10])
xlabel('Input Voltage,V')
ylabel('Output Voltage,V')
legend('Non-Inverting Op-Amp Expt. Data','Non-Inverting Op-Amp Regression Fit','location','northwest')
text(2,4,sprintf('V_{non-inv} = %3.4f%s + %3.4f',p(1),'V_{input}',p(2)),'Fontname','times')
grid on
title('Firstname Lastname''s plot LM358')
subplot(2,1,2)
plot(input2,output2,'bo','markersize',6,'markerfacecolor','b'); hold on;
plot(xfitAD622,yfitAD622,'g-','linewidth',2)
%xlim([0 3.5])
%ylim([0 10])
xlabel('Input Voltage,V')
ylabel('Output Voltage,V')
legend('Instrumentation Op-Amp Expt. Data','Instrumentation Op-Amp Regression Fit','location','northwest')
text(2,3,sprintf('V_{inst}= %3.4f%s + %3.4f',p2(1),'V_{input}',p2(2)),'Fontname','times')
title('Firstname Lastname''s plot AD622')
grid on
% % % Saving the files in png and pdf format
figName = ['..\Figures\Firstname_Lastname_Exp06_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')