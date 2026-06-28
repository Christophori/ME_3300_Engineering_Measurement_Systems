% This is an example for linear curve fitting
% Author: Dr. Vibhav Durgesh
% Date: 1/14/2022
clear all
close all
clc
 
x = 1:0.2:10;
y = 1.37*x + 0.76 + randn(size(x));
hf1 = figure(1);
plot(x,y,'k>--');

hf2= figure(2)
plot(x,y,'b>--');

set(hf2,'units','inches','position',[0.5 0.5 6.00 3.0]);