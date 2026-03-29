%average response time for 10 second windows


subject_ids = [1, 2, 3];
fs          = 1200;
label      = [2, 4, 6];   % low, medium, high cognitive load

WINDOW_SIZE = 10;           % seconds
NUM_WINDOWS = 3;            % 0-10, 10-20, 20-30
% possibly expandable
win_samples = WINDOW_SIZE * fs;

header = {'SubjID', 'Label', ...
          'Airflow_0_10s',  'RT_0_10s', ...
          'Airflow_10_20s', 'RT_10_20s', ...
          'Airflow_20_30s', 'RT_20_30s'};

labelledMatrix = header;   % readable
numericMatrix  = [];       % computable

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

        cueIdx  = find(subject_data(labelID, 29) == 2);
        respIdx = find(subject_data(labelID, 29) == 3);
        %time for stimulus and buttn press

        abs_cue  = labelID(cueIdx);
        abs_resp = [];
        if length(cueIdx) == length(respIdx) && ~isempty(cueIdx)
            abs_resp = labelID(respIdx);
        end
        %check if indices are the same and do exist

        airflow_array = cell(NUM_WINDOWS, 1);
        response_array = cell(NUM_WINDOWS, 1);
        %hm
        for t = 1:length(abs_cue)
            trial_start = abs_cue(t);
            % Get the absolute sample index where this trial's cue appeared
            for w = 0:(NUM_WINDOWS - 1)
                ws = trial_start + w * win_samples;
                % first sample
                we = trial_start + (w + 1) * win_samples - 1;
                %last sample
                we = min(we, size(subject_data, 1));
                %if the window is larger then data, end at last data
 
                if ws > size(subject_data, 1); break; end
                %edge case if window start is past the data
 
                
                flow = smooth(subject_data(ws:we, 3));
                %airflow
                win_airflow{w+1} = [win_airflow{w+1}; flow(flow >= 0)];
                %only positive
 
               
                if ~isempty(abs_resp) && t <= length(abs_resp)
                    %if resp is not empty and time is less than length of
                    %resp
                    rr = abs_resp(t);
                    %sample index for this section
                    if rr >= ws && rr <= we
                        %only inside window
                        win_rt{w+1} = [win_rt{w+1}; (rr - trial_start) / fs];
                        %turn to seconds and store
                    end
                end
            end
        end
 
        % Collapse accumulators to scalar means
        row_nums = [currSub, curLabel];
        % row with subject and label
        for w = 1:NUM_WINDOWS
            row_nums(end+1) = nanmean(win_airflow{w});
            %mean for inhalation samples
            row_nums(end+1) = nanmean(win_rt{w});
            %mean for response time samples 
        end
 
        numericMatrix  = [numericMatrix;  row_nums];
        labelledMatrix = [labelledMatrix; num2cell(row_nums)];
        %build matrix, loop
    end
end

%NOTE: There is no response time returned for 10-20s and 20-30s idk why
%maybe this code is broken but I am not sure

disp(labelledMatrix);
disp(numericMatrix);


save('windowed_rt_airflow.mat', 'labelledMatrix', 'numericMatrix');
fprintf('Saved to windowed_rt_airflow.mat\n');