function plotData(src,event,fid)
time= event.TimeStamps;
voltage=event.Data;
plot(time, voltage,'ko')
hold on
xlabel('time (s)')
ylabel('voltage (v)')
fprintf(fid,'%3.5f \t %3.5f \n',time,voltage);
end