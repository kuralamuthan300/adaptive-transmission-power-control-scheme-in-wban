clear;
CSV_file = csvread("Dataset/WithoutSeq/test.csv");

numFeatures = 6;
numHiddenUnits = 150;
numClasses = 6;

layers = [ 
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];



clear numFeatures;
clear numHiddenUnits;
clear numClasses;

maxEpochs = 10;
miniBatchSize = 20;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');

total_samples = size(CSV_file);

walking = magic(0);
walking_up = magic(0);
walking_down = magic(0);
sitting = magic(0);
standing = magic(0);
jogging = magic(0);
for a = 1:total_samples(1,1)
   row = CSV_file(a,:);
   inertial_values=row(3:8);
   label=row(9);
   
    if label == 0
        standing= [standing;inertial_values];
    end
    if label == 1
    walking = [walking;inertial_values];
    end
    if label == 2
    walking_up= [walking_up;inertial_values];
    end
    if label == 3
        walking_down= [walking_down;inertial_values];
    end
    if label == 4
        sitting= [sitting;inertial_values];
    end
    if label == 5
        jogging= [jogging;inertial_values];
    end
    
end

clear a;
Xtrain = cell(0,0);
Xtrain = {transpose(walking);transpose(walking_up);transpose(walking_down);transpose(sitting);transpose(standing);transpose(jogging)};

stand_label = zeros(1,getSize(standing));
for i = 1 : size(standing)
  stand_label(i) = 0;
end

Wal_label = zeros(1,getSize(walking));
for i = 1 : size(walking)
  Wal_label(i) = 1;
end

Walup_label = zeros(1,getSize(walking_up));
for i = 1 : size(walking_up)
  Walup_label(i) = 2;
end

Waldown_label = zeros(1,getSize(walking_down));
for i = 1 : size(walking_down)
  Waldown_label(i) = 3;
end

sit_label = zeros(1,getSize(sitting));
for i = 1 : size(sitting)
  sit_label(i) = 4;
end

jogg_label = zeros(1,getSize(jogging));
for i = 1 : size(jogging)
  jogg_label(i) = 5;
end
%c = row1;
%c = [cell; row2]


clear i;
clear walking_down;
clear walking_up;
clear sitting;
clear standing;
clear walking;

clear total_samples;
clear row;
clear inertial_values;
clear label;

Wal_label = categorical(Wal_label);
Walup_label = categorical(Walup_label);
Waldown_label = categorical(Waldown_label);
sit_label = categorical(sit_label);
stand_label = categorical(stand_label);
jogg_label = categorical(jogg_label);

Ytrain={Wal_label;Walup_label;Waldown_label;sit_label;stand_label;jogg_label};

net = trainNetwork(Xtrain,Ytrain,layers,options);







function noofsamples = getSize(activity)

s = size(activity);
noofsamples=s(1,1);

end
