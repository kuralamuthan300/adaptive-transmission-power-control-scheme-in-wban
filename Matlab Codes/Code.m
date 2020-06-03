%csv_file = csvread("Dataset/indoor_1.CSV");
%csv_file = csvread("Dataset/indoor_2.CSV");
%csv_file = csvread("Dataset/outdoor_1.CSV");
csv_file = csvread("Dataset/outdoor_2.CSV");
tpl = [-5; -1; 1; 3; 5];
rssi = csv_file(:, 2);
%rssi = sgolayfilt(rssi, 6, 21);

localmax_rssi = islocalmax(rssi);
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
localmax_acc = islocalmax(acc);

dynamic_points = [];
static_points = [];

for itr = 1:30:no_of_packets

    if (itr + 29 <= no_of_packets)
        a = g_min(acc, itr, itr + 29);

        if (is_static(acc, a, localmax_acc))
            static_points = [static_points; a];
        else
            dynamic_points = [dynamic_points; a];
        end

    else
        a = g_min(acc, itr, no_of_packets);

        if (is_static(acc, a, localmax_acc))
            static_points = [static_points; a];
        else
            dynamic_points = [dynamic_points; a];
        end

    end

end

if (dynamic_points(1, 1) < static_points(1, 1))
    dynamic_points = [1; dynamic_points];
else
    static_points = [1; static_points];
end

size_dynamic = size(dynamic_points);
size_dynamic = size_dynamic(1, 1);

size_static = size(static_points);
size_static = size_static(1, 1);

if (dynamic_points(size_dynamic, 1) > static_points(size_static, 1))
    dynamic_points = [dynamic_points; no_of_packets];
else
    static_points = [static_points; no_of_packets];
end

static_ptr = 1;
dynamic_ptr = 1;
ptr = 0;
s = 0;
d = 0;

if (static_points(1, 1) < dynamic_points(1, 1))
    ptr = static_ptr;
    static_ptr = static_ptr + 1;
    s = 1;
else
    ptr = dynamic_ptr;
    dynamic_ptr = dynamic_ptr + 1;
    d = 1;
end

bcqt = []; %best channel quality time
tpl_used = [-5]; %tpl used
threshold_rssi = [-65];
current_rssi_range = [];

while (static_ptr <= size_static && dynamic_ptr <= size_dynamic)

    if (static_points(static_ptr, 1) < dynamic_points(dynamic_ptr, 1))
        next_point = static_points(static_ptr, 1);

        if (s == 1)
            %static to static activity
            %Current RSSI Range
            crr = crr_static_to_static(rssi, ptr);
            current_rssi_range = [current_rssi_range; crr];
            %Threshold calculation
            curr_thres = threshold_calculator(rssi, ptr, next_point - 1, localmax_rssi);
            %Current TPL
            size_of_tpl_used = size(tpl_used);
            size_of_tpl_used = size_of_tpl_used(1, 1);
            current_tpl = tpl_used(size_of_tpl_used, 1);
            %Previous Threshold
            size_of_thres = size(threshold_rssi);
            size_of_thres = size_of_thres(1, 1);
            prev_thres = threshold_rssi(size_of_thres, 1);
            %New TPL
            new_tpl = change_tpl(current_tpl, crr, prev_thres, tpl);
            tpl_used = [tpl_used; new_tpl];
            threshold_rssi = [threshold_rssi; curr_thres];

        else
            %dynamic to static activity
            %Best Channel Quality time
            bcqt = [bcqt; cqt(rssi, ptr, next_point, transpose(localmax_rssi))];
            %Current RSSI Range
            crr = crr_dynamic_to_static(rssi, ptr, next_point);
            current_rssi_range = [current_rssi_range; crr];
            %Threshold calculation
            curr_thres = threshold_calculator(rssi, ptr, next_point - 1, localmax_rssi);
            %Current TPL
            size_of_tpl_used = size(tpl_used);
            size_of_tpl_used = size_of_tpl_used(1, 1);
            current_tpl = tpl_used(size_of_tpl_used, 1);
            %Previous Threshold
            size_of_thres = size(threshold_rssi);
            size_of_thres = size_of_thres(1, 1);
            prev_thres = threshold_rssi(size_of_thres, 1);
            %New TPL
            new_tpl = change_tpl(current_tpl, crr, prev_thres, tpl);
            tpl_used = [tpl_used; new_tpl];
            threshold_rssi = [threshold_rssi; curr_thres];

            d = 0;
            s = 1;
        end

        ptr = static_ptr;
        static_ptr = static_ptr + 1;

    else
        next_point = dynamic_points(dynamic_ptr, 1);

        if (d == 1)
            %dynamic to dynamic activity

            %Best Channel Quality time
            bcqt = [bcqt; cqt(rssi, ptr, next_point, transpose(localmax_rssi))];
            %New threshold RSSI
            curr_thres = threshold_calculator(rssi, ptr, next_point, localmax_rssi);
            %Current RSSI Range
            crr = (((rssi(ptr, 1) + rssi(next_point, 1)) / 2) + curr_thres) / 2;
            current_rssi_range = [current_rssi_range; crr];
            %Current TPL
            size_of_tpl_used = size(tpl_used);
            size_of_tpl_used = size_of_tpl_used(1, 1);
            current_tpl = tpl_used(size_of_tpl_used, 1);
            %Previous Threshold
            size_of_thres = size(threshold_rssi);
            size_of_thres = size_of_thres(1, 1);
            prev_thres = threshold_rssi(size_of_thres, 1);
            %New TPL
            new_tpl = change_tpl(current_tpl, crr, prev_thres, tpl);

            tpl_used = [tpl_used; new_tpl];
            threshold_rssi = [threshold_rssi; curr_thres];
        else
            %static to dymanic activity
            %Best Channel Quality time
            bcqt = [bcqt; cqt(rssi, ptr, next_point, transpose(localmax_rssi))];
            %current rssi range
            crr = crr_static_to_dynamic(rssi, ptr, next_point);
            current_rssi_range = [current_rssi_range; crr];

            %New threshold RSSI
            curr_thres = threshold_calculator(rssi, ptr, next_point, localmax_rssi);
            %Current TPL
            size_of_tpl_used = size(tpl_used);
            size_of_tpl_used = size_of_tpl_used(1, 1);
            current_tpl = tpl_used(size_of_tpl_used, 1);
            %Previous Threshold
            size_of_thres = size(threshold_rssi);
            size_of_thres = size_of_thres(1, 1);
            prev_thres = threshold_rssi(size_of_thres, 1);
            %New TPL
            new_tpl = change_tpl(current_tpl, crr, prev_thres, tpl);

            tpl_used = [tpl_used; new_tpl];
            threshold_rssi = [threshold_rssi; curr_thres];

            d = 1;
            s = 0;
        end

        ptr = dynamic_ptr;
        dynamic_ptr = dynamic_ptr + 1;

    end

end

clear size_dynamic;
clear size_static;
clear itr;
clear csv_file;
clear a;
clear dynamic_ptr;
clear static_ptr;
clear crr;
clear curr_thres;
clear current_tpl;
clear d;
clear new_tpl;
clear next_point;
clear no_of_packets;
clear prev_thres;
clear ptr;
clear s;
clear size_of_thres;
clear size_of_tpl_used;
clear tpl;
clear localmax
clear localmax_rssi;
clear localmax_acc
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

function s = is_static(array, idx, lmax_acc)
    s = false;
    localmax_acc = lmax_acc;

    for itr = idx - 1:-1:idx - 15

        if (itr < 1)
            break;
        end

        if (localmax_acc(itr, 1) == 1)
            mid_point = (array(idx, 1) + array(itr, 1)) / 2;
            diff_val = abs(mid_point - array(idx, 1));

            if (diff_val <= 0.0100)
                s = true;
                break;
            end

        end

    end

end

%cqt - Best channel quality time
function lqe = cqt(Array, s, e, lmax_arr)
    Array = transpose(Array);
    numerator = (e - s);
    localMax = lmax_arr;
    first_maxima = 0;
    last_maxima = 0;

    for itr = s + 1:e - 1

        if localMax(itr) == 1
            first_maxima = itr;
            break;
        end

    end

    for itr = e - 1:-1:s + 1

        if localMax(itr) == 1
            last_maxima = itr;
            break;
        end

    end

    lqe = numerator / (last_maxima - first_maxima);
end

function thres = threshold_calculator(Array, s, e, localmax_rssi)
    Array = transpose(Array);
    lmax = transpose(localmax_rssi);
    count = 0;
    sum = 0;

    for itr = s:e

        if (lmax(itr) == 1)
            sum = sum + Array(itr);
            count = count + 1;
        end

    end

    thres = sum / count;
end

function tpower = change_tpl(current_tpl, rssi_range, threshold, all_tpl)
    all_tpl = transpose(all_tpl);
    idx = 0;

    for itr = 1:5

        if (all_tpl(itr) == current_tpl)
            idx = itr;
            break;
        end

    end

    if (rssi_range > threshold)

        if (idx - 1 >= 1)
            tpower = all_tpl(idx - 1);

        else
            tpower = current_tpl;
        end

    else

        if (idx + 1 <= 5)
            tpower = all_tpl(idx + 1);

        else
            tpower = current_tpl;
        end

    end

end

function crr = crr_static_to_static(array, start)

    sum = 0;

    for i = start:start +29
        sum = sum + array(i, 1);
    end

    crr = sum / 29;
end

function crr = crr_static_to_dynamic(array, s, e)

    sum = 0;

    for i = s + 1:e - 1
        sum = sum + array(i, 1);
    end

    crr = sum / (e - s);
    crr = crr + (0.8 * (array(s, 1) + array(e, 1)));
    crr = crr / 2;
end

function crr = crr_dynamic_to_static(array, s, e)
    crr = (array(s, 1) + array(e, 1)) / 2;
    crr = crr + threshold_calculator(array, s, e, islocalmax(array));
    crr = crr / 2;
    crr = crr - (0.2 * (array(s, 1) + array(e, 1)));
end
