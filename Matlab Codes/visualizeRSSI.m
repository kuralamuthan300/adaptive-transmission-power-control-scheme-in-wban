Array = csvread("data.csv");

Time  = Array(:,1);
RSSI  = Array(:,2);
Acc_x = Array(:,3);
Acc_y = Array(:,4);
Acc_z = Array(:,5);


Total_samples = size(Time);
Acc_Mag = zeros(Total_samples(1,1),1);

for itr = 1:Total_samples(1,1)
    sum = (Acc_x(itr,1)^2)+(Acc_y(itr,1)^2)+(Acc_z(itr,1)^2);
    Acc_Mag(itr,1) = sum^0.5;
end
Smooth_RSSI = sgolayfilt(Array(:,2),6,21);
Smooth_Acc  = sgolayfilt(Acc_Mag,6,21);

g_Max_idx = [];
for itr=1:30:Total_samples(1,1)
    if(itr+29 <=Total_samples(1,1))
        g_Max_idx = [g_Max_idx,g_min(Smooth_Acc,itr,itr+29)];
    else
        g_Max_idx = [g_Max_idx,g_min(Smooth_Acc,itr,Total_samples(1,1))];
    end
end

g_Max_idx = [1,g_Max_idx];
g_Max_idx = [g_Max_idx,Total_samples(1,1)];


local_max_RSSI = islocalmax(Smooth_RSSI);

Threshold = mean(Smooth_RSSI);


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
function avg = l_max_avg(Array,l_max,s,e)
count = 0;
sum = 0;
for itr=s:1:e
    if(l_max(itr,1) == 1)
        sum = sum+Array(itr,1);
        count = count+1;
    end
    avg = sum/count;
end
    
end
