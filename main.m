
% Beres instructions
%1) before analyzing the data, write down and save what you think the data regarding the airflow will show. (mean flow, volume changes, response time, etc.)
%Done

%making table 

subject_ids = [1:1:3];
%only subjects 1-3 but easily expandable
fs = 1200;
label = [2,4,6];
%low medium high 

resultMatrix =[["subj_id", "Label", "mean_airflow", "mean_resp_time", "mean_volume"]];
%top labels

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
        inhalation_vals = airflow_segment(airflow_segment > 0);
        target_mean = mean(inhalation_vals);
        % very simple

        %mean response time
        cueIdx  = find(subject_data(labelID, 29) == 2);
        respIdx = find(subject_data(labelID, 29) == 3);
        
        if length(cueIdx) == length(respIdx) && ~isempty(cueIdx)
            respTimes = (respIdx - cueIdx) / fs;
            mean_resp_time = mean(respTimes);
        else
            mean_resp_time = NaN;  % mismatch or missing
        end
         %mean volume inhaled

         % Column 3 = airflow; only count positive (inhalation)
        airflow_segment = subject_data(labelID, 3);
        inhalation = airflow_segment;
        inhalation(inhalation < 0) = 0; % only inhalation (positive flow)
        mean_volume = sum(inhalation) / fs; % in units of [airflow_unit * seconds]

         %std dev of responses (overall and per label)
        %todo
    newData = [subject_ids(i), label(j), target_mean, mean_resp_time, mean_volume];
    resultMatrix = [resultMatrix; newData];
     
    end

    

   

    
end


resultMatrix
%2) after make the table, write down what the data actually shows
%3) make 1 figure (powerpoint slide) of the data or example of  what you think shows points 1 and 2 and explain why this figure is important.
% For each subject number
%at each level extract
%mean airflow
%Mean response time
%Mean volume  inhaled