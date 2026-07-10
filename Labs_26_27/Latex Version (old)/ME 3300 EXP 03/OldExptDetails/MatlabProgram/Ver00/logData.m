
function logData(src, evt, fid1)

% Add the time stamp and the data values to data. To write data sequentially,
% transpose the matrix.

%   Copyright 2011 The MathWorks, Inc.

data = [evt.TimeStamps, evt.Data]' ;
%fwrite(fid1,data,'double');

fprintf(fid1,'%3.2f \t %3.2f \n',evt.TimeStamps, evt.Data);
end