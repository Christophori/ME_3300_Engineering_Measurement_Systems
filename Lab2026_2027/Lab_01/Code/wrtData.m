% This file is used to create the data file 

clear all
close all
clc

x1 = 3.567 + 1*randn([1 500]);
fid = fopen('myData.dat','w+')
fprintf(fid,'%s \n','Volt data (v)');
for i = 1:length(x1);
    fprintf(fid,'%3.5f \n',x1(i) );
end


x = [0.0000 0.3571 0.7143 1.0714 1.4286 1.7857 2.1429 2.5000 2.8571 ...
     3.2143 3.5714 3.9286 4.2857 4.6429 5.0000];
y = [7.0000 8.4286 9.8571 11.2857 12.7143 14.1429 15.5714 17.0000 18.4286 ...
    19.8571 21.2857 22.7143 24.1429 25.5714 27.0000];

fid = fopen('myData2.dat','w+')
fprintf(fid,'%s \t %s \n','Time (s)', 'Volt (v)');
for i = 1:length(x);
fprintf(fid,'%3.5f \t %3.5f \n',x(i), y(i) )
end
fclose(fid)