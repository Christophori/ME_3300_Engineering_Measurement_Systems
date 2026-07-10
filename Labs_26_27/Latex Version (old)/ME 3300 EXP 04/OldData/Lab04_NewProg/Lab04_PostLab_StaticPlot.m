% This is a genric program to generate plots for Lab#4
% Date: July 19th
% Dr. Vibhav Durgesh
% Rev 0.0
% This is basic program to plot the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

% Make sure to add the data from your experiment 
Input = [0 1 2 3 4 5]; % Volts from power supply
TableTopDMM = [0.00282 0.99867 1.9987 2.9996 3.9991 5.0002]; % Volt read from table top DMM
HandHeldDMM = [0 0.99 1.99 2.99 3.99 4.99]; % Volt read from handheld DMM
Oscilloscope = [0.00627 1.03 2.00 3.02 4.01 5.04]; % Volt read from oscilloscope
DAQMatlab = [0.0042 1.0774 2.0162 3.0374 4.0904 5.0327]; % Volt read from Matlab DAQ program

%% Difference in Voltage Measurements

TTDMM = TableTopDMM-Input;
HHDMM = HandHeldDMM-Input;
Oscope = Oscilloscope-Input;
DAQ = DAQMatlab - Input;

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(Input, TTDMM,'ko','markerfacecolor','k');hold on
plot(Input, HHDMM,'rd','markerfacecolor','r')
plot(Input, Oscope,'bs','markerfacecolor','b')
plot(Input, DAQ, 'mx')
ylim([-0.02 0.06])
xlabel('Input Voltage (v)')
ylabel('Measured-Input (v)')
legend('TableTop DMM','Handheld DMM','Oscilloscope','DAQ','location','northwest')
title('Paulo Yu''s Plot')

% % % Saving the files in png and pdf format
figName = ['Firstname_Lastname_Exp04_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')


