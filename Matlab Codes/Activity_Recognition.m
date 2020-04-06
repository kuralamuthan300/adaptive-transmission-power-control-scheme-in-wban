clear;
%Training file
CSV_file = preprocessor(csvread("Dataset/WithSeq/indoor1.csv"));
%Test file
CSV_file_pred = preprocessor(csvread("Dataset/WithSeq/indoor1.csv"));

total_samples = size(CSV_file);

% numFeatures = 4;
numHiddenUnits = 100;
numClasses = 5;

% layers = [ 
%     sequenceInputLayer(numFeatures)
%     lstmLayer(numHiddenUnits,'OutputMode','sequence')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer];


layers = [ ...
    sequenceInputLayer(4)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]

 maxEpochs = 70;
 miniBatchSize = 10;

%  options = trainingOptions('adam', ...
%      'ExecutionEnvironment','cpu', ...
%      'GradientThreshold',1, ...
%      'MaxEpochs',maxEpochs, ...
%      'MiniBatchSize',miniBatchSize, ...
%      'SequenceLength','longest', ...
%      'Shuffle','never', ...
%      'Verbose',0, ...
%     'Plots','training-progress');

options = trainingOptions('sgdm', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');




walking = magic(0);
walking_up = magic(0);
walking_down = magic(0);
sitting = magic(0);
standing = magic(0);
for a = 1:total_samples(1,1)
   row = CSV_file(a,:);
   inertial_values=row(3:6);
   label=row(8);
   
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
        standing= [standing;inertial_values];
    end
end

clear row;

Xtrain = cell(0,0);
Xtrain = {transpose(walking);transpose(walking_up);transpose(walking_down);transpose(sitting);transpose(standing)};


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

stand_label = zeros(1,getSize(standing));
for i = 1 : size(standing)
  stand_label(i) = 5;
end
%c = row1;
%c = [cell; row2]


Wal_label = categorical(Wal_label);
Walup_label = categorical(Walup_label);
Waldown_label = categorical(Waldown_label);
sit_label = categorical(sit_label);
stand_label = categorical(stand_label);

Ytrain={Wal_label;Walup_label;Waldown_label;sit_label;stand_label};




%Model training
net = trainNetwork(Xtrain,Ytrain,layers,options);

%Activity classification
Xtest = transpose(CSV_file_pred(:,[3:6]));
Ypred = classify( net, Xtest);
Ypred = double(Ypred);



%Saving the data samples in their corresponding matrix

Walk_pred = magic(0);
Walk_Up_pred = magic(0);
Walk_Down_pred = magic(0);
Sit_pred = magic(0);
Stand_pred = magic(0);

for i = 1:total_samples(1,1)

    if(Ypred(i)==1)
    Walk_pred = [Walk_pred;CSV_file_pred(i,:)];
    end
    if(Ypred(i)==2)
    Walk_Up_pred = [Walk_Up_pred;CSV_file_pred(i,:)];
    end
    if(Ypred(i)==3)
    Walk_Down_pred = [Walk_Down_pred;CSV_file_pred(i,:)];
    end
    if(Ypred(i)==4)
    Sit_pred = [Sit_pred;CSV_file_pred(i,:)];
    end
    if(Ypred(i)==5)
    Stand_pred = [Stand_pred;CSV_file_pred(i,:)];
    end
    
end


clear walking;
clear walking_down;
clear walking_up;
clear sitting;
clear standing;
clear a;
clear Wal_label;
clear Waldown_label;
clear Walup_label;
clear sit_label;
clear stand_label;
clear total_samples;
clear maxEpochs;
clear miniBatchSize;
clear numFeatures;
clear numHiddenUnits;
clear numClasses;
clear Xtrain;
clear Ytrain;
clear label;
clear i;
clear inertial_values;
clear CSV_file;
clear CSV_file_pred;
clear layers;
clear net;
clear options;
clear Xtest;
clear Ypred;


function noofsamples = getSize(activity)

s = size(activity);
noofsamples=s(1,1);

end


function file = preprocessor(CSV_file)
Acc_x = CSV_file(:,3);
Acc_y = CSV_file(:,4);
Acc_z = CSV_file(:,5);

total_samples = size(CSV_file);
Acc_Mag = zeros(total_samples(1,1),1);


%Calculating Accleration magnitude from Acc_X,Acc_Y,Acc_Z
for itr = 1:total_samples(1,1)
    sum = (Acc_x(itr,1)^2)+(Acc_y(itr,1)^2)+(Acc_z(itr,1)^2);
    Acc_Mag(itr,1) = sum^0.5;
end

Acc_Mag=sgolayfilt(Acc_Mag,6,21);

left  = CSV_file(:,[1:2]);
right = CSV_file(:,[6:10]);

file = left;
file = [file Acc_Mag];
file = [file right];



end
