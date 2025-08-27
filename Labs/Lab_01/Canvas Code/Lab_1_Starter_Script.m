% Lab 01 Starter Script
% Course: ME 3300
% Date:  MM/DD/YYYY
% Author: FirstName LastName

%% ------------------------------------------------------------------------
% PART 1: Load and Analyze Voltage-Time Data
% -------------------------------------------------------------------------

% Step 1: Clear the workspace, close open figures, and clear the command window
% (Hint: use clear, close, clc)


% Step 2: Load the data
% Option A: Use readtable to load "time_volts_data_example.csv"
%   - Store time data in a variable called "time"
%   - Store voltage data in a variable called "voltage"

% Option B: Use readmatrix to load the same file
%   - Access the first column as time
%   - Access the second column as voltage



% Step 3: Compute basic statistics on the voltage data
%   - mean
%   - standard deviation
%   - variance
%   - minimum
%   - maximum



% Step 4: Print the results using fprintf
% Example format: fprintf("Mean: %10.3f volts\n", value)



% Step 5: Plot the data
%   - Try both line plots and scatter plots
%   - Label the axes, add a title, and enable grid



% Step 6: Make an improved figure
%   - Use scatter for data points
%   - Add a mean line and ±1 standard deviation lines
%   - Add a legend
%   - Save the figure using print(...)



% Step 7: Make a histogram of the voltage data
%   - Experiment with different numbers of bins
%   - Label axes, add a title, enable grid
%   - Save the figure


%% ------------------------------------------------------------------------
% PART 2: Curve Fitting Example
% -------------------------------------------------------------------------

% Step 1: Generate some linear data with noise
%   - Define velocity points
%   - Define slope, bias, and noise
%   - Compute voltage values with random noise
%   - Save the data as a CSV file (writetable)


% Step 2: Read the CSV file back in
%   - Extract velocity and voltage arrays


% Step 3: Fit the data with polyfit
%   - Use a linear fit (order 1)
%   - Evaluate the fit with polyval


% Step 4: Estimate confidence intervals
%   - Use tinv() to get a t-value
%   - Compute standard error (syx)
%   - Add CI lines to the plot


% Step 5: Plot results
%   - Scatter plot of data
%   - Plot fit line and CI lines
%   - Annotate with equation and error text
%   - Add legend, labels, and title
%   - Save the figure


%% ------------------------------------------------------------------------
% PART 3: Normal Distribution Example
% -------------------------------------------------------------------------

% Step 1: Generate normally distributed datasets
%   - Use randn(N,1)*sigma + mu to generate data
%   - Try at least 4 datasets with different mean/sigma


% Step 2: Compute PDF lines
%   - Write a function handle for the normal PDF
%   - Evaluate PDF at a range of x values for each dataset


% Step 3: Plot results
%   - Use tiledlayout with 2 plots
%   - Top: histograms (normalized as PDFs)
%   - Bottom: smooth PDF curves
%   - Use consistent axis limits
%   - Add legend, labels, and title
%   - Save the figure

