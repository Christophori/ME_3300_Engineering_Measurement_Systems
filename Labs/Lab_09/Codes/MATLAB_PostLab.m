clear all
close all
clc

R1 = 5.0265; % Resistor Value (MOhm)
R2 = 5.0656; % Resistor Value (MOhm)
C = 0.05; % Capacitance Value (uF)
K = (R2/R1); %static sensitivity
tau = R2*C; % time constant (s)

%% A is peak-to-peak of Input
%% B is peak-to-peak of Input
%% delay: At 2.5 V find the input difference between A and B

A = [4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0	4.0]; % Input magnitude
B = [3.9725	3.96990000	3.9634	3.9518	3.9364	3.9183	3.774	3.3396	2.8704	2.4618	2.1319	1.2219]; % Output magnitude
T = [100.0	50.0	25.0	16.5	12.5	10.0	5.0	2.5	1.5	1.25	1.0	0.5]; %Period of input signal
delay = [0.75	0.501	0.376	0.33	0.313	0.303	0.268	0.237	0.21	0.186	0.167	0.106]; %time delay in s
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
%% Saving the files in png and pdf format
exportgraphics(better_fig,"..\Figures\My_Awesome_Magnitude_Ratio_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Magnitude_Ratio_Plot.pdf",Resolution=600) % for canvas submission 

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
exportgraphics(better_fig,"..\Figures\My_Awesome_Phase_Shift_Plot.png",Resolution=600) % for reports/presentations
exportgraphics(better_fig,"..\Figures\My_Awesome_Phase_Shift_Plot.pdf",Resolution=600) % for canvas submission 
