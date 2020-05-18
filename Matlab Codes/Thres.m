clear;
Acc_X = randi([-250, 250], [2000, 1]);
Acc_Y = randi([-250, 250], [2000, 1]);
Acc_Z = randi([-250, 250], [2000, 1]);
RSSI = randi([20, 70], [2000, 1]);
label = randi([1, 5], [2000, 1]);

len = size(Acc_X);
len = len(1, 1);

%Calculating Accleration magnitude from Acc_X,Acc_Y,Acc_Z
Acc_Mag = [];

for itr = 1:len
    sum = (Acc_X(itr, 1)^2) + (Acc_Y(itr, 1)^2) + (Acc_Z(itr, 1)^2);
    Acc_Mag(itr, 1) = sum^0.5;
end

%Acc=sgolayfilt(Acc_Mag,6,21);
%RSSI=sgolayfilt(RSSI,6,21);
Acc = Acc_Mag;
%walking
Acc_walk = [];
RSSI_walk = [];
Last_thres_walk = -40;
Threshold_walk = [-40];
Global_min_walk = [1];
size_walk = 0;

%walking_up
Acc_walk_up = [];
RSSI_walk_up = [];
Last_thres_walk_up = -40;
Threshold_walk_up = [-40];
Global_min_walk_up = [1];
size_walk_up = 0;

%walking_down
Acc_walk_down = [];
RSSI_walk_down = [];
Last_thres_walk_down = -40;
Threshold_walk_down = [-40];
Global_min_walk_down = [1];
size_walk_down = 0;

%siting
Acc_sitting = [];
RSSI_sitting = [];
Last_thres_sitting = -40;
Threshold_sitting = [-40];


%standing

Acc_standing = [];
RSSI_standing = [];
Last_thres_standing = -40;
Threshold_standing = [-40];


for itr = 1:len

    if (label(itr, 1) == 1)

        if (size_walk ~= 0)
            size_walk = size_walk + 1;
            Acc_walk = [Acc_walk; Acc(itr, 1)];
            RSSI_walk = [RSSI_walk; RSSI(itr, 1)];

            if (mod(size_walk + 1, 30) == 0)
                temp = size(Global_min_walk);
                temp = temp(1, 1);
                prev_gmin = Global_min_walk(temp, 1);
                g_idx = g_min(Acc_walk, prev_gmin);
                Last_thres_walk = threshold_calc(RSSI_walk, islocalmax(RSSI_walk), prev_gmin);

                Global_min_walk = [Global_min_walk; g_idx];
                Threshold_walk = [Threshold_walk; Last_thres_walk];
                clear temp;
                clear prev_gmin;
                clear g_idx;
            end

        elseif (size_walk == 0)
            size_walk = size_walk + 1;
            Acc_walk = [Acc_walk; Acc(itr, 1)];
            RSSI_walk = [RSSI_walk; RSSI(itr, 1)];
        end

    elseif (label(itr, 1) == 2)

        if (size_walk_up ~= 0)
            size_walk_up = size_walk_up + 1;
            Acc_walk_up = [Acc_walk_up; Acc(itr, 1)];
            RSSI_walk_up = [RSSI_walk_up; RSSI(itr, 1)];

            if (mod(size_walk_up + 1, 30) == 0)
                temp = size(Global_min_walk_up);
                temp = temp(1, 1);
                prev_gmin = Global_min_walk_up(temp, 1);
                g_idx = g_min(Acc_walk_up, prev_gmin);
                Last_thres_walk_up = threshold_calc(RSSI_walk_up, islocalmax(RSSI_walk_up), prev_gmin);

                Global_min_walk_up = [Global_min_walk_up; g_idx];
                Threshold_walk_up = [Threshold_walk_up; Last_thres_walk_up];
                clear temp;
                clear prev_gmin;
                clear g_idx;
            end

        elseif (size_walk_up == 0)
            size_walk_up = size_walk_up + 1;
            Acc_walk_up = [Acc_walk_up; Acc(itr, 1)];
            RSSI_walk_up = [RSSI_walk_up; RSSI(itr, 1)];
        end

    elseif (label(itr, 1) == 3)

        if (size_walk_down ~= 0)
            size_walk_down = size_walk_down + 1;
            Acc_walk_down = [Acc_walk_down; Acc(itr, 1)];
            RSSI_walk_down = [RSSI_walk_down; RSSI(itr, 1)];

            if (mod(size_walk_down + 1, 30) == 0)
                temp = size(Global_min_walk_down);
                temp = temp(1, 1);
                prev_gmin = Global_min_walk_down(temp, 1);
                g_idx = g_min(Acc_walk_down, prev_gmin);
                Last_thres_walk_down = threshold_calc(RSSI_walk_down, islocalmax(RSSI_walk_down), prev_gmin);

                Global_min_walk_down = [Global_min_walk_down; g_idx];
                Threshold_walk_down = [Threshold_walk_down; Last_thres_walk_down];
                clear temp;
                clear prev_gmin;
                clear g_idx;
            end

        elseif (size_walk_down == 0)
            size_walk_down = size_walk_down + 1;
            Acc_walk_down = [Acc_walk_down; Acc(itr, 1)];
            RSSI_walk_down = [RSSI_walk_down; RSSI(itr, 1)];
        end

    elseif (label(itr, 1) == 4)
        Acc_sitting = [Acc_sitting; Acc(itr, 1)];
        RSSI_sitting = [RSSI_sitting; RSSI(itr, 1)];
        size_arr = size(Acc_sitting);
        size_arr = size_arr(1, 1);

        if (size_arr > 10)
            sum_RSSI = 0;
            count = 0;

            for idx = size_arr-9:size_arr
                sum_RSSI = sum_RSSI + RSSI_sitting(idx, 1);
                count = count + 1;
            end

            Last_thres_sitting = sum_RSSI / count;
            Threshold_sitting = [Threshold_sitting; Last_thres_sitting];

        end

    elseif (label(itr, 1) == 5)
        Acc_standing = [Acc_standing; Acc(itr, 1)];
        RSSI_standing = [RSSI_standing ; RSSI(itr, 1)];
        size_arr = size(Acc_standing);
        size_arr = size_arr(1, 1);

        if (size_arr > 10)
            sum_RSSI = 0;
            count = 0;

            for idx = size_arr-9:size_arr
                sum_RSSI = sum_RSSI + RSSI_standing(idx, 1);
                count = count + 1;
            end

            Last_thres_standing = sum_RSSI / count;
            Threshold_standing = [Threshold_standing; Last_thres_standing];
        end

    end

end

%global minimum algorithm
function index = g_min(Array, s)
    min = 1000;
    arr_size = size(Array);
    arr_size = arr_size(1, 1);

    for itr = s:1:arr_size

        if (min > Array(itr, 1))
            min = Array(itr, 1);
            index = itr;
        end

    end

end

%Threshold calculation
function avg = threshold_calc(Smooth_RSSI, local_max_RSSI, s)
    count = 1;
    sum = 0;

    arr_size = size(Smooth_RSSI);
    arr_size = arr_size(1, 1);

    for itr = s:1:arr_size

        if (local_max_RSSI(itr, 1) == 1)
            sum = sum + Smooth_RSSI(itr, 1);
            count = count + 1;
        end

    end

    avg = sum / (count - 1);

    if isnan(avg)
        avg = mean(Smooth_RSSI);
    end

end
