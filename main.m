%all these files have the same variable name and physioData does not open

%how do I handle this data?

clear all ;
close all ;
clc ;
load dataNames.mat
subject_ids = [1 , 2 , 3 , 5 , 6 , 9]; % Add / remove subject numbers as needed
fs =1200;

for i = 1: length ( subject_ids )
subj_id = subject_ids ( i ) ;
% Construct the filename
filename = sprintf ( 'subject_%d.mat' , subj_id ) ;
load ( filename , 'subject_data')
% Process data here
for thisLabel =2:2:6
% Find the indexes associated with this label
labelIdx = find ( subject_data (: ,2) == thisLabel ) ;
% Print the max airflow

%SUBJECT DATA IS FUCKING THIS SHIT UP WHAT IS THIS??????

max ( subject_data ( labelIdx ,3) )
% Find the mean response time
% Get the indexes for the cue and button response
cueIdx = find ( subject_data ( labelIdx ,29) ==2) ;
respIdx = find ( subject_data ( labelIdx ,29) ==3) ;
% Convert from samples to time
respTimes = ( respIdx - cueIdx ) / fs ;
% Print the mean value
mean ( respTimes )
end
end

%sample code given by Beres, what does this do???

%% Szilard extra code for viewing data
figure();
yyaxis left
plot(subject_data(:,3));
yyaxis right
plot(subject_data(:,2));


% suppose you only want high load!

highIdx = find(subject_data(:,2)==6);

highairflow = subject_data(highIdx,3);

figure();
plot(highairflow)

myMatrixNames = {'SN','Label'};

% Beres instructions
%1) before analyzing the data, write down and save what you think the data regarding the airflow will show. (mean flow, volume changes, response time, etc.)
%2) after make the table, write down what the data actually shows
%3) make 1 figure (powerpoint slide) of the data or example of  what you think shows points 1 and 2 and explain why this figure is important.


% For each subject number
%at each level extract

%mean airflow
%Mean response time
%Mean volume  inhaled



