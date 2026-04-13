
% Beres instructions
%1) before analyzing the data, write down and save what you think the data regarding the airflow will show. (mean flow, volume changes, response time, etc.)
%Done

%making table 

%subject_ids = [1,2,3, 5, 6, 9, 10, 11, 13, 14, 15, 18, 19, 20, 21, 22, 23, 24,25,26,27,28,29];
subject_ids = [1,2,3];
%only subjects 1-3 but easily expandable
fs = 1200;
label = [2,4,6];
%low medium high 

resultMatrix =[["subj_id", "Label", "mean_airflow","mean_negairflow", "mean_resp_time", "mean_volume"]];
respMatrix =[];
%top labels

%Note: Understand each unit, not properly finding units for resp_time for
%ex, it is in ms so multiply by 10^3

for i = 1:length(subject_ids)
%iterate through all subjects
    currSub = subject_ids(i);
    filename = sprintf('subject_%d.mat', currSub);
    %curr file
    loadedFile = load(filename);
    subject_data = loadedFile.subject_data;


    
    for j = 1:length(label)
        curLabel  = label(j);
        labelID = find(subject_data(:, 2) == curLabel);
        %matrix where all label == curLabel

        %mean airflow calc
        %index for if col 2 = labelIdx
        % mean that
        neginhalation = smooth(subject_data(labelID, 3)) < 0;
        inhalation_vals = smooth(subject_data(labelID, 3)) >= 0;
        target_mean = mean(smooth(inhalation_vals));
        neg_mean_airflow = mean(neginhalation);
        % very simple

        %mean response time
        cueIdx  = find(subject_data(labelID, 29) == 2);
        respIdx = find(subject_data(labelID, 29) == 3);
        %time for stimulus and buttn press
        
        if length(cueIdx) == length(respIdx) && ~isempty(cueIdx)
            respTimes = (respIdx - cueIdx) / fs;
            mean_resp_time = mean(respTimes);
        else
            mean_resp_time = NaN;  % mismatch or missing
        end
         %mean volume inhaled



         % Note: This is not what beres wanted
         % take every spike in airflow, integrate it,
         % then find the mean of each breath.
         % Column 3 = airflow; only count positive (inhalation)
        airflow_segment = subject_data(labelID, 3);
        inhalation = airflow_segment;
        inhalation(inhalation < 0) = 0; % only inhalation (positive flow)
        inhalation = smooth(inhalation);
        %filter
        
        
        spike_areas = [];
        k = 1;
    while k <= length(inhalation)
        if inhalation(k) == 0 && k < length(inhalation) && inhalation(k+1) ~= 0
        % Find the next zero crossing
        next_zero = k + 1;
            while next_zero < length(inhalation) && inhalation(next_zero) ~= 0
            next_zero = next_zero + 1;
            end

            % Integrate from k to next_zero (inclusive)
            spike_areas(end+1) = trapz(inhalation(k:next_zero))/fs;
            % this returns a 564L for 1 2, with lungs around ~6L this
            %makes no sense 
            %i hope dividing by fs works
            %returns 0.47 1 2 which makes more sense but I can't understand
            

            % Jump to next zero
            k = next_zero;
        else
            k = k + 1;
        end
    end

mean_volume = mean(spike_areas);
         

         %std dev of responses (overall and per label)
        %todo
    newData = [subject_ids(i), label(j), target_mean, neg_mean_airflow, mean_resp_time, mean_volume];
    resultMatrix = [resultMatrix; newData];
    respMatrix = [respMatrix; newData];
     
    end

    

   

    
end


resultMatrix
respMatrix
save('respMatrix.mat','respMatrix')
%2) after make the table, write down what the data actually shows
%3) make 1 figure (powerpoint slide) of the data or example of  what you think shows points 1 and 2 and explain why this figure is important.
% For each subject number
%at each level extract
%mean airflow
%Mean response time
%Mean volume  inhaled