csv_file = csvread("Dataset/indoor_1.CSV");
%csv_file = csvread("Dataset/indoor_2.CSV");
%csv_file = csvread("Dataset/outdoor_1.CSV");
%csv_file = csvread("Dataset/outdoor_2.CSV");

rssi = csv_file(:, 2);
%rssi = sgolayfilt(rssi, 6, 21);

acc_x = csv_file(:, 3);
acc_y = csv_file(:, 4);
acc_z = csv_file(:, 5);

no_of_packets = size(csv_file);
no_of_packets = no_of_packets(1, 1);
acc = zeros(no_of_packets, 1);

for itr = 1:no_of_packets
    sum = (acc_x(itr, 1)^2) + (acc_y(itr, 1)^2) + (acc_z(itr, 1)^2);
    acc(itr, 1) = sum^0.5;
    clear sum;
end

clear acc_x;
clear acc_y;
clear acc_z;

%acc = sgolayfilt(acc, 6, 21);

g_min_idx = [];

for itr = 1:30:no_of_packets

    if (itr + 29 <= no_of_packets)
        g_min_idx = [g_min_idx, g_min(acc, itr, itr + 29)];
    else
        g_min_idx = [g_min_idx, g_min(acc, itr, no_of_packets)];
    end

end

%Adding first and last packets as two end points
g_min_idx = [1, g_min_idx];
g_min_idx = [g_min_idx, no_of_packets];


clear itr;
clear csv_file;
% Global max between s and e
function index = g_min(Array, s, e)
    min = 1000;

    for itr = s:1:e

        if (min > Array(itr, 1))
            min = Array(itr, 1);
            index = itr;
        end

    end

end
