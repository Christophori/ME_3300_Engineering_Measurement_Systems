clear all
close all
clc

TableTopDMM = [0.00282 0.99867 1.9987 2.9996 3.9991 5.0002];
HandHeldDMM = [0 0.99 1.22 2.99 3.99 4.99];
Oscilloscope = [0.00627 1.03 2 3.02 4.01 5.04];


% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data

% % % Saving the files in png and pdf format
figName = ['Paulo_Yu_Exp04_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')


