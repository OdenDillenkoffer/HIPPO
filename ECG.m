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

%maybe add filters here
%also load data
load("subject_1_no_load.mat");
%initial data in table
L = array2table(dataM,"VariableNames",dataNames);




%trying to add other loads
%data is called same things need to differentiate between loads
%using struct 
%1 no load, 2 medium load, 3 high load, maybe adding more subjects later 
subject1(1).fileLoc = "subject_1_no_load.mat";

subject1(2).fileLoc = "subjectTimeSeriesForStudents/subject_1_medium_load.mat";

subject1(3).fileLoc = "subjectTimeSeriesForStudents/subject_1_high_load.mat";
%filters
load("Filters/highpass.mat");
NumHP = Num;  % rename highpass numerator before it gets overwritten

load("Filters\CombIIRforn60.mat");  % now Num and Den belong to the comb IIR





%So for some reason these files have different sizes and
%as such I have to make it so that this system can acomadate
% that (I noticed the typo)
allSignalNames = {};
for i = 1:3
    raw = load(subject1(i).fileLoc);
    dn = raw.dataNames;
    sn    = find(strcmp(dn, 'SN'));
    lb    = find(strcmp(dn, 'Label'));
    tk    = find(strcmp(dn, 'Task'));
    tc    = find(strcmp(dn, 't'));
    ab    = find(strcmp(dn, 'AbdomenRespi'));
    skip  = [sn, lb, tk, tc, ab];
    cols  = setdiff(1:length(dn), skip);
    allSignalNames{i} = dn(cols);
end
sharedSignalNames = intersect(intersect(allSignalNames{1}, allSignalNames{2}), allSignalNames{3})

%new loop for different levels
dataMAll =[];
outputMAll = [];
for i = 1:3
 raw = load(subject1(i).fileLoc);
 dataM = raw.dataM;
 dataNames = raw.dataNames;

 % slop columns
%techinique from claude, hard coding was causing issues
snCol    = find(strcmp(dataNames, 'SN'));
labCol   = find(strcmp(dataNames, 'Label'));
taskCol  = find(strcmp(dataNames, 'Task'));
tCol     = find(strcmp(dataNames, 't'));
AbdCol     = find(strcmp(dataNames, 'AbdomenRespi'));
%AbdCol is NaN fucks up filters

skipCols = [snCol, labCol, taskCol, tCol, AbdCol];
allCols  = 1:length(dataNames);
dataCols = setdiff(allCols, skipCols); % Just the actual signal data
signalNames = dataNames(dataCols);
[~, keepIdx] = intersect(signalNames, sharedSignalNames, 'stable');
dataCols = dataCols(keepIdx);
signalNames = dataNames(dataCols);

 %hopefully filters work here
%to data hm
dataM(:, dataCols) = filtfilt(NumHP, 1, dataM(:, dataCols));
%now 60Hz filter
dataM(:, dataCols)  =filtfilt(Num, Den, dataM(:, dataCols));

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
 numDataCols = length(dataCols);
 outputM = zeros(numPairs * numWindows, 5 + numDataCols);

for p = 1:numPairs
    for w = 1:numWindows
        % Create masks for the current subject/label and current time slot
        pairMask = (pairIdx == p);
        timeMask = (t >= windows(w,1)) & (t < windows(w,2));
        currentTask = dataM(find(pairIdx == p, 1), taskCol);
        
        % Combine masks
        finalMask = pairMask & timeMask; %currentTask is unneeded

        %this whole think handles data organization
       
        % Store identifiers
        outputM(rowCounter, 1) = uniquePairs(p, 1); % SubjectID
        outputM(rowCounter, 2) = uniquePairs(p, 2); % Label
        outputM(rowCounter, 3) = w;                 % Window Index
        outputM(rowCounter, 4) = currentTask; %Task
        outputM(rowCounter, 5) = i; %index
        
        %Not having task was fucking up the output
        
        
        if any(finalMask)
            
            % Mean of all data columns for this specific window
            outputM(rowCounter, 6:end) = mean(dataM(finalMask, dataCols), 1, 'omitnan');
            %meat of this script is just a simple mean and omitting NaN
        end
        
        rowCounter = rowCounter + 1;
    end
end
outputMAll = [outputMAll; outputM];
dataMAll = [dataMAll;dataM(:, dataCols)];
end








% 4. Formatting Output Table
%all data is in outputM
finalNames = [{'SubjectID', 'Label', 'Window', 'Task', 'LoadIdx'}, signalNames];
T = array2table(outputMAll,"VariableNames",finalNames);
T2 = array2table(dataMAll,"VariableNames",signalNames);

disp(T)


%Napoli FFT

% Graphs.m
%Actually do science and work on the data 
Y = fft(diff(L.DiaphragmLeft16));
L2 = length(L.DiaphragmLeft16);
Fs = 1200;
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs/L2*(0:(L2/2));
plot(f,P1,"LineWidth",3) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

figure;
plot((abs(fft(diff(L.DiaphragmLeft16)))))


toSee = L.ScaleneTL - L.ScaleneBL;
figure 
plot(zscore(L.Airflow))
hold on
plot(zscore(toSee))
%% 
Fs = 1200;
[popen,fopen] = periodogram(toSee,[],[],Fs);

plot(fopen,20*log10(abs(popen)),'--')
ylabel('Power/frequency (dB/Hz)')
xlabel('Frequency (Hz)')
title('Power Spectrum')
legend('Unfiltered')
grid