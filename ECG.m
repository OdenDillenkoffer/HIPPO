 %do the windowed times for this aswell

%plot on same plots as other signals

%see if they directly relate, if not

%design something to actually compare them

%Using for muscle data

%all subject 1 no load



%Beam forming

%EMG to Victorias stuff on the float ???

%all same subject and same load, so just mean the the columns? 
% Define our windows (0-10s, 10-20s, 20-30s)
windows = [0, 10; 10, 20; 20, 30];
numWindows = size(windows, 1);

% slop columns
%techinique from claude, hard coding was causing issues
snCol    = find(strcmp(dataNames, 'SN'));
labCol   = find(strcmp(dataNames, 'Label'));
taskCol  = find(strcmp(dataNames, 'Task'));
tCol     = find(strcmp(dataNames, 't'));

skipCols = [snCol, labCol, taskCol, tCol];
allCols  = 1:size(dataM, 2);
dataCols = setdiff(allCols, skipCols); % Just the actual signal data
signalNames = dataNames(dataCols);

% Pull vectors for easy logic handling
t     = dataM(:, tCol);
SN    = dataM(:, snCol);
Label = dataM(:, labCol);

%Find unique Subject/Label pairs
[uniquePairs, ~, pairIdx] = unique([SN, Label], 'rows', 'stable');
numPairs = size(uniquePairs, 1);
%this is kinda redundant for this datafile,
%however it actually matters if I had a bunch of subjects and labels
%as it ties them together to properly look at the data
rowCounter = 1;

%Loop through pairs and windows to calculate means
for p = 1:numPairs
    for w = 1:numWindows
        % Create masks for the current subject/label and current time slot
        pairMask = (pairIdx == p);
        timeMask = (t >= windows(w,1)) & (t < windows(w,2));
        currentTask = dataM(find(pairIdx == p, 1), taskCol);
        
        % Combine masks
        finalMask = pairMask & timeMask & currentTask;

        %this whole think handles data organization
        
        % Store identifiers
        outputM(rowCounter, 1) = uniquePairs(p, 1); % SubjectID
        outputM(rowCounter, 2) = uniquePairs(p, 2); % Label
        outputM(rowCounter, 3) = w;                 % Window Index
        outputM(rowCounter, 3) = currentTask;       %Task
        %Not having task was fucking up the output
        
        
        if any(finalMask)
            % Mean of all data columns for this specific window
            outputM(rowCounter, 5:end) = mean(dataM(finalMask, dataCols), 1, 'omitnan');
            %meat of this script is just a simple mean and omitting NaN
        end
        
        rowCounter = rowCounter + 1;
    end
end

% 4. Formatting Output Table
%all data is in outputM
finalNames = [{'SubjectID', 'Label', 'Task', 'Window'}, signalNames];
T = array2table(outputM,"VariableNames",finalNames);
disp(T)


