function plotAndLogData(src,event,fid,m,c,choice)
time= event.TimeStamps;
voltage=event.Data;
plot(time, m*voltage+c,'k.','markersize',6)
title('Press any key when data acquistion is done','fontsize',14)
hold on
xlabel('time (s)')
ylabel('voltage (v)')
if choice == 1
    for ii = 1:length(voltage)
        fprintf(fid,'%3.5f \t %3.5f \n',time(ii),voltage(ii)*m + c);
    end
end
end