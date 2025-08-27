% Lab 01 Generation and Solution File
% Course: ME 3300
% Date:  06/04/2025
% Author: Dr. Christopher Bitikofer

%% clear workspace, close open figures, and clear the command window
clear all
close all
clc

%% load the data using readtable
% when we read data with readtable, the result is a matlab "table"
% variable. These work much like a Pandas table in Python, or a dataframe
% in R. 
volt_data = readtable('..\Data\time_volts_data_example.csv');
time = volt_data.Time; % This step accesss the values from the table.
voltage = volt_data.Volts;  

%% load the data using readmatrix
% alternatively we can directly read in data values with readmatrix
data = readmatrix("..\Data\time_volts_data_example.csv");
time = data(:,1); % Now we need to access data by column instead of by header name
voltage = data(:,2);

%% compute stats on each of the datasets
% built in matlab functions 
avg_volts = mean(voltage);
std_volts = std(voltage);
var_volts = var(voltage);
min_volts = min(voltage);
max_volts = max(voltage);

% print the results using fprintf
clc % this clears the command window before printing our results
fprintf("Mean:               %10.3f volts\n", avg_volts); 
fprintf("Standard deviation: %10.3f volts\n", std_volts);
fprintf("Variance:           %10.3f volts\n", var_volts);
fprintf("Minimum voltage:    %10.3f volts\n", min_volts);
fprintf("Maximum voltage:    %10.3f volts\n", max_volts);
% here %10.3f is a tag telling fprintf to embed the number values of our
% results in the string we are printing out. The first value 10, in %#.#f
% sets the field width which helps with alignment with multiple print
% lines. The second value, 3, sets the number of decimal placed to print. f
% tells matlab to expect a floating number (as opposed to an integer).

%% plot the trend data
close all
fig = figure(Color="w",WindowStyle="docked"); % This command creates a new figure window
axes(NextPlot="add") % This creates a cartesian axis on the figure to plot data on 
plot(time, voltage, "b-", LineWidth = 1); % This method plots a line between each datapoint... This is usually not a good approach with noisy or discrete data
plot(time, voltage, "ro", LineWidth = 1); % This method instead plots circular markers for each datapoint, acheiving a simple scatter plot

% annother method MATLAB provides is the scatter method. This one provides
% more formatting options for marker size or oppacity. 
ms = 100;
scatter(time,voltage,ms,"pentagram", MarkerFaceColor = "m",MarkerFaceAlpha=.8)

xlabel('Time (s)');
ylabel('Voltage (V)');
title('Time vs Voltage');
grid on;


%% Lets make a more readable plot using better visualization practice
% use scatter markers for showing discrete data and lines for trends...
close all
better_fig = figure(Color="w"); % This command creates a new figure window
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times'); % this command allows us to set several properties for the figure using name-value pair syntax.

axes(NextPlot="add") % This creates a cartesian axis on the figure to plot data on 

% plot the 
ms = 25;
scatter(time,voltage,ms,"o", MarkerFaceColor = "b",MarkerFaceAlpha = 0.5)

% lets plot the mean and first standard devations as lines using "yline"
mean_line = yline(avg_volts,'k-',"\mu",LineWidth=1);
std_line_1 = yline(avg_volts+std_volts,'r--',"\sigma_1",LineWidth=1);
std_line_2 = yline(avg_volts-std_volts,'r--',"\sigma_1",LineWidth=1);
lines = [mean_line,std_line_1,std_line_2]; % grouping line elements into an array for setting properties.
set(lines,"fontname","times","fontsize",10) % Note that by assigning plot elements to variables you can set their propperties simultaniously with the set command.

% lets include a legend 
legend({'Voltage Data', 'Mean', '\sigma_1'}, 'Location', 'southwest');

% to make room for our line labels, lets adjust the x limit
xlim([0,5.5])

% to finish we add descriptive labels
xlabel('Time (s)');
ylabel('Voltage (V)');
title(' FirstName LastName''s Time vs Voltage MM/DD/YY');
grid minor
grid on

%% Finally, lets save the figure to file now that we are happy with it.
print(better_fig,"..\Figures\My_Awesome_Voltage_Scatter",'-dpng','-r600') % for reports/presentations
print(better_fig,"..\Figures\My_Awesome_Voltage_Scatter",'-dpdf','-r600') % for canvas submission 

%% Now let's try making a histogram plot
% use scatter markers for showing discrete data and lines for trends...
close all
historgram_fig = figure(Color="w"); % This command creates a new figure window
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times'); % this command allows us to set several properties for the figure using name-value pair syntax.

axes(NextPlot="add") % This creates a cartesian axis on the figure to plot data on 

histogram(voltage,30,FaceColor="b") % the second argument here is nbins. try setting it to different values. You often need to adjust this setting on histograms to ensure trends in the data are visible.

% to finish add descriptive labels
xlabel('Voltage (V)');
ylabel('Occurances');
title(' FirstName LastName''s Histogram MM/DD/YY');
grid minor
grid on
box off

%% Finally save the figure to file now that we are happy with it.
print(historgram_fig,"..\Figures\My_Awesome_Voltage_Hist",'-dpng','-r600')
print(historgram_fig,"..\Figures\My_Awesome_Voltage_Hist",'-dpdf','-r600')

%%  *** PART 2 ***
%% Generate linear data with some noise
velocity = 1:8; % define sample points
bias = 0.5;  % define bias
slope = 0.375; % define relationship slope
power = 0.8; % define noise power
volts = slope*velocity+bias+rand(1,length(velocity))*power; % generate data

% Save the data as a csv file
dataTable = table(velocity', volts', 'VariableNames', {'Velocity', 'Volts'});

% Save the table to a CSV file
writetable(dataTable, 'velocity_vs_volts_data.csv');
 
% read in the data
data = readtable('velocity_vs_volts_data.csv');
volts = data.Volts;
velocity = data.Velocity;

% use polyfit to curve fit the data
poly_order = 1;
p = polyfit(velocity, volts, poly_order); % Perform linear polynomial fitting

% now we can evaluate points on the polynomial fit using poly val
fittedVolts = polyval(p, velocity); % Evaluate the polynomial at the velocity points

% lets also add confidence interval estimates and text on the figure to communicate the fit relationship and standard devation of the slope
nu = length(velocity)-1;
prob = 0.95;
t_v_p = tinv(prob,nu); % estimate the t table value
s_yx = sqrt(sum(((fittedVolts-volts).^2))/nu); % compute standard error of the fit "syx"
y_cl_1 = fittedVolts+t_v_p*s_yx;
y_cl_2 = fittedVolts-t_v_p*s_yx;

% compute Sa1
volt_avg = mean(volts);
Sa1 = s_yx*sqrt(1/sum((volts-volt_avg).^2));

%% Plot the figure
close all
curve_fit_fig = figure(Color="w"); % This command creates a new figure window
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times'); % this command allows us to set several properties for the figure using name-value pair syntax.
axes(NextPlot="add") % This creates a cartesian axis on the figure to plot data on 

% Add the fitline to the plot
hold on; % Retain current plot
fit_line = plot(velocity, fittedVolts, 'b-', 'LineWidth', 2); % Plot the fitted line
grid on; % Ensure grid is on for better visibility

% Add CI lines to plot 
CI_line = plot(velocity,y_cl_1,'k--',LineWidth=1);
plot(velocity,y_cl_2,'k--',LineWidth=1)

% Add the scatter data points
ms = 75;
data_points = scatter(velocity,volts,100,'red',"filled","o");

% Add the equation and standard error to the plot using text command
equation_string = sprintf("y = %.4fx+%.4f",p(1),p(2)); % sprintf works just like fprintf but lets us store strings in variables to use later
t1 = text(5,1.75,equation_string);
slope_standard_error_string = sprintf("Sa_1 = %.4f",Sa1);
t2 = text(5,1.25,slope_standard_error_string);
tbs = [t1,t2];
set(tbs,"fontname","times","fontsize",12)

% Add labels, title and legend
legend_items = [data_points,fit_line,CI_line];
legend(legend_items,{'Data','Fit Line','95% CI Range'}, ...
    'Location', 'northwest'); % Update legend

% to finish add descriptive labels
xlabel('Velocity (m/s)');
ylabel('Voltage (V)');
title(' FirstName LastName''s Curvefit Plot MM/DD/YY');
grid on
box off

% save the figure to file
print(curve_fit_fig,"..\Figures\My_Curve_Fit",'-dpng','-r600')
print(curve_fit_fig,"..\Figures\My_Curve_Fit",'-dpdf','-r600')

%% *** PART 3 ***
% For Part-3, you'll work with an example set of data that follows a normal (bell curve) distribution. You'll start by
% generating this data and creating a histogram to see how it's spread out. Then, you'll calculate a few key statistics:
% the mean, median, and standard deviation. After that, you'll use the equation for the normal distribution to recreate a
% smooth curve that represents your data. Engineers often use this kind of analysis to turn a set of measured values into
% a continuous model that helps with design decisions. For example, it can help answer questions like: What percentage
% of parts will actually fit together based on size variation?

% generate 4 normally distributed datasets
mu = [-2 0 0 3];
sig = [.8 0.5 2 2];

% generate data
N = 1000;
data_1 = randn(N,1)*sig(1)+mu(1);
data_2 = randn(N,1)*sig(2)+mu(2);
data_3 = randn(N,1)*sig(3)+mu(3);
data_4 = randn(N,1)*sig(4)+mu(4);

% compute PDF lines 
norm_pdf_fun = @(sig,xbar,x)1/(sig*sqrt(2*pi)).*exp(-0.5*((x-xbar)/sig).^2);

x = linspace(-10,10,500)';
pdf_1 = norm_pdf_fun(sig(1),mu(1),x);
pdf_2 = norm_pdf_fun(sig(2),mu(2),x);
pdf_3 = norm_pdf_fun(sig(3),mu(3),x);
pdf_4 = norm_pdf_fun(sig(4),mu(4),x);

% Plot histograms
% use scatter markers for showing discrete data and lines for trends...
close all
historgram_fig_2 = figure(Color="w"); % This command creates a new figure window
set(gcf,'unit','inches','position',[0.50 0.50, 6.50 2*3.50],...
        'defaultaxesfontsize',10,'defaultaxesfontname','times'); % this command allows us to set several properties for the figure using name-value pair syntax.

% lets use tiled layout to make a multi axis figure this time
tl = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
ax1 = nexttile;
hold on
n_bins = 50;
hists(1) = histogram(data_1,n_bins,FaceColor="k"); 
hists(2) = histogram(data_2,n_bins,FaceColor="r"); 
hists(3) = histogram(data_3,n_bins,FaceColor="g"); 
hists(4) = histogram(data_4,n_bins,FaceColor="b"); 
set(hists,"Normalization","pdf") % using normalization changes the y axis from counts to PDF


% add labels
xlabel('Voltage (V)');
ylabel('x');
title('FirstName LastName''s PDF and Historgram Plot MM/DD/YY');
grid on
box off

% make the second plot
ax2 = nexttile;
hold on 
lines(1) = plot(x,pdf_1,'k-');
lines(2) = plot(x,pdf_2,'r-');
lines(3) = plot(x,pdf_3,'g-');
lines(4) = plot(x,pdf_4,'b-');
set(lines,"LineWidth",2)

% set the limits for each plot to match (This is often a very important
% step for making plots easier to compare in reports!)
xlim(ax1, [-10 10]);
xlim(ax2, [-10 10]);
ylim(ax1, [0 1]);
ylim(ax2, [0 1]);

% Add labels
xlabel('x');
ylabel('PDF(x)');
grid on
box off

% add legend
strings = compose("x'=%5.3f, \\sigma = %5.3f", mu(:), sig(:));
legend(ax2,strings)

% save the figure to file
print(historgram_fig_2,"..\Figures\My_PDFs",'-dpng','-r600')
print(historgram_fig_2,"..\Figures\My_PDFs",'-dpdf','-r600')