clear all
close all
clc

R1 = 5.037; % Resistor Value (MOhm)
R2 = 5.054; % Resistor Value (MOhm)
C = 0.05; % Capacitance Value (uF)
K = (R2/R1); %static sensitivity
tau = R2*C; % time constant (s)

A = [4.0151716 4.0157 4.0157 4.005524 4.00552 4.0157 4.00552 4.00552 4.0055 4.005524 4.0055 4.005524]; % Input magnitude
B = [3.982208 3.972 3.9618 3.95165 3.94146 3.9211 3.76832 3.34 2.87207 2.46491 2.1387 1.23234]; % Output magnitude
T = [100.09 50.09 25.02 16.79 12.52 9.97 5.011 2.498 1.67 1.255 1.003 0.499]; %Period of input signal
delay = [0.8 0.5 0.36 0.33 0.31 0.3 0.27 0.236 0.211 0.185 0.165 0.106]; %time delay in s
f = 1./T; %Hz
tau_omega = tau*2*pi*f; 
%% Calculating Magnitude Ratio
M_exp = B./(K*A);
M_theo = 1./sqrt(1+(2*pi*f*tau).^2);

figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
loglog(tau_omega,M_exp,'ko','markerfacecolor','k');hold on
loglog(tau_omega,M_theo,'b-','markerfacecolor','b','linewidth',2)
xlabel('\tau \omega')
ylabel('M(\omega)')
ylim([0 1.2])
set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1.0])
legend('Experimental','Theoretical','location','southwest')
title('FirstName LastName''s Magnitude Ratio plot')
% % % Saving the files in png and pdf format
figName = ['../Figures/FirstName_LastName_Exp10_Part1'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')

%% Calculating Phase Lag
phi = delay.*2*pi.*f*(180/pi); % radians
phaselag_exp = - phi;
phaselag_theo = -atan(2*pi*f*tau)*(180/pi);

figure(2)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times');
semilogx(tau_omega,phaselag_exp,'ko','markerfacecolor','k');hold on
semilogx(tau_omega,phaselag_theo,'b-','markerfacecolor','b','linewidth',2)
xlabel('\tau \omega')
ylabel('Phase shift, \phi(\omega)[^{o}]')
ylim([-90 0])
title('FirstName LastName''s Phase Shift Ratio plot')
legend('Experimental','Theoretical','location','southwest')

% % % Saving the files in png and pdf format
figName = ['../Figures/FirstName_LastName_Exp10_Part2'];
set(gcf,'PaperPositionMode','auto')
print(figName,'-dpng','-r600')
set(gcf,'PaperUnits','inches','Units','inches');
figpos = get(gcf,'Position');
set(gcf,'PaperSize',figpos(3:4),'Units','inches');
print(figName,'-dpdf','-r600')