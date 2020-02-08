Array = csvread("data.csv");

Time_steps  = Array(:,1);
RSSI  = Array(:,2);
Acc_x = Array(:,3);
Acc_y = Array(:,4);
Acc_z = Array(:,5);


Total_samples = size(Time_steps);
Acc_Mag = zeros(Total_samples(1,1),1);

for itr = 1:Total_samples(1,1)
    sum = (Acc_x(itr,1)^2)+(Acc_y(itr,1)^2)+(Acc_z(itr,1)^2);
    Acc_Mag(itr,1) = sum^0.5;
end
 Smooth_RSSI = sgolayfilt(RSSI,7,21);
 Smooth_Acc  = sgolayfilt(Acc_Mag,7,21);
 plot(Time_steps,Smooth_Acc)
 
    