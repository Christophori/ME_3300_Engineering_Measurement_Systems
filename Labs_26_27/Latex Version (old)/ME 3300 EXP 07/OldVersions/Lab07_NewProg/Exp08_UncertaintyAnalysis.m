clear all
close all
clc

format long

mass = [0 0.4 0.4 0.6 0.6 0.8 0.8 1 1 1.2 1.2 1.4 1.4 1.6 1.6 1.8 1.8 2 2]; %Change to appropriate weight for experiment
unloadedweight = [2.1240 2.1264 2.1267 2.1277 2.1293 2.1299 2.1282 2.1291 2.1301 2.1305 2.1328 2.1330 2.1341 2.1341 2.1340 2.1341 2.1356 2.1347 2.1344];%Change to appropriate readout from DMM
loadedweight = [2.1240 2.2714 2.2714 2.3467 2.3467 2.4206 2.4206 2.4929 2.4929 2.5670 2.5670 2.6422 2.6422 2.7149 2.7149 2.7877 2.7877 2.8625 2.8625]; % Change to appropriate readout from DMM

L = 36/100; % length of beam using a tape measure
w = 1.499*(2.54/100); %width of the beam using a caliper
t = 0.2515*(2.54/100); %thickness of the beam using a micrometer
g = 9.8051; % gravitational constant (m/s)
GF = 2.012; % Gain Factor
G = 497.7538855; % gain using Rg = 101.66 ohm
Vi = 10; %Excitation Voltage

m = mass; % mass (kg)
dvo = abs(loadedweight-unloadedweight); %difference in voltage

%% Calculating Stress
stress = ((6*m*g*L)/(w*t^2))/(10^9); %Stress(MPa)

%% Calculating Strain
strain = ((2*dvo)/(Vi*G*GF));

t_nuP = 2.110; %Value read from t-student's table (19 data points)
plotTitle = 'Paulo Yu''s plot';
%%%% END OF USER INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[p,s] = polyfit(strain,stress,1); % Curve fitting data with 1st order fit
xfit = strain;% Generating x-data for curve fitting
yfit = polyval(p,xfit);
nu = s.df; %Getting degree of freedom for the curve fit
norm = s.normr; % Getting the norm of the curve fitting
syx = norm/sqrt(nu);

% Generating figure with specific size
figure(1)
set(gcf,'unit','inches','position',[0.50 0.50 6.50 3.50],...
    'defaultaxesfontsize',10,'defaultaxesfontname','times');
% Plotting data
plot(xfit,yfit,'b-','linewidth',2); hold on
plot(strain,stress,'ro','markersize',9,'markerfacecolor','r')
xlabel('\epsilon, strain')
ylabel('\sigma, GPa')
grid on
% Now adding 95% confidence level in the plot
y_cl_low = yfit - t_nuP*syx; % Using regression analysis
y_cl_up  = yfit + t_nuP*syx;
plot(xfit,y_cl_low,'--','color',[0.2 0.2 0.2],'HandleVisibility','off');
plot(xfit,y_cl_up,'--','color',[0.2 0.2 0.2]);

legend('Curve fit','Expt. data','95% CL range','location','Northwest')
title(plotTitle)
text(1e-4,0.01,sprintf('%s = %3.4f%s+%3.4f','\sigma',p(1),'\epsilon',p(2)),'Fontname','times')
text(1e-4,0.005,sprintf('Norm = %3.4f',s.normr),'Fontname','times')
text(1e-4,0,sprintf('s_{yx} = %3.8f%s',syx,'GPa'),'Fontname','times') 

%% UNCERTAINTY
%Derivatives
syms m g L Vi G GF w t dvo
E = (3*m*g*L*Vi*G*GF)/(w*t^2*dvo);
u_m = diff(E,m);
u_g = diff(E,g);
u_L = diff(E,L);
u_Vi = diff(E,Vi);
u_G = diff(E,G);
u_GF = diff(E,GF);
u_w = diff(E,w);
u_t = diff(E,t);
u_dvo = diff(E,dvo);

%% Uncertainties Values
u_xm = .0108; %uncertainty in mass (kg)
u_xg = 0.000014; %uncertainty in gravity(m/s^2) 
u_xL = 0.0005; %uncertainty in length (m)
u_xw = 0.0000127; %uncertainty in width (m)
u_xt = 0.00000127; %uncertainty in thickness (m)
u_xGF = 0.01*2.012; %uncertainty in gain factor
u_xG = 0.002*497.7538855; %uncertainty in gain (0.2% TYP uncertainty based on AD622 spec sheet)
u_xVi =0.0005; %uncertainty in excitation voltage (V)
u_xdvo = 0.0005; %uncertainty in dvo (V)

u = [u_xm u_xg u_xL u_xw u_xt u_xGF u_xG u_xVi u_xdvo];
%% Subs
old = [m g L w t GF G Vi dvo];
new = [1.08 9.8051 0.3600 0.0380746 0.0063881 2.012 497.7538855 10 0.435941111111111];

U_m = (double(subs(u_m,old,new))*u_xm)/(10^9);
U_g = (double(subs(u_g,old,new))*u_xg)/(10^9);
U_L = (double(subs(u_L,old,new))*u_xL)/(10^9);
U_w = (double(subs(u_w,old,new))*u_xw)/(10^9);
U_t = (double(subs(u_t,old,new))*u_xt)/(10^9);
U_GF = (double(subs(u_GF,old,new))*u_xGF)/(10^9);
U_G = (double(subs(u_G,old,new))*u_xG)/(10^9);
U_Vi = (double(subs(u_Vi,old,new))*u_xVi)/(10^9);
U_dvo = (double(subs(u_dvo,old,new))*u_xdvo)/(10^9);

U = [U_m U_g U_L U_w U_t U_GF U_G U_Vi U_dvo];
%% Calculate Total Uncertainty using Propagation of Error
U_es = sqrt(U_m^2 + U_g^2 + U_L^2 + U_w^2 + U_t^2 + U_GF^2 + U_G^2 + U_Vi^2 + U_dvo^2)

%% Calculate Uncertainty in slope
xbar = mean(strain); % calculate mean strain
den = sum((strain - xbar).^2); 
sa1 = syx*sqrt(1/den) % uncertainty in Young's modulus





