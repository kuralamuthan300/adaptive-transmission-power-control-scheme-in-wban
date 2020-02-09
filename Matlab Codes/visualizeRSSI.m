clear;
CSV_file = csvread("data.csv");

Time  = CSV_file(:,1);
RSSI  = CSV_file(:,2);
Acc_x = CSV_file(:,3);
Acc_y = CSV_file(:,4);
Acc_z = CSV_file(:,5);


Total_samples = size(Time);
Acc_Mag = zeros(Total_samples(1,1),1);


%Calculating Accleration magnitude from Acc_X,Acc_Y,Acc_Z
for itr = 1:Total_samples(1,1)
    sum = (Acc_x(itr,1)^2)+(Acc_y(itr,1)^2)+(Acc_z(itr,1)^2);
    Acc_Mag(itr,1) = sum^0.5;
end

%Signal smoothening with Savitzky-Golay filtering.Polynomial order = 6 and
%framelength = 21
Smooth_RSSI = sgolayfilt(RSSI,6,21);
Smooth_Acc  = sgolayfilt(Acc_Mag,6,21);


%RSSI visualization
figure(1)
plot(Smooth_RSSI);
hold on
plot(RSSI);
legend('After smoothening','Before Smoothening')
title('RSSI Smoothening')
hold off

%Accleration magnitude visualization
figure(2)
plot(Smooth_Acc);
hold on
plot(Acc_Mag);
legend('After smoothening','Before Smoothening')
title('Acceleration magnitude Smoothening')
hold off

%Smoothened Acc and RSSI visualization
figure(3)
plot(Smooth_Acc);
hold on
plot(Smooth_RSSI);
legend('Smoothened Acc','Smoothened RSSI')
title('RSSI and Accleration samples')
hold off


%local_max_RSSI stores local maxima of Smooth_RSSI wave
local_max_RSSI = islocalmax(Smooth_RSSI);


%Calculating global Minimum for every 3s(30 data samples) 
g_Min_idx = [];
for itr=1:30:Total_samples(1,1)
    if(itr+29 <=Total_samples(1,1))
        g_Min_idx = [g_Min_idx,g_min(Smooth_Acc,itr,itr+29)];
    else
        g_Min_idx = [g_Min_idx,g_min(Smooth_Acc,itr,Total_samples(1,1))];
    end
end

%Adding first and last packets as two end points
g_Min_idx = [1,g_Min_idx];
g_Min_idx = [g_Min_idx,Total_samples(1,1)];


%Stores AVG RSSI as threshold RSSI for first cycle
g_max_size = size(g_Min_idx);

%Calculates and stores threshold RSSI for each cycle
avg_threshold_rssi = [];
for itr=1:1:g_max_size(1,2)-1
    threshold_bw_idx = threshold_calc(Smooth_RSSI,local_max_RSSI,g_Min_idx(1,itr),g_Min_idx(1,itr+1));
    avg_threshold_rssi = [avg_threshold_rssi,threshold_bw_idx];
end
avg_threshold_rssi = [mean(Smooth_RSSI),avg_threshold_rssi];

bar(avg_threshold_rssi)


%clearing intermediate variables from the work space
clear local_max_RSSI;
clear g_max_size;
clear CSV_file;
clear Acc_x;
clear Acc_y;
clear Acc_z;
clear Acc_Mag;
clear RSSI;
clear sum;
clear count;
clear itr;
clear Time;
clear Total_samples;
clear threshold_bw_idx;


% Functions
% Global max between s and e
function index = g_min(Array,s,e)
min = 1000;
for itr=s:1:e
    if(min>Array(itr,1))
        min = Array(itr,1);
        index = itr;
    end
end

    
end


%local_max average
function avg = threshold_calc(Smooth_RSSI,local_max_RSSI,s,e)
count = 0;
sum = 0;
for itr=s:1:e
    if(local_max_RSSI(itr,1) == 1)
        sum = sum+Smooth_RSSI(itr,1);
        count = count+1;
    end
end
avg = sum/count;

    
end

