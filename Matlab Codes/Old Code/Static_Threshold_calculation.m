CSV_file = Sit_pred;
Time  = CSV_file(:,1);
RSSI  = CSV_file(:,2);


Total_samples = size(Time);

%Signal smoothening with Savitzky-Golay filtering.Polynomial order = 6 and
%framelength = 21
Smooth_RSSI = sgolayfilt(RSSI,6,21);

threshold = [-40];

for itr=1:30:Total_samples(1,1)
    threshold = [threshold,Smooth_RSSI(itr,1)];
end

figure(4)
bar(threshold)
title("Threshold RSSI Visualization");