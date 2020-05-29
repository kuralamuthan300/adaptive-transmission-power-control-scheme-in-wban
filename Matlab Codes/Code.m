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

dynamic_points = [];
static_points = [];

for itr = 1:30:no_of_packets

    if (itr + 29 <= no_of_packets)
        a = g_min(acc, itr, itr + 29);

        if (is_static(acc, a))
            static_points = [static_points, a];
        else
            dynamic_points = [dynamic_points, a];
        end

    else
        a = g_min(acc, itr, no_of_packets);

        if (is_static(acc, a))
            static_points = [static_points, a];
        else
            dynamic_points = [dynamic_points, a];
        end

    end

end

clear itr;
clear csv_file;

% Global min between s and e
function index = g_min(Array, s, e)
    min = 1000;

    for itr = s:1:e

        if (min > Array(itr, 1))
            min = Array(itr, 1);
            index = itr;
        end

    end

end

function s = is_static(array, idx)
    s = false;
    localmax_acc = islocalmax(array);

    for itr = idx - 1:-1:1

        if (localmax_acc(itr, 1) == 1)
            mid_point = (array(idx, 1) + array(itr, 1)) / 2;
            diff_val = abs(mid_point - array(idx, 1));

            if (diff_val < 0.0070)
                s = true;
%                 disp("diff : ");
%                 disp(diff_val);
%                 disp("idx : ");
%                 disp(idx);
            end

        end

    end

end
